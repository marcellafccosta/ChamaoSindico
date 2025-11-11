import { Injectable, Inject, Logger, OnModuleInit } from '@nestjs/common';
// import { ClientKafka } from '@nestjs/microservices';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Aviso } from '../../shared/entities/aviso.entity';
import { CreateAvisoDto } from './dto/create-aviso.dto';
import { UpdateAvisoDto } from './dto/update-aviso.dto';
import { ClientKafka } from '@nestjs/microservices';

@Injectable()
export class AvisoService implements OnModuleInit {
  private readonly logger = new Logger(AvisoService.name);

  constructor(
    @InjectRepository(Aviso)
    private readonly avisoRepository: Repository<Aviso>,
   @Inject('KAFKA_SERVICE') private readonly kafkaClient: ClientKafka,
  ) {}

  async onModuleInit() {
    await this.kafkaClient.connect();
  }

  async create(createAvisoDto: CreateAvisoDto): Promise<Aviso> {
    const aviso = this.avisoRepository.create(createAvisoDto);
    const novoAviso = await this.avisoRepository.save(aviso);

    this.logger.log(
      `--> [Kafka Producer] Emitindo evento para o tópico "avisos-criados"`,
    );
    this.kafkaClient.emit('avisos-criados', novoAviso);

    return novoAviso;
  }

  // ... resto do serviço (findAll, findOne, etc.) permanece igual
  async findAll(): Promise<Aviso[]> {
    return this.avisoRepository.find();
  }

  async findOne(id: number): Promise<Aviso> {
    return this.avisoRepository.findOne({ where: { id } });
  }

  async update(id: number, updateAvisoDto: UpdateAvisoDto): Promise<Aviso> {
    const aviso = await this.findOne(id);
    if (!aviso) {
      throw new Error(`Aviso com ID ${id} não encontrado`);
    }
    Object.assign(aviso, updateAvisoDto);
    return this.avisoRepository.save(aviso);
  }

  async remove(id: number): Promise<void> {
    const aviso = await this.findOne(id);
    if (!aviso) {
      throw new Error(`Aviso com ID ${id} não encontrado`);
    }
    await this.avisoRepository.remove(aviso);
  }
}
