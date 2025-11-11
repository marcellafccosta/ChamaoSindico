import { Role } from '../../shared/enums/role.enum';
import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Apartamento } from './apartamento.entity';
import { Visitante } from './visitante.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 255 })
  email: string;

  @Column({ type: 'varchar', length: 255 })
  password: string;

  @Column({ type: 'int', enum: Role, default: Role.RESIDENT })
  role: Role;

  @Column({ nullable: true })
  apartamentoId: number;

  @ManyToOne(() => Apartamento, (apartamento) => apartamento.users, {
    nullable: false,
  })
  @JoinColumn({ name: 'apartamentoId' })
  apartamento: Apartamento;

  @OneToMany(() => Visitante, (visitante) => visitante.user)
  vistante: Visitante[];

  @Column({ type: 'text', nullable: true })
  fcmToken: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date;
}
