import { PrismaClient } from 'prisma/generated/client';
import { SeedDocuments, SeedUsers } from './seed.type';

export async function seedDocumentVersions(
  prisma: PrismaClient,
  documents: SeedDocuments,
  users: SeedUsers,
) {
  await prisma.documentVersion.createMany({
    data: [
      {
        documentId: documents.leavePolicy.id,
        version: 'v1.0',
        fileUrl: '/files/leave_policy_v1.pdf',
        uploadedBy: users.hrManager.id,
      },
      {
        documentId: documents.leavePolicy.id,
        version: 'v2.0',
        fileUrl: '/files/leave_policy_v2.pdf',
        uploadedBy: users.hrManager.id,
      },
      {
        documentId: documents.securityPolicy.id,
        version: 'v1.0',
        fileUrl: '/files/security_v1.pdf',
        uploadedBy: users.itManager.id,
      },
    ],
  });
}
