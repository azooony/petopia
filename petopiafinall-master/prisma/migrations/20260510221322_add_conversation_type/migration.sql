-- CreateEnum
CREATE TYPE "PetType" AS ENUM ('DOG', 'CAT');

-- CreateEnum
CREATE TYPE "ConversationType" AS ENUM ('MATCHING', 'SITTING');

-- AlterTable
ALTER TABLE "Conversation" ADD COLUMN     "type" "ConversationType" NOT NULL DEFAULT 'MATCHING';

-- AlterTable
ALTER TABLE "Pet" ADD COLUMN     "description" TEXT,
ADD COLUMN     "isAvailableForSitting" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "payRatePerDay" DOUBLE PRECISION,
ADD COLUMN     "petType" "PetType" NOT NULL DEFAULT 'DOG',
ADD COLUMN     "photo" TEXT,
ADD COLUMN     "sittingNotes" TEXT;

-- AlterTable
ALTER TABLE "SitterProfile" ADD COLUMN     "venuePhotoUrl" TEXT;
