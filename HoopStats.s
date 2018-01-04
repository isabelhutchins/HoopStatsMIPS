.align 2
.globl main

.data
nameprompt:	.asciiz "Please enter a name or DONE:"
numberprompt:	.asciiz "Please enter a jersey number:"
gradprompt:	.asciiz "Please enter a graduation year:"
done:	 .asciiz "DONE\n"
nl:         .asciiz     "\n"
space:	.asciiz " " 
.text

main:
	
	#create the first node, s0
	li $v0, 9 #allocates memory
	li $a0, 16 #because 2 ints, 1 pointer to a string, 1 pointer to a struct
	syscall
	move $s0, $v0 #s0 is the first struct

	#print the name prompt
	li $v0, 4
	la $a0, nameprompt #load address of prompt into the register
	syscall

	#allocate memory for user input
	li $v0, 9
	li $a0, 64
	syscall
	move $a0, $v0

	#get the user name input
	li $v0, 8
	li $a1, 64 
	syscall
	move $t0, $a0
	
	#$s2 will hold previous node address
	move $s2, $zero


loop:

	#initialize name part of struct
	sw $t0, 0($s0)

	#print the jersey number prompt
	li $v0, 4
	la $a0, numberprompt
	syscall

	#get the user jersey number  input
	li $v0, 5 #second input will be a jersey number
	syscall
	move $t0, $v0 #store the input

	#initialize jersey part of struct
	sw $t0, 4($s0)

	#print the graduation year  prompt
	li $v0, 4
	la $a0, gradprompt #load address of prompt into the register
	syscall

	#get the user grad year input
	li $v0, 5 #third input will be grad year
	syscall
	move $t0, $v0 #store the input

	#initialize grad year part of struct
	sw $t0, 8($s0)

	#will be used for sorting
	move $s4, $zero #sets pre pointer to null
	move $s3, $s1 #sets moving pointer to head
	
	#check if this is first node. if yes, set s1 as the head (permanently)
	bne $s2, $zero, sort #s2 will equal zero if this is the first node that's been created
	move $s1, $s0 #sets s1 as the head
	move $s3, $s1 #sets moving pointer to head

	#initialize first node's next pointer to null
	lw $zero, 12($s0)
	
	j continue #don't need to sort if this is the first node created

sort:
	
	beq $s3, $zero, biggest #checks to see if the moving pointer is at the end, in which case current node is biggest
	lw $t4, 8($s0) #t4 holds current node graduation year
	lw $t5, 8($s3) #t5 holds moving pointer node's graduation year

	lw $t2, 0($s0) #t2 holds current node last name
	lw $t3, 0($s3) #t3 holds moving pointer node's last name

	beq $t4, $t5, equal #if grad years are equal, sort by last name
	
	slt $t6, $t4, $t5 #t6 will equal 1 if t4 < t5 AKA current node is smaller than pointer node
	bne $t6, $0, insert #if t6 equals 1, need to insert current node right before pointer node
	move $s4, $s3 #move pre pointer up one #if current node is bigger than pointer, move pre pointer and main pointer
	lw $s3, 12($s3) #move main pointer up one
	j sort

equal:

	lb $s6, 0($t2) #gets first letter in current node last name
	lb $s5, 0($t3) #gets first letter in moving pointer node last name

	addi $t2, $t2, 1 #moves up one char in the string
	addi $t3, $t3, 1 #moves up one char in the string
	
	beq $s6, $s5, equal #if the letters are equal, loop again 
	
	slt $t6, $s6, $s5 #t6 will equal 1 if current node is less than pointer node
	bne $t6, $0, insert #if t6 equals 1, the node will be inserted before the pointer node
	
	move $s4, $s3 #move pre pointer up one
	lw $s3, 12($s3) #move main pointer up one
	
	j sort #if last names aren't equal and current isn't less than pointer node, move pointer and start over
	

insert:

	beq $s4, $zero, addBeg #if only one node, need to add current node to the beginning
	sw $s0, 12($s4) #load address of new node into smallest node's next field
	sw $s3, 12($s0) #load address of bigger node into new node's next field
	j continue

addBeg:
	
	sw $s3, 12($s0) #point new node's next field to s3
	move $s1, $s0 #reset head
	move $s3, $s1 #sets moving pointer to head
	j continue

biggest:

	sw $s0, 12($s4) #point last node in line's nextField to new node, which will now be at end
	sw $0, 12($s0) #point new node's next field to null
	
continue:	

	move $s2, $s0 #indicates there's more than 1 node
	
	#print the name prompt
	li $v0, 4
	la $a0, nameprompt #load address of prompt into the register
	syscall
 
	#allocate memory for user input
	li $v0, 9
	li $a0, 64
	syscall
	move $a0, $v0

	#get the user name input
	li $v0, 8
	li $a1, 64 
	syscall
	move $t0, $a0

	#create/allocate memory for the next new  node, s0
	li $v0, 9 #allocates memory
	li $a0, 16
	syscall
	move $s0, $v0

	#prepare for check input
	move $t2, $zero #makes sure t2 is empty
	move $t6, $zero #makes sure t6 is empty
	move $t3, $zero #makes sure t3 is empty
	move $t5, $t0 #load user input into $t5
	lb $t3, 0($t5) #get first letter of user input
	la $t2, done #holds DONE
	lb $t4, 0($t2) #gets first letter of DONE
	
checkInput:

	
	seq $t6, $t3, $t4 #t6 will equal 1 if the two bytes are equal to each other
	beq $t6, $zero, notDone #if they're not equal, continue prompting the user
	
	beq $t3, $zero, breakLoop #have hit the end of a string without breaking this loop, so end program
	beq $t4, $zero, breakLoop #same

	addi $t5, $t5, 1 #move up one in the string
	
	addi $t2, $t2, 1 #move up one in the string
	
	lb $t3, 0($t5) #get next letter
	lb $t4, 0($t2) #get next letter
	
	j checkInput
	
notDone:

	j loop

breakLoop:

	j printing
	
	
printing:

	beq $s1, $0, exit #breaks out of loop if node is null

nameLoop:

	la $t3, nl #gets new line
	lb $t2, 0($t3) #gets slash from new line
	addi $t3, $t3, 1
	lb $t6, 0($t3) #gets n from new line
	li $t5, 0
	lw $t5, 0($s1) #gets last name in current node
	
	lb $a0, 0($t5) #gets first char of name. parenthesis makes the word an address


loopChar:	
	beq $a0, $t2, conCheck #checks if first char = new line slash

slashInName:	
	#print the letter
	li $v0, 11
	syscall
	
	addi $t5, $t5, 1 #one char farther in the string
	
	lb $a0, 0($t5)
	j loopChar

conCheck:
	move $t7, $t5
	addi $t7, $t7, 1
	lb $a0, 0($t7) #gets next char in last name
	beq $a0, $t6, conPrint #if that char =n, break

	j slashInName #means not at end character, just a back slash in the last name
	
	
conPrint:

	#print space
	li $v0, 4
	la $a0, space
	syscall
	
	#print the JERSEY NUMBER
	li $v0, 1
	lw $a0, 4($s1)
	syscall
	
	lw $s1, 12($s1)	#go to next node

	beq $s1, $zero, printing

	#print new line
	li $v0, 4
	la $a0, nl
	syscall
	
	j  printing

exit:	
	jr $ra

	
