# David Gudeman
# CS10
# Lab five - unroll inner loop by 2

.data
Instructions: .asciiz "Type in integers followed by a space\n"
EnterRowA: .asciiz "Array a - Enter row  "
EnterRowB: .asciiz "Array b - Enter row  "
EmptyLine: .asciiz "\n"
PrintRow: .asciiz "Row "
Colon: .asciiz ": "
Dash: .asciiz "- "
Space: .asciiz " "

listsz: .word 72 # number of integers in the array
answer: .space 200
answersz: .word 16
rowCount: .word 6
charCount: .byte 12 # this is the character count for input string 
columnCount: .word 24

.text
#####################get some memory to catch strings#####
la $t4, 256($sp) # set address to catch STRING in $t4
la $s4, 256($sp) # save address of STRING for LoopB
########################Print out instructions ############
#li $v0, 4    # service number to PRINT STRING
#li $a1, 9    # ok to load 9 characters
#la $a0, Instructions
#syscall
#li $v0, 4    # service number to PRINT STRING
#li $a1, 9    # ok to load 9 characters
#la $a0, EmptyLine
#syscall
########################Input String Text for array a ############
addi $t6, $zero, 1 # set enterString counter to 0
enterStringA: #Enter string numbers
#li $v0, 4    # service number to PRINT STRING
#li $a1, 9    # ok to load 9 characters
#la $a0, EnterRowA
#syscall
#li $v0, 1    # service number PRINT INTEGER
#move $a0, $t6 #load the value of the counter to print row number
#syscall
#li $v0, 4    # service number to PRINT STRING
#li $a1, 2    # ok to load 2 characters
#la $a0, Colon
#syscall
lw $t7, charCount #load in number of columns in input array
lw $t8, rowCount #load in number of rows per array
lw $t5, columnCount #load the number of columns in both arrays
la $a0, ($t4)# loads address to write the string to
add $a1, $t7, 1   # 8 bytes (characters) +1 allows 4 characters and 4 spaces on string input
li $v0, 8    # service number READ STRING
syscall      # read value goes into $t4

addi $t6, $t6, 1 # increment loop counter by one
addi $t4, $t4, 12 # move 8 spaces in the memory to catch next string of 4 char
ble $t6, $t8, enterStringA # ends loop at number of rows to be entered
########################Print an Empty Line #######################
li $v0, 4    # service number to PRINT STRING
li $a1, 2    # ok to load 2 characters
la $a0, EmptyLine
syscall
########################Input String Text for array b ##############
li $t6, 1 # reset the counter to collect array B
enterStringB: #Enter string numbers
#li $v0, 4    # service number to PRINT STRING
#li $a1, 9    # ok to load 9 characters
#la $a0, EnterRowB
#syscall
#li $v0, 1    # service number PRINT INTEGER
#move $a0, $t6 #load the value of the counter to print row number
#syscall
#li $v0, 4    # service number to PRINT STRING
#li $a1, 2    # ok to load 2 characters
#la $a0, Colon
#syscall
la $a0, ($t4)# to continue catching strings
add $a1, $t7, 1   # ok to load 9 colums (characters) +1
li $v0, 8    # service number READ STRING
syscall      # read value goes into $t4
addi $t6, $t6, 1 # increment loop counter by one
addi $t4, $t4, 12 # move 8 spaces in the memory to catch next string of 4 char
ble $t6, $t8, enterStringB # ends loop at number of rows to be entered
############convert char to integers and put in new array#########
mul $s0, $t7, $t5   # $s0 = array dimension

sub $sp, $sp, $s0 #make room on stack for number of words in the array
la $s1 ($sp)     #load base address of the array in $s1
li $t0, 0        # $t0 = # elems init'd

convertSringToInteger:beq $t0, 72, doneConvert # 72 is the iterations of conversion
lb $s3, ($s4) # store byte from $s4 into $s3
sub $s3, $s3, 0x30 # subtract 0x30 from character to convert to integer
sb $s3, ($s1) # store byte from $s3 to $s1
addi $s1, $s1, 4 # step to next array cell
addi $t0, $t0, 1 # count elem just init'd
addi $s4, $s4, 2 #increment the characters
b convertSringToInteger

doneConvert:
################Table of registers for the loop counters###############
#$v0 holds b2 address
#$v1 holds a2 address

#$t0 holds b array value
#$t1 holds i counter - a array row
#$t2 holds j counter - a array column
#$t3 holds k counter - b array row
#$t4 holds l counter - b array column
#$t5 holds calulations for b address offset
#$t6 holds a2 * b2
#$t7 holds calculations for a array
#$t8 holds value for a cell and catches a value to add
#$t9 holds a array value and final calulation

