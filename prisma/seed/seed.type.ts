import { Department, Folder, User } from 'prisma/generated/browser';

export type SeedDepartments = {
  hr: Department;
  it: Department;
  finance: Department;
};

export type SeedUsers = {
  admin: User;
  hrManager: User;
  itManager: User;
  hrStaff: User;
};

export type SeedFolders = {
  hrRoot: Folder;
  benefits: Folder;
  itRoot: Folder;
};

export type SeedDocuments = {
  leavePolicy: Document;
  securityPolicy: Document;
};
