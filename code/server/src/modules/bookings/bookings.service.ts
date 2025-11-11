import { Injectable, ConflictException } from '@nestjs/common';
import { BookingsRepository } from '../../shared/repositories/bookings.repository';
import { Booking } from '../../shared/entities/booking.entity';
import { CreateBookingsRequestDTO } from './dtos/createRequestDTO.dto';
import { UpdateBookingsRequestDTO } from './dtos/updateRequestDTO.dto';

@Injectable()
export class BookingsService {
  constructor(private bookingsRepository: BookingsRepository) {}

  async findAll(): Promise<Booking[]> {
    return this.bookingsRepository.findAll();
  }

  async findByUserId(userId: number): Promise<Booking[]> {
    return this.bookingsRepository.findByUserId(userId);
  }

  async findOne(id: number): Promise<Booking> {
    return this.bookingsRepository.findOne(id);
  }

  async create(dto: CreateBookingsRequestDTO): Promise<Booking> {
    // Verificar conflitos de horário (considerando endTime)
    const conflictingBookings =
      await this.bookingsRepository.findByAreaAndDateWithTimeRange(
        dto.areaId,
        dto.date,
        dto.time,
        dto.endTime,
      );

    if (conflictingBookings.length > 0) {
      throw new ConflictException(
        `Já existe uma reserva para esta área no período solicitado. Escolha outro horário.`,
      );
    }

    const booking = await this.bookingsRepository.create({
      ...dto,
      user: { id: dto.userId },
      area: { id: dto.areaId },
    });
    return booking;
  }

  async update(id: number, dto: UpdateBookingsRequestDTO): Promise<Booking> {
    const booking = await this.findOne(id);
    if (!booking) {
      throw new Error(`Booking with id ${id} not found`);
    }
    Object.assign(booking, dto);
    return this.bookingsRepository.save(booking);
  }

  async remove(id: number): Promise<void> {
    const booking = await this.findOne(id);
    if (!booking) {
      throw new Error(`Booking with id ${id} not found`);
    }
    await this.bookingsRepository.delete(id);
  }
}
