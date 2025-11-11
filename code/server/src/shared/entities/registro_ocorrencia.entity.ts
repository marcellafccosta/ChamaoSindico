import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import {User} from '../../shared/entities/user.entity';
@Entity('registro_ocorrencia')
export class RegistroOcorrencia {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  categoria: string;

  @Column({ length: 100 })
  periodo: string;

  @Column('text')
  localizacao: string;

  @Column('text')
  descricao: string;

  @CreateDateColumn({ name: 'data_criacao' })
  dataCriacao: Date;

  @Column()
  userId: number;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'userId' })
  user: User;
}
