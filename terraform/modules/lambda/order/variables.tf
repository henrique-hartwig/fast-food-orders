variable "environment" {
  description = "Deploy environment (dev, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda functions (MB)"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda functions (seconds)"
  type        = number
  default     = 30
}

variable "vpc_id" {
  description = "ID of the VPC where the Lambda functions will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets where the Lambda functions will be deployed"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}

variable "lambda_layers" {
  description = "Lambda Layers ARN"
  type        = list(string)
}

variable "database_url" {
  description = "Database URL"
  type        = string
}

variable "fast_food_order_payment_queue_url" {
  description = "URL da fila SQS para envio de pedidos para processamento de pagamento"
  type        = string
  default     = ""
}