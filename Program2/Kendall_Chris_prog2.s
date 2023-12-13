# 3760
# Program 2 Test Harness

#-------------------------------------------------------------------------
# PLACE YOUR FUNCTION HERE
#-------------------------------------------------------------------------
.text
convert_hex_str:
li $v0,0
li $v1,0
li $t0,0            # initializing counter
li $t1,57           # value to compare for ASCII 1-9
li $t2,70           # value to compare for ASCII a-f
move $t5,$a0        # storing the value of $a0 in $t5
li $t6,8            # maximum nubmber of bytes
lui $t7,2047
ori $t7,$t7,0xFFFF  # set $t7 to the max a 31 bit register can hold

loop:
addi    $t0,$t0,1       # incrimenting counter
lbu     $t3,0($t5)      # loads byte from $t5

beq     $t3,$0,done     # check for NUL terminator
beq     $t0,$t6,Check_overflow      # Send to make sure overflow is not going to occur if counter reaches 8
sub     $t4,$t3,$t1

bgtz    $t4,upper       # testing if the value is 1-9
sll     $v0,$v0,4       # shifting bits left by 4
addi    $t4,$t4,9       # converting ASCII to decimal
add     $v0,$v0,$t4     # adding the value to hex_value

addi    $t5,$t5,1       # increment pointer
j       loop

upper:
sub     $t4,$t3,$t2
bgtz    $t4,lower
addi    $t4,$t4,15      # converting ASCII to decimal
sll     $v0,$v0,4       # shifting bits left by 4
add     $v0,$v0,$t4     # adding the value to hex_value
addi    $t5,$t5,1       # increment pointer
j       loop

lower:
addi    $t4,$t4,-17
sll     $v0,$v0,4       # shifting bits left by 4
add     $v0,$v0,$t4     # adding the value to hex_value
addi    $t5,$t5,1       # increment pointer
j       loop

Check_overflow:
sub     $t7,$t7,$v0     
bltz    $t7,doneE       # overflow will occur
j       loop

doneE:
addi    $v1,$v1,1       # set $v1 to "1" error status
jr      $ra             # return to $ra

done:
jr      $ra             # return to $ra


#-------------------------------------------------------------------------
# DO NOT MODIFY BELOW THIS COMMENT
#-------------------------------------------------------------------------

# Test harness
# Ask user to enter the hex string.
# Print the resulting integer, or report overflow.
# An empty string will terminate the program.

.data

# User prompt strings
prompt_str:     .asciiz "Enter your hexadecimal string.  Just hit enter to quit: "
your_str:       .asciiz "Your string: "
linefeed:       .asciiz "\n"
dbl_linefeed:   .asciiz "\n\n"
value_str:      .asciiz "Value : "
overflow_str:   .asciiz "Overflow detected!\n\n"
all_done_str:   .asciiz "\nGood luck with your program!.  Goodbye.\n"
hex_str_buf:  # Space for input string from user.
.space 256

.text
.globl main
.globl convert_hex_str

main: 

get_input_string:

# display prompt
    li $v0,4            # code for print_string
    la $a0,prompt_str   # point $a0 to prompt string
    syscall             # print the string


# get the input string from the user
    li $v0,8            # code for read_string
    la $a0,hex_str_buf  # $a0 - input buffer address
    li $a1,256          # $a1 - Input buffer length
    
    syscall                # Get the string
                        # The string is NUL terminated.
    la $s0,hex_str_buf  # Save string in $s0
    
    # SPIM puts a closing NEW LINE (ASCII 0xa) on the end of the string.
    #  We need to strip that off, since that is not a legal character in our hex format.
    #  We just overwrite it with NUL (ASCII 0)

    move $s1, $s0     # $s1 char pointer
    
strip_nl:
    lbu $s2, ($s1)    # $s2 Get the current character
    beqz $s2, remove_nl
    addi $s1, $s1, 1  # Next character
    j strip_nl
    
remove_nl:
    li $s2, 10       # Expected NL = ASCII 10 (0xa)
    lbu $s3, -1($s1) # Character just before the NUL terminator
    bne $s3, $s2, check_for_exit

    li $s2, 0        # NUL Char (0)
    sb $s2, -1($s1)  # Wipe out NL

check_for_exit:
    # Check if the input string is empty.
    lbu $s2, ($s0)         # Load first byte of the string.
    beq $s2, $0, all_done  # Exit if first byte is NUL terminator
    
# print result string
# - Prompt string
    li    $v0,4            # code for print_string
    la $a0, your_str
    syscall                # print the string

# - The string
    li    $v0,4            # code for print_string
    move $a0, $s0
    syscall                # print the string

# - LF    
    li    $v0,4            # code for print_string
    la    $a0,linefeed     # point $a0 to string
    syscall                # print the string
    
# Call Hex Converter
    move $a0, $s0
    jal convert_hex_str

    move $s1, $v0         # Save value result in $s0
    move $s2, $v1         # Save error result in $s1
    
    beq $v1, $0, no_overflow

# - Overflow detected

    # Print overflow message
    li    $v0,4
    la $a0, overflow_str
    syscall                # print the string

    j get_input_string     # Repeat
    
# - Value
no_overflow:
    # Print value message.
    li    $v0,4            # code for print_string
    la $a0, value_str
    syscall                # print value prompt

    li    $v0,1            # code for print_int
    move $a0, $s1
    syscall                # print the value itself.

    li    $v0,4            
    la    $a0,dbl_linefeed
    syscall                # print the linefeed

    j get_input_string     # Repeat
    
# - Prompt string
#    li    $v0,4            # code for print_string
#    la $a0, error_str
#    syscall                # print the string
    
# All done, thank you!
all_done:    
    li    $v0,4            # code for print_string
    la $a0, all_done_str
    syscall                # print the string
    
    li    $v0,10           # code for exit
    syscall                # exit program
