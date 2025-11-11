import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Area } from './area.entity';
import { User } from './user.entity';

@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @ManyToOne(() => User, (user) => user.id, { nullable: false })
  user: User;

  @ManyToOne(() => Area, (area) => area.id, { nullable: false })
  area: Area;

  @Column({ type: 'date' })
  date: Date;

  @Column({ type: 'time' })
  time: string;

  @Column({ type: 'time' }) 
  endTime: string;

  @Column({ type: 'int', default: 1 })
  numberOfPeople: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
