import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsString,
  IsStrongPassword,
} from 'class-validator';
import { Role } from 'prisma/generated/enums';

export class CreateUserDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsStrongPassword()
  password: string;

  @IsEnum(Role)
  role: Role;

  @IsNotEmpty()
  @IsNumber()
  departmentId: number;
}
