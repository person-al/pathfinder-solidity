import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import fs from "fs";
import { ethers } from "hardhat";
import os from "os";
import path from "path";

import type { TestablePoem } from "../../src/types/contracts/TestablePoem";
import type { TestablePoem__factory } from "../../src/types/factories/contracts/TestablePoem__factory";

const DESTINATION = path.join(os.tmpdir(), "poem-svg-render-");

const chooseRandom = (arr: any[], num = 1) => {
  const res = [];
  for (let i = 0; i < num; ) {
    const random = Math.floor(Math.random() * arr.length);
    if (res.indexOf(arr[random]) !== -1) {
      continue;
    }
    res.push(arr[random]);
    i++;
  }
  return res;
};

export async function renderAllPossibleSVGs() {
  const _signers: SignerWithAddress[] = await ethers.getSigners();
  const admin = _signers[0];

  const poemFactory: TestablePoem__factory = <TestablePoem__factory>await ethers.getContractFactory("TestablePoem");
  const poem: TestablePoem = <TestablePoem>await poemFactory.connect(admin).deploy();
  await poem.deployed();

  const possibleValuesForPath = [
    [1],
    [0, 2, 3],
    [0, 4, 5, 6],
    [0, 7, 8, 9, 10],
    [0, 11, 12, 13, 14, 15],
    [0, 16, 17, 18, 19],
    [0, 20, 21, 22],
    [0, 23, 24],
    [25],
  ];
  const tempFolder = fs.mkdtempSync(DESTINATION);
  console.log(`images in folder: ${tempFolder}`);
  let results: number[][] = [[]];

  // for each level of depth
  possibleValuesForPath.forEach(values => {
    const newResults: number[][] = [];
    // grab each node
    values.forEach(val => {
      // for each path we have stored
      results.forEach(resultsVal => {
        // add our node to the end of the path
        const resultsValCopy = JSON.parse(JSON.stringify(resultsVal));
        resultsValCopy.push(val);
        newResults.push(resultsValCopy);
      });
    });
    // and put all our paths on the list
    results = newResults;
  });

  await writeBatchFiles(tempFolder, poem, admin, chooseRandom(results, 100));
}

async function writeBatchFiles(tempFolder: string, poem: TestablePoem, admin: SignerWithAddress, paths: number[][]) {
  const itemsPerFile = 100;
  const numPaths = paths.length;
  console.log(`gonna write files to cover ${numPaths} potential paths`);
  for (let i = 0; i < numPaths; i += itemsPerFile) {
    const fileName = path.join(tempFolder, i + ".html");
    let htmlHead = `<html lang="en">
        <head>
        <meta http-equiv="Content-Type" 
            content="text/html; charset=utf-8">
        </head>`;
    let k = i;
    for (; k < i + itemsPerFile; k++) {
      if (k >= numPaths) {
        break;
      }
      const p = paths[k];
      const currStep = Math.floor(Math.random() * 9);
      const showDiamond = Math.floor(Math.random() * 100);
      await poem.connect(admin).setPath(p);
      await poem.connect(admin).setCurrStep(currStep);
      await poem.connect(admin).setHistoricalInput(showDiamond);
      const tokenId = Math.floor(Math.random() * 7);
      const jitterLevel = Math.floor(Math.random() * 30);
      const hiddenLevel = Math.floor(Math.random() * 100);
      const svg = await poem.connect(admin).getTestableSvg(tokenId, jitterLevel, hiddenLevel);
      htmlHead +=
        `<h1>showDiamond: ${
          (showDiamond >> 3) % 2 == 1
        } - tokenId: ${tokenId} jitterLevel: ${jitterLevel} hiddenLevel: ${hiddenLevel} currStep: ${currStep}- ${p}</h1>` +
        `<div style="width: 500px;height: 500px;">${svg}</div><br/>`;
    }
    fs.writeFileSync(fileName, `${htmlHead}</html>`);
    console.log(`wrote batch ${i} with paths less than ${k}`);
  }
}

async function _writeOneFile(tempFolder: string, poem: TestablePoem, admin: SignerWithAddress, paths: number[][]) {
  const numPaths = paths.length;
  console.log(`gonna write files to cover ${numPaths} potential paths`);
  const fileName = path.join(tempFolder, "oneimage.html");
  let htmlHead = `<html lang="en">
        <head>
        <meta http-equiv="Content-Type" 
            content="text/html; charset=utf-8">
        </head>`;
  const p = paths[0];
  const currStep = Math.floor(Math.random() * 9);
  const showDiamond = 8;
  await poem.connect(admin).setPath(p);
  await poem.connect(admin).setCurrStep(currStep);
  await poem.connect(admin).setHistoricalInput(showDiamond);
  const tokenId = Math.floor(Math.random() * 7);
  const jitterLevel = 0;
  const hiddenLevel = 0;
  const svg = await poem.connect(admin).getTestableSvg(tokenId, jitterLevel, hiddenLevel);
  htmlHead +=
    `<h1>showDiamond: ${
      (showDiamond >> 3) % 2 == 1
    } - tokenId: ${tokenId} jitterLevel: ${jitterLevel} hiddenLevel: ${hiddenLevel} currStep: ${currStep}- ${p}</h1>` +
    `<div style="width: 500px;height: 500px;">${svg}</div><br/>`;
  fs.writeFileSync(fileName, `${htmlHead}</html>`);
}
