const wast2wasm = require('wast2wasm');
const fs = require('fs');
const path = require('path');

const watSourceDirectory = './src/wat';
const wasmOuputDirectory = './dist';

const filesToAssemble = fs.readdirSync(watSourceDirectory).filter(
	fileName => fileName.substring(fileName.length - 4) === '.wat'
);

const codeArray = filesToAssemble.map(fileName => {
	return fs.readFileSync(path.join(watSourceDirectory, fileName)).toString('utf8');
});

const completeModule = '(module (import "js" "mem" (memory 1))' + 
	codeArray.join('\n') + ')';

wast2wasm(completeModule)
	.then(output => new Buffer(output.buffer).toString('base64'))
	.then(output => {
		if (!fs.existsSync(wasmOuputDirectory)) {
			fs.mkdirSync(wasmOuputDirectory);
		}

		const jsContent = 'window.wasmCode = ' + JSON.stringify(output);
		fs.writeFileSync(path.join(wasmOuputDirectory, 'wasmCode.js'), jsContent);
	});