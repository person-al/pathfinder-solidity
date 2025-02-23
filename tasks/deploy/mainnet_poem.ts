import fs from "fs";
import { ethers } from "hardhat";

const myConsole = new console.Console(
  fs.createWriteStream("/home/madeeha/code/person/solidity-sandbox/logs.txt", { flags: "a" }),
);

type EtherscanResult = {
  status: string;
  message: string;
  result: { SafeGasPrice: number };
};

async function main() {
  const [deployer] = await ethers.getSigners();

  myConsole.log("Deploying contracts with the account:", deployer.address);

  myConsole.log("Account balance:", (await deployer.getBalance()).toString());

  const Poem = await ethers.getContractFactory("Poem");
  const poem = await Poem.deploy(BigInt("100000000000000000"));
  myConsole.log("Poem address:", poem.address);

  return poem;
}

function writeAddress(addr: string) {
  try {
    fs.writeFileSync("/home/madeeha/code/person/solidity-sandbox/deployed.txt", addr);
    // file written successfully
  } catch (err) {
    myConsole.error(err);
  }
}

async function checkGas(): Promise<EtherscanResult> {
  const response = await fetch(
    `https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=${process.env.ETHERSCAN_API_KEY}`,
  );
  const data: EtherscanResult = (await response.json()) as EtherscanResult;
  return data;
}
// 4485369 gas used -> gasPrice * gas used = gwei cost / 1000000000 = eth cost
function deployContract(gasPrice: number) {
  const ethCost = (4485369 * gasPrice) / 1000000000;
  myConsole.log(`gasPrice: ${gasPrice}, ethCost: ${ethCost}`);
  if (ethCost > 0.049) {
    myConsole.log("too high");
    return;
  }
  main()
    .then(poem => {
      writeAddress(poem.address);
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

myConsole.log(`Starting deploy check ${new Date().toDateString()} ${new Date().toTimeString()}`);

fs.readFile("/home/madeeha/code/person/solidity-sandbox/deployed.txt", "utf8", (err, data) => {
  if (err) {
    myConsole.error(err);
    return;
  }
  if (data.length > 0) {
    myConsole.log(`Already deployed to: ${data}`);
    return;
  } else {
    checkGas()
      .then((value: EtherscanResult) => {
        deployContract(value.result.SafeGasPrice);
      })
      .catch(error => myConsole.error(error));
  }
});
