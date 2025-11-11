import { Test, TestingModule } from '@nestjs/testing';
import { ChatGeralService } from './chat-geral.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { Repository } from 'typeorm';

describe('ChatGeralService', () => {
  let service: ChatGeralService;
  let repo: Repository<Message>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatGeralService,
        {
          provide: getRepositoryToken(Message),
          useValue: {
            find: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<ChatGeralService>(ChatGeralService);
    repo = module.get<Repository<Message>>(getRepositoryToken(Message));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findPublicMessages', () => {
    it('deve retornar mensagens públicas com sucesso (aceite)', async () => {
      const messages = [
        {
          id: 1,
          content: 'Bem-vindo ao chat geral!',
          fromUserId: 1,
          toUserId: 0,
          createdAt: new Date(),
          sender: { name: 'João' },
        },
      ];
      (repo.find as jest.Mock).mockResolvedValue(messages);

      const result = await service.findPublicMessages();

      expect(result).toEqual([
        {
          id: 1,
          content: 'Bem-vindo ao chat geral!',
          fromUserId: 1,
          toUserId: 0,
          createdAt: messages[0].createdAt,
          senderName: 'João',
        },
      ]);
      expect(repo.find).toHaveBeenCalled();
    });

    it('deve lançar erro ao buscar mensagens públicas (falha)', async () => {
      (repo.find as jest.Mock).mockRejectedValue(
        new Error('Erro ao buscar mensagens'),
      );

      await expect(service.findPublicMessages()).rejects.toThrow(
        'Erro ao buscar mensagens',
      );
      expect(repo.find).toHaveBeenCalled();
    });
  });
});
