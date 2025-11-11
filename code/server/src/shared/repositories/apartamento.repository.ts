import { Injectable } from '@nestjs/common';
import { Apartamento } from '../../shared/entities/apartamento.entity';
import { DataSource, Repository, DeepPartial } from 'typeorm';

@Injectable()
export class ApartamentoRepository {
  private repository: Repository<Apartamento>;

  constructor(private dataSource: DataSource) {
    this.repository = this.dataSource.getRepository(Apartamento);
  }

  findAll(): Promise<Apartamento[]> {
    return this.repository.find({
      select: {
        id: true,
        name: true,
        users: true,
        vaga: true,
      },
      relations: {
        users: true,
        vaga: true,
      },
      order: { updatedAt: 'DESC' },
    });
  }

  findOne(id: number): Promise<Apartamento> {
    return this.repository.findOne({ where: { id } });
  }

  create(dto: DeepPartial<Apartamento>): Promise<Apartamento> {
    const object: Apartamento = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(apartamento: Apartamento): Promise<Apartamento> {
    return this.repository.save(apartamento);
  }

  async delete(id: number): Promise<void> {
    const apartamento = await this.repository.findOne({ where: { id } });
    if (!apartamento) {
      throw new Error(`Apartamento with id ${id} not found`);
    }
    await this.repository.remove(apartamento);
  }
}
