import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RegistroOcorrenciaService } from './registro_ocorrencia.service';
import { RegistroOcorrenciaController } from './registro_ocorrencia.controller';
import { RegistroOcorrencia } from '../../shared/entities/registro_ocorrencia.entity'; 
import { AuthModule } from '../../modules/auth/auth.module';
import { UsersModule } from '../../modules/users/users.module';
@Module({
  imports: [TypeOrmModule.forFeature([RegistroOcorrencia]), AuthModule, UsersModule], 
  controllers: [RegistroOcorrenciaController],
  providers: [RegistroOcorrenciaService],
})
export class RegistroOcorrenciaModule {}
