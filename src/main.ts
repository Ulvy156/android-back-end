import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import cookieParser from 'cookie-parser';
import { corsConfig } from './config/cors.config';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    logger: ['error', 'warn', 'log'],
  });
  // parse cookies
  app.use(cookieParser());

  app.enableCors({
    origin: process.env.FRONT_END_URL ?? 'http://localhost:3000',
    credentials: true,
  });

  // enable validate
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  //enable cors
  app.enableCors(corsConfig);
  await app.listen(process.env.PORT ?? 8080);
}
void bootstrap();
