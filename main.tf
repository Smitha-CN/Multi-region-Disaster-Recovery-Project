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
  region = "us-east-2"
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
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-us-east-1a"
  }
}

resource "aws_subnet" "subnet_us_east_1b" {
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.vpc_us_east_1.id
  cidr_block              = var.subnet_cidrs_us_east_1[1]
  availability_zone       = "us-east-1b"
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
  ami               = "ami-0c101f26f147fa7fd" 
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.subnet_us_east_1a.id
  key_name          = "demo"  # <-- Replace this
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


resource "aws_s3_bucket_versioning" "versioning_source" {
  bucket = aws_s3_bucket.bucket_us_east_1.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "versioning_dest" {
  provider = aws.us_west_2
  bucket   = aws_s3_bucket.bucket_us_west_2.id
  versioning_configuration {
    status = "Enabled"
  }
}


# role
resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
# policy
resource "aws_s3_bucket_policy" "allow_replication_on_dest" {
  provider = aws.us_west_2
  bucket   = aws_s3_bucket.bucket_us_west_2.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.s3_replication_role.arn
        },
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "${aws_s3_bucket.bucket_us_west_2.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "allow_replication_on_source" {
  provider = aws.us_east_1
  bucket   = aws_s3_bucket.bucket_us_east_1.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowReplicationConfiguration",
        Effect    = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.bucket_us_east_1.arn,
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "AllowReplicationObjectAccess",
        Effect    = "Allow",
        Principal = {
          AWS = aws_iam_role.s3_replication_role.arn
        },
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        Resource = "${aws_s3_bucket.bucket_us_east_1.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_replication_policy" {
  name = "s3-replication-policy"
  role = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = [
          aws_s3_bucket.bucket_us_east_1.arn,
          "${aws_s3_bucket.bucket_us_east_1.arn}/*",
          aws_s3_bucket.bucket_us_west_2.arn,
          "${aws_s3_bucket.bucket_us_west_2.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [
    aws_s3_bucket_versioning.versioning_source,
    aws_s3_bucket_versioning.versioning_dest,
    aws_s3_bucket_policy.allow_replication_on_dest
  ]

  bucket = aws_s3_bucket.bucket_us_east_1.id
  role   = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    filter {
      prefix = ""  # replicate all
    }

    delete_marker_replication {
      status = "Disabled"  # required now in latest CRR schema
    }

    destination {
      bucket        = aws_s3_bucket.bucket_us_west_2.arn
      storage_class = "STANDARD"
    }
  }
}
# resource "aws_db_instance" "default" {
#   allocated_storage    = 10
#   db_name              = "mydb"
  
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t3.micro"
#   username             = "foo"
#   password             = "foobarbaz"
#   parameter_group_name = "default.mysql8.0"
#   skip_final_snapshot  = true
# }
# DB Subnet Group for RDS in us-east-1
resource "aws_db_subnet_group" "rds_subnet_group_use1" {
  provider = aws.us_east_1
  name     = "rds-subnet-group-use1"
  subnet_ids = [
    aws_subnet.subnet_us_east_1a.id,
    aws_subnet.subnet_us_east_1b.id
  ]

  tags = {
    Name = "rds-subnet-group-use1"
  }
}

# DB Subnet Group for RDS in us-west-2
resource "aws_db_subnet_group" "rds_subnet_group_usw2" {
  provider = aws.us_west_2
  name     = "rds-subnet-group-usw2"
  subnet_ids = [
    aws_subnet.subnet_us_west_2a.id,
    aws_subnet.subnet_us_west_2b.id
  ]

  tags = {
    Name = "rds-subnet-group-usw2"
  }
}
resource "aws_db_instance" "rds_primary" {
  provider               = aws.us_east_1
  identifier             = "mysql-primary555555"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = "securepass123"  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group_use1.name
  vpc_security_group_ids = [aws_security_group.ec2_sg_us_east_1.id]
  skip_final_snapshot    = true
  backup_retention_period = 7
  publicly_accessible    = false
  multi_az               = false

  tags = {
    Name = "rds-primary"
  }
}
resource "aws_db_instance" "rds_replica" {
  provider                = aws.us_west_2
  identifier              = "mysql-replica"
  instance_class          = "db.t3.micro"
  replicate_source_db     = aws_db_instance.rds_primary.arn
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group_usw2.name
  vpc_security_group_ids  = [aws_security_group.ec2_sg_us_west_2.id]
  publicly_accessible     = false
  skip_final_snapshot     = true

  depends_on = [aws_db_instance.rds_primary]

  tags = {
    Name = "rds-replica"
  }
}


