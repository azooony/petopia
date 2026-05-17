/*
  Warnings:

  - You are about to drop the column `idCardImage` on the `SitterProfile` table. All the data in the column will be lost.
  - Added the required column `IdCardImage` to the `SitterProfile` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "SitterProfile" DROP COLUMN "idCardImage",
ADD COLUMN     "IdCardImage" TEXT NOT NULL;
