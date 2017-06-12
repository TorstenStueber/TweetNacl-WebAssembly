;; Author: Torsten Stüber

;; input/output pointer $p: 4 * (16 i64) = 512 bytes
;; input pointer $q: 4 * (16 i64) = 512 bytes
;; alloc pointer $alloc: 384 bytes
(func $add (export "add")
	(param $p i32)
	(param $q i32)
	(param $alloc i32)

	(local $p1 i32) (local $p2 i32) (local $p3 i32)
	(local $t i32) (local $u i32)

	(set_local $p1 (i32.add (get_local $p) (i32.const 128)))
	(set_local $p2 (i32.add (get_local $p) (i32.const 256)))
	(set_local $p3 (i32.add (get_local $p) (i32.const 384)))
	(set_local $t (i32.add (get_local $alloc) (i32.const 128)))
	(set_local $u (i32.add (get_local $alloc) (i32.const 256)))

	(get_local $alloc)
	(get_local $p)
	(get_local $p1)
	(call $A)

	(get_local $u)
	(get_local $q)
	(i32.add (get_local $q) (i32.const 128))
	(call $A)

	(get_local $t)
	(i32.add (get_local $q) (i32.const 128))
	(get_local $q)
	(call $Z)

	(get_local $p1)
	(get_local $p1)
	(get_local $p)
	(call $Z)

	(get_local $p)
	(get_local $alloc)
	(get_local $u)
	(call $M)

	(get_local $p1)
	(get_local $p1)
	(get_local $t)
	(call $M)

	(get_local $p2)
	(get_local $p2)
	(i32.add (get_local $q) (i32.const 256))
	(call $M)

	(get_local $p2)
	(get_local $p2)
	(get_local $p2)
	(call $A)

	(get_local $p3)
	(get_local $p3)
	(i32.add (get_local $q) (i32.const 384))
	(call $M)

	(get_local $p3)
	(get_local $p3)
	(get_global $D2)
	(call $M)

	(get_local $alloc)
	(get_local $p2)
	(get_local $p3)
	(call $A)

	(get_local $p2)
	(get_local $p2)
	(get_local $p3)
	(call $Z)

	(get_local $p3)
	(get_local $p)
	(get_local $p1)
	(call $A)

	(get_local $p)
	(get_local $p)
	(get_local $p1)
	(call $Z)

	(get_local $p1)
	(get_local $p3)
	(get_local $alloc)
	(call $M)

	(get_local $p3)
	(get_local $p)
	(get_local $p3)
	(call $M)

	(get_local $p)
	(get_local $p)
	(get_local $p2)
	(call $M)

	(get_local $p2)
	(get_local $alloc)
	(get_local $p2)
	(call $M)
)