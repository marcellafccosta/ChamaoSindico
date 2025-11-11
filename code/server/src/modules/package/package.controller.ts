import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Req,
  ForbiddenException, 
  
} from '@nestjs/common';
import { PackageService } from './package.service';
import { CreatePackageDto } from './dto/create-package.dto';
import { UpdatePackageDto } from './dto/update-package.dto';
import { Package } from '../../shared/entities/package.entity';
import { Authorization } from '../../shared/decorators/authorization.decorator';

@Controller('package')
export class PackageController {
  constructor(private readonly packageService: PackageService) {}

  @Post()
  @Authorization({})
  async create(@Body() dto: CreatePackageDto, @Req() req: any) {
    const { apartamentoId } = req.user;

    if (!apartamentoId) {
      throw new ForbiddenException(
        'Você ainda não está vinculado a um apartamento.',
      );
    }

    return this.packageService.create(dto, apartamentoId);
  }

  @Get()
  async findAll(): Promise<Package[]> {
    return this.packageService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: number): Promise<Package> {
    return this.packageService.findOne(+id);
  }

  @Patch(':id')
  async update(
    @Param('id') id: number,
    @Body() dto: UpdatePackageDto,
  ): Promise<Package> {
    return this.packageService.update(+id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: number): Promise<void> {
    return this.packageService.remove(+id);
  }
}
