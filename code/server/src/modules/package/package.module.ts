import { Module } from '@nestjs/common';
import { PackageService } from './package.service';
import { PackageController } from './package.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Package } from '../../shared/entities/package.entity';
import { PackagesRepository } from '../../shared/repositories/packages.repository';
import { AuthModule } from '../../modules/auth/auth.module';
import { UsersModule } from '../../modules/users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([Package]), AuthModule, UsersModule],
  controllers: [PackageController],
  providers: [PackageService, PackagesRepository],
})
export class PackageModule {}
