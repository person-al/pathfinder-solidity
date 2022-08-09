import { expect } from "chai";

import type { PoemStructs } from "../../src/types/contracts/PoemStructs";

export function shouldBehaveLikePoemStructs(): void {
  it("returns 0s for all get functions if deployed with no changes", async function () {
    const node: PoemStructs.NodeStruct = await this.poem.connect(this.signers.admin).getNode(1);
    expect(node.leftChild).to.equal(0);
    expect(node.rightChild).to.equal(0);
    expect(node.value).to.equal("0x0000000000000000000000000000000000000000000000000000");
    expect(node.siblings).deep.equal([0, 0, 0, 0]);
  });

  it("errors out if packed with invalid index", async function () {
    await expect(this.poem.connect(this.signers.admin).storeNode(0, "hello", 2, 3, [0, 0, 0, 0])).to.be.revertedWith(
      "Use a positive, non-zero index for your nodes.",
    );

    await expect(this.poem.connect(this.signers.admin).storeNode(26, "hello", 2, 3, [0, 0, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );
  });

  it("supports 0-index for left and right children", async function () {
    await expect(
      this.poem.connect(this.signers.admin).storeNode(1, "hello", 0, 3, [0, 0, 0, 0]),
    ).not.to.be.revertedWith("Use a positive, non-zero index for your nodes.");

    await expect(
      this.poem.connect(this.signers.admin).storeNode(1, "hello", 3, 0, [0, 0, 0, 0]),
    ).not.to.be.revertedWith("Use a positive, non-zero index for your nodes.");
  });

  it("errors out if packed with invalid left child index", async function () {
    await expect(this.poem.connect(this.signers.admin).storeNode(1, "hello", 26, 3, [0, 0, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );
  });

  it("errors out if packed with invalid right child index", async function () {
    await expect(this.poem.connect(this.signers.admin).storeNode(1, "hello", 2, 26, [0, 0, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );
  });

  it("errors out if packed with too long a value", async function () {
    await expect(
      this.poem
        .connect(this.signers.admin)
        .storeNode(
          1,
          "It was a sore point with everyone. Thousands of years ago, men had spread out from Earth—first to the planets, then to the nearer stars, crawling in ships that could travel no faster than the speed of light. They had even believed that was an absolute limit—that nothing in the universe could exceed the speed of light. It took years to go from Earth to the nearest star.",
          2,
          3,
          [0, 0, 0, 0],
        ),
    ).to.be.revertedWith("Value can't be more than 26 characters/bytes");
  });

  it("errors out if packed with invalid sibling index", async function () {
    await expect(this.poem.connect(this.signers.admin).storeNode(1, "hello", 2, 3, [5, 26, 0, 0])).to.be.revertedWith(
      "Cannot support more than 25 nodes.",
    );

    await expect(this.poem.connect(this.signers.admin).storeNode(1, "hello", 2, 3, [1, 26, 0, 0])).to.be.revertedWith(
      "A node cannot be its own sibling.",
    );
  });

  it("can pack and unpack a node successfully", async function () {
    await this.poem.connect(this.signers.admin).storeNode(1, "hello", 2, 3, [0, 0, 0, 0]);
    const node: PoemStructs.NodeStruct = await this.poem.connect(this.signers.admin).getNode(1);
    expect(node.leftChild).to.equal(2);
    expect(node.rightChild).to.equal(3);
    expect(node.siblings).deep.equal([0, 0, 0, 0]);
    expect(node.value).to.equal("0x68656c6c6f000000000000000000000000000000000000000000");
  });

  it("can pack a small diamond", async function () {
    await this.poem.connect(this.signers.admin).storeNode(1, "hello", 2, 3, [0, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(2, "hello", 4, 5, [3, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(3, "hello", 5, 6, [2, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(4, "hello", 7, 8, [5, 6, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(5, "hello", 8, 9, [4, 6, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(6, "hello", 9, 10, [5, 4, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(7, "hello", 0, 11, [8, 9, 10, 0]);
    await this.poem.connect(this.signers.admin).storeNode(8, "hello", 11, 12, [7, 9, 10, 0]);
    await this.poem.connect(this.signers.admin).storeNode(9, "hello", 12, 13, [7, 8, 10, 0]);
    await this.poem.connect(this.signers.admin).storeNode(10, "hello", 13, 0, [7, 8, 9, 0]);
    await this.poem.connect(this.signers.admin).storeNode(11, "hello", 0, 14, [12, 13, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(12, "hello", 14, 15, [11, 13, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(13, "hello", 15, 0, [11, 12, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(14, "hello", 0, 16, [15, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(15, "hello", 16, 0, [14, 0, 0, 0]);
    await this.poem.connect(this.signers.admin).storeNode(16, "hello", 0, 0, [0, 0, 0, 0]);
  });
}
