provider "aws" {
  version = "~> 2.0"
}

# Create tls private key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096

  # Exec in local computer and put it in the ssh
  provisioner "local-exec" {
    command = "cat > ${var.ssh_key_name} <<EOL\n${tls_private_key.ssh.private_key_pem}\nEOL"
  }

  # Exec in local computer and put it in the pem
  provisioner "local-exec" {
    command = "cat > ${var.ssh_ecs_instance_pem_key} <<EOL\n${tls_private_key.ssh.private_key_pem}\nEOL"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${var.ssh_key_name}"
  }

  # Exec in local computer and put it in the ssh public key
  provisioner "local-exec" {
    command = "cat > ${var.ssh_ecs_instance_public_key} <<EOL\n${tls_private_key.ssh.public_key_openssh}\nEOL"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${var.ssh_ecs_instance_public_key}"
  }
}

# Create aws vpc
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16" # which is the biggest
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "superman-env"
  }
}

# Create subnet in my_vpc
# Note the interpolated string: ${aws_vpc.my_vpc.id}. We referenced the previously created VPC inside a subnet configuration.
# That's how an interpolation syntax in Terraform looks: you wrap the code with ${}.
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.1.0/24"          # which is the subset of the cidr_block
  map_public_ip_on_launch = true
}

# Understanding dependency graph

# # Using vpc and subnet properties
# # Create an instance that attached vpc and subnet above
# resource "aws_instance" "awesome-instance" {
#   ami           = "ami-0c55b159cbfafe1f0"
#   instance_type = "t2.micro"

#   subnet_id              = "${aws_subnet.public.id}"
#   vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]

#   associate_public_ip_address = false

#   key_name = "${aws_key_pair.ecs.key_name}"

#   tags {
#     name = "awesome-ecs"
#   }

#   # aws_launch_configuration can not be modified.
#   # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created 
#   # before the old one get's destroyed. That's why we use name_prefix instead of name.
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Create a aws ssh key
# To bind the aws_instance id
# resource "aws_transfer_ssh_key" "instance_ssh_key" {
#   user_name = "root"
#   server_id = "${aws_instance.awesome-instance.id}"
#   body      = "${aws_key_pair.ecs.key_name}"
# }

## default security group
resource "aws_security_group" "default" {
  name        = "Default SG"
  description = "Allow SSH access"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ecs" {
  key_name   = "ecs-${var.ssh_key_name}"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

## Create a module map with the modules folder
## Or you may choose to take online module
## https://github.com/segmentio/stack OR https://github.com/terraform-community-modules
module "superman" {
  source      = "./modules/application"
  vpc_id      = "${aws_vpc.my_vpc.id}"
  subnet_id   = "${aws_subnet.public.id}"
  name        = "superman-ecs"
  key_name    = "${aws_key_pair.ecs.key_name}"
  password    = "${var.ssh_password}"
  environment = "${var.environment}"

  ## Passed in extra Argument
  extra_sgs = ["${aws_security_group.default.id}"]
}

variable "environment" {
  default = "dev"
}
