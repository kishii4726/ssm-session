locals {
  prefix = "ssm-session-test"
  # Amazon Linux 2 AMI (HVM) - Kernel 4.14, SSD Volume Type
  ami_id         = "ami-0521a4a0a1329ff86"
  instance_type  = "t3.nano"
  instance_count = 10
}