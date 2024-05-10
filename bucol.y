%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

extern int yylex();
extern int yylineno;
void yyerror(const char* s);
void lineEndError(const char* s);
void isProgrameWellFormed();

void addVariable(int size, char* identifier);
void checkIdentifier(char* identifier);
void moveIntToVar(int val, char* identifier);
void moveVarToVar(char* idOne, char* idTwo);
int isVariableDefined(char* vName);

typedef struct {
   char* name;
   int size;
} Var;

Var identifiers[100];
int numVariables = 0;
int isWellFormed = 0;
%}

%union {int number; int size; char* name;}
%start program
%token <name> IDENTIFIER
%token <size> INT_SIZE
%token <number> INTEGER
%token BEGINING
%token BODY
%token END
%token MOVE
%token ADD
%token PRINT
%token INPUT
%token TO
%token SEMICOLON
%token WORD
%token PERIOD

%%
program:            beginning body end {} 
                    
beginning:          BEGINING line_end declarations {}
                    
declarations:       declarations declaration {} | {} 
                    
declaration:        INT_SIZE IDENTIFIER line_end {addVariable($1, $2);}
                     
body:               BODY line_end operations {} | BODY line_end {}
                    
operations:         operation operations {} | operation {} 
                    
operation:          move {} | add {} | print {} | input {}

move:               MOVE IDENTIFIER TO IDENTIFIER line_end {moveVarToVar($2, $4);} 
                    | MOVE INTEGER TO IDENTIFIER line_end {moveIntToVar($2, $4);}

add:                ADD INTEGER TO IDENTIFIER line_end {checkIdentifier($4);}
                    | ADD IDENTIFIER TO IDENTIFIER line_end {checkIdentifier($2); checkIdentifier($4);}

print:              PRINT argumentToPrint {}

argumentToPrint:    WORD SEMICOLON argumentToPrint {}
                    | IDENTIFIER SEMICOLON argumentToPrint {checkIdentifier($1);}
                    | WORD line_end {}
                    | IDENTIFIER line_end {checkIdentifier($1);}

input:              INPUT input_arg {}

input_arg:          IDENTIFIER SEMICOLON input_arg {}
                    | IDENTIFIER line_end {checkIdentifier($1);}

end:                END line_end {isProgrameWellFormed();}

line_end:           PERIOD | {lineEndError("Expect a period at the end of the line");}


%%

int main(){
    return yyparse();
}

int isVariableDefined(char* vName){
    int i;
    for(i = 0; i < numVariables; i++){
        if(strcmp(identifiers[i].name, vName) == 0){
            return i;
        }
    }    
    return -1;
}

void checkIdentifier(char* identifier){
    if(isVariableDefined(identifier) == -1){
        isWellFormed++;
        fprintf(stderr, "Error on line %d: Variable %s does not exist\n", yylineno, identifier);
    } 
}

void addVariable(int size, char*  identifier){
    for (int i = 1; i < strlen(identifier)-1; i++){
        if (identifier[i-1] == 'X' && identifier[i] == 'X'){
            isWellFormed++;
            fprintf(stderr, "Error on line %d, %s Can't have contigious X in variable declaration\n", yylineno, identifier);
            return;
        }
    }
    if(isVariableDefined(identifier) != -1){
        isWellFormed++;
        fprintf(stderr, "Error on line %d: Variable %s already exists\n", yylineno, identifier);
    }
    identifiers[numVariables].name = identifier;
    identifiers[numVariables].size = size;
    numVariables++;
}

void moveIntToVar(int val, char* identifier){
    int variableIndex = isVariableDefined(identifier);
    if(variableIndex == -1){
        isWellFormed++;
        fprintf(stderr, "Error on line %d:  Variable %s does not exist\n", yylineno, identifier);
    }
    else{
        int numberOfDigits = floor(log10(abs(val))) + 1;
        int maxSize = identifiers[variableIndex].size;
        if(numberOfDigits > maxSize){
            isWellFormed++;
            fprintf(stderr, "Warning on line %d: value %d is too big for variable %s of size %d\n", yylineno, val, identifier, maxSize);
        }
    }
}

void moveVarToVar(char* idOne, char* idTwo){
    int variableIndex1 = isVariableDefined(idOne);
    int variableIndex2 = isVariableDefined(idTwo);
    
    if(variableIndex1 == -1){
        isWellFormed++;
        fprintf(stderr, "Error on line %d: Variable %s does not exist\n", yylineno, idOne);
    }
    else if(variableIndex2 == -1){
        isWellFormed++;
        fprintf(stderr, "Error on line %d: Variable %s does not exist\n", yylineno, idTwo);
    }
    else{
        int varOneSize = identifiers[variableIndex1].size;
        int varTwoSize = identifiers[variableIndex2].size;
        
        if(variableIndex1 > variableIndex2){
            isWellFormed++;
            fprintf(stderr, "Warning on line %d: Cannot assign variable of size %d to variable of size %d\n", yylineno, varOneSize, varTwoSize);
        }
    }
}

void yyerror(const char *s) {
    isWellFormed++;
    fprintf(stderr, "Error on line %d: %s\n", yylineno, s);
}

void lineEndError(const char* s){
    isWellFormed++;
    fprintf(stderr, "Error on line %d: %s\n", yylineno, s);
}

void isProgrameWellFormed(){
    if (isWellFormed == 0){
        fprintf(stderr, "\nProgram is well formed\n\n");
    }
    else{
        fprintf(stderr, "\nProgram is not well formed, Found %d issues with the Program\n\n", isWellFormed);
    }
}
