import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersRepository } from '../../shared/repositories/users.repository';
import * as bcrypt from 'bcrypt';
import { LoginDTO } from './dtos/login.dto';
import { RegisterDTO } from './dtos/register.dto';
import { User } from '../../shared/entities/user.entity';
import { notFound } from '../../shared/constants/errors.contant';
import { AuthResponseDTO } from './dtos/authResponde.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly jwtService: JwtService,
  ) {}

  async login(loginDto: LoginDTO): Promise<AuthResponseDTO> {
    const { email, password } = loginDto;

    const user = await this.usersRepository.findByEmail(email);
    if (!user) {
      throw new NotFoundException(notFound('user'));
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const apartamento = user.apartamento;
    const payload = {
      sub: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      ...(apartamento && { apartamentoId: apartamento.id }),
    };
    const accessToken = this.jwtService.sign(payload);

    return { accessToken };
  }

  async register(registerDto: RegisterDTO): Promise<AuthResponseDTO> {
    const { name, email, password, role } = registerDto;

    const existingUser = await this.usersRepository.findByEmail(email);
    if (existingUser) {
      throw new UnauthorizedException('User already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await this.usersRepository.create({
      name,
      email,
      password: hashedPassword,
      role,
    });

    const accessToken = this.generateToken(newUser);
    return { accessToken };
  }

  // Este método agora é mais um helper interno, mas pode ser mantido público se necessário
  generateToken(user: User): string {
    const payload = {
      sub: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      apartamentoId: user.apartamento?.id,
    };
    return this.jwtService.sign(payload);
  }
}
