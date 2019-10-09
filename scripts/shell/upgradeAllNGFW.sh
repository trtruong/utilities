#!/usr/bin/env bash
## This script will apply ansible playbook to all NGFWs in the specified environment

### Require a environment to execute
if [[ $# -ne 2 ]] ; then
    echo "execute $0 with ENV <staging|prod> <playbook name.yml>"
    exit 1
fi

ansible_playbook=$2

pushd ../../ansible
REGIONS=(us-west-1 us-west-2 us-east-1 us-east-2 eu-west-1 eu-west-2)
for REGION in "${REGIONS[@]}"; do
  r=$(echo $REGION | sed 's/-\(.\).*-/\1/')
  # Set domain name for bastion host base on environment
  case $1 in
    'stage'|'stg'|'staging')
      DOMAIN='staging.forcepoint.io'
      env_short='s'
      env='stg'
      sed "s/REGION/$r/" dep-ssh.cfg.tpl | sed "s/DOMAIN/$DOMAIN/" | sed "s/ENV/stg/" > dep-ssh.cfg
      ;;
    'prod'|'production')
      DOMAIN='forcepoint.io'
      sed "s/REGION/$r/" dep-ssh.cfg.tpl | sed "s/DOMAIN/$DOMAIN/" | sed "s/ENV/prod/" > dep-ssh.cfg
      env_short='p'
      env='prod'
      ;;
    *)
      exit 1
      ;;
  esac

  sed "s/REGION/$r/" ansible.cfg.tpl > ansible.cfg
  sed "s/REGION/$REGION/" ../scripts/python/ec2.ini.tpl > ../scripts/python/ec2.ini
  # Login to Prod in order of invoke BLESS lambda to sign SSH cert
  source okta-login pe-prod
  ### Get Ansible encryption passwrord
  if [ -f ~/.vault_pass.txt ]; then
    aws ssm get-parameter --name "/COPS/ansible/vault-pass" --with-decryption --region us-east-2 | jq -r '.Parameter.Value' >  ~/.vault_pass.txt
  fi
  ### Sign ssh key to access bastion hosts
  bless_client -i bastion-host-${r}.${DOMAIN}
  if [ "$env_short" == "s" ]; then
    source okta-login pe-stg
  fi

  ## Get NGFW SSH private key
  if [ ! -f ~/.ssh/cloudops-dep-${env}_rsa ]; then
    aws ssm get-parameter --name "/NGFW/ssh-keypairs/cloudops-dep_private" --with-decryption --region us-east-2 | jq -r '.Parameter.Value' > ~/.ssh/cloudops-dep-${env}_rsa
    chmod 600 ~/.ssh/cloudops-dep-${env}_rsa
  fi

  ansible-playbook ${ansible_playbook} -vvv -e "hostgroup=tag_Name_vm_${r}_cpt_${env_short}_edge_ngfw670"
done
popd
