import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Patch,
} from '@nestjs/common';
import { Area } from '../../shared/entities/area.entity';
import { CreateAreasRequestDTO } from './dtos/createRequestDTO.dto';
import { AreasService } from './areas.service';
import { UpdateAreasRequestDTO } from './dtos/updateRequestDTO.dto';

@Controller('areas')
export class AreasController {
  constructor(private readonly service: AreasService) {}

  @Get()
  async findAll(): Promise<Area[]> {
    return this.service.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: number): Promise<Area> {
    return this.service.findOne(id);
  }

  @Post()
  async create(@Body() dto: CreateAreasRequestDTO): Promise<Area> {
    return this.service.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateAreasRequestDTO,
  ): Promise<Area> {
    return this.service.update(+id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    await this.service.remove(+id);
  }
}
