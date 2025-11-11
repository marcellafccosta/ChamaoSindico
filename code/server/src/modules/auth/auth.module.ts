import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { UsersModule } from '../../modules/users/users.module';
import { UsersRepository } from '../../shared/repositories/users.repository';

@Module({
  imports: [
    UsersModule,
    JwtModule.registerAsync({
      imports: [ConfigModule, UsersModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('NEXTAUTH_SECRET'),
        signOptions: { expiresIn: '1h' },
      }),
      inject: [ConfigService],
    }),
  ],
  providers: [AuthService, UsersRepository],
  controllers: [AuthController],
  exports: [AuthService, JwtModule],
})
export class AuthModule {}
