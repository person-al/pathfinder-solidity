import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { PoemPacked } from "../../src/types/contracts/PoemPacked";
import type { PoemPacked__factory } from "../../src/types/factories/contracts/PoemPacked__factory";

export async function deployPoemFixture(): Promise<{ poem: PoemPacked }> {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const admin: SignerWithAddress = signers[0];

  const poemFactory: PoemPacked__factory = <PoemPacked__factory>await ethers.getContractFactory("PoemPacked");
  const poem: PoemPacked = <PoemPacked>await poemFactory.connect(admin).deploy();
  await poem.deployed();

  return { poem };
}
