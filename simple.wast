(module
  (memory (export "mem") 1)
  (func (export "accumulate") (param $len i32) (result i32)
    (local $ptr i32)
    (local $sum i32)
    (block $break
      (loop $top
        (br_if $break (i32.eq (get_local $ptr) (get_local $len)))
        (set_local $sum (i32.rem_u (i32.add (get_local $sum) (get_local $ptr)) (i32.const 12345) ))
        (set_local $ptr (i32.add (get_local $ptr) (i32.const 1)))
        (br $top)
      )
    )
    (get_local $sum)
  )
)