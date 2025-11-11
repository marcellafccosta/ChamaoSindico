import { forwardRef, Module } from '@nestjs/common';
import { ApartamentoService } from './apartamento.service';
import { ApartamentoController } from './apartamento.controller';
import { Apartamento } from '../../shared/entities/apartamento.entity';
import { ApartamentoRepository } from '../../shared/repositories/apartamento.repository';
import { TypeOrmModule } from '@nestjs/typeorm/dist/typeorm.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Apartamento]),
    forwardRef(() => ApartamentoModule),
  ],
  controllers: [ApartamentoController],
  providers: [ApartamentoService, ApartamentoRepository],
  exports: [TypeOrmModule, ApartamentoService],
})
export class ApartamentoModule {}
