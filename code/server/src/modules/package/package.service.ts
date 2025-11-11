import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { CreatePackageDto } from './dto/create-package.dto';
import { UpdatePackageDto } from './dto/update-package.dto';
import { PackagesRepository } from '../../shared/repositories/packages.repository';
import { Package } from '../../shared/entities/package.entity';
import { packageStatus } from '../../shared/enums/packageStatus.enum';

@Injectable()
export class PackageService {
  constructor(private packagesRepository: PackagesRepository) {}

  async create(dto: CreatePackageDto, apartamentoId: number): Promise<Package> {
    if (!apartamentoId) {
      throw new ForbiddenException('Você ainda não está vinculado a um apartamento.');
    }
    const packages = await this.packagesRepository.create({
      ...dto,
      apartamento: { id: apartamentoId },
      status: packageStatus.PENDENTE,
    });
    
    return packages;
  }

  async findAll(): Promise<Package[]> {
    const packages = await this.packagesRepository.findAll();
    const updatedPackages = [];
    packages.forEach(packageEntity => {
      const estimatedDate = new Date(packageEntity.estimatedDelivery);
      if (estimatedDate < new Date() && packageEntity.status !== packageStatus.ENTREGUE && packageEntity.status !== packageStatus.CANCELADO) {
        packageEntity.status = packageStatus.ATRASADO; 
      }
      updatedPackages.push(this.packagesRepository.save(packageEntity)); 
    });
    await Promise.all(updatedPackages);

    return this.packagesRepository.findAll(); 
}

  async findOne(id: number): Promise<Package> {
    const packageEntity = await this.packagesRepository.findOne(id);
    if (!packageEntity) {
      throw new NotFoundException(`Package with id ${id} not found`);
    }
    return this.packagesRepository.findOne(id);
  }

 async update(id: number, dto: UpdatePackageDto): Promise<Package> {
    const packages = await this.findOne(id);
    if (!packages) {
      throw new NotFoundException(`Package with id ${id} not found`);
    }

    if (dto.status && dto.status !== packageStatus.ENTREGUE && dto.status !== packageStatus.CANCELADO) {
      const estimatedDate = new Date(packages.estimatedDelivery);
      if (new Date() > estimatedDate && packages.status !== packageStatus.ENTREGUE) {
        dto.status = packageStatus.ATRASADO;
      }
    }
    Object.assign(packages, dto);
    return this.packagesRepository.save(packages);
  }

  async remove(id: number): Promise<void> {
    const packages = await this.findOne(id);
    if (!packages) {
      throw new NotFoundException(`Package with id ${id} not found`);
    }
    await this.packagesRepository.delete(id);
  }
}
