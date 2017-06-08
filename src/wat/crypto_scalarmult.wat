;; Author: Torsten Stüber

;; output pointer $q: 32 bytes
;; input pointer $n: 32 bytes
;; alloc pointer $alloc: 928 bytes
(func $crypto_scalarmult_base (export "crypto_scalarmult_base")
	(param $q i32)
	(param $n i32)
	(param $alloc i32)

	(get_local $q)
	(get_local $n)
	(get_global $_9)
	(get_local $alloc)
	(call $crypto_scalarmult)
)


;; output pointer $q: 32 bytes
;; input pointer $n: 32 bytes
;; input pointer $p: 32 bytes
;; alloc pointer $alloc: 32 + 640 + 2*128 = 928 bytes
;;     used structure: 
;;         0..31: $z
;;         32..671: $x; this contains
;;             32..159: used for $x in loop
;;             160..287: $a
;;             288..415: $c
;;             416..543: $b
;;             544..671: $d
;;         672..799: $e, reused in pack25519 and inv25519
;;         800..927: $f, reused in pack25519
(func $crypto_scalarmult (export "crypto_scalarmult")
	(param $q i32)
	(param $n i32)
	(param $p i32)
	(param $alloc i32)

	(local $z i32) ;; pointer to 32 bytes
	(local $x i32) ;; pointer to 640 bytes
	(local $r i32)
	(local $i i32)
	(local $a i32) ;; pointer to 128 bytes
	(local $b i32) ;; pointer to 128 bytes
	(local $c i32) ;; pointer to 128 bytes
	(local $d i32) ;; pointer to 128 bytes
	(local $e i32) ;; pointer to 128 bytes
	(local $f i32) ;; pointer to 128 bytes
	(local $x32 i32)
	(local $x16 i32)

	(tee_local $z (get_local $alloc))
	(tee_local $x (i32.add (i32.const 32)))
	(tee_local $a (i32.add (i32.const 128)))
	(tee_local $c (i32.add (i32.const 128)))
	(tee_local $b (i32.add (i32.const 128)))
	(tee_local $d (i32.add (i32.const 128)))
	(tee_local $e (i32.add (i32.const 128)))
	(set_local $f (i32.add (i32.const 128)))

	(i64.store offset=0 (get_local $z) (i64.load offset=0 (get_local $n)))
	(i64.store offset=8 (get_local $z) (i64.load offset=8 (get_local $n)))
	(i64.store offset=16 (get_local $z) (i64.load offset=16 (get_local $n)))
	(i64.store offset=24 (get_local $z) (i64.load offset=24 (get_local $n)))
	(i32.store8 offset=31 (get_local $z) (i32.or (i32.and (i32.load8_u offset=31 (get_local $n)) (i32.const 127)) (i32.const 64)))
	(i32.store8 (get_local $z) (i32.and (i32.load8_u (get_local $z)) (i32.const 248)))

	(get_local $x)
	(get_local $p)
	(call $unpack25519)

	(i64.store offset=0 (get_local $b) (i64.load offset=0 (get_local $x)))
	(i64.store offset=0 (get_local $d) (i64.const 1)) (i64.store offset=0 (get_local $a) (i64.const 1)) (i64.store offset=0 (get_local $c) (i64.const 0))
	(i64.store offset=8 (get_local $b) (i64.load offset=8 (get_local $x)))
	(i64.store offset=8 (get_local $d) (i64.const 0)) (i64.store offset=8 (get_local $a) (i64.const 0)) (i64.store offset=8 (get_local $c) (i64.const 0))
	(i64.store offset=16 (get_local $b) (i64.load offset=16 (get_local $x)))
	(i64.store offset=16 (get_local $d) (i64.const 0)) (i64.store offset=16 (get_local $a) (i64.const 0)) (i64.store offset=16 (get_local $c) (i64.const 0))
	(i64.store offset=24 (get_local $b) (i64.load offset=24 (get_local $x)))
	(i64.store offset=24 (get_local $d) (i64.const 0)) (i64.store offset=24 (get_local $a) (i64.const 0)) (i64.store offset=24 (get_local $c) (i64.const 0))
	(i64.store offset=32 (get_local $b) (i64.load offset=32 (get_local $x)))
	(i64.store offset=32 (get_local $d) (i64.const 0)) (i64.store offset=32 (get_local $a) (i64.const 0)) (i64.store offset=32 (get_local $c) (i64.const 0))
	(i64.store offset=40 (get_local $b) (i64.load offset=40 (get_local $x)))
	(i64.store offset=40 (get_local $d) (i64.const 0)) (i64.store offset=40 (get_local $a) (i64.const 0)) (i64.store offset=40 (get_local $c) (i64.const 0))
	(i64.store offset=48 (get_local $b) (i64.load offset=48 (get_local $x)))
	(i64.store offset=48 (get_local $d) (i64.const 0)) (i64.store offset=48 (get_local $a) (i64.const 0)) (i64.store offset=48 (get_local $c) (i64.const 0))
	(i64.store offset=56 (get_local $b) (i64.load offset=56 (get_local $x)))
	(i64.store offset=56 (get_local $d) (i64.const 0)) (i64.store offset=56 (get_local $a) (i64.const 0)) (i64.store offset=56 (get_local $c) (i64.const 0))
	(i64.store offset=64 (get_local $b) (i64.load offset=64 (get_local $x)))
	(i64.store offset=64 (get_local $d) (i64.const 0)) (i64.store offset=64 (get_local $a) (i64.const 0)) (i64.store offset=64 (get_local $c) (i64.const 0))
	(i64.store offset=72 (get_local $b) (i64.load offset=72 (get_local $x)))
	(i64.store offset=72 (get_local $d) (i64.const 0)) (i64.store offset=72 (get_local $a) (i64.const 0)) (i64.store offset=72 (get_local $c) (i64.const 0))
	(i64.store offset=80 (get_local $b) (i64.load offset=80 (get_local $x)))
	(i64.store offset=80 (get_local $d) (i64.const 0)) (i64.store offset=80 (get_local $a) (i64.const 0)) (i64.store offset=80 (get_local $c) (i64.const 0))
	(i64.store offset=88 (get_local $b) (i64.load offset=88 (get_local $x)))
	(i64.store offset=88 (get_local $d) (i64.const 0)) (i64.store offset=88 (get_local $a) (i64.const 0)) (i64.store offset=88 (get_local $c) (i64.const 0))
	(i64.store offset=96 (get_local $b) (i64.load offset=96 (get_local $x)))
	(i64.store offset=96 (get_local $d) (i64.const 0)) (i64.store offset=96 (get_local $a) (i64.const 0)) (i64.store offset=96 (get_local $c) (i64.const 0))
	(i64.store offset=104 (get_local $b) (i64.load offset=104 (get_local $x)))
	(i64.store offset=104 (get_local $d) (i64.const 0)) (i64.store offset=104 (get_local $a) (i64.const 0)) (i64.store offset=104 (get_local $c) (i64.const 0))
	(i64.store offset=112 (get_local $b) (i64.load offset=112 (get_local $x)))
	(i64.store offset=112 (get_local $d) (i64.const 0)) (i64.store offset=112 (get_local $a) (i64.const 0)) (i64.store offset=112 (get_local $c) (i64.const 0))
	(i64.store offset=120 (get_local $b) (i64.load offset=120 (get_local $x)))
	(i64.store offset=120 (get_local $d) (i64.const 0)) (i64.store offset=120 (get_local $a) (i64.const 0)) (i64.store offset=120 (get_local $c) (i64.const 0))
	
	(set_local $i (i32.const 254))
	(block
		(loop
			(br_if 1 (i32.lt_s (get_local $i) (i32.const 0)))

			(set_local $r (i32.and (i32.const 1) (i32.shr_u
				(i32.load8_u (i32.add (get_local $z) (i32.shr_u (get_local $i) (i32.const 3))))
				(i32.and (get_local $i) (i32.const 7))))
			)

			(call $sel25519 (get_local $a) (get_local $b) (get_local $r))
			(call $sel25519 (get_local $c) (get_local $d) (get_local $r))
			(call $A (get_local $e) (get_local $a) (get_local $c))
			(call $Z (get_local $a) (get_local $a) (get_local $c))
			(call $A (get_local $c) (get_local $b) (get_local $d))
			(call $Z (get_local $b) (get_local $b) (get_local $d))
			(call $S (get_local $d) (get_local $e))
			(call $S (get_local $f) (get_local $a))
			(call $M (get_local $a) (get_local $c) (get_local $a))
			(call $M (get_local $c) (get_local $b) (get_local $e))
			(call $A (get_local $e) (get_local $a) (get_local $c))
			(call $Z (get_local $a) (get_local $a) (get_local $c))
			(call $S (get_local $b) (get_local $a))
			(call $Z (get_local $c) (get_local $d) (get_local $f))
			(call $M (get_local $a) (get_local $c) (get_global $_121665))
			(call $A (get_local $a) (get_local $a) (get_local $d))
			(call $M (get_local $c) (get_local $c) (get_local $a))
			(call $M (get_local $a) (get_local $d) (get_local $f))
			(call $M (get_local $d) (get_local $b) (get_local $x))
			(call $S (get_local $b) (get_local $e))
			(call $sel25519 (get_local $a) (get_local $b) (get_local $r))
			(call $sel25519 (get_local $c) (get_local $d) (get_local $r))

			(set_local $i (i32.sub (get_local $i) (i32.const 1)))
			(br 0)
		)
	)

	(set_local $x32 (i32.add (get_local $x) (i32.const 256)))
	(set_local $x16 (i32.add (get_local $x) (i32.const 128)))

	
	(call $inv25519 (get_local $x32) (get_local $x32) (get_local $e))
	(call $M (get_local $x16) (get_local $x16) (get_local $x32))
	(call $pack25519 (get_local $q) (get_local $x16) (get_local $e))
)
