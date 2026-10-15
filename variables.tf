variable "aws_region"{
    type = string
    description = "the aws region where the architecture will be deployed"
}

variable "vpc_cidr"{
    type = string
    description = "the cidr of the main vpc"
}

variable "app_instance_type"{
    type = string
    description = "the instance type for the application instance"
}

variable "env" {
  description = "L'environnement de déploiement (ex: dev pour les TP, prod pour le portfolio)"
  type        = string
  default     = "dev"
}

variable "db_user_name"{
    type = string
    description = "the user name for the db"
    default = "admin"
}

variable "s3_bucket_app" {
    type = string
    description = "the bucket that contains the application zip file"
}

variable "app_version" {
  description = "a unique identifier of the application version (git sha)"
  type        = string
  default     = "initial"
}