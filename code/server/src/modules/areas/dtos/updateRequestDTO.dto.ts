import { PartialType } from '@nestjs/swagger';
import { CreateAreasRequestDTO } from './createRequestDTO.dto';

export class UpdateAreasRequestDTO extends PartialType(CreateAreasRequestDTO) {}
