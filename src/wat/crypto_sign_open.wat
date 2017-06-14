;; Author: Torsten Stüber

;; output pointer $m: $n bytes; must already be a copy of $sm
;; input pointer $sm: $n bytes
;; input value $n
;; input $pk: 32 bytes
;; alloc pointer $alloc: 896 + 32 + 64 + 2 * 512 = 2016 bytes
;; return: -1 if error; $m - 64 otherwise
(func $crypto_sign_open (export "crypto_sign_open")
	(param $m i32)
	(param $sm i32)
	(param $n i32)
	(param $pk i32)
	(param $alloc i32)
	(result i32)
	
	(local $t i32)
	(local $h i32)
	(local $p i32)
	(local $q i32)
	
	(tee_local $t (i32.add (get_local $alloc) (i32.const 896)))
	(tee_local $h (i32.add (i32.const 32)))
	(tee_local $p (i32.add (i32.const 64)))
	(set_local $q (i32.add (i32.const 512)))
	
	(if (i32.lt_u (get_local $n) (i32.const 64))
		(then
			(i32.const -1)
			(return)
		)
	)

	(if (call $unpackneg (get_local $q) (get_local $pk) (get_local $alloc))
		(then
			(i32.const -1)
			(return)
		)
	)

	(i64.store offset=32 (get_local $m) (i64.load offset=0 (get_local $pk)))
	(i64.store offset=40 (get_local $m) (i64.load offset=8 (get_local $pk)))
	(i64.store offset=48 (get_local $m) (i64.load offset=16 (get_local $pk)))
	(i64.store offset=56 (get_local $m) (i64.load offset=24 (get_local $pk)))

	(get_local $h)
	(get_local $m)
	(get_local $n)
	(get_local $alloc)
	(call $crypto_hash)

	(get_local $h)
	(get_local $alloc)
	(call $reduce)

	(get_local $p)
	(get_local $q)
	(get_local $h)
	(get_local $alloc)
	(call $scalarmult)

	(get_local $q)
	(i32.add (get_local $sm) (i32.const 32))
	(get_local $alloc)
	(call $scalarbase)
	
	(get_local $p)
	(get_local $q)
	(get_local $alloc)
	(call $add)

	(get_local $t)
	(get_local $p)
	(get_local $alloc)
	(call $pack)

	(set_local $n (i32.sub (get_local $n) (i32.const 64)))

	(if (call $crypto_verify_32 (get_local $sm) (get_local $t))
		(then
			(i32.const -1)
			(return)
		)
	)

	(get_local $n)
)
