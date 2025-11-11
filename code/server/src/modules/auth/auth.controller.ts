import { Body, ConflictException, Controller, Post, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDTO } from './dtos/login.dto';
import { RegisterDTO } from './dtos/register.dto';
import { AuthResponseDTO } from './dtos/authResponde.dto';
import { ApiOkResponse } from '@nestjs/swagger';
import { UsersService } from '../../modules/users/users.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService,
    private readonly userService: UsersService,
  ) {}

  @Post('login')
  @ApiOkResponse({
    description: 'Usuário logado com sucesso e token JWT retornado.',
    type: AuthResponseDTO,
  })
  async login(@Body() loginDto: LoginDTO): Promise<AuthResponseDTO> {

    if (!loginDto.email || !loginDto.password) {
      throw new Error('Email and password are required');
    }

    const user = await this.authService.login(loginDto);

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }
  
    return user;

  }

  @Post('register')
  @ApiOkResponse({
    description: 'Usuário registrado com sucesso e token JWT retornado.',
    type: AuthResponseDTO,
  })
  async register(@Body() dto: RegisterDTO): Promise<AuthResponseDTO> {
    try {
      if (!dto.email || !dto.password) {
        throw new UnauthorizedException('Email and password are required');
      }

      const existingUser = await this.userService.findByEmail(dto.email);
      if (existingUser) {
        throw new ConflictException('Email already registered');
      }

      return this.authService.register(dto);
    } catch (error) {
      if (error instanceof UnauthorizedException || error instanceof ConflictException) {
        throw error;
      }
      throw new Error(`Registration failed: ${error.message}`);
    }
  }
}
