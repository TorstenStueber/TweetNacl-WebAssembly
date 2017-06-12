;; Author: Torsten Stüber

;; input pointer $a: 16 i64 = 128 bytes
;; input pointer $b: 16 i64 = 128 bytes
;; alloc pointer $alloc: 64 + 256 = 384 bytes
;; return bool
(func $neq25519 (export "neq25519")
	(param $a i32)
	(param $b i32)
	(param $alloc i32)
	(result i32)

	(get_local $alloc)
	(get_local $a)
	(i32.add (get_local $alloc) (i32.const 64))
	(call $pack25519)

	(i32.add (get_local $alloc) (i32.const 32))
	(get_local $b)
	(i32.add (get_local $alloc) (i32.const 64))
	(call $pack25519)

	(get_local $alloc)
	(i32.add (get_local $alloc) (i32.const 32))
	(call $crypto_verify_32)
)