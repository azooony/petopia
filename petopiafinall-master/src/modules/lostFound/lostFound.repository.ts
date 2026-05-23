import prisma from "../../config/prisma";
import { LostFoundStatus, PetType, Gender } from "../../../generated/prisma";

export interface CreateLostReportData {
  ownerId:         string;
  species:         PetType;
  description:     string;
  lastSeenLocation: string;
  lastSeenDate:    Date;
  name?:           string;
  breed?:          string;
  gender?:         Gender;
  color?:          string;
  imageUrls:       string[];
}

export interface CreateFoundReportData {
  finderId:             string;
  species:              PetType;
  description:          string;
  foundLocation:        string;
  isPetStillAtLocation: boolean;
  breed?:               string;
  gender?:              Gender;
  color?:               string;
  imageUrls:            string[];
}

const reportInclude = {
  images: true,
  owner:  { select: { id: true, fullName: true, email: true } },
  finder: { select: { id: true, fullName: true, email: true } },
} as const;

export class LostFoundRepository {
  static async createLostReport(data: CreateLostReportData) {
    return prisma.lostFoundReport.create({
      data: {
        status:          LostFoundStatus.LOST,
        species:         data.species,
        description:     data.description,
        lastSeenLocation: data.lastSeenLocation,
        lastSeenDate:    data.lastSeenDate,
        name:            data.name   ?? null,
        breed:           data.breed  ?? null,
        gender:          data.gender ?? null,
        color:           data.color  ?? null,
        ownerId:         data.ownerId,
        images: {
          create: data.imageUrls.map((url) => ({ url })),
        },
      },
      include: reportInclude,
    });
  }

  static async createFoundReport(data: CreateFoundReportData) {
    return prisma.lostFoundReport.create({
      data: {
        status:               LostFoundStatus.FOUND,
        species:              data.species,
        description:          data.description,
        foundLocation:        data.foundLocation,
        isPetStillAtLocation: data.isPetStillAtLocation,
        breed:                data.breed  ?? null,
        gender:               data.gender ?? null,
        color:                data.color  ?? null,
        finderId:             data.finderId,
        images: {
          create: data.imageUrls.map((url) => ({ url })),
        },
      },
      include: reportInclude,
    });
  }

  static async getLostReports() {
    return prisma.lostFoundReport.findMany({
      where:   { status: LostFoundStatus.LOST },
      include: reportInclude,
      orderBy: { createdAt: "desc" },
    });
  }

  static async getFoundReports() {
    return prisma.lostFoundReport.findMany({
      where:   { status: LostFoundStatus.FOUND },
      include: reportInclude,
      orderBy: { createdAt: "desc" },
    });
  }

  static async getReportById(id: string) {
    return prisma.lostFoundReport.findUnique({
      where:   { id },
      include: reportInclude,
    });
  }

  static async deleteFoundReport(id: string, finderId: string) {
    return prisma.lostFoundReport.deleteMany({
      where: { id, finderId, status: LostFoundStatus.FOUND },
    });
  }
}
