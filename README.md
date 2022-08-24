# Poetry through history

Create a poem with strangers. Play with the boundaries of on-chain history and ownership.

You may own or you may create. You cannot do both.

## How does it work? (aka the Mechanics)

PoemPathfinder contains a diamond-shaped poem which, in itself, contains 21600 potential poems:

<svg xmlns="http://www.w3.org/2000/svg" width="800" height="800" style="background:#1a1a1a" viewBox="0 0 800 800"><style>.node{font-size:18px;font-family:serif;color:#a9a9a9;height:100%;overflow:auto;} .nodeNotSelected{font-size:18px;font-family:serif;color:white;height:100%;overflow:auto;} .nodeSelected{font-size:18px;font-family:serif;color:white;height:100%;overflow:auto;} .nodeHidden{font-size:18px;font-family:serif;color:#333333;text-decoration:line-through;height:100%;overflow:auto;}</style><foreignObject x="360" y="75" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">As he </div></foreignObject><foreignObject x="280" y="150" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">reached </div></foreignObject><foreignObject x="440" y="150" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">dropped </div></foreignObject><foreignObject x="200" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">upwards </div></foreignObject><foreignObject x="360" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his hands </div></foreignObject><foreignObject x="520" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his eyes </div></foreignObject><foreignObject x="120" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">joyously, </div></foreignObject><foreignObject x="280" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">to the clouds, </div></foreignObject><foreignObject x="440" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">shyly, </div></foreignObject><foreignObject x="600" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">towards his shoes, </div></foreignObject><foreignObject x="40" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">the sun </div></foreignObject><foreignObject x="200" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">the wind </div></foreignObject><foreignObject x="360" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">the footsteps </div></foreignObject><foreignObject x="520" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">thunderous laughter </div></foreignObject><foreignObject x="680" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">twinkling feathers </div></foreignObject><foreignObject x="120" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">boistered </div></foreignObject><foreignObject x="280" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">assuaged </div></foreignObject><foreignObject x="440" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">echoed in </div></foreignObject><foreignObject x="600" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">brushed </div></foreignObject><foreignObject x="200" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his excitement. </div></foreignObject><foreignObject x="360" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his fears. </div></foreignObject><foreignObject x="520" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his ears. </div></foreignObject><foreignObject x="280" y="600" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">His struggle </div></foreignObject><foreignObject x="440" y="600" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">His adventure </div></foreignObject><foreignObject x="360" y="675" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">was just beginning.</div></foreignObject></svg>

Each of the 7 mintable NFTs represent a choice: left or right? As tokens are transferred and held, the path before them changes. The more owners a token has, the more likely it is to stray off the strict left-right path. And the longer a token is held, the more the future hides from view. To take the next step, a token must be burned and the image for all tokens us updated to reflect the current path. Mint, hold, transfer, sell, or burn, it's up to you! Let's see what we make together.

### Rules

- you may mint a maximum of one token
- you can hold up to 3 tokens at a time

## Architecture

Here's a quick diagram of the contracts involved:
[![](https://mermaid.ink/img/pako:eNptVdtu1DAQ_ZVRHiiIrUQR4rJCQqWtoBKiqAUq0L7MxpONWce2bKfLUvrvjJ2LE7R5SuwztzNnJvdFaQQVy6JU6P25xI3DZqWBn4vrs1fPT07h7d_jY_hiqFn2RyAbq6ghHTBIozv01U7jWtEUHRyWWyiNji8BzE6T87W0gFoAliV5P7NdwpUl_ZOsJSU1-MA4dKLDXHLs58-m7ltPAoKBnQy1cLiDDhHMlrSfGs39Tm7evD6ZOnRmjypI8iB1IFdhSR345m7T4a5JC3Ix1-7iPXp6-eLwXf6ecRKz-3Z9mTjYUIiuq1aXkcg-6QjsTL4Sc8AO4kl3l7o0O4d76K7i49uUdV-ARpV9Q2UcBDaUepMNrj5_-tERGa9rZrvGkGB-AZruyIEgq8ye-jY8TPPoFXI_-DtmD1oojt9wAhxoETWgfUUufaxbp7vTyMKYdxZGUswkwafga9MqAZewaQNztgdTQajJU67s3eMnGX_qKN4DWuvM3YwATVFx6NiHyya_Ws-OwVPZOhn24KTfjh5n1Ua2x1LXrZea3YEyG1lmAnwwjuuPKaxZHGDZaJE-2b_jkQGLoV7kDsSrWkYzWXK6UlsudJC2oFIKyuBdTVzfjmBjuJzfYQEUJsGZK09bIssUTgpXckvjlPRXwk_NlOgLyUHHWEdKDeEmZQ5Cq5xpBh0sc9v7TmcDw1Jy7PZ_i2EeslI4HbNl9XE8h-cYMDe3RM1KCE42HaPDZhGsIGDdolIzMXR43lYsBeYMPROLG4o6StXNwKPSGiNkFUUCPi66-B6Fl_g5rIw86qM-xkGggIKLSPN-8_0DCyTOAo8-a36yPnO6Y1BOwNggG_knSlr6sd4jn2SWKpkXPcsqrpb7rB0l1y6KP8QJdyljHzXKTfeM9DVa8hl-zOGsZBk-SoQ3cUXEzn00Ac5q5P0c_Q8pHQjf78ZJBut9iKNhBg7YmFXBi-pA1BTrFkNZJ53dGse9ORhteIpF0ZBrUAr-m6Woq4JV0tCqWPKroApbFVbFSj8wtLXcFboQkokslhUqT4sC22Bu9roslsG1NID6n-KIsqh_GjN8P_wDZEZc4g)](https://mermaid.live/edit#pako:eNptVdtu1DAQ_ZVRHiiIrUQR4rJCQqWtoBKiqAUq0L7MxpONWce2bKfLUvrvjJ2LE7R5SuwztzNnJvdFaQQVy6JU6P25xI3DZqWBn4vrs1fPT07h7d_jY_hiqFn2RyAbq6ghHTBIozv01U7jWtEUHRyWWyiNji8BzE6T87W0gFoAliV5P7NdwpUl_ZOsJSU1-MA4dKLDXHLs58-m7ltPAoKBnQy1cLiDDhHMlrSfGs39Tm7evD6ZOnRmjypI8iB1IFdhSR345m7T4a5JC3Ix1-7iPXp6-eLwXf6ecRKz-3Z9mTjYUIiuq1aXkcg-6QjsTL4Sc8AO4kl3l7o0O4d76K7i49uUdV-ARpV9Q2UcBDaUepMNrj5_-tERGa9rZrvGkGB-AZruyIEgq8ye-jY8TPPoFXI_-DtmD1oojt9wAhxoETWgfUUufaxbp7vTyMKYdxZGUswkwafga9MqAZewaQNztgdTQajJU67s3eMnGX_qKN4DWuvM3YwATVFx6NiHyya_Ws-OwVPZOhn24KTfjh5n1Ua2x1LXrZea3YEyG1lmAnwwjuuPKaxZHGDZaJE-2b_jkQGLoV7kDsSrWkYzWXK6UlsudJC2oFIKyuBdTVzfjmBjuJzfYQEUJsGZK09bIssUTgpXckvjlPRXwk_NlOgLyUHHWEdKDeEmZQ5Cq5xpBh0sc9v7TmcDw1Jy7PZ_i2EeslI4HbNl9XE8h-cYMDe3RM1KCE42HaPDZhGsIGDdolIzMXR43lYsBeYMPROLG4o6StXNwKPSGiNkFUUCPi66-B6Fl_g5rIw86qM-xkGggIKLSPN-8_0DCyTOAo8-a36yPnO6Y1BOwNggG_knSlr6sd4jn2SWKpkXPcsqrpb7rB0l1y6KP8QJdyljHzXKTfeM9DVa8hl-zOGsZBk-SoQ3cUXEzn00Ac5q5P0c_Q8pHQjf78ZJBut9iKNhBg7YmFXBi-pA1BTrFkNZJ53dGse9ORhteIpF0ZBrUAr-m6Woq4JV0tCqWPKroApbFVbFSj8wtLXcFboQkokslhUqT4sC22Bu9roslsG1NID6n-KIsqh_GjN8P_wDZEZc4g)

### Poem.sol

The Poem contract is the most complex. It contains the following information:

- path: the current path we're taking down the diamond, as expressed by node indices.
- currStep: our current index in the path list.
- nodes: a list of uint256s representing the entire diamond.
  - the index of a node in the list represents the node's id or index.
  - you'll note that node 0 is empty and is only used to denote the end of the graph
  - each uint256 has the following information packed into it:
    1. the node's left child's index
    2. the node's right child's index
    3. the other nodes in the same row as the node's children (known in the code as "jitters" for reasons explained later.)
    4. the string value of the node
  - this means that for node 1 in the diamond above, the following information would be packed into nodes[1]:
    1. 2 (the node's left-child, shown in the diamond as "reached")
    2. 3 (the node's right-child, aka "dropped")
    3. 0, 0, 0 (there are no other nodes in the same row as 2 & 3)
    4. The string "As he" represented as a number

Overrides worth noting:

- **`_beforeTokenTransfers`**:
  - if a token is being burned, take a step down the diamond
  - if we're not burning, make sure the receiver has a max of 2 tokens
- **`_afterTokenTransfers`**:
  - in all cases after a token transfer, we update our \_historicalInput value. We'll get into this later.
  - if we're not burning the token, store the blockstamp of the token transfer. We will use this later to calculate how long a token was held before burning.
    - You'll notice that due to storage restrictions, we're storing a truncated version of the blockstamp by using the deployment blockNumber as our "epoch"
    - we are storing the blockstamp in the "Aux" property in the owner address map (`_packedAddressData`) provided by ERC721A. This works because we only care about how long a token was held by the owner who chooses to burn the token. The value in Aux will and should get overridden if a previous owner gets a new token.
  - If we're burning the last token, advance our currStep to the actual end. Because the last step is always guaranteed to end in the same place, we don't represent that step with an NFT. As such, we need to advance to the end manually once we reach the end.
- **`_extraData`**:
  - extraData is 24 bits of space ERC721A makes available to us in the token ID map (`_packedOwnerships`).
  - Here we store how many owners a token has had. We will use this later.
  - The `_extraData` hook is called in ERC721A's `transferFrom` function.

Internal functions of note:

- **`_newHistoricalInput`**:
  - there were many ways to choose our path down the diamond. I chose to amalgamate the history of the contract into a pseudorandom number that could be used in the `takeNextStep` function.
  - this function is called in the `_afterTransferTokens` hook.
  - Again, the goal here is to smash some of the transfer data into a pseudorandom number that adjusts over time in a loosely unpredictable way.
  - I know that the public can always spy on this value to decide if they want to burn on a specific day or not. I believe that (1) adding block difficulty and block number to the equation and (2) having this run whenever a transfer happens shake up enough of the public's control to make this inconvenient to force. You'd need to wait for the right week with the right address and then may get foiled by someone else transferring or burning in the middle. If someone _really_ wants to choose an outcome and goes through the effort to do so, I'm gonna call it part of the art.
  - That said, if this approach doesn't work for some reason, or if there are elements I haven't covered, please let me know so I can learn.
- **`_opacityLevel`**:
  - This is poorly named. I think I need to switch this to "transparency" or something.
  - This function takes in the number of blocks a given token was held by their current owner.
  - It uses that to determine the likelihood we skip this row in the poem. The idea here is that the longer a token is held, the more "faint" our path becomes.
  - The general formulat is: if the token is held for less than 4 months, there's a 0% chance we skip this row. If it's held for over a year, there's a 100% change we skip this row.
  - If we're in the middle, the percent chance is determined by the function 12x-54. This is a loosely linear line from (4,0) to (12,100).
- **`jitterLevel`**:
  - this function returns the percent change we stray from our typical path.
  - When you look at the diamond above, there is a clear left and right child to any given node. If we were on the "his hands" node, the obvious path would be to choose either "to the clouds" or "shyly".
  - However, if a token has had a certain number of owners, there's a chance we pick a random other node in that row: either "joyously" or "towards his shoes".
  - This function looks at the number of owners a token has had and returns that percentage, ranging from 0 to a max of 30%.
  - note to self: maybe I need to up that to 60%? So that makes an even 20% chance per node?
- **`_getCurrIndex`**:
  - this function returns the current index we're on by checking path.
  - this is straightforward in most cases. However, let's say someone held a token for too long and we skipped a given row. In that case, we want `_getCurrIndex` to pick a potential index we _could_ be on so we can advance to a valid next step.
  - it uses the token's owner's address as a pseudo random number to decide which index we might be on. (Again, this is gameable, but I think I'm okay with that?)
- **`takeNextStep`**:
  - this function determines what step we should take next. It does so via the following steps:
    1. determine the likelihood we skip this step (`_opacityLevel`)
    2. determine the likelihood we jump off our typical path (`_jitterLevel`)
    3. determine the likelihood we choose the left child
    4. determine the likelihood we choose the right child
    5. use the historical seed to choose one of the above 4 outcomes
    6. update path and currStep to take our next step

Notes on rendering:

- There are currently two ways the token can be rendered (it changes based on the historicalInput value). There's the diamond poem shape:
  <svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" style="background:#1a1a1a" viewBox="0 0 800 800"><style>.node{font-size:18px;font-family:serif;color:#a9a9a9;height:100%;overflow:auto;} .nodeNotSelected{font-size:18px;font-family:serif;color:#555555;height:100%;overflow:auto;} .nodeSelected{font-size:18px;font-family:serif;color:white;height:100%;overflow:auto;} .nodeHidden{font-size:18px;font-family:serif;color:#333333;text-decoration:line-through;height:100%;overflow:auto;}</style><foreignObject x="360" y="75" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">As he </div></foreignObject><foreignObject x="280" y="150" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">reached </div></foreignObject><foreignObject x="440" y="150" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">dropped </div></foreignObject><foreignObject x="200" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">upwards </div></foreignObject><foreignObject x="360" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his hands </div></foreignObject><foreignObject x="520" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his eyes </div></foreignObject><foreignObject x="120" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">joyously, </div></foreignObject><foreignObject x="280" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">to the clouds, </div></foreignObject><foreignObject x="440" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">shyly, </div></foreignObject><foreignObject x="600" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">towards his shoes, </div></foreignObject><foreignObject x="40" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">the sun </div></foreignObject><foreignObject x="200" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">the wind </div></foreignObject><foreignObject x="360" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">the footsteps </div></foreignObject><foreignObject x="520" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">thunderous laughter </div></foreignObject><foreignObject x="680" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">twinkling feathers </div></foreignObject><foreignObject x="120" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">boistered </div></foreignObject><foreignObject x="280" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">assuaged </div></foreignObject><foreignObject x="440" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">echoed in </div></foreignObject><foreignObject x="600" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">brushed </div></foreignObject><foreignObject x="200" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his excitement. </div></foreignObject><foreignObject x="360" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his fears. </div></foreignObject><foreignObject x="520" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">his ears. </div></foreignObject><foreignObject x="280" y="600" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">His struggle </div></foreignObject><foreignObject x="440" y="600" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">His adventure </div></foreignObject><foreignObject x="360" y="675" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="node">was just beginning.</div></foreignObject></svg>

and a linear version:
<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" style="background:#1a1a1a" viewBox="0 0 800 800"><style>.sentence{font-size:70px;font-family:serif;color:white;height:100%;overflow:auto;}</style><foreignObject x="30" y="20" width="760" height="760"><div xmlns="http://www.w3.org/1999/xhtml" class="sentence">As he ████████████████████████████████████████</div></foreignObject></svg>
(more examples in [Rendering Examples](#rendering-examples) below)

The goal was to make it easier to see the forest as well as the tree, so to speak.

## Open Questions

- Do I need a Reentrancy Guard with the way the contract is designed?
- Are there cheaper ways to store the SVG rendering pieces?
- Are there better renderings I could do or adjustments to the rendering I should do?
- Is my randomness random enough? Are there edge cases I haven't thought of? This isn't a DeFi application, a high profile launch, or a game where fairness matters. So I don't need the randomness to be foolproof. It needs to be fun and inconvenient to game.
  - One option that's occurred to me is to get rid of \_historicalInput all together and just use the hash of the previous block. But I like the sense of history historicalInput brings to the piece.

## Inspiration, Resources, and Kudos

PoemPathfinder draws inspiration from many sources:

- I wanted to keep as much data on-chain as possible, and create something that wouldn't mean as much if it was built off-chain. Loot and Corruption(s\*) provided helpful examples of how to achieve those goals.
- Layli Long Soldier's poem [Obligations 2](https://www.poetryfoundation.org/poems/149976/obligations-2) inspired the shape of the poem and the pathfinding concept.

The following resources were instrumental in my smartcontract construction:

- Xuannü's blog posts ([1](https://cryptocoven.mirror.xyz/A622VSRm8-9oLzc8l3oFGmfnFUZQmDQ3Wx3ObhSlhsc?ref=tokendaily), [2](https://cryptocoven.mirror.xyz/0eZ0tjudMU0ByeXLlRtPzDqxGzMMZw6ldzf-HfYETW0)) on developing CryptoCoven were a crucial starting point. They combined code with context in a way that a reading a smart contract on its own couldn't do.
- The [CryptoCoven](https://www.solidlint.com/address/0x5180db8f5c931aae63c74266b211f580155ecac8), [Loot](https://www.solidlint.com/address/0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7), and [WatchfaceWorld](https://www.solidlint.com/address/0x8d3b078d9d9697a8624d4b32743b02d270334af1) smartcontracts
- w1nt3r_eth's [meta thread](https://twitter.com/w1nt3r_eth/status/1504163829881528329?s=20&t=E4WmXMQhXuYG1J7ZmXLl2Q) on developing in Solidity
- I learned a _lot_ about current best practices from [w1nt3r_eth](https://twitter.com/w1nt3r_eth), [cygaar_dev](https://twitter.com/cygaar_dev) and [nazar_ilamanov](https://twitter.com/nazar_ilamanov)'s threads breaking down smart contracts.
- The [Hardhat developer template](https://github.com/paulrberg/hardhat-template)

Thanks to CommitsVortex for the [ideas and brainstorming](https://person-al.github.io/%F0%9F%8C%B0/2022/06/08/a-meeting-on-nft-art.html). Thanks to w1nt3r_eth, nazar_ilamanov, Doggo, and [thenerdassassin](https://twitter.com/thenerdassassin) for your encouragement and Solidity expertise. And thanks to meta for being the first to mint PoemPathfinder on the testnet!

## Rendering Examples

### Diamond, path with skips: [1,3,5,7,0,0,0,0,25] currStep: 8

<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" style="background:#1a1a1a" viewBox="0 0 800 800"><style>.node{font-size:18px;font-family:serif;color:#a9a9a9;height:100%;overflow:auto;} .nodeNotSelected{font-size:18px;font-family:serif;color:#555555;height:100%;overflow:auto;} .nodeSelected{font-size:18px;font-family:serif;color:white;height:100%;overflow:auto;} .nodeHidden{font-size:18px;font-family:serif;color:#333333;text-decoration:line-through;height:100%;overflow:auto;}</style><foreignObject x="360" y="75" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">As he </div></foreignObject><foreignObject x="280" y="150" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeNotSelected">reached </div></foreignObject><foreignObject x="440" y="150" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">dropped </div></foreignObject><foreignObject x="200" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeNotSelected">upwards </div></foreignObject><foreignObject x="360" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">his hands </div></foreignObject><foreignObject x="520" y="225" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeNotSelected">his eyes </div></foreignObject><foreignObject x="120" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">joyously, </div></foreignObject><foreignObject x="280" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeNotSelected">to the clouds, </div></foreignObject><foreignObject x="440" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeNotSelected">shyly, </div></foreignObject><foreignObject x="600" y="300" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeNotSelected">towards his shoes, </div></foreignObject><foreignObject x="40" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">the sun </div></foreignObject><foreignObject x="200" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">the wind </div></foreignObject><foreignObject x="360" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">the footsteps </div></foreignObject><foreignObject x="520" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">thunderous laughter </div></foreignObject><foreignObject x="680" y="375" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">twinkling feathers </div></foreignObject><foreignObject x="120" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">boistered </div></foreignObject><foreignObject x="280" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">assuaged </div></foreignObject><foreignObject x="440" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">echoed in </div></foreignObject><foreignObject x="600" y="450" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">brushed </div></foreignObject><foreignObject x="200" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">his excitement. </div></foreignObject><foreignObject x="360" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">his fears. </div></foreignObject><foreignObject x="520" y="525" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">his ears. </div></foreignObject><foreignObject x="280" y="600" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">His struggle </div></foreignObject><foreignObject x="440" y="600" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeHidden">His adventure </div></foreignObject><foreignObject x="360" y="675" width="130" height="60"><div xmlns="http://www.w3.org/1999/xhtml" class="nodeSelected">was just beginning.</div></foreignObject></svg>

### Line, path with skips: [1,3,0,8,11,18,0,0,25] currStep: 6

<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" style="background:#1a1a1a" viewBox="0 0 800 800"><style>.sentence{font-size:70px;font-family:serif;color:white;height:100%;overflow:auto;}</style><foreignObject x="30" y="20" width="760" height="760"><div xmlns="http://www.w3.org/1999/xhtml" class="sentence">As he dropped █████ to the clouds, the sun echoed in █████ ██████████</div></foreignObject></svg>

## Developer Tips

The following tips come from the [Hardhat Template repo](https://github.com/paulrberg/hardhat-template). For more details, I recommend checking out their instructions.

### Compile

Compile the smart contracts with Hardhat:

```sh
$ yarn compile
```

### TypeChain

Compile the smart contracts and generate TypeChain bindings:

```sh
$ yarn typechain
```

### Test

Run the tests with Hardhat:

```sh
$ yarn test
```

### Lint Solidity

Lint the Solidity code:

```sh
$ yarn lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```sh
$ yarn lint:ts
```

### Coverage

Generate the code coverage report:

```sh
$ yarn coverage
```

### Report Gas

See the gas usage per unit test and average gas per method call:

```sh
$ REPORT_GAS=true yarn test
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```sh
$ yarn clean
```

### Deploy

Deploy the contracts to Hardhat Network:

```sh
$ yarn deploy --greeting "Bonjour, le monde!"
```
