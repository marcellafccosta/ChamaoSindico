import { Injectable } from '@nestjs/common';
import { Visitante } from '../../shared/entities/visitante.entity';
import { DataSource, Repository, DeepPartial } from 'typeorm';

@Injectable()
export class VisitanteRepository {
  private repository: Repository<Visitante>;

  constructor(private dataSource: DataSource) {
    this.repository = this.dataSource.getRepository(Visitante);
  }

  findAll(): Promise<Visitante[]> {
    return this.repository.find({
      select: {
        id: true,
        name: true,
        document: true,
        phone: true,
        model: true,
        checkIn: true,
        checkOut: true,
        typeVisitant: true,
        apartamentoId: true,
        apartamento: {
          name: true,
        },
        userId: true,
        user: {
          id: true,
          name: true,
          email: true,
        },
      },
      relations: {
        apartamento: true,
        user: true,
      },
      order: { updatedAt: 'DESC' },
    });
  }

  async findVisitantesByApartamento(
    apartamentoId: number,
  ): Promise<Visitante[]> {
    return this.repository.find({
      where: {
        apartamento: { id: apartamentoId }, // Filtro diretamente pela relação
      },
      relations: {
        apartamento: true,
        user: true,
      },
      select: {
        id: true,
        name: true,
        document: true,
        phone: true,
        model: true,
        checkIn: true,
        checkOut: true,
        typeVisitant: true,
        apartamentoId: true,
        apartamento: {
          name: true,
        },
        userId: true,
        user: {
          id: true,
          name: true,
          email: true,
        },
      },
      order: { updatedAt: 'DESC' }, // Ordenar pela data de atualização
    });
  }

  findOne(id: number): Promise<Visitante> {
    return this.repository.findOne({ where: { id } });
  }

  create(dto: DeepPartial<Visitante>): Promise<Visitante> {
    const object: Visitante = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(visitante: Visitante): Promise<Visitante> {
    return this.repository.save(visitante);
  }

  async delete(id: number): Promise<void> {
    const visitante = await this.repository.findOne({ where: { id } });
    if (!visitante) {
      throw new Error(`Visitante with id ${id} not found`);
    }
    await this.repository.remove(visitante);
  }
}
