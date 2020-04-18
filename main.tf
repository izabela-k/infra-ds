# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "ds1-terraform-state"
    key    = "terraform-state"
    region = "eu-west-1"
  }
}

module "aws" {
  source = "./aws"
}

module "postgresql" {
  source = "./postgresql"
}

module "mongodb" {
  source = "./mongodb"
}