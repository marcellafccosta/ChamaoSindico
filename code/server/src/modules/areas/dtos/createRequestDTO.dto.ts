import { ApiProperty } from '@nestjs/swagger';
import {
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateAreasRequestDTO {
  @ApiProperty({
    description: 'Name of the area',
    example: 'Conference Room A',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Descrição da área comum',
    example:
      'Amplo salão com capacidade para 50 pessoas, cozinha equipada e banheiros.',
    required: false,
  })
  @IsString()
  @IsNotEmpty()
  description?: string;

  @ApiProperty({
    description: 'Price of the area',
    example: 100.0,
  })
  @IsNumber()
  @IsPositive()
  @IsNotEmpty()
  price: number;

  @ApiProperty({
    description: 'People limit of the area',
    example: 10,
  })
  @IsInt()
  @IsPositive()
  @IsNotEmpty()
  peopleLimit: number;
}
