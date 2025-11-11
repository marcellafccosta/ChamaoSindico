import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UnauthorizedException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { VisitanteService } from './visitante.service';
import { CreateVisitanteDto } from './dto/create-visitante.dto';
import { UpdateVisitanteDto } from './dto/update-visitante.dto';
import { UsersService } from '../../modules/users/users.service';
import { ApartamentoService } from '../../modules/apartamento/apartamento.service';
import { Role } from '../../shared/enums/role.enum';


@Controller('visitante')
export class VisitanteController {
  constructor(
    private readonly visitanteService: VisitanteService,
    private userService: UsersService,
    private apartamentoService: ApartamentoService,
  ) {}

  @Post()
  async create(@Body() dto: CreateVisitanteDto) {
    if (!dto.apartamentoId || !dto.userId) {
      throw new UnauthorizedException(
        'Apartamento ID and User ID are required',
      );
    }
    const apartamentoId = Number(dto.apartamentoId);
    const userId = Number(dto.userId);
    const apartamento = await this.apartamentoService.findOne(apartamentoId);
    const user = await this.userService.findOne(userId);
    if (!apartamento) {
      throw new NotFoundException('Apartamento not found');
    }
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.role == Role.EMPLOYEE) {
      return this.visitanteService.employeeCreate(dto);
    }

    return this.visitanteService.create(dto);
  }

  @Get()
  findAll() {
    return this.visitanteService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    if (!id) {
      throw new UnauthorizedException('ID is required');
    }
    const visitanteId = Number(id);
    const visitante = await this.visitanteService.findOne(visitanteId);
    if (!visitante) {
      throw new NotFoundException('Visitante not found');
    }
    return visitante;
  }

  @Get('apartamento/:id')
  async findVisitantesByApartamento(@Param('id') id: string) {
    if (!id) {
      throw new UnauthorizedException('ID is required');
    }
    const apartamentoId = Number(id);
    const apartamento = await this.apartamentoService.findOne(apartamentoId);
    if (!apartamento) {
      throw new NotFoundException('Apartamento not found');
    }
    return this.visitanteService.findVisitantesByApartamento(apartamentoId);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateVisitanteDto: UpdateVisitanteDto,
  ) {
    if (!id) {
      throw new BadRequestException('ID is required');
    }

    const visitanteId = Number(id);
    const visitante = await this.visitanteService.findOne(visitanteId);

    if (!visitante) {
      throw new NotFoundException('Visitante not found');
    }

    return this.visitanteService.update(visitante, updateVisitanteDto);
  }

  @Patch('check/:id')
  async check(@Param('id') id: string) {
    if (!id) {
      throw new BadRequestException('ID is required');
    }

    const visitanteId = Number(id);
    const visitante = await this.visitanteService.findOne(visitanteId);

    if (!visitante) {
      throw new NotFoundException('Visitante not found');
    }

    if (visitante.checkIn && visitante.checkOut) {
      throw new BadRequestException('Check-in and check-out are already set');
    }

    return this.visitanteService.check(visitante);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    if (!id) {
      throw new UnauthorizedException('ID is required');
    }
    const visitanteId = Number(id);
    const visitante = await this.visitanteService.findOne(visitanteId);
    if (!visitante) {
      throw new NotFoundException('Visitante not found');
    }
    return this.visitanteService.remove(visitanteId);
  }

    
}
