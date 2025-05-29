output "app_instance_id" {
    description = "Public IP of the app instance"
    value       = aws_instance.instances["${var.aws_project}-app"].public_ip
}