# VPC Module
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    "Name" = var.name
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index % length(var.azs))

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

# Public Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway
resource "aws_eip" "gateway" {
  count = var.enable_nat_gateway ? length(var.public_subnets) : 0 # One EIP per NAT Gateway
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnets) : 0 # One NAT Gateway per public subnet for high availability
  allocation_id = aws_eip.gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = length(var.private_subnets) # One route table per private subnet
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id
    }
  }

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}
