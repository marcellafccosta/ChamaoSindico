import env from '../../config/env';
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { errors } from '../../shared/constants';
import { UsersRepository } from '../../shared/repositories/users.repository';
import { Request } from 'express';

@Injectable()
export class isAuthenticated implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private readonly usersRepository: UsersRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request: Request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException(errors.invalidType);
    }

    try {
      // Valida o token e obtém o payload
      const payload = await this.jwtService.verifyAsync(token, {
        secret: env().application.jwt.secret,
      });

      // Busca o usuário no banco de dados usando o campo "sub" (ID do usuário)
      const user = await this.usersRepository.findOne(Number(payload.sub));

      if (!user) {
        throw new UnauthorizedException(errors.invalidToken);
      }

      // Anexa o usuário à requisição
      request['user'] = { ...payload, ...user };
    } catch {
      throw new UnauthorizedException(errors.invalidToken);
    }

    return true;
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
