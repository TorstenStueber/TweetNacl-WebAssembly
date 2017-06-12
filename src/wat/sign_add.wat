;; Author: Torsten Stüber

;; input/output pointer $p: 4 * (16 i64) = 512 bytes
;; input pointer $q: 4 * (16 i64) = 512 bytes
;; alloc pointer $alloc: 9 * 128 = 1152 bytes
(func $add (export "add")
	(param $p i32)
	(param $q i32)
	(param $alloc i32)

	(local $b i32) (local $c i32) (local $d i32) (local $e i32)
	(local $f i32) (local $g i32) (local $h i32) (local $t i32)

	(set_local $b (i32.add (get_local $alloc) (i32.const 128)))
	(set_local $c (i32.add (get_local $alloc) (i32.const 256)))
	(set_local $d (i32.add (get_local $alloc) (i32.const 384)))
	(set_local $e (i32.add (get_local $alloc) (i32.const 512)))
	(set_local $f (i32.add (get_local $alloc) (i32.const 640)))
	(set_local $g (i32.add (get_local $alloc) (i32.const 768)))
	(set_local $h (i32.add (get_local $alloc) (i32.const 896)))
	(set_local $t (i32.add (get_local $alloc) (i32.const 1024)))

	(get_local $alloc)
	(i32.add (get_local $p) (i32.const 128))
	(get_local $p)
	(call $Z)

	(get_local $t)
	(i32.add (get_local $q) (i32.const 128))
	(get_local $q)
	(call $Z)

	(get_local $alloc)
	(get_local $alloc)
	(get_local $t)
	(call $M)

	(get_local $b)
	(get_local $p)
	(i32.add (get_local $p) (i32.const 128))
	(call $A)

	(get_local $t)
	(get_local $q)
	(i32.add (get_local $q) (i32.const 128))
	(call $A)

	(get_local $b)
	(get_local $b)
	(get_local $t)
	(call $M)

	(get_local $c)
	(i32.add (get_local $p) (i32.const 384))
	(i32.add (get_local $q) (i32.const 384))
	(call $M)

	(get_local $c)
	(get_local $c)
	(get_global $D2)
	(call $M)

	(get_local $d)
	(i32.add (get_local $p) (i32.const 256))
	(i32.add (get_local $q) (i32.const 256))
	(call $M)

	(get_local $d)
	(get_local $d)
	(get_local $d)
	(call $A)

	(get_local $e)
	(get_local $b)
	(get_local $alloc)
	(call $Z)

	(get_local $f)
	(get_local $d)
	(get_local $c)
	(call $Z)

	(get_local $g)
	(get_local $d)
	(get_local $c)
	(call $A)

	(get_local $h)
	(get_local $b)
	(get_local $alloc)
	(call $A)

	(get_local $p)
	(get_local $e)
	(get_local $f)
	(call $M)

	(i32.add (get_local $p) (i32.const 128))
	(get_local $h)
	(get_local $g)
	(call $M)

	(i32.add (get_local $p) (i32.const 256))
	(get_local $g)
	(get_local $f)
	(call $M)

	(i32.add (get_local $p) (i32.const 384))
	(get_local $e)
	(get_local $h)
	(call $M)
)