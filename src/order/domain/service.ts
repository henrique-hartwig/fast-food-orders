import { Items, Order, OrderStatus } from './entity';
import { OrderRepository } from './repository';

export class OrderService {
  constructor(private order: OrderRepository) {}

  async createOrder(items: Items, total: number, userId?: number): Promise<Order> {
    const order = new Order(Date.now(), items, total, OrderStatus.RECEIVED, userId);
    return this.order.create(order);
  }

  async getOrderById(id: number): Promise<Order | null> {
    return this.order.findById(id);
  }

  async updateOrder(id: number, items: Items, total: number, userId?: number): Promise<Order> {
    const order = await this.order.findById(id);
    if (!order) {
      throw new Error('Order not found');
    }
    order.items = items;
    order.total = total;
    if (userId) {
      order.userId = userId;
    }
    return this.order.update(order);
  }

  async updateOrderStatus(id: number, status: OrderStatus): Promise<Order> {
    const order = await this.getOrderById(id);
    if (!order) {
      throw new Error('Order not found');
    }
    order.status = status;
    return this.order.update(order);
  }

  async deleteOrder(id: number): Promise<boolean> {
    return this.order.delete(id);
  }

  async listOrders(limit: number, offset: number): Promise<Order[]> {
    return this.order.list(limit, offset);
  }
}
