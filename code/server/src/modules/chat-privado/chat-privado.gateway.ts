import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatPrivadoService } from './chat-privado.service';

@WebSocketGateway({ cors: { origin: '*' } })
export class ChatPrivadoGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private userSockets = new Map<string, string>();

  constructor(private readonly service: ChatPrivadoService) {}

  handleConnection(client: Socket) {
    console.log(`Conectado: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    for (const [userId, socketId] of this.userSockets.entries()) {
      if (socketId === client.id) {
        this.userSockets.delete(userId);
        break;
      }
    }
  }

  @SubscribeMessage('register-user')
  handleRegister(
    @MessageBody() userId: string,
    @ConnectedSocket() client: Socket,
  ) {
    this.userSockets.set(userId, client.id);
  }

  @SubscribeMessage('private-message')
  async handlePrivateMessage(
    @MessageBody()
    data: { fromUserId: number; toUserId: number; content: string },
    @ConnectedSocket() client: Socket,
  ) {
    const saved = await this.service.saveMessage(
      data.content,
      data.fromUserId,
      data.toUserId,
    );

    const payload = {
      id: saved.id,
      content: saved.content,
      fromUserId: saved.fromUserId,
      toUserId: saved.toUserId,
      createdAt: saved.createdAt,
      senderName: saved.sender?.name ?? 'Desconhecido',
    };

    if (data.toUserId === 0) {
      for (const socketId of this.userSockets.values()) {
        this.server.to(socketId).emit('general-message', payload);
      }
    } else {
      const toSocketId = this.userSockets.get(data.toUserId.toString());

      if (toSocketId) {
        this.server.to(toSocketId).emit('private-message', payload);
      }
      client.emit('private-message', payload); 
    }
  }
}
