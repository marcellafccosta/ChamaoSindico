import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Request,
  UseGuards,
  ParseIntPipe,
  Query,
  DefaultValuePipe,
} from '@nestjs/common';
import { ProfissionalService } from './profissional.service';
import { CreateProfissionalDto } from './dto/create-profissional.dto';
import { UpdateProfissionalDto } from './dto/update-profissional.dto';
import { Profissional } from '../../shared/entities/profissional.entity';
import { isAuthenticated } from '../../shared/guards/isAuthenticated.guard.guard';

@Controller('profissional')
export class ProfissionalController {
  constructor(private readonly profissionalService: ProfissionalService) {}

  @Post()
  @UseGuards(isAuthenticated)
  async create(
    @Body() createProfissionalDto: CreateProfissionalDto,
    @Request() req: any,
  ): Promise<Profissional> {
    const userId = req.user?.sub || req.user?.id;
    return this.profissionalService.create(createProfissionalDto, userId);
  }

  @Get()
  async findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number,
  ) {
    return this.profissionalService.findAll(page, Math.min(limit, 100)); // Max 100 por página
  }

  @Get('area/:area')
  async findByArea(@Param('area') area: string): Promise<Profissional[]> {
    return this.profissionalService.findByArea(area);
  }

  @Get('meus')
  @UseGuards(isAuthenticated)
  async findMyIndications(@Request() req: any): Promise<Profissional[]> {
    const userId = req.user?.sub || req.user?.id;
    return this.profissionalService.findByUser(userId);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number): Promise<Profissional> {
    return this.profissionalService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(isAuthenticated)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateProfissionalDto: UpdateProfissionalDto,
    @Request() req: any,
  ): Promise<Profissional> {
    const userId = req.user?.sub || req.user?.id;
    return this.profissionalService.update(id, updateProfissionalDto, userId);
  }

  @Delete(':id')
  @UseGuards(isAuthenticated)
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: any,
  ): Promise<void> {
    const userId = req.user?.sub || req.user?.id;
    return this.profissionalService.remove(id, userId);
  }
}
