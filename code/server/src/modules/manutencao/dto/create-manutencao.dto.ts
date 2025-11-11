import { ApiProperty } from '@nestjs/swagger';
import { manutencaoStatus } from '../../../shared/enums/manutencaoStatus.enum';
import {
  IsIn,
  IsString,
  IsDateString,
  IsOptional,
  IsEnum,
  IsBoolean,
} from 'class-validator';

export class CreateManutencaoDto {
  @ApiProperty({ example: 'Preventiva', enum: ['Preventiva', 'Preditiva'] })
  @IsIn(['Preventiva', 'Preditiva'])
  tipoManutencao: string;

  @ApiProperty({
    example: 'Elevador',
    enum: [
      'Elevador',
      'Câmera de segurança',
      'Porta automática',
      'Portão da Garagem',
      'Portão de Pedestre',
      'Outro',
    ],
  })
  @IsIn([
    'Elevador',
    'Câmera de segurança',
    'Porta automática',
    'Portão da Garagem',
    'Portão de Pedestre',
    'Outro',
  ])
  tipoEquipamento: string;

  @ApiProperty({ example: '2025-04-10' })
  @IsDateString()
  dataManutencao: string;

  @ApiProperty({ example: 'Manutenção feita com troca de peças' })
  @IsString()
  observacoes: string;

  @ApiProperty({ example: 'João da Silva' })
  @IsString()
  responsavel: string;

  @ApiProperty({
    example: 'Mensal',
    enum: ['Diária', 'Semanal', 'Mensal', 'Anual'],
  })
  @IsIn(['Diária', 'Semanal', 'Mensal', 'Anual'])
  frequencia: string;

  @ApiProperty({ example: '2025-05-10' })
  @IsDateString()
  dataProximaManutencao: string;

  @ApiProperty({ enum: manutencaoStatus, required: false })
  @IsOptional()
  @IsEnum(manutencaoStatus)
  status?: manutencaoStatus;

  @ApiProperty({ example: false, required: false })
  @IsOptional()
  @IsBoolean()
  manutencaoRealizada?: boolean;
}
