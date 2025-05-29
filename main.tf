module "vpc" {
  source = "./modules/vpc"

  name = var.aws_project

  cidr                 = var.aws_vpc_config.cidr_block
  enable_dns_hostnames = var.aws_vpc_config.enable_dns_hostnames
  enable_dns_support   = var.aws_vpc_config.enable_dns_support
  public_subnets       = var.aws_vpc_config.public_subnets_cidr
  private_subnets      = var.aws_vpc_config.private_subnets_cidr
  azs                  = local.selected_azs
  map_public_ip_on_launch = true
  enable_nat_gateway = var.aws_vpc_config.enable_nat_gateway
}

module "app_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-app-sg"
    description = "Security group for app instance"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
        {
            description = "Allow HTTP Access"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            description = "Allow HTTPS Access"
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            description = "Allow SSH Access"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        }
    ]

    egress_rules = [
        {
            description = "Allow all outbound traffic"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = "0.0.0.0/0"
        }
    ]
}

module "instances" {
  source = "./modules/instance"

  subnet_id = module.vpc.private_subnets_id[0]
  security_groups = [module.servers_sg.id]
  key_name = var.aws_keyname
  ami = local.ec2_ami
  instance_type = "t2.micro"
  ebs_size = 8
  instances = [
    {
      name = "${var.aws_project}-app"
      private_ips = var.gearment_app_private_ips
      subnet_id = module.vpc.public_subnets_id[0]
      instance_type = var.gearment_app_instance_type
      ebs_size = var.gearment_app_ebs_size
      security_groups = [module.app_sg.id]
      # user_data = file("./scripts/init.sh")
    },
  ]
}
