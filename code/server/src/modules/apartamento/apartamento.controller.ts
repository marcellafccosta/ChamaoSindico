import { Controller, Get, Post, Body, Patch, Param, Delete, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { ApartamentoService } from './apartamento.service';
import { CreateApartamentoDto } from './dto/create-apartamento.dto';
import { UpdateApartamentoDto } from './dto/update-apartamento.dto';

@Controller('apartamento')
export class ApartamentoController {
  constructor(private readonly service: ApartamentoService) {}

  @Post()
  async create(@Body() dto: CreateApartamentoDto) {
    try {
      if (!dto.name) {
        throw new UnauthorizedException('Name is required');
      }

      return this.service.create(dto);
    } catch (error) {
      console.error('Error creating apartamento:', error);
      throw new UnauthorizedException('Failed to create apartamento');
    }
  }

  @Get()
  async findAll() {
    try {
      const apartamento = await this.service.findAll();
      if (!apartamento || apartamento.length === 0) {
        throw new UnauthorizedException('No apartamentos found');
      }

      return apartamento;

    }catch (error) {
      console.error('Error fetching apartamentos:', error);
      throw new UnauthorizedException('Failed to fetch apartamentos');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    if (!id) {
      throw new UnauthorizedException('Id is required in apartamento');
    }
    
    const apartamento = await this.service.findOne(+id);

    if (!apartamento) {
      throw new NotFoundException('Apartamento not found');
    }
    return apartamento;
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateApartamentoDto: UpdateApartamentoDto) {
    try{
      if (!id) {
        throw new UnauthorizedException('Id is required to update apartamento');
      }
      
      const apartamento = await this.service.findOne(+id);
      
      if (!apartamento) {
        throw new NotFoundException('Apartamento not found');
      }

      return this.service.update(+id, updateApartamentoDto);

    }catch (error) {
      console.error('Error update apartamento:', error);
      throw new UnauthorizedException('Failed to update apartamento');
    }
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    try{
      if (!id) {
        throw new UnauthorizedException('Id is required to remove apartamento');
      }
      
      const apartamento = await this.service.findOne(+id);
      
      if (!apartamento) {
        throw new NotFoundException('Apartamento not found');
      }

      return this.service.remove(+id);

    }catch (error) {
      console.error('Error remove apartamento:', error);
      throw new UnauthorizedException('Failed to remove apartamento');
    }
  }
}
