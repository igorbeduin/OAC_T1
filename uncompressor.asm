.data
	startMessage:		.asciiz		"Hi!\nWelcome to LZW uncompressor.\nWhat file would you like to uncompress?\n>> "
	errorMessage:   	.asciiz     	"\n\nWARNING: Error while trying to open the file!\nClosing the application...\n"
	successMessage:		.asciiz		"\n\nSuccess in opening the file!\n"
	fileName:       	.space   	10 		# Reserve 10 bytes to filename be stored.
	uncmpssngMessage: 	.asciiz     	"\n\nStarting uncompression...\n\n"
	buffer:         	.space     	 4 		# Reserve 4 bytes (1 word) to be read from the file and stored in the buffer
	dictionary:		.word 
.text
    main:
        # Initialize registers
        li      $s0, 0 
        la	$s1, dictionary
        li	$s7, 0

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

    open_file:
        # Open file to be read
        li      $v0, 13   # Defines syscall to open a file
        la      $a0, fileName
        li      $a1, 0    # Set flag to 'reading' \ 0 for 'reading'; 1 for 'writing'
        li      $a2, 0    # Mode is ignored
        syscall           # Open the file (and save the descriptor in $v0)
        move    $s0, $v0  # Save the file descriptor in $s0
        
        blt 	$s0, 0, op_errorFinishing
        
        # Print success message
        la      $a0, successMessage
        li      $v0, 4
        syscall

        # Print that uncompression has started
        la      $a0, uncmpssngMessage
        li      $v0, 4
        syscall
        
        j       readFile

        
    Finish:
    	li	$v0, 10
    	syscall
    	
    op_errorFinishing:
        li      $v0, 4
        la      $a0, errorMessage
        syscall

	j	Finish
	
    readFile:
        li      $v0, 14
        move    $a0, $s0
        la      $a1, buffer
        li      $a2, 4
        syscall
        move	$a2, $zero
        
        # $a2 stores the index read
        lb   	$t2, 3($a1)	
        sll	$a2, $a2, 8
        add	$a2, $a2, $t2
        lb   	$t2, 2($a1)	
        sll	$a2, $a2, 8
        add	$a2, $a2, $t2
        lb   	$t2, 1($a1)	
        sll	$a2, $a2, 8
        add	$a2, $a2, $t2
        lb   	$t2, 0($a1)	
        sll	$a2, $a2, 8
        add	$a2, $a2, $t2
        
        move	$t1, $a2
        
        li      $v0, 14
        move    $a0, $s0
        la      $a1, buffer
        li      $a2, 4
        syscall
        
        move	$a2, $t1
        
        # $a3 stores the word read
        lb   	$t2, 3($a1)	
        sll	$a3, $a3, 8
        add	$a3, $a3, $t2
        lb   	$t2, 2($a1)	
        sll	$a3, $a3, 8
        add	$a3, $a3, $t2
        lb   	$t2, 1($a1)	
        sll	$a3, $a3, 8
        add	$a3, $a3, $t2
        lb   	$t2, 0($a1)	
        sll	$a3, $a3, 8
        add	$a3, $a3, $t2
        
        beq	$v0, 0, Finish
        
    searchDict:
    	
      
        seq	$t0, $a3, 0
        beq	$t0, 1, pushbackDict
        
    pushbackDict:
        sw	$a2, 0($s1)
        sw	$a3, 4($s1)
        add	$s7, $s7, 8
        j	readFile
