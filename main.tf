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
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

 # VPCs
# data "aws_caller_identity" "current" {}

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

# Subnets - us-east-1
resource "aws_subnet" "subnet_us_east_1a" {
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.vpc_us_east_1.id
  cidr_block              = var.subnet_cidrs_us_east_1[0]
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-us-east-1a"
  }
}

resource "aws_subnet" "subnet_us_east_1b" {
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.vpc_us_east_1.id
  cidr_block              = var.subnet_cidrs_us_east_1[1]
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-us-east-1b"
  }
}

# Subnets - us-west-2
resource "aws_subnet" "subnet_us_west_2a" {
  provider                = aws.us_west_2
  vpc_id                  = aws_vpc.vpc_us_west_2.id
  cidr_block              = var.subnet_cidrs_us_west_2[0]
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-us-west-2a"
  }
}

resource "aws_subnet" "subnet_us_west_2b" {
  provider                = aws.us_west_2
  vpc_id                  = aws_vpc.vpc_us_west_2.id
  cidr_block              = var.subnet_cidrs_us_west_2[1]
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-us-west-2b"
  }
}

# Route Table for VPC in us-east-1
resource "aws_route_table" "rtb_us_east_1" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.vpc_us_east_1.id

  tags = {
    Name = "rtb-us-east-1"
  }
}

# Route Table for VPC in us-west-2
resource "aws_route_table" "rtb_us_west_2" {
  provider = aws.us_west_2
  vpc_id   = aws_vpc.vpc_us_west_2.id

  tags = {
    Name = "rtb-us-west-2"
  }
}
# us-east-1
resource "aws_route_table_association" "assoc_us_east_1a" {
  provider       = aws.us_east_1
  subnet_id      = aws_subnet.subnet_us_east_1a.id
  route_table_id = aws_route_table.rtb_us_east_1.id
}

resource "aws_route_table_association" "assoc_us_east_1b" {
  provider       = aws.us_east_1
  subnet_id      = aws_subnet.subnet_us_east_1b.id
  route_table_id = aws_route_table.rtb_us_east_1.id
}

# us-west-2
resource "aws_route_table_association" "assoc_us_west_2a" {
  provider       = aws.us_west_2
  subnet_id      = aws_subnet.subnet_us_west_2a.id
  route_table_id = aws_route_table.rtb_us_west_2.id
}

resource "aws_route_table_association" "assoc_us_west_2b" {
  provider       = aws.us_west_2
  subnet_id      = aws_subnet.subnet_us_west_2b.id
  route_table_id = aws_route_table.rtb_us_west_2.id
}
# IGW for us-east-1
resource "aws_internet_gateway" "igw_us_east_1" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.vpc_us_east_1.id

  tags = {
    Name = "igw-us-east-1"
  }
}

# IGW for us-west-2
resource "aws_internet_gateway" "igw_us_west_2" {
  provider = aws.us_west_2
  vpc_id   = aws_vpc.vpc_us_west_2.id

  tags = {
    Name = "igw-us-west-2"
  }
}
# Route in us-east-1
resource "aws_route" "route_internet_us_east_1" {
  provider               = aws.us_east_1
  route_table_id         = aws_route_table.rtb_us_east_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_us_east_1.id
}

# Route in us-west-2
resource "aws_route" "route_internet_us_west_2" {
  provider               = aws.us_west_2
  route_table_id         = aws_route_table.rtb_us_west_2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_us_west_2.id
}
