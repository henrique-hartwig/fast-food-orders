resource "aws_apigatewayv2_api" "api" {
  name          = "${var.api_name}-${var.environment}"
  description   = var.api_description
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group_fast_food.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
    })
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
    data_trace_enabled     = true
    logging_level          = "INFO"
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "api_gateway_log_group_fast_food" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.api.name}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

################################################################################
# ProductCategory
################################################################################

resource "aws_apigatewayv2_integration" "create_product_category" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_category_lambdas.create.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_product_category" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /product-category"
  target    = "integrations/${aws_apigatewayv2_integration.create_product_category.id}"
}

resource "aws_apigatewayv2_integration" "list_product_categories" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_category_lambdas.list.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_product_categories" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /product-categories"
  target    = "integrations/${aws_apigatewayv2_integration.list_product_categories.id}"
}

resource "aws_apigatewayv2_integration" "get_product_category" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_category_lambdas.get.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_product_category" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /product-category/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_product_category.id}"
}

resource "aws_apigatewayv2_integration" "update_product_category" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_category_lambdas.update.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_product_category" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /product-category/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_product_category.id}"
}

resource "aws_apigatewayv2_integration" "delete_product_category" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_category_lambdas.delete.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_product_category" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /product-category/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_product_category.id}"
}

resource "aws_lambda_permission" "create_product_category" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_category_lambdas.create.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product-category"
}

resource "aws_lambda_permission" "list_product_categories" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_category_lambdas.list.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product-categories"
}

resource "aws_lambda_permission" "get_product_category" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_category_lambdas.get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product-category/*"
}

resource "aws_lambda_permission" "update_product_category" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_category_lambdas.update.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product-category/*"
}

resource "aws_lambda_permission" "delete_product_category" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_category_lambdas.delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product-category/*"
}


################################################################################
# Product
################################################################################

resource "aws_apigatewayv2_integration" "create_product" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_lambdas.create.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_product" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /product"
  target    = "integrations/${aws_apigatewayv2_integration.create_product.id}"
}

resource "aws_apigatewayv2_integration" "list_product" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_lambdas.list.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_product" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /product"
  target    = "integrations/${aws_apigatewayv2_integration.list_product.id}"
}

resource "aws_apigatewayv2_integration" "get_product" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_lambdas.get.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_product" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /product/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_product.id}"
}

resource "aws_apigatewayv2_integration" "update_product" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_lambdas.update.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_product" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /product/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_product.id}"
}

resource "aws_apigatewayv2_integration" "delete_product" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.product_lambdas.delete.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_product" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /product/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_product.id}"
}

resource "aws_lambda_permission" "create_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_lambdas.create.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product"
}

resource "aws_lambda_permission" "list_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_lambdas.list.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product"
}

resource "aws_lambda_permission" "get_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_lambdas.get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product/*"
}

resource "aws_lambda_permission" "update_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_lambdas.update.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product/*"
}

resource "aws_lambda_permission" "delete_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.product_lambdas.delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/product/*"
}

################################################################################
# Order
################################################################################

resource "aws_apigatewayv2_integration" "create_order" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.order_lambdas.create.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_order" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /order"
  target    = "integrations/${aws_apigatewayv2_integration.create_order.id}"
}

resource "aws_apigatewayv2_integration" "list_orders" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.order_lambdas.list.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_orders" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /orders"
  target    = "integrations/${aws_apigatewayv2_integration.list_orders.id}"
}

resource "aws_apigatewayv2_integration" "get_order" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.order_lambdas.get.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_order" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /order/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_order.id}"
}

resource "aws_apigatewayv2_integration" "update_order" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.order_lambdas.update.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_order" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /order/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_order.id}"
}

resource "aws_apigatewayv2_integration" "delete_order" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.order_lambdas.delete.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_order" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /order/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_order.id}"
}

resource "aws_lambda_permission" "create_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.order_lambdas.create.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/order"
}

resource "aws_lambda_permission" "list_orders" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.order_lambdas.list.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/orders"
}

resource "aws_lambda_permission" "get_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.order_lambdas.get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/order/*"
}

resource "aws_lambda_permission" "update_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.order_lambdas.update.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/order/*"
}

resource "aws_lambda_permission" "delete_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.order_lambdas.delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/order/*"
} 