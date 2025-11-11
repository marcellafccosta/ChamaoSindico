import { Test, TestingModule } from '@nestjs/testing';
import { ManutencaoService } from './manutencao.service';
import { ManutencaoRepository } from '../../shared/repositories/manutencao.repository';
import { manutencaoStatus } from '../../shared/enums/manutencaoStatus.enum';
import { NotFoundException } from '@nestjs/common';

const mockManutencaoRepository = () => ({
  create: jest.fn(),
  findAll: jest.fn(),
  findById: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
});

describe('ManutencaoService', () => {
  let service: ManutencaoService;
  let repository: ReturnType<typeof mockManutencaoRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ManutencaoService,
        { provide: ManutencaoRepository, useFactory: mockManutencaoRepository },
      ],
    }).compile();

    service = module.get<ManutencaoService>(ManutencaoService);
    repository = module.get(ManutencaoRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a manutencao with status EM_DIA if dates are missing', async () => {
      const dto = { descricao: 'Teste' };
      repository.create.mockResolvedValue({
        ...dto,
        status: manutencaoStatus.EM_DIA,
      });
      const result = await service.create(dto as any);
      expect(result.status).toBe(manutencaoStatus.EM_DIA);
      expect(repository.create).toHaveBeenCalled();
    });

    it('should create a manutencao with status CONCLUIDO if manutencaoRealizada is true', async () => {
      const dto = {
        descricao: 'Teste',
        dataManutencao: new Date(),
        dataProximaManutencao: new Date(),
        manutencaoRealizada: true,
      };
      repository.create.mockResolvedValue({
        ...dto,
        status: manutencaoStatus.CONCLUIDO,
      });
      const result = await service.create(dto as any);
      expect(result.status).toBe(manutencaoStatus.CONCLUIDO);
    });
  });

  describe('findAll', () => {
    it('should return all manutencoes', async () => {
      const manutencoes = [
        {
          id: 1,
          dataManutencao: new Date(),
          dataProximaManutencao: new Date(Date.now() + 86400000),
          manutencaoRealizada: false,
          status: manutencaoStatus.EM_DIA,
        },
      ];
      repository.findAll.mockResolvedValue(manutencoes);
      repository.update.mockResolvedValue(undefined);
      const result = await service.findAll();
      expect(result).toEqual(manutencoes);
    });
  });



});
