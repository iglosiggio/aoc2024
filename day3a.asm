global _start
_start:
  ; [rsp] = argc
  ; [rsp+4] = argv
  mov rax, [rsp + 8]
  xor rdi, rdi ; result
  ; rcx = current char
  ; rdx = mul lhs
  ; rsi = mul rhs

  %macro next_char 0
    mov cl, [rax]
    inc rax
    cmp cl, '0'
    je .ret
  %endmacro

  .wait_for_m:
    next_char
    cmp cl, 'm'
    jne .wait_for_m
  .expect_u:
    next_char
    cmp cl, 'u'
    jne .wait_for_m
  .expect_l:
    next_char
    cmp cl, 'l'
    jne .wait_for_m
  .expect_left_paren:
    next_char
    cmp cl, '('
    jne .wait_for_m
  ; Hasta acá ví "mul("

  ; Me toca parsear el LHS!
  .expect_digit_lhs:
    ; Mínimo un dígito
    next_char
    cmp cl, '0'
    jb .wait_for_m
    cmp cl, '9'
    ja .wait_for_m
    sub cl, '0'
    movzx rdx, cl
  .expect_digit_or_comma_lhs:
    next_char
    cmp cl, ','
    je .expect_digit_rhs
    cmp cl, '0'
    jb .wait_for_m
    cmp cl, '9'
    ja .wait_for_m
    sub cl, '0'
    movzx rcx, cl
    imul rdx, 10
    add rdx, rcx
    jmp .expect_digit_or_comma_lhs

  ; Me toca parsear el RHS!
  .expect_digit_rhs:
    ; Mínimo un dígito
    next_char
    cmp cl, '0'
    jb .wait_for_m
    cmp cl, '9'
    ja .wait_for_m
    sub cl, '0'
    movzx rsi, cl
  .expect_digit_or_comma_rhs:
    next_char
    cmp cl, ')'
    je .finish_mul
    cmp cl, '0'
    jb .wait_for_m
    cmp cl, '9'
    ja .wait_for_m
    sub cl, '0'
    movzx rcx, cl
    imul rsi, 10
    add rsi, rcx
    jmp .expect_digit_or_comma_rhs

  .finish_mul:
    imul rdx, rsi
    add rdi, rdx
    jmp .wait_for_m

  .ret:
    mov rax, 60
    syscall
