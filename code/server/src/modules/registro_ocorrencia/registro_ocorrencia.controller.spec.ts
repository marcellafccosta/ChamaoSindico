import { Test, TestingModule } from '@nestjs/testing';
import { RegistroOcorrenciaController } from './registro_ocorrencia.controller';
import { RegistroOcorrenciaService } from './registro_ocorrencia.service';

describe('RegistroOcorrenciaController', () => {
  let controller: RegistroOcorrenciaController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RegistroOcorrenciaController],
      providers: [RegistroOcorrenciaService],
    }).compile();

    controller = module.get<RegistroOcorrenciaController>(RegistroOcorrenciaController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
