.data   
buffer:     .space  31                                          # buffer to store the input string (30 characters + null terminator)
int_buffer: .space  31                                          # buffer to store the input integer as string (30 characters + null terminator)

l_out:      .asciiz "Shifted string = ["
buffer2:    .space  31                                          # Buffer to store the shifted string
r_out:      .asciiz "]\n"

prompt1:    .asciiz "Input a string of 30 characters or less: "
prompt2:    .asciiz "Input an integer greater than 0: "

error1:     .asciiz "No input. Run again.\n"
error2:     .asciiz "Wrong input. Run again.\n"


.text   
            .globl  main

main:       

    # VALUE OF INPUT STRING --> buffer
    li      $v0,        4                                       # 4 = print string
    la      $a0,        prompt1                                 # arg0 = address pointed to by 'prompt1'
    syscall                                                     # print string starting at address 'prompt1'

    li      $v0,        8                                       # 8 = read string
    la      $a0,        buffer                                  # arg0 = address pointed to by 'buffer'
    li      $a1,        30                                      # arg1 = read up to 30 chars
    syscall                                                     # read 30 chars max from user input into address pointed to by 'buffer'

    lb      $t0,        0($a0)                                  # load first character of input string into $t0
    beq     $t0,        10,         err_empty_str               # if $t0 == '\n' then throw an error
    li      $t0,        0                                       # clear the memory at address $t0


    # VALUE OF INPUT INTEGER (AS STRING) --> int_buffer
    li      $v0,        4                                       # 4 = print string
    la      $a0,        prompt2                                 # arg0 = address pointed to by 'prompt2'
    syscall                                                     # print string starting at address 'prompt2'

    li      $v0,        8                                       # 8 = read string
    la      $a0,        int_buffer                              # arg0 = address pointed to by 'int_buffer'
    li      $a1,        30                                      # arg1 = read up to 30 chars
    syscall                                                     # read 30 chars max from user input into address pointed to by 'int_buffer'

    lb      $t0,        0($a0)                                  # load first character of input string into $t0
    ble     $t0,        48,         err_wrong_input             # if $t0 is not an ascii digit then throw an error
    li      $t0,        0                                       # clear the memory at address $t0


    # VALUE OF INPUT INTEGER (IN HEX) --> $s0
    li      $t0,        10                                      # assign $t0 a value of 10
    la      $t1,        int_buffer                              #load the address of 'int_buffer' into $t1
    li      $s0,        0                                       # clear the memory at address $s0
    jal     int_of_str                                          # convert string to int, store at $s0


    # INPUT STRING LENGTH (IN HEX) --> $s1
    la      $t0,        buffer                                  # load the address of pointed to by 'buffer' into $t0
    jal     count                                               # count the input string length, store at $s1


    # $s0 MODULO $s1 -> $s0
    div     $s0,        $s1                                     # divide the shift ($s0) by the string length ($s1)
    mfhi    $s0                                                 # store result in $s0


    # SHIFT INPUT STRING -> buffer2
    la      $t1,        buffer                                  # load the address of 'buffer' into $t1
    la      $t2,        buffer2                                 # load the address of 'buffer2' into $t2
    add     $t3,        $t1,        $s0                         # get the address of where printing should start using shift ($s0)
    jal     shift                                               # shift the input string, store at 'buffer2'


    # DISPLAY SHIFTED STRING
    li      $v0,        4                                       # 4 = print string
    la      $a0,        l_out                                   # arg0 = address pointed to by 'l_out'
    syscall                                                     # print string starting at address 'l_out'

    la      $a0,        buffer2                                 # arg0 = address pointed to by 'buffer2'
    syscall                                                     # print string starting at address 'buffer2'

    la      $a0,        r_out                                   # arg0 = address pointed to by 'r_out'
    syscall                                                     # print string starting at address 'r_out'


    # EXIT
    li      $v0,        10                                      # 10 = exit
    syscall                                                     # exit the program





    ##############################################################
    #     SHIFT INPUT INTEGER BY SPECIFIED AMOUNT -> buffer2     #
    ##############################################################
shift:      
    lb      $t4,        0($t3)                                  # load the next character at the shifted address into $t4
    beq     $t4,        10,         unshift                     # if at end of string, exit loop
    sb      $t4,        0($t2)                                  # store the character at the next spot in 'buffer2'

    addi    $t3,        $t3,        1                           # move shifted address to the next address in memory (next character)
    addi    $t2,        $t2,        1                           # move target address to the next address in memory
    j       shift                                               # loop

unshift:    

    beqz    $s0,        end_shift                               # if at end of string, exit loop
    lb      $t4,        0($t1)                                  # load the next character at the unshifted address into $t4
    sb      $t4,        0($t2)                                  # store the character at the next spot in 'buffer2'
    addi    $t1,        $t1,        1                           # move unshifted address to the next address in memory (next character)
    addi    $t2,        $t2,        1                           # move target address to the next address in memory
    subi    $s0,        $s0,        1                           # reduce accumulator by 1
    j       unshift                                             # loop

end_shift:  
    li      $t1,        0                                       # clear the memory at address $t1
    li      $t2,        0                                       # clear the memory at address $t2
    li      $t3,        0                                       # clear the memory at address $t3
    li      $t4,        0                                       # clear the memory at address $t4
    jr      $ra                                                 # return to main


    #################################################
    #     BUFFER STRING LENGTH (IN HEX) --> $s1     #
    #################################################
count:      
    lb      $t1,        0($t0)                                  # get the next character in the input string
    beq     $t1,        10,         end_count                   # if at end of string, exit loop
    addi    $s1,        $s1,        1                           # add 1 to the accumulator
    addi    $t0,        $t0,        1                           # move $t0 to the next address in memory (next character)
    j       count                                               # loop

end_count:  
    li      $t0,        0                                       # clear the memory at address $t0
    li      $t1,        0                                       # clear the memory at address $t1
    jr      $ra                                                 # return to main


    ###################################################
    #     VALUE OF INPUT INTEGER (IN HEX) --> $s0     #
    ###################################################
int_of_str: 
    lb      $t2,        0($t1)                                  # load the character at $t1 into $t2
    beq     $t2,        10,         end_int_of_str              # if at end of the string, exit loop

    mult    $s0,        $t0                                     # multiply the hex accumulator by 10 ($t0)
    mflo    $s0                                                 # move result to $s0
    sub     $t2,        $t2,        48                          # subtract 48 from ascii digit to convert to hex

    add     $s0,        $s0,        $t2                         # add the digit to the hex accumulator
    addi    $t1,        $t1,        1                           # move $t1 to the next address in memory (next character)

    j       int_of_str                                          # loop

end_int_of_str:
    li      $t0,        0                                       # clear the memory at address $t0
    li      $t1,        0                                       # clear the memory at address $t1
    li      $t2,        0                                       # clear the memory at address $t2
    jr      $ra                                                 # return to main


    ##################################
    #     SUBROUTINES FOR ERRORS     #
    ##################################
err_empty_str:

    li      $v0,        4                                       # 4 = print string
    la      $a0,        error1                                  # arg0 = address pointed to by 'error1'
    syscall                                                     # print string starting at address pointed to by 'error1'

    li      $v0,        10                                      # 10 = exit
    syscall                                                     # exit the program

err_wrong_input:

    li      $v0,        4                                       # 4 = print string
    la      $a0,        error2                                  # arg0 = address pointed to by 'error2'
    syscall                                                     # print string starting at address pointed to by 'error2'

    li      $v0,        10                                      # 10 = exit
    syscall                                                     # exit the program
