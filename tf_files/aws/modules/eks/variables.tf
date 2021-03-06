
variable "vpc_name" {}

variable "ec2_keyname" {
  default = "someone@uchicago.edu"
}

variable "instance_type" {
  default = "t3.large"
}

variable "jupyter_instance_type"{
  default = "t3.medium"
}

variable "csoc_cidr" {
  default = "10.128.0.0/20"
}

variable "users_policy" {}

variable "worker_drive_size" {
  default = 30
}

variable "eks_version" {
  default = "1.10"
}

variable "deploy_jupyter_pool" {
  default = "no"
}

variable "workers_subnet_size" {
  default = 24
}

variable "kernel" {
  default = "N/A"
}

variable "bootstrap_script" {
  default = "bootstrap-2.0.0.sh"
}

variable "jupyter_bootstrap_script" {
  default =  "bootstrap-2.0.0.sh"
}

variable "jupyter_worker_drive_size" {
  default = 30
}
