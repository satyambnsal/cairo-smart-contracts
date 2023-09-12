# Cairo Smart contracts for learning purpose


```
[[target.starknet-contract]]
sierra = true
```



### Important Commands
1. Check rust version
  ```
  rustc --version
  ```
2. Install scarb
```
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

3. Check scarb version
```
scarb --version
```


## Important Facts

- In Cairo, a string is a collection of characters stored in a `felt252`. Strings can have a maximum length of 31 characters.
- field elements are integers in the range between `0 <= x < P`, where P is a very large prime number, currently `P = 2^{251} + 17 * 2^{192} + 1`


## Important Links
- [Starknet Goerli network faucet](faucet.goerli.starknet.io)
- [Starscan](https://testnet.starkscan.co/)
- [Voyager](https://goerli.voyager.online/?lang=en-US&theme=light)
- [Starknet Documentation](https://docs.starknet.io/documentation/)
- [Starknet Book](https://book.starknet.io/)
- [Cairo Book](https://cairo-book.github.io/)
