/*
  Warnings:

  - A unique constraint covering the columns `[memberId,feeId]` on the table `MemberFeeAssignment` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "public"."MemberFeeAssignment_memberId_key";

-- CreateIndex
CREATE UNIQUE INDEX "MemberFeeAssignment_memberId_feeId_key" ON "MemberFeeAssignment"("memberId", "feeId");
