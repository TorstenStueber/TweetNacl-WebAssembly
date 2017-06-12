;; Author: Torsten Stüber

;; output pointer $r: 32 bytes
;; input/output pointer $x: 64 i64 = 512 bytes
(func $modL (export "modL")
	(param $r i32)
	(param $x i32)

	(local $carry i64)
	(local $i i32) (local $j i32) (local $k i32) (local $xi i32) (local $xj i32)

	(set_local $i (i32.const 63))
	(set_local $xi (i32.add (get_local $x) (i32.const 504)))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 31)))

			(set_local $carry (i64.const 0))

			(set_local $j (i32.sub (get_local $i) (i32.const 32)))
			(set_local $k (i32.sub (get_local $i) (i32.const 12)))
			(set_local $xj (i32.add (get_local $x) (i32.shl (get_local $j) (i32.const 3))))
			(block
				(loop
					(br_if 1 (i32.eq (get_local $j) (get_local $k)))

					(i64.store (get_local $xj) (i64.add (i64.load (get_local $xj)) (i64.sub
						(get_local $carry)
						(i64.shl
							(i64.mul
								(i64.load (get_local $xi))
								(i64.load (i32.add (get_global $L) (i32.shl (i32.sub
									(get_local $j) 
									(i32.sub (get_local $i) (i32.const 32))
								) (i32.const 3))))
							)
							(i64.const 4)
						)
					)))

					(set_local $carry (i64.shr_s (i64.add
						(i64.load (get_local $xj))
						(i64.const 128)
					) (i64.const 8)))

					(i64.store (get_local $xj) (i64.sub
						(i64.load (get_local $xj))
						(i64.shl (get_local $carry) (i64.const 8))
					))

					(set_local $j (i32.add (get_local $j) (i32.const 1)))
					(set_local $xj (i32.add (get_local $xj) (i32.const 8)))
					(br 0)
				)
			)

			(i64.store (get_local $xj) (i64.add (i64.load (get_local $xj)) (get_local $carry)))
			(i64.store (get_local $xi) (i64.const 0))

			(set_local $i (i32.sub (get_local $i) (i32.const 1)))
			(set_local $xi (i32.sub (get_local $xi) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $carry (i64.const 0))

	(set_local $j (i32.const 0))
	(set_local $xj (get_local $x))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $j) (i32.const 32)))

			(i64.store (get_local $xj) (i64.add (i64.load (get_local $xj)) (i64.sub
				(get_local $carry)
				(i64.mul
					(i64.shr_s (i64.load offset=248 (get_local $x)) (i64.const 4))
					(i64.load (i32.add (get_global $L) (i32.shl (get_local $j) (i32.const 3))))
				)
			)))

			(set_local $carry (i64.shr_s (i64.load (get_local $xj)) (i64.const 8)))

			(i64.store (get_local $xj) (i64.and
				(i64.load (get_local $xj))
				(i64.const 255)
			))

			(set_local $j (i32.add (get_local $j) (i32.const 1)))
			(set_local $xj (i32.add (get_local $xj) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $j (i32.const 0))
	(set_local $xj (get_local $x))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $j) (i32.const 32)))

			(i64.store (get_local $xj) (i64.sub (i64.load (get_local $xj))
				(i64.mul (get_local $carry) (i64.load (i32.add
					(get_global $L) 
					(i32.shl (get_local $j) (i32.const 3))
				)))
			))

			(set_local $j (i32.add (get_local $j) (i32.const 1)))
			(set_local $xj (i32.add (get_local $xj) (i32.const 8)))
			(br 0)
		)
	)

	(set_local $i (i32.const 0))
	(set_local $xi (get_local $x))
	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 32)))

			(i64.store offset=8 (get_local $xi) (i64.add
				(i64.load offset=8 (get_local $xi))
				(i64.shr_s (i64.load (get_local $xi)) (i64.const 8))
			))

			(i64.store8 (i32.add (get_local $r) (get_local $i)) (i64.load (get_local $xi)))

			(set_local $i (i32.add (get_local $i) (i32.const 1)))
			(set_local $xi (i32.add (get_local $xi) (i32.const 8)))
			(br 0)
		)
	)
)