variable "name" {}
variable "vpc_cidr" {}
variable "azs" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }

variable "enable_dns_support" { 
    type = bool 
    default = true 
    }

variable "enable_dns_hostnames" { 
    type = bool
    default = true
    }

variable "map_public_ip_on_launch" { 
    type = bool
    default = true
    }

variable "tags" { 
  type = map(string)
  default = {}
  }

variable "public_subnet_tags" {
  type = map(string)
  default = {}
  }

variable "private_subnet_tags" {
  type = map(string)
  default = {}
  }
  