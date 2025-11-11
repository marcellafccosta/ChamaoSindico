import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { AvisoService } from './aviso.service';
import { CreateAvisoDto } from './dto/create-aviso.dto';
import { UpdateAvisoDto } from './dto/update-aviso.dto';
import { Aviso } from '../../shared/entities/aviso.entity';

@Controller('aviso')
export class AvisoController {
  constructor(private readonly avisoService: AvisoService) {}

  @Post()
  async create(@Body() createAvisoDto: CreateAvisoDto): Promise<Aviso> {
    return this.avisoService.create(createAvisoDto);
  }

  @Get()
  async findAll(): Promise<Aviso[]> {
    return this.avisoService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Aviso> {
    return this.avisoService.findOne(+id);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateAvisoDto: UpdateAvisoDto,
  ): Promise<Aviso> {
    return this.avisoService.update(+id, updateAvisoDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    return this.avisoService.remove(+id);
  }
}
