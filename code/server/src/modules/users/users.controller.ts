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
} from '@nestjs/common';
import { User } from '../../shared/entities/user.entity';
import { CreateRequestDTO } from './dto/createRequest.dto';
import { UpdateRequestDTO } from './dto/updateRequest.dto';
import { UsersService } from './users.service';
import { ApartamentoService } from '../../modules/apartamento/apartamento.service';
import { UpdateFcmTokenDto } from './dto/updateFcmToken.dto';

@Controller('user')
export class UsersController {
  constructor(
    private readonly service: UsersService,
    private apartamentoService: ApartamentoService,
  ) {}

  @Get()
  async findAll(): Promise<User[]> {
    return this.service.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: number): Promise<User> {
    return this.service.findOne(id);
  }

  @Post()
  async create(@Body() dto: CreateRequestDTO): Promise<User> {
    return this.service.create(dto);
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const user = await this.service.findByEmail(body.email);

    if (!user || user.password !== body.password) {
      throw new UnauthorizedException('Credenciais inválidas');
    }

    return user;
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateRequestDTO,
  ): Promise<User> {
    return this.service.update(+id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    await this.service.remove(+id);
  }

  @Patch(':apartamentoId/users')
  async vincularUsuarios(
    @Param('apartamentoId') apartamentoId: number,
    @Body('userIds') userIds: number[],
  ) {
    if (!userIds || userIds.length === 0) {
      throw new UnauthorizedException(
        'Nenhum usuário fornecido para vinculação',
      );
    }

    if (!apartamentoId) {
      throw new UnauthorizedException('ID do apartamento não fornecido');
    }
    const apartamento = await this.apartamentoService.findOne(apartamentoId);

    if (!apartamento) {
      throw new NotFoundException('Apartamento não encontrado');
    }
    return this.service.vincularUsuarios(apartamentoId, userIds);
  }

  @Patch(':id/fcm-token')
  updateFcmToken(
    @Param('id') id: string,
    @Body() updateFcmTokenDto: UpdateFcmTokenDto,
  ) {
    return this.service.updateFcmToken(+id, updateFcmTokenDto.fcmToken);
  }
}
