%{
#include "final.h"

struct variable
{
	char *name;
	char *type;
	double value;
};

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }

char *getBoolWord(unsigned int value)
{
	return (value == 1) ? "true" : "false";
}

double numEval(char *operator, double operand1, double operand2)
{
   if(strcmp(operator, "+") == 0) return operand1 + operand2;
   else if(strcmp(operator, "-") == 0) return operand1 - operand2;
   else if(strcmp(operator, "*") == 0) return operand1 * operand2;
   else if(strcmp(operator, "/") == 0)
   {
      if(operand2 == 0.0)
      {
         printf("\nError: Divide by zero: %g/%g\n", operand1, operand2);
         return 0.0;
      }
      else
      {
         return operand1 / operand2;
      }
   }
   else
   {
         printf("\nError: Unknown operator: %s\n", operator);
         return 0.0;
   }
}

unsigned int relEval(char *rel_op, double op1, double op2)
{
   if(strcmp(rel_op, "<") == 0) return (op1 < op2 ? 1 : 0);
   else if(strcmp(rel_op, "<=") == 0) return (op1 <= op2 ? 1 : 0);
   else if(strcmp(rel_op, ">") == 0) return (op1 > op2 ? 1 : 0);
   else if(strcmp(rel_op, ">=") == 0) return (op1 >= op2 ? 1 : 0);
   else if(strcmp(rel_op, "==") == 0) return (op1 == op2 ? 1 : 0);
   else if(strcmp(rel_op, "!=") == 0) return (op1 != op2 ? 1 : 0);
   else
   {
      printf("ERROR: Unknown relational operator: %s\n", rel_op);
      return 0;
   }
}
   
unsigned int boolEval(char *bool_op, unsigned int op1, unsigned int op2)
{
   if(strcmp(bool_op, "&&") == 0) return op1 && op2;
   if(strcmp(bool_op, "||") == 0) return op1 || op2;
   else
   {
      printf("ERROR: Unknown boolean operator: %s\n", bool_op);
      return 0;
   }
}

extern struct variable symbolTable[TABLE_SIZE];
extern struct variable * lookup(char* sym);

struct variable * assign(char* sym, double val)
{
	struct variable *vp = &symbolTable[symhash(sym)%TABLE_SIZE];
	int vcount = TABLE_SIZE;
	while(--vcount >= 0)
	{
		if(vp->name && !strcmp(vp->name, sym))
		{
			vp->value = val;
		}
		if(!vp->name)
		{
			char * unknown = "Unknown";
			/* For now type and value are defaulted to unknown, later on we must fix this method to have type and value as parameters */
			vp->name = strdup(sym);
			vp->type = unknown;
			vp->value = 0.0;
			return vp;
		}
		if(++vp >= symbolTable+TABLE_SIZE)
			vp = symbolTable;
	}
}

double getVal(char* sym)
{
	struct variable *vp = &symbolTable[symhash(sym)%TABLE_SIZE];
	int vcount = TABLE_SIZE;
	while(--vcount >= 0)
	{
		if(vp->name && !strcmp(vp->name, sym))
		{
			return vp->value;
		}
		if(!vp->name)
		{
			char * unknown = "Unknown";
			/* For now type and value are defaulted to unknown, later on we must fix this method to have type and value as parameters */
			vp->name = strdup(sym);
			vp->type = unknown;
			vp->value = 0.0;
			return -8008.0;
		}
		if(++vp >= symbolTable+TABLE_SIZE)
			vp = symbolTable;
	}
}

%}

%union
{
	int  theInt;
    double theReal;
	char theOperator[MAX_STRING_LEN + 1];
	char theVariable[MAX_STRING_LEN + 1];
	char theReserved[MAX_STRING_LEN + 1];
	char theString[MAX_STRING_LEN + 1];
	unsigned int theBoolean;
}
%error-verbose
%token NL
%token <theOperator> LT
%token <theOperator> LTE
%token <theOperator> GT
%token <theOperator> GTE
%token <theOperator> EQ
%token <theOperator> NEQ
%token <theOperator> ADD
%token <theOperator> SUBTRACT
%token <theOperator> MULTIPLY
%token <theOperator> DIVIDE
%token <theOperator> AND
%token <theOperator> OR
%token <theOperator> ASSIGNMENT
%token <theReserved> DSYMTAB
%token <theReserved> PRINT
%token <theReserved> IF
%token <theReserved> THEN
%token <theReserved> FI

%token <theInt> INTEGER
%token <theReal> REAL
%token <theVariable> VARIABLE
%token <theReserved> STRING
%token <theReserved> COMMA

%type <theOperator> arith_op
%type <theOperator> bool_op
%type <theOperator> rel_op
%type <theReal> number
%type <theReal> num_expr
%type <theBoolean> bool_expr
%type <theOperator> ass_expr
%type <theReserved> dsymtab_expr
%type <theReserved> print_expr
%type <theReserved> string_expr
%type <theReserved> if_expr

%left AND OR
%left LT LTE GT GTE EQ NEQ
%left '+' '-'
%left '*' '/'

%start program

%%

arith_op
	: ADD | SUBTRACT | MULTIPLY | DIVIDE  		{ strcpy($$, $1); }
rel_op
	: LT | LTE | GT | GTE | EQ | NEQ        	{ strcpy($$, $1); }
bool_op
	: AND | OR                             		{ strcpy($$, $1); }

number
	: INTEGER    								{ $$ = $1; }
number
	: REAL										{ $$ = $1; }
num_expr
	: number									{ $$ = $1; }
num_expr
	: VARIABLE 									{ $$ = getVal($1); }
num_expr
	: num_expr arith_op num_expr 				{ $$ = numEval($2, $1, $3); }
num_expr
	: '(' num_expr ')'    						{ $$ = $2; }
bool_expr
	: num_expr rel_op num_expr  				{ $$ = relEval($2, $1, $3); }
bool_expr
	: bool_expr bool_op bool_expr 				{ $$ = boolEval($2, $1, $3); }
bool_expr
	: '(' bool_expr ')'          				{ $$ = $2; }
ass_expr
	: VARIABLE ASSIGNMENT num_expr 				{ assign($1, $3); }
print_expr
	: PRINT string_expr 						{ printf("%s\n", $2); }
dsymtab_expr
	: DSYMTAB 									{ printf("DSYMTAB FOUND - CALL METHOD TO PRINT SYMBOL TABLE HERE\n"); }
string_expr
	: STRING 									{ strcpy($$, $1); }
string_expr
	: num_expr 									{ char tmp[MAX_STRING_LEN+1]; snprintf(tmp, (MAX_STRING_LEN + 1), "%g", $1); strcpy($$, tmp); }
string_expr
	: bool_expr 								{ strcpy($$, getBoolWord($1)); }
string_expr
	: string_expr COMMA string_expr 			{ strcat($1, $3); strcpy($$, $1); }
if_expr
	: IF bool_expr NL THEN NL ass_expr NL FI	{ printf("IF STATEMENT DETECTED! - WRITE METHOD TO EVALUATE IF STATEMENT HERE\n"); }
			    
program
	: 
	| statement_list NL
	;

statement_list
	: 
	| statement_list statement
	;
                  
statement
	: ass_expr NL {  }
	| print_expr NL {  }
	| dsymtab_expr NL {  }
	| if_expr NL {  }
	| NL {  }
	;
%%

int main(int argc, char **argv)
{
   yyparse();

   return 0;
}
