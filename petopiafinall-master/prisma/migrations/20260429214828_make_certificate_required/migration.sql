/*
  Warnings:

  - Made the column `certificateImage` on table `VetProfile` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "VetProfile" ALTER COLUMN "certificateImage" SET NOT NULL;
