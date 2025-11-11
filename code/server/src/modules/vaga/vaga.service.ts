import { Injectable } from '@nestjs/common';
import { CreateVagaDto } from './dto/create-vaga.dto';
import { UpdateVagaDto } from './dto/update-vaga.dto';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { VagaRepository } from '../../shared/repositories/vaga.repository';
import { Apartamento } from '../../shared/entities/apartamento.entity';

@Injectable()
export class VagaService {
  constructor(
    private vagaRepository: VagaRepository,
    @InjectRepository(Apartamento)
    private apartamentoRepository: Repository<Apartamento>,
  ) {}

  async create(dto: CreateVagaDto) {
    const apartamento = await this.apartamentoRepository.findOne({
      where: { id: dto.apartamentoId },
    });
    if (apartamento) {
      const vaga = await this.vagaRepository.create({
        ...dto,
        apartamento: { id: dto.apartamentoId },
      });
      return vaga;
    }

    const vaga = await this.vagaRepository.create({
      ...dto,
    });

    return vaga;
  }

  findAll() {
    return this.vagaRepository.findAll();
  }

  findOne(id: number) {
    return this.vagaRepository.findOne(id);
  }

  async findByApartamento(apartamentoId: number) {
    const vagas = await this.vagaRepository.findAll();
    return vagas.filter((vaga) => vaga.apartamentoId === apartamentoId);
  }

  async update(id: number, dto: UpdateVagaDto) {
    const vaga = await this.findOne(id);
    if (!vaga) {
      throw new Error(`Apartamento with id ${id} not found`);
    }
    Object.assign(vaga, dto);
    return this.vagaRepository.save(vaga);
  }

  async remove(id: number) {
    const vaga = await this.findOne(id);
    if (!vaga) {
      throw new Error(`Apartamento with id ${id} not found`);
    }
    await this.vagaRepository.delete(id);
  }
}
