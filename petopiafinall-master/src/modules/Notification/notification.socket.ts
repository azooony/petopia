import { Server } from 'socket.io';

/** Must match the room name used in socket.ts after JWT auth. */
export function userNotificationRoom(userId: string): string {
  return `user:${userId}`;
}

export class NotificationGateway {

  private static io: Server | null = null;

  static initialize(io: Server): void {
    this.io = io;
  }

  static emitToUser(
    userId: string,
    event: string,
    payload: unknown,
  ): void {
    if (!this.io) {
      return;
    }

    this.io.to(userNotificationRoom(userId)).emit(event, payload);
  }
}
