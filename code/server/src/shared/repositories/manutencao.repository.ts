import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Manutencao } from '../../shared/entities/manutencao.entity';

@Injectable()
export class ManutencaoRepository {
  constructor(
    @InjectRepository(Manutencao)
    private readonly repository: Repository<Manutencao>,
  ) {}

  async create(manutencao: Manutencao): Promise<Manutencao> {
    return this.repository.save(manutencao);
  }

  async findAll(): Promise<Manutencao[]> {
    return this.repository.find();
  }

  async findById(id: number): Promise<Manutencao | null> {
    return this.repository.findOneBy({ id });
  }

  async update(id: number, manutencao: Partial<Manutencao>): Promise<void> {
    await this.repository.update(id, manutencao);
  }

  async delete(id: number): Promise<void> {
    await this.repository.delete(id);
  }
}
