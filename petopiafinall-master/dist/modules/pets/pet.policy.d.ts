import type { Pet } from "../../../generated/prisma";
export declare class PetPolicy {
    static ensureOwner(pet: Pet | null, userId: string): void;
}
//# sourceMappingURL=pet.policy.d.ts.map