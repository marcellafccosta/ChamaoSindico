import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { Repository } from 'typeorm';

@Injectable()
export class ChatGeralService {
  constructor(
    @InjectRepository(Message)
    private readonly messageRepository: Repository<Message>,
  ) {}

  async findPublicMessages() {
    const messages = await this.messageRepository.find({
      where: { toUserId: 0 },
      order: { createdAt: 'ASC' },
      relations: ['sender'],
    });

    return messages.map((msg) => ({
      id: msg.id,
      content: msg.content,
      fromUserId: msg.fromUserId,
      toUserId: msg.toUserId,
      createdAt: msg.createdAt,
      senderName: msg.sender.name,
    }));
  }
}
