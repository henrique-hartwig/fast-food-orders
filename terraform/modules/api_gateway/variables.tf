variable "environment" {
  description = "Deployment environment (dev, prod)"
  type        = string
  default     = "dev"
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}
variable "product_category_lambdas" {
  description = "Information about the product category lambda functions"
  type = map(object({
    function_name = string
    arn           = string
    invoke_arn    = string
  }))
}

variable "product_lambdas" {
  description = "Information about the product lambda functions"
  type = map(object({
    function_name = string
    arn           = string
    invoke_arn    = string
  }))
}

variable "order_lambdas" {
  description = "Information about the order lambda functions"
  type = map(object({
    function_name = string
    arn           = string
    invoke_arn    = string
  }))
}