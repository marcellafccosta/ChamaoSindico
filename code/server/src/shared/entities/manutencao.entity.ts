import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

import { manutencaoStatus } from '../../shared/enums/manutencaoStatus.enum';

@Entity('manutencao')
export class Manutencao {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ length: 100 })
  tipoManutencao: string;

  @Column({ length: 100 })
  tipoEquipamento: string;

  @Column({ type: 'date', nullable: true })
  dataManutencao: Date;

  @Column({ type: 'date', nullable: true })
  dataProximaManutencao: Date;

  @Column({ length: 300 })
  observacoes: string;

  @Column({ length: 100 })
  responsavel: string;

  @Column({ length: 50 })
  frequencia: string;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  @Column({
    type: 'enum',
    enum: manutencaoStatus,
    default: manutencaoStatus.EM_DIA,
  })
  status: manutencaoStatus;

  @Column({ type: 'boolean', default: false })
  manutencaoRealizada: boolean;
}
