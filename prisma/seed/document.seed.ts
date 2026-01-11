import { PrismaClient } from 'prisma/generated/client';
import { SeedDepartments, SeedFolders } from './seed.type';

export async function seedDocuments(
  prisma: PrismaClient,
  folders: SeedFolders,
  departments: SeedDepartments,
) {
  const leavePolicy = await prisma.document.create({
    data: {
      title: 'Leave Policy',
      description: 'Employee leave and absence policy',
      folderId: folders.benefits.id,
      departmentId: departments.hr.id,
    },
  });

  const securityPolicy = await prisma.document.create({
    data: {
      title: 'IT Security Guidelines',
      description: 'Security rules and best practices',
      folderId: folders.itRoot.id,
      departmentId: departments.it.id,
    },
  });

  return { leavePolicy, securityPolicy };
}
