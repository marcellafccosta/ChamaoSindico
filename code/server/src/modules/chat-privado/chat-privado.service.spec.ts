import { Test, TestingModule } from '@nestjs/testing';
import { ChatPrivadoService } from './chat-privado.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { Repository } from 'typeorm';

describe('ChatPrivadoService', () => {
  let service: ChatPrivadoService;
  let repo: Repository<Message>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatPrivadoService,
        {
          provide: getRepositoryToken(Message),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
            find: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<ChatPrivadoService>(ChatPrivadoService);
    repo = module.get<Repository<Message>>(getRepositoryToken(Message));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('saveMessage', () => {
    it('deve salvar uma mensagem privada com sucesso (aceite)', async () => {
      const msg = { content: 'Oi', fromUserId: 1, toUserId: 2 };
      const savedMsg = { id: 1, ...msg };
      const msgWithSender = { ...savedMsg, sender: { name: 'João' } };

      (repo.create as jest.Mock).mockReturnValue(msg);
      (repo.save as jest.Mock).mockResolvedValue(savedMsg);
      (repo.findOne as jest.Mock).mockResolvedValue(msgWithSender);

      const result = await service.saveMessage('Oi', 1, 2);

      expect(result).toEqual(msgWithSender);
      expect(repo.create).toHaveBeenCalledWith({
        content: 'Oi',
        fromUserId: 1,
        toUserId: 2,
      });
      expect(repo.save).toHaveBeenCalledWith(msg);
      expect(repo.findOne).toHaveBeenCalledWith({
        where: { id: savedMsg.id },
        relations: ['sender'],
      });
    });

    it('deve lançar erro ao salvar uma mensagem privada (falha)', async () => {
      (repo.create as jest.Mock).mockReturnValue({
        content: 'Oi',
        fromUserId: 1,
        toUserId: 2,
      });
      (repo.save as jest.Mock).mockRejectedValue(
        new Error('Erro ao salvar mensagem'),
      );

      await expect(service.saveMessage('Oi', 1, 2)).rejects.toThrow(
        'Erro ao salvar mensagem',
      );
    });
  });

  describe('getConversation', () => {
    it('deve retornar uma conversa privada com sucesso (aceite)', async () => {
      const messages = [
        {
          id: 1,
          content: 'Oi',
          fromUserId: 1,
          toUserId: 2,
          createdAt: new Date(),
          sender: { name: 'João' },
        },
        {
          id: 2,
          content: 'Olá',
          fromUserId: 2,
          toUserId: 1,
          createdAt: new Date(),
          sender: { name: 'Maria' },
        },
      ];
      (repo.find as jest.Mock).mockResolvedValue(messages);

      const result = await service.getConversation(1, 2);

      expect(result).toEqual([
        {
          id: 1,
          content: 'Oi',
          fromUserId: 1,
          toUserId: 2,
          createdAt: messages[0].createdAt,
        },
        {
          id: 2,
          content: 'Olá',
          fromUserId: 2,
          toUserId: 1,
          createdAt: messages[1].createdAt,
        },
      ]);
      expect(repo.find).toHaveBeenCalled();
    });

    it('deve lançar erro ao buscar conversa privada (falha)', async () => {
      (repo.find as jest.Mock).mockRejectedValue(
        new Error('Erro ao buscar conversa'),
      );

      await expect(service.getConversation(1, 2)).rejects.toThrow(
        'Erro ao buscar conversa',
      );
    });
  });
});
