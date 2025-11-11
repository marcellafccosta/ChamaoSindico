import { Injectable } from '@nestjs/common';
import { CreateVisitanteDto } from './dto/create-visitante.dto';
import { UpdateVisitanteDto } from './dto/update-visitante.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Apartamento } from '../../shared/entities/apartamento.entity';
import { UsersRepository } from '../../shared/repositories/users.repository';
import { Repository } from 'typeorm';
import { VisitanteRepository } from '../../shared/repositories/visitante.repository';
import { Visitante } from '../../shared/entities/visitante.entity';

@Injectable()
export class VisitanteService {
  constructor(private visitanteRepository: VisitanteRepository) {}

  async create(dto: CreateVisitanteDto): Promise<Visitante> {
    return this.visitanteRepository.create({
      ...dto,
      apartamento: { id: dto.apartamentoId },
      user: { id: dto.userId },
    });
  }

  async employeeCreate(dto: CreateVisitanteDto): Promise<Visitante> {
    return this.visitanteRepository.create({
      ...dto,
      apartamento: { id: dto.apartamentoId },
      user: { id: dto.userId },
      checkIn: new Date(),
    });
  }

  async findVisitantesByApartamento(id: number): Promise<Visitante[]> {
    return this.visitanteRepository.findVisitantesByApartamento(id);
  }

  findAll(): Promise<Visitante[]> {
    return this.visitanteRepository.findAll();
  }

  findOne(id: number): Promise<Visitante> {
    return this.visitanteRepository.findOne(id);
  }

  update(visitante: Visitante, dto: UpdateVisitanteDto): Promise<Visitante> {
    Object.assign(visitante, dto);
    return this.visitanteRepository.save(visitante);
  }

  check(visitante: Visitante): Promise<Visitante> {
    if (!visitante.checkIn) {
      visitante.checkIn = new Date();
    } else {
      visitante.checkOut = new Date();
    }
    return this.visitanteRepository.save(visitante);
  }

  remove(id: number): Promise<void> {
    return this.visitanteRepository.delete(id);
  }
}
