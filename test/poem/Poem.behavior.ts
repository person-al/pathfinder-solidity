import { expect } from "chai";

export function shouldBehaveLikePoem(): void {
  describe("Minting Requirements", function () {
    it("doesn't allow minting if you've done so before", async function () {
      await this.poem.connect(this.signers.admin).mint();
      await expect(this.poem.connect(this.signers.admin).mint()).to.be.revertedWith("You can only mint 1 token.");
    });

    it("doesn't allow minting if you already hold three token", async function () {
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
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.admin.address)).to.equal(1);
      await this.poem.connect(this.signers.user).mint();
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.user.address)).to.equal(2);
    });
  });

  describe("Pseudorandom number adjuster", function () {});

  describe("Transfer requirements", function () {
    it("on transfer, update pseudoRandomNumber", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).getPsuedoRandomNumber()).to.not.equal(1);
    });

    it("on transfer, update transfer timestamp", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.user.address)).to.equal(0);

      this.poem.connect(this.signers.admin).transferFrom(this.signers.admin.address, this.signers.user.address, 0);
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.user.address)).to.equal(2);
    });
  });

  describe("Burn requirements", function () {
    it("on burn, update ownership", async function () {
      // await this.poem.connect(this.signers.admin).mint();
      // await this.poem.connect(this.signers.admin).burn(0);
    });

    it("on burn, update pseudoRandomNumber", async function () {
      await this.poem.connect(this.signers.admin).mint();
      const num = await this.poem.connect(this.signers.admin).getPsuedoRandomNumber();
      expect(num).to.not.equal(1);
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.connect(this.signers.admin).getPsuedoRandomNumber()).to.not.equal(num);
    });

    it("on burn, DO NOT update transfer timestamp", async function () {
      await this.poem.connect(this.signers.admin).mint();
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.admin.address)).to.equal(1);
      await this.poem.connect(this.signers.admin).burn(0);
      expect(await this.poem.connect(this.signers.admin).getAux(this.signers.admin.address)).to.equal(1);
      expect(await this.poem.connect(this.signers.admin).getAux(0)).to.equal(0);
    });
  });

  it("after token transfer (not burn), it updates pseudoRandomNumber and transfer timestamp and ownership update");
  it("transferring multiple times properly updates owner count");
  it("transferring multiple times properly updates block timestamp");
  it("opacityLevel can handle an extremely large numBlocksHeld");
  it("opacityLevel returns the correct value for all levels");
  it("jitterLevel can handle extremely large numOwners");
  it("jitterLevel properly accounts for the number of owners");
  it("jitterLevel properly accounts for currStep");
  it("getCurrIndex works when currIndex is non-0");
  it("getCurrIndex works when currIndex is 0 and last step is 1 away");
  it("getCurrIndex works when currIndex is 0 and last step is 2 away");
  it("getCurrIndex works when currIndex is 0 and last step is 3 away");
  it("getCurrIndex works when currIndex is 0 and last step is 4 away");
  it("getCurrIndex works when currIndex is 0 and last step is 5 away");
  it("getCurrIndex works when currIndex is 0 and last step is 6 away");
  it("getCurrIndex works when currIndex is 0 and last step is 7 away");
  it("takeNextStep");
  it("burn");
  it("calculate distribution of pseudoRandomNumber");
  it("calculate distribution of getCurrIndex");
  it("calculate distribution of takeNextStep");
}
