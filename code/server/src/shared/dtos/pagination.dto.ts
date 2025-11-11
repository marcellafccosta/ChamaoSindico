import { ApiProperty } from '@nestjs/swagger';
import { Order } from '../../shared/enums/data.enum';
import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsNotEmpty, Min } from 'class-validator';

export class PaginationDTO {
  @ApiProperty({ required: true, example: 1 })
  @Min(1)
  @IsInt()
  @Transform(({ value }) => parseInt(value))
  @IsNotEmpty()
  page: number;

  @ApiProperty({ required: true, example: 10 })
  @Min(1)
  @IsInt()
  @Transform(({ value }) => parseInt(value))
  @IsNotEmpty()
  take: number;

  @ApiProperty({ required: false, example: false })
  @Transform(({ value }) => {
    switch (value.toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        return value;
    }
  })
  withDeleted: boolean;

  @ApiProperty({ required: true, example: Order.ASC, enum: Order })
  @IsEnum(Order)
  @Transform(({ value }) => value.toUpperCase())
  sortOrder?: Order;
}
