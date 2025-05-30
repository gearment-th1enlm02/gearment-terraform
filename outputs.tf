output "app_instance_id" {
    description = "Public IP of the app instance"
    value       = module.instances.instances["${var.aws_project}-app"].public_ip
}

# To print the outputs:
# - terraform output -json s3_access_keys
# - terraform output -json s3_access_keys > s3_access_keys.json
output "s3_access_keys" {
    description = "Map of IAM user names to their access key IDs and secret access keys"
    value       = module.s3.access_keys
    sensitive   = true
}