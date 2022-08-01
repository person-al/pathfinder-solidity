import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { Poem } from "../../src/types/contracts/Poem";
import type { Poem__factory } from "../../src/types/factories/contracts/Poem__factory";

export async function deployPoemFixture(): Promise<{ poem: Poem }> {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const admin: SignerWithAddress = signers[0];

  const poemFactory: Poem__factory = <Poem__factory>await ethers.getContractFactory("Poem");
  const poem: Poem = <Poem>await poemFactory.connect(admin).deploy();
  await poem.deployed();

  return { poem };
}
