import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { shouldBehaveLikePoemStructs } from "./PoemStructs.behavior";
import { deployPoemFixture } from "./PoemStructs.fixture";

describe("PoemStructs", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  beforeEach(async function () {
    const { poem } = await this.loadFixture(deployPoemFixture);
    this.poem = poem;
  });

  shouldBehaveLikePoemStructs();
});
