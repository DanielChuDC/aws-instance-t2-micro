# Create a security group
# Application level security group
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "superman" {
  ami = "ami-0c55b159cbfafe1f0"

  // instance_type          = "t2.micro"
  instance_type = "${lookup(var.instance_type, var.environment)}"
  subnet_id     = "${var.subnet_id}"

  # vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]
  vpc_security_group_ids = ["${distinct(concat(aws_security_group.allow_http.*.id, var.extra_sgs))}"]
  key_name               = "${var.key_name}"

  // tags {
  //   Name = "${var.name}"
  // }

  # provisioner "remote-exec" {
  #   inline = [
  #     "apt-get ntp -y",
  #     "systemctl start ntp",
  #     "systemctl enable ntp",
  #   ]
  # }

  # aws_launch_configuration can not be modified.
  # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created 
  # before the old one get's destroyed. That's why we use name_prefix instead of name.
  lifecycle {
    create_before_destroy = true
  }
}

### Add in variable for passing from module parameter at root level
variable "vpc_id" {}

variable "subnet_id" {}
variable "name" {}

variable "key_name" {}
variable "password" {}

### this eip is not neccessary if your instance have ip
# ## Create an eip and bind it to instance
# resource "aws_eip" "default" {
#   instance = "${aws_instance.superman.id}"
#   vpc      = true

#   depends_on = ["aws_internet_gateway.superman"]
# }

## gateway and route table is needed
## Create a gateways 
resource "aws_internet_gateway" "superman" {
  vpc_id = "${var.vpc_id}" //gateways.tf

  // tags {
  //   Name = "superman-gw"
  // }
}

## //subnets.tf create route table 
resource "aws_route_table" "superman" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.superman.id}"
  }


}

## Create aws route table to route to the instance
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${var.subnet_id}"
  route_table_id = "${aws_route_table.superman.id}"
}
