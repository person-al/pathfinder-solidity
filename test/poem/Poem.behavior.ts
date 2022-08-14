import { mineUpTo } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

export function shouldBehaveLikePoem(): void {
  describe("Poem withdraw", function () {
    it("only allows owner to withdraw");
    it("allows owner to withdraw ETH");
    it("allows owner to withdraw random ERC20 tokens");
    it("allows owner to withdraw random ERC721A tokens");
  });

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
      await this.poem
        .connect(this.signers.admin)
        .transferFrom(this.signers.admin.address, this.signers.user.address, 0);

      await this.poem.connect(this.signers.others[0]).mint();
      await this.poem
        .connect(this.signers.others[0])
        .transferFrom(this.signers.others[0].address, this.signers.user.address, 1);

      await this.poem.connect(this.signers.others[1]).mint();
      await this.poem
        .connect(this.signers.others[1])
        .transferFrom(this.signers.others[1].address, this.signers.user.address, 2);

      await this.poem.connect(this.signers.others[2]).mint();
      await expect(
        this.poem
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

  describe("Poem historicalInput adjustments", function () {
    it("when there's an overflow, the contract is okay with it", async function () {
      const difficulty = 5;
      const blockNumber = 0;
      const from = 7;
      const to = 0;
      const currInput = BigInt("115792089237316195423570985008687907853269984665640564039457584007913129639935");
      const historicalInput = await this.poem
        .connect(this.signers.admin)
        .newHistoricalInput(currInput, from, to, difficulty, blockNumber);
      expect(historicalInput).to.equal(5 + 7 - 1);
    });
  });

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

    describe("should take jitter step and choose", function () {
      beforeEach(async function () {
        // mint 3 tokens and burn all of them
        for (let i = 0; i < 3; i++) {
          await this.poem.connect(this.signers.others[i]).mint();
          // set historical seed so we always choose the left child
          await this.poem
            .connect(this.signers.admin)
            .setHistoricalInput(
              BigInt("1157920892373161954235709850086879078532699846656405640394575840079131296400") -
                BigInt(this.signers.others[i].address),
            );
          await this.poem.connect(this.signers.others[i]).burn(i);
        }
        // Now mint the 4th token. It has 4 kids to choose from when jittering
        await this.poem.connect(this.signers.admin).mint();
        // pass it back and forth 8 times so that jitterLevel is 10
        const fromUser = [this.signers.admin, this.signers.user];
        const toUser = [this.signers.user, this.signers.admin];
        for (let i = 0; i < 8; i++) {
          const userIndex = i % 2;
          await this.poem
            .connect(fromUser[userIndex])
            .transferFrom(fromUser[userIndex].address, toUser[userIndex].address, 3);
        }
      });

      it("left", async function () {
        // If we chose left, we should be at node 7 right now.
        expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
        expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
        expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
        expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
        expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
        expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

        // The token has been minted and was passed around the owner number is 8.
        // This means a 10% jitter likelihood. Values are currently: [45,90,100]
        // So in order to jitter I need seed % 100 > 90
        // The siblings list will be 15, 14, 13, 12, (11 is left)
        // Then inside the jitter function, I need it to go 0,0,0,0,1
        // So the final 5 bits are 10000
        await this.poem
          .connect(this.signers.admin)
          .setHistoricalInput(
            BigInt("96230537732805810709003998350712726735510319204374157684181885535773934182995") -
              BigInt(this.signers.admin.address),
          );
        // so now if we burn, the next step should be 11
        await this.poem.connect(this.signers.admin).burn(3);
        expect(await this.poem.currStep()).to.equal(4);
        expect(await this.poem.path(4)).to.equal(11);
      });

      it("right", async function () {
        // If we chose left, we should be at node 7 right now.
        expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
        expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
        expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
        expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
        expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
        expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

        // I need seed % 100 > 80
        // The siblings list will be 15, 14, 13, 12, (11 is left)
        // Then inside the jitter function, I need it to go 0,0,0,1,0
        // So the final 5 bits are 10000
        await this.poem
          .connect(this.signers.admin)
          .setHistoricalInput(
            BigInt("61918807874958815746790948911337494449742115977377729583759372904494587393595") -
              BigInt(this.signers.admin.address),
          );
        // so now if we burn, the next step should be 11
        await this.poem.connect(this.signers.admin).burn(3);
        expect(await this.poem.currStep()).to.equal(4);
        expect(await this.poem.path(4)).to.equal(12);
      });

      it("sibling 1", async function () {
        // If we chose left, we should be at node 7 right now.
        expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
        expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
        expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
        expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
        expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
        expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

        // I need seed % 100 > 90
        // The siblings list will be 15, 14, 13, 12, (11 is left)
        // Then inside the jitter function, I need it to go 0,0,1,0,0
        // So the final 5 bits are 00100
        await this.poem
          .connect(this.signers.admin)
          .setHistoricalInput(
            BigInt("14020019946167396737247803966093464688787132973293974027242799015757365473195") -
              BigInt(this.signers.admin.address),
          );
        // so now if we burn, the next step should be 11
        await this.poem.connect(this.signers.admin).burn(3);
        expect(await this.poem.currStep()).to.equal(4);
        expect(await this.poem.path(4)).to.equal(13);
      });

      it("sibling 2", async function () {
        // If we chose left, we should be at node 7 right now.
        expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
        expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
        expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
        expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
        expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
        expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

        // Final 5 bits are 00010
        await this.poem
          .connect(this.signers.admin)
          .setHistoricalInput(
            BigInt("114655377565417663845180483440748171914344049594080292602998703635102979546695") -
              BigInt(this.signers.admin.address),
          );
        // so now if we burn, the next step should be 11
        await this.poem.connect(this.signers.admin).burn(3);
        expect(await this.poem.currStep()).to.equal(4);
        expect(await this.poem.path(4)).to.equal(14);
      });

      it("sibling 3", async function () {
        // If we chose left, we should be at node 7 right now.
        expect(await this.poem.connect(this.signers.admin).currStep()).to.equal(3);
        expect(await this.poem.connect(this.signers.admin).path(0)).to.equal(1);
        expect(await this.poem.connect(this.signers.admin).path(1)).to.equal(2);
        expect(await this.poem.connect(this.signers.admin).path(2)).to.equal(4);
        expect(await this.poem.connect(this.signers.admin).path(3)).to.equal(7);
        expect(await this.poem.connect(this.signers.admin).getCurrentPathIndex()).to.equal(7);

        // Final 5 bits are 00001
        // So the number is: 18129116707341080426964920390299662852095841932611337458718960052007814971695
        await this.poem
          .connect(this.signers.admin)
          .setHistoricalInput(
            BigInt("18129116707341080426964920390299662852095841932611337458718960052007814971695") -
              BigInt(this.signers.admin.address),
          );
        // so now if we burn, the next step should be 11
        await this.poem.connect(this.signers.admin).burn(3);
        expect(await this.poem.currStep()).to.equal(4);
        expect(await this.poem.path(4)).to.equal(15);
      });
    });
  });
}
