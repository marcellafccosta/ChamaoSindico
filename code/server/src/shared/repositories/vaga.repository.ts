import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Vaga } from '../../shared/entities/vaga.entity';
import { DataSource, Repository, DeepPartial } from 'typeorm';

Injectable();
export class VagaRepository {
  constructor(
    @InjectRepository(Vaga)
    private readonly repository: Repository<Vaga>,
  ) {}

  findAll(): Promise<Vaga[]> {
    return this.repository.find({
      select: {
        id: true,
        name: true,
        isOcupada: true,
        apartamentoId: true,
        apartamento: {
          name: true,
        },
      },
      relations: {
        apartamento: true,
      },
      order: { createdAt: 'ASC' },
    });
  }

  findOne(id: number): Promise<Vaga> {
    return this.repository.findOne({ where: { id } });
  }

  create(dto: DeepPartial<Vaga>): Promise<Vaga> {
    const object: Vaga = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(vaga: Vaga): Promise<Vaga> {
    return this.repository.save(vaga);
  }

  async delete(id: number): Promise<void> {
    const vaga = await this.repository.findOne({ where: { id } });
    if (!vaga) {
      throw new Error(`Vaga with id ${id} not found`);
    }
    await this.repository.remove(vaga);
  }
}
