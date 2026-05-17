-- CreateTable
CREATE TABLE "PetSitterImage" (
    "id" TEXT NOT NULL,
    "imagePath" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "serviceId" TEXT NOT NULL,

    CONSTRAINT "PetSitterImage_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "PetSitterImage" ADD CONSTRAINT "PetSitterImage_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
