variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_ip_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "avail_zone_1" {
  type    = string
  default = "eu-central-1a"
}

variable "avail_zone_2" {
  type    = string
  default = "eu-central-1b"
}

variable "public_subnet_1_ip" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_2_ip" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_subnet_1_ip" {
  type    = string
  default = "10.0.3.0/24"
}

variable "private_subnet_2_ip" {
  type    = string
  default = "10.0.4.0/24"
}