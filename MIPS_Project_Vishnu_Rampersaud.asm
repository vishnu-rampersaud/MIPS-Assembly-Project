.data
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
m: .word 30	#declare variable m, m <-- 30 
n: .word 50	#declare variable n, n <-- 50

.text

la $t1, frameBuffer
li $t2, 0x00ffff00	#yellow color code
li $t3, 0x000000ff	#blue color code
addi $s0, $zero, 512 	#total columns
addi $s1, $zero, 256 	#total rows
addi $s2, $zero, 128	#middle of rows
addi $t4, $zero, 0 	#column counter
addi $t5, $zero, 0 	#row counter
lw $s3, n		#store value of n into register $s3
lw $s4, m		#store value of m into register $s4
srl $s3, $s3, 1		#s3 <-- n/2
sub $s5, $s2, $s3	#s5 <-- 128-(n/2) start row of piece2
sub $s6, $s5, $s4	#s6 <-- 128-(n/2)-m start row of piece1
add $s7, $s2, $s3	#s7 <-- 128+(n/2) start row of piece3

#Figure will not print if n and m are out of bounds. 
#Checks to make sure n and m are even
check_n:
andi $t9, $s3, 1		#t9 <-- 1 if n is odd, t9 <-- 0 if n is even
bne $t9, $zero, make_neven	#if n is odd, jump to make_neven

check_m:
andi $t9, $s4, 1		#t9 <-- 1 if m is odd, t9 <-- 0 if m is even
bne $t9, $zero, make_meven	#if m is oddm jump to make_meven
j yellow			#leave check if m is even

make_neven:
addi $s3, $s3, 1		#increment n by 1 to make n even
j check_m			#jump to check if m is even or odd

make_meven:
addi $s4, $s4, 1		#increment m by 1 to make m even
j yellow			#leave check

#prints the screen yellow
yellow:
beq $t4, $s0, next_row #IF col counter == 512 move to next row
sw $t2, 0($t1)  	#print yellow in current byte
addi $t1, $t1, 4 	#move to next byte
addi $t4, $t4, 1 	#column counter
j yellow

#keeps track of which row currently in
next_row:
add $t4, $zero, $zero 	#reset col counter
addi $t5, $t5, 1 	#row counter
beq $t5, $s6, piece1 	#If row counter == start of n stop printing yellow, start printing square(blue)
beq $t5, $s1, End 	#If row counter == 256 stop printing yellow
j yellow

#Formulas to determine where the figure should start and end
piece1:
sub $t6, $s1, $s3	#256-(n/2) start column
add $t7, $s1, $s3	#256+(n/2) end column
			#$s5 end row
			
#Prints screen yellow until it reaches the byte at start of figure
loop3:
beq $t4, $t6, piece1a
sw $t2, 0($t1)  	#print yellow in current byte
addi $t1, $t1, 4 	#move to next byte
addi $t4, $t4, 1 	#column counter
j loop3

#prints blue for the figure until finished in that row
piece1a:
beq $t4, $t7, loop4
sw $t3, 0($t1)		#print blue
addi $t1, $t1, 4 	#move to next byte
addi $t4, $t4, 1 	#column counter
j piece1a

#Prints yellow after printing blue figure in the row
loop4:
beq $t4, $s0, loop5
sw $t2, 0($t1)  	#print yellow in current byte
addi $t1, $t1, 4 	#move to next byte
addi $t4, $t4, 1 	#column counter
j loop4

#keeps track of row and column
loop5:
add $t4, $zero, $zero 	#reset col counter
addi $t5, $t5, 1 	#row counter
beq $t5, $s5, piece2	#print second part of figure
beq $t5, $s7, piece3	#print third part of figure
beq $t5, $t8, yellow	#print screen yellow
j loop3

#prints second piece (long horizontal piece) of figure
piece2:
sub $t6, $s1, $s3	#256-(n/2)
sub $t6, $t6, $s4	#256-(n/2)-m start column
add $t7, $s1, $s3	#256+(n/2) 
add $t7, $t7, $s4	#256+(n/2)+m end column
			#$s7 end row
j loop3

#print last piece of figure
piece3:
sub $t6, $s1, $s3	#256-(n/2) start column
add $t7, $s1, $s3	#256+(n/2) end column
add $t8, $s2, $s3	#128+(n/2)
add $t8, $t8, $s4	#128+(n/2)+m end row
j loop3

End:
addi $v0, $zero, 10	#system call to exit program
syscall 		#Exit program
