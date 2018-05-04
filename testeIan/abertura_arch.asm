        .data
#fout:   .asciiz "testein.txt"      # filename for output
fout: .space 20
buff: .space 200
        .text
  li      $v0, 8    # Defines syscall to read a string input
        la      $a0, fout
        li      $a1, 15   # Defines a max number of characters (bytes) in the input string. Used "dataX.txt" as standard (9 characters + null terminator)
        syscall
        move $t1, $a0
       	trat_quebra_linha:
      		lb $t0, ($t1)
       		addi $t1, $t1, 1
       		bne $t0, '\n', trat_quebra_linha
        	addi $t1, $t1, -1
        	li $t0, '\0'
        	sb $t0, ($t1) 
  ###############################################################
  # Open (for read) a file that exists
  li   $v0, 13       # system call for open file
  la   $a0, fout     # output file name
  li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 
  ###############################################################
  # Couting the number of characteres on the file
  move $t2, $s6

  counting_bytes:
  	addi $s0, $s0, 1	
  	lb $t1, ($t2)
  	addi $t2, $t2, 1
#  	addi $t0, $t0, 1		
#  	j present_dictionary
  	bne $t1, '\0', counting_bytes
  	j end
  		

  
  	  	  	
  ###############################################################
  # Read to file just opened
  li $v0, 14
  move $a0, $s6
  la $a1, buff
  li $a2, 150
  syscall
  
  ###############################################################
  # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  ###############################################################
  # Printing the file's string 
  #li $v0, 4
  #la $a0, buff
  #syscall
 
  
 #$t0 ponteiro do arquivo
#  la $t0, ($a0)

#  present_dictionary:
#  	lb $t1, 0($sp)
#  	la $t3, ($sp)
#  	beq $t2, $t1, yeap
#  	bne $t1, 0, present_dictionary
#  	j counting_bytes	
  
  
#  yeap:
#  	addi $sp, $sp, -8
#  	sb $t1, 0($sp)
#	j counting_bytes
  end:	
	  li $v0, 1
	  move $a0, $s0
	  syscall
	  
	  li $v0, 10
	  syscall
	  
#  move $t0, $a0
#  addi $sp, $sp, -4
#  la $t1, 0($sp)
#  li $t1, 0
#  compressing: 		
#  	while:
  	   
#	    while_2:  
#		beq $t1, $t0, present
#		addi $t1, $t1, -4
#	    	bnez $t1, while_2 
#	    	jal not_present	  
#	beq $t0, $0, continue
#	addi $t0, $t0, 4
#	bnez $t0, while
#  	present:
#	
#	not_present: 
#		
#	continue:
