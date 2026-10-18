terraform {

  backend "s3" {
    bucket = "portfolio-architecture-project-state-dev"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

output "alb_url" {
  description = "URL publique de l'Application Load Balancer"
  value       = "http://${aws_lb.app_alb_3-tiers.dns_name}"
}