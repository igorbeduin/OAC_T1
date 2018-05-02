.data
    startMessage:   .asciiz     "Hi!\nWelcome to LZW compressor.\nWhat file would you like to compress?\n>> "
    errorMessage:   .asciiz     "\n\nWARNING: Error while trying to open the file!\nClosing the application...\n"
    successMessage: .asciiz     "\n\nSuccess in opening the file\n!"
    fileName:       .space      11 # Reserve 10 bytes to filename be stored.
    cmpssngMessage: .asciiz     "\n\nCompression started..."
    buffer:         .space      4 # Reserve 4 bytes (1 word) to be read from the file and stored in the buffer
.text
    main:
        # Initialize registers
        li      $t1, 0
        li      $s6, 0    # Stores the number of bytes stored in the stack (size)
        li      $s7, 0

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
        move $t1, $a0
#       	trat_quebra_linha:
#      		lb $t0, ($t1)
#       		addi $t1, $t1, 1
#       		bne $t0, '\n', trat_quebra_linha
#        	addi $t1, $t1, -1
#        	li $t0, '\0'
#        	sb $t0, ($t1)      	

	open_file:
        # Open file
        li      $v0, 13   # Defines syscall to open a file
        la      $a0, fileName #$a0 has already the adress of 'fileName'
        li      $a1, 0    # Set flag to 'reading' \ 0 for 'reading'; 1 for 'writing'
        li      $a2, 0    # Mode is ignored
        syscall           # Open the file (and save the descriptor in $v0
        move    $s7, $v0  # Save the file descriptor in $s7

        blt     $s7, 0, op_errorFinishing

        # Print success message
        la      $a0, successMessage
        li      $v0, 4
        syscall

        # Print that compression has started
        la      $a0, cmpssngMessage
        li      $v0, 4
        syscall

        j       readingLoop

    Finish:
        # Close the file
        li      $v0, 16   # Defines syscall to close a file
        move    $a0, $s7  # Sets $a0 to file descriptor
        syscall

        li      $v0, 10   # Defines syscall to terminate the execution
        syscall

    op_errorFinishing:
        li      $v0, 4
        la      $a0, errorMessage
        syscall

        li      $v0, 10 # Defines syscall to terminate the execution
        syscall

    readingLoop:
        li      $v0, 14
        move    $a0, $s7
        la      $a1, buffer
        li      $a2, 4
        syscall
        move    $a3, $a1  # $a3 is the argument to be used inside the other functions with the buffer adress

        li    $t1, -4   # Instruction necessary so in "bne $t1, $s6, searchDict" $t1 has value 0 in the fisrt loop
        j       searchDict

        #bne    $v0, 0, readingLoop

        j       Finish

    searchDict:
        addi    $t1, $t1, 4

        add     $t3, $sp, $t1   # $t1 is the index of the stack
        seq     $t0, $a3, $t3
        beq     $t0, 1, storeIndex

        bne     $t1, $s6, searchDict
        li      $t1, 0
        j       pushbackDict

    pushbackDict:
        addi     $sp, $sp, -4
        sw       $a3, 0($sp)

    storeIndex:
        move    $s5, $t0        #$s5 stores the index of the stack (dict) that contains de word that I want
