import { Injectable } from '@nestjs/common';
import { Booking } from '../../shared/entities/booking.entity';
import { Order } from '../../shared/enums/data.enum';
import { DataSource, Repository, DeepPartial } from 'typeorm';

@Injectable()
export class BookingsRepository {
  private repository: Repository<Booking>;

  constructor(private dataSource: DataSource) {
    this.repository = this.dataSource.getRepository(Booking);
  }

  findAll(): Promise<Booking[]> {
    return this.repository.find({
      relations: ['user', 'area'],
      select: {
        id: true,
        date: true,
        time: true,
        numberOfPeople: true,
        createdAt: true,
        updatedAt: true,
        user: {
          id: true,
          name: true,
        },
        area: {
          id: true,
          name: true,
          description: true,
        },
      },
      order: { createdAt: Order.ASC },
    });
  }

  async findByAreaAndDateWithTimeRange(
    areaId: number,
    date: string,
    startTime: string,
    endTime: string,
  ): Promise<Booking[]> {
    return this.repository
      .createQueryBuilder('booking')
      .leftJoinAndSelect('booking.area', 'area')
      .leftJoinAndSelect('booking.user', 'user')
      .where('area.id = :areaId', { areaId })
      .andWhere('booking.date = :date', { date })
      .andWhere('(booking.time < :endTime AND booking.endTime > :startTime)', {
        startTime,
        endTime,
      })
      .getMany();
  }

  findByUserId(userId: number): Promise<Booking[]> {
    return this.repository.find({
      where: { user: { id: userId } },
      relations: ['user', 'area'],
      select: {
        id: true,
        date: true,
        time: true,
        numberOfPeople: true,
        createdAt: true,
        updatedAt: true,
        user: {
          id: true,
          name: true,
        },
        area: {
          id: true,
          name: true,
          description: true,
        },
      },
      order: { createdAt: Order.ASC },
    });
  }

  async findByAreaDateAndTime(
    areaId: number,
    date: string,
    time: string,
  ): Promise<Booking | null> {
    return this.repository.findOne({
      where: {
        area: { id: areaId },
        date: new Date(date),
        time: time,
      },
      relations: ['area', 'user'],
    });
  }

  findOne(id: number): Promise<Booking> {
    return this.repository.findOne({
      where: { id },
      relations: ['user', 'area'],
      select: {
        id: true,
        date: true,
        time: true,
        numberOfPeople: true,
        createdAt: true,
        updatedAt: true,
        user: {
          id: true,
          name: true,
        },
        area: {
          id: true,
          name: true,
          description: true,
        },
      },
    });
  }

  create(dto: DeepPartial<Booking>): Promise<Booking> {
    const object: Booking = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(booking: Booking): Promise<Booking> {
    return this.repository.save(booking);
  }

  async delete(id: number): Promise<void> {
    const booking = await this.repository.findOne({ where: { id } });
    if (!booking) {
      throw new Error(`Booking with id ${id} not found`);
    }
    await this.repository.remove(booking);
  }
}
