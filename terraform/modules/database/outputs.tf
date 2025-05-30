output "db_instance_endpoint" {
  value       = aws_db_instance.db_fast_food_orders.endpoint
  description = "Database endpoint"
}

output "db_instance_address" {
  value       = aws_db_instance.db_fast_food_orders.address
  description = "Database address"
}
