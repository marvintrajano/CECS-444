%{
/* Team Members: Marvin Trajano, Lisa Tran */
#define INTEGER 257
#define REAL 258
#define CHARACTER 259
#define STRING 260
#define VARIABLE 261
#define IF 262
#define THEN 263
#define FI 264
#define FOR 265
#define WHILE 266
#define DO 267
#define DONE 268
#define LEFT_PAREN 269
#define RIGHT_PAREN 270
#define PRINT 271
#define ASSIGNMENT 272
#define RELOPERATOR 273
#define TO 274
#define STEP 275
#define ARITHOPERATOR 276
#define TABLE_SIZE 1000

int isNullTerminated = 1;

struct variable
{
	char *name;
	char *type;
	char *value;
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
			vp->value = unknown;
			return vp;
		}
		if(++vp >= symbolTable+TABLE_SIZE)
			vp = symbolTable;
	}
}

%}
%x string character
%%
[0-9]+						{ 
								printf("Recognized Type: Integer\t\tValue: %s\n", yytext);
								return INTEGER;
							}
[0-9]*\.[0-9]+				{ 	
								printf("Recognized Type: Real\t\tValue: %s\n", yytext);
								return REAL;
							}
\"							{	
								isNullTerminated = 1;
								BEGIN(string);
							}
<string>[^"]*				{	
								printf("Recognized Type: String\t\tValue: %s\n", yytext);
								isNullTerminated = 0;
								return STRING;
							}
<string>\"					{ 
								if(isNullTerminated == 1) printf("Recognized Type: String\t\tValue: \n"); 
								BEGIN(INITIAL);
								return STRING;
							}
\'							{	
								isNullTerminated = 1;
								BEGIN(character);
							}
\'/[^'][^']					{ }
<character>[^']				{	
								printf("Recognized Type: Character\t\tValue: %s\n", yytext);
								isNullTerminated = 0;
								return CHARACTER;
							}
<character>\'				{	
								if(isNullTerminated == 1) printf("Recognized Type: Character\t\tValue: \n");
								BEGIN(INITIAL);
								return CHARACTER;
							}
<character>\'\'				{	
								printf("Recognized Type: Character\t\tValue: %s\n", yytext);
								BEGIN(INITIAL);
								return CHARACTER;
							}
"FOR"|"for"					{	
								printf("Recognized Type: for\t\t\tValue: %s\n", yytext);
								return FOR;
							}
f/or[a-zA-Z0-9]+			{ }
"("							{	
								printf("Recognized Type: Left Paren\t\tValue: %s\n", yytext);
								return LEFT_PAREN;
							}
[a-zA-Z][0-9]*				{	
								lookup(yytext);
								printf("Recognized Type: Variable\t\tValue: %s\n", yytext);
								return VARIABLE;
							}
":="						{	
								printf("Recognized Type: Assignment\t\tValue: %s\n", yytext);
								return ASSIGNMENT;
							}
"TO"|"to"					{
								printf("Recognized Type: to\t\t\tValue: %s\n", yytext);
								return TO;
							}
t/o[a-zA-Z0-9]+				{ }
"STEP"|"step"				{ 
								printf("Recognized Type: step\t\t\tValue: %s\n", yytext);
								return STEP;
							}
s/tep[a-zA-Z0-9]+			{ }
")"							{
								printf("Recognized Type: Right Paren\t\tValue: %s\n", yytext);
								return RIGHT_PAREN;
							}
"DO"|"do"					{
								printf("Recognized Type: do\t\t\tValue: %s\n", yytext);
								return DO;
							}
d/o[a-zA-Z0-9]+				{ }
"DONE"|"done"				{
								printf("Recognized Type: done\t\t\tValue: %s\n", yytext);
								return DONE;
							}
d/one[a-zA-Z0-9]+			{ }
"IF"|"if"					{
								printf("Recognized Type: if\t\t\tValue: %s\n", yytext);
								return IF;
							}
i/f[a-zA-Z0-9]+				{ }
"THEN"|"then"				{
								printf("Recognized Type: then\t\t\tValue: %s\n", yytext);
								return THEN;
							}
t/hen[a-zA-Z0-9]+			{ }
"FI"|"fi"					{
								printf("Recognized Type: fi\t\t\tValue: %s\n", yytext);
								return FI;
							}
f/i[a-zA-Z0-9]+				{ }
"WHILE"|"while"				{
								printf("Recognized Type: while\t\t\tValue: %s\n", yytext);
								return WHILE;
							}
w/hile[a-zA-Z0-9]+			{ }
"=="|"!="|">"|">="|"<"|"<="	{
								printf("Recognized Type: Relational Operator\tValue: %s\n", yytext);
								return RELOPERATOR;
							}
"+"|"-"|"*"|"/"				{
								printf("Recognized Type: Arithmetic Operator\tValue: %s\n", yytext);
								return ARITHOPERATOR;
							}
"PRINT"|"print"				{
								printf("Recognized Type: print\t\t\tValue: %s\n", yytext);
								return PRINT;
							}
p/rint[a-zA-Z0-9]+			{ }
. 							{ }
\n { }
%%
int compare (const void * a, const void * b)
{
  return ( *(int*)a - *(int*)b );
}

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

main(int argc, char **argv)
{
	int token;
	while(token = yylex())
	{
		/* Do stuff with token here */
	}
	int i;
	qsort(symbolTable, TABLE_SIZE, sizeof(struct variable), symcompare);
	printf("\nSymbol Table\n");
	for(i = 0; i < 10; i++)
	{
		struct variable *vp = &symbolTable[i];
		printf("Variable name: %s\ttype: %s\tvalue: %s\n", vp->name, vp->type, vp->value);
		//Print symbol table
	}
}



