;; Author: Torsten Stüber

;; output pointer $p: 4 * (16 i64) = 512 bytes
;; input pointer $s: 64 bytes
;; alloc pointer $alloc: 512 + 384 = 896 bytes
(func $scalarbase (export "scalarbase")
	(param $p i32)
	(param $s i32)
	(param $alloc i32)

	(get_local $alloc)
	(get_global $X)
	(call $set25519)

	(i32.add (get_local $alloc) (i32.const 128))
	(get_global $Y)
	(call $set25519)

	(i32.add (get_local $alloc) (i32.const 256))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $alloc) (i32.const 384))
	(get_global $X)
	(get_global $Y)
	(call $M)

	(get_local $p)
	(get_local $alloc)
	(get_local $s)
	(i32.add (get_local $alloc) (i32.const 512))
	(call $scalarmult)
)