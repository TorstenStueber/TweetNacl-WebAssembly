;; Author: Torsten Stüber

;; input/output pointer $h: 64 bytes; 8 x 64 bit numbers (stored little endian, not big endian as in original tweetnacl)
;; input pointer $m: $n bytes
;; input value $n
;; alloc pointer $alloc: 128 bytes
(func $crypto_hashblocks (export "crypto_hashblocks")
	(param $h i32)
	(param $m i32)
	(param $n i32)
	(param $alloc i32)

	(local $b0 i64) (local $b1 i64) (local $b2 i64) (local $b3 i64)
	(local $b4 i64) (local $b5 i64) (local $b6 i64) (local $b7 i64)
	(local $a0 i64) (local $a1 i64) (local $a2 i64) (local $a3 i64)
	(local $a4 i64) (local $a5 i64) (local $a6 i64) (local $a7 i64)
	(local $t i64)
	(local $tmp1 i64) (local $tmp2 i64) (local $tmp3 i64)
	(local $w i32) (local $i i32) (local $j i32) (local $k i32) (local $K i32)

	(set_local $w (get_local $alloc))
	
	(set_local $a0 (i64.load offset=0 (get_local $h)))
	(set_local $a1 (i64.load offset=8 (get_local $h)))
	(set_local $a2 (i64.load offset=16 (get_local $h)))
	(set_local $a3 (i64.load offset=24 (get_local $h)))
	(set_local $a4 (i64.load offset=32 (get_local $h)))
	(set_local $a5 (i64.load offset=40 (get_local $h)))
	(set_local $a6 (i64.load offset=48 (get_local $h)))
	(set_local $a7 (i64.load offset=56 (get_local $h)))

	(block
		(loop
			(br_if 1(i32.lt_u (get_local $n) (i32.const 128)))

			(set_local $i (i32.const 0))
			(set_local $j (get_local $m))
			(set_local $k (get_local $w))
			(block
				(loop
					(br_if 1 (i32.eq (get_local $i) (i32.const 16)))

					(i64.store (get_local $k) (i64.or
						(i64.or
							(i64.or
								(i64.shl (i64.load8_u offset=0 (get_local $j)) (i64.const 56))
								(i64.shl (i64.load8_u offset=1 (get_local $j)) (i64.const 48))
							)
							(i64.or
								(i64.shl (i64.load8_u offset=2 (get_local $j)) (i64.const 40))
								(i64.shl (i64.load8_u offset=3 (get_local $j)) (i64.const 32))
							)
						)
						(i64.or
							(i64.or
								(i64.shl (i64.load8_u offset=4 (get_local $j)) (i64.const 24))
								(i64.shl (i64.load8_u offset=5 (get_local $j)) (i64.const 16))
							)
							(i64.or 
								(i64.shl (i64.load8_u offset=6 (get_local $j)) (i64.const 8))
								(i64.load8_u offset=7 (get_local $j))
							)
						)
					))

					(set_local $i (i32.add (i32.const 1) (get_local $i)))
					(set_local $j (i32.add (i32.const 8) (get_local $j)))
					(set_local $k (i32.add (i32.const 8) (get_local $k)))
					(br 0)
				)
			)

			(set_local $i (i32.const 0))
			(set_local $K (get_global $K))
			(block
				(loop
					(br_if 1 (i32.eq (get_local $i) (i32.const 80)))

					(set_local $b0 (get_local $a0))
					(set_local $b1 (get_local $a1))
					(set_local $b2 (get_local $a2))
					(set_local $b3 (get_local $a3))
					(set_local $b4 (get_local $a4))
					(set_local $b5 (get_local $a5))
					(set_local $b6 (get_local $a6))
					(set_local $b7 (get_local $a7))

					(set_local $t (i64.add
						(i64.add
							(get_local $a7)
							(i64.xor 
								(i64.xor
									(i64.rotr (get_local $a4) (i64.const 14))
									(i64.rotr (get_local $a4) (i64.const 18))
								)
								(i64.rotr (get_local $a4) (i64.const 41))
							)
						)
						(i64.add
							(i64.xor 
								(i64.and (get_local $a4) (get_local $a5))
								(i64.and (i64.xor (get_local $a4) (i64.const -1)) (get_local $a6))
							)
							(i64.add
								(i64.load (get_local $K))
								(i64.load (i32.add (get_local $w) (i32.shl (i32.and (get_local $i) (i32.const 0xf)) (i32.const 3))))
							)
						)
					))

					(set_local $b7 (i64.add
						(i64.add
							(get_local $t)
							(i64.xor 
								(i64.xor
									(i64.rotr (get_local $a0) (i64.const 28))
									(i64.rotr (get_local $a0) (i64.const 34))
								)
								(i64.rotr (get_local $a0) (i64.const 39))
							)
						)
						(i64.xor 
							(i64.xor
								(i64.and (get_local $a0) (get_local $a1))
								(i64.and (get_local $a0) (get_local $a2))
							)
							(i64.and (get_local $a1) (get_local $a2))
						)
					))

					(set_local $b3 (i64.add (get_local $b3) (get_local $t)))

					(set_local $a1 (get_local $b0))
					(set_local $a2 (get_local $b1))
					(set_local $a3 (get_local $b2))
					(set_local $a4 (get_local $b3))
					(set_local $a5 (get_local $b4))
					(set_local $a6 (get_local $b5))
					(set_local $a7 (get_local $b6))
					(set_local $a0 (get_local $b7))

					(if (i32.eq (i32.and (get_local $i) (i32.const 0xf)) (i32.const 15))
						(then

							(set_local $tmp1 (i64.load offset=72 (get_local $w)))
							(set_local $tmp2 (i64.load offset=8 (get_local $w)))
							(set_local $tmp3 (i64.load offset=112 (get_local $w)))
							(i64.store offset=0 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=0 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=80 (get_local $w)))
							(set_local $tmp2 (i64.load offset=16 (get_local $w)))
							(set_local $tmp3 (i64.load offset=120 (get_local $w)))
							(i64.store offset=8 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=8 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=88 (get_local $w)))
							(set_local $tmp2 (i64.load offset=24 (get_local $w)))
							(set_local $tmp3 (i64.load offset=0 (get_local $w)))
							(i64.store offset=16 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=16 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=96 (get_local $w)))
							(set_local $tmp2 (i64.load offset=32 (get_local $w)))
							(set_local $tmp3 (i64.load offset=8 (get_local $w)))
							(i64.store offset=24 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=24 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=104 (get_local $w)))
							(set_local $tmp2 (i64.load offset=40 (get_local $w)))
							(set_local $tmp3 (i64.load offset=16 (get_local $w)))
							(i64.store offset=32 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=32 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=112 (get_local $w)))
							(set_local $tmp2 (i64.load offset=48 (get_local $w)))
							(set_local $tmp3 (i64.load offset=24 (get_local $w)))
							(i64.store offset=40 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=40 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=120 (get_local $w)))
							(set_local $tmp2 (i64.load offset=56 (get_local $w)))
							(set_local $tmp3 (i64.load offset=32 (get_local $w)))
							(i64.store offset=48 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=48 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=0 (get_local $w)))
							(set_local $tmp2 (i64.load offset=64 (get_local $w)))
							(set_local $tmp3 (i64.load offset=40 (get_local $w)))
							(i64.store offset=56 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=56 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=8 (get_local $w)))
							(set_local $tmp2 (i64.load offset=72 (get_local $w)))
							(set_local $tmp3 (i64.load offset=48 (get_local $w)))
							(i64.store offset=64 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=64 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=16 (get_local $w)))
							(set_local $tmp2 (i64.load offset=80 (get_local $w)))
							(set_local $tmp3 (i64.load offset=56 (get_local $w)))
							(i64.store offset=72 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=72 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=24 (get_local $w)))
							(set_local $tmp2 (i64.load offset=88 (get_local $w)))
							(set_local $tmp3 (i64.load offset=64 (get_local $w)))
							(i64.store offset=80 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=80 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=32 (get_local $w)))
							(set_local $tmp2 (i64.load offset=96 (get_local $w)))
							(set_local $tmp3 (i64.load offset=72 (get_local $w)))
							(i64.store offset=88 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=88 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=40 (get_local $w)))
							(set_local $tmp2 (i64.load offset=104 (get_local $w)))
							(set_local $tmp3 (i64.load offset=80 (get_local $w)))
							(i64.store offset=96 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=96 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=48 (get_local $w)))
							(set_local $tmp2 (i64.load offset=112 (get_local $w)))
							(set_local $tmp3 (i64.load offset=88 (get_local $w)))
							(i64.store offset=104 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=104 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=56 (get_local $w)))
							(set_local $tmp2 (i64.load offset=120 (get_local $w)))
							(set_local $tmp3 (i64.load offset=96 (get_local $w)))
							(i64.store offset=112 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=112 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							(set_local $tmp1 (i64.load offset=64 (get_local $w)))
							(set_local $tmp2 (i64.load offset=0 (get_local $w)))
							(set_local $tmp3 (i64.load offset=104 (get_local $w)))
							(i64.store offset=120 (get_local $w) (i64.add
								(i64.add
									(i64.load offset=120 (get_local $w))
									(get_local $tmp1)
								)
								(i64.add
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp2) (i64.const 1))
											(i64.rotr (get_local $tmp2) (i64.const 8))
										)
										(i64.shr_u (get_local $tmp2) (i64.const 7))
									)
									(i64.xor
										(i64.xor
											(i64.rotr (get_local $tmp3) (i64.const 19))
											(i64.rotr (get_local $tmp3) (i64.const 61))
										)
										(i64.shr_u (get_local $tmp3) (i64.const 6))
									)
								)
							))

							

						)
					)

					(set_local $i (i32.add (i32.const 1) (get_local $i)))
					(set_local $K (i32.add (i32.const 8) (get_local $K)))
					(br 0)
				)
			)

			(i64.store offset=0 (get_local $h) (tee_local $a0 (i64.add
				(get_local $a0) (i64.load offset=0 (get_local $h))
			)))
			(i64.store offset=8 (get_local $h) (tee_local $a1 (i64.add
				(get_local $a1) (i64.load offset=8 (get_local $h))
			)))
			(i64.store offset=16 (get_local $h) (tee_local $a2 (i64.add
				(get_local $a2) (i64.load offset=16 (get_local $h))
			)))
			(i64.store offset=24 (get_local $h) (tee_local $a3 (i64.add
				(get_local $a3) (i64.load offset=24 (get_local $h))
			)))
			(i64.store offset=32 (get_local $h) (tee_local $a4 (i64.add
				(get_local $a4) (i64.load offset=32 (get_local $h))
			)))
			(i64.store offset=40 (get_local $h) (tee_local $a5 (i64.add
				(get_local $a5) (i64.load offset=40 (get_local $h))
			)))
			(i64.store offset=48 (get_local $h) (tee_local $a6 (i64.add
				(get_local $a6) (i64.load offset=48 (get_local $h))
			)))
			(i64.store offset=56 (get_local $h) (tee_local $a7 (i64.add
				(get_local $a7) (i64.load offset=56 (get_local $h))
			)))

			(set_local $m (i32.add (i32.const 128) (get_local $m)))
			(set_local $n (i32.sub (get_local $n) (i32.const 128)))
			(br 0)
		)
	)
)
