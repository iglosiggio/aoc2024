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

  %macro expect 2
    next_char
    cmp cl, %1
    jne %2
  %endmacro

  %macro parse_digit 3
    %%first_digit:
      ; Mínimo un dígito
      next_char
      sub cl, '0'
      jb %3
      cmp cl, 9
      ja %3
      movzx %1, cl
    %%digit_or_exit:
      next_char
      cmp cl, %2
      je %%next
      sub cl, '0'
      jb %3
      cmp cl, 9
      ja %3
      movzx rcx, cl
      imul %1, 10
      add %1, rcx
      jmp %%digit_or_exit
    %%next:
  %endmacro

  .do_state:
    next_char
    cmp cl, 'd'
    je .maybe_dont
    cmp cl, 'm'
    jne .do_state
    expect 'u', .do_state
    expect 'l', .do_state
    expect '(', .do_state
    parse_digit rdx, ',', .do_state
    parse_digit rsi, ')', .do_state
    imul rdx, rsi
    add rdi, rdx
    jmp .do_state
  .maybe_dont:
    expect 'o', .do_state
    expect 'n', .do_state
    expect "'", .do_state
    expect 't', .do_state
    expect '(', .do_state
    expect ')', .do_state
  .dont_state:
    expect 'd', .dont_state
    expect 'o', .dont_state
    expect '(', .dont_state
    expect ')', .dont_state
    jmp .do_state

  .ret:
    mov rax, 60
    syscall