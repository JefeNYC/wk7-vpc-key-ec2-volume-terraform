# This is the code for VPC

resource "aws_vpc" "vpc1" {
  cidr_block           = "172.120.0.0/16" // class B 65K
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name       = "UTC-Vpc"
    env        = "Dev"
    app-name   = "utc"
    Team       = "wdp"
    created_by = "Jefe"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "UTC-IGW"
  }
}

# Public Subnet creation

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "172.120.1.0/24" // class C 254 ips
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "UTC-public-sub1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "172.120.2.0/24" // class C 254 ips
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "UTC-public-sub2"
  }
  depends_on = [aws_vpc.vpc1] # Dependency
}

# Private Subnet creation

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "172.120.3.0/24" // class C 254 ips
  availability_zone = "us-east-1a"

  tags = {
    Name = "UTC-private-sub1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "172.120.4.0/24" // class C 254 ips
  availability_zone = "us-east-1b"

  tags = {
    Name = "UTC-private-sub2"
  }
}

# NAT Gateway

resource "aws_eip" "eip" {

}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "utc-NAT"
  }
}

# Route Table for Private Subnet

resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

# Route Table for Public Subnet

resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}


# Route Table Association Public

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}

# Route Table Association Private

resource "aws_route_table_association" "rtapriv1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "rtapriv2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.rtprivate.id
}