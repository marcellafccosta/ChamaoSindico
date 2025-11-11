import { Test, TestingModule } from '@nestjs/testing';
import { AvisoService } from './aviso.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Aviso } from '../../shared/entities/aviso.entity';
import { Repository } from 'typeorm';
import { ClientKafka } from '@nestjs/microservices';

describe('AvisoService', () => {
  let service: AvisoService;
  let repo: Repository<Aviso>;
  let kafkaClient: ClientKafka;

  beforeEach(async () => {
    const mockKafkaClient = {
      connect: jest.fn().mockResolvedValue(undefined),
      emit: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AvisoService,
        {
          provide: getRepositoryToken(Aviso),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
          },
        },
        {
          provide: 'KAFKA_SERVICE',
          useValue: mockKafkaClient,
        },
      ],
    }).compile();

    service = module.get<AvisoService>(AvisoService);
    repo = module.get<Repository<Aviso>>(getRepositoryToken(Aviso));
    kafkaClient = module.get<ClientKafka>('KAFKA_SERVICE');
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('Aceitar: deve criar um aviso e emitir evento Kafka', async () => {
    const dto = { titulo: 'Teste', descricao: 'Descrição' };
    const avisoCriado = { id: 1, ...dto };
    (repo.create as jest.Mock).mockReturnValue(dto);
    (repo.save as jest.Mock).mockResolvedValue(avisoCriado);

    const result = await service.create(dto as any);

    expect(repo.create).toHaveBeenCalledWith(dto);
    expect(repo.save).toHaveBeenCalledWith(dto);
    expect(kafkaClient.emit).toHaveBeenCalledWith(
      'avisos-criados',
      avisoCriado,
    );
    expect(result).toEqual(avisoCriado);
  });

  it('Falha: deve lançar erro ao atualizar aviso inexistente', async () => {
    (repo.findOne as jest.Mock).mockResolvedValue(undefined);
    await expect(
      service.update(999, { titulo: 'Novo' } as any),
    ).rejects.toThrow('Aviso com ID 999 não encontrado');
  });

  describe('findAll', () => {
    it('deve retornar todos os avisos (aceite)', async () => {
      const avisos = [
        { id: 1, titulo: 'Aviso 1', descricao: 'Desc 1' },
        { id: 2, titulo: 'Aviso 2', descricao: 'Desc 2' },
      ] as unknown as Aviso[];
      (repo.find as jest.Mock).mockResolvedValue(avisos);

      const result = await service.findAll();

      expect(result).toEqual(avisos);
      expect(repo.find).toHaveBeenCalled();
    });

    it('deve lançar erro ao buscar todos os avisos (falha)', async () => {
      const error = new Error('Erro ao buscar avisos');
      (repo.find as jest.Mock).mockRejectedValue(error);

      await expect(service.findAll()).rejects.toThrowError(error);
      expect(repo.find).toHaveBeenCalled();
    });
  });
});
