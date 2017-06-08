;; Author: Torsten Stüber

;; output pointer: $c bytes
;; input pointer $msg: $d bytes
;; input value $d
;; input pointer $nonce: 24 bytes
;; input pointer $key: 32 bytes
;; alloc pointer $alloc: 120 bytes
;; return: pointer to output: $d - 16 bytes; will point to $c area
(func $nacl_secretbox (export "nacl_secretbox")
	(param $c i32)
	(param $m i32)
	(param $d i32)
	(param $nonce i32)
	(param $key i32)
	(param $alloc i32)
	(result i32)

	(i64.store offset=0 (get_local $m) (i64.const 0))
	(i64.store offset=8 (get_local $m) (i64.const 0))
	(i64.store offset=16 (get_local $m) (i64.const 0))
	(i64.store offset=24 (get_local $m) (i64.const 0))
	
	(get_local $c)
	(get_local $m)
	(get_local $d)
	(get_local $nonce)
	(get_local $key)
	(get_local $alloc)
	(call $crypto_secretbox)

	(drop)

	(i32.add (get_local $c) (i32.const 16))
)

;; output pointer $m: $d bytes
;; input pointer $box: $d bytes
;; input value $d
;; input pointer $nonce: 24 bytes
;; input pointer $key: 32 bytes
;; alloc pointer $alloc: 152 bytes
;; return: pointer to output: $d - 32 bytes (if -1, then problem occured); will point to $d area
(func $nacl_secretbox_open (export "nacl_secretbox_open")
	(param $m i32)
	(param $box i32)
	(param $d i32)
	(param $nonce i32)
	(param $key i32)
	(param $alloc i32)
	(result i32)

	(i64.store offset=0 (get_local $box) (i64.const 0))
	(i64.store offset=8 (get_local $box) (i64.const 0))
	
	(get_local $m)
	(get_local $box)
	(get_local $d)
	(get_local $nonce)
	(get_local $key)
	(get_local $alloc)
	(call $crypto_secretbox_open)

	(i32.const 0)
	(if (i32.ne)
		(then
			(i32.const -1)
			(return)
		)
	)

	(i32.add (get_local $m) (i32.const 32))
)
