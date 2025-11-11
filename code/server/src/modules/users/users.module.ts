import { forwardRef, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersRepository } from '../../shared/repositories/users.repository';
import { User } from '../../shared/entities/user.entity';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { ApartamentoModule } from '../../modules/apartamento/apartamento.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    forwardRef(() => ApartamentoModule),
  ],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersRepository, UsersService, TypeOrmModule],
})
export class UsersModule {}
