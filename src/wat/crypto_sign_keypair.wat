;; Author: Torsten Stüber

;; output pointer $pk: 32 bytes
;; input/output pointer $sk: 64 bytes (first 32 bytes input; last 32 bytes output)
;; alloc pointer $alloc: 896 + 64 + 512 = 1472 bytes
(func $crypto_sign_keypair (export "crypto_sign_keypair")
	(param $pk i32)
	(param $sk i32)
	(param $alloc i32)
	
	(local $d i32)
	(local $p i32)

	(tee_local $d (i32.add (get_local $alloc) (i32.const 896)))
	(set_local $p (i32.add (i32.const 64)))
	
	(get_local $d)
	(get_local $sk)
	(i32.const 32)
	(get_local $alloc)
	(call $crypto_hash)

	(i32.store8 offset=0 (get_local $d) (i32.and
		(i32.load8_u offset=0 (get_local $d))
		(i32.const 248)
	))
	(i32.store8 offset=31 (get_local $d) (i32.and
		(i32.load8_u offset=31 (get_local $d))
		(i32.const 127)
	))
	(i32.store8 offset=31 (get_local $d) (i32.or
		(i32.load8_u offset=31 (get_local $d))
		(i32.const 64)
	))

	(get_local $p)
	(get_local $d)
	(get_local $alloc)
	(call $scalarbase)

	(get_local $pk)
	(get_local $p)
	(get_local $alloc)
	(call $pack)

	(i64.store offset=32 (get_local $sk) (i64.load offset=0 (get_local $pk)))
	(i64.store offset=40 (get_local $sk) (i64.load offset=8 (get_local $pk)))
	(i64.store offset=48 (get_local $sk) (i64.load offset=16 (get_local $pk)))
	(i64.store offset=56 (get_local $sk) (i64.load offset=24 (get_local $pk)))
)
