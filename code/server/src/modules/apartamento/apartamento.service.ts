import { Injectable } from '@nestjs/common';
import { ApartamentoRepository } from '../../shared/repositories/apartamento.repository';
import { CreateApartamentoDto } from './dto/create-apartamento.dto';
import { UpdateApartamentoDto } from './dto/update-apartamento.dto';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from '../../shared/entities/user.entity';

@Injectable()
export class ApartamentoService {
  constructor(private apartamentoRepository: ApartamentoRepository) {}

  async create(dto: CreateApartamentoDto) {
    const apartamento = await this.apartamentoRepository.create({
      ...dto,
    });
    return apartamento;
  }

  findAll() {
    return this.apartamentoRepository.findAll();
  }

  findOne(id: number) {
    return this.apartamentoRepository.findOne(id);
  }

  async update(id: number, dto: UpdateApartamentoDto) {
    const apartamento = await this.findOne(id);
    Object.assign(apartamento, dto);
    return this.apartamentoRepository.save(apartamento);
  }

  async remove(id: number) {
    const apartamento = await this.findOne(id);
    if (!apartamento) {
      throw new Error(`Apartamento with id ${id} not found`);
    }
    await this.apartamentoRepository.delete(id);
  }
}
