variable ssh_key_name {
  description = "SSH Key Label"
  default     = "awd-key"
}

variable ssh_ecs_instance_public_key {
  description = "SSH Public Key Label"
  default     = "ecs-public-key"
}

variable ssh_ecs_instance_pem_key {
  description = "pem Key Label"
  default     = "ecs-pem-key"
}

variable "region" {
  description = "AWS region. Changing it will lead to loss of complete stack."
  default     = "us-east-2"
}

variable "ssh_password" {
  default= "WER_YOU_THE_TURN_OVER_A_LEFT_234_@@@@_###"
}

