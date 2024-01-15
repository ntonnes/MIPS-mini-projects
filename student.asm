.data   
MAX_STUDENTS:   .word   5
students:       .space  100                             # For storing student records
newline:        .asciiz "\n"

.text   
main:           
    la      $a0,            students                    # Load the address of the student records array
    li      $a1,            MAX_STUDENTS                # Load the maximum number of students
    jal     sort_students                               # Call to sort student records

    # Exit the program
    li      $v0,            10                          # Exit system call
    syscall 

sort_students:  
    # $a0: address of the student records array
    # $a1: maximum number of students

    li      $t0,            0                           # Initialize loop counter (i)
outer_loop:     
    bge     $t0,            $a1,            exit_outer  # If i >= number of students, exit outer loop

    li      $t1,            0                           # Initialize inner loop counter (j)
inner_loop:     
    bge     $t1,            $a1,            exit_inner  # If j >= number of students, exit inner loop

    # Calculate the base address of the current and next student records
    mul     $t2,            $t0,            8           # Multiply i by size of each student record
    add     $t2,            $a0,            $t2         # Calculate base address of the current student record
    mul     $t3,            $t1,            8           # Multiply j by size of each student record
    add     $t3,            $a0,            $t3         # Calculate base address of the next student record

    lw      $t4,            4($t2)                      # Load the grade of the current student
    lw      $t5,            4($t3)                      # Load the grade of the next student

    ble     $t4,            $t5,            no_swap     # If grade of current student <= grade of next student, no swap needed

    # Swap the grades
    sw      $t4,            4($t3)                      # Store the grade of the current student in the next student
    sw      $t5,            4($t2)                      # Store the grade of the next student in the current student

no_swap:        
    addi    $t1,            $t1,            1           # Increment inner loop counter (j)
    j       inner_loop                                  # Jump back to the inner loop

exit_inner:     
    addi    $t0,            $t0,            1           # Increment outer loop counter (i)
    j       outer_loop                                  # Jump back to the outer loop

exit_outer:     
    jr      $ra                                         # Return from function
