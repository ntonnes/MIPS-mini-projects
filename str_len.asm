.data   
my_string:  .asciiz "Hello, Assembly!"

.text   
main:       
    la      $t0,                my_string           # Point $t0 to the beginning of the string
    li      $t1,                0                   # Clear $t1 to store the length

calculate_length:
    lb      $t2,                0($t0)              # Load the current character into $t2
    beq     $t2,                $zero,      exit    # If null terminator is found, exit the loop
    addi    $t1,                $t1,        1       # Increment the length counter
    addi    $t0,                $t0,        1       # Move to the next character in the string
    j       calculate_length                        # Jump back to the loop

exit:       

    # Exit the program
    li      $v0,                10                  # Exit system call
    syscall 
