import { Injectable, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

@Injectable()
export class NotificationService implements OnModuleInit {
  onModuleInit() {
    // Adicione esta verificação
    if (admin.apps.length > 0) {
      return;
    }
    const serviceAccountPath = path.join(
      process.cwd(),
      'chama-o-sindico-52d5b-firebase-adminsdk-fbsvc-a59b268a27.json',
    );

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccountPath),
    });
  }

  // Seu método sendPushNotification permanece o mesmo
  async sendPushNotification(tokens: string[], title: string, body: string) {
    if (tokens.length === 0) {
      console.log('Nenhum token FCM para enviar notificação.');
      return;
    }
    const message: admin.messaging.MulticastMessage = {
      notification: { title, body },
      tokens: tokens,
    };
    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log('Notificações enviadas com sucesso:', response.successCount);
      if (response.failureCount > 0) {
        console.log('Falhas ao enviar notificações:', response.failureCount);
      }
    } catch (error) {
      console.error('Erro ao enviar notificação push:', error);
    }
  }
}
