import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import { PrismaClient } from '@prisma/client';
import { OrderService } from '../../domain/service';
import { DbOrderRepository } from '../../domain/database';
import { CreateOrderController } from './controller';
import logger from '../../../utils/logger';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  const prismaClient = new PrismaClient();
  const sqs = new SQSClient({ region: 'us-east-1' });

  try {
    if (!event.body || Object.keys(JSON.parse(event.body)).length === 0) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: 'Request body is required' })
      };
    }

    const requestData = JSON.parse(event.body);

    const orderRepository = new DbOrderRepository(prismaClient);
    const orderService = new OrderService(orderRepository);
    const orderController = new CreateOrderController(orderService);

    const order = await orderController.handle(requestData);

    const sendToPaymentQueueUrl = process.env.QUEUE_URL;

    if (!sendToPaymentQueueUrl) {
      throw new Error('QUEUE_URL is not set');
    }
    const paymentRequest = {
      orderId: order.id,
      paymentMethod: order.paymentMethod,
      amount: order.total,
      items: order.items,
    }

    await sqs.send(new SendMessageCommand({
      QueueUrl: sendToPaymentQueueUrl,
      MessageBody: JSON.stringify(paymentRequest),
      MessageAttributes: {
        OrderId: {
          DataType: 'String',
          StringValue: paymentRequest.toString(),
        },
      },
    }));

    return {
      statusCode: 201,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: 'Order created successfully',
        data: order,
      }),
    };
  } catch (error: any) {
    logger.error('Error creating order', error);

    if (error?.name === 'ZodError') {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: 'Validation error',
          details: error.errors,
        }),
      };
    }

    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'Internal server error' }),
    };
  }
}; 