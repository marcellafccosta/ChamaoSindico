import { Test, TestingModule } from '@nestjs/testing';
import { ChatGeralController } from './chat-geral.controller';
import { ChatGeralService } from './chat-geral.service';

describe('ChatGeralController', () => {
  let controller: ChatGeralController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ChatGeralController],
      providers: [ChatGeralService],
    }).compile();

    controller = module.get<ChatGeralController>(ChatGeralController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
