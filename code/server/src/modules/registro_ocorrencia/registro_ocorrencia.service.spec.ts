import { Test, TestingModule } from '@nestjs/testing';
import { RegistroOcorrenciaService } from './registro_ocorrencia.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RegistroOcorrencia } from '../../shared/entities/registro_ocorrencia.entity';
import { BadRequestException } from '@nestjs/common';

describe('RegistroOcorrenciaService', () => {
  let service: RegistroOcorrenciaService;
  let repo: Repository<RegistroOcorrencia>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RegistroOcorrenciaService,
        {
          provide: getRepositoryToken(RegistroOcorrencia),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<RegistroOcorrenciaService>(RegistroOcorrenciaService);
    repo = module.get<Repository<RegistroOcorrencia>>(getRepositoryToken(RegistroOcorrencia));
  });

  it('deve criar e retornar um registro de ocorrência', async () => {
    const dto = { descricao: 'Teste', titulo: 'Ocorrência', dataCriacao: new Date() } as any;
    const userId = 42;
    const registroMock = { id: 1, ...dto, userId };

    (repo.create as jest.Mock).mockReturnValue(registroMock);
    (repo.save as jest.Mock).mockResolvedValue(registroMock);

    const result = await service.create(dto, userId);

    expect(result).toEqual(registroMock);
    expect(repo.create).toHaveBeenCalledWith({ ...dto, userId });
    expect(repo.save).toHaveBeenCalledWith(registroMock);
  });

  // Teste de falha (erro ao salvar)
  it('deve lançar BadRequestException se ocorrer erro ao salvar', async () => {
    const dto = { descricao: 'Teste', titulo: 'Ocorrência', dataCriacao: new Date() } as any;
    const userId = 42;
    const registroMock = { id: 1, ...dto, userId };

    (repo.create as jest.Mock).mockReturnValue(registroMock);
    (repo.save as jest.Mock).mockRejectedValue(new Error('Falha ao salvar'));

    await expect(service.create(dto, userId)).rejects.toThrow(BadRequestException);
  });
});
