import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { Role } from 'prisma/generated/enums';
import { hashingPassword } from 'src/utils/hashingPassword';
import { prismaError } from 'src/utils/prismaError';

@Injectable()
export class UserService {
  constructor(private readonly prisma: PrismaService) {}

  // ======================
  // CREATE USER
  // ======================
  async create(createUserDto: CreateUserDto) {
    try {
      const hashedPassword = await hashingPassword(createUserDto.password);
      createUserDto.password = hashedPassword;
      return this.prisma.user.create({
        data: createUserDto,
      });
    } catch (error) {
      prismaError(error);
    }
  }

  // ======================
  // GET ALL USERS
  // ======================
  async findAll() {
    return this.prisma.user.findMany({
      include: {
        department: true,
      },
    });
  }

  // ======================
  // GET USER BY ID
  // ======================
  async findOne(id: number) {
    return this.prisma.user.findUniqueOrThrow({
      where: { id },
      include: {
        department: true,
      },
    });
  }

  // ======================
  // CREATE USER
  // ======================
  async update(id: number, updateUserDto: UpdateUserDto) {
    try {
      return this.prisma.user.update({
        data: updateUserDto,
        where: { id },
      });
    } catch (error) {
      prismaError(error);
    }
  }

  // ======================
  // LOCK / UNLOCK USER
  // ======================
  async setLock(id: number, isLocked: boolean) {
    return this.prisma.user.update({
      where: { id },
      data: { isLocked },
    });
  }

  // ======================
  // CHANGE ROLE (ADMIN ONLY)
  // ======================
  async changeRole(id: number, role: Role) {
    return this.prisma.user.update({
      where: { id },
      data: { role },
    });
  }
}
