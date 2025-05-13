resource "aws_lambda_layer_version" "lambda_layer_dependencies" {
  filename   = "${path.module}/dependencies/fastfood-orders-lambda-layer.zip"
  layer_name = "fastfood-orders-lambda-layer"
  compatible_runtimes = ["nodejs18.x"]
  skip_destroy = true
  description = "Fast Food Lambda Layer"
}

resource "aws_lambda_layer_version" "lambda_layer_prisma" {
  filename   = "${path.module}/prisma/fastfood-orders-lambda-layer-prisma.zip"
  layer_name = "fastfood-orders-lambda-layer-prisma"
  compatible_runtimes = ["nodejs18.x"]
  skip_destroy = true
  description = "Fast Food Lambda Layer Prisma"
}