import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { Repository } from 'typeorm';

@Injectable()
export class MessagesService {
  constructor(
    @InjectRepository(Message)
    private readonly repo: Repository<Message>,
  ) {}

  async create(content: string, fromUserId: number, toUserId?: number) {
    const msg = this.repo.create({ content, fromUserId, toUserId });
    return this.repo.save(msg);
  }

  async findPublicMessages() {
    const messages = await this.repo.find({
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

  async findConversation(user1: number, user2: number) {
    const messages = await this.repo.find({
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
      senderName: msg.sender.name,
    }));
  }

  async getMessages(user1: number, user2: number) {
    if (user2 === 0) {
      return this.findPublicMessages();
    } else {
      return this.findConversation(user1, user2);
    }
  }
}
