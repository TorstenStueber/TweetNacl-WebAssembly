;; Author: Torsten Stüber

;; input pointer $a: 16 i64 = 128 bytes
;; alloc pointer $alloc: 256 + 128 = 384 bytes
;; return value: 1 or 0
(func $par25519 (export "par25519")
	(param $a i32)
	(param $alloc i32)
	(result i32)

	(local $d i32)
	(tee_local $d (i32.add (get_local $alloc) (i32.const 256)))

	(get_local $a)
	(get_local $alloc)
	(call $pack25519)

	(i32.and (i32.const 1) (i32.load8_u (get_local $d)))
)