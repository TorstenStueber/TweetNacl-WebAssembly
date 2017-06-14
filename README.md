# TweetNacl in WebAssembly

Work in Progress

This is a handwritten port of the crypto library TweetNacl to WebAssembly. This is the fastest library for end-to-end encryption running in the browser. It provides state of the art strong cryptography.

It provides the following features:

- Secret-key authenticated encryption
	- implements XSalsa20, Poly1305
- Public-key authenticatd encryption
	- implements X25519, XSalsa20, Poly1305
- Public-key signatures
	- implements Ed25519
- Hashing
	- implements SHA512

The WebAssembly source code is to be found in the directory `src/wat/*`.

- edit the Web Assembly code in `src/wat/*`
- run `npm run build` to build the JavaScript file `dist/wasmCode.js`
- open `index.html` in the browser in order to run `dist/wasmCode.js`