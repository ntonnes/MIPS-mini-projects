.data   
n:  .word   10

.text   
main:
    lw      $t3,    n                       # Load n (number of terms) into $t3
    li      $t0,    0                       # Initialize first Fibonacci number
    li      $t1,    1                       # Initialize second Fibonacci number

generate_fibonacci:

    add     $t2,    $t0,                $t1 # Calculate the next Fibonacci number
    move    $t0,    $t1                     # Move the second number to the first
    move    $t1,    $t2                     # Move the calculated number to the second
    sub     $t3,    $t3,                1   # Decrement the loop counter
    bnez    $t3,    generate_fibonacci      # Branch if the loop counter is not zero

    # Exit the program
    li      $v0,    10                      # Exit system call
    syscall 
