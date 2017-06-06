;; Author: Torsten Stüber

;; input pointer $x: $n bytes
;; input pointer $y: $n bytes
;; input value $n
;; return bool
(func $vn
	(param $x i32)
	(param $y i32)
	(param $n i32)
	(result i32)

	(local $i i32)
	(local $d i32)
	
	(block
		(loop
			(br_if 1 (i32.eq (get_local $i) (get_local $n)))

			(set_local $d (i32.or (get_local $d)
				(i32.xor (i32.load8_u (get_local $x)) (i32.load8_u (get_local $y)))))

			(set_local $i (i32.add (get_local $i) (i32.const 1)))
			(set_local $x (i32.add (get_local $x) (i32.const 1)))
			(set_local $y (i32.add (get_local $y) (i32.const 1)))
			(br 0)
		)
	)

	(i32.sub
		(i32.and (i32.const 1) (i32.shr_u (i32.sub (get_local $d) (i32.const 1)) (i32.const 8))) 
		(i32.const 1))
)

;; input pointer $x: 16 bytes
;; input pointer $y: 16 bytes
;; return bool
(func $crypto_verify_16 (export "crypto_verify_16")
	(param $x i32)
	(param $y i32)
	(result i32)

	(local $d i64)
	(set_local $d (i64.or (get_local $d)
		(i64.xor (i64.load offset=0 (get_local $x)) (i64.load offset=0 (get_local $y)))
		(i64.xor (i64.load offset=8 (get_local $x)) (i64.load offset=8 (get_local $y)))
	))

	(set_local $d (i64.or (
		(i64.and (get_local $d) (0xffffffff))
		(i64.shr_u (get_local $d) (32))
	)))

	(i32.wrap/i64 (i64.sub
		(i64.and (i64.const 1) (i64.shr_u (i64.sub (get_local $d) (i64.const 1)) (i64.const 32))) 
		(i64.const 1)))
)

;; input pointer $x: 32 bytes
;; input pointer $y: 32 bytes
;; return bool
(func $crypto_verify_32 (export "crypto_verify_32")
	(param $x i32)
	(param $y i32)
	(result i32)

	(local $d i64)
	(set_local $d (i64.or
		(i64.or (get_local $d)
			(i64.xor (i64.load offset=0 (get_local $x)) (i64.load offset=0 (get_local $y)))
			(i64.xor (i64.load offset=8 (get_local $x)) (i64.load offset=8 (get_local $y)))
		)
		(i64.or (get_local $d)
			(i64.xor (i64.load offset=16 (get_local $x)) (i64.load offset=16 (get_local $y)))
			(i64.xor (i64.load offset=24 (get_local $x)) (i64.load offset=24 (get_local $y)))
		)
	))

	(set_local $d (i64.or (
		(i64.and (get_local $d) (0xffffffff))
		(i64.shr_u (get_local $d) (32))
	)))

	(i32.wrap/i64 (i64.sub
		(i64.and (i64.const 1) (i64.shr_u (i64.sub (get_local $d) (i64.const 1)) (i64.const 32))) 
		(i64.const 1)))
)