# output "ssh_privtave_key" {
#   value = "${tls_private_key.ssh.private_key_pem}"
# }
# output "ssh_public_key" {
#   value = "${var.ssh_ecs_instance_public_key}"
# }
# output "example_public_dns" {
#   value = "${aws_instance.superman.public_dns}"
# }
# output "example_public_addr" {
#   value = "${aws_instance.superman.public_ip}"
# }
# output "icp_url" {
#   value = "https://${ibm_compute_vm_instance.master.0.ipv4_address}:8443"
# }

output "ssh_key" {
  value="${tls_private_key.ssh.private_key_pem}"
}

output "module_superman_ecs_public_ip" {
  value = "${module.superman.public_ip}"
}

output "module_superman_ecs_hostname" {
  value = "${module.superman.hostname}"
}
