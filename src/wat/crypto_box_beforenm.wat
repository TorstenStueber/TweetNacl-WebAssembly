;; Author: Torsten Stüber

;; output pointer $k: 32 bytes
;; input pointer $y: 32 bytes
;; input pointer $x: 32 bytes
;; alloc pointer $alloc: 928 + 32 = 960 bytes
(func $crypto_box_beforenm (export "crypto_box_beforenm") 
	(param $k i32)
	(param $y i32)
	(param $x i32)
	(param $alloc i32)
	
	(local $s i32)
	(set_local $s (i32.add (i32.const 928) (get_local $alloc)))

	(get_local $s)
	(get_local $x)
	(get_local $y)
	(get_local $alloc)
	(call $crypto_scalarmult)

	(get_local $k)
	(get_global $_0)
	(get_local $s)
	(get_global $sigma)
	(call $core_hsalsa20) ;; crypto_stream_salsa20
)
