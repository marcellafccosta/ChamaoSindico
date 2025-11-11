import { Test, TestingModule } from '@nestjs/testing';
import { ProfissionalService } from './profissional.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Profissional } from '../../shared/entities/profissional.entity';
import { Repository } from 'typeorm';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';

const profissionalArray = [
  {
    id: 1,
    nome: 'João',
    areaAtuacao: 'Elétrica',
    userId: 1,
    usuario: {},
    createdAt: new Date(),
  },
  {
    id: 2,
    nome: 'Maria',
    areaAtuacao: 'Pintura',
    userId: 2,
    usuario: {},
    createdAt: new Date(),
  },
];

describe('ProfissionalService', () => {
  let service: ProfissionalService;
  let repo: Repository<Profissional>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfissionalService,
        {
          provide: getRepositoryToken(Profissional),
          useValue: {
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
            findAndCount: jest.fn(),
            find: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<ProfissionalService>(ProfissionalService);
    repo = module.get<Repository<Profissional>>(
      getRepositoryToken(Profissional),
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('update', () => {
    it('deve atualizar um profissional com sucesso (aceite)', async () => {
      const profissional = { ...profissionalArray[0] };
      const dto = { nome: 'João Atualizado' } as any;
      jest
        .spyOn(service, 'findOne')
        .mockResolvedValueOnce(profissional as Profissional);
      (repo.update as jest.Mock).mockResolvedValue(undefined);
      jest
        .spyOn(service, 'findOne')
        .mockResolvedValueOnce({ ...profissional, ...dto } as Profissional);

      const result = await service.update(1, dto, 1);

      expect(result).toEqual({ ...profissional, ...dto });
      expect(repo.update).toHaveBeenCalledWith(1, dto);
    });

    it('deve lançar erro ao tentar atualizar um profissional de outro usuário (falha)', async () => {
      jest
        .spyOn(service, 'findOne')
        .mockResolvedValueOnce({
          ...profissionalArray[0],
          userId: 2,
        } as Profissional);

      await expect(
        service.update(1, { nome: 'Teste' } as any, 1),
      ).rejects.toThrow(ForbiddenException);
    });

    it('deve lançar erro ao tentar atualizar um profissional inexistente (falha)', async () => {
      jest
        .spyOn(service, 'findOne')
        .mockRejectedValueOnce(new NotFoundException());

      await expect(
        service.update(999, { nome: 'Teste' } as any, 1),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('deve remover um profissional com sucesso (aceite)', async () => {
      jest
        .spyOn(service, 'findOne')
        .mockResolvedValueOnce({
          ...profissionalArray[0],
          userId: 1,
        } as Profissional);
      (repo.delete as jest.Mock).mockResolvedValue({ affected: 1 });

      await expect(service.remove(1, 1)).resolves.toBeUndefined();
      expect(repo.delete).toHaveBeenCalledWith(1);
    });

    it('deve lançar erro ao tentar remover um profissional de outro usuário (falha)', async () => {
      jest
        .spyOn(service, 'findOne')
        .mockResolvedValueOnce({
          ...profissionalArray[0],
          userId: 2,
        } as Profissional);

      await expect(service.remove(1, 1)).rejects.toThrow(ForbiddenException);
    });

    it('deve lançar erro ao tentar remover um profissional inexistente (falha)', async () => {
      jest
        .spyOn(service, 'findOne')
        .mockResolvedValueOnce({
          ...profissionalArray[0],
          userId: 1,
        } as Profissional);
      (repo.delete as jest.Mock).mockResolvedValue({ affected: 0 });

      await expect(service.remove(1, 1)).rejects.toThrow(NotFoundException);
    });
  });
});
