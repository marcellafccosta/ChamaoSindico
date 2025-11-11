import { Module } from '@nestjs/common';
import { VisitanteService } from './visitante.service';
import { VisitanteController } from './visitante.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Visitante } from '../../shared/entities/visitante.entity';
import { UsersModule } from '../../modules/users/users.module';
import { ApartamentoModule } from '../../modules/apartamento/apartamento.module';
import { VisitanteRepository } from '../../shared/repositories/visitante.repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([Visitante]),
    UsersModule,
    ApartamentoModule,
  ], // Add your entities here
  controllers: [VisitanteController],
  providers: [VisitanteService, VisitanteRepository],
  exports: [TypeOrmModule],
})
export class VisitanteModule {}
