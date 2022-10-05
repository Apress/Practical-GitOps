# Output the Public IP Address
output "ip_address" {
  value = aws_instance.apache2_server.public_ip
}

# Uncomment for Section 6.4.1 - New Feature Request
// output "ip_address_1" {
//   value = aws_instance.apache2_server_1.public_ip
// }