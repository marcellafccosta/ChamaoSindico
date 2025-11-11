import { Injectable } from '@nestjs/common';
import { Area } from '../../shared/entities/area.entity';
import { CreateAreasRequestDTO } from './dtos/createRequestDTO.dto';
import { AreasRepository } from '../../shared/repositories/areas.repository';
import { UpdateAreasRequestDTO } from './dtos/updateRequestDTO.dto';

@Injectable()
export class AreasService {
  constructor(private areasRepository: AreasRepository) {}

  async findAll(): Promise<Area[]> {
    return this.areasRepository.findAll();
  }

  async findOne(id: number): Promise<Area> {
    return this.areasRepository.findOne(id);
  }

  async create(dto: CreateAreasRequestDTO): Promise<Area> {
    return this.areasRepository.create(dto);
  }

  async update(id: number, dto: UpdateAreasRequestDTO): Promise<Area> {
    const area = await this.findOne(id);
    if (!area) {
      throw new Error(`Area with id ${id} not found`);
    }
    Object.assign(area, dto);
    return this.areasRepository.save(area);
  }

  async remove(id: number): Promise<void> {
    const area = await this.findOne(id);
    if (!area) {
      throw new Error(`Area with id ${id} not found`);
    }
    await this.areasRepository.delete(id);
  }
}
