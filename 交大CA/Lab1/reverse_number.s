.data
	input_msg:	.asciiz "Enter a number: "
	output_msg:	.asciiz "Reversed number is "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure reverse_number)

# jump to procedure reverse_number
	jal 	reverse_number
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure reverse_number on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t0			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure reverse_number -----------------------------
# load argument n in $a0, return value in $v0. 
.text
reverse_number:	
	addi 	$sp, $sp, -4		# adiust stack for 1 item
	sw 		$ra, 0($sp)         # save the return address    
	move    $s0, $zero			# $s0 is int reversednum
	move    $t1, $zero
	addi    $t1, $zero, 10		# $t1 is int 10 for modulus operation   
L1:
	slt     $t0, $zero, $a0     # check if $a0 is greater than 0
	beq     $t0, $zero, exit_reverse_number	
	div     $a0, $t1		    # divide $a0 by 10
	mfhi    $t2			        # get the remainder to int d($t2)
	mflo    $a0                 # n = n / 10
	mul     $s0, $s0, $t1       # reversednum = reversednum * 10
	add     $s0, $s0, $t2       # finish reversednum = reversednum * 10 + d
	j       L1
exit_reverse_number:
	addi     $v0, $s0, 0
	lw       $ra, 0($sp)
	addi     $sp, $sp, 4
	jr       $ra