(nacl => {
	'use strict';

	//don't change the next line, it gets replaced by the automatic build tool
	const wasmCode = '';

	// Ported in 2017 by Torsten Stueber
	// Public domain.
	//
	// Implementation derived from TweetNaCl version 20140427.
	// See for details: http://tweetnacl.cr.yp.to/

	//Pluggable, initialized in high-level API below.
	let randombytes = () => { throw new Error('no PRNG'); };
	let wasmInstance;
	let wasmInstancePromise;
	let wasmMemory = new WebAssembly.Memory({initial: 2000});
	
	function copyToWasmMemory(arrayDescriptors, instance) {
		let currentStart = wasmInstance.exports.globalsEnd;
		const indexObject = {};
		
		Object.keys(arrayDescriptors).forEach(name => {
			indexObject[name] = currentStart;
			const descriptor = arrayDescriptors[name];
			const paddingBefore = descriptor.paddingBefore | 0;
			const array = descriptor.array;
			
			if (array) {
				const memoryArray = new Uint8Array(
					wasmMemory.buffer,
					currentStart + paddingBefore,
					array.length
				);
				memoryArray.set(array);
			}

			const sectionLength = paddingBefore + (array ? array.length : 0);
			const alignedLength = Math.ceil((sectionLength) / 8) * 8;
			currentStart += alignedLength;
		});
		return indexObject;
	}

	function checkLengths(k, n) {
		if (k.length !== crypto_secretbox_KEYBYTES) {
			throw new Error('bad key size');
		}
		if (n.length !== crypto_secretbox_NONCEBYTES) {
			throw new Error('bad nonce size');
		}
	}

	function checkBoxLengths(pk, sk) {
		if (pk.length !== crypto_box_PUBLICKEYBYTES) {
			throw new Error('bad public key size');
		}
		if (sk.length !== crypto_box_SECRETKEYBYTES) {
			throw new Error('bad secret key size');
		}
	}

	function checkArrayTypes() {
		for (let i = 0; i < arguments.length; i++) {
			if (!(arguments[i] instanceof Uint8Array)) {
				throw new TypeError('unexpected type, use Uint8Array');
			}
		}
	}

	const crypto_secretbox_KEYBYTES = 32;
	const crypto_secretbox_NONCEBYTES = 24;
	const crypto_secretbox_ZEROBYTES = 32;
	const crypto_secretbox_BOXZEROBYTES = 16;
	const crypto_scalarmult_BYTES = 32;
	const crypto_scalarmult_SCALARBYTES = 32;
	const crypto_box_PUBLICKEYBYTES = 32;
	const crypto_box_SECRETKEYBYTES = 32;
	const crypto_box_BEFORENMBYTES = 32;
	const crypto_box_NONCEBYTES = crypto_secretbox_NONCEBYTES;
	const crypto_box_ZEROBYTES = crypto_secretbox_ZEROBYTES;
	const crypto_box_BOXZEROBYTES = crypto_secretbox_BOXZEROBYTES;
	const crypto_sign_BYTES = 64;
	const crypto_sign_PUBLICKEYBYTES = 32;
	const crypto_sign_SECRETKEYBYTES = 64;
	const crypto_sign_SEEDBYTES = 32;
	const crypto_hash_BYTES = 64;

	//p: Uint8Array[16]
	//k: Uint8Array[32]
	//c: Uint8Array[16]
	//return: Uint8Array[32]
	function crypto_core_hsalsa20(p, k, c) {
		const indexes = copyToWasmMemory({
			o: {paddingBefore: 32},
			p: {array: p},
			k: {array: k},
			c: {array: c},
		});
		wasmInstance.exports.core_hsalsa20(
			indexes.o,
			indexes.p,
			indexes.k,
			indexes.c
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.o, indexes.o + 32));
	}

	//m: Uint8Array[]
	//n: Uint8Array[24]
	//k: Uint8Array[32]
	//return: Uint8Array[m.length]
	function crypto_stream_xor(m, n, k) {
		const indexes = copyToWasmMemory({
			c: {paddingBefore: m.length},
			m: {array: m},
			n: {array: n},
			k: {array: k},
			alloc: {paddingBefore: 120}
		});
		wasmInstance.exports.crypto_stream_xor(
			indexes.c,
			indexes.m,
			m.length,
			indexes.n,
			indexes.k,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.c, indexes.c + m.length));
	}

	//d: integer
	//n: Uint8Array[24]
	//k: Uint8Array[32]
	//return: Uint8Array[d]
	function crypto_stream(d, n, k) {
		const indexes = copyToWasmMemory({
			c: {paddingBefore: d},
			n: {array: n},
			k: {array: k},
			alloc: {paddingBefore: 120}
		});
		wasmInstance.exports.crypto_stream(
			indexes.c,
			d,
			indexes.n,
			indexes.k,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.c, indexes.c + d));
	}

	//m: Uint8Array[]
	//n: Uint8Array[8]
	//k: Uint8Array[32]
	//return: Uint8Array[m.length]
	function crypto_stream_salsa20_xor(m, n, k) {
		const indexes = copyToWasmMemory({
			c: {paddingBefore: m.length},
			m: {array: m},
			n: {array: n},
			k: {array: k},
			alloc: {paddingBefore: 80}
		});
		wasmInstance.exports.crypto_stream_salsa20_xor(
			indexes.c,
			indexes.m,
			m.length,
			indexes.n,
			indexes.k,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.c, indexes.c + m.length));
	}

	//d: integer
	//n: Uint8Array[8]
	//k: Uint8Array[32]
	//return: Uint8Array[d]
	function crypto_stream_salsa20(d, n, k) {
		const indexes = copyToWasmMemory({
			c: {paddingBefore: d},
			n: {array: n},
			k: {array: k},
			alloc: {paddingBefore: 80}
		});
		wasmInstance.exports.crypto_stream_salsa20(
			indexes.c,
			d,
			indexes.n,
			indexes.k,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.c, indexes.c + d));
	}

	//m: Uint8Array[]
	//k: Uint8Array[32]
	//return: Uint8Array[16]
	function crypto_onetimeauth(m, k) {
		const indexes = copyToWasmMemory({
			mac: {paddingBefore: 16},
			m: {array: m},
			k: {array: k},
			alloc: {paddingBefore: 80}
		});
		wasmInstance.exports.crypto_onetimeauth(
			indexes.mac,
			indexes.m,
			m.length,
			indexes.k,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.mac, indexes.mac + 16));
	}

	//h: Uint8Array[8]
	//m: Uint8Array[]
	//k: Uint8Array[32]
	//return: 0 if verification okay, -1 otherwise
	function crypto_onetimeauth_verify(h, m, k) {
		const indexes = copyToWasmMemory({
			h: {array: h},
			m: {array: m},
			k: {array: k},
			alloc: {paddingBefore: 96}
		});
		return wasmInstance.exports.crypto_onetimeauth_verify(
			indexes.h,
			indexes.m,
			m.length,
			indexes.k,
			indexes.alloc
		);
	}

	//x: Uint8Array[16]
	//y: Uint8Array[16]
	//return: 0 if equal, -1 otherwise
	function crypto_verify_16(x, y) {
		const indexes = copyToWasmMemory({
			x: {array: x},
			y: {array: y},
		});
		return wasmInstance.exports.crypto_verify_16(
			indexes.x,
			indexes.y,
		);
	}

	//x: Uint8Array[32]
	//y: Uint8Array[32]
	//return: 0 if equal, -1 otherwise
	function crypto_verify_32(x, y) {
		const indexes = copyToWasmMemory({
			x: {array: x},
			y: {array: y},
		});
		return wasmInstance.exports.crypto_verify_32(
			indexes.x,
			indexes.y,
		);
	}

	//m: Uint8Array[]; m.length >= 32
	//n: Uint8Array[24]
	//k: Uint8Array[32]
	//return: Uint8Array[m.length]; null if m.length < 32
	function crypto_secretbox(m, n, k) {
		const indexes = copyToWasmMemory({
			c: {paddingBefore: m.length},
			m: {array: m},
			n: {array: n},
			k: {array: k},
			alloc: {paddingBefore: 120}
		});
		const result = wasmInstance.exports.crypto_secretbox(
			indexes.c,
			indexes.m,
			m.length,
			indexes.n,
			indexes.k,
			indexes.alloc
		);
		return result === -1 ? null :
			new Uint8Array(wasmMemory.buffer.slice(indexes.c, indexes.c + m.length));
	}

	//c: Uint8Array[]; c.length >= 32
	//n: Uint8Array[24]
	//k: Uint8Array[32]
	//return: Uint8Array[c.length]; null if problem occured
	function crypto_secretbox_open(c, n, k) {
		const indexes = copyToWasmMemory({
			m: {paddingBefore: c.length},
			c: {array: c},
			n: {array: n},
			k: {array: k},
			alloc: {paddingBefore: 152}
		});
		const result = wasmInstance.exports.crypto_secretbox_open(
			indexes.m,
			indexes.c,
			c.length,
			indexes.n,
			indexes.k,
			indexes.alloc
		);
		return result === -1 ? null :
			new Uint8Array(wasmMemory.buffer.slice(indexes.m, indexes.m + c.length));
	}

	//n: Uint8Array[32]
	//p: Uint8Array[32]
	//return: Uint8Array[32]
	function crypto_scalarmult(n, p) {
		const indexes = copyToWasmMemory({
			q: {paddingBefore: 32},
			n: {array: n},
			p: {array: p},
			alloc: {paddingBefore: 928}
		});
		wasmInstance.exports.crypto_scalarmult(
			indexes.q,
			indexes.n,
			indexes.p,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.q, indexes.q + 32));
	}
	
	//n: Uint8Array[32]
	//return: Uint8Array[32]
	function crypto_scalarmult_base(n) {
		const indexes = copyToWasmMemory({
			q: {paddingBefore: 32},
			n: {array: n},
			alloc: {paddingBefore: 928}
		});
		wasmInstance.exports.crypto_scalarmult_base(
			indexes.q,
			indexes.n,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.q, indexes.q + 32));
	}

	//y: Uint8Array[32]
	//x: Uint8Array[32]
	//return: Uint8Array[32]
	function crypto_box_beforenm(y, x) {
		const indexes = copyToWasmMemory({
			k: {paddingBefore: 32},
			y: {array: y},
			x: {array: x},
			alloc: {paddingBefore: 960}
		});
		wasmInstance.exports.crypto_box_beforenm(
			indexes.k,
			indexes.y,
			indexes.x,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.k, indexes.k + 32));
	}

	//m: Uint8Array[]; m.length >= 32
	//n: Uint8Array[24]
	//y: Uint8Array[32]
	//x: Uint8Array[32]
	//return: Uint8Array[m.length]; null if problem occured
	function crypto_box(m, n, y, x) {
		const indexes = copyToWasmMemory({
			c: {paddingBefore: m.length},
			m: {array: m},
			n: {array: n},
			y: {array: y},
			x: {array: x},
			alloc: {paddingBefore: 992}
		});
		const result = wasmInstance.exports.crypto_box(
			indexes.c,
			indexes.m,
			m.length,
			indexes.n,
			indexes.y,
			indexes.x,
			indexes.alloc
		);
		return result === -1 ? null :
			new Uint8Array(wasmMemory.buffer.slice(indexes.c, indexes.c + m.length));
	}

	//c: Uint8Array[]; c.length >= 32
	//n: Uint8Array[24]
	//y: Uint8Array[32]
	//x: Uint8Array[32]
	//return: Uint8Array[c.length]; null if problem occured
	function crypto_box_open(c, n, y, x) {
		const indexes = copyToWasmMemory({
			m: {paddingBefore: c.length},
			c: {array: c},
			n: {array: n},
			y: {array: y},
			x: {array: x},
			alloc: {paddingBefore: 992}
		});
		const result = wasmInstance.exports.crypto_box_open(
			indexes.m,
			indexes.c,
			c.length,
			indexes.n,
			indexes.y,
			indexes.x,
			indexes.alloc
		);
		return result === -1 ? null :
			new Uint8Array(wasmMemory.buffer.slice(indexes.m, indexes.m + c.length));
	}

	//return: [Uint8Array[32], Uint8Array[32]]
	function crypto_box_keypair() {
		const x = nacl.randomBytes(32);
		return [crypto_scalarmult_base(x), x];
	}

	//m: Uint8Array[]
	//return: Uint8Array[64]
	function crypto_hash(m) {
		const indexes = copyToWasmMemory({
			out: {paddingBefore: 64},
			m: {array: m},
			alloc: {paddingBefore: 384}
		});
		const result = wasmInstance.exports.crypto_hash(
			indexes.out,
			indexes.m,
			m.length,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.out, indexes.out + 64));
	}

	//n: integer
	//return: Uint8Array[n]
	function nacl_randomBytes(n) {
		var b = new Uint8Array(n);
		randombytes(b, n);
		return b;
	}

	//return: Promise<void>
	function nacl_instanceReady() {
		return wasmInstancePromise
			.then(() => {});
	}

	//msg: Uint8Array[]
	//nonce: Uint8Array[24]
	//key: Uint8Array[32]
	//return: Uint8Array[msg.length + 16]
	function nacl_secretbox(msg, nonce, key) {
		checkArrayTypes(msg, nonce, key);
		checkLengths(key, nonce);

		const indexes = copyToWasmMemory({
			c: {paddingBefore: crypto_secretbox_ZEROBYTES + msg.length},
			msg: {paddingBefore: crypto_secretbox_ZEROBYTES, array: msg},
			nonce: {array: nonce},
			key: {array: key},
			alloc: {paddingBefore: 120}
		});
		const resultPointer = wasmInstance.exports.nacl_secretbox(
			indexes.c,
			indexes.msg,
			msg.length + crypto_secretbox_ZEROBYTES,
			indexes.nonce,
			indexes.key,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(
			resultPointer, 
			resultPointer + msg.length + crypto_secretbox_ZEROBYTES - crypto_secretbox_BOXZEROBYTES)
		);
	}

	//box: Uint8Array[]; box.length >= 16
	//nonce: Uint8Array[24]
	//key: Uint8Array[32]
	//return: Uint8Array[box.length - 16]; null if box.length < 16
	function nacl_secretbox_open(box, nonce, key) {
		checkArrayTypes(box, nonce, key);
		checkLengths(key, nonce);

		if (box.length < 32 - crypto_secretbox_BOXZEROBYTES) return null;

		const indexes = copyToWasmMemory({
			msg: {paddingBefore: crypto_secretbox_BOXZEROBYTES + box.length},
			c: {paddingBefore: crypto_secretbox_BOXZEROBYTES, array: box},
			nonce: {array: nonce},
			key: {array: key},
			alloc: {paddingBefore: 152}
		});
		const resultPointer = wasmInstance.exports.nacl_secretbox_open(
			indexes.msg,
			indexes.c,
			box.length + crypto_secretbox_BOXZEROBYTES,
			indexes.nonce,
			indexes.key,
			indexes.alloc
		);
		if (resultPointer === -1) {
			return null;
		}

		return new Uint8Array(wasmMemory.buffer.slice(
			resultPointer,
			resultPointer + box.length - crypto_secretbox_ZEROBYTES + crypto_secretbox_BOXZEROBYTES)
		);
	}

	//n: Uint8Array[32]
	//p: Uint8Array[32]
	//return: Uint8Array[32]
	function nacl_scalarMult(n, p) {
		checkArrayTypes(n, p);
		if (n.length !== crypto_scalarmult_SCALARBYTES) {
			throw new Error('bad n size');
		}
		if (p.length !== crypto_scalarmult_BYTES) {
			throw new Error('bad p size');
		}
		return crypto_scalarmult(n, p);
	}

	//n: Uint8Array[32]
	//return: Uint8Array[32]
	function nacl_scalarMult_base(n) {
		checkArrayTypes(n);
		if (n.length !== crypto_scalarmult_SCALARBYTES) {
			throw new Error('bad n size');
		}
		return crypto_scalarmult_base(n);
	}

	//msg: Uint8Array[]
	//nonce: Uint8Array[24]
	//publicKey: Uint8Array[32]
	//secretKey: Uint8Array[32]
	//return: Uint8Array[msg.length + 16]
	function nacl_box(msg, nonce, publicKey, secretKey) {
		const k = nacl.box.before(publicKey, secretKey);
		return nacl.secretbox(msg, nonce, k);
	}

	//publicKey: Uint8Array[32]
	//secretKey: Uint8Array[32]
	//return: Uint8Array[32]
	function nacl_box_before(publicKey, secretKey) {
		checkArrayTypes(publicKey, secretKey);
		checkBoxLengths(publicKey, secretKey);
		return crypto_box_beforenm(publicKey, secretKey);
	}

	//box: Uint8Array[]; box.length >= 16
	//nonce: Uint8Array[24]
	//publicKey: Uint8Array[32]
	//secretKey: Uint8Array[32]
	//return: Uint8Array[box.length - 16]; null if box.length < 16
	function nacl_box_open(msg, nonce, publicKey, secretKey) {
		const k = nacl.box.before(publicKey, secretKey);
		return nacl.secretbox.open(msg, nonce, k);
	}

	//return: {publicKey: Uint8Array[32], secretKey: Uint8Array[32]}
	function nacl_box_keyPair() {
		const keyPair = crypto_box_keypair();
		return {publicKey: keyPair[0], secretKey: keyPair[1]};
	}

	//secretKey: Uint8Array[32]
	//return: {publicKey: Uint8Array[32], secretKey: Uint8Array[32]}
	function nacl_box_keyPair_fromSecretKey(secretKey) {
		checkArrayTypes(secretKey);
		if (secretKey.length !== crypto_box_SECRETKEYBYTES) {
			throw new Error('bad secret key size');
		}
		const pk = crypto_scalarmult_base(secretKey);
		return {publicKey: pk, secretKey: new Uint8Array(secretKey)};
	}

	/* Low-level API */
	nacl.lowlevel = {
		crypto_core_hsalsa20: crypto_core_hsalsa20,
		crypto_stream_xor: crypto_stream_xor,
		crypto_stream: crypto_stream,
		crypto_stream_salsa20_xor: crypto_stream_salsa20_xor,
		crypto_stream_salsa20: crypto_stream_salsa20,
		crypto_onetimeauth: crypto_onetimeauth,
		crypto_onetimeauth_verify: crypto_onetimeauth_verify,
		crypto_verify_16: crypto_verify_16,
		crypto_verify_32: crypto_verify_32,
		crypto_secretbox: crypto_secretbox,
		crypto_secretbox_open: crypto_secretbox_open,
		crypto_scalarmult: crypto_scalarmult,
		crypto_scalarmult_base: crypto_scalarmult_base,
		crypto_box_beforenm: crypto_box_beforenm,
		crypto_box_afternm: crypto_secretbox,
		crypto_box: crypto_box,
		crypto_box_open: crypto_box_open,
		crypto_box_keypair: crypto_box_keypair,
		crypto_hash: crypto_hash,
		//crypto_sign: crypto_sign,
		//crypto_sign_keypair: crypto_sign_keypair,
		//crypto_sign_open: crypto_sign_open,

		crypto_secretbox_KEYBYTES: crypto_secretbox_KEYBYTES,
		crypto_secretbox_NONCEBYTES: crypto_secretbox_NONCEBYTES,
		crypto_secretbox_ZEROBYTES: crypto_secretbox_ZEROBYTES,
		crypto_secretbox_BOXZEROBYTES: crypto_secretbox_BOXZEROBYTES,
		crypto_scalarmult_BYTES: crypto_scalarmult_BYTES,
		crypto_scalarmult_SCALARBYTES: crypto_scalarmult_SCALARBYTES,
		crypto_box_PUBLICKEYBYTES: crypto_box_PUBLICKEYBYTES,
		crypto_box_SECRETKEYBYTES: crypto_box_SECRETKEYBYTES,
		crypto_box_BEFORENMBYTES: crypto_box_BEFORENMBYTES,
		crypto_box_NONCEBYTES: crypto_box_NONCEBYTES,
		crypto_box_ZEROBYTES: crypto_box_ZEROBYTES,
		crypto_box_BOXZEROBYTES: crypto_box_BOXZEROBYTES,
		crypto_sign_BYTES: crypto_sign_BYTES,
		crypto_sign_PUBLICKEYBYTES: crypto_sign_PUBLICKEYBYTES,
		crypto_sign_SECRETKEYBYTES: crypto_sign_SECRETKEYBYTES,
		crypto_sign_SEEDBYTES: crypto_sign_SEEDBYTES,
		crypto_hash_BYTES: crypto_hash_BYTES
	};

	/* High-level API */
	nacl.randomBytes = nacl_randomBytes;
	nacl.instanceReady = nacl_instanceReady;
	nacl.secretbox = nacl_secretbox;
	nacl.secretbox.open = nacl_secretbox_open;
	nacl.scalarMult = nacl_scalarMult;
	nacl.scalarMult.base = nacl_scalarMult_base;
	nacl.box = nacl_box;
	nacl.box.before = nacl_box_before;
	nacl.box.after = nacl_secretbox
	nacl.box.open = nacl_box_open;
	nacl.box.open.after = nacl_secretbox_open;
	nacl.box.keyPair = nacl_box_keyPair;
	nacl.box.keyPair.fromSecretKey = nacl_box_keyPair_fromSecretKey;

	//constants
	nacl.secretbox.keyLength = crypto_secretbox_KEYBYTES;
	nacl.secretbox.nonceLength = crypto_secretbox_NONCEBYTES;
	nacl.secretbox.overheadLength = crypto_secretbox_BOXZEROBYTES;
	nacl.scalarMult.scalarLength = crypto_scalarmult_SCALARBYTES;
	nacl.scalarMult.groupElementLength = crypto_scalarmult_BYTES;
	nacl.box.publicKeyLength = crypto_box_PUBLICKEYBYTES;
	nacl.box.secretKeyLength = crypto_box_SECRETKEYBYTES;
	nacl.box.sharedKeyLength = crypto_box_BEFORENMBYTES;
	nacl.box.nonceLength = crypto_box_NONCEBYTES;
	nacl.box.overheadLength = nacl.secretbox.overheadLength;


	var K = [
  0x428a2f98, 0xd728ae22, 0x71374491, 0x23ef65cd,
  0xb5c0fbcf, 0xec4d3b2f, 0xe9b5dba5, 0x8189dbbc,
  0x3956c25b, 0xf348b538, 0x59f111f1, 0xb605d019,
  0x923f82a4, 0xaf194f9b, 0xab1c5ed5, 0xda6d8118,
  0xd807aa98, 0xa3030242, 0x12835b01, 0x45706fbe,
  0x243185be, 0x4ee4b28c, 0x550c7dc3, 0xd5ffb4e2,
  0x72be5d74, 0xf27b896f, 0x80deb1fe, 0x3b1696b1,
  0x9bdc06a7, 0x25c71235, 0xc19bf174, 0xcf692694,
  0xe49b69c1, 0x9ef14ad2, 0xefbe4786, 0x384f25e3,
  0x0fc19dc6, 0x8b8cd5b5, 0x240ca1cc, 0x77ac9c65,
  0x2de92c6f, 0x592b0275, 0x4a7484aa, 0x6ea6e483,
  0x5cb0a9dc, 0xbd41fbd4, 0x76f988da, 0x831153b5,
  0x983e5152, 0xee66dfab, 0xa831c66d, 0x2db43210,
  0xb00327c8, 0x98fb213f, 0xbf597fc7, 0xbeef0ee4,
  0xc6e00bf3, 0x3da88fc2, 0xd5a79147, 0x930aa725,
  0x06ca6351, 0xe003826f, 0x14292967, 0x0a0e6e70,
  0x27b70a85, 0x46d22ffc, 0x2e1b2138, 0x5c26c926,
  0x4d2c6dfc, 0x5ac42aed, 0x53380d13, 0x9d95b3df,
  0x650a7354, 0x8baf63de, 0x766a0abb, 0x3c77b2a8,
  0x81c2c92e, 0x47edaee6, 0x92722c85, 0x1482353b,
  0xa2bfe8a1, 0x4cf10364, 0xa81a664b, 0xbc423001,
  0xc24b8b70, 0xd0f89791, 0xc76c51a3, 0x0654be30,
  0xd192e819, 0xd6ef5218, 0xd6990624, 0x5565a910,
  0xf40e3585, 0x5771202a, 0x106aa070, 0x32bbd1b8,
  0x19a4c116, 0xb8d2d0c8, 0x1e376c08, 0x5141ab53,
  0x2748774c, 0xdf8eeb99, 0x34b0bcb5, 0xe19b48a8,
  0x391c0cb3, 0xc5c95a63, 0x4ed8aa4a, 0xe3418acb,
  0x5b9cca4f, 0x7763e373, 0x682e6ff3, 0xd6b2b8a3,
  0x748f82ee, 0x5defb2fc, 0x78a5636f, 0x43172f60,
  0x84c87814, 0xa1f0ab72, 0x8cc70208, 0x1a6439ec,
  0x90befffa, 0x23631e28, 0xa4506ceb, 0xde82bde9,
  0xbef9a3f7, 0xb2c67915, 0xc67178f2, 0xe372532b,
  0xca273ece, 0xea26619c, 0xd186b8c7, 0x21c0c207,
  0xeada7dd6, 0xcde0eb1e, 0xf57d4f7f, 0xee6ed178,
  0x06f067aa, 0x72176fba, 0x0a637dc5, 0xa2c898a6,
  0x113f9804, 0xbef90dae, 0x1b710b35, 0x131c471b,
  0x28db77f5, 0x23047d84, 0x32caab7b, 0x40c72493,
  0x3c9ebe0a, 0x15c9bebc, 0x431d67c4, 0x9c100d4c,
  0x4cc5d4be, 0xcb3e42b6, 0x597f299c, 0xfc657e2a,
  0x5fcb6fab, 0x3ad6faec, 0x6c44198c, 0x4a475817
];

