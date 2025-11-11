import { Test, TestingModule } from '@nestjs/testing';
import { MessagesService } from './message.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { Repository } from 'typeorm';

describe('MessagesService', () => {
  let service: MessagesService;
  let repo: Repository<Message>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MessagesService,
        {
          provide: getRepositoryToken(Message),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<MessagesService>(MessagesService);
    repo = module.get<Repository<Message>>(getRepositoryToken(Message));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('deve criar uma mensagem com sucesso (aceite)', async () => {
      const msg = { content: 'Oi', fromUserId: 1, toUserId: 2 };
      const savedMsg = { id: 1, ...msg };
      (repo.create as jest.Mock).mockReturnValue(msg);
      (repo.save as jest.Mock).mockResolvedValue(savedMsg);

      const result = await service.create('Oi', 1, 2);

      expect(result).toEqual(savedMsg);
      expect(repo.create).toHaveBeenCalledWith({
        content: 'Oi',
        fromUserId: 1,
        toUserId: 2,
      });
      expect(repo.save).toHaveBeenCalledWith(msg);
    });

    it('deve lançar erro ao criar uma mensagem (falha)', async () => {
      (repo.create as jest.Mock).mockReturnValue({
        content: 'Oi',
        fromUserId: 1,
        toUserId: 2,
      });
      (repo.save as jest.Mock).mockRejectedValue(
        new Error('Erro ao salvar mensagem'),
      );

      await expect(service.create('Oi', 1, 2)).rejects.toThrow(
        'Erro ao salvar mensagem',
      );
    });
  });

  describe('getMessages', () => {
    it('deve chamar findPublicMessages quando toUserId for 0', async () => {
      const spy = jest
        .spyOn(service, 'findPublicMessages')
        .mockResolvedValue([]);
      await service.getMessages(1, 0);
      expect(spy).toHaveBeenCalled();
    });

    it('deve chamar findConversation quando toUserId for diferente de 0', async () => {
      const spy = jest.spyOn(service, 'findConversation').mockResolvedValue([]);
      await service.getMessages(1, 2);
      expect(spy).toHaveBeenCalledWith(1, 2);
    });
  });
});
