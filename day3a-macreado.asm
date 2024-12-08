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

  %macro expect 1
    next_char
    cmp cl, %1
    jne .start
  %endmacro

  %macro parse_digit 2
    %%first_digit:
      ; Mínimo un dígito
      next_char
      sub cl, '0'
      jb .start
      cmp cl, 9
      ja .start
      movzx %1, cl
    %%digit_or_exit:
      next_char
      cmp cl, %2
      je %%next
      sub cl, '0'
      jb .start
      cmp cl, 9
      ja .start
      movzx rcx, cl
      imul %1, 10
      add %1, rcx
      jmp %%digit_or_exit
    %%next:
  %endmacro

  .start:
    expect 'm'
    expect 'u'
    expect 'l'
    expect '('
    parse_digit rdx, ','
    parse_digit rsi, ')'
    imul rdx, rsi
    add rdi, rdx
    jmp .start

  .ret:
    mov rax, 60
    syscall
