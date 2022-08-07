import { expect } from "chai";

export function shouldBehaveLikePoem(): void {
  describe("Poem Minting Requirements", function () {
    it("doesn't allow minting if you've done so before", async function () {
      await this.poem.connect(this.signers.admin).mint();
      await expect(this.poem.connect(this.signers.admin).mint()).to.be.revertedWith("You can only mint 1 token.");
    });

    it("doesn't allow minting if you already hold three tokens", async function () {
      await this.poem.connect(this.signers.admin).mint();
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      await this.poem.connect(this.signers.others[0]).mint();
      this.poem
        .connect(this.signers.others[0])
        .transferFrom(this.signers.others[0].address, this.signers.user.address, 1);
      await this.poem.connect(this.signers.others[1]).mint();
      this.poem
        .connect(this.signers.others[1])
        .transferFrom(this.signers.others[1].address, this.signers.user.address, 2);

      await expect(this.poem.connect(this.signers.user).mint()).to.be.revertedWith(
        "One can hold max 3 tokens at a time.",
      );
    });

    it("doesn't allow minting if it's out of tokens", async function () {
      const maxNum = await this.poem.connect(this.signers.admin).MAX_NUM_NFTS();
      for (let i = 0; i < maxNum; i++) {
        await this.poem.connect(this.signers.others[i]).mint();
      }
      await expect(this.poem.connect(this.signers.user).mint()).to.be.revertedWith("Out of tokens.");
    });

    it("allows minting if all conditions are met", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.admin.address)).to.equal(1);
    });

    it("on mint, update pseudoRandomNumber", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).getPsuedoRandomNumber()).to.not.equal(1);
    });

    it("on mint, update ownership", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.admin.address)).to.equal(1);
      await this.poem.connect(this.signers.user).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.user.address)).to.equal(1);
    });

    it("on mint, update owner count", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.admin.address)).to.equal(1);
      await this.poem.connect(this.signers.user).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.user.address)).to.equal(1);
    });

    it("on mint, update transfer timestamp", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.admin.address)).to.equal(1);
    });
  });

  describe("Poem Transfer requirements", function () {
    it("on transfer, update pseudoRandomNumber", async function () {
      await this.poem.connect(this.signers.admin).mint();
      const oldPseudoRandomNumber = await this.poem.connect(this.signers.admin).getPsuedoRandomNumber();
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.admin).getPsuedoRandomNumber()).to.not.equal(oldPseudoRandomNumber);
    });

    it("on transfer, update transfer timestamp", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.user.address)).to.equal(0);

      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.user.address)).to.equal(2);
    });

    it("on transfer, update ownership", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.admin.address)).to.equal(1);
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.admin.address)).to.equal(0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.user.address)).to.equal(1);
    });

    it("on transfer, update owner count", async function () {
      // TODO
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.admin.address)).to.equal(1);
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.admin.address)).to.equal(0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.user.address)).to.equal(1);
    });

    it("doesn't allow transfer if receiver already hold three tokens", async function () {
      await this.poem.connect(this.signers.admin).mint();
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);

      await this.poem.connect(this.signers.others[0]).mint();
      this.poem
        .connect(this.signers.others[0])
        .transferFrom(this.signers.others[0].address, this.signers.user.address, 1);

      await this.poem.connect(this.signers.others[1]).mint();
      this.poem
        .connect(this.signers.others[1])
        .transferFrom(this.signers.others[1].address, this.signers.user.address, 2);

      await this.poem.connect(this.signers.others[2]).mint();
      expect(
        await this.poem
          .connect(this.signers.others[2])
          .transferFrom(this.signers.others[2].address, this.signers.user.address, 3),
      ).to.be.revertedWith("One can hold max 3 tokens at a time.");
    });
  });

  describe("Poem Burn requirements", function () {
    it("on burn, update ownership", async function () {
      await this.poem.connect(this.signers.admin).mint();
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.admin.address)).to.equal(0);
    });

    it("on burn, update pseudoRandomNumber", async function () {
      await this.poem.connect(this.signers.admin).mint();
      const num = await this.poem.connect(this.signers.admin).getPsuedoRandomNumber();
      expect(num).to.not.equal(1);
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.connect(this.signers.admin).getPsuedoRandomNumber()).to.not.equal(num);
    });

    it("on burn, update currStep and path", async function () {
      await this.poem.connect(this.signers.admin).initialize();
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(0);
      expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
      for (let i = 1; i < 8; i++) {
        expect(await this.poem.connect(this.signers.admin).path(i)).to.equal(0);
      }
      expect(await this.poem.connect(this.signers.admin).path(8)).to.equal(25);
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).path(1)).to.be.oneOf([2, 3]);
      for (let i = 2; i < 8; i++) {
        expect(await this.poem.connect(this.signers.admin).path(i)).to.equal(0);
      }
      expect(await this.poem.connect(this.signers.admin).path(8)).to.equal(25);
    });
  });

  describe("Poem Pseudorandom number adjuster", function () {});
  describe("Poem multiple transfers in a row", function () {
    it("transferring multiple times properly updates owner count");
    it("transferring multiple times properly updates block timestamp");
  });
  describe("Poem opacityLevel", function () {
    it("opacityLevel can handle an extremely large numBlocksHeld");
    it("opacityLevel returns the correct value for all levels");
  });
  describe("Poem jitterLevel", function () {
    it("jitterLevel can handle extremely large numOwners");
    it("jitterLevel properly accounts for the number of owners");
    it("jitterLevel properly accounts for currStep");
  });
  describe("Poem getCurrIndex", function () {
    it("getCurrIndex works when currIndex is non-0");
    it("getCurrIndex works when currIndex is 0 and last step is 1 away");
    it("getCurrIndex works when currIndex is 0 and last step is 2 away");
    it("getCurrIndex works when currIndex is 0 and last step is 3 away");
    it("getCurrIndex works when currIndex is 0 and last step is 4 away");
    it("getCurrIndex works when currIndex is 0 and last step is 5 away");
    it("getCurrIndex works when currIndex is 0 and last step is 6 away");
    it("getCurrIndex works when currIndex is 0 and last step is 7 away");
  });
  describe("Poem takeNextStep", function () {
    it("takeNextStep");
  });

  describe("Poem testing distributions", function () {
    const randomBinaryString = (length: number) => {
      // Declare all characters
      let chars = "01";

      // Pick characers randomly
      let str = "0b";
      for (let i = 0; i < length; i++) {
        str += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      return str;
    };

    it("calculate distribution of newHistoricalInput", async function () {
      // for (let i=0; i<3000; i++) {
      console.log(`let's do this 2`);
      const historicalInputs = [];
      const difficulties = [];
      const blockNumbers = [];
      const froms = [];
      const tos = [];

      let historicalInput = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      ];
      let difficulty = BigInt(randomBinaryString(256));
      let blockNumber = BigInt(randomBinaryString(256));

      // historicalInputs.push(JSON.stringify({x:blockNumber, y:1}));
      // difficulties.push(JSON.stringify({x:blockNumber, y:difficulty}));
      // blockNumbers.push(JSON.stringify({x:0, y:blockNumber}));

      for (let k = 0; k < 3000; k++) {
        if (k % 100 == 0) {
          console.log(`subtest ${k}`);
        }
        const from = BigInt(randomBinaryString(256));
        const to = BigInt(randomBinaryString(256));
        // froms.push(JSON.stringify({x:blockNumber, y:from}));
        // tos.push(JSON.stringify({x:blockNumber, y:to}));

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

        // historicalInputs.push(JSON.stringify({x:blockNumber, y:historicalInput}));
        // difficulties.push(JSON.stringify({x:blockNumber, y:difficulty}));
        // blockNumbers.push(JSON.stringify({x: k+1, y:blockNumber}));
      }

      // console.log(`historicalInputs: ${historicalInputs}\n`);
      // console.log(`difficulties: ${difficulties}\n`);
      // console.log(`blockNumbers: ${blockNumbers}\n`);
      // console.log(`froms: ${froms}\n`);
      // console.log(`tos: ${tos}\n`);
      // }
    });

    it("calculate distribution of getCurrIndex");
    it("calculate distribution of takeNextStep");
  });
}
