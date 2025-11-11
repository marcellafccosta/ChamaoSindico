import { Module } from '@nestjs/common';
import { NotificationConsumerController } from './notification.consumer';
import { NotificationService } from './notification.service';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [UsersModule],
  controllers: [NotificationConsumerController],
  providers: [NotificationService],
  exports: [NotificationService],
})
export class NotificationModule {}
