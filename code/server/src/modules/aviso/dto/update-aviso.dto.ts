import { PartialType } from '@nestjs/swagger';
import { CreateAvisoDto } from './create-aviso.dto';
import { IsString, IsBoolean, IsOptional, IsDateString, MaxLength } from 'class-validator';

export class UpdateAvisoDto extends PartialType(CreateAvisoDto) {
  @IsOptional()
  @IsString()
  aviso?: string;

  @IsOptional()
  @IsBoolean()
  isReuniao?: boolean;

  @IsOptional()
  @IsDateString()
  dataReuniao?: Date;

  @IsOptional()
  @IsBoolean()
  isImportant?: boolean;

  @IsString()
  @MaxLength(50)
  assunto: string;
}
