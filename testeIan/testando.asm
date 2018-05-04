.data
palavra: .asciiz "3w/"
buffer: .space 1
dctio: .space 60 

.text

#$t1 contains C
#the stack contains P
la $t0, palavra
la $t1, buffer
la $t2, dctio

addi $sp, $sp, -8
sw $0, 0($sp)
sw $0, 4($sp)


  counting_bytes:
  	addi $s0, $s0, 1	
  	lb $t1, ($t0)
  	addi $t0, $t0, 1
  	move $t2, $sp		
  	j dictionary
  	bne $t1, '\0', counting_bytes
  	j end
  	
dictionary:		
	addi $t3, $t3, 1
	lb $t4, 0($t2)
	beq  $t1, $t4, counting_bytes
	addi $t2, $t2, 8
	bne $t4, $0, dictionary
	addi $sp, $sp, 8
	sb $t1, 0($sp)
	sw $t3, 4($sp)
	j counting_bytes

end:
		
	
	
 	
