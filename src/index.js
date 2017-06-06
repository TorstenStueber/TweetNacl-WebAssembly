(function () {
	const base64Lookup = [];
	const inverseBase64Lookup = [];
	const code = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

	for (let i = 0; i < code.length; i++) {
		base64Lookup[i] = code[i];
		inverseBase64Lookup[code.charCodeAt(i)] = i;
	}
	inverseBase64Lookup['-'.charCodeAt(0)] = 62;
	inverseBase64Lookup['_'.charCodeAt(0)] = 63;

	const memory = new WebAssembly.Memory({initial: 2000});
	const importObject = {
		js: {
			mem: memory
		}
	};


	const bytes = base64ToUint8Array(window.wasmCode);
	const binaryCode = bytes.buffer;

	WebAssembly.instantiate(binaryCode, importObject)
		.then(result => {
			run(result.instance);
		});

	function compareArrays(arr1, arr2, length) {
		for (let i = 0; i < length; i++) {
			if (arr1[i] !== arr2[i]) {
				console.log(arr1);
				console.log(arr2);
				return false;
			}
		}
		return true;
	}

	function combineArrays(arrayObject) {
		let currentStart = 0;
		const indexObject = {};
		Object.keys(arrayObject).forEach(name => {
			indexObject[name] = currentStart;
			const array = arrayObject[name];
			const memoryArray = new Uint8Array(memory.buffer, currentStart, array.length);
			for (let i = 0; i < array.length; i++) {
				memoryArray[i] = array[i];
			}

			const alignedLength = Math.ceil(array.length / 8) * 8;
			currentStart += alignedLength;
		});

		return indexObject;
	}

	function fillRandom(array) {
		for (let i = 0; i < array.length; i++) {
			array[i] = Math.floor(Math.random() * 256);
		}
	}

	function testCryptoStreamSalsa20Xor(instance) {
		const b = 23423323;

		const c = new Uint8Array(b);
		const c2 = new Uint8Array(b);
		const m = new Uint8Array(b);
		const n = new Uint8Array(8);
		const k = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(80);

		fillRandom(m);
		fillRandom(n);
		fillRandom(k);

		window.crypto.subtle.generateKey({
			name: 'AES-GCM',
			length: 256
		}, false, ['encrypt']
		).then(key => {
			var rand = window.crypto.getRandomValues(new Uint8Array(12));
			console.time('Native');
			window.crypto.subtle.encrypt({
				name: "AES-GCM",
				iv: rand
			}, key, m)
			.then(() => {
				console.timeEnd('Native');

				const indexes = combineArrays({c, m, n, k, sigma, alloc});
				console.time('Wasm');
				instance.exports.crypto_stream_salsa20_xor(
					indexes.c,
					indexes.m,
					b,
					indexes.n,
					indexes.k,
					indexes.sigma,
					indexes.alloc
				);
				console.timeEnd('Wasm');

				console.time('JavaScript');
				window.nacl.lowlevel.crypto_stream_salsa20_xor(c2, 0, m, 0, b, n, k);
				console.timeEnd('JavaScript');

				console.log('testCryptoStreamSalsa20Xor',
					compareArrays(new Uint8Array(memory.buffer, indexes.c, b), c2, b) ? 'Equal' : 'Not equal');
			})
		})
	}

	function testCryptoStreamSalsa20(instance) {
		const b = 23423323;

		const c = new Uint8Array(b);
		const c2 = new Uint8Array(b);
		const n = new Uint8Array(8);
		const k = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(80);

		fillRandom(n);
		fillRandom(k);

		const indexes = combineArrays({c, n, k, sigma, alloc});

		console.time('Wasm');
		instance.exports.crypto_stream_salsa20(
			indexes.c,
			b,
			indexes.n,
			indexes.k,
			indexes.sigma,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		window.nacl.lowlevel.crypto_stream_salsa20(c2, 0, b, n, k);
		console.timeEnd('JavaScript');

		console.log('testCryptoStreamSalsa20',
			compareArrays(new Uint8Array(memory.buffer, indexes.c, b), c2, b) ? 'Equal' : 'Not equal');
	}

	function testCryptoCoreHSalsa20(instance) {
		const o = new Uint8Array(32);
		const o2 = new Uint8Array(32);
		const p = new Uint8Array(16);
		const k = new Uint8Array(32);
		const c = new Uint8Array(16);

		fillRandom(p);
		fillRandom(k);
		fillRandom(c);

		const indexes = combineArrays({o, p, k, c});

		console.time('Wasm');
		instance.exports.core_hsalsa20(
			indexes.o,
			indexes.p,
			indexes.k,
			indexes.c
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		window.nacl.lowlevel.crypto_core_hsalsa20(o2, p, k, c);
		console.timeEnd('JavaScript');

		console.log('testCryptoCoreHSalsa20',
			compareArrays(new Uint8Array(memory.buffer, indexes.o, 32), o2, 32) ? 'Equal' : 'Not equal');
	}

	function testCryptoStreamXor(instance) {
		const d = 23423323;

		const c = new Uint8Array(d);
		const c2 = new Uint8Array(d);
		const m = new Uint8Array(d);
		const n = new Uint8Array(24);
		const k = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(120);

		fillRandom(m);
		fillRandom(n);
		fillRandom(k);

		const indexes = combineArrays({c, m, n, k, sigma, alloc});

		console.time('Wasm');
		instance.exports.crypto_stream_xor(
			indexes.c,
			indexes.m,
			d,
			indexes.n,
			indexes.k,
			indexes.sigma,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		window.nacl.lowlevel.crypto_stream_xor(c2, 0, m, 0, d, n, k);
		console.timeEnd('JavaScript');

		console.log('testCryptoStreamXor',
			compareArrays(new Uint8Array(memory.buffer, indexes.c, d), c2, d) ? 'Equal' : 'Not equal');
	}

	function testCryptoStream(instance) {
		const d = 23423323;

		const c = new Uint8Array(d);
		const c2 = new Uint8Array(d);
		const n = new Uint8Array(24);
		const k = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(120);

		fillRandom(n);
		fillRandom(k);

		const indexes = combineArrays({c, n, k, sigma, alloc});

		console.time('Wasm');
		instance.exports.crypto_stream(
			indexes.c,
			d,
			indexes.n,
			indexes.k,
			indexes.sigma,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		window.nacl.lowlevel.crypto_stream(c2, 0, d, n, k);
		console.timeEnd('JavaScript');

		console.log('testCryptoStream',
			compareArrays(new Uint8Array(memory.buffer, indexes.c, d), c2, d) ? 'Equal' : 'Not equal');
	}

	function testCryptoOnetimeAuth(instance) {
		const bytes = 23423323;

		const mac = new Uint8Array(16);
		const mac2 = new Uint8Array(16);
		const m = new Uint8Array(bytes);
		const key = new Uint8Array(32);
		const alloc = new Uint8Array(80);

		fillRandom(m);
		fillRandom(key);

		const indexes = combineArrays({mac, m, key, alloc});

		console.time('Wasm');
		instance.exports.crypto_onetimeauth(
			indexes.mac,
			indexes.m,
			bytes,
			indexes.key,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		window.nacl.lowlevel.crypto_onetimeauth(mac2, 0, m, 0, bytes, key);
		console.timeEnd('JavaScript');

		console.log('testPoly1305Auth',
			compareArrays(new Uint8Array(memory.buffer, indexes.mac, 16), mac2, 16) ? 'Equal' : 'Not equal');
	}

	function testCryptoSecretbox(instance) {
		const d = 23423323;

		const c = new Uint8Array(d);
		const c2 = new Uint8Array(d);
		const m = new Uint8Array(d);
		const n = new Uint8Array(24);
		const key = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(120);

		fillRandom(m);
		fillRandom(n);
		fillRandom(key);

		const indexes = combineArrays({c, m, n, key, sigma, alloc});

		console.time('Wasm');
		instance.exports.crypto_secretbox(
			indexes.c,
			indexes.m,
			d,
			indexes.n,
			indexes.key,
			indexes.sigma,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		window.nacl.lowlevel.crypto_secretbox(c2, m, d, n, key);
		console.timeEnd('JavaScript');

		console.log('testCryptoSecretbox',
			compareArrays(new Uint8Array(memory.buffer, indexes.c, d), c2, d) ? 'Equal' : 'Not equal');
	}

	function testCryptoSecretboxOpen(instance) {
		const d = 23423323;

		const c = new Uint8Array(d);
		const m = new Uint8Array(d);
		const m2 = new Uint8Array(d);
		const m3 = new Uint8Array(d);
		const n = new Uint8Array(24);
		const key = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(152);

		fillRandom(m);
		fillRandom(n);
		fillRandom(key);
		for (let i = 0; i < 32; i++) {
			m[i] = 0;
		}

		const indexes = combineArrays({c, m, n, key, sigma, alloc});

		instance.exports.crypto_secretbox(
			indexes.c,
			indexes.m,
			d,
			indexes.n,
			indexes.key,
			indexes.sigma,
			indexes.alloc
		);

		const cArray = new Uint8Array(memory.buffer, indexes.c, d)
		for (let i = 0; i < c.length; i++) {
			c[i] = cArray[i];
		}

		console.time('Wasm');
		const result1 = instance.exports.crypto_secretbox_open(
			indexes.m3,
			indexes.c,
			d,
			indexes.n,
			indexes.key,
			indexes.sigma,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		const result2 = window.nacl.lowlevel.crypto_secretbox_open(m2, c, d, n, key);
		console.timeEnd('JavaScript');

		console.log('testCryptoSecretboxOpen',
			compareArrays(new Uint8Array(memory.buffer, indexes.m3, d), m2, d) &&
			compareArrays([result1], [result2], 1) ? 'Equal' : 'Not equal');
	}

	function testNaclSecretbox(instance) {
		const d = 23423323;

		const msg = new Uint8Array(d);
		const nonce = new Uint8Array(24);
		const key = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc = new Uint8Array(184 + Math.ceil(d / 8) * 16);

		fillRandom(msg);
		fillRandom(nonce);
		fillRandom(key);

		const indexes = combineArrays({msg, nonce, key, sigma, alloc});

		console.time('Wasm');
		const c = instance.exports.nacl_secretbox(
			indexes.msg,
			d,
			indexes.nonce,
			indexes.key,
			indexes.sigma,
			indexes.alloc
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		const c2 = window.nacl.secretbox(msg, nonce, key);
		console.timeEnd('JavaScript');

		console.log('testNaclSecretbox',
			compareArrays(new Uint8Array(memory.buffer, c, d + 16), c2, d + 16) ? 'Equal' : 'Not equal');
	}

	function testNaclSecretboxOpen(instance) {
		const d = 23423323;

		const msg = new Uint8Array(d);
		const nonce = new Uint8Array(24);
		const key = new Uint8Array(32);
		const sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
		const alloc1 = new Uint8Array(184 + Math.ceil(d / 8) * 16);
		const alloc2 = new Uint8Array(184 + Math.ceil((d + 16) / 8) * 16);

		fillRandom(msg);
		fillRandom(nonce);
		fillRandom(key);

		const indexes = combineArrays({msg, nonce, key, sigma, alloc1, alloc2});

		const c = instance.exports.nacl_secretbox(
			indexes.msg,
			d,
			indexes.nonce,
			indexes.key,
			indexes.sigma,
			indexes.alloc1
		);

		const cArray = new Uint8Array(memory.buffer, c, d + 16)

		console.time('Wasm');
		const result1 = instance.exports.nacl_secretbox_open(
			c,
			d + 16,
			indexes.nonce,
			indexes.key,
			indexes.sigma,
			indexes.alloc2
		);
		console.timeEnd('Wasm');

		console.time('JavaScript');
		const result2 = window.nacl.secretbox.open(cArray, nonce, key);
		console.timeEnd('JavaScript');

		console.log('testNaclSecretboxOpen',
			compareArrays(new Uint8Array(memory.buffer, result1, d), result2, d) ? 'Equal' : 'Not equal');
	}

	function run(instance) {
		testCryptoStreamSalsa20Xor(instance);
		testCryptoStreamSalsa20(instance);
		testCryptoCoreHSalsa20(instance);
		testCryptoStreamXor(instance);
		testCryptoStream(instance);
		testCryptoOnetimeAuth(instance);
		testCryptoSecretbox(instance);
		testCryptoSecretboxOpen(instance);
		testNaclSecretbox(instance);
		testNaclSecretboxOpen(instance);
	}

	function base64ToUint8Array(string) {
		string = string.replace(/=/g, '');

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
})();