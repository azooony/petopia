export interface RegisterVetDto {
    phone: string;
    yearsOfExperience: number | string;
    appointmentPrice?: number | string;
    startTime?: string;
    endTime?: string;
    clinicId: string;
    certificateUrl: string;
}
export interface UpdateVetProfileDto {
    photo?: string;
    firstName?: string;
    surname?: string;
    email?: string;
    phone?: string;
    specialization?: string;
    description?: string;
    yearsOfExperience?: number | string;
    appointmentPrice?: number | string;
    startTime?: string;
    endTime?: string;
    clinicAddress?: string;
}
export interface AddAvailabilitySlotDto {
    startTime: string;
    endTime: string;
    clinicId?: string;
}
export interface UpdateAvailabilitySlotDto {
    startTime?: string;
    endTime?: string;
    isActive?: boolean;
}
//# sourceMappingURL=vets.dto.d.ts.map