output "public_ip" {
  value = aws_instance.demo.public_ip
}

output "ssh_command" {
  value = "ssh -i private_key.pem ubuntu@${aws_instance.demo.public_ip}"
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
