import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import { shouldBehaveLikePoem } from "../poem/Poem.behavior";
import { shouldStressWithoutProblems } from "../poem/Poem.stresstest";
import type { Signers } from "../types";
import { shouldBehaveLikeTestablePoem } from "./TestablePoem.behavior";
import { deployTestablePoemFixture } from "./TestablePoem.fixture";

describe("TestablePoem", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];
    this.signers.user = signers[1];
    this.signers.others = signers.slice(2, -1);

    this.loadFixture = loadFixture;
  });

  beforeEach(async function () {
    const { poem } = await this.loadFixture(deployTestablePoemFixture);
    this.poem = poem;
  });

  shouldBehaveLikeTestablePoem();
  shouldBehaveLikePoem();
  shouldStressWithoutProblems();
});
