/*
  Warnings:

  - You are about to drop the column `sittingBookingId` on the `Payment` table. All the data in the column will be lost.
  - You are about to drop the column `uploadedById` on the `SitterImage` table. All the data in the column will be lost.
  - You are about to drop the `PetSitting` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Services` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Payment" DROP CONSTRAINT "Payment_sittingBookingId_fkey";

-- DropForeignKey
ALTER TABLE "PetSitterImage" DROP CONSTRAINT "PetSitterImage_serviceId_fkey";

-- DropForeignKey
ALTER TABLE "PetSitting" DROP CONSTRAINT "PetSitting_listingId_fkey";

-- DropForeignKey
ALTER TABLE "PetSitting" DROP CONSTRAINT "PetSitting_petId_fkey";

-- DropForeignKey
ALTER TABLE "PetSitting" DROP CONSTRAINT "PetSitting_petOwnerId_fkey";

-- DropForeignKey
ALTER TABLE "Services" DROP CONSTRAINT "Services_petid_fkey";

-- DropForeignKey
ALTER TABLE "Services" DROP CONSTRAINT "Services_sitterId_fkey";

-- DropForeignKey
ALTER TABLE "SitterAvailability" DROP CONSTRAINT "SitterAvailability_userId_fkey";

-- DropForeignKey
ALTER TABLE "SitterImage" DROP CONSTRAINT "SitterImage_uploadedById_fkey";

-- DropIndex
DROP INDEX "Payment_sittingBookingId_key";

-- DropIndex
DROP INDEX "SitterImage_uploadedById_idx";

-- AlterTable
ALTER TABLE "Payment" DROP COLUMN "sittingBookingId";

-- AlterTable
ALTER TABLE "SitterImage" DROP COLUMN "uploadedById";

-- AlterTable
ALTER TABLE "SitterProfile" ADD COLUMN     "idCardImage" TEXT;

-- DropTable
DROP TABLE "PetSitting";

-- DropTable
DROP TABLE "Services";
