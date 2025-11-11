import { ApiProperty } from '@nestjs/swagger';
[];
import {
  IsDate,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
export class CreateVisitanteDto {
  @ApiProperty({
    description: 'Nome',
    example: 'Joao Pedro',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Documento pessoal ou do automovel',
    example: '123456789000',
  })
  @IsString()
  @IsNotEmpty()
  document: string;

  @ApiProperty({
    description: 'Numero de telefone',
    example: '31999999999',
  })
  @IsString()
  @IsOptional()
  phone: string;

  @ApiProperty({
    description: 'Modelo do automovel',
    example: 'Onix Vermelho',
  })
  @IsString()
  @IsOptional()
  model: string;

  @ApiProperty({
    description: 'Data de entrada',
    example: '22/10/2023',
  })
  @IsDate()
  @IsOptional()
  checkIn: Date;

  @ApiProperty({
    description: 'Data de saida',
    example: '23/10/2023',
  })
  @IsDate()
  @IsOptional()
  checkOut: Date;

  @ApiProperty({
    description: 'Id do apartamento',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  apartamentoId: number;

  @ApiProperty({
    description: 'Id do usuario',
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  userId: number;

  // @ApiProperty({
  //   enum: TipoVisitante,
  //   required: true,
  // })
  // @IsNotEmpty()
  // @IsEnum(TipoVisitante)
  // typeVisitant: TipoVisitante;
}
