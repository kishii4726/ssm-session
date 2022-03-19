# ssm-session
Tools to ease the use of Session Manager.

# Requirements
- bash 5.0.17
- terraform  1.1.4

# Usage
```
./ssm_session.sh <AWS profile name>
```

# Creating Sample Resources
**Warning: Execute the following to create 10 EC2 instances of t3.nano.**

Create an EC2 instance to test this tool.

```
$ cd terraform
$ terraform init
$ terraform apply

# Clean up
$ terraform destroy
```