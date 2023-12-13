.data
            #.align 2
 #homedbase: .space 5400
 prompt1:    .asciiz "Greetings! This is the number guessing game!\n"
 prompt2:    .asciiz "Player, please enter your guess: "
 TooLow:     .asciiz "Too low! \n"
 TooHigh:    .asciiz "Too high! \n"
 Success:    .asciiz "You got it! It took you this many tries: "
 Failure:       .asciiz "You lose! "

.text  
 main:
        li $t0, 56       # initialize the random number to be the imediate input
        li $t2, 1       # initialize our attempts counter
        li $t3, 11      # initialize the maximum number of tries (plus 1)

        li	$v0,4			# code for print_string
        la	$a0,prompt1
        syscall

        Loop:
                beq     $t2,$t3,Lose
                li	$v0,4			
                la	$a0,prompt2             # Ask user to guess
                syscall
                li	$v0,5			# code for read_int
	        syscall		                # get an int from user --> returned in $v0
	        move	$s0,$v0			# move the resulting int to $s0
                bne     $s0,$t0,Wrong
                j       Win                 # Guess was correct, begin cleanup

        Wrong:
                sub     $t1,$s0,$t0             # testing if the guess is greater or less than	
                bgtz    $t1,Greater
                li	$v0,4			# guess is less than if it reaches this point
                la	$a0,TooLow
                syscall
                addi    $t2,1                   # add 1 to the guesses
                j       Loop

        Greater:
                li      $v0,4
                la      $a0,TooHigh             # guess is too high
                syscall
                addi    $t2,1                   # add 1 to the guesses
                j       Loop

        Win:
                li      $v0,4
                la      $a0,Success             # game over, Success!
                syscall
                li	$v0,1			# code for print_int
	        move	$a0,$t2			# print out the number of guesses it took
	        syscall	
                j       Exit

        Lose:
                li      $v0,4
                la      $a0,Failure             # game over, Lose!
                syscall
                j       Exit
                
        Exit:     
                li	$v0,10                  # Exit code
                syscall	