terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

 resource "aws_vpc" "vpc_us_east_1" {
  provider             = aws.us_east_1
  cidr_block           = var.vpc_cidr_us_east_1
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-us-east-1"
  }
}

resource "aws_vpc" "vpc_us_west_2" {
  provider             = aws.us_west_2
  cidr_block           = var.vpc_cidr_us_west_2
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-us-west-2"
  }
}
