.data
            .align 2
 homedbase: .space 5400
.text  
 main:
      li $t0, 0  # initialize $t0 to 0
      li $t1, 49 # end loop at 50 times
      li $t5, 4  # offset homedbase to the taxes
      li $s1, 108 # $s1 is set to the sturuct size for use in the multiply
                                               
     Repeat: 
             mult $s1,$t0               # multiply the index variable $t0 * structure size
             mflo $t4                     # making sure it doesnt take the bigger side of the binary mult
             add $t5, $t5,$t4            # locate each home struct's taxes = homebase[4+$t0*$s1]
             lw $t2, homedbase($t5)      # read homedbase[$t5] into $t2
             addi $t2,$t2, 500           # add 500 to each home 
             sw $t2, homedbase($t5)      # write the new value back
             addi $t0,$t0,1              # increment $t0 by 1
             bne $t0, $t1, Repeat        
                        
     Exit:
             addi $v0,$0, 10
             syscall