import { Module } from '@nestjs/common';
import { ChatPrivadoService } from './chat-privado.service';
import { ChatPrivadoController } from './chat-privado.controller';
import { ChatPrivadoGateway } from './chat-privado.gateway';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Message])],
  providers: [ChatPrivadoService, ChatPrivadoGateway],
  controllers: [ChatPrivadoController],
})
export class ChatPrivadoModule {}
