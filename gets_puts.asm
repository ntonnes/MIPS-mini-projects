    .data
buffer_first: .space 64    # buffer to store first name
buffer_last:  .space 64    # buffer to store last name
prompt_first: .asciiz "First name: "
prompt_last:  .asciiz "Last name: "
format_output: .asciiz "You entered: "
comma_space:  .asciiz ", "
dot:          .asciiz "."
newline:      .asciiz "\n"

    .text
main:
    la $a0, prompt_first
    jal PUTS
    la $a0, newline
    jal PUTS
    la $a0, buffer_first
    la $a1, 64
    jal GETS

    la $a0, prompt_last
    jal PUTS
    la $a0, newline
    jal PUTS
    la $a0, buffer_last
    li $a1, 64
    jal GETS

    la $a0, format_output
    jal PUTS
    la $a0, buffer_last
    jal PUTS
    la $a0, comma_space
    jal PUTS
    la $a0, buffer_first
    jal PUTS
    la $a0, dot
    jal PUTS
    la $a0, newline
    jal PUTS

    li $v0, 10
    syscall


# Driver for getting 1 character
GETCHAR:
		lui $a3, 0xffff 			# base address of memory map
CkReady:
		lw $t1, 0($a3) 				# read from receiver control reg
    		andi $t1, $t1, 0x0001 			# extract ready bit
    		beqz $t1, CkReady 			# if 1, then load char, else loop
    		lw $v0, 4($a3) 				# load character from keyboard
		jr $ra 					# return to gets_loop
		
# Function for getting a string into a passed buffer
GETS:
    		addi $sp, $sp, -12      		# allocate space for 3 items on the stack
    		
    		sw $ra, 8($sp)				# push the parent's return address onto the stack
    		sw $a1, 4($sp)         			# push the buffer limit onto the stack 
    		sw $a0, 0($sp)             		# push the buffer address onto the stack
    		
    		move $v0, $zero				# initialize the return value to 0
    
getchar_loop:
		jal GETCHAR
		
		li $t0, 10
		beq $v0, $t0, end_gets
		addiu $t1, $v0, 1
		beq $t1, $a1, end_gets

        # Check if the character is a backspace
        li $t0, 8
        beq $v0, $t0, handle_backspace
        li $t0, 127
        beq $v0, $t0, handle_backspace
		
		sb $v0, 0($a0)
		addiu $a0, $a0, 1
		
		addiu $v0, $v0, 1
		
		j getchar_loop
    
handle_backspace:
    # Check if we're at the start of the buffer
    lw $t0, 0($sp)
    bne $a0, $t0, decrement_pointer
    j getchar_loop

decrement_pointer:
    addiu $a0, $a0, -1
    j getchar_loop
    
end_gets:
    		beq     $v0, $a1, skip_null
   		sb      $zero, 0($a0)
   		
skip_null:
    # Restore registers from the stack
    lw      $a0, 0($sp)
    lw      $a1, 4($sp)
    lw      $ra, 8($sp)
    addiu   $sp, $sp, 12

    # Return to the caller
    jr      $ra



PUTCHAR:
		lui $t0, 0xffff 			# base address of memory map
XReady:
		lw $t1, 8($t0) 				# read from transmitter control reg
		andi $t1, $t1, 0x0001 			# extract ready bit
		beqz $t1, XReady 			# if 1, then store char, else loop
		sw $a0, 12($t0) 			# send character to display
		jr $ra 					# return to call location
		
PUTS:
    # Save registers on the stack
    addiu   $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $a0, 0($sp)

putchar_loop:
    # Load a character from the buffer
    lb      $a0, 0($a0)

    # Check if the character is a null byte
    beq     $a0, $zero, end_puts

    # Call PUTCHAR function
    jal     PUTCHAR

    # Increment the buffer pointer
    lw      $a0, 0($sp)
    addiu   $a0, $a0, 1
    sw      $a0, 0($sp)

    # Continue the loop
    j       putchar_loop

end_puts:
    # Restore registers from the stack
    lw      $a0, 0($sp)
    lw      $ra, 4($sp)
    addiu   $sp, $sp, 8

    # Return to the caller
    jr      $ra


