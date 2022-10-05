# Output the Public IP Address
output "ip_address" {
  value = aws_instance.apache2_server.public_ip
}