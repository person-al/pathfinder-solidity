import { mineUpTo } from "@nomicfoundation/hardhat-network-helpers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { Poem } from "../../src/types/contracts/Poem.sol/Poem";
import type { Poem__factory } from "../../src/types/factories/contracts/Poem.sol/Poem__factory";
import type { Signers } from "../types";

describe("Poem", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];
    this.signers.user = signers[1];
    this.signers.others = signers.slice(2, -1);

    this.loadFixture = loadFixture;
  });

  beforeEach(async function () {
    const { poem } = await this.loadFixture(deployPoemFixture);
    this.poem = poem;
  });

  simulateContractLifecycle(10, 500, false);
});

async function deployPoemFixture(): Promise<{ poem: Poem }> {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const admin: SignerWithAddress = signers[0];

  const poemFactory: Poem__factory = (<Poem__factory>await ethers.getContractFactory("Poem")) as Poem__factory;
  const poem: Poem = <Poem>await poemFactory.connect(admin).deploy("Poem", "POEM", 0);
  await poem.deployed();

  return { poem };
}

const getRandomUserWithTokens = (userToToken: Map<SignerWithAddress, number[]>, admin: SignerWithAddress) => {
  const usersWithTokens = Array.from(userToToken.keys()).filter(value => {
    const tokens = userToToken.get(value) || [];
    return tokens.length > 0;
  });
  if (usersWithTokens.length == 0) {
    return [false, admin, 0];
  }
  const user = usersWithTokens[Math.floor(Math.random() * usersWithTokens.length)];
  const tokens = userToToken.get(user) || [];
  return [true, user, tokens[0]];
};

export function simulateContractLifecycle(
  outerLoopCount: number,
  innerLoopCount: number,
  debug: boolean = false,
): void {
  it("simulate entire contract lifecycle", async function () {
    enum Options {
      MINT,
      BURN,
      TRANSFER,
      HOLD,
    }
    for (let k = 0; k < outerLoopCount; k++) {
      const userToToken = new Map<SignerWithAddress, number[]>();
      const numUsers = this.signers.others.length;
      const hasMinted = new Set<string>();
      // start by minting the first token
      let next = Options.MINT;
      let currToken = 0;
      let blockNum = 0;

      // TODO: if you update the 500 to 1000 you often end up with a generic failure
      for (let i = 0; i < innerLoopCount; i++) {
        if (currToken >= 7 && !getRandomUserWithTokens(userToToken, this.signers.admin)[0]) {
          // If we've minted and burned everything, we can step out of the for-loop
          break;
        }
        const a = getRandomUserWithTokens(userToToken, this.signers.admin);
        const success = a[0] as boolean;
        const randomUserWithToken = a[1] as SignerWithAddress;
        const tokenId = a[2] as number;
        const randomUser = this.signers.others[Math.floor(Math.random() * numUsers)];
        switch (next) {
          case Options.MINT: {
            if (currToken >= 7) {
              debug && console.log("We've minted all the tokens already");
              break;
            }
            if (hasMinted.has(randomUser.address)) {
              debug && console.log("User has minted before");
              break;
            }
            await this.poem.connect(randomUser).mint(false);
            const a = userToToken.get(randomUser) || [];
            a.push(currToken);
            userToToken.set(randomUser, a);
            currToken += 1;
            blockNum += 1;
            hasMinted.add(randomUser.address);
            debug && console.log(`MINTED TOKEN ${currToken - 1}`);
            break;
          }
          case Options.BURN: {
            // Pick a random token
            if (!success) {
              debug && console.log("Couldn't find a user with any tokens to burn");
              break;
            }
            await this.poem.connect(randomUserWithToken).burn(tokenId);
            blockNum += 1;
            debug && console.log(`BURNED TOKEN ${tokenId}`);
            const burnTokens = userToToken.get(randomUserWithToken) || [];
            burnTokens.shift();
            userToToken.set(randomUserWithToken, burnTokens);
            break;
          }
          case Options.HOLD: {
            const numBlocks = Math.floor(Math.random() * 7000 * 180); // Hold a random number of blocks up to 6 months out.
            await mineUpTo(blockNum + numBlocks);
            blockNum += numBlocks;
            debug && console.log(`HELD ${numBlocks} BLOCKS`);
            break;
          }
          case Options.TRANSFER: {
            if (!success) {
              debug && console.log("Couldn't find a user with any tokens to transfer");
              break;
            }
            const tokens = userToToken.get(randomUser) || [];
            if (tokens.length >= 3) {
              debug && console.log("Receiver had 3 tokens already");
              break;
            }
            // do the transfer
            await this.poem
              .connect(randomUserWithToken)
              .transferFrom(randomUserWithToken.address, randomUser.address, tokenId);
            // remove the token from one user's ledger and move it to the other
            const otherTokens = userToToken.get(randomUserWithToken) || [];
            otherTokens.shift();
            userToToken.set(randomUserWithToken, otherTokens);
            tokens.push(tokenId);
            userToToken.set(randomUser, tokens);
            debug &&
              console.log(`TRANSFER TOKEN ${tokenId} from ${randomUserWithToken.address} to ${randomUser.address}`);
            break;
          }
          default:
            break;
        }

        const nextPercentage = Math.floor(Math.random() * 100);
        if (nextPercentage <= 30) {
          next = Options.HOLD;
        } else if (nextPercentage <= 70) {
          next = Options.TRANSFER;
        } else if (nextPercentage <= 80) {
          next = Options.MINT;
        } else {
          next = Options.BURN;
        }
      }

      const path = [];
      for (let i = 0; i < 9; i++) {
        path.push(await this.poem.connect(this.signers.admin).path(i));
      }
      debug && console.log("POEM " + path);

      // re-deploy poem for next cycle
      if (outerLoopCount > 1) {
        const { poem } = await this.loadFixture(deployPoemFixture);
        this.poem = poem;
      }
    }
  });
}
