import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Apartamento } from './apartamento.entity';
import { TipoVisitante } from '../../shared/enums/tipoVisitante.enum';
import { User } from './user.entity';
@Entity('visitante')
export class Visitante {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ default: false, type: 'varchar', length: 255 })
  document: string;

  @Column({ default: false, type: 'varchar', length: 255 })
  phone: string;

  @Column({ nullable: true, type: 'varchar', length: 255 })
  model: string;

  @Column({ nullable: true, type: 'timestamp' })
  checkIn: Date;

  @Column({ nullable: true, type: 'timestamp' })
  checkOut: Date;

  @Column({ nullable: true, type: 'int' })
  apartamentoId: number;

  @ManyToOne(() => Apartamento, (apartamento) => apartamento.vaga, {
    nullable: false,
  })
  @JoinColumn({ name: 'apartamentoId' })
  apartamento: Apartamento;

  @Column({
    type: 'varchar',
    enum: TipoVisitante,
    default: TipoVisitante.PESSOAL,
  })
  typeVisitant: TipoVisitante;

  @Column({ nullable: true, type: 'int' })
  userId: number;

  @ManyToOne(() => User, (user) => user.vistante, { nullable: false })
  @JoinColumn({ name: 'userId' })
  user: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
