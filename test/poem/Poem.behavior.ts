import { mineUpTo } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

export function shouldBehaveLikePoem(): void {
  describe("Poem withdraw", function () {});

  describe("Poem Minting Requirements", function () {
    // TODO: minting price
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

    it("on mint, update historicalInput", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).getHistoricalInput()).to.not.equal(1);
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
    it("on transfer, update historicalInput", async function () {
      await this.poem.connect(this.signers.admin).mint();
      const oldPseudoRandomNumber = await this.poem.connect(this.signers.admin).getHistoricalInput();
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.admin).getHistoricalInput()).to.not.equal(oldPseudoRandomNumber);
    });

    it("on transfer, update transfer timestamp", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.user.address)).to.equal(0);

      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).lastTransferedAt(this.signers.user.address)).to.equal(2);
    });

    it("on transfer, update ownership and owner count", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).balanceOf(this.signers.admin.address)).to.equal(1);
      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.admin.address)).to.equal(0);
      expect(await this.poem.connect(this.signers.user).balanceOf(this.signers.user.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).numOwners(0)).to.equal(2);
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

    it("on burn, update historicalInput", async function () {
      await this.poem.connect(this.signers.admin).mint();
      const num = await this.poem.connect(this.signers.admin).getHistoricalInput();
      expect(num).to.not.equal(1);
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.connect(this.signers.admin).getHistoricalInput()).to.not.equal(num);
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
    beforeEach(async function () {
      await this.poem.connect(this.signers.admin).initialize();
    });

    it("should be opaque", async function () {
      // start by minting
      await this.poem.connect(this.signers.admin).mint();
      // update to block number... 1365000 which gets us to 15% opacityLevel
      await mineUpTo(1365000);
      // set historical seed to something such that (historicalInput + this.signers.admin) % 100 = 87
      await this.poem
        .connect(this.signers.admin)
        .setHistoricalInput(
          BigInt("1157920892373161954235709850086879078532699846656405640394575840079131296487") -
            BigInt(this.signers.admin.address),
        );
      // so now if we burn, the next step should be 0
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.currStep()).to.equal(1);
      expect(await this.poem.path(1)).to.equal(0);
    });

    it("should take left step", async function () {
      // start by minting, next block number is 2
      await this.poem.connect(this.signers.admin).mint();
      // at this point, the values will be... [50,100]
      // set historical seed to something such that (historicalInput + this.signers.admin) % 100 = 0
      await this.poem
        .connect(this.signers.admin)
        .setHistoricalInput(
          BigInt("1157920892373161954235709850086879078532699846656405640394575840079131296400") -
            BigInt(this.signers.admin.address),
        );
      // so now if we burn, the next step should be 2
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.currStep()).to.equal(1);
      expect(await this.poem.path(1)).to.equal(2);
    });

    it("should take right step", async function () {
      // start by minting, next block number is 2
      await this.poem.connect(this.signers.admin).mint();
      // at this point, the values will be... [50,100]
      // set historical seed to something such that (historicalInput + this.signers.admin) % 100 = 59
      await this.poem
        .connect(this.signers.admin)
        .setHistoricalInput(
          BigInt("1157920892373161954235709850086879078532699846656405640394575840079131296459") -
            BigInt(this.signers.admin.address),
        );
      // so now if we burn, the next step should be 3
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.currStep()).to.equal(1);
      expect(await this.poem.path(1)).to.equal(3);
    });

    // TODO: works for PoemPacked but not PoemStruct
    // describe("should take jitter step and choose", function () {
    //   beforeEach(async function () {
    //     // mint 3 tokens and burn all of them
    //     for (let i=0; i < 3; i++) {
    //       await this.poem.connect(this.signers.others[i]).mint();
    //       // set historical seed so we always choose the left child
    //       await this.poem.connect(this.signers.admin).setHistoricalInput(BigInt('1157920892373161954235709850086879078532699846656405640394575840079131296400')-BigInt(this.signers.others[i].address));
    //       await this.poem.connect(this.signers.others[i]).burn(i);
    //     }
    //     // Now mint the 4th token. It has 4 kids to choose from when jittering
    //     await this.poem.connect(this.signers.admin).mint();
    //     // pass it back and forth 8 times so that jitterLevel is 10
    //     const fromUser = [this.signers.admin, this.signers.user]
    //     const toUser = [this.signers.user, this.signers.admin]
    //     for (let i=0; i < 8; i++) {
    //       const userIndex = i%2;
    //       await this.poem.connect(fromUser[userIndex]).transferFrom(
    //         fromUser[userIndex].address, toUser[userIndex].address, 3);
    //     }
    //   });

    //   it("left", async function() {
    //     // If we chose left, we should be at node 7 right now.
    //     expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
    //     expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
    //     expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
    //     expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
    //     expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
    //     expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

    //     // The token has been minted and was passed around the owner number is 8.
    //     // This means a 10% jitter likelihood. Values are currently: [45,90,100]
    //     // So in order to jitter I need seed % 100 > 90
    //     // The siblings list will be 15, 14, 13, 12, (11 is left)
    //     // Then inside the jitter function, I need it to go 0,0,0,0,1
    //     // So the final 5 bits are 10000
    //     await this.poem.connect(this.signers.admin).setHistoricalInput(BigInt('96230537732805810709003998350712726735510319204374157684181885535773934182995')-BigInt(this.signers.admin.address));
    //     // so now if we burn, the next step should be 11
    //     await this.poem.connect(this.signers.admin).burn(3);
    //     expect(await this.poem.currStep()).to.equal(4);
    //     expect(await this.poem.path(4)).to.equal(11);
    //   });

    //   it("right", async function() {
    //     // If we chose left, we should be at node 7 right now.
    //     expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
    //     expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
    //     expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
    //     expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
    //     expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
    //     expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

    //     // I need seed % 100 > 80
    //     // The siblings list will be 15, 14, 13, 12, (11 is left)
    //     // Then inside the jitter function, I need it to go 0,0,0,1,0
    //     // So the final 5 bits are 10000
    //     await this.poem.connect(this.signers.admin).setHistoricalInput(BigInt('61918807874958815746790948911337494449742115977377729583759372904494587393595')-BigInt(this.signers.admin.address));
    //     // so now if we burn, the next step should be 11
    //     await this.poem.connect(this.signers.admin).burn(3);
    //     expect(await this.poem.currStep()).to.equal(4);
    //     expect(await this.poem.path(4)).to.equal(12);
    //   });

    //   it("sibling 1", async function() {
    //     // If we chose left, we should be at node 7 right now.
    //     expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
    //     expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
    //     expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
    //     expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
    //     expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
    //     expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

    //     // I need seed % 100 > 90
    //     // The siblings list will be 15, 14, 13, 12, (11 is left)
    //     // Then inside the jitter function, I need it to go 0,0,1,0,0
    //     // So the final 5 bits are 00100
    //     await this.poem.connect(this.signers.admin).setHistoricalInput(BigInt('14020019946167396737247803966093464688787132973293974027242799015757365473195')-BigInt(this.signers.admin.address));
    //     // so now if we burn, the next step should be 11
    //     await this.poem.connect(this.signers.admin).burn(3);
    //     expect(await this.poem.currStep()).to.equal(4);
    //     expect(await this.poem.path(4)).to.equal(13);
    //   });

    //   it("sibling 2", async function() {
    //     // If we chose left, we should be at node 7 right now.
    //     expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
    //     expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
    //     expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
    //     expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
    //     expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
    //     expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

    //     // Final 5 bits are 00010
    //     await this.poem.connect(this.signers.admin).setHistoricalInput(BigInt('114655377565417663845180483440748171914344049594080292602998703635102979546695')-BigInt(this.signers.admin.address));
    //     // so now if we burn, the next step should be 11
    //     await this.poem.connect(this.signers.admin).burn(3);
    //     expect(await this.poem.currStep()).to.equal(4);
    //     expect(await this.poem.path(4)).to.equal(14);
    //   });

    //   it("sibling 3", async function() {
    //     // If we chose left, we should be at node 7 right now.
    //     expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
    //     expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
    //     expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
    //     expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
    //     expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
    //     expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

    //     // Final 5 bits are 00001
    //     // So the number is: 18129116707341080426964920390299662852095841932611337458718960052007814971695
    //     await this.poem.connect(this.signers.admin).setHistoricalInput(BigInt('18129116707341080426964920390299662852095841932611337458718960052007814971695')-BigInt(this.signers.admin.address));
    //     // so now if we burn, the next step should be 11
    //     await this.poem.connect(this.signers.admin).burn(3);
    //     expect(await this.poem.currStep()).to.equal(4);
    //     expect(await this.poem.path(4)).to.equal(15);
    //   });
    // });
  });

  describe("Poem testing distributions", function () {
    // const randomBinaryString = (length: number) => {
    //   // Declare all characters
    //   const chars = "01";

    //   // Pick characers randomly
    //   let str = "0b";
    //   for (let i = 0; i < length; i++) {
    //     str += chars.charAt(Math.floor(Math.random() * chars.length));
    //   }

    //   return str;
    // };

    // TODO: getting overflow issues
    it("calculate distribution of newHistoricalInput", async function () {
      //   // for (let i=0; i<3000; i++) {
      //   console.log(`let's do this 2`);
      //   const historicalInputs = [];
      //   const difficulties = [];
      //   const blockNumbers = [];
      //   const froms = [];
      //   const tos = [];
      //   let historicalInput = [
      //     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      //   ];
      //   let difficulty = BigInt(randomBinaryString(256));
      //   let blockNumber = BigInt(randomBinaryString(256));
      //   // historicalInputs.push(JSON.stringify({x:blockNumber, y:1}));
      //   // difficulties.push(JSON.stringify({x:blockNumber, y:difficulty}));
      //   // blockNumbers.push(JSON.stringify({x:0, y:blockNumber}));
      //   for (let k = 0; k < 3000; k++) {
      //     if (k % 100 == 0) {
      //       console.log(`subtest ${k}`);
      //     }
      //     const from = BigInt(randomBinaryString(256));
      //     const to = BigInt(randomBinaryString(256));
      //     // froms.push(JSON.stringify({x:blockNumber, y:from}));
      //     // tos.push(JSON.stringify({x:blockNumber, y:to}));
      //     historicalInput = await this.poem
      //       .connect(this.signers.admin)
      //       .newHistoricalInput(historicalInput, from, to, difficulty, blockNumber);
      //     // Move ahead by max 90ish days
      //     blockNumber += BigInt(randomBinaryString(19));
      //     // Adjust difficulty every 100-200 blocks by a semi-random amount
      //     if (k % 3 == 0) {
      //       difficulty += BigInt(randomBinaryString(100));
      //     }
      //     if (k % 7 == 0) {
      //       difficulty -= BigInt(randomBinaryString(100));
      //     }
      //     // historicalInputs.push(JSON.stringify({x:blockNumber, y:historicalInput}));
      //     // difficulties.push(JSON.stringify({x:blockNumber, y:difficulty}));
      //     // blockNumbers.push(JSON.stringify({x: k+1, y:blockNumber}));
      //   }
      //   // console.log(`historicalInputs: ${historicalInputs}\n`);
      //   // console.log(`difficulties: ${difficulties}\n`);
      //   // console.log(`blockNumbers: ${blockNumbers}\n`);
      //   // console.log(`froms: ${froms}\n`);
      //   // console.log(`tos: ${tos}\n`);
      //   // }
    });

    it("calculate distribution of getCurrIndex");
    it("calculate distribution of takeNextStep");
  });
}
