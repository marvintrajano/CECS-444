%{
/* Team Members: Marvin Trajano, Lisa Tran, Ben Kray, Victor Tran, Keith Farnham */
#include "project.h"

struct variable
{
	char *name;
	double value;
	struct variable *next;
	struct variable *prev;
}*head, *current, *temp;

void createNode(char* sym)
{
	temp = (struct variable *)malloc(1*sizeof(struct variable));
	temp->prev = NULL;
	temp->next = NULL;
	temp->name = strdup(sym);
	temp->value = 0.0;
}

struct variable * search(char* sym)
{
	struct variable *searchPointer = head;
	if(searchPointer == NULL)
	{
		printf("Symbol table is empty");
		return NULL;
	}
	while(searchPointer != NULL)
	{
		if(!strcmp(searchPointer->name, sym))
		{
			return searchPointer;
		}
		else
			searchPointer = searchPointer->next;
	}
}

void insert(char* sym)
{
	if(head == NULL)
	{
		createNode(sym);
		head = temp;
		current = head;
	}
	else if(search(sym) == NULL)
	{
		createNode(sym);
		current->next = temp;
		temp->prev = current;
		current = temp;
	}
}

void tablePrint()
{
	struct variable *printPointer = current;
	if(printPointer == NULL)
	{
		printf("Symbol table is empty");
		return;
	}
	printf("\nSymbol Table\n");
	while(printPointer->prev != NULL)
	{
		printf("Variable Name: %s\t%f\n", printPointer->name, printPointer->value);
		printPointer = printPointer->prev;
	}
	printf("Variable Name: %s\t%f\n", printPointer->name, printPointer->value);
	printPointer = printPointer->prev;	
}

void assign(char* sym, double val)
{
	struct variable *assignPointer = search(sym);
	assignPointer->value = val;
}

double getVal(char* sym)
{
	struct variable *valuePointer = search(sym);
	return valuePointer->value;
}

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
%token END
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
%token <theOperator> LP
%token <theOperator> RP
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
	: ADD | SUBTRACT | MULTIPLY | DIVIDE { strcpy($$, $1); }
rel_op
	: LT | LTE | GT | GTE | EQ | NEQ { strcpy($$, $1); }
bool_op
	: AND | OR { strcpy($$, $1); }

number
	: INTEGER { $$ = $1; }
number
	: REAL { $$ = $1; }
num_expr
	: number { $$ = $1; }
num_expr
	: VARIABLE { $$ = getVal($1); }
num_expr
	: num_expr arith_op num_expr { $$ = numEval($2, $1, $3); }
num_expr
	: LP num_expr RP { $$ = $2; }
bool_expr
	: num_expr rel_op num_expr { $$ = relEval($2, $1, $3); }
bool_expr
	: bool_expr bool_op bool_expr { $$ = boolEval($2, $1, $3); }
bool_expr
	: LP 
