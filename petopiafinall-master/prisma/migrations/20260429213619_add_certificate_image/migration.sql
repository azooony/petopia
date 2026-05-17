/*
  Warnings:

  - You are about to drop the column `certificateUrl` on the `VetProfile` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "VetProfile" DROP COLUMN "certificateUrl",
ADD COLUMN     "certificateImage" TEXT;
