variable "env" {
  description = "Environment name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support"
  type        = bool
  default     = true
}

variable "public_subnet_tags" {
  description = "Tags for public subnets"
  type        = map(string)
}

variable "private_subnet_tags" {
  description = "Tags for private subnets"
  type        = map(string)
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Should be true to auto-assign public IPs in public subnets"
  type        = bool
  default     = false
}
