import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import env from './config/env';
import { Logger, ValidationPipe } from '@nestjs/common';

async function bootstrap() {
// ✅ REMOVER { cors: true } daqui
const app = await NestFactory.create(AppModule);

// ✅ CONFIGURAÇÃO CORS MAIS COMPLETA
app.enableCors({
  origin: [
    'http://localhost:3000',
    'https://clientweb-phi.vercel.app',
    /https:\/\/.*\.vercel\.app$/,
  ],
  methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With'],
  credentials: true,
  preflightContinue: false,
  optionsSuccessStatus: 204,
});

app.setGlobalPrefix('api');

const port = process.env.PORT || env().application.port;
const logger = new Logger('NestApplication');

const config = new DocumentBuilder()
  .setTitle('Chama o Síndico Backend')
  .setVersion('1.0')
  .addBearerAuth()
  .build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);

app.useGlobalPipes(new ValidationPipe());

await app.listen(port, '0.0.0.0', () =>
  logger.log(`API is running on port ${port}`)
);
}

bootstrap();