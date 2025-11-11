import { Controller, Get, Post, Body, Patch, Param, Delete, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { VagaService } from './vaga.service';
import { CreateVagaDto } from './dto/create-vaga.dto';
import { UpdateVagaDto } from './dto/update-vaga.dto';

@Controller('vaga')
export class VagaController {
  constructor(private readonly service: VagaService) {}

  @Post()
  async create(@Body() dto: CreateVagaDto) {
    try {
      if (!dto.apartamentoId || !dto.name) {
        throw new UnauthorizedException('Nome e id do apartamento is required');
      }

      const vaga = await this.service.findOne(dto.apartamentoId);

      if (vaga) {
        throw new UnauthorizedException('Vaga já existe para este apartamento');
      }

      return this.service.create(dto);

    }catch (error) {
      console.error('Error creating vaga:', error);
      throw new UnauthorizedException('Failed to create vaga');
    }
  }

  @Get()
  async findAll() {
    try {
      const vagas = await this.service.findAll();
      if (!vagas || vagas.length === 0) {
        throw new UnauthorizedException('No vagas found');
      }

      return vagas;

    }catch (error) {
      console.error('Error fetching vagas:', error);
      throw new UnauthorizedException('Failed to fetch vagas');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    if (!id) {
      throw new UnauthorizedException('Id is required in vaga');
    }
    
    const vaga = await this.service.findOne(+id);

    if (!vaga) {
      throw new NotFoundException('Vaga not found');
    }
    return vaga;
  }

  @Get('/apartamento/:id')
  async findByApartamento(@Param('id') id: string) {
    if (!id) {
      throw new UnauthorizedException('Id is required in vaga');
    }
    
    const vaga = await this.service.findByApartamento(+id);

    if (!vaga) {
      throw new NotFoundException('Vaga not found');
    }
    return this.service.findByApartamento(+id);
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateVagaDto: UpdateVagaDto) {
    try{
      if (!id) {
        throw new UnauthorizedException('Id is required to update Vaga');
      }
      
      const vaga = await this.service.findOne(+id);
      
      if (!vaga) {
        throw new NotFoundException('Vaga not found');
      }

      return this.service.update(+id, updateVagaDto);

    }catch (error) {
      console.error('Error update Vaga:', error);
      throw new UnauthorizedException('Failed to update Vaga');
    }
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    try{
      if (!id) {
        throw new UnauthorizedException('Id is required to remove Vaga');
      }
      
      const vaga = await this.service.findOne(+id);
      
      if (!vaga) {
        throw new NotFoundException('Vaga not found');
      }

      return this.service.remove(+id);

    }catch (error) {
      console.error('Error remove Vaga:', error);
      throw new UnauthorizedException('Failed to remove Vaga');
    }
  }
}
