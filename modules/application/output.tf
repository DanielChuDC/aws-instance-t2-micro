### Output
output "hostname" {
  value = "${aws_instance.superman.private_dns}"
}

output "public_ip" {
  value = "${aws_instance.superman.public_ip}"
}
