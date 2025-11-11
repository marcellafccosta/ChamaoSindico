import { ApiProperty } from '@nestjs/swagger';

export class AuthResponseDTO {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'JSON Web Token para autenticação',
  })
  accessToken: string;
}
