import {
  NotificationEntityType,
  NotificationType,
} from '../../../generated/prisma';

import { NotificationService } from './notification.service';
import type { CreateNotificationInput } from './notification.types';

async function dispatch(params: CreateNotificationInput) {
  return NotificationService.send(params);
}

// ── Vet verification (admin approves / rejects certificates) ─────────────────

export async function notifyVetApproved(userId: string, vetProfileId: string) {
  return dispatch({
    userId,
    title: 'Certificate approved',
    body: 'Your vet account is verified. You can now set your clinic and availability.',
    type: NotificationType.VET_VERIFICATION,
    entityId: vetProfileId,
    entityType: NotificationEntityType.VET_PROFILE,
  });
}

export async function notifyVetRejected(userId: string, vetProfileId: string) {
  return dispatch({
    userId,
    title: 'Certificate rejected',
    body: 'Your registration was not approved. Contact support if you believe this is a mistake.',
    type: NotificationType.VET_VERIFICATION,
    entityId: vetProfileId,
    entityType: NotificationEntityType.VET_PROFILE,
  });
}

// ── Appointment payments (InstaPay invoice verified by admin) ────────────────

export async function notifyPaymentApproved(
  ownerId: string,
  paymentId: string,
  appointmentId: string,
) {
  return dispatch({
    userId: ownerId,
    title: 'Payment confirmed',
    body: 'Your appointment payment was verified. Your reservation is confirmed.',
    type: NotificationType.PAYMENT,
    entityId: paymentId,
    entityType: NotificationEntityType.PAYMENT,
  });
}

export async function notifyPaymentRejected(
  ownerId: string,
  paymentId: string,
  appointmentId: string,
) {
  return dispatch({
    userId: ownerId,
    title: 'Payment rejected',
    body: 'Your payment could not be verified. The appointment was cancelled.',
    type: NotificationType.PAYMENT,
    entityId: paymentId,
    entityType: NotificationEntityType.PAYMENT,
  });
}

export async function notifyAppointmentConfirmedForVet(
  vetUserId: string,
  appointmentId: string,
  petName?: string,
) {
  const petLabel = petName ? ` for ${petName}` : '';
  return dispatch({
    userId: vetUserId,
    title: 'New confirmed appointment',
    body: `A pet owner booked an appointment${petLabel}. Check your schedule.`,
    type: NotificationType.APPOINTMENT,
    entityId: appointmentId,
    entityType: NotificationEntityType.APPOINTMENT,
  });
}

export async function notifyAppointmentBookedPending(
  ownerId: string,
  appointmentId: string,
) {
  return dispatch({
    userId: ownerId,
    title: 'Appointment submitted',
    body: 'Your booking is pending payment verification by an admin.',
    type: NotificationType.APPOINTMENT,
    entityId: appointmentId,
    entityType: NotificationEntityType.APPOINTMENT,
  });
}

export async function notifyAppointmentCancelled(
  userId: string,
  appointmentId: string,
  reason?: string,
) {
  return dispatch({
    userId,
    title: 'Appointment cancelled',
    body: reason ?? 'An appointment was cancelled.',
    type: NotificationType.APPOINTMENT,
    entityId: appointmentId,
    entityType: NotificationEntityType.APPOINTMENT,
  });
}

// ── Pet sitting (admin approves sitter place + ID) ───────────────────────────

export async function notifySitterApproved(userId: string, sitterProfileId: string) {
  return dispatch({
    userId,
    title: 'Pet sitter approved',
    body: 'Your sitter profile was approved. Owners can now book you.',
    type: NotificationType.PET_SITTING,
    entityId: sitterProfileId,
  });
}

export async function notifySitterRejected(userId: string, sitterProfileId: string) {
  return dispatch({
    userId,
    title: 'Pet sitter rejected',
    body: 'Your sitter application was not approved. Update your photos and try again.',
    type: NotificationType.PET_SITTING,
    entityId: sitterProfileId,
  });
}

