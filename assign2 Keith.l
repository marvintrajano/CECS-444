/*Team members: Mark Davis, Keith Farnham*/

%{
#include<stdlib.h>
#include<string.h>
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


int fixQuotes(char* x);
void printrefs();
static int symcompare(const void *xa, const void *xb);
void addref(int lineno, char *filename, char *word, int flags);
static unsigned symhash(char *sym);

int i = 0;

struct symbol { /* a word */
	 char *name;
	 struct ref *reflist;
};
 
 struct ref {
	 struct ref *next;
	 char *filename;
	 int flags;
	 int lineno;
 };
 /* simple symtab of fixed size */
 #define NHASH 9997
 struct symbol symtab[NHASH];
 struct symbol *lookup(char*);
 void addref(int, char*, char*,int);
 char *curfilename; /* name of current input file */

%}

%option noyywrap

%%
[0-9]+       		{printf("Recognized Type: Integer Value: %d\n", atoi(yytext)); return(INTEGER);}
[0-9]*"."[0-9]+ 	{printf("Recognized Type: Real Value: %4.2f\n", atof(yytext)) ; return(REAL); }
"true"|"TRUE"	 	{printf("Recognized Type: Boolean Value: %s\n", yytext); }
"false"|"FALSE"       	{printf("Recognized Type: Boolean Value: %s\n", yytext); }
"if"|"IF"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(IF); }
"then"|"THEN"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(THEN); }
"fi"|"FI"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(FI); }
"for"|"FOR"     	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(FOR); }
"while"|"WHILE"       	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(WHILE); }
"do"|"DO"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(DO); }
"done"|"DONE"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(DONE); }
"to"|"TO"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(TO); }
"step"|"STEP"        	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(STEP); }
"print"|"PRINT"       	{printf("Recognized Type: Keyword Value: %s\n", yytext); return(PRINT); }
"("			{printf("Recognized Type: Left_Paren Value: %s\n", yytext); return(LEFT_PAREN); }
")"			{printf("Recognized Type: Right_Paren Value: %s\n", yytext); return(RIGHT_PAREN); }
":="			{printf("Recognized Type: Assignment Value: %s\n", yytext); return(ASSIGNMENT); }
"=="			{printf("Recognized Type: Reloperator Value: %s\n", yytext); return(RELOPERATOR); }
"!="			{printf("Recognized Type: Reloperator Value: %s\n", yytext); return(RELOPERATOR);}
">"			{printf("Recognized Type: Reloperator Value: %s\n", yytext); return(RELOPERATOR);}
"<"			{printf("Recognized Type: Reloperator Value: %s\n", yytext); return(RELOPERATOR);}
">="			{printf("Recognized Type: Reloperator Value: %s\n", yytext); return(RELOPERATOR);}
"<="			{printf("Recognized Type: Reloperator Value: %s\n", yytext); return(RELOPERATOR);}
[a-zA-Z][0-9]*		{addref(yylineno, curfilename, yytext, 0); printf("Recognized Type: Variable Value: %s\n", yytext); return(VARIABLE); }
"\""[a-zA-Z0-9]*"\"" 	{printf("Recognized Type: String Value: "); fixQuotes(yytext); return(STRING); }
"\'"[a-zA-Z]?"\'"	{printf("Recognized Type: Character Value: "); fixQuotes(yytext); return(CHARACTER); }
"\t"|"\n"|" "|"	"|"+"|"-"|"/"|"\\"|"*"	{};

%%

int fixQuotes(char* x)
{
	int length = strlen(x);;
	int i = 1;
	for(i; i < length-1; i++)
	{
		printf("%c",x[i]);
	}
	printf("\n");
  	return (0);
}

main(int argc, char **argv)
{
  int tok;
  while(tok = yylex()){};
 
 if(argc < 2) { /* just read stdin */
	 curfilename = "(stdin)";
	 yylineno = 1;
	 yylex();
 } else{
	 for(i = 1; i < argc; i++) {
		FILE *f = fopen(argv[i], "r");

		 if(!f) {
			 perror(argv[1]);
			 return (1);
		 }
	 
		 curfilename = argv[i]; /* for addref */
		 yyrestart(f);
		 yylineno = 1;
		 yylex();
		 fclose(f);
	 }
 } 
 
 printrefs();
 
}

/* hash a symbol */
static unsigned symhash(char *sym)
{
	 unsigned int hash = 0;
	 unsigned c;
	 while(c = *sym++) hash = hash*9 ^ c;
	 return hash;
}

struct symbol *lookup(char* sym)
{
	 struct symbol *sp = &symtab[symhash(sym)%NHASH];
	 int scount = NHASH; /* how many have we looked at */
	 while(--scount >= 0) {
		 if(sp->name && !strcmp(sp->name, sym)) return sp;
		 if(!sp->name) { /* new entry */
		 sp->name = strdup(sym);
		 sp->reflist = 0;
		 return sp;
		 }
		 if(++sp >= symtab+NHASH) sp = symtab; /* try the next entry */
	 }
	 fputs("symbol table overflow\n", stderr);
	 abort(); /* tried them all, table is full */
}

void addref(int lineno, char *filename, char *word, int flags)
{
	 struct ref *r;
	 struct symbol *sp = lookup(word);
	 /* don't do dups of same line and file */
	 if(sp->reflist &&
	 sp->reflist->lineno == lineno &&
	 sp->reflist->filename == filename) return;
	 r = malloc(sizeof(struct ref));
	 if(!r) {fputs("out of space\n", stderr); abort(); }
	 r->next = sp->reflist;
	 r->filename = filename;
	 r->lineno = lineno;
	 r->flags = flags;
	 sp->reflist = r;
}

/* print the references
 * sort the table alphabetically
 * then flip each entry's reflist to get it into forward order
 * and print it out
 */
/* aux function for sorting */
static int symcompare(const void *xa, const void *xb)
{
	 const struct symbol *a = xa;
	 const struct symbol *b = xb;
	 if(!a->name) {
		if(!b->name) return 0; /* both empty */
		 return 1; /* put empties at the end */
	 }
	 if(!b->name) return -1;
	 return strcmp(a->name, b->name);
}

void printrefs()
{
	 struct symbol *sp;
	 qsort(symtab, NHASH, sizeof(struct symbol), symcompare); /* sort the symbol table */
	 printf("\nSymbol Table\n");
	 for(sp = symtab; sp->name && sp < symtab+NHASH; sp++) {
		 char *prevfn = NULL; /* last printed filename, to skip dups */
		 /* reverse the list of references */
		 struct ref *rp = sp->reflist;
		 struct ref *rpp = 0; /* previous ref */
		 struct ref *rpn; /* next ref */
		 do {
			 rpn = rp->next;
			 rp->next = rpp;
			 rpp = rp;
			 rp = rpn;
		 } while(rp);
		 
		 /* now print the word and its references */
		
		 printf("Variable name: %s type: Unknown, value: Unknown", sp->name);
		 printf("\n");
	 }
}




