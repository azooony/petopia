import prisma from './prisma' //changed from import {prisma} from './prisma'

async function testDB() {
  try {
    await prisma.$connect()
    console.log("✅ Database connected successfully")
  } catch (error) {
    console.error("❌ Connection failed:", error)
  } finally {
    await prisma.$disconnect()
  }
}

testDB()