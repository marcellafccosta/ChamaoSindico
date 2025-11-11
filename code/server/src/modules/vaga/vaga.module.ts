import { Module } from '@nestjs/common';
import { VagaService } from './vaga.service';
import { VagaController } from './vaga.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Vaga } from '../../shared/entities/vaga.entity';
import { ApartamentoModule } from '../../modules/apartamento/apartamento.module';
import { VagaRepository } from '../../shared/repositories/vaga.repository';

@Module({
  imports: [TypeOrmModule.forFeature([Vaga]), ApartamentoModule],
  controllers: [VagaController],
  providers: [VagaService, VagaRepository],
  exports: [VagaRepository],
})
export class VagaModule {}
