// src/modules/vets/vets.dto.ts

// ── Registration ──────────────────────────────────────────────
export interface RegisterVetDto {
  phone: string;
  yearsOfExperience: number | string;
  appointmentPrice?: number | string;
  startTime?: string;
  endTime?: string;
  clinicId: string;
  certificateUrl: string;          // URL to the uploaded certificate image
}

// ── Profile Setup / Update ────────────────────────────────────
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

// ── Availability Slots ────────────────────────────────────────
export interface AddAvailabilitySlotDto {
  startTime: string;               // ISO-8601 datetime string
  endTime: string;                 // ISO-8601 datetime string
  clinicId?: string;
}

export interface UpdateAvailabilitySlotDto {
  startTime?: string;
  endTime?: string;
  isActive?: boolean;
}
