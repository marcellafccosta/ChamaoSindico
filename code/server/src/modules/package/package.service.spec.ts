import { Test, TestingModule } from '@nestjs/testing';
import { PackageService } from './package.service';
import { PackagesRepository } from '../../shared/repositories/packages.repository';
import { packageStatus } from '../../shared/enums/packageStatus.enum';
import { ForbiddenException } from '@nestjs/common';

describe('PackageService', () => {
  let service: PackageService;
  let repo: PackagesRepository;

  beforeEach(async () => {
    const repoMock = {
      create: jest.fn(),
      findAll: jest.fn(),
      findOne: jest.fn(),
      save: jest.fn(),
      delete: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PackageService,
        { provide: PackagesRepository, useValue: repoMock },
      ],
    }).compile();

    service = module.get<PackageService>(PackageService);
    repo = module.get<PackagesRepository>(PackagesRepository);
  });

  it('deve criar e retornar um pacote', async () => {
    const dto = { descricao: 'Pacote Teste', estimatedDelivery: new Date() } as any;
    const apartamentoId = 10;
    const pacoteMock = { id: 1, ...dto, apartamento: { id: apartamentoId }, status: packageStatus.PENDENTE };

    (repo.create as jest.Mock).mockResolvedValue(pacoteMock);

    const result = await service.create(dto, apartamentoId);

    expect(result).toEqual(pacoteMock);
    expect(repo.create).toHaveBeenCalledWith({
      ...dto,
      apartamento: { id: apartamentoId },
      status: packageStatus.PENDENTE,
    });
  });

  it('deve lançar ForbiddenException se apartamentoId não for informado', async () => {
    const dto = { descricao: 'Pacote Teste', estimatedDelivery: new Date() } as any;

    await expect(service.create(dto, undefined)).rejects.toThrow(ForbiddenException);
  });
});