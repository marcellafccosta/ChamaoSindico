import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ManutencaoController } from './manutencao.controller';
import { ManutencaoService } from './manutencao.service';
import { Manutencao } from '../../shared/entities/manutencao.entity';
import { ManutencaoRepository } from '../../shared/repositories/manutencao.repository';
import { AuthModule } from '../../modules/auth/auth.module';
import { UsersModule } from '../../modules/users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([Manutencao]), AuthModule, UsersModule],
  controllers: [ManutencaoController],
  providers: [ManutencaoService, ManutencaoRepository],
  // exports: [ManutencaoService],
})
export class ManutencaoModule {}
