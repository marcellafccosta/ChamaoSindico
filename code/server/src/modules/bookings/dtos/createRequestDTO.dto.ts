import { ApiProperty } from '@nestjs/swagger';
import {
  IsDateString,
  IsInt,
  IsNotEmpty,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateBookingsRequestDTO {
  @ApiProperty({
    description: 'ID of the user making the booking',
    example: 1,
  })
  @IsInt()
  @IsPositive()
  @IsNotEmpty()
  userId: number;

  @ApiProperty({
    description: 'ID of the area being booked',
    example: 2,
  })
  @IsInt()
  @IsPositive()
  @IsNotEmpty()
  areaId: number;

  @ApiProperty({
    description: 'Date of the booking (YYYY-MM-DD)',
    example: '2025-05-06',
  })
  @IsDateString()
  @IsNotEmpty()
  date: string;

  @ApiProperty({
    description: 'Time of the booking (HH:mm)',
    example: '14:00',
  })
  @IsString()
  @IsNotEmpty()
  time: string;

  @ApiProperty({
    description: 'End time of the booking (HH:mm)',
    example: '16:00',
  })
  @IsString()
  @IsNotEmpty()
  endTime: string;

  @ApiProperty({
    description: 'Number of people for the booking',
    example: 5,
  })
  @IsInt()
  @IsPositive()
  @IsNotEmpty()
  numberOfPeople: number;
}
