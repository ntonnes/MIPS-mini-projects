                .data
buffer_first:   .space 64                       # Allocate 64 bytes for the first name buffer
buffer_last:    .space 64                       # Allocate 64 bytes for the last name buffer
prompt_first:   .asciiz "First name: "          # String for the first name prompt
prompt_last:    .asciiz "Last name: "           # String for the last name prompt
format_output:  .asciiz "You entered: "         # String for the output format
comma_space:    .asciiz ", "                    # String for a comma and a space
dot:            .asciiz "."                     # String for a dot
newline:        .asciiz "\n"                    # String for a newline


                .text
main:
                la $a0, prompt_first            # Load the address of the first name prompt
                jal PUTS                        # Call the PUTS function to print the prompt
                la $a0, newline                 # Load the address of the newline string
                jal PUTS                        # Call the PUTS function to print a newline
                la $a0, buffer_first            # Load the address of the first name buffer
                la $a1, 64                      # Load the buffer size
                jal GETS                        # Call the GETS function to read the first name

                la $a0, prompt_last             # Load the address of the last name prompt
                jal PUTS                        # Call the PUTS function to print the prompt
                la $a0, newline                 # Load the address of the newline string
                jal PUTS                        # Call the PUTS function to print a newline
                la $a0, buffer_last             # Load the address of the last name buffer
                li $a1, 64                      # Load the buffer size
                jal GETS                        # Call the GETS function to read the last name

                la $a0, format_output           # Load the address of the output format string
                jal PUTS                        # Call the PUTS function to print the format string
                la $a0, buffer_last             # Load the address of the last name buffer
                jal PUTS                        # Call the PUTS function to print the last name
                la $a0, comma_space             # Load the address of the comma and space string
                jal PUTS                        # Call the PUTS function to print the comma and space
                la $a0, buffer_first            # Load the address of the first name buffer
                jal PUTS                        # Call the PUTS function to print the first name
                la $a0, dot                     # Load the address of the dot string
                jal PUTS                        # Call the PUTS function to print the dot
                la $a0, newline                 # Load the address of the newline string
                jal PUTS                        # Call the PUTS function to print a newline

                li $v0, 10                      # Load the syscall number for exit
                syscall                         # Call the syscall to exit the program


# Driver for reading 1 character from input
GETCHAR:
                lui $a3, 0xffff                 # Base address of memory map
CkReady:
                lw $t1, 0($a3)                  # Read from receiver control reg
                andi $t1, $t1, 0x0001           # Extract ready bit
                beqz $t1, CkReady               # If 1, then load char, else loop
                lw $v0, 4($a3)                  # Load character from keyboard
                jr $ra                          # Return to gets_loop

# Function for reading a string from input into a buffer
GETS:
                addi $sp, $sp, -16              # Allocate space for 3 items on the stack
                
                sw $zero, 12($sp)                  # Push the parent's return address onto the stack
                sw $ra, 8($sp)                  # Push the parent's return address onto the stack
                sw $a1, 4($sp)                  # Push the buffer limit onto the stack 
                sw $a0, 0($sp)                  # Push the buffer address onto the stack

                move $v0, $zero                 # Initialize the return value to 0
    
getchar_loop:
                jal GETCHAR                     # Call GETCHAR function to get a character from input

                li $t0, 10                      # Load immediate value 10 into $t0
                beq $v0, $t0, end_gets          # If the input character is newline (ASCII 10), jump to end_gets
                addiu $t1, $v0, 1               # Add 1 to the input character and store in $t1
                beq $t1, $a1, end_gets          # If $t1 equals to $a1, jump to end_gets

                li $t0, 8                       # Load immediate value 8 into $t0
                beq $v0, $t0, handle_backspace  # If the input character is backspace (ASCII 8), jump to handle_backspace
                li $t0, 127                     # Load immediate value 127 into $t0
                beq $v0, $t0, handle_backspace  # If the input character is delete (ASCII 127), jump to handle_backspace

                sb $v0, 0($a0)                  # Store the byte in $v0 to the address in $a0
                addiu $a0, $a0, 1               # Increment the address in $a0 by 1

                addiu $v0, $v0, 1               # Increment the value in $v0 by 1

                j getchar_loop                  # Jump to getchar_loop

handle_backspace:
                lw $t0, 0($sp)                  # Load the word at the address in $sp into $t0
                bne $a0, $t0, decrement         # If $a0 is not equal to $t0, jump to decrement_pointer
                j getchar_loop                  # Jump to getchar_loop

decrement:
                addiu $a0, $a0, -1              # Decrement the address in $a0 by 1
                j getchar_loop                  # Jump to getchar_loop

end_gets:
                beq $v0, $a1, skip_null         # If $v0 equals to $a1, jump to skip_null
                sb $zero, 0($a0)                # Store the byte in $zero to the address in $a0

skip_null:
                lw $a0, 0($sp)                  # Load the word at the address in $sp into $a0
                lw $a1, 4($sp)                  # Load the word at the address in $sp+4 into $a1
                lw $ra, 8($sp)                  # Load the word at the address in $sp+8 into $ra
                addiu $sp, $sp, 12              # Add 12 to the address in $sp

                jr $ra                          # Jump to the address in $ra


# Driver for printing 1 character to output
PUTCHAR:
                lui $t0, 0xffff                 # Base address of memory map
XReady:
                lw $t1, 8($t0)                  # Read from transmitter control reg
                andi $t1, $t1, 0x0001           # Extract ready bit
                beqz $t1, XReady                # If ready bit is 0, loop until it's 1
                sw $a0, 12($t0)                 # Send character to display
                jr $ra                          # Return to call location

# Function for printing a string to output from a buffer
PUTS:
                addiu $sp, $sp, -8              # Allocate space for 2 items on the stack
                sw $ra, 4($sp)                  # Push the parent's return address onto the stack
                sw $a0, 0($sp)                  # Push the string address onto the stack

putchar_loop:
                lb $a0, 0($a0)                  # Load the next byte from the string
                beq $a0, $zero, end_puts        # If the byte is null, jump to end_puts
                jal PUTCHAR                     # Call PUTCHAR function to print the byte

                lw $a0, 0($sp)                  # Load the string address from the stack
                addiu $a0, $a0, 1               # Increment the string address
                sw $a0, 0($sp)                  # Update the string address on the stack

                j putchar_loop                  # Jump to putchar_loop

end_puts:
                lw $a0, 0($sp)                  # Load the string address from the stack
                lw $ra, 4($sp)                  # Load the parent's return address from the stack
                addiu $sp, $sp, 8               # Deallocate the stack space

                jr $ra                          # Return to the parent function


