Host 10.0.*.*
  User aws
  ProxyCommand ssh -W %h:%p bastion-host-REGION.DOMAIN
  IdentityFile ~/.ssh/cloudops-dep-ENV_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host *.DOMAIN
  Hostname bastion-host-REGION.DOMAIN
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/id_rsa
  ControlMaster auto
  ControlPath ~/.ssh/REGION-%r@%h:%p
  ControlPersist 5m
  UserKnownHostsFile /dev/null
