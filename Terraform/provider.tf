terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }

  # Recommended: store state remotely instead of locally.
  # Create the bucket + DynamoDB table once (manually or via a bootstrap
  # config) and then uncomment this block.
  #
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "devops-demo/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}