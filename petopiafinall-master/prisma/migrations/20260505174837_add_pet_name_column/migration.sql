/*
  Warnings:

  - You are about to drop the column `Price` on the `Appointment` table. All the data in the column will be lost.
  - Added the required column `price` to the `Appointment` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "SitterVerificationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "SittingBookingStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED', 'COMPLETED');

-- AlterTable
ALTER TABLE "Appointment" DROP COLUMN "Price",
ADD COLUMN     "price" DOUBLE PRECISION NOT NULL;

-- AlterTable
ALTER TABLE "VetProfile" ADD COLUMN     "appointmentPrice" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "endTime" TEXT NOT NULL DEFAULT '17:00',
ADD COLUMN     "firstName" TEXT,
ADD COLUMN     "photo" TEXT,
ADD COLUMN     "specialization" TEXT,
ADD COLUMN     "startTime" TEXT NOT NULL DEFAULT '09:00',
ADD COLUMN     "surname" TEXT;

-- CreateTable
CREATE TABLE "SitterProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bio" TEXT,
    "supportedPetTypes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "maxPets" INTEGER NOT NULL DEFAULT 3,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "emergencyContact" TEXT NOT NULL,
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,
    "ratingAverage" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalReviews" INTEGER NOT NULL DEFAULT 0,
    "verificationStatus" "SitterVerificationStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SitterProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterImage" (
    "id" TEXT NOT NULL,
    "sitterProfileId" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "storageKey" TEXT NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "uploadedById" TEXT NOT NULL,

    CONSTRAINT "SitterImage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterAvailability" (
    "id" TEXT NOT NULL,
    "sitterProfileId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SitterAvailability_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SittingBooking" (
    "id" TEXT NOT NULL,
    "sitterProfileId" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "petOwnerId" TEXT NOT NULL,
    "petId" TEXT NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "totalDays" INTEGER NOT NULL,
    "ownerNotes" TEXT,
    "emergencyPhone" TEXT NOT NULL,
    "status" "SittingBookingStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SittingBooking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterReview" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "sitterProfileId" TEXT NOT NULL,
    "reviewerUserId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SitterReview_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "SitterProfile_userId_key" ON "SitterProfile"("userId");

-- CreateIndex
CREATE INDEX "SitterProfile_userId_idx" ON "SitterProfile"("userId");

-- CreateIndex
CREATE INDEX "SitterProfile_verificationStatus_idx" ON "SitterProfile"("verificationStatus");

-- CreateIndex
CREATE INDEX "SitterProfile_city_idx" ON "SitterProfile"("city");

-- CreateIndex
CREATE INDEX "SitterProfile_ratingAverage_idx" ON "SitterProfile"("ratingAverage");

-- CreateIndex
CREATE UNIQUE INDEX "SitterImage_storageKey_key" ON "SitterImage"("storageKey");

-- CreateIndex
CREATE INDEX "SitterImage_sitterProfileId_idx" ON "SitterImage"("sitterProfileId");

-- CreateIndex
CREATE INDEX "SitterImage_uploadedById_idx" ON "SitterImage"("uploadedById");

-- CreateIndex
CREATE INDEX "SitterAvailability_sitterProfileId_startDate_idx" ON "SitterAvailability"("sitterProfileId", "startDate");

-- CreateIndex
CREATE INDEX "SitterAvailability_userId_startDate_idx" ON "SitterAvailability"("userId", "startDate");

-- CreateIndex
CREATE INDEX "SittingBooking_sitterProfileId_startDate_idx" ON "SittingBooking"("sitterProfileId", "startDate");

-- CreateIndex
CREATE INDEX "SittingBooking_petOwnerId_startDate_idx" ON "SittingBooking"("petOwnerId", "startDate");

-- CreateIndex
CREATE INDEX "SittingBooking_sitterId_startDate_idx" ON "SittingBooking"("sitterId", "startDate");

-- CreateIndex
CREATE INDEX "SittingBooking_status_idx" ON "SittingBooking"("status");

-- CreateIndex
CREATE UNIQUE INDEX "SitterReview_bookingId_key" ON "SitterReview"("bookingId");

-- CreateIndex
CREATE INDEX "SitterReview_sitterProfileId_idx" ON "SitterReview"("sitterProfileId");

-- CreateIndex
CREATE INDEX "SitterReview_reviewerUserId_idx" ON "SitterReview"("reviewerUserId");

-- AddForeignKey
ALTER TABLE "SitterProfile" ADD CONSTRAINT "SitterProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterImage" ADD CONSTRAINT "SitterImage_sitterProfileId_fkey" FOREIGN KEY ("sitterProfileId") REFERENCES "SitterProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterImage" ADD CONSTRAINT "SitterImage_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterAvailability" ADD CONSTRAINT "SitterAvailability_sitterProfileId_fkey" FOREIGN KEY ("sitterProfileId") REFERENCES "SitterProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterAvailability" ADD CONSTRAINT "SitterAvailability_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SittingBooking" ADD CONSTRAINT "SittingBooking_sitterProfileId_fkey" FOREIGN KEY ("sitterProfileId") REFERENCES "SitterProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SittingBooking" ADD CONSTRAINT "SittingBooking_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SittingBooking" ADD CONSTRAINT "SittingBooking_petOwnerId_fkey" FOREIGN KEY ("petOwnerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SittingBooking" ADD CONSTRAINT "SittingBooking_petId_fkey" FOREIGN KEY ("petId") REFERENCES "Pet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterReview" ADD CONSTRAINT "SitterReview_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "SittingBooking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterReview" ADD CONSTRAINT "SitterReview_sitterProfileId_fkey" FOREIGN KEY ("sitterProfileId") REFERENCES "SitterProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterReview" ADD CONSTRAINT "SitterReview_reviewerUserId_fkey" FOREIGN KEY ("reviewerUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
