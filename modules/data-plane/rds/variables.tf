 variable "name" { type = string }
 variable "vpc_id" { type = string }
 variable "subnet_ids" { type = list(string) }
 variable "eks_security_group_id" { type = string }
 variable "tags" { type = map(string) }

 variable "engine_version" {
    type = string
    default = "15.4"
    }

 variable "engine_version_major" {
    type = string
    default = "15"
    }

 variable "instance_class" {
    type = string
    default = "db.t3.micro"
    }

 variable "allocated_storage" {
    type = number
    default = 20
    }

 variable "max_allocated_storage" {
    type = number
    default = 100
    }

 variable "master_username" {
    type = string
    default = "postgres"
    }

 variable "parameters" {
    type = list(any)
    default = []
    }

 variable "kms_description" {
    type = string
    default = "RDS KMS Key"
    }

 variable "port" {
    type = number
    default = 5432
    }

 variable "skip_final_snapshot" {
    type = bool
    default = true
    }

 variable "deletion_protection" {
    type = bool
    default = false
    }

 variable "multi_az" {
    type = bool
    default = false
    }

 variable "backup_retention_period" {
    type = number
    default = 1
    }

 variable "maintenance_window" {
    type = string
    default = "Mon:00:00-Mon:03:00"
    }

 variable "performance_insights_enabled" {
    type = bool
    default = false
    }
