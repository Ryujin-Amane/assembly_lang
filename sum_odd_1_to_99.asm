# ==============================================================================
# Program:  sum_odd_1_to_99.asm
# Purpose:  1. Prompt user to press/enter 1, 3, 5, 7, or 9.
#           2. Validate that the entered key is one of {1, 3, 5, 7, 9}.
#           3. Use a loop entering/iterating values from 1 to 100.
#           4. Accumulate the sum of all odd numbers (1, 3, 5, ..., 99).
#           5. Display the calculated sum (Result = 2500).
# Platform: MIPS Architecture (QtSpim / SPIM / MARS)
# ==============================================================================

# ------------------------------------------------------------------------------
# DATA SEGMENT: Variables, prompts, and output text strings stored in RAM
# ------------------------------------------------------------------------------
.data
    # Prompts for user input
    prompt_msg:     .asciiz "========================================================\n                 SUM OF ODD NUMBERS (1 to 99)\n========================================================\nPress 1 or 3 or 5 or 7 or 9 to calculate odd sum: "

    # Feedback messages
    msg_valid:      .asciiz "\nValid key received! Running loop for values 1 to 100...\n"
    msg_result:     .asciiz "\n========================================================\nResult: Sum of odd numbers from 1 to 99 is: "
    msg_formula:    .asciiz "\nVerification: 50 odd numbers x average 50 = 2500\n========================================================\n"
    
    # Error message if user enters any key other than 1, 3, 5, 7, or 9
    msg_invalid:    .asciiz "\n[ERROR] Invalid key! You must enter 1, 3, 5, 7, or 9.\nProgram terminated.\n"
    newline:        .asciiz "\n"

# ------------------------------------------------------------------------------
# TEXT SEGMENT: Executable CPU instructions
# ------------------------------------------------------------------------------
.text
.globl main

main:
    # ==========================================================================
    # STEP 1: Prompt the user to enter 1, 3, 5, 7, or 9
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
    # Requirement: User must press 1, 3, 5, 7, or 9
    # We compare the entered number in $s0 against each valid odd digit.
    # If it matches any of 1, 3, 5, 7, or 9 -> jump to valid_input
    # Otherwise -> jump to invalid_input
    # ==========================================================================
    beq $s0, 1, valid_input     # If user entered 1 -> Valid, proceed to loop
    beq $s0, 3, valid_input     # If user entered 3 -> Valid, proceed to loop
    beq $s0, 5, valid_input     # If user entered 5 -> Valid, proceed to loop
    beq $s0, 7, valid_input     # If user entered 7 -> Valid, proceed to loop
    beq $s0, 9, valid_input     # If user entered 9 -> Valid, proceed to loop

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
    # 2. We test whether $t0 is ODD using bitwise AND: ($t0 & 1).
    #    - If ($t0 & 1) == 1 -> the number is ODD (e.g. 1, 3, 5, ..., 99).
    #    - If ($t0 & 1) == 0 -> the number is EVEN (e.g. 2, 4, 6, ..., 100).
    # 3. If ODD, add $t0 to the running sum in $s1 ($s1 = $s1 + $t0).
    # 4. If EVEN, skip the addition.
    # 5. Increment $t0 by 1 ($t0 = $t0 + 1) and repeat until $t0 > 100.
    # ==========================================================================
loop_odd:
    # Loop Condition: if current value ($t0) > upper limit 100 ($t1), stop loop
    bgt $t0, $t1, end_loop      # Branch to end_loop when $t0 reaches 101

    # --- Check if current value $t0 is Odd ---
    # In binary:
    # An odd number always has its least-significant bit (LSB) set to 1.
    # 1 in binary = ...0001
    # 3 in binary = ...0011
    # 'andi $t2, $t0, 1' isolates the lowest bit into $t2.
    andi $t2, $t0, 1            # $t2 = $t0 & 1
    beq $t2, $zero, skip_add    # If $t2 == 0, the number is EVEN -> skip adding

    # --- If Odd: Add $t0 to running sum $s1 ---
    add $s1, $s1, $t0           # $s1 = $s1 + $t0 (accumulate odd number)

skip_add:
    # --- Increment loop counter by 1 to enter the next number ---
    addi $t0, $t0, 1            # $t0 = $t0 + 1 (step to next number)
    j loop_odd                  # Jump back to start of loop_odd

end_loop:
    # ==========================================================================
    # STEP 6: Display the Final Sum Result
    # ==========================================================================
    # Print result label message
    li $v0, 4                   # Syscall code 4 = Print String
    la $a0, msg_result          # Address of "Result: Sum of odd numbers..."
    syscall                     # Print result header

    # Print the calculated integer sum stored in $s1 (Expected: 2500)
    li $v0, 1                   # Syscall code 1 = Print Integer
    move $a0, $s1               # Move sum from $s1 to argument register $a0
    syscall                     # Print the integer 2500

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
# END OF PROGRAM: sum_odd_1_to_99.asm
# ==============================================================================
