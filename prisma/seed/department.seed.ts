import { PrismaClient } from 'prisma/generated/client';

export async function seedDepartments(prisma: PrismaClient) {
  const hr = await prisma.department.create({
    data: { name: 'HR', description: 'Human Resources' },
  });

  const it = await prisma.department.create({
    data: { name: 'IT', description: 'Information Technology' },
  });

  const finance = await prisma.department.create({
    data: { name: 'FINANCE', description: 'Finance Department' },
  });

  return { hr, it, finance };
}
