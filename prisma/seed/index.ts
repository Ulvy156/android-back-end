import { seedDepartments } from './department.seed';
import { seedUsers } from './user.seed';
import { prisma } from 'src/prisma/prisma.client';

async function main() {
  const departments = await seedDepartments(prisma);
  await seedUsers(prisma, departments);

  console.log('✅ Seeding completed');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
