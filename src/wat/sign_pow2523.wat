;; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $i: 16 i64 = 128 bytes
;; alloc pointer $alloc: 16 i64 = 128 bytes
(func $pow2523 (export "pow2523")
	(param $o i32)
	(param $i i32)
	(param $alloc i32)

	(local $a i32)

	(i64.store offset=0 (get_local $alloc) (i64.load offset=0 (get_local $i)))
	(i64.store offset=8 (get_local $alloc) (i64.load offset=8 (get_local $i)))
	(i64.store offset=16 (get_local $alloc) (i64.load offset=16 (get_local $i)))
	(i64.store offset=24 (get_local $alloc) (i64.load offset=24 (get_local $i)))
	(i64.store offset=32 (get_local $alloc) (i64.load offset=32 (get_local $i)))
	(i64.store offset=40 (get_local $alloc) (i64.load offset=40 (get_local $i)))
	(i64.store offset=48 (get_local $alloc) (i64.load offset=48 (get_local $i)))
	(i64.store offset=56 (get_local $alloc) (i64.load offset=56 (get_local $i)))
	(i64.store offset=64 (get_local $alloc) (i64.load offset=64 (get_local $i)))
	(i64.store offset=72 (get_local $alloc) (i64.load offset=72 (get_local $i)))
	(i64.store offset=80 (get_local $alloc) (i64.load offset=80 (get_local $i)))
	(i64.store offset=88 (get_local $alloc) (i64.load offset=88 (get_local $i)))
	(i64.store offset=96 (get_local $alloc) (i64.load offset=96 (get_local $i)))
	(i64.store offset=104 (get_local $alloc) (i64.load offset=104 (get_local $i)))
	(i64.store offset=112 (get_local $alloc) (i64.load offset=112 (get_local $i)))
	(i64.store offset=120 (get_local $alloc) (i64.load offset=120 (get_local $i)))
	

	(set_local $a (i32.const 251))

	(block
		(loop
			(br_if 1 (i32.eqz (get_local $a)))
			(get_local $alloc)
			(get_local $alloc)
			(call $S)

			(if (i32.ne (get_local $a) (i32.const 2))
				(then
					(get_local $alloc)
					(get_local $alloc)
					(get_local $i)
					(call $M)
				)
			)

			(set_local $a (i32.sub (get_local $a) (i32.const 1)))
			(br 0)
		)
	)

	(i64.store offset=0 (get_local $o) (i64.load offset=0 (get_local $alloc)))
	(i64.store offset=8 (get_local $o) (i64.load offset=8 (get_local $alloc)))
	(i64.store offset=16 (get_local $o) (i64.load offset=16 (get_local $alloc)))
	(i64.store offset=24 (get_local $o) (i64.load offset=24 (get_local $alloc)))
	(i64.store offset=32 (get_local $o) (i64.load offset=32 (get_local $alloc)))
	(i64.store offset=40 (get_local $o) (i64.load offset=40 (get_local $alloc)))
	(i64.store offset=48 (get_local $o) (i64.load offset=48 (get_local $alloc)))
	(i64.store offset=56 (get_local $o) (i64.load offset=56 (get_local $alloc)))
	(i64.store offset=64 (get_local $o) (i64.load offset=64 (get_local $alloc)))
	(i64.store offset=72 (get_local $o) (i64.load offset=72 (get_local $alloc)))
	(i64.store offset=80 (get_local $o) (i64.load offset=80 (get_local $alloc)))
	(i64.store offset=88 (get_local $o) (i64.load offset=88 (get_local $alloc)))
	(i64.store offset=96 (get_local $o) (i64.load offset=96 (get_local $alloc)))
	(i64.store offset=104 (get_local $o) (i64.load offset=104 (get_local $alloc)))
	(i64.store offset=112 (get_local $o) (i64.load offset=112 (get_local $alloc)))
	(i64.store offset=120 (get_local $o) (i64.load offset=120 (get_local $alloc)))

)