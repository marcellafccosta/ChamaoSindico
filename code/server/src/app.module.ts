import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AvisoModule } from './modules/aviso/aviso.module';
import { ManutencaoModule } from './modules/manutencao/manutencao.module';
import { RegistroOcorrenciaModule } from './modules/registro_ocorrencia/registro_ocorrencia.module';
import { AreasModule } from './modules/areas/areas.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { ApartamentoModule } from './modules/apartamento/apartamento.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { PackageModule } from './modules/package/package.module';
import { VagaModule } from './modules/vaga/vaga.module';
import { VisitanteModule } from './modules/visitante/visitante.module';
import { ChatPrivadoModule } from './modules/chat-privado/chat-privado.module';
import { ChatGeralModule } from './modules/chat-geral/chat-geral.module';
import { ProfissionalModule } from './modules/profissional/profissional.module';
import { dataSource } from './config/typeorm/dataSource';
import { NotificationModule } from './modules/notification/notification.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      // load: [configuration],
      isGlobal: true,
    }),
    TypeOrmModule.forRoot(dataSource.options),
    AvisoModule,
    ManutencaoModule,
    RegistroOcorrenciaModule,
    AreasModule,
    BookingsModule,
    UsersModule,
    ApartamentoModule,
    AuthModule,
    PackageModule,
    VagaModule,
    VisitanteModule,
    ChatPrivadoModule,
    ChatGeralModule,
    ProfissionalModule,
    NotificationModule,
  ],
})
export class AppModule {}