nacl.test2 = function(hh, hl, m, n) {
  var wh = new Int32Array(16), wl = new Int32Array(16),
      bh0, bh1, bh2, bh3, bh4, bh5, bh6, bh7,
      bl0, bl1, bl2, bl3, bl4, bl5, bl6, bl7,
      th, tl, i, j, h, l, a, b, c, d;

  var ah0 = hh[0],
      ah1 = hh[1],
      ah2 = hh[2],
      ah3 = hh[3],
      ah4 = hh[4],
      ah5 = hh[5],
      ah6 = hh[6],
      ah7 = hh[7],

      al0 = hl[0],
      al1 = hl[1],
      al2 = hl[2],
      al3 = hl[3],
      al4 = hl[4],
      al5 = hl[5],
      al6 = hl[6],
      al7 = hl[7];

  var pos = 0;
  while (n >= 128) {
    for (i = 0; i < 16; i++) {
      j = 8 * i + pos;
      wh[i] = (m[j+0] << 24) | (m[j+1] << 16) | (m[j+2] << 8) | m[j+3];
      wl[i] = (m[j+4] << 24) | (m[j+5] << 16) | (m[j+6] << 8) | m[j+7];
    }
    for (i = 0; i < 80; i++) {
      bh0 = ah0;
      bh1 = ah1;
      bh2 = ah2;
      bh3 = ah3;
      bh4 = ah4;
      bh5 = ah5;
      bh6 = ah6;
      bh7 = ah7;

      bl0 = al0;
      bl1 = al1;
      bl2 = al2;
      bl3 = al3;
      bl4 = al4;
      bl5 = al5;
      bl6 = al6;
      bl7 = al7;

      // add
      h = ah7;
      l = al7;

      a = l & 0xffff; b = l >>> 16;
      c = h & 0xffff; d = h >>> 16;

      // Sigma1
      h = ((ah4 >>> 14) | (al4 << (32-14))) ^ ((ah4 >>> 18) | (al4 << (32-18))) ^ ((al4 >>> (41-32)) | (ah4 << (32-(41-32))));
      l = ((al4 >>> 14) | (ah4 << (32-14))) ^ ((al4 >>> 18) | (ah4 << (32-18))) ^ ((ah4 >>> (41-32)) | (al4 << (32-(41-32))));

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      // Ch
      h = (ah4 & ah5) ^ (~ah4 & ah6);
      l = (al4 & al5) ^ (~al4 & al6);

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      // K
      h = K[i*2];
      l = K[i*2+1];

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      // w
      h = wh[i%16];
      l = wl[i%16];

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      b += a >>> 16;
      c += b >>> 16;
      d += c >>> 16;

      th = c & 0xffff | d << 16;
      tl = a & 0xffff | b << 16;

      // add
      h = th;
      l = tl;

      a = l & 0xffff; b = l >>> 16;
      c = h & 0xffff; d = h >>> 16;

      // Sigma0
      h = ((ah0 >>> 28) | (al0 << (32-28))) ^ ((al0 >>> (34-32)) | (ah0 << (32-(34-32)))) ^ ((al0 >>> (39-32)) | (ah0 << (32-(39-32))));
      l = ((al0 >>> 28) | (ah0 << (32-28))) ^ ((ah0 >>> (34-32)) | (al0 << (32-(34-32)))) ^ ((ah0 >>> (39-32)) | (al0 << (32-(39-32))));

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      // Maj
      h = (ah0 & ah1) ^ (ah0 & ah2) ^ (ah1 & ah2);
      l = (al0 & al1) ^ (al0 & al2) ^ (al1 & al2);

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      b += a >>> 16;
      c += b >>> 16;
      d += c >>> 16;

      bh7 = (c & 0xffff) | (d << 16);
      bl7 = (a & 0xffff) | (b << 16);

      // add
      h = bh3;
      l = bl3;

      a = l & 0xffff; b = l >>> 16;
      c = h & 0xffff; d = h >>> 16;

      h = th;
      l = tl;

      a += l & 0xffff; b += l >>> 16;
      c += h & 0xffff; d += h >>> 16;

      b += a >>> 16;
      c += b >>> 16;
      d += c >>> 16;

      bh3 = (c & 0xffff) | (d << 16);
      bl3 = (a & 0xffff) | (b << 16);

      ah1 = bh0;
      ah2 = bh1;
      ah3 = bh2;
      ah4 = bh3;
      ah5 = bh4;
      ah6 = bh5;
      ah7 = bh6;
      ah0 = bh7;

      al1 = bl0;
      al2 = bl1;
      al3 = bl2;
      al4 = bl3;
      al5 = bl4;
      al6 = bl5;
      al7 = bl6;
      al0 = bl7;

      if (i%16 === 15) {
        for (j = 0; j < 16; j++) {
          // add
          h = wh[j];
          l = wl[j];

          a = l & 0xffff; b = l >>> 16;
          c = h & 0xffff; d = h >>> 16;

          h = wh[(j+9)%16];
          l = wl[(j+9)%16];

          a += l & 0xffff; b += l >>> 16;
          c += h & 0xffff; d += h >>> 16;

          // sigma0
          th = wh[(j+1)%16];
          tl = wl[(j+1)%16];
          h = ((th >>> 1) | (tl << (32-1))) ^ ((th >>> 8) | (tl << (32-8))) ^ (th >>> 7);
          l = ((tl >>> 1) | (th << (32-1))) ^ ((tl >>> 8) | (th << (32-8))) ^ ((tl >>> 7) | (th << (32-7)));

          a += l & 0xffff; b += l >>> 16;
          c += h & 0xffff; d += h >>> 16;

          // sigma1
          th = wh[(j+14)%16];
          tl = wl[(j+14)%16];
          h = ((th >>> 19) | (tl << (32-19))) ^ ((tl >>> (61-32)) | (th << (32-(61-32)))) ^ (th >>> 6);
          l = ((tl >>> 19) | (th << (32-19))) ^ ((th >>> (61-32)) | (tl << (32-(61-32)))) ^ ((tl >>> 6) | (th << (32-6)));

          a += l & 0xffff; b += l >>> 16;
          c += h & 0xffff; d += h >>> 16;

          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;

          wh[j] = (c & 0xffff) | (d << 16);
          wl[j] = (a & 0xffff) | (b << 16);
        }
      }
    }

    // add
    h = ah0;
    l = al0;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[0];
    l = hl[0];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[0] = ah0 = (c & 0xffff) | (d << 16);
    hl[0] = al0 = (a & 0xffff) | (b << 16);

    h = ah1;
    l = al1;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[1];
    l = hl[1];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[1] = ah1 = (c & 0xffff) | (d << 16);
    hl[1] = al1 = (a & 0xffff) | (b << 16);

    h = ah2;
    l = al2;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[2];
    l = hl[2];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[2] = ah2 = (c & 0xffff) | (d << 16);
    hl[2] = al2 = (a & 0xffff) | (b << 16);

    h = ah3;
    l = al3;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[3];
    l = hl[3];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[3] = ah3 = (c & 0xffff) | (d << 16);
    hl[3] = al3 = (a & 0xffff) | (b << 16);

    h = ah4;
    l = al4;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[4];
    l = hl[4];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[4] = ah4 = (c & 0xffff) | (d << 16);
    hl[4] = al4 = (a & 0xffff) | (b << 16);

    h = ah5;
    l = al5;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[5];
    l = hl[5];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[5] = ah5 = (c & 0xffff) | (d << 16);
    hl[5] = al5 = (a & 0xffff) | (b << 16);

    h = ah6;
    l = al6;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[6];
    l = hl[6];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[6] = ah6 = (c & 0xffff) | (d << 16);
    hl[6] = al6 = (a & 0xffff) | (b << 16);

    h = ah7;
    l = al7;

    a = l & 0xffff; b = l >>> 16;
    c = h & 0xffff; d = h >>> 16;

    h = hh[7];
    l = hl[7];

    a += l & 0xffff; b += l >>> 16;
    c += h & 0xffff; d += h >>> 16;

    b += a >>> 16;
    c += b >>> 16;
    d += c >>> 16;

    hh[7] = ah7 = (c & 0xffff) | (d << 16);
    hl[7] = al7 = (a & 0xffff) | (b << 16);

    pos += 128;
    n -= 128;
  }

  return n;
}

