                    .data   
prompt_input:       .word input_str
output_given:       .word given_str
output_result:      .word result_str
output_question:    .word question_str

input_str:          .asciiz "\nPlease input an integer value greater than or equal to 0: "
given_str:          .asciiz "Your input: "
result_str:         .asciiz "\nThe factorial is: "
question_str:       .asciiz "\nWould you like to do this again (Y/N): "


          
                    .text
                    .globl main
main:               
                    la $t0, prompt_input                                                        # load address of prompt_input into $t0
                    lw $a0, 0($t0)                                                              # load the data at $t0 into $a0
                    li $v0, 4                                                                   # code for print string
                    syscall                                                                     # print prompt for user input

                    li $v0, 5                                                                   # code for read int
                    syscall                                                                     # read an int from user input
                    sw $v0, 0($sp)                                                               # save the input int in $s0

                    jal factorial                                                               # call factorial

                    move $t0, $v0                                                               # load final result into $t0

                    la $t1, output_given                                                        # load output_given address into $t1
                    lw $a0, 0($t1)                                                              # load output_given value into $a0
                    li $v0, 4                                                                   # code for print string
                    syscall                                                                     # print "Your input: " to screen

                    move $a0, $s0                                                               # load input integer into $a0
                    li $v0, 1                                                                   # code for print int
                    syscall                                                                     # print input integer to screen

                    la $t1, output_result                                                       # load output_result address into $t1
                    lw $a0, 0($t1)                                                              # load output_result value into $a0
                    li $v0, 4                                                                   # code for print string
                    syscall                                                                     # print "The factorial is: " to screen

                    move $a0, $t0                                                               # move final result from $t0 to arg register $a0
                    li $v0, 1                                                                   # code for print int
                    syscall                                                                     # print final result to screen

                    la $t1, output_question                                                     # load output_question address into $t1
                    lw $a0, 0($t1)                                                              # load output_question value into $a0
                    li $v0, 4                                                                   # code for print string
                    syscall                                                                     # ask if the user would like to go again

                    li $v0, 12                                                                  # read a single character from the user
                    syscall                                                                     # reads first character as soon as it is typed
                    beq $v0, 89, main                                                           # branch to top of main if the character is 'Y'

                    li $v0, 10                                                                  # code for exit
                    syscall                                                                     # exit the program


                    .text   
factorial:          
                    lw $s0, 0($sp)                                                              # load the argument passed by the parent
                    beqz $s0, base_case                                                         # branch to base_case when we decrement down to 

                    addi $s0, $s0, -1
                    addi $sp, $sp, -8                                                           # adjust the stack frame to hold 2 items
                    sw $s0, 0($sp)                                                           # decrement the argument passed by 1
                    sw $ra, 4(sp)
                    jal factorial                                                               # recursively call factorial on the decremented argument

                    addi $sp, $sp, 8                                                            # shift the stack frame to the parent's stack segment
                    lw $ra, 4($sp)                                                              # load the next parent's return address
                    lw $s0, 0($sp)                                                              # load the argument passed by the parent
                    

                    mul $v0, $s0, $v0                                                           # multiply child's return value by the argument passed
                    jr $ra                                                                      # return the product to the parent call
 
base_case:          
                    li $v0, 1                                                                   # set $v0 to return 1 on the base case
                    jr $ra                                                                      # return the base case to the parent call