import { PrismaClient } from 'prisma/generated/client';
import { SeedDepartments } from './seed.type';

export async function seedFolders(
  prisma: PrismaClient,
  departments: SeedDepartments,
) {
  const hrRoot = await prisma.folder.create({
    data: {
      name: 'HR Policies',
      departmentId: departments.hr.id,
    },
  });

  const benefits = await prisma.folder.create({
    data: {
      name: 'Employee Benefits',
      departmentId: departments.hr.id,
      parentId: hrRoot.id,
    },
  });

  const itRoot = await prisma.folder.create({
    data: {
      name: 'IT Policies',
      departmentId: departments.it.id,
    },
  });

  return { hrRoot, benefits, itRoot };
}
