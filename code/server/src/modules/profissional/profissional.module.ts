import { Module } from '@nestjs/common';
import { ProfissionalService } from './profissional.service';
import { ProfissionalController } from './profissional.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Profissional } from '../../shared/entities/profissional.entity';
import { AuthModule } from '../../modules/auth/auth.module'; // Ajuste o caminho
import { UsersModule } from '../../modules/users/users.module'; // Ajuste o caminho

@Module({
  imports: [TypeOrmModule.forFeature([Profissional]), AuthModule, UsersModule],
  controllers: [ProfissionalController],
  providers: [ProfissionalService],
  exports: [ProfissionalService],
})
export class ProfissionalModule {}
