.data
    startMessage:   .asciiz     "Hi!\nWelcome to LZW compressor.\nWhat file would you like to compress?\n>> "
    errorMessage:   .asciiz     "\n\nWARNING: Error while trying to open the file!\nClosing the application...\n"
    successMessage: .asciiz     "\n\nSuccess in opening the file!\n"
    readingMessage: .asciiz 	"\n\nReading file...\n" 
    fileName:       .space      10 # Reserve 10 bytes to filename be stored.
    cmpssngMessage: .asciiz     "\n\nCompression started...\n\n"
    buffer:         .space      4 # Reserve 4 bytes (1 word) to be read from the file and stored in the buffer
    dataArray:	    
.text
    main:
        # Initialize registers
        li      $t1, 0
        li	$t9, 0
        li	$s5, 0
        li      $s6, 0    # Stores the space reserved in the stack (size)
        li      $s7, 0
        move	$s4, $sp

        # Print the starting message
        la      $a0, startMessage
        li      $v0, 4    # Defines syscall to print a string
        syscall
	
    read_nameFile:
        # Read the file name string to be read
        li      $v0, 8    # Defines syscall to read a string input
        la      $a0, fileName
        li      $a1, 10   # Defines a max number of characters (bytes) in the input string. Used "dataX.txt" as standard (9 characters + null terminator)
        syscall
        move 	$t1, $a0      	

    open_file:
        # Open file
        li      $v0, 13   # Defines syscall to open a file
        la      $a0, fileName #$a0 has already the adress of 'fileName'
        li      $a1, 0    # Set flag to 'reading' \ 0 for 'reading'; 1 for 'writing'
        li      $a2, 0    # Mode is ignored
        syscall           # Open the file (and save the descriptor in $v0)
        move    $s7, $v0  # Save the file descriptor in $s7

        blt     $s7, 0, op_errorFinishing

        # Print success message
        la      $a0, successMessage
        li      $v0, 4
        syscall
        
        # Print that reading file has started
        la	$a0, readingMessage
        li	$v0, 4
        syscall
     	
     	j       readFile

        # Print that compression has started
        la      $a0, cmpssngMessage
        li      $v0, 4
        syscall

    Finish:
        # Close the file
        li      $v0, 16   # Defines syscall to close a file
        move    $a0, $s7  # Sets $a0 to file descriptor
        syscall
        
        li	$t1, 0
        #jal 	printDict

        li      $v0, 10   # Defines syscall to terminate the execution
        syscall

    op_errorFinishing:
        li      $v0, 4
        la      $a0, errorMessage
        syscall

	j	Finish

    readFile:
        li      $v0, 14
        move    $a0, $s7
        la      $a1, buffer
        li      $a2, 1
        syscall
        lb   	$a3, 0($a1)		# $a3 is the argument to be used inside the other functions with the buffer adress
        #li	$s5, 0
        
        beq	$t9, 1, pushbackDict
     
    CallSearcher:   
        li	$t1, 4
        
        bne     $v0, 0, searchDict
        
        j 	Finish
        
   

    searchDict:
        addi    $t1, $t1, -4

        add     $t3, $s4, $t1  # $t1 is the index of the stack
        #lb	$t5, -4($t3)
        lb	$t4, 0($t3)
        
        #seq     $t0, $a3, $t4
        #seq 	$t6, $t0, 1
        #seq	$t7, $s5, $t5
        
        #beq     $t7, $t6, storeIndex

        bne     $t1, $s6, searchDict
        li      $t1, 0
        move	$s5, $zero
        j       pushbackDict

    pushbackDict:
        addi     $sp, $sp, -8
        sw	 $s5, 0($sp)
        sw	 $a3, 4($sp)
        
        li	$t9, 0
        
        addi 	 $s6, $s6, -8	# Increse the stack size counter register 
        j readFile

    storeIndex:
        sub	$s5, $zero, $t1      #$s5 stores the index of the stack (dict) that contains de word that I want
        li	$t9, 1
        j	readFile
        
	
    printDict:
    	# Print index
    	la	$t2, 4($sp)
    	li	$v0, 1
    	move	$a0, $t2
    	syscall
    	
    	# Print word
    	#la	$t2, 0($sp)
    	#li	$v0, 4
    	#move	$a0, $t2
    	#syscall
    	
    	addi	$sp, $sp, 8
    	addi	$t1, $t1, 8

    	bne	$t1, $s6, printDict
    	
    	jr 	$ra
    	
	
