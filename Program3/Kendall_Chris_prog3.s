.data
# Set up constants for the array and array size
Xarray: .word 15, 5, -3, 8, 5, 1
Xsize: .word 6
Swap: .asciiz "Swap\n"
Space: .asciiz ", "
Line: .asciiz "\n"

.text
main:
        # Set up registers to hold the array and array size
        la $a1, Xarray
        addi $t2,$a1,0      # extra temp register holding address of array for simplicity later
        la $a2, Xsize

        # Load array size into a register
        lw $t1, 0($a2)

        # Main loop
        li $t3, 0   # Initialize counter for number of passes
        li $t4, 0   # Initialize flag for whether a swap occurred
        loop:
            jal printArray
            li $t5, 0   # Initialize flag for whether a swap occurred during this pass
            li $t6, 1   # Initialize counter for array traversal
            
            # Loop through array
            inner_loop:
                lw $t7, 0($a1)
                lw $t8, 4($a1)
                
                # Compare adjacent elements
                jal compare
                beq $v1, $0, no_swap     # If no swap needed, skip swap
                
                # Swap elements
                jal swap
                addi $t5, $t5, 1               # Set swap flag to indicate swap occurred
                
                no_swap:
                addi $a1, $a1, 4    # Increment array pointer by 4 (one word)
                addi $t6, $t6, 1        # Increment array traversal counter
                bne $t6, $t1, inner_loop    # Check if end of array has been reached

            # Set address back to the start of the array
            li $t9, 4
            addi $t0, $t6, -1
            mult $t0, $t9
            mflo $t9
            sub $a1, $a1, $t9       
                
            addi $t3, $t3, 1        # Increment pass counter
            beq $t5, $0, done    # If no swaps occurred during this pass, exit
            
            addi $t1, $t1, -1        # Decrement array size by 1
            j loop                  # Continue with next pass

        done:
            li	$v0,10                  # Exit code
            syscall

        # Comparison subroutine
        # Returns 1 if first element is greater than second element, 0 otherwise
        compare:
            sw $ra, -4($sp)         # Save return address on stack
            slt $v1, $t8, $t7       # Compare elements
            lw $ra, -4($sp)         # Restore return address from stack
            jr $ra                  # Return from subroutine

        # Swap subroutine
        # Does not return anything
        swap:
            sw $ra, -4($sp)     # Save return address on stack
            addi $t0, $t7, 0    # Copy value of first element to a temporary register
            sw $t8, 0($a1)      # Store second element into first element's location
            sw $t0, 4($a1)      # Store first element into second element's location
            lw $ra, -4($sp)     # Restore return address from stack
            jr $ra              # Return from subroutine

        printArray:
            sw $ra, -4($sp)     # Save return address on stack
            lw $t0, 0($a2)      # load the array size into temp
            li $t8, 0           # inititalize iteration counter to 0
            iterate:
            li $t7,0            # clear register, was giving me issues when I didn't
            lw $t7, 0($t2)      # Load first element into a register
            li	$v0, 1			# code for print_int
	        move	$a0, $t7
            syscall
            li	$v0, 4			# code for print_string
	        la	$a0, Space		# point $a0 to prompt string
	        syscall				# print the prompt
            
            addi $t2, $t2, 4        # increment array memory pointer by 1 word
            addi $t8, $t8, 1        # increment iteration counter
            beq $t8, $t0, set       # check if iterations = array size. If not iterate again. 
            j iterate

            set:
                li	$v0, 4			# code for print_string
	            la	$a0, Line		# point $a0 to prompt string
	            syscall				# print the prompt

                # Set address back to the start of the array
                li $t9, 4
                mult $8, $t9
                mflo $t9
                sub $t2, $t2, $t9       

                lw $ra, -4($sp)     # Restore return address from stack
                jr $ra          # Return from subroutine

            

            