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
                .globl main
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


# DRIVER: PUTCHAR
GETCHAR:
                lui $a3, 0xffff                 # Base address of memory map
CkReady:
                lw $t1, 0($a3)                  # Read from receiver control reg
                andi $t1, $t1, 0x0001           # Extract ready bit
                beqz $t1, CkReady               # If 1, then load char, else loop
                lw $v0, 4($a3)                  # Load character from keyboard
                jr $ra                          # Return to gets_loop

# FUNCTION: GETS
GETS:
                addi $sp, $sp, -16              # Allocate space for 4 items on the stack

                sw $ra, 12($sp)                 # Push the parent's return address onto the stack
                sw $a1, 8($sp)                  # Push the buffer limit onto the stack 
                sw $a0, 4($sp)                  # Push the buffer address onto the stack
                sw $zero, 0($sp)                # Initialize the number of characters read to $zero

getchar_loop:
                
                lw $t0, 4($sp)                  # Load the buffer address from the stack into $t0
                lw $t1, 8($sp)                  # Load the buffer limit from the stack into $t1
                lw $t2, 0($sp)                  # Load the number of characters read from the stack into $t2

                beq $t1, $t2, end_gets          # If the buffer is full, jump to end_gets

                jal GETCHAR                     # Call GETCHAR function to get a character from input

                li $t3, 10
                beq $v0, $t3, end_gets          # If the character is a newline, jump to end_gets

                li $t3, 8                       # ASCII value for backspace
                beq $v0, $t3, handle_backspace  # If the character is a backspace, jump to handle_backspace
                li $t3, 127                     # ASCII value for delete
                beq $v0, $t3, handle_backspace  # If the character is a delete, jump to handle_backspace

                sb $v0, 0($t0)                  # Otherwise store the character in the buffer 

                addiu $t0, $t0, 1               # Increment the buffer address
                addiu $t2, $t2, 1               # Increment the number of characters read
                sw $t0, 4($sp)                  # Update the buffer address on the stack
                sw $t2, 0($sp)                  # Update the number of characters read on the stack
          

                j getchar_loop                  # Jump to getchar_loop

handle_backspace:
                lw $t3, 4($sp)                  # Load the buffer address from the stack into $t3
                beqz $t3, getchar_loop          # If the buffer is empty, branch to getchar_loop
                addiu $t0, $t0, -1              # Decrement the buffer address
                addiu $t2, $t2, -1              # Decrement the number of characters read
                sw $t0, 4($sp)                  # Update the buffer address on the stack
                sw $t2, 0($sp)                  # Update the number of characters read on the stack
                j getchar_loop                  # Jump to getchar_loop

end_gets:
                bne $t2, $t1, add_null         # If the buffer is not full, add null character
                lw $v0, 0($sp)                  # Load the number of characters read from the stack
                lw $ra, 12($sp)                 # Load the parent's return address from the stack
                jr $ra                          # Return to the parent function

add_null:
                sb $zero, 0($t0)
                

# DRIVER: PUTCHAR 
PUTCHAR:
                lui $t0, 0xffff                 # Base address of memory map
XReady:
                lw $t1, 8($t0)                  # Read from transmitter control reg
                andi $t1, $t1, 0x0001           # Extract ready bit
                beqz $t1, XReady                # If ready bit is 0, loop until it's 1
                sw $a0, 12($t0)                 # Send character to display
                jr $ra                          # Return to call location

# FUNCTION: PUTS
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


