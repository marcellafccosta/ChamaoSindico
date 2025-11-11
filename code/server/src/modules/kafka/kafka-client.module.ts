import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { readFileSync } from 'fs';
import * as path from 'path';

@Module({
  imports: [
    ClientsModule.registerAsync([
      {
        name: 'KAFKA_SERVICE',
        imports: [ConfigModule],
        useFactory: (configService: ConfigService) => {
          const serviceURI = configService.get<string>('KAFKA_SERVICE_URI');

          if (serviceURI) {
            // --- Configuração de Produção (Aiven no Render) ---
            const isProduction = process.env.NODE_ENV === 'production';
            const basePath = isProduction
              ? '/etc/secrets'
              : path.join(process.cwd(), 'kafka-certs');

            return {
              transport: Transport.KAFKA,
              options: {
                client: {
                  brokers: [serviceURI],
                  ssl: {
                    rejectUnauthorized: false,
                    ca: readFileSync(path.join(basePath, 'ca.pem'), 'utf-8'),
                    key: readFileSync(
                      path.join(basePath, 'service.key'),
                      'utf-8',
                    ),
                    cert: readFileSync(
                      path.join(basePath, 'service.cert'),
                      'utf-8',
                    ),
                  },
                },
                // Adicione seu serializer se estiver usando
              },
            };
          }

          // --- Configuração Local (Docker) ---
          return {
            transport: Transport.KAFKA,
            options: { client: { brokers: ['localhost:9092'] } },
          };
        },
        inject: [ConfigService],
      },
    ]),
  ],
  exports: [ClientsModule],
})
export class KafkaClientModule {}
