;; Author: Torsten Stüber

;; output pointer $dest: $length bytes
;; input pointer $src: $length bytes
;; input value $length
(func $cpy
	(param $dest i32)
	(param $src i32)
	(param $length i32)

	(block
		(loop
			(br_if 1 (i32.lt_u (get_local $length) (i32.const 8)))

			(i64.store (get_local $dest) (i64.load (get_local $src)))

			(set_local $dest (i32.add (get_local $dest) (i32.const 8)))
			(set_local $src (i32.add (get_local $src) (i32.const 8)))
			(set_local $length (i32.sub (get_local $length) (i32.const 8)))
			(br 0)
		)
	)

	(block
		(loop
			(br_if 1 (i32.eq (get_local $length) (i32.const 0)))

			(i32.store8 (get_local $dest) (i32.load8_u (get_local $src)))

			(set_local $dest (i32.add (get_local $dest) (i32.const 1)))
			(set_local $src (i32.add (get_local $src) (i32.const 1)))
			(set_local $length (i32.sub (get_local $length) (i32.const 1)))
			(br 0)
		)
	)
)

;; input pointer $msg: $d bytes
;; input value $d
;; input pointer $nonce: 24 bytes
;; input pointer $key: 32 bytes
;; input pointer $sigma: 16 bytes
;; alloc pointer $alloc: 120 bytes + 2 * (32 + ceil($d/8)*8) (=184 + ceil($d/8)*16)
;; return: pointer to output: $d + 16 bytes; will point to $alloc area
(func $nacl_secretbox (export "nacl_secretbox")
	(param $msg i32)
	(param $d i32)
	(param $nonce i32)
	(param $key i32)
	(param $sigma i32)
	(param $alloc i32)
	(result i32)

	(local $daligned i32)
	(local $c i32)
	(local $m i32)

	(if (i32.gt_u (i32.and (get_local $d) (i32.const 7)) (i32.const 0))
		(then
			(set_local $daligned (i32.add (i32.and (get_local $d) (i32.const 0xfffffff8)) (i32.const 8)))
		)
		(else
			(set_local $daligned (get_local $d))
		)
	)

	(set_local $m (i32.add (get_local $alloc) (i32.const 120)))
	(set_local $c (i32.add (i32.add (get_local $alloc) (i32.const 152)) (get_local $daligned)))
	(i64.store offset=0 (get_local $m) (i64.const 0))
	(i64.store offset=8 (get_local $m) (i64.const 0))
	(i64.store offset=16 (get_local $m) (i64.const 0))
	(i64.store offset=24 (get_local $m) (i64.const 0))

	(i32.add (get_local $m) (i32.const 32))
	(get_local $msg)
	(get_local $d)
	(call $cpy)
	
	(get_local $c)
	(get_local $m)
	(i32.add (get_local $d) (i32.const 32))
	(get_local $nonce)
	(get_local $key)
	(get_local $sigma)
	(get_local $alloc)
	(call $crypto_secretbox)

	(drop)

	(i32.add (get_local $c) (i32.const 16))
)

;; input pointer $box: $d bytes
;; input value $d
;; input pointer $nonce: 24 bytes
;; input pointer $key: 32 bytes
;; input pointer $sigma: 16 bytes
;; alloc pointer $alloc: 152 bytes + 2 * (16 + ceil($d/8)*8) (=184 + ceil($d/8)*16)
;; return: pointer to output: $d - 16 bytes (if -1, then problem occured); will point to $alloc area
(func $nacl_secretbox_open (export "nacl_secretbox_open")
	(param $box i32)
	(param $d i32)
	(param $nonce i32)
	(param $key i32)
	(param $sigma i32)
	(param $alloc i32)
	(result i32)

	(local $daligned i32)
	(local $c i32)
	(local $m i32)

	(if (i32.lt_u (get_local $d) (i32.const 16))
		(then
			(i32.const -1)
			(return)
		)
	)

	(if (i32.gt_u (i32.and (get_local $d) (i32.const 7)) (i32.const 0))
		(then
			(set_local $daligned (i32.add (i32.and (get_local $d) (i32.const 0xfffffff8)) (i32.const 8)))
		)
		(else
			(set_local $daligned (get_local $d))
		)
	)

	(set_local $c (i32.add (get_local $alloc) (i32.const 152)))
	(set_local $m (i32.add (i32.add (get_local $alloc) (i32.const 168)) (get_local $daligned)))
	(i64.store offset=0 (get_local $c) (i64.const 0))
	(i64.store offset=8 (get_local $c) (i64.const 0))

	(i32.add (get_local $c) (i32.const 16))
	(get_local $box)
	(get_local $d)
	(call $cpy)
	
	(get_local $m)
	(get_local $c)
	(i32.add (get_local $d) (i32.const 16))
	(get_local $nonce)
	(get_local $key)
	(get_local $sigma)
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
