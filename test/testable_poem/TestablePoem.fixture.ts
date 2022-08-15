import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { TestablePoem } from "../../src/types/contracts/TestablePoem";
import type { TestablePoem__factory } from "../../src/types/factories/contracts/TestablePoem__factory";

export async function deployPoemFixture(): Promise<{ poem: TestablePoem }> {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const admin: SignerWithAddress = signers[0];

  const poemFactory: TestablePoem__factory = <TestablePoem__factory>await ethers.getContractFactory("TestablePoem");
  const poem: TestablePoem = <TestablePoem>await poemFactory.connect(admin).deploy();
  await poem.deployed();

  return { poem };
}
