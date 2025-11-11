import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { ManutencaoService } from './manutencao.service';
import { CreateManutencaoDto } from './dto/create-manutencao.dto';
import { UpdateManutencaoDto } from './dto/update-manutencao.dto';
import { Manutencao } from '../../shared/entities/manutencao.entity';
import { Authorization } from '../../shared/decorators/authorization.decorator';
import { Role } from '../../shared/enums/role.enum';

@Controller('manutencao')
export class ManutencaoController {
  constructor(private readonly manutencaoService: ManutencaoService) {}

  @Post()
  @Authorization({ roles: [Role.SYNDIC, Role.EMPLOYEE] })
  async create(
    @Body() createManutencaoDto: CreateManutencaoDto,
  ): Promise<Manutencao> {
    return this.manutencaoService.create(createManutencaoDto);
  }

  @Get()
  async findAll(): Promise<Manutencao[]> {
    return this.manutencaoService.findAll();
  }

  @Get(':id')
  @Authorization({ roles: [Role.SYNDIC, Role.EMPLOYEE] })
  async findOne(@Param('id') id: string): Promise<Manutencao> {
    return this.manutencaoService.findOne(+id);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateManutencaoDto: UpdateManutencaoDto,
  ): Promise<Manutencao> {
    return this.manutencaoService.update(+id, updateManutencaoDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    return this.manutencaoService.remove(+id);
  }
}
