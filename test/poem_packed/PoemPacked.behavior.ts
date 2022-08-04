import { expect } from "chai";

export function shouldBehaveLikePoemPacked(): void {
  it("throws require when getting a Node that doesn't exist", async function () {
    await expect(this.poem.connect(this.signers.admin).getLeftChild(0)).to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );
    await expect(this.poem.connect(this.signers.admin).getRightChild(0)).to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );
    await expect(this.poem.connect(this.signers.admin).getValueBytes(0)).to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );
    await expect(this.poem.connect(this.signers.admin).getSiblings(0)).to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );
  });

  it("returns 0s for all get functions if deployed with no changes", async function () {
    expect(await this.poem.connect(this.signers.admin).getLeftChild(1)).to.equal(0);
    expect(await this.poem.connect(this.signers.admin).getRightChild(1)).to.equal(0);
    expect(await this.poem.connect(this.signers.admin).getValueBytes(1)).to.equal(
      "0x0000000000000000000000000000000000000000000000000000000000000000",
    );
    expect(await this.poem.connect(this.signers.admin).getSiblings(1)).deep.equal([0, 0, 0, 0]);
  });

  it("errors out if packed with invalid index", async function () {
    await expect(this.poem.connect(this.signers.admin).packNode(0, "hello", 2, 3, [0, 0, 0, 0])).to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );

    await expect(this.poem.connect(this.signers.admin).packNode(26, "hello", 2, 3, [0, 0, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );
  });

  it("supports 0-index for left and right children", async function () {
    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 0, 3, [0, 0, 0, 0])).not.to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );

    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 3, 0, [0, 0, 0, 0])).not.to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );
  });

  it("errors out if packed with invalid left child index", async function () {
    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 26, 3, [0, 0, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );
  });

  it("errors out if packed with invalid right child index", async function () {
    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 2, 26, [0, 0, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );
  });

  it("errors out if packed with too long a value", async function () {
    await expect(
      this.poem
        .connect(this.signers.admin)
        .packNode(
          1,
          "It was a sore point with everyone. Thousands of years ago, men had spread out from Earth—first to the planets, then to the nearer stars, crawling in ships that could travel no faster than the speed of light. They had even believed that was an absolute limit—that nothing in the universe could exceed the speed of light. It took years to go from Earth to the nearest star.",
          2,
          3,
          [0, 0, 0, 0],
        ),
    ).to.be.revertedWith("Value can't be more than 26 characters/bytes");
  });

  it("errors out if packed with invalid sibling index", async function () {
    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 2, 3, [5, 26, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );

    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 2, 3, [1, 5, 0, 0])).to.be.revertedWith(
      "A node cannot be its own sibling.",
    );
  });

  it("errors out if packed with too many siblings", async function () {
    await expect(this.poem.connect(this.signers.admin).packNode(1, "hello", 2, 3, [5, 6, 7, 8, 9])).to.throw(
      "too many arguments",
    );
  });

  it("errors if Owner tries to modify graph after minting has begun");

  it("can pack and unpack a node successfully", async function () {
    await this.poem.connect(this.signers.admin).packNode(1, "hello", 2, 3, [5, 6, 0, 0]);
    expect(await this.poem.connect(this.signers.admin).getLeftChild(1)).to.equal(2);
    expect(await this.poem.connect(this.signers.admin).getRightChild(1)).to.equal(3);
    expect(await this.poem.connect(this.signers.admin).getValueBytes(1)).to.equal(
      "0x00000000000000000000000000000000000000000000000000000068656c6c6f",
    );
    expect(await this.poem.connect(this.signers.admin).getSiblings(1)).deep.equal([0, 0, 6, 5]);
  });

  it("can pack a small diamond", async function () {
    await this.poem.connect(this.signers.admin).packNode(1, "hello", 2, 3, [0, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(2, "hello", 4, 5, [3, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(3, "hello", 5, 6, [2, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(4, "hello", 7, 8, [5, 6, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(5, "hello", 8, 9, [4, 6, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(6, "hello", 9, 10, [5, 4, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(7, "hello", 0, 11, [8, 9, 10, 0]);
    await this.poem.connect(this.signers.admin).packNode(8, "hello", 11, 12, [7, 9, 10, 0]);
    await this.poem.connect(this.signers.admin).packNode(9, "hello", 12, 13, [7, 8, 10, 0]);
    await this.poem.connect(this.signers.admin).packNode(10, "hello", 13, 0, [7, 8, 9, 0]);
    await this.poem.connect(this.signers.admin).packNode(11, "hello", 0, 14, [12, 13, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(12, "hello", 14, 15, [11, 13, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(13, "hello", 15, 0, [11, 12, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(14, "hello", 0, 16, [15, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(15, "hello", 16, 0, [14, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).packNode(16, "hello", 0, 0, [0, 0, 0, 0]);
  });
}
