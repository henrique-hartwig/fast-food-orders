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
      name        = "create-product-category"
      description = "Create a new product category"
      handler     = ".build/product_category/useCases/create/handler.handler"
    },
    get = {
      name        = "get-product-category"
      description = "Get a product category by ID"
      handler     = ".build/product_category/useCases/get/handler.handler"
    },
    list = {
      name        = "list-product-categories"
      description = "List product categories with pagination"
      handler     = ".build/product_category/useCases/list/handler.handler"
    },
    update = {
      name        = "update-product-category"
      description = "Update an existing product category"
      handler     = ".build/product_category/useCases/update/handler.handler"
    },
    delete = {
      name        = "delete-product-category"
      description = "Remove a product category"
      handler     = ".build/product_category/useCases/delete/handler.handler"
    }
  }
}

resource "aws_lambda_function" "product_category_functions" {
  for_each = local.lambda_functions

  function_name = "fast-food-orders-${each.value.name}-${var.environment}"
  description   = each.value.description
  role          = "arn:aws:iam::992382498858:role/LabRole"
  handler       = each.value.handler

  filename         = "${path.module}/../../../../dist/product_category/${each.key}.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../../dist/product_category/${each.key}.zip")

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
    Service     = "product-category"
  }
} 