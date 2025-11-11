import { Controller, Get, Query } from '@nestjs/common';
import { ChatPrivadoService } from './chat-privado.service';

@Controller('chat-privado')
export class ChatPrivadoController {
  constructor(private readonly chatPrivadoService: ChatPrivadoService) {}

  @Get()
  getConversation(
    @Query('user1') user1: number,
    @Query('user2') user2: number,
  ) {
    return this.chatPrivadoService.getConversation(user1, user2);
  }
}
