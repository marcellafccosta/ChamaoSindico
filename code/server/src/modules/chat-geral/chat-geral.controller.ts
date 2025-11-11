import { Controller, Get } from '@nestjs/common';
import { ChatGeralService } from './chat-geral.service';

@Controller('chat-geral')
export class ChatGeralController {
  constructor(private readonly chatGeralService: ChatGeralService) {}

  @Get()
  async getPublicMessages() {
    return this.chatGeralService.findPublicMessages();
  }
}
