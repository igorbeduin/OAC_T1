.data
	startMessage:	.asciiz		"Hi!\nWelcome to LZW compressor.\nWhat file would you like to compress?\n>> "
	errorMessage:	.asciiz 	"\n\nWARNING: Error while trying to open the file!\nClosing the application...\n"
	successMessage:	.asciiz 	"Success in opening the file!"
	fileName:	.space		10 # Reserve 10 bytes to filename be stored. 
.text
	main:
		# Print the starting message
		la	$a0, startMessage 
		li	$v0, 4 # Defines syscall to print a string
		syscall	
		
		# Read the file name string to be read
		li	$v0, 8 # Defines syscall to read a string input
		la	$a0, fileName
		li	$a1, 10 # Defines a max number of characters (bytes) in the input string. Used "dataX.txt" as standard (9 characters + null terminator)
		syscall
		
		# Open file
		li	$v0, 13 # Defines syscall to open a file
		la	$a0, fileName #$a0 has already the adress of 'fileName'
		li	$a1, 0 # Set flag to 'reading' \ 0 for 'reading'; 1 for 'writing'
		li	$a2, 0 # Mode is ignored
		syscall # Open the file (and save the descriptor in $v0
		move $s7, $v0 # Save the file descriptor in $s7
		
		blt $s7, 0, op_errorFinishing
		
		# Print success message
		li	$v0, 4
		la	$a0, successMessage
		syscall
		
		
		# Close the file
		li	$v0, 16 # Defines syscall to close a file
		move	$a0, $s7 # Sets $a0 to file descriptor
		syscall
		
	op_errorFinishing:
		li 	$v0, 4
		la 	$a0, errorMessage
		syscall
		
		li 	$v0, 10 # # Defines syscall to terminate the execution
		syscall 
	
	
	
	
	
