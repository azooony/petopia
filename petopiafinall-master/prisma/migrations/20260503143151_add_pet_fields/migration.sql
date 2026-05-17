/*
  Warnings:

  - Added the required column `age` to the `Pet` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name` to the `Pet` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Pet" ADD COLUMN     "age" INTEGER NOT NULL,
ADD COLUMN     "breed" TEXT,
ADD COLUMN     "gender" "Gender",
ADD COLUMN     "name" TEXT NOT NULL;
