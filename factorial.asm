                    .globl  main
.data   
prompt_input:       .word   input_str
output_given:       .word   given_str
output_result:      .word   result_str
output_question:    .word   question_str

input_str:          .asciiz "\nPlease input an integer value greater than or equal to 0: "
given_str:          .asciiz "Your input: "
result_str:         .asciiz "\nThe factorial is: "
question_str:       .asciiz "\nWould you like to do this again (Y/N): "


.text   
main:               
    la      $t0,        prompt_input                                                        # load address of prompt_input into %t0
    lw      $a0,        0($t0)                                                              # load the data at $t0 into $a0
    li      $v0,        4                                                                   # code for print string
    syscall                                                                                 # print prompt for user input

    li      $v0,        5                                                                   # code for read int
    syscall                                                                                 # read an int from user input
    move    $t0,        $v0                                                                 # store the input int in $t0

    move    $a0,        $t0                                                                 # move input to arg register $a0
    addi    $sp,        $sp,                -12                                             # adjust the stack frame for 3 words
    sw      $t0,        0($sp)                                                              # push input int to the top of stack
    sw      $ra,        8($sp)                                                              # save return address at the bottom of stack 
    jal     factorial                                                                       # go to factorial [reserve 4($sp) for result]


    lw      $s0,        4($sp)                                                              # load final result into $s0

    la      $t1,        output_given                                                        # load output_given address into $t1
    lw      $a0,        0($t1)                                                              # load output_given value into $a0
    li      $v0,        4                                                                   # code for print string
    syscall                                                                                 # print "Your input: " to screen

    lw      $a0,        0($sp)                                                              # load input integer into $a0
    li      $v0,        1                                                                   # code for print int
    syscall                                                                                 # print input integer to screen

    la      $t1,        output_result                                                       #load output_result address into $t1
    lw      $a0,        0($t1)                                                              # load output_result value into $a0
    li      $v0,        4                                                                   # code for print string
    syscall                                                                                 # print "The factorial is: " to screen

    move    $a0,        $s0                                                                 # move final result from $s0 to arg register $a0
    li      $v0,        1                                                                   # code for print int
    syscall                                                                                 # print final result to screen

    addi    $sp,        $sp,                12                                              # move stack pointer to starting address

    # Step 5

    la      $t1,        output_question                                                     # load output_question address into $t1
    lw      $a0,        0($t1)                                                              # load output_question value into $a0
    li      $v0,        4                                                                   # code for print string
    syscall                                                                                 # ask if the user would like to go again
    li      $v0,        12                                                                  # read a single character from the user
    syscall                                                                                 # reads first character as soon as it is typed
    beq     $v0,        89,                 reset                                           # branch to reset if the character is 'Y'

    li      $v0,        10                                                                  # code for exit
    syscall                                                                                 # exit the program

.text   
reset:              
    j       main                                                                            # return to the top of the main function

.text   
factorial:          
    lw      $t0,        0($sp)                                                              # load input from top of stack into register $t0
    beq     $t0,        0,                  base_case                                       # if $t0 is equal to 0, branch to base_case
    addi    $t0,        $t0,                -1                                              # subtract 1 from $t0 if not equal to 0

    addi    $sp,        $sp,                -12                                             # adjust the stack frame for 3 words
    sw      $t0,        0($sp)                                                              # store current result at the top of stack segment
    sw      $ra,        8($sp)                                                              # store return address at the bottom of stack segment

    jal     factorial                                                                       # recursive call

    lw      $ra,        8($sp)                                                              # load this call's return address
    lw      $t1,        4($sp)                                                              # load child's return value into $t1
    lw      $t2,        12($sp)                                                             # load parent's working result into $t2

    mul     $t3,        $t1,                $t2                                             # multiply child's return value by parent's working value & store in $t3
    sw      $t3,        16($sp)                                                             # move the result into parent's return value

    addi    $sp,        $sp,                12                                              # move stack pointer to the parent call

    jr      $ra                                                                             # jump to parent call

.text   
base_case:          
    li      $t0,        1                                                                   # load immediate 1 into register $t0
    sw      $t0,        4($sp)                                                              # store 1 in parent stack return value
    jr      $ra                                                                             # jump to parent call
