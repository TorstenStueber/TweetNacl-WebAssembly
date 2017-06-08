;; Author: Torsten Stüber

;; output pointer $o: 32 bytes
;; input pointer $n: 16 i64 = 128 bytes
;; alloc pointer $alloc: 256 bytes
(func $pack25519 (export "pack25519")
	(param $o i32)
	(param $n i32)
	(param $alloc i32)

	(local $b i32)
	(local $m i32)
	(local $t i32)

	(tee_local $m (get_local $alloc))
	(set_local $t (i32.add (i32.const 128)))

	(i64.store offset=0 (get_local $t) (i64.load offset=0 (get_local $n)))
	(i64.store offset=8 (get_local $t) (i64.load offset=8 (get_local $n)))
	(i64.store offset=16 (get_local $t) (i64.load offset=16 (get_local $n)))
	(i64.store offset=24 (get_local $t) (i64.load offset=24 (get_local $n)))
	(i64.store offset=32 (get_local $t) (i64.load offset=32 (get_local $n)))
	(i64.store offset=40 (get_local $t) (i64.load offset=40 (get_local $n)))
	(i64.store offset=48 (get_local $t) (i64.load offset=48 (get_local $n)))
	(i64.store offset=56 (get_local $t) (i64.load offset=56 (get_local $n)))
	(i64.store offset=64 (get_local $t) (i64.load offset=64 (get_local $n)))
	(i64.store offset=72 (get_local $t) (i64.load offset=72 (get_local $n)))
	(i64.store offset=80 (get_local $t) (i64.load offset=80 (get_local $n)))
	(i64.store offset=88 (get_local $t) (i64.load offset=88 (get_local $n)))
	(i64.store offset=96 (get_local $t) (i64.load offset=96 (get_local $n)))
	(i64.store offset=104 (get_local $t) (i64.load offset=104 (get_local $n)))
	(i64.store offset=112 (get_local $t) (i64.load offset=112 (get_local $n)))
	(i64.store offset=120 (get_local $t) (i64.load offset=120 (get_local $n)))

	(get_local $t)
	(call $car25519)
	(get_local $t)
	(call $car25519)
	(get_local $t)
	(call $car25519)

	
	(i64.store offset=0 (get_local $m) (i64.sub (i64.load offset=0 (get_local $t)) (i64.const 0xffed)))
	(i64.store offset=8 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=8 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=0 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=0 (get_local $m) (i64.and (i64.load offset=0 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=16 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=16 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=8 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=8 (get_local $m) (i64.and (i64.load offset=8 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=24 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=24 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=16 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=16 (get_local $m) (i64.and (i64.load offset=16 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=32 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=32 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=24 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=24 (get_local $m) (i64.and (i64.load offset=24 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=40 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=40 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=32 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=32 (get_local $m) (i64.and (i64.load offset=32 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=48 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=48 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=40 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=40 (get_local $m) (i64.and (i64.load offset=40 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=56 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=56 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=48 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=48 (get_local $m) (i64.and (i64.load offset=48 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=64 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=64 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=56 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=56 (get_local $m) (i64.and (i64.load offset=56 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=72 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=72 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=64 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=64 (get_local $m) (i64.and (i64.load offset=64 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=80 (get_local $m) (i64.sub 
		(i64.sub (i64.load offset=80 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=72 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=72 (get_local $m) (i64.and (i64.load offset=72 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=88 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=88 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=80 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=80 (get_local $m) (i64.and (i64.load offset=80 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=96 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=96 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=88 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=88 (get_local $m) (i64.and (i64.load offset=88 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=104 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=104 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=96 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=96 (get_local $m) (i64.and (i64.load offset=96 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=112 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=112 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=104 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=104 (get_local $m) (i64.and (i64.load offset=104 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=120 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=120 (get_local $t)) (i64.const 0x7fff)) 
		(i64.and (i64.shr_s (i64.load offset=112 (get_local $m)) (i64.const 16)) (i64.const 1))
	))

	(set_local $b (i32.wrap/i64 (i64.and
		(i64.shr_s (i64.load offset=120 (get_local $m)) (i64.const 16))
		(i64.const 1)
	)))
	(i64.store offset=112 (get_local $m) (i64.and (i64.load offset=112 (get_local $m)) (i64.const 0xffff)))

	(get_local $t)
	(get_local $m)
	(i32.sub (i32.const 1) (get_local $b))
	(call $sel25519)


	(i64.store offset=0 (get_local $m) (i64.sub (i64.load offset=0 (get_local $t)) (i64.const 0xffed)))
	(i64.store offset=8 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=8 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=0 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=0 (get_local $m) (i64.and (i64.load offset=0 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=16 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=16 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=8 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=8 (get_local $m) (i64.and (i64.load offset=8 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=24 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=24 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=16 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=16 (get_local $m) (i64.and (i64.load offset=16 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=32 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=32 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=24 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=24 (get_local $m) (i64.and (i64.load offset=24 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=40 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=40 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=32 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=32 (get_local $m) (i64.and (i64.load offset=32 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=48 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=48 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=40 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=40 (get_local $m) (i64.and (i64.load offset=40 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=56 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=56 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=48 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=48 (get_local $m) (i64.and (i64.load offset=48 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=64 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=64 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=56 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=56 (get_local $m) (i64.and (i64.load offset=56 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=72 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=72 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=64 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=64 (get_local $m) (i64.and (i64.load offset=64 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=80 (get_local $m) (i64.sub 
		(i64.sub (i64.load offset=80 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=72 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=72 (get_local $m) (i64.and (i64.load offset=72 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=88 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=88 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=80 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=80 (get_local $m) (i64.and (i64.load offset=80 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=96 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=96 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=88 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=88 (get_local $m) (i64.and (i64.load offset=88 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=104 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=104 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=96 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=96 (get_local $m) (i64.and (i64.load offset=96 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=112 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=112 (get_local $t)) (i64.const 0xffff)) 
		(i64.and (i64.shr_s (i64.load offset=104 (get_local $m)) (i64.const 16)) (i64.const 1))
	))
	(i64.store offset=104 (get_local $m) (i64.and (i64.load offset=104 (get_local $m)) (i64.const 0xffff)))
	(i64.store offset=120 (get_local $m) (i64.sub
		(i64.sub (i64.load offset=120 (get_local $t)) (i64.const 0x7fff)) 
		(i64.and (i64.shr_s (i64.load offset=112 (get_local $m)) (i64.const 16)) (i64.const 1))
	))

	(set_local $b (i32.wrap/i64 (i64.and
		(i64.shr_s (i64.load offset=120 (get_local $m)) (i64.const 16))
		(i64.const 1)
	)))
	(i64.store offset=112 (get_local $m) (i64.and (i64.load offset=112 (get_local $m)) (i64.const 0xffff)))

	(get_local $t)
	(get_local $m)
	(i32.sub (i32.const 1) (get_local $b))
	(call $sel25519)

	(i64.store16 offset=0 (get_local $o) (i64.load offset=0 (get_local $t)))
	(i64.store16 offset=2 (get_local $o) (i64.load offset=8 (get_local $t)))
	(i64.store16 offset=4 (get_local $o) (i64.load offset=16 (get_local $t)))
	(i64.store16 offset=6 (get_local $o) (i64.load offset=24 (get_local $t)))
	(i64.store16 offset=8 (get_local $o) (i64.load offset=32 (get_local $t)))
	(i64.store16 offset=10 (get_local $o) (i64.load offset=40 (get_local $t)))
	(i64.store16 offset=12 (get_local $o) (i64.load offset=48 (get_local $t)))
	(i64.store16 offset=14 (get_local $o) (i64.load offset=56 (get_local $t)))
	(i64.store16 offset=16 (get_local $o) (i64.load offset=64 (get_local $t)))
	(i64.store16 offset=18 (get_local $o) (i64.load offset=72 (get_local $t)))
	(i64.store16 offset=20 (get_local $o) (i64.load offset=80 (get_local $t)))
	(i64.store16 offset=22 (get_local $o) (i64.load offset=88 (get_local $t)))
	(i64.store16 offset=24 (get_local $o) (i64.load offset=96 (get_local $t)))
	(i64.store16 offset=26 (get_local $o) (i64.load offset=104 (get_local $t)))
	(i64.store16 offset=28 (get_local $o) (i64.load offset=112 (get_local $t)))
	(i64.store16 offset=30 (get_local $o) (i64.load offset=120 (get_local $t)))
)