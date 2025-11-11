import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity'; 

@Entity('profissional')
export class Profissional {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ length: 100 })
  nome: string;

  @Column({ length: 100 })
  areaAtuacao: string;

  @Column({ length: 100, nullable: true }) 
  contato: string;

  @Column({ name: 'user_id' })
  userId: number;

  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'user_id' })
  usuario: User;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;
}
