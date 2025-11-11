import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
// import { decoratorsMetadata } from '../../shared/constants';
import { Role } from '../../shared/enums/role.enum';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const { user } = request;

    const requiredRoles: number[] = this.reflector.get(
      'ROLES',
      context.getHandler(),
    );

    if (!requiredRoles || requiredRoles.length === 0) return true;

    if (!user) {
      return false;
    }

    const isAdmin = user.role === Role.SYNDIC;
    if (isAdmin) {
      return true;
    }

    return requiredRoles.some((role) => role === user.role);
  }
}
