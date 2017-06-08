;; Author: Torsten Stüber

;; output pointer $c: $d bytes
;; input pointer $m: $d bytes
;; input value $d >= 32
;; input pointer $n: 24 bytes
;; input pointer $k: 32 bytes
;; alloc pointer $alloc: 120 bytes
;; return: 0 okay, -1 if $d < 32
(func $crypto_secretbox (export "crypto_secretbox")
	(param $c i32)
	(param $m i32)
	(param $d i32)
	(param $n i32)
	(param $k i32)
	(param $alloc i32)
	(result i32)
	
	(if (i32.ge_u (get_local $d) (i32.const 32))
		(then
			(get_local $c)
			(get_local $m)
			(get_local $d)
			(get_local $n)
			(get_local $k)
			(get_local $alloc)
			(call $crypto_stream_xor)

			(i32.add (i32.const 16) (get_local $c))
			(i32.add (i32.const 32) (get_local $c))
			(i32.sub (get_local $d) (i32.const 32))
			(get_local $c)
			(get_local $alloc)
			(call $crypto_onetimeauth)

			(i64.store offset=0 (get_local $c) (i64.const 0))
			(i64.store offset=8 (get_local $c) (i64.const 0))
			(i32.const 0)
			return
		)
	)
	(i32.const -1)
)
