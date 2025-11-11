import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';
import { Transport } from '@nestjs/microservices';
import { ConfigService } from '@nestjs/config';
import { readFileSync } from 'fs';
import * as path from 'path';

async function bootstrap() {
  const logger = new Logger('KafkaConsumerWorker');
  logger.log('Iniciando o worker do Kafka Consumer...');

  // Cria um contexto da aplicação para acessar o ConfigService
  const app = await NestFactory.createApplicationContext(AppModule);
  const configService = app.get(ConfigService);

  const serviceURI = configService.get<string>('KAFKA_SERVICE_URI');
  if (!serviceURI) {
    logger.error('KAFKA_SERVICE_URI não encontrada. Worker não pode iniciar.');
    process.exit(1); // Encerra o processo se a URI não for encontrada
  }

  const isProduction = process.env.NODE_ENV === 'production';
  const basePath = isProduction
    ? '/etc/secrets'
    : path.join(process.cwd(), 'kafka-certs');

  // --- A CORREÇÃO ESTÁ AQUI ---
  // Passamos o AppModule como primeiro argumento e as opções como segundo.
  const consumerApp = await NestFactory.createMicroservice(
    AppModule, // <--- Argumento 1: O Módulo
    {
      // <--- Argumento 2: O Objeto de Opções
      transport: Transport.KAFKA,
      options: {
        client: {
          brokers: [serviceURI],
          ssl: {
            rejectUnauthorized: false,
            ca: readFileSync(path.join(basePath, 'ca.pem'), 'utf-8'),
            key: readFileSync(path.join(basePath, 'service.key'), 'utf-8'),
            cert: readFileSync(path.join(basePath, 'service.cert'), 'utf-8'),
          },
        },
        consumer: {
          groupId: 'notification-group',
        },
      },
    },
  );

  await consumerApp.listen();
  logger.log(
    'Worker do Kafka Consumer está rodando e ouvindo mensagens do Aiven.',
  );
}

bootstrap();
