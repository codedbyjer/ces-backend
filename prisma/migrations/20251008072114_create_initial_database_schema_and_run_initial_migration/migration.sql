-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('ORG_ADMIN', 'FINANCE_OFFICER');

-- CreateEnum
CREATE TYPE "FeeType" AS ENUM ('MANDATORY', 'OPTIONAL');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "User" (
    "userId" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "Member" (
    "memberId" SERIAL NOT NULL,
    "studentNo" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "mobile" TEXT,
    "course" TEXT NOT NULL,
    "section" TEXT NOT NULL,
    "yearLevel" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Member_pkey" PRIMARY KEY ("memberId")
);

-- CreateTable
CREATE TABLE "Fee" (
    "feeId" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "amount" MONEY NOT NULL,
    "type" "FeeType" NOT NULL,
    "dueDate" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdBy" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Fee_pkey" PRIMARY KEY ("feeId")
);

-- CreateTable
CREATE TABLE "MemberFeeAssignment" (
    "assignmentId" SERIAL NOT NULL,
    "memberId" INTEGER NOT NULL,
    "feeId" INTEGER NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isPaid" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "MemberFeeAssignment_pkey" PRIMARY KEY ("assignmentId")
);

-- CreateTable
CREATE TABLE "Payment" (
    "paymentId" SERIAL NOT NULL,
    "memberId" INTEGER NOT NULL,
    "feeId" INTEGER NOT NULL,
    "amountPaid" MONEY NOT NULL,
    "proofImageUrl" TEXT NOT NULL,
    "gcashRefNumber" TEXT,
    "paymentDate" TIMESTAMP(3) NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedBy" INTEGER,
    "reviewedAt" TIMESTAMP(3),
    "rejectionReason" TEXT,
    "verificationNotes" TEXT,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("paymentId")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "tokenId" SERIAL NOT NULL,
    "token" TEXT NOT NULL,
    "userId" INTEGER,
    "memberId" INTEGER,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("tokenId")
);

-- CreateTable
CREATE TABLE "SystemSettings" (
    "settingsId" SERIAL NOT NULL,
    "gcashNumber" INTEGER NOT NULL,
    "gcashName" TEXT NOT NULL,
    "orgName" TEXT NOT NULL DEFAULT 'Computer Explorer Society',
    "orgEmail" TEXT,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "updatedBy" INTEGER,

    CONSTRAINT "SystemSettings_pkey" PRIMARY KEY ("settingsId")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_email_idx" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_role_isActive_idx" ON "User"("role", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "Member_email_key" ON "Member"("email");

-- CreateIndex
CREATE INDEX "Member_studentNo_idx" ON "Member"("studentNo");

-- CreateIndex
CREATE INDEX "Member_email_idx" ON "Member"("email");

-- CreateIndex
CREATE INDEX "Member_course_idx" ON "Member"("course");

-- CreateIndex
CREATE INDEX "Member_section_idx" ON "Member"("section");

-- CreateIndex
CREATE INDEX "Member_yearLevel_idx" ON "Member"("yearLevel");

-- CreateIndex
CREATE INDEX "Member_course_yearLevel_idx" ON "Member"("course", "yearLevel");

-- CreateIndex
CREATE INDEX "Member_isActive_idx" ON "Member"("isActive");

-- CreateIndex
CREATE INDEX "Fee_type_isActive_idx" ON "Fee"("type", "isActive");

-- CreateIndex
CREATE INDEX "Fee_dueDate_idx" ON "Fee"("dueDate");

-- CreateIndex
CREATE INDEX "Fee_createdBy_idx" ON "Fee"("createdBy");

-- CreateIndex
CREATE INDEX "MemberFeeAssignment_memberId_isPaid_idx" ON "MemberFeeAssignment"("memberId", "isPaid");

-- CreateIndex
CREATE INDEX "MemberFeeAssignment_feeId_isPaid_idx" ON "MemberFeeAssignment"("feeId", "isPaid");

-- CreateIndex
CREATE UNIQUE INDEX "MemberFeeAssignment_memberId_key" ON "MemberFeeAssignment"("memberId");

-- CreateIndex
CREATE INDEX "Payment_memberId_status_idx" ON "Payment"("memberId", "status");

-- CreateIndex
CREATE INDEX "Payment_feeId_status_idx" ON "Payment"("feeId", "status");

-- CreateIndex
CREATE INDEX "Payment_status_submittedAt_idx" ON "Payment"("status", "submittedAt");

-- CreateIndex
CREATE INDEX "Payment_reviewedBy_idx" ON "Payment"("reviewedBy");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_token_key" ON "RefreshToken"("token");

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "RefreshToken"("userId");

-- CreateIndex
CREATE INDEX "RefreshToken_memberId_idx" ON "RefreshToken"("memberId");

-- CreateIndex
CREATE INDEX "RefreshToken_revoked_expiresAt_idx" ON "RefreshToken"("revoked", "expiresAt");

-- AddForeignKey
ALTER TABLE "Fee" ADD CONSTRAINT "Fee_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("userId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MemberFeeAssignment" ADD CONSTRAINT "MemberFeeAssignment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "Member"("memberId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MemberFeeAssignment" ADD CONSTRAINT "MemberFeeAssignment_feeId_fkey" FOREIGN KEY ("feeId") REFERENCES "Fee"("feeId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "Member"("memberId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_feeId_fkey" FOREIGN KEY ("feeId") REFERENCES "Fee"("feeId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_reviewedBy_fkey" FOREIGN KEY ("reviewedBy") REFERENCES "User"("userId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("userId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "Member"("memberId") ON DELETE SET NULL ON UPDATE CASCADE;
