# identity-service-jwks
SCW-Managed JWKS Keystore to store public keys of applications using client_credentials flow auth with signed JWT client assertion

## Using the KeyGen.ps1 Script

The KeyGen script should make it easier to create Public/Private key pairs and also jwks files 

You will need this to generate jwks

https://www.npmjs.com/package/pem-jwk

```
$ npm install -g pem-jwk
```

or use something like https://github.com/russelldavies/jwk-creator 

Example for Windows

To use you will need to provide 2 vars -env <environment>  -kid <keyname> 

e.g. 
  
```PowerShell  
  PS C:\Users\Path\to\file> KeyGen.ps1 -env sandbox -kid sandbox-1 
```
  
This will generate a set of file using the following file Structure : 

Path to folder
- \<env> folder e.g. Sandbox
  - \<kid> folder e.g. Sandbox-1
    - jwtRS512 - private key in PEM format
    - jwtRS512.pub - public key in OpenSSH authorized_keys format - which is not used
    - jwtR512.key.pub - is public key in PEM format
    - jwtRS512.key - copy of jwtRS512 with .key extenstion
    - jwtRS512Public.jwks - file with Public key converted > JWKS format (uses pem-jwks)
    - jwtRS512jwks.json - compiled jwks - if supplied optional input val will be used as filename otherwise will use jwtRS512jwks as default 
