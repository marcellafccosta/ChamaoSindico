import { PartialType } from '@nestjs/swagger';
import { CreateRequestDTO } from './createRequest.dto';

export class UpdateRequestDTO extends PartialType(CreateRequestDTO) {}
