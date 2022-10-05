# Output the Public IP Address
output "ip_address" {
  value = aws_instance.apache2_server.public_ip
}

# Uncomment for Section 5.3.4 - Trigger the VCS
// output "ip_address_1" {
//   value = aws_instance.apache2_server_1.public_ip
// }