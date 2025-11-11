import { Injectable } from '@nestjs/common';
import { CreateManutencaoDto } from './dto/create-manutencao.dto';
import { UpdateManutencaoDto } from './dto/update-manutencao.dto';
import { ManutencaoRepository } from '../../shared/repositories/manutencao.repository';
import { Manutencao } from '../../shared/entities/manutencao.entity';
import { manutencaoStatus } from '../../shared/enums/manutencaoStatus.enum';
import { NotFoundException } from '@nestjs/common';

@Injectable()
export class ManutencaoService {
  constructor(private manutencaoRepository: ManutencaoRepository) {}

  async create(createManutencaoDto: CreateManutencaoDto): Promise<Manutencao> {
    const manutencao = new Manutencao();
    Object.assign(manutencao, createManutencaoDto);

    const { dataManutencao, dataProximaManutencao, manutencaoRealizada } =
      manutencao;

    if (dataManutencao && dataProximaManutencao) {
      manutencao.status = await this.calcStatus(
        dataManutencao,
        dataProximaManutencao,
        manutencaoRealizada ?? false,
      );
    } else {
      manutencao.status = manutencaoStatus.EM_DIA;
    }

    return this.manutencaoRepository.create(manutencao);
  }

  async findAll(): Promise<Manutencao[]> {
    const manutencoes = await this.manutencaoRepository.findAll();

    for (const m of manutencoes) {
      const statusAtual = await this.calcStatus(
        m.dataManutencao,
        m.dataProximaManutencao,
        m.manutencaoRealizada ?? false,
      );

      if (m.status !== statusAtual) {
        m.status = statusAtual;
        await this.manutencaoRepository.update(m.id, { status: statusAtual });
      }
    }

    return manutencoes;
  }

  async findOne(id: number): Promise<Manutencao> {
    const manutencao = await this.manutencaoRepository.findById(id);
    if (!manutencao) {
      throw new NotFoundException(`Manutenção com id ${id} não encontrada`);
    }
    return manutencao;
  }

  async update(
    id: number,
    updateManutencaoDto: UpdateManutencaoDto,
  ): Promise<Manutencao> {
    const manutencao = await this.findOne(id);
    if (!manutencao) {
      throw new Error(`Manutenção com id ${id} não encontrada`);
    }

    Object.assign(manutencao, updateManutencaoDto);

    const { dataManutencao, dataProximaManutencao, manutencaoRealizada } =
      manutencao;

    if (dataManutencao && dataProximaManutencao) {
      manutencao.status = await this.calcStatus(
        dataManutencao,
        dataProximaManutencao,
        manutencaoRealizada ?? false,
      );
    } else {
      manutencao.status = manutencaoStatus.EM_DIA;
    }

    await this.manutencaoRepository.update(id, manutencao);
    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    const manutencao = await this.findOne(id);
    if (!manutencao) {
      throw new Error(`Manutenção com id ${id} não encontrada`);
    }
    await this.manutencaoRepository.delete(id);
  }

  async calcStatus(
    dataManutencao: Date,
    dataProximaManutencao: Date,
    manutencaoRealizada: boolean,
  ): Promise<manutencaoStatus> {
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);

    const dataProxima = new Date(dataProximaManutencao);
    dataProxima.setHours(0, 0, 0, 0);

    if (manutencaoRealizada) {
      return manutencaoStatus.CONCLUIDO;
    }

    if (hoje > dataProxima) {
      return manutencaoStatus.ATRASADO;
    }

    return manutencaoStatus.EM_DIA;
  }
}
