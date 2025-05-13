resource "aws_security_group" "lambda_sg" {
  name        = "${var.lambda_name}-sg-${var.environment}"
  description = "Security group for the ${var.lambda_name} Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.lambda_name} Security Group"
  })
}

locals {
  lambda_functions = {
    create = {
      name        = "create-product"
      description = "Create a new product"
      handler     = ".build/product/useCases/create/handler.handler"
    },
    get = {
      name        = "get-product"
      description = "Get a product by ID"
      handler     = ".build/product/useCases/get/handler.handler"
    },
    list = {
      name        = "list-product"
      description = "List product with pagination"
      handler     = ".build/product/useCases/list/handler.handler"
    },
    update = {
      name        = "update-product"
      description = "Update an existing product"
      handler     = ".build/product/useCases/update/handler.handler"
    },
    delete = {
      name        = "delete-product"
      description = "Remove a product"
      handler     = ".build/product/useCases/delete/handler.handler"
    }
  }
}

resource "aws_lambda_function" "product_functions" {
  for_each = local.lambda_functions

  function_name = "fast-food-orders-${each.value.name}-${var.environment}"
  description   = each.value.description
  role          = "arn:aws:iam::992382498858:role/LabRole"
  handler       = each.value.handler

  filename         = "${path.module}/../../../../dist/product/${each.key}.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../../dist/product/${each.key}.zip")

  layers = var.lambda_layers

  runtime     = "nodejs18.x"
  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      NODE_ENV     = var.environment
      DATABASE_URL = var.database_url
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Environment = var.environment
    Service     = "product"
  }
} 