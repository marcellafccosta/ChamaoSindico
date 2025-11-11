import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AvisoController } from './aviso.controller';
import { AvisoService } from './aviso.service';
import { Aviso } from '../../shared/entities/aviso.entity';
import { KafkaClientModule } from '../kafka/kafka-client.module';

@Module({
  imports: [TypeOrmModule.forFeature([Aviso]), KafkaClientModule],
  controllers: [AvisoController],
  providers: [AvisoService],
})
export class AvisoModule {}
