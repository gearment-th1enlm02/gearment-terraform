variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "aws_keyname" {
  description = "AWS keypair name"
  type        = string
}

variable "aws_environment" {
  description = "Environment"
  type        = string
}

variable "aws_project" {
  description = "Project"
  type        = string
}

variable "aws_owner" {
  description = "Owner"
  type        = string
}

variable "aws_vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block                   = string,
    enable_dns_support           = bool,
    enable_dns_hostnames         = bool,
    public_subnets_cidr          = list(string),
    private_subnets_cidr         = list(string),
    number_of_availability_zones = number,
    enable_nat_gateway           = bool
  })
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = ""
}

variable "gearment_app_instance_type" {
  description = "Application instance type"
  type        = string
  default     = "t2.micro"
}

variable "gearment_app_ebs_size" {
  description = "Application EBS size"
  type        = number
  default     = 8
}

variable "gearment_app_private_ips" {
  description = "Private IPs for the application instance"
  type        = list(string)
  default     = []
}

variable "s3_buckets" {
  description = "List of S3 buckets to create with their configurations"
  type = list(object({
    name              = string
    versioning_enabled = bool
    tags              = optional(map(string), {})
  }))
  default = []
}

variable "s3_policies" {
  description = "List of IAM policies for S3 access"
  type = list(object({
    name = string
    statements = list(object({
      effect        = string
      actions       = list(string)
      bucket_names  = list(string)
      resource_type = string
    }))
    users = optional(list(string), [])
  }))
  default = []
}

variable "s3_users" {
  description = "List of IAM user names to create and attach to S3 policies"
  type        = list(string)
  default     = []
}
