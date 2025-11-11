import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Vaga } from './vaga.entity';
import { Visitante } from './visitante.entity';

@Entity('apartamento')
export class Apartamento {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @OneToMany(() => User, (user) => user.apartamento)
  users: User[];

  @OneToMany(() => Vaga, (vaga) => vaga.apartamento)
  vaga: Vaga[];

  @OneToMany(() => Visitante, (visitante) => visitante.apartamento)
  visitante: Visitante[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}


