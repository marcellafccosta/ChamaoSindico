import { Test, TestingModule } from '@nestjs/testing';
import { ConflictException } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { BookingsRepository } from '../../shared/repositories/bookings.repository';
import { Booking } from '../../shared/entities/booking.entity';
import { CreateBookingsRequestDTO } from './dtos/createRequestDTO.dto';
import { UpdateBookingsRequestDTO } from './dtos/updateRequestDTO.dto';

const mockBookingsRepository = () => ({
  findAll: jest.fn(),
  findByUserId: jest.fn(),
  findOne: jest.fn(),
  findByAreaAndDateWithTimeRange: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  delete: jest.fn(),
});

describe('BookingsService', () => {
  let service: BookingsService;
  let repository: ReturnType<typeof mockBookingsRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BookingsService,
        { provide: BookingsRepository, useFactory: mockBookingsRepository },
      ],
    }).compile();

    service = module.get<BookingsService>(BookingsService);
    repository = module.get(BookingsRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });


  describe('update', () => {
    it('deve atualizar uma reserva com sucesso (aceite)', async () => {
      const booking = { id: 1, foo: 'bar' } as unknown as Booking;
      const dto: UpdateBookingsRequestDTO = { foo: 'baz' } as any;
      repository.findOne.mockResolvedValue(booking);
      repository.save.mockResolvedValue({ ...booking, ...dto });

      const result = await service.update(1, dto);

      expect(result).toEqual({ id: 1, foo: 'baz' });
      expect(repository.save).toHaveBeenCalledWith({ id: 1, foo: 'baz' });
    });

    it('deve lançar erro ao tentar atualizar uma reserva inexistente (falha)', async () => {
      repository.findOne.mockResolvedValue(undefined);
      const dto: UpdateBookingsRequestDTO = { foo: 'baz' } as any;

      await expect(service.update(999, dto)).rejects.toThrow(
        'Booking with id 999 not found',
      );
    });
  });

  describe('remove', () => {
    it('deve remover uma reserva com sucesso (aceite)', async () => {
      repository.findOne.mockResolvedValue({ id: 1 } as Booking);
      repository.delete.mockResolvedValue(undefined);

      await expect(service.remove(1)).resolves.toBeUndefined();
      expect(repository.delete).toHaveBeenCalledWith(1);
    });

    it('deve lançar erro ao tentar remover uma reserva inexistente (falha)', async () => {
      repository.findOne.mockResolvedValue(undefined);

      await expect(service.remove(999)).rejects.toThrow(
        'Booking with id 999 not found',
      );
    });
  });

 
});
