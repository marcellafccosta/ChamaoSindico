import {
Column,
CreateDateColumn,
Entity,
PrimaryGeneratedColumn,
UpdateDateColumn,
} from 'typeorm';

@Entity('aviso')
export class Aviso {
@PrimaryGeneratedColumn('increment')
id: number;

@Column({ length: 50 })
assunto: string;

@Column({ length: 300 })
aviso: string;

@Column({ default: false })
isReuniao: boolean;

@Column({ type: 'date', nullable: true })
dataReuniao: Date;

@Column({ default: false })
isImportant: boolean;

@Column({ length: 100 })
autor: string;
}