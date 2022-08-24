import { simulateContractLifecycle } from "./Poem";

export function shouldStressWithoutProblems(): void {
  describe("Poem stress tests", function () {
    const randomBinaryString = (length: number) => {
      // Declare all characters
      const chars = "01";

      // Pick characers randomly
      let str = "0b";
      for (let i = 0; i < length; i++) {
        str += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      return str;
    };

    it("simulate newHistoricalInput updates", async function () {
      let historicalInput = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      ];
      let difficulty = BigInt(randomBinaryString(256));
      let blockNumber = BigInt(randomBinaryString(256));
      for (let k = 0; k < 1000; k++) {
        const from = BigInt(randomBinaryString(256));
        const to = BigInt(randomBinaryString(256));
        historicalInput = await this.poem
          .connect(this.signers.admin)
          .newHistoricalInput(historicalInput, from, to, difficulty, blockNumber);
        // Move ahead by max 90ish days
        blockNumber += BigInt(randomBinaryString(19));
        // Adjust difficulty every 100-200 blocks by a semi-random amount
        if (k % 3 == 0) {
          difficulty += BigInt(randomBinaryString(100));
        }
        if (k % 7 == 0) {
          difficulty -= BigInt(randomBinaryString(100));
        }
      }
    });

    it("simulate getCurrIndex updates");
    it("simulate takeNextStep updates");

    simulateContractLifecycle(1, 400, false);
  });
}
