output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "api_gateway_url" {
  value = module.api_gateway.api_endpoint
}

output "api_gateway_id" {
  value = module.api_gateway.api_id
}

output "api_gateway_execution_arn" {
  value = module.api_gateway.api_execution_arn
}

output "fast_food_order_payment_queue_arn" {
  value = module.queue.fast_food_order_payment_queue_arn
}

output "fast_food_order_payment_queue_url" {
  value = module.queue.fast_food_order_payment_queue_url
}
