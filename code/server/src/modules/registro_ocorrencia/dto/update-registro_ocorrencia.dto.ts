import { PartialType } from '@nestjs/swagger';
import { CreateRegistroOcorrenciaDto } from './create-registro_ocorrencia.dto';

export class UpdateRegistroOcorrenciaDto extends PartialType(CreateRegistroOcorrenciaDto) {}
