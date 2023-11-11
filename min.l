%{


#include <string.h>
#include "min.tab.h"

#define MAXSYM	100
#define	MAXSYMLEN	20

char symtbl[MAXSYM][MAXSYMLEN];
int lineno=1;
int insertsym();
int maxsym=0;
char s[30];
int temp;

%}



sp		[ \t]
ws		{sp}+
nl		\n
eletter	[A-Za-z]
hletter	[\xb0-\xfe][\xa0-\xfe]
letter	({eletter}|{hletter})
digit	[0-9]
id		{letter}({letter}|{digit})*
number 	[0-9]+\.[0-9]+



%%


{ws}	{/* do nothing */}
{nl}	{lineno++; }

곱하기|"*"|MUL  		{return(MUL); }
나누기|"/"|DIV		{return(DIV); }
더하기|"+"|ADD 		{return(ADD); }
빼기|"-"|SUB		{return(SUB); }

만약|IF			{return(IF);  }
아니면|ELSE 		{return(ELSE);}
아니면만약|ELSEIF	{return(ELSEIF);}

조건동안반복|LOOP		{return(LOOP);}
반복문|WHILE		{return(WHILE);}

"{"|LBRACE		{return(LBRACE);}
"}"|RBRACE		{return(RBRACE);}
"("|LP			{return(LP);}
")"|RP			{return(RP);}

미만|"<"|LT   		{return(LT); }
초과|">"|GT      	{return(GT); }
이하|"<="|LE 		{return(LE); }
이상|">="|GE		{return(GE); }
같다|"=="|EQ		{return(EQ); }
다르다|"!="|NE		{return(NE); }


은|는|:=|ASSGN		{return(ASSGN); }
이다|;|STMTEND	{return(STMTEND); }
시작|START		{return(START); }
끝|END			{return(END); }
{id}			{strcpy(s, yytext); temp=insertsym(s); yylval=MakeNode(ID, temp); return(ID);}
{digit}+		{sscanf(yytext, "%d", &temp); yylval=MakeNode(NUM, temp); return(NUM);}
.				{printf("invalid token %s\n", yytext); }




%%

int insertsym(s)
char *s;
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}