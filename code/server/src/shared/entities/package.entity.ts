import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';

import { Apartamento } from './apartamento.entity';
import { packageStatus } from '../../shared/enums/packageStatus.enum';

@Entity('packages')
export class Package {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ type: 'varchar', length: 255 })
  store: string;

  @Column({ type: 'varchar', length: 255 })
  keyword: string;

  @Column({ type: 'date', nullable: true })
  estimatedDelivery: Date;

  @ManyToOne(() => Apartamento, (apartamento) => apartamento.id, {
    nullable: false,
  })
  apartamento: Apartamento;

  @Column({ type: 'varchar', length: 255 })
  recipient: string;

  @Column({
    type: 'enum',
    enum: packageStatus,
    default: packageStatus.PENDENTE,
  })
  status: packageStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
