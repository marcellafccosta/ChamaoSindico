import { Test, TestingModule } from '@nestjs/testing';
import { AreasService } from './areas.service';
import { AreasRepository } from '../../shared/repositories/areas.repository';
import { Area } from '../../shared/entities/area.entity';
import { CreateAreasRequestDTO } from './dtos/createRequestDTO.dto';
import { UpdateAreasRequestDTO } from './dtos/updateRequestDTO.dto';

const mockAreasRepository = () => ({
  findAll: jest.fn(),
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  delete: jest.fn(),
});

describe('AreasService', () => {
  let service: AreasService;
  let repository: ReturnType<typeof mockAreasRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AreasService,
        { provide: AreasRepository, useFactory: mockAreasRepository },
      ],
    }).compile();

    service = module.get<AreasService>(AreasService);
    repository = module.get(AreasRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('deve retornar todas as áreas (aceite)', async () => {
      const areas = [
        { id: 1, nome: 'Piscina' },
        { id: 2, nome: 'Salão de Festas' },
      ] as unknown as Area[];
      repository.findAll.mockResolvedValue(areas);

      const result = await service.findAll();

      expect(result).toEqual(areas);
      expect(repository.findAll).toHaveBeenCalled();
    });

    it('deve lançar erro ao buscar todas as áreas (falha)', async () => {
      const error = new Error('Erro ao buscar áreas');
      repository.findAll.mockRejectedValue(error);

      await expect(service.findAll()).rejects.toThrowError(error);
      expect(repository.findAll).toHaveBeenCalled();
    });
  });

  describe('create', () => {
    it('deve criar uma área com sucesso (aceite)', async () => {
      const dto: CreateAreasRequestDTO = { nome: 'Churrasqueira' } as any;
      const areaCriada = { id: 1, nome: 'Churrasqueira' } as unknown as Area;
      repository.create.mockResolvedValue(areaCriada);

      const result = await service.create(dto);

      expect(result).toEqual(areaCriada);
      expect(repository.create).toHaveBeenCalledWith(dto);
    });

    it('deve lançar erro ao criar uma área (falha)', async () => {
      const dto: CreateAreasRequestDTO = { nome: 'Churrasqueira' } as any;
      const error = new Error('Erro ao criar área');
      repository.create.mockRejectedValue(error);

      await expect(service.create(dto)).rejects.toThrowError(error);
      expect(repository.create).toHaveBeenCalledWith(dto);
    });
  });
});