export async function notifySittingBookingRequested(
  sitterUserId: string,
  bookingId: string,
  petName?: string,
) {
  const petLabel = petName ?? 'a pet';
  return dispatch({
    userId: sitterUserId,
    title: 'New sitting request',
    body: `You received a sitting request for ${petLabel}.`,
    type: NotificationType.PET_SITTING,
    entityId: bookingId,
    entityType: NotificationEntityType.SITTING_BOOKING,
  });
}

export async function notifySittingBookingAccepted(
  ownerUserId: string,
  bookingId: string,
) {
  return dispatch({
    userId: ownerUserId,
    title: 'Sitting request accepted',
    body: 'Your pet sitter accepted the booking.',
    type: NotificationType.PET_SITTING,
    entityId: bookingId,
    entityType: NotificationEntityType.SITTING_BOOKING,
  });
}

export async function notifySittingBookingCancelled(
  userId: string,
  bookingId: string,
  reason?: string,
) {
  return dispatch({
    userId,
    title: 'Sitting booking cancelled',
    body: reason ?? 'A sitting booking was cancelled.',
    type: NotificationType.PET_SITTING,
    entityId: bookingId,
    entityType: NotificationEntityType.SITTING_BOOKING,
  });
}

export async function notifySittingBookingRejected(
  ownerUserId: string,
  bookingId: string,
) {
  return dispatch({
    userId: ownerUserId,
    title: 'Sitting request declined',
    body: 'The sitter declined your booking request.',
    type: NotificationType.PET_SITTING,
    entityId: bookingId,
    entityType: NotificationEntityType.SITTING_BOOKING,
  });
}

// ── Pet matching ─────────────────────────────────────────────────────────────

export async function notifyMatchRequestReceived(
  targetOwnerId: string,
  requestId: string,
  fromPetName?: string,
) {
  const petLabel = fromPetName ? `${fromPetName}` : 'another pet';
  return dispatch({
    userId: targetOwnerId,
    title: 'New match request',
    body: `${petLabel} wants to match with your pet.`,
    type: NotificationType.PET_MATCH,
    entityId: requestId,
    entityType: NotificationEntityType.MATCH_REQUEST,
  });
}

export async function notifyMatchAccepted(
  requesterOwnerId: string,
  requestId: string,
  toPetName?: string,
) {
  const petLabel = toPetName ? `${toPetName}'s owner` : 'A pet owner';
  return dispatch({
    userId: requesterOwnerId,
    title: 'Match accepted',
    body: `${petLabel} accepted your match request. You can chat now.`,
    type: NotificationType.PET_MATCH,
    entityId: requestId,
    entityType: NotificationEntityType.MATCH_REQUEST,
  });
}

// ── Chat ─────────────────────────────────────────────────────────────────────

export async function notifyNewChatMessage(
  recipientUserId: string,
  conversationId: string,
  senderName: string,
) {
  return dispatch({
    userId: recipientUserId,
    title: 'New message',
    body: `${senderName} sent you a message.`,
    type: NotificationType.CHAT,
    entityId: conversationId,
    entityType: NotificationEntityType.CONVERSATION,
  });
}

// ── Lost & found ─────────────────────────────────────────────────────────────

export async function notifyLostPetReported(
  ownerId: string,
  reportId: string,
  petName?: string,
) {
  const petLabel = petName ?? 'Your pet';
  return dispatch({
    userId: ownerId,
    title: 'Lost pet report submitted',
    body: `${petLabel} was reported as lost. Related bookings were cancelled.`,
    type: NotificationType.LOST_FOUND,
    entityId: reportId,
    entityType: NotificationEntityType.LOST_FOUND_REPORT,
  });
}

// ── Generic system messages ──────────────────────────────────────────────────

export async function notifySystem(userId: string, title: string, body: string) {
  return dispatch({
    userId,
    title,
    body,
    type: NotificationType.SYSTEM,
  });
}
