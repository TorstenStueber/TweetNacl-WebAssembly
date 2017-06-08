;; Author: Torsten Stüber

;; output pointer $c: $d bytes
;; input value $d
;; input pointer $n: 24 bytes
;; input pointer $k: 32 bytes
;; alloc pointer $alloc: 120 bytes
(func $crypto_stream (export "crypto_stream") 
	(param $c i32)
	(param $d i32)
	(param $n i32)
	(param $k i32)
	(param $alloc i32)
	
	(local $s i32)
	(local $sn i32)

	(set_local $sn (i32.add (i32.const 32) (tee_local $s (get_local $alloc))))

	(get_local $s)
	(get_local $n)
	(get_local $k)
	(get_global $sigma)
	(call $core_hsalsa20) ;; core_hsalsa20

	(i64.store (get_local $sn) (i64.load offset=16 (get_local $n)))

	(get_local $c)
	(get_local $d)
	(get_local $sn)
	(get_local $s)
	(i32.add (i32.const 40) (get_local $alloc))
	(call $crypto_stream_salsa20) ;; crypto_stream_salsa20
)
