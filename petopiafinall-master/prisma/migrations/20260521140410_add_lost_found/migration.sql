-- CreateEnum
CREATE TYPE "LostFoundStatus" AS ENUM ('LOST', 'FOUND');

-- CreateTable
CREATE TABLE "LostFoundReport" (
    "id" TEXT NOT NULL,
    "status" "LostFoundStatus" NOT NULL,
    "species" "PetType" NOT NULL,
    "breed" TEXT,
    "gender" "Gender",
    "color" TEXT,
    "description" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "name" TEXT,
    "lastSeenLocation" TEXT,
    "lastSeenDate" TIMESTAMP(3),
    "ownerId" TEXT,
    "foundLocation" TEXT,
    "isPetStillAtLocation" BOOLEAN NOT NULL DEFAULT true,
    "finderId" TEXT,

    CONSTRAINT "LostFoundReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LostFoundImage" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "storageKey" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LostFoundImage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "LostFoundReport_status_idx" ON "LostFoundReport"("status");

-- CreateIndex
CREATE INDEX "LostFoundReport_species_idx" ON "LostFoundReport"("species");

-- CreateIndex
CREATE INDEX "LostFoundReport_ownerId_idx" ON "LostFoundReport"("ownerId");

-- CreateIndex
CREATE INDEX "LostFoundReport_finderId_idx" ON "LostFoundReport"("finderId");

-- CreateIndex
CREATE INDEX "LostFoundReport_createdAt_idx" ON "LostFoundReport"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "LostFoundImage_storageKey_key" ON "LostFoundImage"("storageKey");

-- CreateIndex
CREATE INDEX "LostFoundImage_reportId_idx" ON "LostFoundImage"("reportId");

-- AddForeignKey
ALTER TABLE "LostFoundReport" ADD CONSTRAINT "LostFoundReport_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LostFoundReport" ADD CONSTRAINT "LostFoundReport_finderId_fkey" FOREIGN KEY ("finderId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LostFoundImage" ADD CONSTRAINT "LostFoundImage_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "LostFoundReport"("id") ON DELETE CASCADE ON UPDATE CASCADE;
