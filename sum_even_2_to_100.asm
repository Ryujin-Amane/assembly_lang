# ==============================================================================
# Program:  sum_even_2_to_100.asm
# Purpose:  1. Prompt user to press/enter 2, 4, 6, or 8.
#           2. Validate that the entered key is one of {2, 4, 6, 8}.
#           3. Use a loop entering/iterating values from 1 to 100.
#           4. Accumulate the sum of all even numbers (2, 4, 6, ..., 100).
#           5. Display the calculated sum (Result = 2550).
# Platform: MIPS Architecture (QtSpim / SPIM / MARS)
# ==============================================================================

# ------------------------------------------------------------------------------
# DATA SEGMENT: Variables, prompts, and output text strings stored in RAM
# ------------------------------------------------------------------------------
.data
    # Prompts for user input
    prompt_msg:     .asciiz "========================================================\n                SUM OF EVEN NUMBERS (2 to 100)\n========================================================\nPress 2 or 4 or 6 or 8 to calculate even sum: "

    # Feedback messages
    msg_valid:      .asciiz "\nValid key received! Running loop for values 1 to 100...\n"
    msg_result:     .asciiz "\n========================================================\nResult: Sum of even numbers from 2 to 100 is: "
    msg_formula:    .asciiz "\nVerification: 50 even numbers x average 51 = 2550\n========================================================\n"
    
    # Error message if user enters any key other than 2, 4, 6, or 8
    msg_invalid:    .asciiz "\n[ERROR] Invalid key! You must enter 2, 4, 6, or 8.\nProgram terminated.\n"
    newline:        .asciiz "\n"

# ------------------------------------------------------------------------------
# TEXT SEGMENT: Executable CPU instructions
# ------------------------------------------------------------------------------
.text
.globl main

main:
    # ==========================================================================
    # STEP 1: Prompt the user to enter 2, 4, 6, or 8
    # ==========================================================================
    li $v0, 4                   # Syscall code 4 = Print String
    la $a0, prompt_msg          # Load address of prompt_msg into argument $a0
    syscall                     # Print the prompt to the QtSpim Console

    # ==========================================================================
    # STEP 2: Read the entered number from the user
    # ==========================================================================
    li $v0, 5                   # Syscall code 5 = Read Integer from keyboard
    syscall                     # Wait for user input (input stored into $v0)
    move $s0, $v0               # Save entered key into $s0 so $v0 is not lost

    # ==========================================================================
    # STEP 3: Validate user input
    # Requirement: User must press 2, 4, 6, or 8
    # We compare the entered number in $s0 against each valid even digit.
    # If it matches any of 2, 4, 6, or 8 -> jump to valid_input
    # Otherwise -> jump to invalid_input
    # ==========================================================================
    beq $s0, 2, valid_input     # If user entered 2 -> Valid, proceed to loop
    beq $s0, 4, valid_input     # If user entered 4 -> Valid, proceed to loop
    beq $s0, 6, valid_input     # If user entered 6 -> Valid, proceed to loop
    beq $s0, 8, valid_input     # If user entered 8 -> Valid, proceed to loop

    # If execution falls through to here, none of the valid keys were entered
    j invalid_input             # Branch to error handling

# ==============================================================================
# STEP 4: Valid Input Processing & Loop Execution
# ==============================================================================
valid_input:
    # Print confirmation message
    li $v0, 4                   # Syscall code 4 = Print String
    la $a0, msg_valid           # Load address of msg_valid
    syscall                     # Print the confirmation

    # --------------------------------------------------------------------------
    # REGISTER INITIALIZATION FOR THE LOOP:
    # $s1 = Running sum (accumulator), initialized to 0
    # $t0 = Loop counter / current value, initialized to 1 (starts at 1)
    # $t1 = Upper limit boundary, initialized to 100
    # --------------------------------------------------------------------------
    li $s1, 0                   # sum = 0
    li $t0, 1                   # current_value = 1 (we enter values from 1 to 100)
    li $t1, 100                 # upper_limit = 100

    # ==========================================================================
    # STEP 5: Loop to Enter & Process Values from 1 to 100
    # ==========================================================================
    # How the loop works:
    # 1. At each step, $t0 takes a value from 1, 2, 3, ..., up to 100.
    # 2. We test whether $t0 is EVEN using bitwise AND: ($t0 & 1).
    #    - If ($t0 & 1) == 0 -> the number is EVEN (e.g. 2, 4, 6, ..., 100).
    #    - If ($t0 & 1) == 1 -> the number is ODD (e.g. 1, 3, 5, ..., 99).
    # 3. If EVEN, add $t0 to the running sum in $s1 ($s1 = $s1 + $t0).
    # 4. If ODD, skip the addition.
    # 5. Increment $t0 by 1 ($t0 = $t0 + 1) and repeat until $t0 > 100.
    # ==========================================================================
loop_even:
    # Loop Condition: if current value ($t0) > upper limit 100 ($t1), stop loop
    bgt $t0, $t1, end_loop      # Branch to end_loop when $t0 reaches 101

    # --- Check if current value $t0 is Even ---
    # In binary:
    # An even number always has its least-significant bit (LSB) set to 0.
    # 2 in binary = ...0010
    # 4 in binary = ...0100
    # 'andi $t2, $t0, 1' isolates the lowest bit into $t2.
    andi $t2, $t0, 1            # $t2 = $t0 & 1
    bne $t2, $zero, skip_add    # If $t2 != 0, the number is ODD -> skip adding

    # --- If Even: Add $t0 to running sum $s1 ---
    add $s1, $s1, $t0           # $s1 = $s1 + $t0 (accumulate even number)

skip_add:
    # --- Increment loop counter by 1 to enter the next number ---
    addi $t0, $t0, 1            # $t0 = $t0 + 1 (step to next number)
    j loop_even                 # Jump back to start of loop_even

end_loop:
    # ==========================================================================
    # STEP 6: Display the Final Sum Result
    # ==========================================================================
    # Print result label message
    li $v0, 4                   # Syscall code 4 = Print String
    la $a0, msg_result          # Address of "Result: Sum of even numbers..."
    syscall                     # Print result header

    # Print the calculated integer sum stored in $s1 (Expected: 2550)
    li $v0, 1                   # Syscall code 1 = Print Integer
    move $a0, $s1               # Move sum from $s1 to argument register $a0
    syscall                     # Print the integer 2550

    # Print mathematical verification string
    li $v0, 4                   # Syscall code 4 = Print String
    la $a0, msg_formula         # Address of verification message
    syscall                     # Print verification

    # Gracefully terminate the program
    j exit_program              # Jump to exit

# ==============================================================================
# STEP 7: Handle Invalid Input
# ==============================================================================
invalid_input:
    li $v0, 4                   # Syscall code 4 = Print String
    la $a0, msg_invalid         # Address of error message
    syscall                     # Print the error message

# ==============================================================================
# STEP 8: Clean Program Exit
# ==============================================================================
exit_program:
    li $v0, 10                  # Syscall code 10 = Halt / Terminate execution
    syscall                     # Tells QtSpim to stop the program cleanly

# ==============================================================================
# END OF PROGRAM: sum_even_2_to_100.asm
# ==============================================================================
