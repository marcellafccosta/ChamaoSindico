import { IsString, IsNotEmpty, MaxLength, IsOptional } from 'class-validator';

export class CreateProfissionalDto {
@IsString()
@IsNotEmpty({ message: 'O nome do profissional é obrigatório.' })
@MaxLength(100, { message: 'Nome deve ter no máximo 100 caracteres.' })
nome: string;

@IsString()
@IsNotEmpty({ message: 'A área de atuação é obrigatória.' })
@MaxLength(100, { message: 'Área de atuação deve ter no máximo 100 caracteres.' })
areaAtuacao: string;

@IsString()
@IsNotEmpty({ message: 'O contato é obrigatório.' })
@MaxLength(100, { message: 'Contato deve ter no máximo 100 caracteres.' })
contato: string; 
}