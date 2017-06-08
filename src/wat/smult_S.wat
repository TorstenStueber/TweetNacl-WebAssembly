;; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
(func $S (export "S")
	(param $o i32)
	(param $a i32)

	(get_local $o)
	(get_local $a)
	(get_local $a)
	(call $M)
)