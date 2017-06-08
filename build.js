const wast2wasm = require('wast2wasm');
const fs = require('fs');
const path = require('path');

const watSourceDirectory = './src/wat';
const sourceDirectory = './src';
const wasmOuputDirectory = './dist';

const naclWasmSourceSearchString = 'const wasmCode = \'\';'

const filesToAssemble = fs.readdirSync(watSourceDirectory).filter(
	fileName => fileName.substring(fileName.length - 4) === '.wat'
);

const codeArray = filesToAssemble.map(fileName => {
	return fs.readFileSync(path.join(watSourceDirectory, fileName)).toString('utf8');
});

const completeModule = '(module (import "js" "mem" (memory 1))' + 
	codeArray.join('\n') + ')';

wast2wasm(completeModule, true)
	.then(output => {
		fs.writeFileSync(path.join(wasmOuputDirectory, 'build.wasm'), output.buffer);
		fs.writeFileSync(path.join(wasmOuputDirectory, 'build.log'), output.log);
		return new Buffer(output.buffer).toString('base64');
	})
	.then(output => {
		let chunkedOutput = output.match(/.{1,100}/g).map(chunk => JSON.stringify(chunk)).join(' +\n\t\t');
		let naclWasmSource = fs.readFileSync(path.join(sourceDirectory, 'nacl-wasm.js')).toString('utf8');
		naclWasmSource = naclWasmSource.replace(naclWasmSourceSearchString, 'const wasmCode =\n\t\t' + chunkedOutput);
		
		if (!fs.existsSync(wasmOuputDirectory)) {
			fs.mkdirSync(wasmOuputDirectory);
		}

		fs.writeFileSync(path.join(wasmOuputDirectory, 'nacl-wasm.js'), naclWasmSource);
	});