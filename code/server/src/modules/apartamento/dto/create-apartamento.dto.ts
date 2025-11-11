import { ApiProperty } from '@nestjs/swagger';
import {
  IsInt,
  IsNotEmpty,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateApartamentoDto {
  @ApiProperty({
    description: 'ID of the user creating the apartment',
    example: 1,
  })

  @ApiProperty({
    description: 'Numero do apartamento',
    example: '202A',
  })
  @IsString()
  @IsNotEmpty()
  name: string;
}
