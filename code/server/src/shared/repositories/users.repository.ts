import { Injectable } from '@nestjs/common';
import { User } from '../../shared/entities/user.entity';
import { Order } from '../../shared/enums/data.enum';
import { DataSource, Repository, DeepPartial, FindOptionsWhere } from 'typeorm';

@Injectable()
export class UsersRepository {
  createQueryBuilder(arg0: string) {
    throw new Error('Method not implemented.');
  }
  private repository: Repository<User>;

  constructor(private dataSource: DataSource) {
    this.repository = this.dataSource.getRepository(User);
  }

  findAll(): Promise<User[]> {
    return this.repository.find({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        apartamentoId: true,
        fcmToken: true,
        apartamento: {
          id: true,
          name: true,
        },
      },
      relations: {
        apartamento: true,
      },
      order: { updatedAt: 'DESC' },
    });
  }

  findOne(id: number): Promise<User> {
    return this.repository.findOne({ where: { id } });
  }

  findByEmail(email: string): Promise<User | null> {
    return this.repository.findOne({
      where: { email },
      relations: ['apartamento'],
    });
  }

  create(dto: DeepPartial<User>): Promise<User> {
    const object: User = this.repository.create(dto);
    try {
      return this.repository.save(object);
    } catch (error) {
      console.error('Erro ao salvar no banco:', error);
      throw error;
    }
  }

  async save(user: User): Promise<User> {
    return this.repository.save(user);
  }

  async delete(id: number): Promise<void> {
    const user = await this.repository.findOne({ where: { id } });
    if (!user) {
      throw new Error(`User with id ${id} not found`);
    }
    await this.repository.remove(user);
  }

  findBy(where: FindOptionsWhere<User>): Promise<User[]> {
    return this.repository.find({ where });
  }

  async update(id: number, dto: DeepPartial<User>): Promise<User | null> {
    const user = await this.repository.findOne({ where: { id } });
    if (!user) {
      return null;
    }

    this.repository.merge(user, dto);
    return this.repository.save(user);
  }
}
