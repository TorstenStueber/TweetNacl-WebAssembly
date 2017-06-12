;; Author: Torsten Stüber

;; input/output pointer $r: 64 bytes
;; alloc pointer $alloc: 64 i64 = 512 bytes
(func $reduce (export "reduce")
	(param $r i32)
	(param $alloc i32)

	(local $i i32)


	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (i32.const 64)))

			(i64.store (i32.add (get_local $alloc) (i32.shl (get_local $i) (i32.const 3))) (
				i64.load8_u (i32.add (get_local $r) (get_local $i))
			))

			(set_local $i (i32.add (get_local $i) (i32.const 1)))
			(br 0)
		)
	)

	(i64.store offset=0 (get_local $r) (i64.const 0))
	(i64.store offset=8 (get_local $r) (i64.const 0))
	(i64.store offset=16 (get_local $r) (i64.const 0))
	(i64.store offset=24 (get_local $r) (i64.const 0))
	(i64.store offset=32 (get_local $r) (i64.const 0))
	(i64.store offset=40 (get_local $r) (i64.const 0))
	(i64.store offset=48 (get_local $r) (i64.const 0))
	(i64.store offset=56 (get_local $r) (i64.const 0))

	(get_local $r)
	(get_local $alloc)
	(call $modL)
)