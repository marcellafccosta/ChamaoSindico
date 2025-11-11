import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { Repository } from 'typeorm';

@Injectable()
export class ChatPrivadoService {
  constructor(
    @InjectRepository(Message)
    private readonly messageRepository: Repository<Message>,
  ) {}

  async saveMessage(content: string, fromUserId: number, toUserId?: number) {
    const message = this.messageRepository.create({
      content,
      fromUserId,
      toUserId,
    });
    const saved = await this.messageRepository.save(message);

    return this.messageRepository.findOne({
      where: { id: saved.id },
      relations: ['sender'],
    });
  }

  async getConversation(user1: number, user2: number) {
    const messages = await this.messageRepository.find({
      where: [
        { fromUserId: user1, toUserId: user2 },
        { fromUserId: user2, toUserId: user1 },
      ],
      order: { createdAt: 'ASC' },
      relations: ['sender'],
    });

    return messages.map((msg) => ({
      id: msg.id,
      content: msg.content,
      fromUserId: msg.fromUserId,
      toUserId: msg.toUserId,
      createdAt: msg.createdAt,
    }));
  }
}
