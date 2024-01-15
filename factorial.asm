.data   
number: .word   5

.text   
main:   
    lw      $t0,                    number          # Load the number into $t0
    li      $t1,                    1               # Initialize counter for factorial
    li      $t2,                    1               # Initialize result (factorial) to 1

calculate_factorial:
    bge     $t1,                    $t0,    exit    # If counter >= number, jump to 'exit'

    mul     $t2,                    $t2,    $t1     # Multiply result by counter
    addi    $t1,                    $t1,    1       # Increment counter
    j       calculate_factorial                     # Jump back to the loop

exit:   

    # Exit the program
    li      $v0,                    10              # Exit system call
    syscall 
