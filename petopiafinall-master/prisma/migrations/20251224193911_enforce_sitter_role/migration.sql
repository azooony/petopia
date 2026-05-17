/*
  Warnings:

  - You are about to drop the column `isVerified` on the `VetProfile` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[ownerId]` on the table `Pet` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "public"."Pet" DROP CONSTRAINT "Pet_ownerId_fkey";

-- AlterTable
ALTER TABLE "VetProfile" DROP COLUMN "isVerified",
ADD COLUMN     "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'PENDING';

-- CreateIndex
CREATE UNIQUE INDEX "Pet_ownerId_key" ON "Pet"("ownerId");

-- AddForeignKey
ALTER TABLE "Pet" ADD CONSTRAINT "Pet_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
-- Create a function to check if user is a PET_OWNER
CREATE OR REPLACE FUNCTION check_sitter_is_pet_owner()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM "User"
    WHERE id = NEW."sitterId" AND role = 'PET_OWNER'
  ) THEN
    RAISE EXCEPTION 'Only users with PET_OWNER role can create sitting listings';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on Services table
CREATE TRIGGER enforce_sitter_role_trigger
BEFORE INSERT OR UPDATE ON "Services"
FOR EACH ROW
EXECUTE FUNCTION check_sitter_is_pet_owner();
