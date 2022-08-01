import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { PoemStructs } from "../../src/types/contracts/PoemStructs";
import type { PoemStructs__factory } from "../../src/types/factories/contracts/PoemStructs__factory";

export async function deployPoemFixture(): Promise<{ poem: PoemStructs }> {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const admin: SignerWithAddress = signers[0];

  const poemFactory: PoemStructs__factory = <PoemStructs__factory>await ethers.getContractFactory("PoemStructs");
  const poem: PoemStructs = <PoemStructs>await poemFactory.connect(admin).deploy();
  await poem.deployed();

  return { poem };
}
