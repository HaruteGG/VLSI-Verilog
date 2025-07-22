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
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure)
	
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall  

	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1 (set arugument of procedure)

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
    # --- Procedure Prologue ---
    # Save callee-saved registers and the return address
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)      # Using s3 to save original modulus m0

    move $s3, $a1       # Save original modulus m: m0 ($s3) = m ($a1)

    # --- Initial Argument Checks ---
    # Check if modulus m <= 0
    slti $t0, $a1, 1    # if m < 1 (i.e., m <= 0), then $t0 = 1
    bne $t0, $zero, return_invalid

    # Check if a == 0
    beq $a0, $zero, check_a_is_zero

    # --- Normalize 'a' ---
    # Ensure 'a' is in the range [0, m-1]
    div $a0, $s3        # a / m0
    mfhi $a0            # a = a % m0
    slt $t0, $a0, $zero # if a < 0
    beq $t0, $zero, setup_loop
    add $a0, $a0, $s3   # a = a + m0

setup_loop:
    # --- Initialize Loop Variables ---
    li   $t5, 1         # s0 = 1
    li   $t6, 0         # s1 = 0
    move $s0, $a0       # cur_a = a
    move $s1, $s3       # cur_b = m0

    # --- Main Euclidean Algorithm Loop ---
loop:
    # Check for loop termination condition
    beq $s1, $zero, loop_exit

    # Perform division
    div $s0, $s1        # Signed division: cur_a / cur_b
    mflo $s2            # quotient = cur_a / cur_b
    mfhi $t3            # temp_r = cur_a % cur_b

    # Update remainders for next iteration
    move $s0, $s1       # cur_a = cur_b
    move $s1, $t3       # cur_b = temp_r

    # Update Bézout coefficients s
    mul $t8, $s2, $t6   # quotient * s1
    sub $t4, $t5, $t8   # temp_s = s0 - (quotient * s1)
    move $t5, $t6       # s0 = s1
    move $t6, $t4       # s1 = temp_s

    j loop              # Repeat the loop

loop_exit:
    # --- Check GCD ---
    # After the loop, $s0 contains the GCD(a, m)
    li $t0, 1
    bne $s0, $t0, return_invalid # If GCD is not 1, inverse does not exist.

    # --- Calculate Final Answer ---
    # The inverse is the final s0 coefficient, made positive.
    div $t5, $s3        # final_s0 % m0
    mfhi $v0            # $v0 = result
    slt $t0, $v0, $zero # if result < 0
    beq $t0, $zero, procedure_exit # If positive, we are done.
    add $v0, $v0, $s3   # If negative, add m0 to make it positive.
    j procedure_exit

check_a_is_zero:
    # Special case: if a is 0, inverse is 0 only if m is 1.
    li $t0, 1
    bne $a1, $t0, return_invalid
    li $v0, 0           # Set return value to 0
    j procedure_exit

return_invalid:
    # Set return value to -1 for all invalid cases
    li $v0, -1

    # --- Procedure Epilogue (Single Exit Point) ---
procedure_exit:
    # Restore registers from the stack
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra              # Return to caller