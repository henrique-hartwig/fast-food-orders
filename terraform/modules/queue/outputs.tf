variable "environment" {
  description = "The environment to deploy (dev, prod)"
  type        = string
  default     = "dev"
}

output "fast_food_order_payment_queue_url" {
  description = "SQS URL for fast food order payment queue"
  value       = aws_sqs_queue.fast_food_order_payment_queue.id
}

output "fast_food_order_payment_queue_arn" {
  description = "SQS ARN for fast food order payment queue"
  value       = aws_sqs_queue.fast_food_order_payment_queue.arn
}
