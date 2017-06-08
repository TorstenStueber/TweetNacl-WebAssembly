;; Author: Torsten Stüber

;; output pointer $c: $b bytes
;; input value $b
;; input pointer $n: 8 bytes
;; input pointer $k: 32 bytes
;; alloc pointer $alloc: 80 bytes
(func $crypto_stream_salsa20 (export "crypto_stream_salsa20")
	(param $c i32)
	(param $b i32)
	(param $n i32)
	(param $k i32)
	(param $alloc i32)

	(local $z i32)
	(local $x i32)
	(local $i i32)

	(set_local $z (get_local $alloc))
	(set_local $x (i32.add (get_local $alloc) (i32.const 16)))

	(i64.store offset=0 (get_local $z) (i64.load offset=0 (get_local $n)))
	(i64.store offset=8 (get_local $z) (i64.const 0))
	
	(block $break
		(loop $top
			(br_if $break (i32.lt_u (get_local $b) (i32.const 64)))

			(get_local $x)
			(get_local $z)
			(get_local $k)
			(get_global $sigma)
			(call $core_salsa20)

			(i64.store offset=0 (get_local $c) (i64.load offset=0 (get_local $x)))
			(i64.store offset=8 (get_local $c) (i64.load offset=8 (get_local $x)))
			(i64.store offset=16 (get_local $c) (i64.load offset=16 (get_local $x)))
			(i64.store offset=24 (get_local $c) (i64.load offset=24 (get_local $x)))
			(i64.store offset=32 (get_local $c) (i64.load offset=32 (get_local $x)))
			(i64.store offset=40 (get_local $c) (i64.load offset=40 (get_local $x)))
			(i64.store offset=48 (get_local $c) (i64.load offset=48 (get_local $x)))
			(i64.store offset=56 (get_local $c) (i64.load offset=56 (get_local $x)))

			(i64.store offset=8 (get_local $z) (i64.add (i64.load offset=8 (get_local $z)) (i64.const 1)))

			(set_local $b (i32.sub (get_local $b) (i32.const 64)))
			(set_local $c (i32.add (get_local $c) (i32.const 64)))
			
			(br $top)
		)
	)

	(if (i32.gt_u (get_local $b) (i32.const 0))
		(then
			(get_local $x)
			(get_local $z)
			(get_local $k)
			(get_global $sigma)
			(call $core_salsa20)

			(block $break2
				(loop $top2
					(br_if $break2 (i32.eq (get_local $b) (i32.const 0)))

					(i32.store8 (get_local $c) (i32.load8_u (get_local $x)))

					(set_local $b (i32.sub (get_local $b) (i32.const 1)))
					(set_local $c (i32.add (get_local $c) (i32.const 1)))
					(set_local $x (i32.add (get_local $x) (i32.const 1)))
					
					(br $top2)
				)
			)
		)
	)
)
