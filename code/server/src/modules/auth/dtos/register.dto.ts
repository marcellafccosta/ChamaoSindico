import { ApiProperty } from '@nestjs/swagger';
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

export class RegisterDTO {
  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: 'Password123!' })
  @IsStrongPassword(
    {
      minLength: 8,
      minLowercase: 1,
      minUppercase: 1,
      minNumbers: 1,
      minSymbols: 1,
    },
    { message: 'A senha deve ter pelo menos 8 caracteres, incluindo maiúscula, minúscula, número e símbolo.' }
  )
  @IsNotEmpty()
  password: string;

  @ApiProperty({ enum: Role, example: Role.RESIDENT })
  @IsEnum(Role)
  @IsNotEmpty()
  role: Role;
}
