%{
	/* Team Members: Marvin Trajano, Lisa Tran, Ben Kray, Victor Tran, Keith Farnham */
   #include <stdlib.h>
   #include <string.h>
   #include "final.h"
   #include "final.tab.h"
   
   int isNullTerminated = 1;
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
","						{	
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

