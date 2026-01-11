import { seedDepartments } from './department.seed';
import { seedUsers } from './user.seed';
import { seedFolders } from './folder.seed';
import { seedDocuments } from './document.seed';
import { seedDocumentVersions } from './document-version.seed';
import { seedDocumentPermissions } from './document-permission.seed';
import { prisma } from 'src/prisma/prisma.client';

async function main() {
  const departments = await seedDepartments(prisma);
  const users = await seedUsers(prisma, departments);
  const folders = await seedFolders(prisma, departments);
  const documents = await seedDocuments(prisma, folders, departments);

  await seedDocumentVersions(prisma, documents, users);
  await seedDocumentPermissions(prisma, documents);

  console.log('✅ Seeding completed (type-safe)');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
