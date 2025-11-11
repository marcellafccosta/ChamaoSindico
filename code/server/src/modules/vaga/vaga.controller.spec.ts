import { Test, TestingModule } from '@nestjs/testing';
import { VagaController } from './vaga.controller';
import { VagaService } from './vaga.service';
import { NotFoundException } from '@nestjs/common';

describe('VagaController', () => {
  let controller: VagaController;
  let service: VagaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VagaController],
      providers: [
        {
          provide: VagaService,
          useValue: {
            findOne: jest.fn(),
            update: jest.fn(),
            findByApartamento: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<VagaController>(VagaController);
    service = module.get<VagaService>(VagaService);
  });

  // findOne - aceite
  it('deve retornar uma vaga quando o id for válido', async () => {
    const vagaMock = { id: 1, name: 'Vaga 1' };
    jest.spyOn(service, 'findOne').mockResolvedValue(vagaMock as any);

    expect(await controller.findOne('1')).toEqual(vagaMock);
  });

  // findOne - erro
  it('deve lançar NotFoundException se a vaga não existir', async () => {
    jest.spyOn(service, 'findOne').mockResolvedValue(undefined);

    await expect(controller.findOne('999')).rejects.toThrow(NotFoundException);
  });

  // update - aceite
  it('deve atualizar uma vaga quando o id for válido', async () => {
    const vagaAtualizada = { id: 1, name: 'Vaga Atualizada' };
    jest.spyOn(service, 'findOne').mockResolvedValue(vagaAtualizada as any);
    jest.spyOn(service, 'update').mockResolvedValue(vagaAtualizada as any);

    expect(await controller.update('1', { name: 'Vaga Atualizada' })).toEqual(vagaAtualizada);
  });

  // update - erro
  it('deve lançar NotFoundException ao tentar atualizar uma vaga inexistente', async () => {
    jest.spyOn(service, 'findOne').mockResolvedValue(undefined);

    await expect(controller.update('999', { name: 'Teste' })).rejects.toThrow(NotFoundException);
  });

  // findByApartamento - aceite
  it('deve retornar vagas de um apartamento válido', async () => {
    const vagas = [{ id: 1, name: 'Vaga 1' }];
    jest.spyOn(service, 'findByApartamento').mockResolvedValue(vagas as any);

    expect(await controller.findByApartamento('1')).toEqual(vagas);
  });

  // findByApartamento - erro
  it('deve lançar NotFoundException se não houver vagas para o apartamento', async () => {
    jest.spyOn(service, 'findByApartamento').mockResolvedValue(undefined);

    await expect(controller.findByApartamento('999')).rejects.toThrow(NotFoundException);
  });
});