nacl.test = function(h, m) {
		const indexes = copyToWasmMemory({
			h: {array: h},
			m: {array: m},
			alloc: {paddingBefore: 128}
		});
		wasmInstance.exports.crypto_hashblocks(
			indexes.h,
			indexes.m,
			m.length,
			indexes.alloc
		);
		return new Uint8Array(wasmMemory.buffer.slice(indexes.h, indexes.h + h.length));
	}

	/*nacl.sign = (msg, secretKey) => {
		checkArrayTypes(msg, secretKey);
		if (secretKey.length !== crypto_sign_SECRETKEYBYTES)
			throw new Error('bad secret key size');
		var signedMsg = new Uint8Array(crypto_sign_BYTES+msg.length);
		crypto_sign(signedMsg, msg, msg.length, secretKey);
		return signedMsg;
	};

	nacl.sign.open = (signedMsg, publicKey) => {
		checkArrayTypes(signedMsg, publicKey);
		if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
			throw new Error('bad public key size');
		var tmp = new Uint8Array(signedMsg.length);
		var mlen = crypto_sign_open(tmp, signedMsg, signedMsg.length, publicKey);
		if (mlen < 0) return null;
		var m = new Uint8Array(mlen);
		for (var i = 0; i < m.length; i++) m[i] = tmp[i];
		return m;
	};

	nacl.sign.detached = (msg, secretKey) => {
		var signedMsg = nacl.sign(msg, secretKey);
		var sig = new Uint8Array(crypto_sign_BYTES);
		for (var i = 0; i < sig.length; i++) sig[i] = signedMsg[i];
		return sig;
	};

	nacl.sign.detached.verify = (msg, sig, publicKey) => {
		checkArrayTypes(msg, sig, publicKey);
		if (sig.length !== crypto_sign_BYTES)
			throw new Error('bad signature size');
		if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
			throw new Error('bad public key size');
		var sm = new Uint8Array(crypto_sign_BYTES + msg.length);
		var m = new Uint8Array(crypto_sign_BYTES + msg.length);
		var i;
		for (i = 0; i < crypto_sign_BYTES; i++) sm[i] = sig[i];
		for (i = 0; i < msg.length; i++) sm[i+crypto_sign_BYTES] = msg[i];
		return (crypto_sign_open(m, sm, sm.length, publicKey) >= 0);
	};

	nacl.sign.keyPair = () => {
		var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
		var sk = new Uint8Array(crypto_sign_SECRETKEYBYTES);
		crypto_sign_keypair(pk, sk);
		return {publicKey: pk, secretKey: sk};
	};

	nacl.sign.keyPair.fromSecretKey = (secretKey) => {
		checkArrayTypes(secretKey);
		if (secretKey.length !== crypto_sign_SECRETKEYBYTES)
			throw new Error('bad secret key size');
		var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
		for (var i = 0; i < pk.length; i++) pk[i] = secretKey[32+i];
		return {publicKey: pk, secretKey: new Uint8Array(secretKey)};
	};

	nacl.sign.keyPair.fromSeed = (seed) => {
		checkArrayTypes(seed);
		if (seed.length !== crypto_sign_SEEDBYTES)
			throw new Error('bad seed size');
		var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
		var sk = new Uint8Array(crypto_sign_SECRETKEYBYTES);
		for (var i = 0; i < 32; i++) sk[i] = seed[i];
		crypto_sign_keypair(pk, sk, true);
		return {publicKey: pk, secretKey: sk};
	};

	nacl.sign.publicKeyLength = crypto_sign_PUBLICKEYBYTES;
	nacl.sign.secretKeyLength = crypto_sign_SECRETKEYBYTES;
	nacl.sign.seedLength = crypto_sign_SEEDBYTES;
	nacl.sign.signatureLength = crypto_sign_BYTES;

	nacl.hash = (msg) => {
		checkArrayTypes(msg);
		var h = new Uint8Array(crypto_hash_BYTES);
		crypto_hash(h, msg, msg.length);
		return h;
	};

	nacl.hash.hashLength = crypto_hash_BYTES;*/

	nacl.verify = (x, y) => {
		checkArrayTypes(x, y);
		// Zero length arguments are considered not equal.
		if (x.length === 0 || y.length === 0) return false;
		if (x.length !== y.length) return false;

		const indexes = copyToWasmMemory({
			x: {array: x},
			y: {array: y},
		});
		const result = wasmInstance.exports.vn(
			indexes.x,
			indexes.y,
			x.length
		);
		return result === 0 ? true : false;
	};

	nacl.setPRNG = fn => {
		randombytes = fn;
	};

	(() => {
		const base64Lookup = [];
		const inverseBase64Lookup = [];
		const code = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

		for (let i = 0; i < code.length; i++) {
			base64Lookup[i] = code[i];
			inverseBase64Lookup[code.charCodeAt(i)] = i;
		}
		inverseBase64Lookup['-'.charCodeAt(0)] = 62;
		inverseBase64Lookup['_'.charCodeAt(0)] = 63;

		function base64ToUint8Array(string) {
			string = string.replace(/[^A-Za-z0-9\/\+]/g, '');

			const length = string.length;
			let completeChunksLength;
			let bytesInFinalChunk;
			if (length % 4) {
				bytesInFinalChunk = length % 4 - 1;
				completeChunksLength = Math.floor(length / 4) * 4;
			} else {
				bytesInFinalChunk = string[length - 2] === '=' ? 1 : string[length - 1] === '=' ? 2 : 0;
				completeChunksLength = bytesInFinalChunk > 0 ? length - 4 : length;
			}

			const array = new Uint8Array(completeChunksLength / 4 * 3 + bytesInFinalChunk);

			let outputIndex = 0;
			let inputIndex = 0;

			while (inputIndex < completeChunksLength) {
				const quadruplet = (inverseBase64Lookup[string.charCodeAt(inputIndex++)] << 18) |
					(inverseBase64Lookup[string.charCodeAt(inputIndex++)] << 12) |
					(inverseBase64Lookup[string.charCodeAt(inputIndex++)] << 6) |
					inverseBase64Lookup[string.charCodeAt(inputIndex++)];
				array[outputIndex++] = (quadruplet >> 16) & 0xFF;
				array[outputIndex++] = (quadruplet >> 8) & 0xFF;
				array[outputIndex++] = quadruplet & 0xFF;
			}

			if (bytesInFinalChunk === 1) {
				const doublet = (inverseBase64Lookup[string.charCodeAt(inputIndex)] << 2) |
					(inverseBase64Lookup[string.charCodeAt(inputIndex + 1)] >> 4);
				array[outputIndex++] = doublet & 0xFF;
			} else if (bytesInFinalChunk === 2) {
				const triplet = (inverseBase64Lookup[string.charCodeAt(inputIndex)] << 10) |
					(inverseBase64Lookup[string.charCodeAt(inputIndex + 1)] << 4) |
					(inverseBase64Lookup[string.charCodeAt(inputIndex + 2)] >> 2);
				array[outputIndex++] = (triplet >> 8) & 0xFF;
				array[outputIndex++] = triplet & 0xFF;
			}

			return array;
		}

		const bytes = base64ToUint8Array(wasmCode);
		const binaryCode = bytes.buffer;

		wasmInstancePromise = WebAssembly.instantiate(binaryCode, {js: {mem: wasmMemory}});
		wasmInstancePromise
			.then(result => {
				wasmInstance = result.instance;
			});

		const crypto = typeof self !== 'undefined' ? (self.crypto || self.msCrypto) : null;
		if (crypto && crypto.getRandomValues) {
			// Browsers.
			const QUOTA = 65536;
			nacl.setPRNG((x, n) => {
				for (let i = 0; i < n; i += QUOTA) {
					crypto.getRandomValues(x.subarray(i, i + Math.min(n - i, QUOTA)));
				}
			});
		} else if (typeof require !== 'undefined') {
			// Node.js.
			crypto = require('crypto');
			if (crypto && crypto.randomBytes) {
				nacl.setPRNG((x, n) => {
					const buffer = crypto.randomBytes(n);
					x.set(new Uint8Array(buffer));
					for (let i = 0; i < buffer.length; i++) {
						buffer[i] = 0;
					}
				});
			}
		}
	})();

	/*function set25519(r, a) {
		var i;
		for (i = 0; i < 16; i++) r[i] = a[i]|0;
	}

	function neq25519(a, b) {
		var c = new Uint8Array(32), d = new Uint8Array(32);
		pack25519(c, a);
		pack25519(d, b);
		return crypto_verify_32(c, 0, d, 0);
	}

	function par25519(a) {
		var d = new Uint8Array(32);
		pack25519(d, a);
		return d[0] & 1;
	}

	function pow2523(o, i) {
		var c = gf();
		var a;
		for (a = 0; a < 16; a++) c[a] = i[a];
		for (a = 250; a >= 0; a--) {
				S(c, c);
				if(a !== 1) M(c, c, i);
		}
		for (a = 0; a < 16; a++) o[a] = c[a];
	}

	function crypto_box_keypair(y, x) {
		randombytes(x, 32);
		return crypto_scalarmult_base(y, x);
	}

	function crypto_box_beforenm(k, y, x) {
		var s = new Uint8Array(32);
		crypto_scalarmult(s, x, y);
		return crypto_core_hsalsa20(k, _0, s, sigma);
	}

	var crypto_box_afternm = crypto_secretbox;
	var crypto_box_open_afternm = crypto_secretbox_open;

	function crypto_box(c, m, d, n, y, x) {
		var k = new Uint8Array(32);
		crypto_box_beforenm(k, y, x);
		return crypto_box_afternm(c, m, d, n, k);
	}

	function crypto_box_open(m, c, d, n, y, x) {
		var k = new Uint8Array(32);
		crypto_box_beforenm(k, y, x);
		return crypto_box_open_afternm(m, c, d, n, k);
	}


	function crypto_hashblocks_hl(hh, hl, m, n) {
		var wh = new Int32Array(16), wl = new Int32Array(16),
				bh0, bh1, bh2, bh3, bh4, bh5, bh6, bh7,
				bl0, bl1, bl2, bl3, bl4, bl5, bl6, bl7,
				th, tl, i, j, h, l, a, b, c, d;

		var ah0 = hh[0],
				ah1 = hh[1],
				ah2 = hh[2],
				ah3 = hh[3],
				ah4 = hh[4],
				ah5 = hh[5],
				ah6 = hh[6],
				ah7 = hh[7],

				al0 = hl[0],
				al1 = hl[1],
				al2 = hl[2],
				al3 = hl[3],
				al4 = hl[4],
				al5 = hl[5],
				al6 = hl[6],
				al7 = hl[7];

		var pos = 0;
		while (n >= 128) {
			for (i = 0; i < 16; i++) {
				j = 8 * i + pos;
				wh[i] = (m[j+0] << 24) | (m[j+1] << 16) | (m[j+2] << 8) | m[j+3];
				wl[i] = (m[j+4] << 24) | (m[j+5] << 16) | (m[j+6] << 8) | m[j+7];
			}
			for (i = 0; i < 80; i++) {
				bh0 = ah0;
				bh1 = ah1;
				bh2 = ah2;
				bh3 = ah3;
				bh4 = ah4;
				bh5 = ah5;
				bh6 = ah6;
				bh7 = ah7;

				bl0 = al0;
				bl1 = al1;
				bl2 = al2;
				bl3 = al3;
				bl4 = al4;
				bl5 = al5;
				bl6 = al6;
				bl7 = al7;

				// add
				h = ah7;
				l = al7;

				a = l & 0xffff; b = l >>> 16;
				c = h & 0xffff; d = h >>> 16;

				// Sigma1
				h = ((ah4 >>> 14) | (al4 << (32-14))) ^ ((ah4 >>> 18) | (al4 << (32-18))) ^ ((al4 >>> (41-32)) | (ah4 << (32-(41-32))));
				l = ((al4 >>> 14) | (ah4 << (32-14))) ^ ((al4 >>> 18) | (ah4 << (32-18))) ^ ((ah4 >>> (41-32)) | (al4 << (32-(41-32))));

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				// Ch
				h = (ah4 & ah5) ^ (~ah4 & ah6);
				l = (al4 & al5) ^ (~al4 & al6);

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				// K
				h = K[i*2];
				l = K[i*2+1];

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				// w
				h = wh[i%16];
				l = wl[i%16];

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				b += a >>> 16;
				c += b >>> 16;
				d += c >>> 16;

				th = c & 0xffff | d << 16;
				tl = a & 0xffff | b << 16;

				// add
				h = th;
				l = tl;

				a = l & 0xffff; b = l >>> 16;
				c = h & 0xffff; d = h >>> 16;

				// Sigma0
				h = ((ah0 >>> 28) | (al0 << (32-28))) ^ ((al0 >>> (34-32)) | (ah0 << (32-(34-32)))) ^ ((al0 >>> (39-32)) | (ah0 << (32-(39-32))));
				l = ((al0 >>> 28) | (ah0 << (32-28))) ^ ((ah0 >>> (34-32)) | (al0 << (32-(34-32)))) ^ ((ah0 >>> (39-32)) | (al0 << (32-(39-32))));

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				// Maj
				h = (ah0 & ah1) ^ (ah0 & ah2) ^ (ah1 & ah2);
				l = (al0 & al1) ^ (al0 & al2) ^ (al1 & al2);

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				b += a >>> 16;
				c += b >>> 16;
				d += c >>> 16;

				bh7 = (c & 0xffff) | (d << 16);
				bl7 = (a & 0xffff) | (b << 16);

				// add
				h = bh3;
				l = bl3;

				a = l & 0xffff; b = l >>> 16;
				c = h & 0xffff; d = h >>> 16;

				h = th;
				l = tl;

				a += l & 0xffff; b += l >>> 16;
				c += h & 0xffff; d += h >>> 16;

				b += a >>> 16;
				c += b >>> 16;
				d += c >>> 16;

				bh3 = (c & 0xffff) | (d << 16);
				bl3 = (a & 0xffff) | (b << 16);

				ah1 = bh0;
				ah2 = bh1;
				ah3 = bh2;
				ah4 = bh3;
				ah5 = bh4;
				ah6 = bh5;
				ah7 = bh6;
				ah0 = bh7;

				al1 = bl0;
				al2 = bl1;
				al3 = bl2;
				al4 = bl3;
				al5 = bl4;
				al6 = bl5;
				al7 = bl6;
				al0 = bl7;

				if (i%16 === 15) {
					for (j = 0; j < 16; j++) {
						// add
						h = wh[j];
						l = wl[j];

						a = l & 0xffff; b = l >>> 16;
						c = h & 0xffff; d = h >>> 16;

						h = wh[(j+9)%16];
						l = wl[(j+9)%16];

						a += l & 0xffff; b += l >>> 16;
						c += h & 0xffff; d += h >>> 16;

						// sigma0
						th = wh[(j+1)%16];
						tl = wl[(j+1)%16];
						h = ((th >>> 1) | (tl << (32-1))) ^ ((th >>> 8) | (tl << (32-8))) ^ (th >>> 7);
						l = ((tl >>> 1) | (th << (32-1))) ^ ((tl >>> 8) | (th << (32-8))) ^ ((tl >>> 7) | (th << (32-7)));

						a += l & 0xffff; b += l >>> 16;
						c += h & 0xffff; d += h >>> 16;

						// sigma1
						th = wh[(j+14)%16];
						tl = wl[(j+14)%16];
						h = ((th >>> 19) | (tl << (32-19))) ^ ((tl >>> (61-32)) | (th << (32-(61-32)))) ^ (th >>> 6);
						l = ((tl >>> 19) | (th << (32-19))) ^ ((th >>> (61-32)) | (tl << (32-(61-32)))) ^ ((tl >>> 6) | (th << (32-6)));

						a += l & 0xffff; b += l >>> 16;
						c += h & 0xffff; d += h >>> 16;

						b += a >>> 16;
						c += b >>> 16;
						d += c >>> 16;

						wh[j] = (c & 0xffff) | (d << 16);
						wl[j] = (a & 0xffff) | (b << 16);
					}
				}
			}

			// add
			h = ah0;
			l = al0;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[0];
			l = hl[0];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[0] = ah0 = (c & 0xffff) | (d << 16);
			hl[0] = al0 = (a & 0xffff) | (b << 16);

			h = ah1;
			l = al1;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[1];
			l = hl[1];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[1] = ah1 = (c & 0xffff) | (d << 16);
			hl[1] = al1 = (a & 0xffff) | (b << 16);

			h = ah2;
			l = al2;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[2];
			l = hl[2];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[2] = ah2 = (c & 0xffff) | (d << 16);
			hl[2] = al2 = (a & 0xffff) | (b << 16);

			h = ah3;
			l = al3;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[3];
			l = hl[3];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[3] = ah3 = (c & 0xffff) | (d << 16);
			hl[3] = al3 = (a & 0xffff) | (b << 16);

			h = ah4;
			l = al4;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[4];
			l = hl[4];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[4] = ah4 = (c & 0xffff) | (d << 16);
			hl[4] = al4 = (a & 0xffff) | (b << 16);

			h = ah5;
			l = al5;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[5];
			l = hl[5];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[5] = ah5 = (c & 0xffff) | (d << 16);
			hl[5] = al5 = (a & 0xffff) | (b << 16);

			h = ah6;
			l = al6;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[6];
			l = hl[6];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[6] = ah6 = (c & 0xffff) | (d << 16);
			hl[6] = al6 = (a & 0xffff) | (b << 16);

			h = ah7;
			l = al7;

			a = l & 0xffff; b = l >>> 16;
			c = h & 0xffff; d = h >>> 16;

			h = hh[7];
			l = hl[7];

			a += l & 0xffff; b += l >>> 16;
			c += h & 0xffff; d += h >>> 16;

			b += a >>> 16;
			c += b >>> 16;
			d += c >>> 16;

			hh[7] = ah7 = (c & 0xffff) | (d << 16);
			hl[7] = al7 = (a & 0xffff) | (b << 16);

			pos += 128;
			n -= 128;
		}

		return n;
	}

	function crypto_hash(out, m, n) {
		var hh = new Int32Array(8),
				hl = new Int32Array(8),
				x = new Uint8Array(256),
				i, b = n;

		hh[0] = 0x6a09e667;
		hh[1] = 0xbb67ae85;
		hh[2] = 0x3c6ef372;
		hh[3] = 0xa54ff53a;
		hh[4] = 0x510e527f;
		hh[5] = 0x9b05688c;
		hh[6] = 0x1f83d9ab;
		hh[7] = 0x5be0cd19;

		hl[0] = 0xf3bcc908;
		hl[1] = 0x84caa73b;
		hl[2] = 0xfe94f82b;
		hl[3] = 0x5f1d36f1;
		hl[4] = 0xade682d1;
		hl[5] = 0x2b3e6c1f;
		hl[6] = 0xfb41bd6b;
		hl[7] = 0x137e2179;

		crypto_hashblocks_hl(hh, hl, m, n);
		n %= 128;

		for (i = 0; i < n; i++) x[i] = m[b-n+i];
		x[n] = 128;

		n = 256-128*(n<112?1:0);
		x[n-9] = 0;
		ts64(x, n-8,  (b / 0x20000000) | 0, b << 3);
		crypto_hashblocks_hl(hh, hl, x, n);

		for (i = 0; i < 8; i++) ts64(out, 8*i, hh[i], hl[i]);

		return 0;
	}

	function add(p, q) {
		var a = gf(), b = gf(), c = gf(),
				d = gf(), e = gf(), f = gf(),
				g = gf(), h = gf(), t = gf();

		Z(a, p[1], p[0]);
		Z(t, q[1], q[0]);
		M(a, a, t);
		A(b, p[0], p[1]);
		A(t, q[0], q[1]);
		M(b, b, t);
		M(c, p[3], q[3]);
		M(c, c, D2);
		M(d, p[2], q[2]);
		A(d, d, d);
		Z(e, b, a);
		Z(f, d, c);
		A(g, d, c);
		A(h, b, a);

		M(p[0], e, f);
		M(p[1], h, g);
		M(p[2], g, f);
		M(p[3], e, h);
	}

	function cswap(p, q, b) {
		var i;
		for (i = 0; i < 4; i++) {
			sel25519(p[i], q[i], b);
		}
	}

	function pack(r, p) {
		var tx = gf(), ty = gf(), zi = gf();
		inv25519(zi, p[2]);
		M(tx, p[0], zi);
		M(ty, p[1], zi);
		pack25519(r, ty);
		r[31] ^= par25519(tx) << 7;
	}

	function scalarmult(p, q, s) {
		var b, i;
		set25519(p[0], gf0);
		set25519(p[1], gf1);
		set25519(p[2], gf1);
		set25519(p[3], gf0);
		for (i = 255; i >= 0; --i) {
			b = (s[(i/8)|0] >> (i&7)) & 1;
			cswap(p, q, b);
			add(q, p);
			add(p, p);
			cswap(p, q, b);
		}
	}

	function scalarbase(p, s) {
		var q = [gf(), gf(), gf(), gf()];
		set25519(q[0], X);
		set25519(q[1], Y);
		set25519(q[2], gf1);
		M(q[3], X, Y);
		scalarmult(p, q, s);
	}

	function crypto_sign_keypair(pk, sk, seeded) {
		var d = new Uint8Array(64);
		var p = [gf(), gf(), gf(), gf()];
		var i;

		if (!seeded) randombytes(sk, 32);
		crypto_hash(d, sk, 32);
		d[0] &= 248;
		d[31] &= 127;
		d[31] |= 64;

		scalarbase(p, d);
		pack(pk, p);

		for (i = 0; i < 32; i++) sk[i+32] = pk[i];
		return 0;
	}

	function modL(r, x) {
		var carry, i, j, k;
		for (i = 63; i >= 32; --i) {
			carry = 0;
			for (j = i - 32, k = i - 12; j < k; ++j) {
				x[j] += carry - 16 * x[i] * L[j - (i - 32)];
				carry = (x[j] + 128) >> 8;
				x[j] -= carry * 256;
			}
			x[j] += carry;
			x[i] = 0;
		}
		carry = 0;
		for (j = 0; j < 32; j++) {
			x[j] += carry - (x[31] >> 4) * L[j];
			carry = x[j] >> 8;
			x[j] &= 255;
		}
		for (j = 0; j < 32; j++) x[j] -= carry * L[j];
		for (i = 0; i < 32; i++) {
			x[i+1] += x[i] >> 8;
			r[i] = x[i] & 255;
		}
	}

	function reduce(r) {
		var x = new Float64Array(64), i;
		for (i = 0; i < 64; i++) x[i] = r[i];
		for (i = 0; i < 64; i++) r[i] = 0;
		modL(r, x);
	}

	// Note: difference from C - smlen returned, not passed as argument.
	function crypto_sign(sm, m, n, sk) {
		var d = new Uint8Array(64), h = new Uint8Array(64), r = new Uint8Array(64);
		var i, j, x = new Float64Array(64);
		var p = [gf(), gf(), gf(), gf()];

		crypto_hash(d, sk, 32);
		d[0] &= 248;
		d[31] &= 127;
		d[31] |= 64;

		var smlen = n + 64;
		for (i = 0; i < n; i++) sm[64 + i] = m[i];
		for (i = 0; i < 32; i++) sm[32 + i] = d[32 + i];

		crypto_hash(r, sm.subarray(32), n+32);
		reduce(r);
		scalarbase(p, r);
		pack(sm, p);

		for (i = 32; i < 64; i++) sm[i] = sk[i];
		crypto_hash(h, sm, n + 64);
		reduce(h);

		for (i = 0; i < 64; i++) x[i] = 0;
		for (i = 0; i < 32; i++) x[i] = r[i];
		for (i = 0; i < 32; i++) {
			for (j = 0; j < 32; j++) {
				x[i+j] += h[i] * d[j];
			}
		}

		modL(sm.subarray(32), x);
		return smlen;
	}

	function unpackneg(r, p) {
		var t = gf(), chk = gf(), num = gf(),
				den = gf(), den2 = gf(), den4 = gf(),
				den6 = gf();

		set25519(r[2], gf1);
		unpack25519(r[1], p);
		S(num, r[1]);
		M(den, num, D);
		Z(num, num, r[2]);
		A(den, r[2], den);

		S(den2, den);
		S(den4, den2);
		M(den6, den4, den2);
		M(t, den6, num);
		M(t, t, den);

		pow2523(t, t);
		M(t, t, num);
		M(t, t, den);
		M(t, t, den);
		M(r[0], t, den);

		S(chk, r[0]);
		M(chk, chk, den);
		if (neq25519(chk, num)) M(r[0], r[0], I);

		S(chk, r[0]);
		M(chk, chk, den);
		if (neq25519(chk, num)) return -1;

		if (par25519(r[0]) === (p[31]>>7)) Z(r[0], gf0, r[0]);

		M(r[3], r[0], r[1]);
		return 0;
	}

	function crypto_sign_open(m, sm, n, pk) {
		var i, mlen;
		var t = new Uint8Array(32), h = new Uint8Array(64);
		var p = [gf(), gf(), gf(), gf()],
				q = [gf(), gf(), gf(), gf()];

		mlen = -1;
		if (n < 64) return -1;

		if (unpackneg(q, pk)) return -1;

		for (i = 0; i < n; i++) m[i] = sm[i];
		for (i = 0; i < 32; i++) m[i+32] = pk[i];
		crypto_hash(h, m, n);
		reduce(h);
		scalarmult(p, q, h);

		scalarbase(q, sm.subarray(32));
		add(p, q);
		pack(t, p);

		n -= 64;
		if (crypto_verify_32(sm, 0, t, 0)) {
			for (i = 0; i < n; i++) m[i] = 0;
			return -1;
		}

		for (i = 0; i < n; i++) m[i] = sm[i + 64];
		mlen = n;
		return mlen;
	}*/
})(typeof module !== 'undefined' && module.exports ? module.exports : (self.nacl_wasm = self.nacl_wasm || {}));
