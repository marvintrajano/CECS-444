%{
	/* Team Members: Marvin Trajano, Lisa Tran, Ben Kray, Victor Tran, Keith Farnham */
   #include <stdlib.h>
   #include <string.h>
   #include "final.h"
   #include "final.tab.h"
   
   int isNullTerminated = 1;
   
struct variable
{
	char *name;
	char *type;
	double value;
};

/* simple symbol table of fixed size */
struct variable symbolTable[TABLE_SIZE];

struct variable * lookup(char* sym)
{
	struct variable *vp = &symbolTable[symhash(sym)%TABLE_SIZE];
	int vcount = TABLE_SIZE;
	while(--vcount >= 0)
	{
		if(vp->name && !strcmp(vp->name, sym))
		{
			return vp;
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

%}

%x string

%%

[0-9]+						{ 
								yylval.theInt = atoi(yytext); 
								return(INTEGER);
							}
[0-9]*\.[0-9]+				{ 	
								yylval.theReal = atof(yytext); 
								return(REAL);
							}
\"							{	
								isNullTerminated = 1;
								BEGIN(string);
							}
<string>[^"]*				{	
								strcpy(yylval.theString, yytext);
								isNullTerminated = 0;
							}
<string>\"					{ 
								if(isNullTerminated == 1) 
									strcpy(yylval.theString, yytext);; 
								BEGIN(INITIAL);
								return STRING;
							}
[a-zA-Z][0-9]*				{	
								lookup(yytext);
								strcpy(yylval.theVariable, yytext);
								return VARIABLE;
							}
"DSYMTAB"					{ 	
								strcpy(yylval.theReserved, yytext);
								return DSYMTAB;
							}
"PRINT"						{ 	
								strcpy(yylval.theReserved, yytext);
								return PRINT;
							}
"IF"						{ 	
								strcpy(yylval.theReserved, yytext);
								return IF;
							}
"THEN"						{ 	
								strcpy(yylval.theReserved, yytext);
								return THEN;
							}
"FI"						{ 	
								strcpy(yylval.theReserved, yytext);
								return FI;
							}
","							{	
								strcpy(yylval.theReserved, yytext);
								return COMMA;
							}							
":="						{	
								strcpy(yylval.theOperator, yytext);
								return ASSIGNMENT;
							}
"+"		      				{ 
								strcpy(yylval.theOperator, yytext);
								return(ADD); 
							}
"-"		      				{  
								strcpy(yylval.theOperator, yytext);
								return(SUBTRACT); 
							}
"*"		      				{  
								strcpy(yylval.theOperator, yytext);
								return(MULTIPLY); 
							}
"/"		      				{  
								strcpy(yylval.theOperator, yytext);
								return(DIVIDE); 
							}
"<"		      				{  
								strcpy(yylval.theOperator, yytext);
								return(LT); 
							}
"<="		      			{  
								strcpy(yylval.theOperator, yytext);
								return(LTE); 
							}
">"		      				{  
								strcpy(yylval.theOperator, yytext);
								return(GT); 
							}
">="		      			{  
								strcpy(yylval.theOperator, yytext);
								return(GTE); 
							}
"=="                  		{  
								strcpy(yylval.theOperator, yytext);
								return(EQ); 
							}
"!="                  		{  
								strcpy(yylval.theOperator, yytext);
								return(NEQ); 
							}
"&&"		      			{  
								strcpy(yylval.theOperator, yytext);
								return(AND); 
							}
"||"		      			{  
								strcpy(yylval.theOperator, yytext);
								return(OR); 
							}
[ \t]+                		{ }
\n		      				{ return NL; }
.                    
%%
symhash(char *sym)
{
	unsigned int hash = 0;
	unsigned c;
	while(c = *sym++)
		hash = hash*9^c;
	return hash;
}

symcompare(const void *xa, const void *xb)
{
	const struct variable *a = xa;
	const struct variable *b = xb;
	
	if(!a->name)
	{
		if(!b->name)
			return 0;
		return 1;
	}
	if(!b->name)
		return -1;
	return strcmp(a->name, b->name);
}

