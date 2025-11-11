import { Test, TestingModule } from '@nestjs/testing';
import { ApartamentoController } from './apartamento.controller';
import { ApartamentoService } from './apartamento.service';
import { NotFoundException } from '@nestjs/common/exceptions';

describe('ApartamentoController', () => {
  let controller: ApartamentoController;
  let service: ApartamentoService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ApartamentoController],
      providers: [
        {
          provide: ApartamentoService,
          useValue: {
            findOne: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ApartamentoController>(ApartamentoController);
    service = module.get<ApartamentoService>(ApartamentoService);
  });

  // Teste de aceite (sucesso)
  it('deve retornar um apartamento quando o id for válido', async () => {
    const aptoMock = { id: 1, name: '101' };
    jest.spyOn(service, 'findOne').mockResolvedValue(aptoMock as any);

    expect(await controller.findOne('1')).toEqual(aptoMock);
  });

  // Teste de erro (not found)
  it('deve lançar NotFoundException se o apartamento não existir', async () => {
    jest.spyOn(service, 'findOne').mockResolvedValue(undefined);

    await expect(controller.findOne('999')).rejects.toThrow(NotFoundException);
  });
});
