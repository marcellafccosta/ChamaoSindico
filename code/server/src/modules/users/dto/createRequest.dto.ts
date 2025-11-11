import { ApiProperty } from '@nestjs/swagger';
[];
import { Role } from '../../../shared/enums/role.enum';
import {
  IsEmail,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
  IsStrongPassword,
} from 'class-validator';

export class CreateRequestDTO {
  @ApiProperty({
    description: 'Nome',
    example: 'User',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Email',
    example: 'teste@email.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    description: 'Senha',
    example: 'Senha123',
  })
  @IsStrongPassword()
  @IsNotEmpty()
  password: string;

  @ApiProperty({
    enum: Role,
    required: true,
  })
  @IsNotEmpty()
  @IsEnum(Role)
  role: Role;

  @ApiProperty({
    description: 'ID do apartamento ao qual o usuário pertence',
    example: 1,
  })
  @IsOptional()
  @IsPositive()
  @IsInt()
  apartamentoId: number;
}
