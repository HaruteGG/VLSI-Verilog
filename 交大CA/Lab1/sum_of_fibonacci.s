.data
	input_msg:	.asciiz "Please input a number: "
	output_msg1:	.asciiz "The sum of Fibonacci(0) to Fibonacci("
	output_msg2:	.asciiz ") is: "
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
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure)
	move    $t7, $v0			# save input value in $t7 for later use

# jump to procedure 
	jal 	sum_of_fibonacci
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall

# print the input value from $t7(user input)
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t7			# move value of integer into $a0
	syscall 					# run the syscall

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure on the console interface
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

#------------------------- procedure  -----------------------------
# load argument n in $a0, return value in $v0. 
.text
sum_of_fibonacci:	
	addi 	$sp, $sp, -4		# adiust stack for 1 item
	sw 		$ra, 0($sp)         # save the return address    
	move    $s1, $a0			# $s1 is n
	move    $t0, $zero			# $t0 is int i
    move    $s2, $zero			# $s2 is sum of Fibonacci numbers
loop:	
	move    $a0, $t0
	jal 	fibonacci			# call fibonacci procedure
	addi    $t0, $t0, 1			# increment i
    add     $s2, $s2, $v0		# add fibonacci(i) to sum
	slt     $t1, $s1, $t0	 	# check if $s1 is less than 0
	beq     $t1, $zero, loop
	j       exit_sum_of_fib		# if i > n , exit loop
	
fibonacci:
	addi    $sp, $sp, -12		# adjust stack for 1 item
    sw      $s0, 8($sp)         # save s0 (fibonacci(n-1))
	sw      $a0, 4($sp)         # save the argument n (a0)
	sw      $ra, 0($sp)         # save the return address
	beq     $a0, $zero, L1		# check if n is 0
	move    $t2, $zero
	addi    $t2, $t2, 1         
	beq     $a0, $t2, L2		# check if n is 1
	addi    $a0, $a0, -1		# n = n - 1
	jal     fibonacci			# call fibonacci(n-1)
	move    $s0, $v0         # save fibonacci(n-1) in s0
	lw      $a0, 4($sp)		 # restore the argument n
	addi    $a0, $a0, -2		# n = n - 2
	jal     fibonacci			# call fibonacci(n-2)
	add     $v0, $s0, $v0         # return value is fibonacci(n-1) + fibonacci(n-2)
	j       exit_fib
L1: move    $v0, $zero         #return 0
	j       exit_fib
L2: move    $v0, $t2
	j       exit_fib
exit_fib:
	lw      $ra, 0($sp)         # restore the return address
    lw      $s0, 8($sp)         # restore s0
	addi    $sp, $sp, 12
	jr      $ra

exit_sum_of_fib:
	lw      $ra, 0($sp)         # restore the return address
	addi    $sp, $sp, 4        # adjust stack
    move    $v0, $s2          # return the sum of Fibonacci numbers
    jr      $ra                 # return to caller

	
	