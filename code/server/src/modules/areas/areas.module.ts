import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AreasRepository } from '../../shared/repositories/areas.repository';
import { AreasController } from './areas.controller';
import { AreasService } from './areas.service';
import { Area } from '../../shared/entities/area.entity';
import { JwtModule } from '@nestjs/jwt';
import { AuthModule } from '../../modules/auth/auth.module';
import { UsersModule } from '../../modules/users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Area]),
    JwtModule,
    AuthModule,
    UsersModule,
  ],
  controllers: [AreasController],
  providers: [AreasService, AreasRepository],
})
export class AreasModule {}
