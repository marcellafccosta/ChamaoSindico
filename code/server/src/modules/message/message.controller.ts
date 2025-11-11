import { Controller, Get, Query } from '@nestjs/common';
import { MessagesService } from './message.service';

@Controller('messages')
export class MessagesController {
  constructor(private readonly service: MessagesService) {}


  @Get('private')
  async getPrivateMessages(
    @Query('user1') user1: number,
    @Query('user2') user2: number,
  ) {
    return this.service.getMessages(user1, user2);
  }
}
