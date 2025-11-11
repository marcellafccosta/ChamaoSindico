import { Injectable } from '@nestjs/common';
import { Package } from '../../shared/entities/package.entity';
import { DataSource, Repository, DeepPartial, In } from 'typeorm';

@Injectable()
export class PackagesRepository {
  private repository: Repository<Package>;

  constructor(private dataSource: DataSource) {
    this.repository = this.dataSource.getRepository(Package);
  }

  findAll(): Promise<Package[]> {
    return this.repository.find({
      select: {
        id: true,
        store: true,
        keyword: true,
        estimatedDelivery: true,
        recipient: true,
        status: true,
      },
      relations: ['apartamento'],
      order: { createdAt: 'ASC' },
    });
  }

  findOne(id: number): Promise<Package> {
    return this.repository.findOne({ where: { id } });
  }

  create(dto: DeepPartial<Package>): Promise<Package> {
    const object: Package = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(packageEntity: Package): Promise<Package> {
    return this.repository.save(packageEntity);
  }

  async delete(id: number): Promise<void> {
    const packageEntity = await this.repository.findOne({ where: { id } });
    if (!packageEntity) {
      throw new Error(`Package with id ${id} not found`);
    }
    await this.repository.remove(packageEntity);
  }
}
