import { PrismaClient, Role } from 'prisma/generated/client';
import { SeedDocuments } from './seed.type';

export async function seedDocumentPermissions(
  prisma: PrismaClient,
  documents: SeedDocuments,
) {
  await prisma.documentPermission.createMany({
    data: [
      { documentId: documents.leavePolicy.id, role: Role.ADMIN },
      { documentId: documents.leavePolicy.id, role: Role.MANAGER },
      { documentId: documents.leavePolicy.id, role: Role.STAFF },

      { documentId: documents.securityPolicy.id, role: Role.ADMIN },
      { documentId: documents.securityPolicy.id, role: Role.MANAGER },
    ],
  });
}
