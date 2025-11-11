import { Controller, Logger } from '@nestjs/common';
import { MessagePattern, Payload } from '@nestjs/microservices';
import { NotificationService } from './notification.service';
import { UsersService } from '../users/users.service';
import { Aviso } from '../../shared/entities/aviso.entity';

@Controller()
export class NotificationConsumerController {
  private readonly logger = new Logger(NotificationConsumerController.name);

  constructor(
    private readonly notificationService: NotificationService,
    private readonly usersService: UsersService,
  ) {
    this.logger.log(
      '!!! NOTIFICATION CONSUMER CONTROLLER PRONTO PARA O FIREBASE !!!',
    );
  }

  @MessagePattern('avisos-criados')
  async handleAvisoCriado(@Payload() novoAviso: Aviso) {
    this.logger.log(`--> [Kafka Consumer] Mensagem recebida para o Firebase`);
    this.logger.debug('Payload:', JSON.stringify(novoAviso, null, 2));

    try {
      this.logger.log('Buscando todos os usuários para notificar...');
      const usuarios = await this.usersService.findAll();

      const tokens = usuarios
        .map((u) => u.fcmToken)
        .filter((token): token is string => !!token);

      if (tokens.length === 0) {
        this.logger.warn(
          'Nenhum token FCM válido encontrado para enviar a notificação.',
        );
        return;
      }

      this.logger.log(
        `Enviando notificação push para ${tokens.length} tokens...`,
      );

      await this.notificationService.sendPushNotification(
        tokens,
        'Novo Aviso no Condomínio!',
        novoAviso.assunto,
      );

      this.logger.log('Notificação push enviada com sucesso via Firebase!');
    } catch (error) {
      this.logger.error(
        'Falha no processo de envio da notificação push.',
        error,
      );
    }
  }
}
