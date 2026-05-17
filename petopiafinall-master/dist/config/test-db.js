"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const prisma_1 = __importDefault(require("./prisma")); //changed from import {prisma} from './prisma'
async function testDB() {
    try {
        await prisma_1.default.$connect();
        console.log("✅ Database connected successfully");
    }
    catch (error) {
        console.error("❌ Connection failed:", error);
    }
    finally {
        await prisma_1.default.$disconnect();
    }
}
testDB();
//# sourceMappingURL=test-db.js.map