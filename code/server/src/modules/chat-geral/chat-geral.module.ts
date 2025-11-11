import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Message } from '../../shared/entities/message.entity';
import { ChatGeralService } from './chat-geral.service';
import { ChatGeralController } from './chat-geral.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Message])],
  providers: [ChatGeralService],
  controllers: [ChatGeralController],
})
export class ChatGeralModule {}
