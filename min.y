%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG	0

#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2

#define STMTLIST 500

typedef struct nodeType {
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;

#define YYSTYPE Node*
	
int tsymbolcnt=0;
int errorcnt=0;
int counter=0; // 반복문용

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;

void DFSTree(Node*);
Node * MakeOPTree(int, Node*, Node*);
Node * MakeLOOPTree(int, Node*, Node*);
Node * MakeNode(int, int);
Node * MakeListTree(Node*, Node*);
Node * MakeIFELSETree(int, Node*, Node*, Node*);
Node * MakeELSEIFTree(int, Node*, Node*);
void codegen(Node* );
void prtcode(int, int);

void	dwgen();
int	gentemp();
void	assgnstmt(int, int);
void	numassgn(int, int);
void	addstmt(int, int, int);
void	substmt(int, int, int);
int		insertsym(char *);
%}

%token	ADD SUB MUL DIV LT GT LE GE EQ NE LP RP LBRACE RBRACE IF ELSE IF_ELSE  ELSEIF LOOP WHILE ASSGN ID NUM STMTEND START END ID2 



%%
program	: START stmt_list END	{ if (errorcnt==0) {codegen($2); dwgen();} }
		;

stmt_list: 	stmt_list stmt 	{$$=MakeListTree($1, $2);}
		|	stmt			{$$=MakeListTree(NULL, $1);}
		| 	error STMTEND	{ errorcnt++; yyerrok;}
		;



com 	:	expr LT expr		{$$=MakeOPTree(LT, $1, $3); }
		|	expr GT expr	{$$=MakeOPTree(GT, $1, $3); }
		| 	expr LE expr   	{$$=MakeOPTree(LE, $1, $3); }
		| 	expr GE expr 	{$$=MakeOPTree(GE, $1, $3); }
		|	expr EQ expr 	{$$=MakeOPTree(EQ, $1, $3); }
		|	expr NE expr 	{$$=MakeOPTree(NE, $1, $3); }
		;

stmt	: 	ID ASSGN expr STMTEND	{ $1->token = ID2; $$=MakeOPTree(ASSGN, $1, $3);}
		| IF LP com RP LBRACE stmt_list RBRACE  {$$=MakeOPTree(IF, $3, $6); }
		| IF LP com RP LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE { $$=MakeIFELSETree( IF_ELSE, $3, $6, $10); }
		| ELSEIF LP com RP LBRACE stmt_list RBRACE { $$=MakeELSEIFTree( ELSEIF, $3, $6 ); }
		| WHILE LP com RP LBRACE stmt_list RBRACE   {$$=MakeLOOPTree(WHILE, $3, $6);}
		;





expr	: 	expr ADD term	{ $$=MakeOPTree(ADD, $1, $3); }
		|	expr SUB term	{ $$=MakeOPTree(SUB, $1, $3); }
		|	term
		;

term	: 	term MUL factor { $$=MakeOPTree(MUL, $1, $3); }
		|	term DIV factor { $$=MakeOPTree(DIV, $1, $3); }
		| 	factor
		;

factor	:	ID		{ /* ID node is created in lex */ }
		|	NUM		{ /* NUM node is created in lex */ }
		;


%%
int main(int argc, char *argv[]) 
{
	printf("\nSample Korean-lang Compiler\n");
	printf("(C) Copyright by SeongMin, MinHyeong, SuJin 2023.\n");
	
	if (argc == 2)
		yyin = fopen(argv[1], "r");
	else {
		printf("Usage: cbu2 inputfile\noutput file is 'a.asm'\n");
		return(0);
		}
		
	fp=fopen("a.s", "w");
	
	yyparse();
	
	fclose(yyin);
	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.s'.\n"); }
}

yyerror(s)
char *s;
{
	printf("%s (line %d)\n", s, lineno);
}


Node * MakeOPTree(int op, Node* operand1, Node* operand2)
{

Node * newnode;
newnode = (Node *)malloc(sizeof (Node));

	if(op == IF){

	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	operand2->brother = NULL;

	}else{
	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	}

	
	return newnode;
}

