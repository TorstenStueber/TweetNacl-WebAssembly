;; Author: Torsten Stüber

;; output pointer $out: 64 bytes
;; input pointer $m: $n bytes
;; input value $n
;; alloc pointer $alloc: 128 + 256 = 384 bytes
(func $crypto_hash (export "crypto_hash")
	(param $out i32)
	(param $m i32)
	(param $n i32)
	(param $alloc i32)

	(local $x i32)
	(local $i i32)
	(local $tmp i32)

	(set_local $x (i32.add (i32.const 128) (get_local $alloc)))

	(i64.store offset=0  (get_local $out) (i64.const 0x6a09e667f3bcc908))
	(i64.store offset=8  (get_local $out) (i64.const 0xbb67ae8584caa73b))
	(i64.store offset=16 (get_local $out) (i64.const 0x3c6ef372fe94f82b))
	(i64.store offset=24 (get_local $out) (i64.const 0xa54ff53a5f1d36f1))
	(i64.store offset=32 (get_local $out) (i64.const 0x510e527fade682d1))
	(i64.store offset=40 (get_local $out) (i64.const 0x9b05688c2b3e6c1f))
	(i64.store offset=48 (get_local $out) (i64.const 0x1f83d9abfb41bd6b))
	(i64.store offset=56 (get_local $out) (i64.const 0x5be0cd19137e2179))

	(get_local $out)
	(get_local $m)
	(get_local $n)
	(get_local $alloc)
	(call $crypto_hashblocks)

	(get_local $n)
		(set_local $m (i32.add (get_local $m) (get_local $n)))
		(set_local $n (i32.and (get_local $n) (i32.const 127)))
		(set_local $m (i32.sub (get_local $m) (get_local $n)))

		(set_local $tmp (get_local $x))
		(block
			(loop
				(br_if 1 (i32.eq (get_local $i) (get_local $n)))

				(i32.store8 (get_local $tmp) (i32.load8_u (get_local $m)))

				(set_local $i (i32.add (i32.const 1) (get_local $i)))
				(set_local $tmp (i32.add (i32.const 1) (get_local $tmp)))
				(set_local $m (i32.add (i32.const 1) (get_local $m)))
				(br 0)
			)
		)
	(set_local $tmp)

	(i32.store8 (get_local $tmp) (i32.const 128))

	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 256)))

			(i32.store8 (get_local $tmp) (i32.const 0))

			(set_local $i (i32.add (i32.const 1) (get_local $i)))
			(set_local $tmp (i32.add (i32.const 1) (get_local $tmp)))
			(br 0)
		)
	)

	(set_local $n (select (i32.const 128) (i32.const 256) (i32.lt_u (get_local $n) (i32.const 112))))

	(get_local $out)
	(get_local $x)
	(get_local $n)
	(get_local $alloc)
		(set_local $x (i32.sub (i32.add (get_local $x) (get_local $n)) (i32.const 9)))
		(i32.store8 (get_local $x) (i32.const 0))
		(i32.store8 offset=1 (get_local $x) (i32.const 0))
		(i32.store8 offset=2 (get_local $x) (i32.const 0))
		(i32.store8 offset=3 (get_local $x) (i32.const 0))
		(i32.store8 offset=4 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 29)))
		(i32.store8 offset=5 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 21)))
		(i32.store8 offset=6 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 13)))
		(i32.store8 offset=7 (get_local $x) (i32.shr_u (get_local $tmp) (i32.const 5)))
		(i32.store8 offset=8 (get_local $x) (i32.shl (get_local $tmp) (i32.const 3)))
	(call $crypto_hashblocks)
)
