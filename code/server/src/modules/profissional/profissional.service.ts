import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { CreateProfissionalDto } from './dto/create-profissional.dto';
import { UpdateProfissionalDto } from './dto/update-profissional.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Profissional } from '../../shared/entities/profissional.entity';

@Injectable()
export class ProfissionalService {
  constructor(
    @InjectRepository(Profissional)
    private readonly profissionalRepository: Repository<Profissional>,
  ) {}

  async create(
    createProfissionalDto: CreateProfissionalDto,
    userId: number,
  ): Promise<Profissional> {
    try {
      // Verificar se já existe um profissional com mesmo nome e área
      const existingProfissional = await this.profissionalRepository.findOne({
        where: {
          nome: createProfissionalDto.nome,
          areaAtuacao: createProfissionalDto.areaAtuacao,
        },
      });

      if (existingProfissional) {
        throw new BadRequestException(
          'Já existe um profissional com este nome e área de atuação',
        );
      }

      const profissional = this.profissionalRepository.create({
        ...createProfissionalDto,
        userId,
      });

      const savedProfissional =
        await this.profissionalRepository.save(profissional);

      // Carregar com relações para retorno
      return await this.findOne(savedProfissional.id);
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }

      console.error('Erro ao criar profissional:', error);
      throw new BadRequestException(
        'Erro ao criar profissional. Verifique os dados e tente novamente.',
      );
    }
  }

  async findAll(
    page = 1,
    limit = 50,
  ): Promise<{ data: Profissional[]; total: number }> {
    const [data, total] = await this.profissionalRepository.findAndCount({
      relations: ['usuario'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return { data, total };
  }

  async findByUser(userId: number): Promise<Profissional[]> {
    return await this.profissionalRepository.find({
      where: { userId },
      relations: ['usuario'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Profissional> {
    const profissional = await this.profissionalRepository.findOne({
      where: { id },
      relations: ['usuario'],
    });

    if (!profissional) {
      throw new NotFoundException(`Profissional com ID ${id} não encontrado.`);
    }
    return profissional;
  }

  async findByArea(areaAtuacao: string): Promise<Profissional[]> {
    return await this.profissionalRepository.find({
      where: { areaAtuacao },
      relations: ['usuario'],
      order: { createdAt: 'DESC' },
    });
  }

  async update(
    id: number,
    updateProfissionalDto: UpdateProfissionalDto,
    userId: number,
  ): Promise<Profissional> {
    const profissional = await this.findOne(id);

    if (profissional.userId !== userId) {
      throw new ForbiddenException(
        'Você só pode editar suas próprias indicações',
      );
    }

    await this.profissionalRepository.update(id, updateProfissionalDto);
    return await this.findOne(id);
  }

  async remove(id: number, userId: number): Promise<void> {
    const profissional = await this.findOne(id);

    if (profissional.userId !== userId) {
      throw new ForbiddenException(
        'Você só pode excluir suas próprias indicações',
      );
    }

    const result = await this.profissionalRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(
        `Profissional com ID ${id} não encontrado para exclusão.`,
      );
    }
  }
}
