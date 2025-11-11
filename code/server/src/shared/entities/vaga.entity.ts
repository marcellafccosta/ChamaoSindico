import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Apartamento } from './apartamento.entity';
@Entity('vaga')
export class Vaga {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ default: false })
  isOcupada: boolean;

  @Column({ nullable: true })
  apartamentoId: number;

  @ManyToOne(() => Apartamento, (apartamento) => apartamento.vaga, { nullable: false })
  @JoinColumn({ name: 'apartamentoId' })
  apartamento: Apartamento;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

export { Apartamento };
