;; Author: Torsten Stüber

;; polyobject
;;  pad: 0..15
;;  r: 16..35
;;  leftover: 36..39
;;  h: 40..59 
;;  final: 60..63
;;  buffer: 64..79

;; pointer $poly: 80 bytes (polyobject)
;; input pointer $m: $bytes bytes
;; input value $bytes
(func $poly1305_update (export "poly1305_update")
	(param $poly i32)
	(param $m i32)
	(param $bytes i32)

	(local $i i32)
	(local $want i32)
	(local $tmp1 i32)
	(local $tmp2 i32)

	(if (i32.ne (i32.load offset=36 (get_local $poly)) (i32.const 0))
		(then
			(set_local $want (i32.sub (i32.const 16) (i32.load offset=36 (get_local $poly))))
	
			(if (i32.gt_u (get_local $want) (get_local $bytes))
				(then
					(set_local $want (get_local $bytes))
				)
			)

			(set_local $tmp1 (i32.add (get_local $poly) (i32.load offset=36 (get_local $poly))))
			(set_local $tmp2 (get_local $m))
			(block $break1
				(loop $top1
					(br_if $break1 (i32.eq (get_local $i) (get_local $want)))
					
					(i32.store8 offset=64 (get_local $tmp1) (i32.load8_u (get_local $tmp2)))

					(set_local $i (i32.add (get_local $i) (i32.const 1)))
					(set_local $tmp1 (i32.add (get_local $tmp1) (i32.const 1)))
					(set_local $tmp2 (i32.add (get_local $tmp2) (i32.const 1)))

					(br $top1)
				)
			)

			(set_local $bytes (i32.sub (get_local $bytes) (get_local $want)))
			(set_local $m (i32.add (get_local $m) (get_local $want)))
			(i32.store offset=36 (get_local $poly) (i32.add (get_local $want) (i32.load offset=36 (get_local $poly))))

			(if (i32.lt_u (i32.load offset=36 (get_local $poly)) (i32.const 16))
				(then
					return
				)
			)

			(get_local $poly)
			(i32.add (get_local $poly) (i32.const 64))
			(i32.const 16)
			(call $poly1305_blocks) ;; poly1305_blocks

			(i32.store offset=36 (get_local $poly) (i32.const 0))
		)
	)

	(if (i32.ge_u (get_local $bytes) (i32.const 16))
		(then
			(set_local $want (i32.and (get_local $bytes) (i32.const 0xfffffff0)))
			
			(get_local $poly)
			(get_local $m)
			(get_local $want)
			(call $poly1305_blocks) ;; poly1305_blocks

			(set_local $m (i32.add (get_local $m) (get_local $want)))
			(set_local $bytes (i32.sub (get_local $bytes) (get_local $want)))
		)
	)

	(if (i32.gt_u (get_local $bytes) (i32.const 0))
		(then
			(set_local $i (i32.const 0))
			(set_local $tmp1 (i32.add (get_local $poly) (i32.load offset=36 (get_local $poly))))
			(set_local $tmp2 (get_local $m))
			(block $break2
				(loop $top2
					(br_if $break2 (i32.eq (get_local $i) (get_local $bytes)))
					
					(i32.store8 offset=64 (get_local $tmp1) (i32.load8_u (get_local $tmp2)))

					(set_local $i (i32.add (get_local $i) (i32.const 1)))
					(set_local $tmp1 (i32.add (get_local $tmp1) (i32.const 1)))
					(set_local $tmp2 (i32.add (get_local $tmp2) (i32.const 1)))

					(br $top2)
				)
			)

			(i32.store offset=36 (get_local $poly) (i32.add (i32.load offset=36 (get_local $poly)) (get_local $bytes)))
		)
	)
)
