const wast2wasm = require('wast2wasm');
const fs = require('fs');

const wastCode = fs.readFileSync('./src/simple.wat').toString('utf8');

wast2wasm(wastCode).then(output => {
	const outputArray = [];
	for (let i = 0; i < output.buffer.length; i++) {
		outputArray.push(output.buffer[i]);
	}

	const jsContent = 'window.wasmCode = [' + outputArray.join(',') + ']';

	const dir = './dist';
	if (!fs.existsSync(dir)){
		fs.mkdirSync(dir);
	}

	fs.writeFileSync('./dist/wasmCode.js', jsContent);
})
