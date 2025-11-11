import { Test, TestingModule } from '@nestjs/testing';
import { ChatPrivadoController } from './chat-privado.controller';
import { ChatPrivadoService } from './chat-privado.service';

describe('ChatPrivadoController', () => {
  let controller: ChatPrivadoController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ChatPrivadoController],
      providers: [ChatPrivadoService],
    }).compile();

    controller = module.get<ChatPrivadoController>(ChatPrivadoController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
