variable "region" {
  type    = string
  default = "eu-central-1"
}

#################################################
################# VPC VARIABLES #################
#################################################

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


#################################################
############## INSTANCES VARIABLES ##############
#################################################

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-0a116fa7c861dd5f9"
}

variable "key_name" {
  type    = string
  default = "devops-key-pair"
}

variable "instance_count" {
  type    = number
  default = 1
}

#################################################
############### RDS VARIABLES ###################
#################################################

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "devopsdb"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_storage_type" {
  type    = string
  default = "gp3"
}