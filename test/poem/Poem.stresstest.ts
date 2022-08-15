import { mineUpTo } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { deployPoemFixture } from "../testable_poem/TestablePoem.fixture";

export function shouldStressWithoutProblems(): void {
  describe("Poem stress tests", function () {
    const randomBinaryString = (length: number) => {
      // Declare all characters
      const chars = "01";

      // Pick characers randomly
      let str = "0b";
      for (let i = 0; i < length; i++) {
        str += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      return str;
    };

    it("simulate newHistoricalInput updates", async function () {
      let historicalInput = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
      ];
      let difficulty = BigInt(randomBinaryString(256));
      let blockNumber = BigInt(randomBinaryString(256));
      for (let k = 0; k < 1000; k++) {
        const from = BigInt(randomBinaryString(256));
        const to = BigInt(randomBinaryString(256));
        historicalInput = await this.poem
          .connect(this.signers.admin)
          .newHistoricalInput(historicalInput, from, to, difficulty, blockNumber);
        // Move ahead by max 90ish days
        blockNumber += BigInt(randomBinaryString(19));
        // Adjust difficulty every 100-200 blocks by a semi-random amount
        if (k % 3 == 0) {
          difficulty += BigInt(randomBinaryString(100));
        }
        if (k % 7 == 0) {
          difficulty -= BigInt(randomBinaryString(100));
        }
      }
    });

    it("simulate getCurrIndex updates");
    it("simulate takeNextStep updates");

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

    it("simulate entire contract lifecycle", async function () {
      enum Options {
        MINT,
        BURN,
        TRANSFER,
        HOLD,
      }
      for (let k = 0; k < 1; k++) {
        const userToToken = new Map<SignerWithAddress, number[]>();
        const numUsers = this.signers.others.length;
        const hasMinted = new Set<string>();
        // start by minting the first token
        let next = Options.MINT;
        let currToken = 0;
        let blockNum = 0;

        // TODO: if you update the 500 to 1000 you often end up with a generic failure
        for (let i = 0; i < 500; i++) {
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
                // console.log("We've minted all the tokens already");
                break;
              }
              if (hasMinted.has(randomUser.address)) {
                // console.log("User has minted before");
                break;
              }
              await this.poem.connect(randomUser).mint(false);
              const a = userToToken.get(randomUser) || [];
              a.push(currToken);
              userToToken.set(randomUser, a);
              currToken += 1;
              blockNum += 1;
              hasMinted.add(randomUser.address);
              // console.log(`MINTED TOKEN ${currToken - 1}`);
              break;
            }
            case Options.BURN: {
              // Pick a random token
              if (!success) {
                // console.log("Couldn't find a user with any tokens to burn");
                break;
              }
              await this.poem.connect(randomUserWithToken).burn(tokenId);
              blockNum += 1;
              // console.log(`BURNED TOKEN ${tokenId}`);
              const burnTokens = userToToken.get(randomUserWithToken) || [];
              burnTokens.shift();
              userToToken.set(randomUserWithToken, burnTokens);
              break;
            }
            case Options.HOLD: {
              const numBlocks = Math.floor(Math.random() * 7000 * 180); // Hold a random number of blocks up to 6 months out.
              await mineUpTo(blockNum + numBlocks);
              blockNum += numBlocks;
              // console.log(`HELD ${numBlocks} BLOCKS`);
              break;
            }
            case Options.TRANSFER: {
              if (!success) {
                // console.log("Couldn't find a user with any tokens to transfer");
                break;
              }
              const tokens = userToToken.get(randomUser) || [];
              if (tokens.length >= 3) {
                // console.log("Receiver had 3 tokens already");
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
              // console.log(`TRANSFER TOKEN ${transferToken} from ${transferUser.address} to ${receiver.address}`);
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

        const poemPath = await this.poem.connect(this.signers.admin).getPath();
        console.log("POEM " + poemPath);

        // re-deploy poem for next cycle
        const { poem } = await this.loadFixture(deployPoemFixture);
        this.poem = poem;
      }
    });
  });
}
