import { Injectable } from '@nestjs/common';
import { User } from '../../shared/entities/user.entity';
import { UsersRepository } from '../../shared/repositories/users.repository';
import { CreateRequestDTO } from './dto/createRequest.dto';
import { UpdateRequestDTO } from './dto/updateRequest.dto';
import { In } from 'typeorm';

@Injectable()
export class UsersService {
  constructor(private usersRepository: UsersRepository) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.findAll();
  }

  async findByEmail(email: string): Promise<User | undefined> {
    return await this.usersRepository.findByEmail(email);
  }

  async findOne(id: number): Promise<User> {
    return this.usersRepository.findOne(id);
  }

  async create(dto: CreateRequestDTO): Promise<User> {
    return this.usersRepository.create(dto);
  }

  async update(id: number, dto: UpdateRequestDTO): Promise<User> {
    const user = await this.findOne(id);
    if (!user) {
      throw new Error(`User with id ${id} not found`);
    }
    Object.assign(user, dto);
    return this.usersRepository.save(user);
  }

  async remove(id: number): Promise<void> {
    const user = await this.findOne(id);
    if (!user) {
      throw new Error(`User with id ${id} not found`);
    }
    await this.usersRepository.delete(id);
  }

  async vincularUsuarios(apartamentoId: number, userIds: number[]) {
    const users = await this.usersRepository.findBy({ id: In(userIds) });
    for (const user of users) {
      user.apartamentoId = apartamentoId;
      this.usersRepository.save(user);
    }

    return { message: 'Usuários atualizados com sucesso' };
  }

  async updateFcmToken(userId: number, fcmToken: string): Promise<void> {
    await this.usersRepository.update(userId, { fcmToken });
  }
}
