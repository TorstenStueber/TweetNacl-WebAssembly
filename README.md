# TweetNacl in WebAssembly

This is a direct port of the crypto library TweetNacl to WebAssembly. This is the fastest library for end-to-end encryption in the browser. It provides state of the art strong cryptography.

- edit the Web Assembly code in `src/wat/*`
- run `npm run build` to build the JavaScript file `dist/wasmCode.js`
- open `index.html` in the browser in order to run `dist/wasmCode.js`