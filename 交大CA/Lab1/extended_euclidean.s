.data
	input_msg1:	.asciiz "Enter the number: "
	input_msg2: .asciiz "Enter the modulo: "
	output_msg1: .asciiz "Inverse not exis."
	output_msg2: .asciiz "Result: "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t0, $v0      		# stor input in t0 for restore
	
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall  

	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1 (set arugument of procedure)
    move    $a0, $t0            # restore input in $a0 (set arugument of procedure)

# jump to procedure 
	jal 	extended_euclidean
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

	slt $t1, $t0, $zero
	bne $t1, $zero, out

# print output_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall
# print the result of procedure on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t0			# move value of integer into $a0
	syscall                 	# run the syscall
    j exit_main
out:
# print output_msg1 on the console interface
    li      $v0, 4				# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                     # run the syscall
exit_main:
# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall




#------------------------- procedure  -----------------------------
# load argument a in $a0, b in $a1, return value in $v0. 
.text
extended_euclidean:	
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    slt $t1, $zero, $a1
    beq $t1, $zero, return_minus1_or_0 # if b <= 0, return -1
    beq $a0, $zero, return_minus1_or_0 # if a == 0
    div $a0, $a1 
    mfhi $a0  # a0 %= m0
    slt $t1, $a0, $zero
    beq $t1, $zero, next2
    add $a0, $a0, $a1 # if a < 0, a += m0
next2:
    move $t5, $zero
    addi $t5, $t5, 1 #$t5 as s0 = 1
    move $t6, $zero #$t6 as s1 = 0
    move $s0, $a0 # $s0 as cur_a = a
    move $s1, $a1 # $s1 as cur_b = b
loop:
    move $s2, $zero # $s2 as quotient
    div $s0, $s1
    mflo $s2 # s2 = quotient
    mfhi $t3 # $t3 as temp_r = cur_a % cur_b
    move $s0, $s1 # cur_a = cur_b
    move $s1, $t3 # cur_b = temp_r
    move $t4, $zero # $t4 as temp_s
    mul $t8, $s2, $t6 # t8 = quotient * s1
    sub $t4, $t5, $t8 # temp_s = s0 - (quotient * s1)
    move $t5, $t6 # s0 = s1
    move $t6, $t4 # s1 = temp_s
    bne $s1, $zero, loop # if cur_b != 0, continue loop
    
    li $t9, 1
    beq $s0, $t9, return_answer
    j return_a_not_1 # if cur_a != 1, return -1
return_answer:
    div $t5, $a1
    mfhi $t9 # t9 = s0 % m0
    add $t9, $t9, $a1
    div $t9, $a1
    mfhi $t9 # t9 = (s0 % m0 + m0) % m0
    move $v0, $t9
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
return_a_not_1:
    li $v0, -1 # return -1 if cur_a != 1
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
return_minus1_or_0:
    li $t2, 1
    beq $a1, $t2, end_if
    li $v0, -1 # return -1 if b <= 0
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
end_if:
    move $v0, $zero
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra