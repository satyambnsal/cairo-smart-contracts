# Cairo Smart contracts for learning purpose


```
[[target.starknet-contract]]
sierra = true
```



### Important Commands
Install rust
  ```
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```

Check rust version
  ```
  rustc --version
  ```

Install scarb
```
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

Check scarb version
```
scarb --version
```

Install **starkli**
```
curl https://get.starkli.sh | sh
starkliup
```

Check **starkli** version
```
starkli --version
```

Create a keystore file for starkli
```
starkli signer keystore from-key ~/.starkli-wallets/deployer/my_keystore_1.json
```
Create a account descriptor
```
account fetch <SMART_WALLET_ADDRESS> --output ~/.starkli-wallets/deployer/my_account_1.json
```

Set Account desciptor and KeyStore path for starkli
```
export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/my_account_1.json
export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/my_keystore_1.json
```

Set Starknet RPC
```
export STARKNET_RPC="https://starknet-goerli.g.alchemy.com/v2/<API_KEY>"
```

Convert a string to felt value
```
starkli to-cairo-string blabla
```

## Important Facts

- In Cairo, a string is a collection of characters stored in a `felt252`. Strings can have a maximum length of 31 characters.
- field elements are integers in the range between `0 <= x < P`, where P is a very large prime number, currently `P = 2^{251} + 17 * 2^{192} + 1`


## Important Links
- [Braavos google play store link](https://chrome.google.com/webstore/detail/braavos-smart-wallet/jnlgamecbpmbajjfhmmmlhejkemejdma)
- 
- [Starknet Goerli network faucet](faucet.goerli.starknet.io)
- [Starscan](https://testnet.starkscan.co/)
- [Voyager](https://goerli.voyager.online/?lang=en-US&theme=light)
- [Starknet Documentation](https://docs.starknet.io/documentation/)
- [Starknet Book](https://book.starknet.io/)
- [Cairo Book](https://cairo-book.github.io/)
- [Starknet Foundry book](https://foundry-rs.github.io/)
- [Starknet Ecosystem](https://www.starknet-ecosystem.com/)
- [Run Starknet Locally with Katana](https://book.dojoengine.org/toolchain/katana/overview.html)
- [Starknet By Example Voyager book](https://starknet-by-example.voyager.online/)