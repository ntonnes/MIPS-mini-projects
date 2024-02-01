.data   
input_prompt:       .asciiz "\nPlease input an integer value greater than or equal to 0: "
invalid_msg:        .asciiz "The value you entered is less than zero. This program only works with values greater than or equal to zero."
output_input:       .asciiz "Your input: "
output_factorial:   .asciiz "\nThe factorial is: "
prompt_again:       .asciiz "\nWould you like to do this again (Y/N): "


.text   
main:               
    # Prompt user for input
    li      $v0,            4
    la      $a0,            input_prompt
    syscall 

    # Read integer from user
    li      $v0,            5
    syscall 
    move    $t0,            $v0
    move    $s0,            $v0                                                                                                             # Store user input in $t0

    # If input is less than zero, throw error and exit
    bltz    $t0,            exit_program_invalid

    # Call factorial function
    li      $t1,            1
    jal     factorial

    # Print user input
    li      $v0,            4
    la      $a0,            output_input
    syscall 

    li      $v0,            1
    move    $a0,            $s0
    syscall 

    # Print factorial
    li      $v0,            4
    la      $a0,            output_factorial
    syscall 

    li      $v0,            1
    move    $a0,            $t1                                                                                                             # Use the return value from the factorial function
    syscall 

    # Prompt user to do it again
    li      $v0,            4
    la      $a0,            prompt_again
    syscall 

    # Read a single character from user
    li      $v0,            12
    syscall 
    move    $t1,            $v0

    # Check if the user wants to repeat
    beq     $t1,            89,                     main                                                                                    # ASCII code for 'Y'
    j       exit_program

factorial:          
    # $t0: input value - iteration number
    # result: the accumulator

    # Base case: if input is 0 or 1, return 1
    beqz    $t0,            end_factorial
    beq     $t0,            1,                      end_factorial

    mul     $t1,        $t0,                    $t1
    
        
    sub     $t0,            $t0,                    1
    j       factorial


end_factorial:      
    li      $t0,             0
    jr      $ra



exit_program_invalid:
    # Display error message and exit
    li      $v0,            4
    la      $a0,            invalid_msg
    syscall 

exit_program:       
    # Exit program
    li      $v0,            10
    syscall 
