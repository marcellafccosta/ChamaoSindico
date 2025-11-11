import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Patch,
  Query,
} from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { CreateBookingsRequestDTO } from './dtos/createRequestDTO.dto';
import { Booking } from '../../shared/entities/booking.entity';
import { UpdateBookingsRequestDTO } from './dtos/updateRequestDTO.dto';

@Controller('bookings')
export class BookingsController {
  constructor(private readonly service: BookingsService) {}

  @Get()
  async findAll(@Query('userId') userId?: string): Promise<Booking[]> {
    console.log('Query userId recebido:', userId);

    if (userId) {
      const userIdNumber = +userId;
      console.log('Buscando reservas para userId:', userIdNumber);
      return this.service.findByUserId(userIdNumber);
    }

    console.log('Buscando todas as reservas');
    return this.service.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: number): Promise<Booking> {
    return this.service.findOne(id);
  }

  @Post()
  async create(@Body() dto: CreateBookingsRequestDTO): Promise<Booking> {
    return this.service.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateBookingsRequestDTO,
  ): Promise<Booking> {
    return this.service.update(+id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    await this.service.remove(+id);
  }
}
