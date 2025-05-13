resource "aws_security_group" "lambda_sg" {
  name        = "orders-lambda-sg-${var.environment}"
  description = "Security group for the Lambda functions of the Orders microservice"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Orders Lambda Security Group"
    Environment = var.environment
  }
}

locals {
  lambda_functions = {
    create = {
      name        = "create-order"
      description = "Create a new order"
      handler     = ".build/order/useCases/create/handler.handler"
    },
    get = {
      name        = "get-order"
      description = "Get an order by ID"
      handler     = ".build/order/useCases/get/handler.handler"
    },
    list = {
      name        = "list-orders"
      description = "List orders with pagination"
      handler     = ".build/order/useCases/list/handler.handler"
    },
    update = {
      name        = "update-order"
      description = "Update an existing order"
      handler     = ".build/order/useCases/update/handler.handler"
    },
    update_status = {
      name        = "update-order-status"
      description = "Update the status of an existing order"
      handler     = ".build/order/useCases/update_status/handler.handler"
    },
    delete = {
      name        = "delete-order"
      description = "Remove an order"
      handler     = ".build/order/useCases/delete/handler.handler"
    }
  }
}

# Criação das funções Lambda
resource "aws_lambda_function" "orders_functions" {
  for_each = local.lambda_functions

  function_name = "fast-food-orders-${each.value.name}-${var.environment}"
  description   = each.value.description
  role          = "arn:aws:iam::992382498858:role/LabRole"
  handler       = each.value.handler

  filename         = "${path.module}/../../../../dist/order/${each.key}.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../../dist/order/${each.key}.zip")

  layers = var.lambda_layers

  runtime     = "nodejs18.x"
  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      NODE_ENV     = var.environment
      DATABASE_URL = var.database_url,
      QUEUE_URL    = var.fast_food_order_payment_queue_url
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Environment = var.environment
    Service     = "orders"
  }
} 