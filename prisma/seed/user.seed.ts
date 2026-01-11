import * as bcrypt from 'bcrypt';
import { PrismaClient, Role } from 'prisma/generated/client';
import { SeedDepartments } from './seed.type';

export async function seedUsers(
  prisma: PrismaClient,
  departments: SeedDepartments,
) {
  const password = await bcrypt.hash('password123', 10);

  const admin = await prisma.user.create({
    data: {
      name: 'Admin User',
      email: 'admin@company.com',
      password,
      role: Role.ADMIN,
      departmentId: departments.hr.id,
    },
  });

  const hrManager = await prisma.user.create({
    data: {
      name: 'HR Manager',
      email: 'hr.manager@company.com',
      password,
      role: Role.MANAGER,
      departmentId: departments.hr.id,
    },
  });

  const itManager = await prisma.user.create({
    data: {
      name: 'IT Manager',
      email: 'it.manager@company.com',
      password,
      role: Role.MANAGER,
      departmentId: departments.it.id,
    },
  });

  const hrStaff = await prisma.user.create({
    data: {
      name: 'HR Staff',
      email: 'hr.staff@company.com',
      password,
      role: Role.STAFF,
      departmentId: departments.hr.id,
    },
  });

  return { admin, hrManager, itManager, hrStaff };
}
