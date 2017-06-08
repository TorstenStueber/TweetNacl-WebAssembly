;; Author: Torsten Stüber

;; output pointer $o: 16 i64 = 128 bytes
;; input pointer $a: 16 i64 = 128 bytes
;; input pointer $b: 16 i64 = 128 bytes
(func $A (export "A")
	(param $o i32)
	(param $a i32)
	(param $b i32)

	(i64.store offset=0 (get_local $o) (i64.add (i64.load offset=0 (get_local $a)) (i64.load offset=0 (get_local $b))))
	(i64.store offset=8 (get_local $o) (i64.add (i64.load offset=8 (get_local $a)) (i64.load offset=8 (get_local $b))))
	(i64.store offset=16 (get_local $o) (i64.add (i64.load offset=16 (get_local $a)) (i64.load offset=16 (get_local $b))))
	(i64.store offset=24 (get_local $o) (i64.add (i64.load offset=24 (get_local $a)) (i64.load offset=24 (get_local $b))))
	(i64.store offset=32 (get_local $o) (i64.add (i64.load offset=32 (get_local $a)) (i64.load offset=32 (get_local $b))))
	(i64.store offset=40 (get_local $o) (i64.add (i64.load offset=40 (get_local $a)) (i64.load offset=40 (get_local $b))))
	(i64.store offset=48 (get_local $o) (i64.add (i64.load offset=48 (get_local $a)) (i64.load offset=48 (get_local $b))))
	(i64.store offset=56 (get_local $o) (i64.add (i64.load offset=56 (get_local $a)) (i64.load offset=56 (get_local $b))))
	(i64.store offset=64 (get_local $o) (i64.add (i64.load offset=64 (get_local $a)) (i64.load offset=64 (get_local $b))))
	(i64.store offset=72 (get_local $o) (i64.add (i64.load offset=72 (get_local $a)) (i64.load offset=72 (get_local $b))))
	(i64.store offset=80 (get_local $o) (i64.add (i64.load offset=80 (get_local $a)) (i64.load offset=80 (get_local $b))))
	(i64.store offset=88 (get_local $o) (i64.add (i64.load offset=88 (get_local $a)) (i64.load offset=88 (get_local $b))))
	(i64.store offset=96 (get_local $o) (i64.add (i64.load offset=96 (get_local $a)) (i64.load offset=96 (get_local $b))))
	(i64.store offset=104 (get_local $o) (i64.add (i64.load offset=104 (get_local $a)) (i64.load offset=104 (get_local $b))))
	(i64.store offset=112 (get_local $o) (i64.add (i64.load offset=112 (get_local $a)) (i64.load offset=112 (get_local $b))))
	(i64.store offset=120 (get_local $o) (i64.add (i64.load offset=120 (get_local $a)) (i64.load offset=120 (get_local $b))))
	
)