#$s1 FREE
#$s1 holds i calulcations a row
#$s2 holds j calculations a column
#$s3 holds k calculations b row
#$s4 holds 1) l calculations b columns (2) holds b2 operand
#$s5 holds address for start of b array CONSTANT
#$s6 holds address for b array element
#$s7 holds address for a array element

#$a0 FREE
#$a1 unknown
#$a2 hold counter for the answer which incrments by 4
#$a3 holds address for the answer
##################initialize values for the loops###################
li $t0, 0x00
li $t1, 0x00 # i counter (array a rows)
li $t2, 0x00 # j counter (array a columns)
li $t3, 0x00 # k counter (array b rows)
li $t4, 0x00 # l counter (array b columns)
li $a2, 0x00 # ANSWER COUNTER
li $t7, 0x00 # m start the loop counter to calculate the answer array
li $t8, 0x00 # j counter for columns of Array One
li $t9, 0x00 # k counter for rows of Array Two
li $s0, 0x00 # 
li $s2, 0x00 

###########set base addresses for arrays to calculate and catch answer###
la $s5, 144($sp) # array b: add (array size a * 4) to $sp get to start address of array b 
la $a3 768($sp)#a3 will be the base address of ANSWER array 
###########start loops##################################################
i_loop:
li $t4, 0x00 # l counter
l_loop:
li $t2, 0x00 # j counter
li $t3, 0x00 # k counter
k_loop:
#set up b array
#set up b1 get-operand
mul $s4, $t4, 4   # array b: (l counter) * (word) caclulates the b column offset
mul $s3, $t3, 24  # array b: (k counter) * (length of row) calculates the b row offset
add $t5, $s3, $s4 # array b: add (word * l counter) + (length of row * k counter) = total offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address ($s4 cam be used)
#set up b2 get-operand 
lw $t0, 0($s6)	  # array b1: load operand
lw $s4, 24($s6)   # array b2: load operand b1 adress + 24 ($s4 reused for $v0)
lw $t8, 48($s6)   # array b3: load operand b1 adress + 48 
#set up a array
mul $s1, $t1, 24  # array a1: i * 24 calculates a1 row
mul $s2, $t2, 4   # array a1: j * 4 calculates the a1 column
add $t7, $s1, $s2 # array a1: (i * 24)+(j*4) yields offset ($s2 can be reused)
add $s7, $sp, $t7 # array a1: this adjusts the get-operand a1 address ($t7 can be reused)
# load operands a
lw $t9, ($s7)     # array a1: load a1 operand      
lw $t6, 4($s7)    # array a2: a2 operand address = a1 address + 4
lw $v0, 8($s7)    # array a3: a3 operand address = a1 address + 8
mul $t9, $t0, $t9 # a1 * b1 hold in $t9
mul $s1, $s4, $t6 # a2 * b2 hold in $s1 ($s4 reused for $v0)
mul $t0, $t8, $v0 # a3 * b3 held in $t0 reused
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c1 + (a1 * b1) = c1
add $t8, $s1, $t8 # c1 + (a2 * b2) = c2
add $t8, $t0, $t8 # c2 + (a3 * b2) = c3
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $a2, $a2, 1  # ANSWER: increment counter 
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 3  # array b: increment k
blt $t3, 6, k_loop # terminate at 3 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 6, l_loop
#increment counter
addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 6, i_loop
#exit:
####################Print out ANSWER array################################
la $a3 768($sp)#a3 will be the base address of answer array CONSTANT
li $t2, 0x00 #initialize a counter for the OuterLoop
#sub $s1, $s1, 132 # load base address of the array

AnswerArrayPrintOut:
addi $t7, $zero, 0 # initialize a counter for InnerLoopOutPut
addi $a0, $0, 0xA #ascii code for Line Feed
addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
syscall

FourIntegerRowPrintOut: # cycles through 4 integers per row
lw $t5, ($a3) #loads INTEGER to print into $t5
li $v0, 1 # service number PRINT INTEGER
move $a0, $t5 #load the value $t5 (INTEGER) into $a0 for syscall
syscall
li $v0, 4 # service number to PRINT SPACE
li $a1, 2 # ok to load 9 characters
la $a0, Space # load address of Space into $a0
syscall
addi $t7, $t7, 1 # increment counter for InnerLoopOutPut
addi $a3, $a3, 4 # add to get to the next word in array

bne $t7, 6, FourIntegerRowPrintOut # break out of inner loop at 4
addi $t2, $t2, 1 # increment outer loop counter by one
ble $t2, 5, AnswerArrayPrintOut # break out of Loop if 9 rows is hit

li $v0, 10
syscall 
