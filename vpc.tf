resource "aws_vpc" "devops_vpc" {
  cidr_block           = var.vpc_ip_range
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "devops_public_1" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = var.public_subnet_1_ip
  availability_zone       = var.avail_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-1"
  }
}

resource "aws_subnet" "devops_public_2" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = var.public_subnet_2_ip
  availability_zone       = var.avail_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-2"
  }
}

resource "aws_subnet" "devops_private_1" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.private_subnet_1_ip
  availability_zone = var.avail_zone_1

  tags = {
    Name = "devops-private-1"
  }
}

resource "aws_subnet" "devops_private_2" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.private_subnet_2_ip
  availability_zone = var.avail_zone_2

  tags = {
    Name = "devops-private-2"
  }
}

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

resource "aws_route_table" "devops_public_route_table" {
  vpc_id = aws_vpc.devops_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "devops-public-route-table"
  }
}
resource "aws_route_table_association" "devops_public_subnet_1" {
  subnet_id      = aws_subnet.devops_public_1.id
  route_table_id = aws_route_table.devops_public_route_table.id
}

resource "aws_route_table_association" "devops_public_subnet_2" {
  subnet_id      = aws_subnet.devops_public_2.id
  route_table_id = aws_route_table.devops_public_route_table.id
}
