;; Author: Torsten Stüber

;; output pointer $c: $d bytes
;; input pointer $m: $d bytes
;; input value $d >= 32
;; input pointer $n: 24 bytes
;; input pointer $y: 32 bytes
;; input pointer $x: 32 bytes
;; alloc pointer $alloc: 960 + 32 = 992 bytes
;; return: 0 okay, -1 problem
(func $crypto_box (export "crypto_box")
	(param $c i32)
	(param $m i32)
	(param $d i32)
	(param $n i32)
	(param $y i32)
	(param $x i32)
	(param $alloc i32)
	(result i32)
	
	(local $k i32)
	(set_local $k (i32.add (i32.const 960) (get_local $alloc)))

	(get_local $k)
	(get_local $y)
	(get_local $x)
	(get_local $alloc)
	(call $crypto_box_beforenm)

	(get_local $c)
	(get_local $m)
	(get_local $d)
	(get_local $n)
	(get_local $k)
	(get_local $alloc)
	(call $crypto_secretbox)
)
