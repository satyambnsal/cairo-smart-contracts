# Cairo Smart contracts
Smart contracts written in cairo1.0



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
# Local Deployment With Katana

Install Katana 
```
git clone https://github.com/dojoengine/dojo
cd dojo
cargo install --path ./crates/katana --locked --force
```

## How to Generate a keystore and account descriptor for Local development

1. Start katana with `katana` command. You should see a list of accounts with **Account Address**, **Private Key**, and **Public Key**
and see similar message 👇
```
🚀 JSON-RPC server started: http://0.0.0.0:5050
```

2. Create a keystore file by running
```
starkli signer keystore from-key ~/.starkli-wallets/deployer/my_local_account_1_key.json
```
Note: If you see folder not found or similar error, create `.starkli-wallets/deployer` folder with `mkdir`

Now, you should see a prompt asking for a **Private Key**. copy first account private key from katana output.
Now. you see a prompt asking for a password. remember to enter something you can remember easily 😀
that's it, now we have our keystore file.

3. Create account descriptor file

```
touch ~/.starkli-wallets/deployer/my_local_account_1.json
```
Open the newly created `my_local_account_1.json` file and paste following content
```
{
  "version": 1,
  "variant": {
        "type": "open_zeppelin",
        "version": 1,
        "public_key": "<SMART_WALLET_PUBLIC_KEY>"
  },
    "deployment": {
        "status": "deployed",
        "class_hash": "<SMART_WALLET_CLASS_HASH>",
        "address": "<SMART_WALLET_ADDRESS>"
  }
}
```


- here replace **<SMART_WALLET_PUBLIC_KEY>** and **<SMART_WALLET_ADDRESS>** with respected values that you have from `katana` command output.

- to get a class hash for wallet run, replace **SMART_WALLET_ADDRESS** with respected value.
```
starkli class-hash-at  <SMART_WALLET_ADDRESS> --rpc http://0.0.0.0:5050
```
You will get class hash as the output, put that value in `my_local_account_1.json` file.




## How to setup Katana wallet and rpc file path.

Replace respected file path in `local.env` file and then run `source local.env` on terminal. you can verify if values are set correctly using
```
echo ${STARKNET_ACCOUNT}
```

# Testnet deployment with Goerli Network and Braavos Wallet

1. Copy your Braavos wallet private key from **Privacy and Security section** 

![Braavos Private Key](/assets/braavos_private_key.png)

  
2. Create a keystore file for starkli
```
starkli signer keystore from-key ~/.starkli-wallets/deployer/my_testnet_account_1_key.json
```
Note: If you see folder not found or similar error, create `.starkli-wallets/deployer` folder with `mkdir`

3. Create a account descriptor
```
account fetch <SMART_WALLET_ADDRESS> --output ~/.starkli-wallets/deployer/my_testnet_account_1.json
```
Here Replace <SMART_WALLET_ADDRESS> with your Braavos wallet address.
You Should see a message similar to 
```
WARNING: no valid provider option found. Falling back to using the sequencer gateway for the goerli-1 network. Doing this is discouraged. See https://book.starkli.rs/providers for more details.
Account contract type identified as: Braavos
Description: Braavos official proxy account
Downloaded new account config file: ~/.starkli-wallets/deployer/my_testnet_account_1.json
```
Note: If you get unknown class hash error, checkout [Issues](#Known-Issues) section.

4. Create a new env file `testnet.env` and copy `sample.testnet.env` content. You can replace values if you are using different RPC or path for keys is different.

5. run `source testnet.env` to export env variables to your terminal. you can verify if values are set correctly using
```
echo ${STARKNET_ACCOUNT}
``` 

# How to declare contract
```
starkli declare target/dev/<CONTRACT_NAME>.sierra.json --compiler-version 2.1.0
```

# How to deploy contract
```
starkli deploy <CLASS_HASH> <CONSTRUCTOR_ARGS>
```





# How to call contract methods

1. To call view functions, use **call** keyword, for example

```
starkli call 0x03d568de0f4e151ed97a196e7585cae03be68b8d01c3d5af2e19c7aa4bb07202 get
```

2. To call writable functions, use **invoke** keyword, for example

```
 starkli invoke 0x03d568de0f4e151ed97a196e7585cae03be68b8d01c3d5af2e19c7aa4bb07202 set 7
```

## Important Facts

- In Cairo, a string is a collection of characters stored in a `felt252`. Strings can have a maximum length of 31 characters.
- field elements are integers in the range between `0 <= x < P`, where P is a very large prime number, currently `P = 2^{251} + 17 * 2^{192} + 1`


# Known-Issues

1. **Unknown Classhash error**: 
If you get an unknown classhash error while creating account descriptor for your braavos account, you can create a account file manually.
create a file `~/.starkli-wallets/deployer/my_testnet_account1.json` with following content
```
{
  "version": 1,
  "variant": {
        "type": "open_zeppelin",
        "version": 1,
        "public_key": "<PUBLIC_KEY>"
  },
    "deployment": {
        "status": "deployed",
        "class_hash": "<CLASS_HASH>",
        "address": "<WALLET_ADDRESS>"
  }
}
```

- Get **<PUBLIC_KEY>**, from **Privacy and Security** section in **Braavos**
- To get classhash, open `https://testnet.starkscan.co/contract/<WALLET_ADDRESS>` link in browser. you should be able to see classhash for your account.



## Important Links
- [Braavos google play store link](https://chrome.google.com/webstore/detail/braavos-smart-wallet/jnlgamecbpmbajjfhmmmlhejkemejdma)
- [Starknet Goerli network faucet](https://faucet.goerli.starknet.io)
- [Starscan](https://testnet.starkscan.co/)
- [Voyager](https://goerli.voyager.online/?lang=en-US&theme=light)
- [Starknet Documentation](https://docs.starknet.io/documentation/)
- [Starknet Book](https://book.starknet.io/)
- [Cairo Book](https://cairo-book.github.io/)
- [Starknet Foundry book](https://foundry-rs.github.io/)
- [Starknet Ecosystem](https://www.starknet-ecosystem.com/)
- [Run Starknet Locally with Katana](https://book.dojoengine.org/toolchain/katana/overview.html)
- [Starknet By Example Voyager book](https://starknet-by-example.voyager.online/)