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
 data "aws_caller_identity" "current" {}

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

# Open port 22 for SSH (change CIDR for more secure access)
resource "aws_security_group" "ec2_sg_us_east_1" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.vpc_us_east_1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in real usage
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-east"
  }
}

resource "aws_security_group" "ec2_sg_us_west_2" {
  provider = aws.us_west_2
  vpc_id   = aws_vpc.vpc_us_west_2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-west"
  }
}

# EC2 in us-east-1
resource "aws_instance" "ec2_us_east_1" {
  provider          = aws.us_east_1
  ami               = "ami-0af9569868786b23a" 
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.subnet_us_east_1a.id
  key_name          = "demo1"  # <-- Replace this
  vpc_security_group_ids = [aws_security_group.ec2_sg_us_east_1.id]

  tags = {
    Name = "ec2-east"
  }
}

# EC2 in us-west-2
resource "aws_instance" "ec2_us_west_2" {
  provider          = aws.us_west_2
  ami               = "ami-04999cd8f2624f834" 
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.subnet_us_west_2a.id
  key_name          = "demo"  # <-- Replace this
  vpc_security_group_ids = [aws_security_group.ec2_sg_us_west_2.id]

  tags = {
    Name = "ec2-west"
  }
}


# S3 Bucket in us-east-1
resource "aws_s3_bucket" "bucket_us_east_1" {
  provider = aws.us_east_1
  bucket   = "my-unique-bucket-us-east-1-primary"  
  force_destroy = true

  tags = {
    Name = "bucket-east"
    Environment = "dev"
  }
}

# S3 Bucket in us-west-2
resource "aws_s3_bucket" "bucket_us_west_2" {
  provider = aws.us_west_2
  bucket   = "my-unique-bucket-us-west-2-replica"  
  force_destroy = true

  tags = {
    Name = "bucket-west"
    Environment = "dev"
  }
}



