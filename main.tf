        provider "aws" {
          alias = "us-east-1"
          region = "us-east-1"
        }

        provider "aws" {
          alias = "us-west-2"
          region = "us-west-2"
        }


# Primary region VPC
resource "aws_vpc" "vpc_use1" {
  provider   = aws.us-east-1
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-us-east-1"
  }
}
resource "aws_subnet" "use1_public" {
  provider                = aws.us-east-1
  vpc_id                  = aws_vpc.vpc_use1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "use1-public-subnet"
  }
}

resource "aws_subnet" "use1_private" {
  provider          = aws.us-east-1
  vpc_id            = aws_vpc.vpc_use1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "use1-private-subnet"
  }
}
resource "aws_internet_gateway" "use1_igw" {
  provider = aws.us-east-1
  vpc_id   = aws_vpc.vpc_use1.id

  tags = {
    Name = "use1-igw"
  }
}
# Route Table for public subnet
resource "aws_route_table" "use1_public_rt" {
  provider = aws.us-east-1
  vpc_id   = aws_vpc.vpc_use1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.use1_igw.id
  }

  tags = {
    Name = "use1-public-rt"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "use1_public_assoc" {
  provider       = aws.us-east-1
  subnet_id      = aws_subnet.use1_public.id
  route_table_id = aws_route_table.use1_public_rt.id
}
# VPC in us-west-2
resource "aws_vpc" "vpc_usw2" {
  provider   = aws.us-west-2
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "vpc-us-west-2"
  }
}
resource "aws_subnet" "usw2_public" {
  provider                = aws.us-west-2
  vpc_id                  = aws_vpc.vpc_usw2.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "usw2-public-subnet"
  }
}

resource "aws_subnet" "usw2_private" {
  provider          = aws.us-west-2
  vpc_id            = aws_vpc.vpc_usw2.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "usw2-private-subnet"
  }
}
resource "aws_internet_gateway" "usw2_igw" {
  provider = aws.us-west-2
  vpc_id   = aws_vpc.vpc_usw2.id

  tags = {
    Name = "usw2-igw"
  }
}
resource "aws_route_table" "usw2_public_rt" {
  provider = aws.us-west-2
  vpc_id   = aws_vpc.vpc_usw2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.usw2_igw.id
  }

  tags = {
    Name = "usw2-public-rt"
  }
}
resource "aws_route_table_association" "usw2_public_assoc" {
  provider       = aws.us-west-2
  subnet_id      = aws_subnet.usw2_public.id
  route_table_id = aws_route_table.usw2_public_rt.id
}
# S3 bucket in us-east-1
resource "aws_s3_bucket" "source" {
  provider = aws.us-east-1
  bucket   = "my-crr1-source-bucket-123456"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = { Name = "source-bucket" }
}
# S3 bucket in us-west-2

resource "aws_s3_bucket" "destination" {
  provider = aws.us-west-2
  bucket   = "my-crr1-destination-bucket-123456"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = { Name = "destination-bucket" }
}

# Security groups for rds
resource "aws_security_group" "rds_sg_use1" {
  provider = aws.us-east-1
  name        = "rds-sg-use1"
  description = "Allow DB access"
  vpc_id      = aws_vpc.vpc_use1.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for demo, restrict this in prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg-use1" }
}

resource "aws_security_group" "rds_sg_usw2" {
  provider = aws.us-west-2
  name   = "rds-sg-usw2"
  vpc_id = aws_vpc.vpc_usw2.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg-usw2" }
}
resource "aws_db_subnet_group" "rds_subnet_group_use1" {
  provider = aws.us-east-1
  name       = "rds-subnet-use1"
  subnet_ids = [aws_subnet.use1_private.id]

  tags = { Name = "rds-subnet-use1" }
}

resource "aws_db_subnet_group" "rds_subnet_group_usw2" {
  provider = aws.us-west-2
  name       = "rds-subnet-usw2"
  subnet_ids = [aws_subnet.usw2_private.id]

  tags = { Name = "rds-subnet-usw2" }
}

# primary rds
resource "aws_db_instance" "primary" {
  provider                = aws.us-east-1
  identifier              = "pg-primary"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "password"
  allocated_storage       = 20
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group_use1.name
  vpc_security_group_ids  = [aws_security_group.rds_sg_use1.id]
  multi_az                = false
  publicly_accessible     = false

  tags = {
    Name = "pg-primary"
  }
}
# replica rds
resource "aws_db_instance" "replica" {
  provider                = aws.us-west-2
  identifier              = "pg-replica"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  replicate_source_db     = aws_db_instance.primary.arn
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group_usw2.name
  vpc_security_group_ids  = [aws_security_group.rds_sg_usw2.id]
  publicly_accessible     = false

  depends_on = [aws_db_instance.primary]

  tags = {
    Name = "pg-replica"
  }
}

