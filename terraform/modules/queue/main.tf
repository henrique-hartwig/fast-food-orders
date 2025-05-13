resource "aws_sqs_queue" "fast_food_order_payment_queue" {
  name                      = "fast-food-order-payment-queue-${var.environment}"
  delay_seconds             = 0
  max_message_size          = 10240
  message_retention_seconds = 3600
  receive_wait_time_seconds = 10

  tags = {
    Environment = var.environment
    Service     = "fast-food-order"
  }
}

resource "aws_sqs_queue_policy" "fast_food_order_payment_queue_policy" {
  queue_url = aws_sqs_queue.fast_food_order_payment_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::992382498858:role/LabRole"
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.fast_food_order_payment_queue.arn
      }
    ]
  })
}
