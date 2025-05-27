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

# Open port 22 for SSH (change CIDR for more secure access)
resource "aws_security_group" "ec2_sg_us_east_1" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.vpc_us_east_1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }
ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }
ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
  provider                  = aws.us_east_1
  ami                       = "ami-0af9569868786b23a"
  instance_type             = "t2.micro"
  subnet_id                 = aws_subnet.subnet_us_east_1a.id
  key_name                  = "demo1"  # Replace with your key pair name
  vpc_security_group_ids    = [aws_security_group.ec2_sg_us_east_1.id]

 
user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd

    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \\
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    if [[ -n "$TOKEN" ]]; then
      AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \\
        http://169.254.169.254/latest/meta-data/placement/availability-zone)
    else
      AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    fi

    echo "<h1>Hello world from $(hostname -f) in AZ $AZ</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "ec2-east"
  }
}

resource "aws_instance" "ec2_us_west_2" {
  provider                  = aws.us_west_2
  ami                       = "ami-04999cd8f2624f834"
  instance_type             = "t2.micro"
  subnet_id                 = aws_subnet.subnet_us_west_2a.id
  key_name                  = "demo44"  # Replace with your key pair name
  vpc_security_group_ids    = [aws_security_group.ec2_sg_us_west_2.id]

user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd

    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \\
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    if [[ -n "$TOKEN" ]]; then
      AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \\
        http://169.254.169.254/latest/meta-data/placement/availability-zone)
    else
      AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    fi

    echo "<h1>Hello world from $(hostname -f) in AZ $AZ</h1>" > /var/www/html/index.html
  EOF

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
     provider = aws.us_east_1
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
 provider = aws.us_east_1
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
            "AWS:SourceAccount" = "417311687307"
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
    provider = aws.us_east_1
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
 provider = aws.us_east_1
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
  publicly_accessible    = true
  multi_az               = false

  tags = {
    Name = "rds-primary"
    }
    
}
resource "aws_db_instance" "replica" {
  provider = aws.us_west_2
  identifier           = "mydb-replica"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  publicly_accessible  = true
  replicate_source_db  = aws_db_instance.rds_primary.arn  # Must use ARN
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group_usw2.name
  skip_final_snapshot  = true
}

data "aws_route53_zone" "smitha_zone" {
  provider = aws.us_west_2
  name         = "smithaproperties.com"
  private_zone = false
}
resource "aws_route53_health_check" "primary_ec2" {
  provider = aws.us_west_2
  fqdn              = "www.smithaproperties.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}
resource "aws_route53_record" "primary" {
  provider = aws.us_east_1
  zone_id = data.aws_route53_zone.smitha_zone.zone_id
  name    = "www.smithaproperties.com"
  type    = "A"
  ttl     = 30

  set_identifier  = "primary"
 failover_routing_policy {
    type = "PRIMARY"
  }
  records         = [aws_instance.ec2_us_east_1.public_ip]
  health_check_id = aws_route53_health_check.primary_ec2.id
}

resource "aws_route53_record" "secondary" {
   provider = aws.us_west_2
  zone_id = data.aws_route53_zone.smitha_zone.zone_id
  name    = "www.smithaproperties.com"
  type    = "A"
  ttl     = 30

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
  records        = [aws_instance.ec2_us_west_2.public_ip]
}
resource "aws_cloudwatch_metric_alarm" "cross_region_replica_lag" {
  provider               = aws.us_east_1
  alarm_name             = "CrossRegionReplicaLag"
  
  evaluation_periods     = 1
  metric_name            = "ReplicaLag"
  namespace              = "AWS/RDS"
  period                 = 300
  statistic              = "Average"
  threshold = -1
comparison_operator = "GreaterThanThreshold"

  alarm_description      = "Alarm when cross-region RDS replica lag exceeds 60 seconds"
  treat_missing_data     = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "mydb-replica"
  }

  alarm_actions          = [aws_sns_topic.alerts.arn]
  ok_actions             = [aws_sns_topic.alerts.arn]
  insufficient_data_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  provider               = aws.us_east_1
  name = "rds-replica-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  provider               = aws.us_east_1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "smithamalthi@gmail.com"
}

# route53 alarm
resource "aws_route53_health_check" "web_health_check" {
  provider               = aws.us_east_1
  fqdn              = "www.smithaproperties.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
  tags = {
    Name = "WebHealthCheck"
  }
}
# 
resource "aws_cloudwatch_metric_alarm" "route53_health_check_alarm" {
  alarm_name          = "Route53HealthCheckFailed"
  provider               = aws.us_east_1
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 60
  alarm_description   = "Alarm when Route 53 health check fails"
  treat_missing_data  = "breaching"

  dimensions = {
    HealthCheckId = aws_route53_health_check.web_health_check.id
  }
}

