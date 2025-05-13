resource "aws_vpc" "vpc_fast_food" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "fast-food-vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_fast_food" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc_fast_food.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-${count.index}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_fast_food" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc_fast_food.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "private-subnet-${count.index}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw_fast_food" {
  vpc_id = aws_vpc.vpc_fast_food.id

  tags = {
    Name        = "fast-food-igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table" "public_route_table_fast_food" {
  vpc_id = aws_vpc.vpc_fast_food.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_fast_food.id
  }

  tags = {
    Name        = "public-route-table-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_route_table_association_fast_food" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet_fast_food[count.index].id
  route_table_id = aws_route_table.public_route_table_fast_food.id
}

resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gateway_fast_food" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet_fast_food[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "private_route_table_fast_food" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc_fast_food.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_fast_food[count.index].id
  }

  tags = {
    Name        = "private-route-table-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_route_table_association_fast_food" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet_fast_food[count.index].id
  route_table_id = aws_route_table.private_route_table_fast_food[count.index].id
}

resource "aws_flow_log" "vpc_flow_log_fast_food" {
  iam_role_arn    = "arn:aws:iam::992382498858:role/LabRole"
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_fast_food.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_fast_food.id

  tags = {
    Name        = "vpc-flow-log-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_fast_food" {
  name              = "/aws/vpc/flow-log-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "vpc-flow-log-group-${var.environment}"
    Environment = var.environment
  }
} 