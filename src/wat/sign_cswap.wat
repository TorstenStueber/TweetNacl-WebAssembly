;; Author: Torsten Stüber

;; input/output pointer $p: 4 * (16 i64) = 512 bytes
;; input/output pointer $q: 4 * (16 i64) = 512 bytes
;; input value $b (is 1 or 0)
(func $cswap (export "cswap")
	(param $p i32)
	(param $q i32)
	(param $b i32)

	(get_local $p)
	(get_local $q)
	(get_local $b)
	(call $sel25519)

	(i32.add (get_local $p) (i32.const 128))
	(i32.add (get_local $q) (i32.const 128))
	(get_local $b)
	(call $sel25519)

	(i32.add (get_local $p) (i32.const 256))
	(i32.add (get_local $q) (i32.const 256))
	(get_local $b)
	(call $sel25519)

	(i32.add (get_local $p) (i32.const 384))
	(i32.add (get_local $q) (i32.const 384))
	(get_local $b)
	(call $sel25519)
)