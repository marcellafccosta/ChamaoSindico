import { PartialType } from '@nestjs/mapped-types';
import { CreateChatPrivadoDto } from './create-chat-privado.dto';

export class UpdateChatPrivadoDto extends PartialType(CreateChatPrivadoDto) {}
