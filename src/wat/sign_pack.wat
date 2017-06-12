;; Author: Torsten Stüber

;; output pointer $r: 32 bytes
;; input pointer $p: 4 * (16 i64) = 512 bytes
;; alloc pointer $alloc: 512 bytes
(func $pack (export "pack")
	(param $r i32)
	(param $p i32)
	(param $alloc i32)

	(local $ty i32) (local $zi i32)

	(set_local $ty (i32.add (get_local $p) (i32.const 128)))
	(tee_local $zi (i32.add (get_local $p) (i32.const 256)))

	(i32.add (get_local $p) (i32.const 256))
	(get_local $alloc)
	(call $inv25519)

	(get_local $alloc)
	(get_local $p)
	(get_local $zi)
	(call $M)

	(get_local $ty)
	(i32.add (get_local $p) (i32.const 128))
	(get_local $zi)
	(call $M)

	(get_local $r)
	(get_local $ty)
	(get_local $zi)
	(call $pack25519)

	
	(i32.store8 offset=31 (get_local $r) (i32.xor (i32.load8_u offset=31 (get_local $r))
		(i32.shl (call $par25519 (get_local $alloc) (get_local $ty)) (i32.const 7))
	))
)