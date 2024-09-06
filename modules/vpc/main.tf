data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.project_name}"
    Terraform  = "true"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${var.project_name}"
    Terraform  = "true"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${var.project_name}-${count.index + 1}"
    Terraform  = "true"
    "kubernetes.io/role/elb"  = "1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${var.project_name}-${count.index + 1}"
    Terraform  = "true"
  }
}

resource "aws_eip" "nat" {

  tags = {
    Name = "nat-eip-${var.project_name}"
    Terraform  = "true"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)

  tags = {
    Name = "nat-gateway-${var.project_name}"
    Terraform  = "true"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table-${var.project_name}"
    Terraform  = "true"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-route-table-${var.project_name}"
    Terraform  = "true"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id        = aws_vpc.main.id
  service_name  = "com.amazonaws.${var.region}.s3"
  route_table_ids = concat(
    aws_route_table.public.*.id,
    aws_route_table.private.*.id
  )

  tags = {
    Name = "s3-vpc-endpoint-${var.project_name}"
    Terraform  = "true"
    "kubernetes.io/role/elb"  = "1"
    "kubernetes.io/role/internal-elb"  = "1"
  }
}

resource "aws_key_pair" "admin_key" {
  key_name   = var.ssh_key_name  # Desired name for the key pair
  public_key = file(var.ssh_key_path)  # Path to your existing public key

  tags = {
    Name = "admin-key-${var.project_name}"
    Terraform  = "true"
  }
}