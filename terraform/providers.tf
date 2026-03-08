terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Configuração de tags padrão para todos os recursos criados, facilitando a identificação e organização dos recursos na AWS.
  default_tags {
    tags = {
      Project     = "CoinFlip"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}
