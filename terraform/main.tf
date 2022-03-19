module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${local.prefix}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets       = ["10.0.0.0/24"]
  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "this" {
  name = "${local.prefix}-ec2-sg"
  tags = {
    Name = "${local.prefix}-ec2-sg"
  }
  vpc_id = module.vpc.vpc_id
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
  ]
}

resource "aws_iam_role" "this" {
  name                 = "${local.prefix}-ec2-role"
  max_session_duration = 3600
  path                 = "/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.prefix}-ec2-role"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  count                       = local.instance_count
  ami                         = local.ami_id
  instance_type               = local.instance_type
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.this.id]
  subnet_id                   = module.vpc.public_subnets[0]
  tags = {
    Name = "${local.prefix}-instance-${count.index}"
  }
}