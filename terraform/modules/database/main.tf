resource "aws_db_subnet_group" "subnet_group_fast_food_orders" {
  name       = "fast-food-orders-subnet-group-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "Fast Food Orders DB Subnet Group"
    Environment = var.environment
  }
}

resource "aws_security_group" "security_group_fast_food_orders" {
  name        = "fast-food-orders-sg-${var.environment}"
  description = "Allow database traffic for Orders microservice"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Fast Food Orders RDS Security Group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "db_fast_food_orders" {
  identifier              = "fast-food-orders-db-${var.environment}"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  db_name                 = var.db_name
  username                = var.db_username
  port                    = var.db_port
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.subnet_group_fast_food_orders.name
  vpc_security_group_ids  = [aws_security_group.security_group_fast_food_orders.id]
  skip_final_snapshot     = true
  deletion_protection     = var.environment == "prod" ? true : false
  backup_retention_period = var.environment == "prod" ? 14 : 7
  publicly_accessible     = true
  tags = {
    Name        = "Fast Food Orders Database"
    Environment = var.environment
  }
}
