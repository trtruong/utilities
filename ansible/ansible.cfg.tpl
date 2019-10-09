[defaults]
inventory           = ../scripts/python/ec2.py
vault_password_file = ~/.vault_pass.txt
host_key_checking   = False
forks               = 3
timeout             = 60

[ssh_connection]
ssh_args = -F ./dep-ssh.cfg -o ControlMaster=auto -o ControlPersist=30m
control_path = ~/.ssh/REGION-%%r@%%h:%%p
