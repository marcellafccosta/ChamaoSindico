import { IsString, IsBoolean, IsOptional, IsDateString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAvisoDto {
@ApiProperty({ example: 'Manutenção da piscina no sábado de manhã para aplicação de produtos' })
@IsString()
aviso: string;

@ApiProperty({ example: false })
@IsBoolean()
isReuniao: boolean;

@ApiProperty({ example: '2025-05-05', required: false })
@IsOptional()
@IsDateString()
dataReuniao?: Date;

@ApiProperty({ example: true })
@IsBoolean()
isImportant: boolean;

@ApiProperty({ example: 'Manutenção piscina' })
@IsString()
@MaxLength(50)
assunto: string;

@ApiProperty({ example: '1' })
@IsString()
autor: string;
}