;; Author: Torsten Stüber

;; output pointer $p: 4 * (16 i64) = 512 bytes
;; input/output pointer $q: 4 * (16 i64) = 512 bytes
;; input pointer $s: 64 bytes
;; alloc pointer $alloc: 384 bytes
(func $scalarmult (export "scalarmult")
	(param $p i32)
	(param $q i32)
	(param $s i32)
	(param $alloc i32)

	(local $b i32) (local $i i32)

	(get_local $p)
	(get_global $gf0)
	(call $set25519)

	(i32.add (get_local $p) (i32.const 128))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $p) (i32.const 256))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $p) (i32.const 384))
	(get_global $gf0)
	(call $set25519)

	(set_local $i (i32.const 255))
	(block
		(loop
			(set_local $b (i32.and (i32.shr_u
				(i32.load8_u (i32.add (get_local $s) (i32.shr_u (get_local $i) (i32.const 3))))
				(i32.and (get_local $i) (i32.const 7))
			) (i32.const 1)))

			(get_local $p)
			(get_local $q)
			(get_local $b)
			(call $cswap)

			(get_local $q)
			(get_local $p)
			(get_local $alloc)
			(call $add)

			(get_local $p)
			(get_local $p)
			(get_local $alloc)
			(call $add)

			(get_local $p)
			(get_local $q)
			(get_local $b)
			(call $cswap)

			(set_local $i (i32.sub (get_local $i) (i32.const 1)))
			(br_if 0 (i32.ge_s (get_local $i) (i32.const 0)))
			(br 1)
		)
	)
)