Node * MakeLOOPTree(int op, Node* operand1, Node* operand2)
{

Node * newnode;
Node * loopnode;
newnode = (Node *)malloc(sizeof (Node));
loopnode = (Node *)malloc(sizeof (Node));

   if(op == WHILE){

   newnode->token = op;
   newnode->tokenval = op;
   newnode->son = loopnode;
   newnode->brother = NULL;

   loopnode->token=LOOP;
   loopnode->tokenval=LOOP;
   loopnode->son=NULL;
   loopnode->brother = operand1;
   operand1->brother = operand2;
   operand2->brother=NULL;

   }

   
   return newnode;
}


Node * MakeIFELSETree(int op, Node* operand1, Node* operand2, Node* operand3)
{
    Node * newnode;
    Node * elsenode;
    newnode = (Node *)malloc(sizeof (Node));
    elsenode = (Node *)malloc(sizeof (Node));

    newnode->token = op;
    newnode->tokenval = op;
    newnode->son = operand1;
    newnode->brother = NULL;
    operand1->brother = operand2;

    elsenode->token = ELSE;
    elsenode->tokenval = ELSE;
    elsenode->son = NULL;
    operand2->brother = elsenode;
    elsenode->brother = operand3;
    operand3->brother = NULL;

    return newnode;
}

Node * MakeELSEIFTree(int op, Node* operand1, Node* operand2)
{
	Node * newnode;
	newnode = (Node *)malloc(sizeof (Node));

	if(op == ELSEIF){

	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	operand2->brother = NULL;
	}else{
	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	}

    return newnode;
}
 	





Node * MakeNode(int token, int operand)
{
Node * newnode;

	newnode = (Node *) malloc(sizeof (Node));
	newnode->token = token;
	newnode->tokenval = operand; 
	newnode->son = newnode->brother = NULL;
	return newnode;
}

Node * MakeListTree(Node* operand1, Node* operand2)
{
Node * newnode;
Node * node;

	if (operand1 == NULL){
		newnode = (Node *)malloc(sizeof (Node));
		newnode->token = newnode-> tokenval = STMTLIST;
		newnode->son = operand2;
		newnode->brother = NULL;
		return newnode;
		}
	else {
		node = operand1->son;
		while (node->brother != NULL) node = node->brother;
		node->brother = operand2;
		return operand1;
		}
	
}




void codegen(Node * root)
{
	DFSTree(root);
}

void DFSTree(Node * n)
{
	if (n==NULL) return;
	DFSTree(n->son);
	prtcode(n->token, n->tokenval);
	DFSTree(n->brother);
	
}

void prtcode(int token, int val)
{
	switch (token) {
	case ID:
		fprintf(fp,"RVALUE %s\n", symtbl[val]);
		break;
	case ID2:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		break;
	case NUM:
		fprintf(fp, "PUSH %d\n", val);
		break;
	case ADD:
		fprintf(fp, "+\n");
		break;
	case SUB:
		fprintf(fp, "-\n");
		break;
	case MUL:
		fprintf(fp, "*\n");
		break;
	case DIV:
		fprintf(fp, "/\n");
		break;
	case IF:
		fprintf(fp, "LABEL OUT\n");
		break;
	case ELSE:
		 fprintf(fp, "GOTO FIN\n");
		 fprintf(fp, "LABEL OUT\n");
		 break;	
	case IF_ELSE:
		fprintf(fp, "LABEL FIN\n");
		break;
	
	
	case LOOP:
		fprintf(fp, "LABEL LOOP\n");
		break;
	case WHILE:
		// 조건 검사하기 -> 조건에 맞으면 다시 "GOTO LOOP"
		fprintf(fp, "GOTO LOOP\n");
		fprintf(fp, "LABEL OUT\n");
		break;

	case LT: // 미만
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS OUT\n");
		fprintf(fp, "GOFALSE OUT\n");
		break;
	case GT: // 초과
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS OUT\n");
		fprintf(fp, "GOFALSE OUT\n");
		break;
	case NE: // 다르다
		fprintf(fp, "-\n");
		fprintf(fp, "GOFALSE OUT\n");
		break;
	case EQ: // 같다
		fprintf(fp, "-\n");
		fprintf(fp, "GOTRUE OUT\n");
		break;
	case LE: // 이하
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS OUT\n");
		break;

	case GE: // 이상
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS OUT\n");
		break;
	
	 
	case ASSGN:
		fprintf(fp, ":=\n");
		break;
	case STMTLIST:
	default:
		break;
	};
}


/*
int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}
*/
void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++) 
		fprintf(fp, "DW %s\n", symtbl[i]);
	fprintf(fp, "END\n");
}
