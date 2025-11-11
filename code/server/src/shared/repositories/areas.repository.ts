import { Injectable } from '@nestjs/common';
import { Area } from '../../shared/entities/area.entity';
import { Order } from '../../shared/enums/data.enum';
import { DataSource, Repository, DeepPartial } from 'typeorm';

@Injectable()
export class AreasRepository {
  private repository: Repository<Area>;

  constructor(private dataSource: DataSource) {
    this.repository = this.dataSource.getRepository(Area);
  }

  findAll(): Promise<Area[]> {
    return this.repository.find({
      select: {
        id: true,
        name: true,
        price: true,
        peopleLimit: true,
      },
      order: { name: Order.ASC },
    });
  }

  findOne(id: number): Promise<Area> {
    return this.repository.findOne({ where: { id } });
  }

  create(dto: DeepPartial<Area>): Promise<Area> {
    const object: Area = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(area: Area): Promise<Area> {
    return this.repository.save(area);
  }

  async delete(id: number): Promise<void> {
    const area = await this.repository.findOne({ where: { id } });
    if (!area) {
      throw new Error(`Area with id ${id} not found`);
    }
    await this.repository.remove(area);
  }
}
