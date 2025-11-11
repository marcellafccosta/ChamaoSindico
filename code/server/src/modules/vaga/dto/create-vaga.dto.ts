import { ApiProperty } from '@nestjs/swagger';
import {
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateVagaDto {
  @ApiProperty({
    description: 'Name of the vaga',
    example: 'Vaga do Wanderson',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'A vaga está ocupada?',
    example: true,
    required: true,
  })
  @IsBoolean()
  @IsNotEmpty()
  isOcupada: boolean;

  // @ApiProperty({
  //   description: 'ID do usuário que está reservando a vaga',
  //   example: 1,
  // })
  // @IsNumber()
  // @IsPositive()
  // usuarioId: number;

  @ApiProperty({
    description: 'ID da apartamento que está reservando a vaga',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  @IsPositive()
  apartamentoId?: number;
}
