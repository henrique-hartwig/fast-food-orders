module "network" {
  source = "./modules/network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "database" {
  source = "./modules/database"

  environment       = var.environment
  db_instance_class = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_port           = var.db_port
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnet_ids
}

module "queue" {
  source      = "./modules/queue"
  environment = var.environment
}

module "product_category" {
  source = "./modules/lambda/product-category"

  environment        = var.environment
  database_url       = var.database_url
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.private_subnet_ids
  lambda_memory_size = var.lambda_memory_size
  lambda_timeout     = var.lambda_timeout
  lambda_layers      = [module.lambda_layer.dependencies_layer_arn, module.lambda_layer.prisma_layer_arn]
  tags = {
    Service = "ProductCategory"
  }
}

module "product" {
  source = "./modules/lambda/product"

  environment        = var.environment
  database_url       = var.database_url
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.private_subnet_ids
  lambda_memory_size = var.lambda_memory_size
  lambda_timeout     = var.lambda_timeout
  lambda_layers      = [module.lambda_layer.dependencies_layer_arn, module.lambda_layer.prisma_layer_arn]
  tags = {
    Service = "Product"
  }
}

module "order" {
  source = "./modules/lambda/order"

  environment                       = var.environment
  database_url                      = var.database_url
  vpc_id                            = module.network.vpc_id
  subnet_ids                        = module.network.private_subnet_ids
  lambda_memory_size                = var.lambda_memory_size
  lambda_timeout                    = var.lambda_timeout
  lambda_layers                     = [module.lambda_layer.dependencies_layer_arn, module.lambda_layer.prisma_layer_arn]
  fast_food_order_payment_queue_url = module.queue.fast_food_order_payment_queue_url
  tags = {
    Service = "Order"
  }
}

module "api_gateway" {
  source = "./modules/api_gateway"

  environment              = var.environment
  api_name                 = var.api_name
  api_description          = var.api_description
  product_category_lambdas = module.product_category.lambda_functions
  order_lambdas            = module.order.lambda_functions
  product_lambdas          = module.product.lambda_functions
  tags = {
    Service = "API Gateway"
  }
}

module "lambda_layer" {
  source = "./modules/lambda_layer"
}
