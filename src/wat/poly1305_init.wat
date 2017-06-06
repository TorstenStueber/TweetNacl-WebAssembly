;; Author: Torsten Stüber

;; polyobject
;;  pad: 0..15
;;  r: 16..35
;;  leftover: 36..39
;;  h: 40..59 
;;  final: 60..63
;;  buffer: 64..79

;; output pointer $polyobject: 80 bytes
;; input pointer $k: 32 bytes
(func $poly1305_init (export "poly1305_init")
	(param $polyobject i32)
	(param $k i32)
	
	(i32.store offset=16 (get_local $polyobject) (i32.and (i32.load offset=0 (get_local $k))                            (i32.const 0x3ffffff)))
	(i32.store offset=20 (get_local $polyobject) (i32.and (i32.shr_u (i32.load offset=3 ( get_local $k)) (i32.const 2)) (i32.const 0x3ffff03)))
	(i32.store offset=24 (get_local $polyobject) (i32.and (i32.shr_u (i32.load offset=6  (get_local $k)) (i32.const 4)) (i32.const 0x3ffc0ff)))
	(i32.store offset=28 (get_local $polyobject) (i32.and (i32.shr_u (i32.load offset=9  (get_local $k)) (i32.const 6)) (i32.const 0x3f03fff)))
	(i32.store offset=32 (get_local $polyobject) (i32.and (i32.shr_u (i32.load offset=12 (get_local $k)) (i32.const 8)) (i32.const 0x00fffff)))

	(i64.store offset=0 (get_local $polyobject) (i64.load offset=16 (get_local $k)))
	(i64.store offset=8 (get_local $polyobject) (i64.load offset=24 (get_local $k)))
	(i32.store offset=36 (get_local $polyobject) (i32.const 0))
	(i64.store offset=40 (get_local $polyobject) (i64.const 0))
	(i64.store offset=48 (get_local $polyobject) (i64.const 0))
	(i64.store offset=56 (get_local $polyobject) (i64.const 0))
)
