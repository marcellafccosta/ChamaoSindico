import { BadRequestException, Injectable, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RegistroOcorrencia } from '../../shared/entities/registro_ocorrencia.entity';
import { CreateRegistroOcorrenciaDto } from './dto/create-registro_ocorrencia.dto';
import { UpdateRegistroOcorrenciaDto } from './dto/update-registro_ocorrencia.dto';
import { NotFoundException } from '@nestjs/common';

@Injectable()
export class RegistroOcorrenciaService {
constructor(
  @InjectRepository(RegistroOcorrencia)
  private readonly registroRepository: Repository<RegistroOcorrencia>,
) {}

async create(createDto: CreateRegistroOcorrenciaDto, userId: number): Promise<RegistroOcorrencia> {
  try {
    const registro = this.registroRepository.create({
      ...createDto,
      userId: userId,
    });
    return await this.registroRepository.save(registro);
  } catch (error) {
    throw new BadRequestException("Erro ao registrar uma ocorrência. Verifique os dados inseridos.");
  }
}

async findAll(user: any): Promise<RegistroOcorrencia[]> {
  return await this.registroRepository.find({
    relations: ['user'], 
    order: { dataCriacao: 'DESC' }
  });
  
}

async findOne(id: number, userId: number): Promise<RegistroOcorrencia> {
  const ocorrencia = await this.registroRepository.findOne({ 
    where: { id },
    relations: ['user']
  });

  if (!ocorrencia) {
    throw new NotFoundException(`Ocorrência com ID ${id} não encontrada.`);
  }

  return ocorrencia; 
}

async update(id: number, updateDto: UpdateRegistroOcorrenciaDto, userId: number): Promise<RegistroOcorrencia> {
  const ocorrenciaExistente = await this.registroRepository.findOne({ where: { id } });
  
  if (!ocorrenciaExistente) {
    throw new NotFoundException(`Ocorrência com ID ${id} não encontrada para atualização.`);
  }

  if (ocorrenciaExistente.userId !== userId) {
    throw new ForbiddenException('Você só pode editar ocorrências que você criou.');
  }

  const ocorrencia = await this.registroRepository.preload({
    id,
    ...updateDto,
    userId: ocorrenciaExistente.userId, 
  });

  return await this.registroRepository.save(ocorrencia);
}

async remove(id: number, userId: number): Promise<void> {
  const ocorrencia = await this.registroRepository.findOne({ where: { id } });
  
  if (!ocorrencia) {
    throw new NotFoundException(`Ocorrência com ID ${id} não encontrada para exclusão.`);
  }

  if (ocorrencia.userId !== userId) {
    throw new ForbiddenException('Você só pode excluir ocorrências que você criou.');
  }

  const result = await this.registroRepository.delete(id);
  
  if (result.affected === 0) {
    throw new NotFoundException(`Erro inesperado ao excluir ocorrência com ID ${id}.`);
  }
}
}