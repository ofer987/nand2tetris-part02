(INIT)
	// End of SCREEN
	@KBD
	D=A

	@END_OF_SCREEN
	M=D

(START)
	// Start from the beginnning of SCREEN
	@SCREEN
	D=A

	@cursor
	M=D

	@KBD
	D=M

	@current_key
	M=D

	// Iterate till 16384
(LOOP)
	@cursor
	D=M

	@END_OF_SCREEN
	D=M-D

	@START
	D;JEQ

	// Has key changed?
	@KBD
	D=M

	@new_key
	M=D

	@current_key
	D=M-D

	@START
	D;JNE

	@current_key
	D=M

	@PRINT_WHITE
	D;JEQ

(PRINT_BLACK)
	@cursor
	A=M

	// 1111 111 1111 1111
	M=-1

	@CONTINUE
	0;JMP

(PRINT_WHITE)
	@cursor
	A=M

	// 0000 000 0000 0000
	M=0

	@CONTINUE
	0;JMP

(CONTINUE)

	@cursor
	M=M+1

	@LOOP
	0;JMP
(END_LOOP)

(END)
	@END
	0;JMP
