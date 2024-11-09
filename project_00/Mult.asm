(START)
  @R2
  M=0

  @R0
  D=M

  // n is R0
  @n
  M=D

  // i starts @ 0
  @i
  M=0

(LOOP)
  // GO_TO @END if n - i = 0
  @i
  D=M

  // M is n
  // Then D will be = n - i
  @n
  D=M-D

  @END
  D;JEQ

  @i
  M=M+1

  @R1
  D=M

  @R2
  M=M+D

  @LOOP
  0;JMP

(END)
  @END
  0;JMP
