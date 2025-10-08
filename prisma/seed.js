const { PrismaClient } = require('../generated/prisma');
const bcrypt = require('bcrypt');
const { faker, tr } = require('@faker-js/faker');

const prisma = new PrismaClient();

const BCRYPT_ROUNDS = 10;

const generatePhilMobileNo = () => {
    const randomDigits = Math.floor(Math.random() * 1000000000).toString().padStart(9, '0');
    return `09${randomDigits}`;
}

async function runSeeder() {
    console.log('Starting database seeding...');

    await prisma.memberFeeAssignment.deleteMany();
    await prisma.payment.deleteMany();
    await prisma.fee.deleteMany();
    await prisma.member.deleteMany();
    await prisma.refreshToken.deleteMany();
    await prisma.systemSettings.deleteMany();
    await prisma.user.deleteMany();

    console.log('Cleared existing data.')

    //create org admin
    const adminPassword = await bcrypt.hash('admin123', BCRYPT_ROUNDS);
    const admin = await prisma.user.create({
        data: {
            email: 'admin@ces.com',
            password: adminPassword,
            firstName: 'James',
            lastName: 'Lincoln',
            role: 'ORG_ADMIN',
            isActive: true
        }
    });
    console.log('Created admin:', admin.email, '/ admin123')

    const officerPassword = await bcrypt.hash('officer123', BCRYPT_ROUNDS);
    const officer = await prisma.user.create({
        data: {
            email: 'finance@ces.com',
            password: officerPassword,
            firstName: 'Lebron',
            lastName: 'James',
            role: 'FINANCE_OFFICER',
            isActive: true
        }

    });
    console.log('Created finance officer', officer.email, '/ officer123');

    const courses = ['BSCS', 'BSIT', 'BSCE'];
    const sections = ['LFAU122A902', 'LFAU1322N002', 'OLAU222M023'];
    const yearLevels = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];
    const yearLevelsNo = [1, 2, 3, 4]
    const members = [];

    for (let i = 1; i <= 50; i++) {
        const yearLevelNo = faker.helpers.arrayElement(yearLevelsNo);
        const yearLevel = faker.helpers.arrayElement(yearLevels);
        const course = faker.helpers.arrayElement(courses);
        const section = faker.helpers.arrayElement(sections);
        const studentNo = `UA${2024 - yearLevelNo + 1}${String(i).padStart(5, '0')}`;
        const password = await bcrypt.hash('member123', BCRYPT_ROUNDS);

        const member = await prisma.member.create({
            data: {
                studentNo: studentNo,
                password: password,
                firstName: faker.person.firstName(),
                lastName: faker.person.lastName(),
                email: faker.internet.email().toLowerCase(),
                mobile: generatePhilMobileNo(),
                course: course,
                section: section,
                yearLevel: yearLevel,
                isActive: true
            }
        });

        members.push(member);
    }
    console.log(`Created ${members.length} members.`);

    await prisma.systemSettings.create({
        data: {
            gcashNumber: '09129305678',
            gcashName: 'CES Gcash',
            orgName: 'Computer Explorer Society',
            orgEmail: 'contact@ces.com'
        }
    });

    console.log('Created system settings.')

    const membershipFee = await prisma.fee.create({
        data: {
            title: 'Membership Fee 20251',
            description: 'Every semester membership for CES',
            amount: 20.00,
            type: 'MANDATORY',
            dueDate: new Date('2025-12-31'),
            isActive: true,
            createdBy: admin.userId
        }
    });


    const seminarFee = await prisma.fee.create({
        data: {
            title: 'Web Develooment Workshop 2025',
            description: 'Web development seminar',
            amount: 50.00,
            type: 'OPTIONAL',
            dueDate: new Date('2025-11-25'),
            isActive: true,
            createdBy: admin.userId
        }
    });

    const shirtFee = await prisma.fee.create({
        data: {
            title: 'Organization Shirt',
            description: 'Official Shirt of CES',
            amount: 350.00,
            type: 'OPTIONAL',
            dueDate: null,
            isActive: true,
            createdBy: admin.userId
        }
    });

    console.log('Created 3 fees.');

    for (const member of members) {
        await prisma.memberFeeAssignment.create({
            data: {
                memberId: member.memberId,
                feeId: membershipFee.feeId,
                isPaid: false
            }
        })
    }
    console.log('Assigned membership fee to all 50 members.');

    const bscsMembers = members.filter(m => m.course === 'BSCS')
    for (const member of bscsMembers) {
        await prisma.memberFeeAssignment.create({
            data: {
                memberId: member.memberId,
                feeId: seminarFee.feeId,
                isPaid: false
            }
        });
    }
    console.log(`Assigned seminar fee to ${bscsMembers.length} BSCS members.`);

    const thirdYearMembers = members.filter(m => m.yearLevel === 'Third Year');
    for (const member of thirdYearMembers) {
        await prisma.memberFeeAssignment.create({
            data: {
                memberId: member.memberId,
                feeId: shirtFee.feeId,
                isPaid: false
            }
        })
    }

    console.log(`Assigned shirt fee to ${thirdYearMembers.length} 3rd year members.`);

    console.log('\n=== Seeding completed successfully! ===\n');
    console.log('Test Accounts:');
    console.log('Admin: admin@ces.com / admin123');
    console.log('Finance: finance@ces.com / officer123');
    console.log('Members: Use any studentNo (e.g UA202400001) / member123');
}

runSeeder()
    .catch((e) => {
        console.log(`Error seeding database:  ${e}`);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    })