/** Run a notification without failing the parent business operation. */
export function fireNotification(task: Promise<unknown>): void {
  void task.catch(() => {});
}
