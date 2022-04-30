# Notes

## Setup for VSCode

See [this](https://book.getfoundry.sh/config/vscode.html).

## Gas

[gas snapshot](https://book.getfoundry.sh/forge/gas-snapshots.html)'s are used to get a general feel for how much gas your contract will consume, or to compare gas usage before and after various optimizations.

```
forge snapshot
```

```
forge snapshot --diff .gas-snapshot
```

## Debugging

```
forge test --debug "testSomething"
```

## Profiles

Switch profiles using `FOUNDRY_PROFILE` env var.

## Verification

verify:

```zsh
forge verify-contract --chain-id 3 --compiler-version v0.8.13+commit.abaa5c0e --constructor-args $(cast abi-encode "constructor(string,string)" "Batman" "BAT") --num-of-optimizations 200 "0x83239abd51a2fd7066f8f1e92e464441f37d8854" src/NFT.sol:NFT "MNMYPJ5UKIBHQAQ5K61FJENN657HTP7IRK"
```

check:

```zsh
forge verify-check --chain-id 3 "fmkuzwbnq7nk66mkfyftrw346agfktrwyvnptby8qqpmbvhg2z" "MNMYPJ5UKIBHQAQ5K61FJENN657HTP7IRK"
```

to check the exact commit of compiler for the `--compiler-version` flag:

```zsh
~/.svm/0.8.13/solc-0.8.13 --version
```
