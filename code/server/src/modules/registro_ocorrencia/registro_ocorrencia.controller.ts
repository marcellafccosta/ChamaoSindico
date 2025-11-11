import { Controller, Get, Post, Body, Param, Delete, Patch, Request } from '@nestjs/common';
import { RegistroOcorrenciaService } from './registro_ocorrencia.service';
import { CreateRegistroOcorrenciaDto } from './dto/create-registro_ocorrencia.dto';
import { RegistroOcorrencia } from '../../shared/entities/registro_ocorrencia.entity';
import { UpdateRegistroOcorrenciaDto } from './dto/update-registro_ocorrencia.dto';
import { ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Authorization } from '../../shared/decorators/authorization.decorator'; 

@Controller('registro-ocorrencia')
@Authorization({}) 
export class RegistroOcorrenciaController {
constructor(private readonly registroOcorrenciaService: RegistroOcorrenciaService) {}

@Post()
@ApiOperation({ summary: 'Criar uma ocorrência' })
@ApiResponse({ status: 200, description: 'Ocorrência criada com sucesso' })
@ApiResponse({ status: 404, description: 'Não foi possível criar essa ocorrência' })
async create(
  @Body() createRegistroOcorrenciaDto: CreateRegistroOcorrenciaDto,
  @Request() req: any,
): Promise<RegistroOcorrencia> {
  return this.registroOcorrenciaService.create(createRegistroOcorrenciaDto, req.user.id);
}

@Get()
@ApiOperation({ summary: 'Buscar todas as ocorrências' })
@ApiResponse({ status: 200, description: 'Ocorrências encontradas' })
findAll(@Request() req: any) {
  return this.registroOcorrenciaService.findAll(req.user);
}

@Get(':id')
@ApiOperation({ summary: 'Buscar uma ocorrência pelo ID' })
@ApiResponse({ status: 200, description: 'Ocorrência encontrada' })
@ApiResponse({ status: 404, description: 'Ocorrência não encontrada' })
findOne(@Param('id') id: string, @Request() req: any) {
  return this.registroOcorrenciaService.findOne(+id, req.user.id);
}

@Patch(':id')
@ApiOperation({ summary: 'Atualizar uma ocorrência pelo ID' })
@ApiResponse({ status: 200, description: 'Ocorrência atualizada com sucesso' })
@ApiResponse({ status: 404, description: 'Ocorrência não encontrada' })
update(
  @Param('id') id: string,
  @Body() updateRegistroOcorrenciaDto: UpdateRegistroOcorrenciaDto,
  @Request() req: any,
): Promise<RegistroOcorrencia> {
  return this.registroOcorrenciaService.update(+id, updateRegistroOcorrenciaDto, req.user.id);
}

@Delete(':id')
@ApiOperation({ summary: 'Remover uma ocorrência pelo ID' })
@ApiResponse({ status: 200, description: 'Ocorrência removida com sucesso' })
@ApiResponse({ status: 404, description: 'Ocorrência não encontrada' })
remove(@Param('id') id: string, @Request() req: any) {
  return this.registroOcorrenciaService.remove(+id, req.user.id);
}
}