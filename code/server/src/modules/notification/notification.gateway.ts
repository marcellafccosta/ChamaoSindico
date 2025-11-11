import { Logger } from '@nestjs/common';
import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway({ cors: { origin: '*' } })
export class NotificationGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  private readonly logger = new Logger(NotificationGateway.name);
  @WebSocketServer() server: Server;

  handleConnection(client: any) {
    this.logger.log(`Cliente conectado via WebSocket: ${client.id}`);
  }

  handleDisconnect(client: any) {
    this.logger.log(`Cliente desconectado: ${client.id}`);
  }

  sendAviso(aviso: any) {
    this.server.emit('novo_aviso', aviso);
    this.logger.log(
      `--> [WebSocket] Evento "novo_aviso" emitido para os clientes.`,
    );
  }
}
