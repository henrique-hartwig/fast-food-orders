import { z } from 'zod';
import { ProductCategoryService } from '../../domain/service';

const CreateProductCategorySchema = z.object({
  name: z.string().trim().min(1).max(100),
  description: z.string().trim().min(5).max(500)
});

export type CreateProductCategoryRequest = z.infer<typeof CreateProductCategorySchema>;

export class CreateProductCategoryController {
  constructor(private productCategoryService: ProductCategoryService) { }

  async handle(request: CreateProductCategoryRequest) {
    try {
      const validatedData = CreateProductCategorySchema.parse(request);

      const productCategory = await this.productCategoryService.createProductCategory(
        validatedData.name,
        validatedData.description
      ) as any;

      if (productCategory.error) {
        throw Error(productCategory.error);
      }

      return productCategory;
    } catch (error: any) {
      throw error;
    }
  }
}