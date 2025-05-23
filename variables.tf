variable "vpc_cidr_us_east_1" {
  default = "10.0.0.0/16"
}

variable "vpc_cidr_us_west_2" {
  default = "10.1.0.0/16"
}

variable "subnet_cidrs_us_east_1" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_cidrs_us_west_2" {
  default = ["10.1.10.0/24", "10.1.20.0/24"]
}
