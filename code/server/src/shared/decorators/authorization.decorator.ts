import { applyDecorators, SetMetadata, UseGuards } from '@nestjs/common';
import { isAuthenticated } from '../../shared/guards/isAuthenticated.guard.guard';
// import { decoratorsMetadata } from '../../shared/constants';
import { RolesGuard } from '../../shared/guards/roles.guard';

interface IAuthorizationDecorator {
  roles?: number[];
}
export const Authorization = ({ roles }: IAuthorizationDecorator) => {
  return applyDecorators(
    SetMetadata('ROLES', roles),
    UseGuards(isAuthenticated, RolesGuard),
  );
};
