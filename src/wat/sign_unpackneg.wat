;; Author: Torsten Stüber

;; output pointer $r: 4 * (16 i64) = 512 bytes
;; input pointer $p: 32 bytes
;; alloc pointer $alloc: 7 * 128 = 896 bytes
;; return bool
(func $unpackneg (export "unpackneg")
	(param $r i32)
	(param $p i32)
	(param $alloc i32)
	(result i32)

	(local $t i32)
	(local $chk i32)
	(local $num i32)
	(local $den i32)
	(local $den2 i32)
	(local $den4 i32)
	(local $den6 i32)

	(tee_local $t (get_local $alloc))
	(tee_local $chk (i32.add (i32.const 128)))
	(tee_local $num (i32.add (i32.const 128)))
	(tee_local $den (i32.add (i32.const 128)))
	(tee_local $den2 (i32.add (i32.const 128)))
	(tee_local $den4 (i32.add (i32.const 128)))
	(set_local $den6 (i32.add (i32.const 128)))

	(i32.add (get_local $r) (i32.const 256))
	(get_global $gf1)
	(call $set25519)

	(i32.add (get_local $r) (i32.const 128))
	(get_local $p)
	(call $unpack25519)

	(get_local $num)
	(i32.add (get_local $r) (i32.const 128))
	(call $S)

	(get_local $den)
	(get_local $num)
	(get_global $D)
	(call $M)

	(get_local $num)
	(get_local $num)
	(i32.add (get_local $r) (i32.const 256))
	(call $Z)

	(get_local $den)
	(i32.add (get_local $r) (i32.const 256))
	(get_local $den)
	(call $A)

	
	(get_local $den2)
	(get_local $den)
	(call $S)

	(get_local $den4)
	(get_local $den2)
	(call $S)

	(get_local $den6)
	(get_local $den4)
	(get_local $den2)
	(call $M)

	(get_local $t)
	(get_local $den6)
	(get_local $num)
	(call $M)

	(get_local $t)
	(get_local $t)
	(get_local $den)
	(call $M)


	(get_local $t)
	(get_local $t)
	(get_local $den2)
	(call $pow2523)

	(get_local $t)
	(get_local $t)
	(get_local $num)
	(call $M)

	(get_local $t)
	(get_local $t)
	(get_local $den)
	(call $M)

	(get_local $t)
	(get_local $t)
	(get_local $den)
	(call $M)

	(get_local $r)
	(get_local $t)
	(get_local $den)
	(call $M)


	(get_local $chk)
	(get_local $r)
	(call $S)

	(get_local $chk)
	(get_local $chk)
	(get_local $den)
	(call $M)

	(if (call $neq25519 (get_local $chk) (get_local $num) (get_local $den2))
		(then
			(get_local $r)
			(get_local $r)
			(get_global $I)
			(call $M)
		)
	)


	(get_local $chk)
	(get_local $r)
	(call $S)

	(get_local $chk)
	(get_local $chk)
	(get_local $den)
	(call $M)

	(if (call $neq25519 (get_local $chk) (get_local $num) (get_local $den2))
		(then
			(i32.const -1)
			(return)
		)
	)

	(if (i32.eq
			(call $par25519 (get_local $r) (get_local $den2))
			(i32.shr_u (i32.load8_u offset=31 (get_local $p)) (i32.const 7))
		)
		(then
			(get_local $r)
			(get_global $gf0)
			(get_local $r)
			(call $Z)
		)
	)

	(i32.add (get_local $r) (i32.const 384))
	(get_local $r)
	(i32.add (get_local $r) (i32.const 128))
	(call $M)

	(i32.const 0)
)