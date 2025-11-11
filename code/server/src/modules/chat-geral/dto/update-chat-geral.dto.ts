import { PartialType } from '@nestjs/swagger';
import { CreateChatGeralDto } from './create-chat-geral.dto';

export class UpdateChatGeralDto extends PartialType(CreateChatGeralDto) {}
