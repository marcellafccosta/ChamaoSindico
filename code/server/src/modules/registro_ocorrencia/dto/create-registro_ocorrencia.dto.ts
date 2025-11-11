import { ApiHideProperty, ApiProperty } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateRegistroOcorrenciaDto {
  @ApiProperty({
    example: 'Outros',
    description:
      'Categoria da ocorrência. Pode ser: Infracoes_Regras_Condominio, Ocorrencias_Seguranca, Ocorrencias_Ambientais, Ocorrencias_Administrativas, Problemas_Estruturais ou Outros.',
  })
  @IsString()
  @IsIn([
    'Infrações das Regras Condominio',
    'Ocorrências de Seguranca',
    'Ocorrências Ambientais',
    'Ocorrências Administrativas',
    'Problemas Estruturais',
    'Outros'
  ])
  categoria: string;

  @ApiProperty({
    example: 'Tarde',
    description: 'Período do dia em que a ocorrência foi registrada: Manha, Tarde ou Noite.',
  })
  @IsString()
  @IsIn(['Manha', 'Tarde', 'Noite'])
  periodo: string;

  @ApiProperty({
    example: 'Bloco A, 3º andar',
    description: 'Localização da ocorrência dentro do condomínio.',
  })
  @IsString()
  @IsNotEmpty()
  localizacao: string;

  @ApiProperty({
    example: 'Relato de barulho excessivo na área comum durante a noite.',
    description: 'Descrição detalhada da ocorrência.',
  })
  @IsString()
  @IsNotEmpty()
  descricao: string;
  @ApiHideProperty() // Esconde do Swagger pois é definido automaticamente
  @IsOptional()
  @IsNumber()
  userId?: number;
}
