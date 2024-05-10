# Bucol flex and parser

## To Run
To BUILD the PARSER you can run the following 3 commands:
```
flex bucol.l
bison -d bucol.y
gcc lex.yy.c bucol.tab.c -o project_program.out
```
Or jam it in on one line:
```
flex bucol.l && bison -d bucol.y && gcc lex.yy.c bucol.tab.c -o project_program.out
```
To RUN the PARSER run the following with either valid or invalid inputs, these are only example inputs, feel free to change them up:
```
./project_program.out < input_valid.txt
./project_program.out < input_invalid.txt
```

## Example Output
```
Error on line 5, XXY-1 Can't have contigious X in variable declaration
Error on line 6: Variable Z already exists
Warning on line 12: value 15000 is too big for variable Z of size 4
Warning on line 13: Cannot assign variable of size 4 to variable of size 3
Error on line 15: Variable XY does not exist
Error on line 17: Expect a period at the end of the line

Program is not well formed, Found 6 issues with the Program
```
OR
```
Program is well formed
```