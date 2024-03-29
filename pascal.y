%{
/*
 * grammar.y
 *
 * Pascal grammar in Yacc format, based originally on BNF given
 * in "Standard Pascal -- User Reference Manual", by Doug Cooper.
 * This in turn is the BNF given by the ANSI and ISO Pascal standards,
 * and so, is PUBLIC DOMAIN. The grammar is for ISO Level 0 Pascal.
 * The grammar has been massaged somewhat to make it LALR.
 */

#include "shared.h"
#include "rulefuncs.h"
#include "usrdef.h"
#include <assert.h>

  int yylex(void);
  void yyerror(const char *error);

  extern char *yytext;          /* yacc text variable */
  extern int line_number;       /* Holds the current line number; specified
				   in the lexer */
  struct program_t *program;    /* points to our program */
%}

%token AND ARRAY ASSIGNMENT CLASS COLON COMMA DIGSEQ
%token DO DOT DOTDOT ELSE END EQUAL EXTENDS FUNCTION
%token GE GT IDENTIFIER IF LBRAC LE LPAREN LT MINUS MOD NEW NOT
%token NOTEQUAL OF OR PBEGIN PLUS PRINT PROGRAM RBRAC
%token RPAREN SEMICOLON SLASH STAR THEN
%token VAR WHILE

%type <tden> type_denoter
%type <id> result_type
%type <id> identifier
%type <idl> identifier_list
%type <fdes> function_designator
%type <apl> actual_parameter_list
%type <apl> params
%type <ap> actual_parameter
%type <vd> variable_declaration
%type <vdl> variable_declaration_list
%type <r> range
%type <un> unsigned_integer
%type <fpsl> formal_parameter_section_list
%type <fps> formal_parameter_section
%type <fps> value_parameter_specification
%type <fps> variable_parameter_specification
%type <va> variable_access
%type <as> assignment_statement
%type <os> object_instantiation
%type <ps> print_statement
%type <e> expression
%type <s> statement
%type <ss> compound_statement
%type <ss> statement_sequence
%type <ss> statement_part
%type <is> if_statement
%type <ws> while_statement
%type <e> boolean_expression
%type <iv> indexed_variable
%type <ad> attribute_designator
%type <md> method_designator
%type <iel> index_expression_list
%type <e> index_expression
%type <se> simple_expression
%type <t> term
%type <f> factor
%type <i> sign
%type <p> primary
%type <un> unsigned_constant
%type <un> unsigned_number
%type <at> array_type
%type <cb> class_block
%type <vdl> variable_declaration_part
%type <fdl> func_declaration_list
%type <funcd> function_declaration
%type <fb> function_block
%type <fh> function_heading
%type <id> function_identification
%type <fpsl> formal_parameter_list
%type <cl> class_list
%type <ci> class_identification
%type <program> program
%type <ph> program_heading
%type <op> relop
%type <op> addop
%type <op> mulop

%union {
  struct type_denoter_t *tden;
  char *id;
  struct identifier_list_t *idl;
  struct function_designator_t *fdes;
  struct actual_parameter_list_t *apl;
  struct actual_parameter_t *ap;
  struct variable_declaration_list_t *vdl;
  struct variable_declaration_t *vd;
  struct range_t *r;
  struct unsigned_number_t *un;
  struct formal_parameter_section_list_t *fpsl;
  struct formal_parameter_section_t *fps;
  struct variable_access_t *va;
  struct assignment_statement_t *as;
  struct object_instantiation_t *os;
  struct print_statement_t *ps;
  struct expression_t *e;
  struct statement_t *s;
  struct statement_sequence_t *ss;
  struct if_statement_t *is;
  struct while_statement_t *ws;
  struct indexed_variable_t *iv;
  struct attribute_designator_t *ad;
  struct method_designator_t *md;
  struct index_expression_list_t *iel;
  struct simple_expression_t *se;
  struct term_t *t;
  struct factor_t *f;
  int *i;
  struct primary_t *p;
  struct array_type_t *at;
  struct class_block_t *cb;
  struct func_declaration_list_t *fdl;
  struct function_declaration_t *funcd;
  struct function_block_t *fb;
  struct function_heading_t *fh;
  struct class_identification_t *ci;
  struct class_list_t *cl;
  struct program_t *program;
  struct program_heading_t *ph;
  int op;
}



%%

program : program_heading semicolon class_list DOT
	{
	
	printf("program : program_heading semicolon class_list DOT \n");
	$$ = (struct program_t*) malloc(sizeof(struct program_t));

	program = $$;
	$$->ph = $1;
	$$->cl = $3;
	}
 ;

program_heading : PROGRAM identifier
	{
	// TODO make sure that this identifier is checked against list of identifiers
	// Change our scope to be within this program
	if ( moveDownToNewScope($2) == NULL ) {
		yyerror("Program Identifier has already been used");
	}
	printf("program_heading : PROGRAM identifier \n");
	$$ = (struct program_heading_t *) malloc(sizeof(struct program_heading_t));
	$$->id = $2;
	}
 | PROGRAM identifier LPAREN identifier_list RPAREN
	{
	// printf("my text = %s\n\n",text.id);
	printf("PROGRAM identifier LPAREN identifier_list RPAREN \n");

	$$ = (struct program_heading_t *) malloc(sizeof(struct program_heading_t));
	$$->id = $2;
	$$->il = $4;
	}
 ;

identifier_list : identifier_list comma identifier
        {
		printf("identifier_list : identifier_list comma identifier \n%s",yytext);
		$$ = (struct identifier_list_t*) malloc(sizeof(struct identifier_list_t));
		$$->next = $1;
		$$->id = $3;
        }
 | identifier
        {
		printf("identifier_list : identifier \n");
		$$ = (struct identifier_list_t*) malloc(sizeof(struct identifier_list_t));
		$$->next = NULL;
		$$->id = $1;
        }
 ;

class_list : class_list class_identification PBEGIN class_block END
	{
	printf("class_list : class_list class_identification PBEGIN class_block END \n");
	$$ = (struct class_list_t*) malloc(sizeof(struct class_list_t));
	
	$$->next = $1;
	$$->ci = $2;
	$$->cb = $4;
	}
 | class_identification PBEGIN class_block END
	{
	printf("class_list : class_identification PBEGIN class_block END \n");
	$$ = (struct class_list_t*) malloc(sizeof(struct class_list_t));

	$$->next = NULL;
	$$->ci = $1;
	$$->cb = $3;
	}
 ;

class_identification : CLASS identifier
	{
	printf("class_identification : CLASS identifier \n");

	$$ = (struct class_identification_t*) malloc(sizeof(struct class_identification_t));
        // TODO - Create class node
	$$->id = $2;
	$$->extend = NULL;
	$$->line_number = line_number;
	}
| CLASS identifier EXTENDS identifier
	{
	printf("class_identification : CLASS identifier EXTENDS identifier \n");

	$$ = (struct class_identification_t*) malloc(sizeof(struct class_identification_t));
        // TODO - Create class node
        // TODO - Verify identifier as class node
	$$->id = $2;
	$$->extend = $4;
	$$->line_number = line_number;
	}
;

class_block : variable_declaration_part func_declaration_list
	{
	printf("class_block : variable_declaration_part func_declaration_list \n");
	$$ = (struct class_block_t*) malloc(sizeof(struct class_block_t));

	$$->vdl = $1;
	$$->fdl = $2;
	}
 ;

type_denoter : array_type
	{
	printf("type_denoter : array_type \n");

        $$ = (struct type_denoter_t*) malloc(sizeof(struct type_denoter_t));
	$$->type = TYPE_DENOTER_T_ARRAY_TYPE;
	
	// $$->name = ?;
	$$->data.at = $1;

	}
 | identifier
	{
	
	printf("type_denoter : identifier \n");
        $$ = (struct type_denoter_t*) malloc(sizeof(struct type_denoter_t));
        // TODO - determine if identifier is a class, or base type (e.g. integer or boolean)
	// $$->type = ?;
	}
 ;

array_type : ARRAY LBRAC range RBRAC OF type_denoter
	{
	printf("array_type : ARRAY LBRAC range RBRAC OF type_denoter \n");
	$$ = (struct array_type_t*) malloc(sizeof(struct array_type_t));
	$$->r = $3;
	$$->td = $6;
	}
 ;

range : unsigned_integer DOTDOT unsigned_integer
	{
	printf("range : unsigned_integer DOTDOT unsigned_integer\nValue1 = %i\nValue2 = %i\n",$1->ui,$3->ui);
	$$ = (struct range_t*) malloc(sizeof(struct range_t));
	$$->min = $1;
	$$->max = $3;
	// TODO: verify min <= max ?
	}
 ;

variable_declaration_part : VAR variable_declaration_list semicolon
	{
	printf("variable_declaration_part : VAR variable_declaration_list semicolon \n");
        $$ = (struct variable_declaration_list_t*) malloc(sizeof(struct variable_declaration_list_t));

        // $$->vd = ?;
        $$->next = $2;
	}
 |
	{
	printf("variable_declaration_part :  \n");
        $$ = (struct variable_declaration_list_t*) malloc(sizeof(struct variable_declaration_list_t));

	$$->vd = NULL;
	$$->next = NULL;
	}
 ;

variable_declaration_list : variable_declaration_list semicolon variable_declaration
	{
	printf("variable_declaration_list : variable_declaration_list semicolon variable_declaration \n");
        $$ = (struct variable_declaration_list_t*) malloc(sizeof(struct variable_declaration_list_t));
	$$->next = $1;

	$$->vd = $3;
	}
 | variable_declaration
	{
	printf("variable_declaration_list : variable_declaration \n");
        $$ = (struct variable_declaration_list_t*) malloc(sizeof(struct variable_declaration_list_t));
	$$->next = NULL;
	$$->vd = $1;
	}

 ;

variable_declaration : identifier_list COLON type_denoter
	{
	printf("variable_declaration : identifier_list COLON type_denoter \n");
        $$ = (struct variable_declaration_t*) malloc(sizeof(struct variable_declaration_t));
	$$->il = $1;
	$$->tden = $3;
	$$->line_number = line_number;
	}
 ;

func_declaration_list : func_declaration_list semicolon function_declaration
	{
	printf("func_declaration_list : func_declaration_list semicolon function_declaration \n");
	$$ = (struct func_declaration_list_t*) malloc(sizeof(struct func_declaration_list_t));
	$$->next = $1;
	$$->fd = $3;
	}
 | function_declaration
	{
	printf("func_declaration_list : function_declaration \n");
	$$ = (struct func_declaration_list_t*) malloc(sizeof(struct func_declaration_list_t));
	$$->next = NULL;
	$$->fd = $1;
	}
 |
	{
	printf("func_declaration_list :  \n");
	$$ = (struct func_declaration_list_t*) malloc(sizeof(struct func_declaration_list_t));

	$$->next = NULL;
	$$->fd = NULL;
	}
 ;

formal_parameter_list : LPAREN formal_parameter_section_list RPAREN 
	{
	printf("formal_parameter_list : LPAREN formal_parameter_section_list RPAREN  \n");
        $$ = (struct formal_parameter_section_list_t*) malloc(sizeof(struct formal_parameter_section_list_t));
        $$->fps = NULL;
        $$->next = $2;
	}
;
formal_parameter_section_list : formal_parameter_section_list semicolon formal_parameter_section
	{
	printf("formal_parameter_section_list : formal_parameter_section_list semicolon formal_parameter_section \n");
        $$ = (struct formal_parameter_section_list_t*) malloc(sizeof(struct formal_parameter_section_list_t));
	$$->next = $1;
	$$->fps = $3;
	}
 | formal_parameter_section
	{
	printf("formal_parameter_section_list : formal_parameter_section \n");
        $$ = (struct formal_parameter_section_list_t*) malloc(sizeof(struct formal_parameter_section_list_t));
	$$->next = NULL;
	$$->fps = $1;
	}
 ;

formal_parameter_section : value_parameter_specification
	{
	printf("formal_parameter_section : value_parameter_specification \n");
        $$ = $1;
	}
 | variable_parameter_specification
 	{
	printf("formal_parameter_section : variable_parameter_specification \n");
        $$ = $1;
 	}
 ;

value_parameter_specification : identifier_list COLON identifier
	{
	// The previous rule has nothing that needs to be done?
	printf("value_parameter_specification : identifier_list COLON identifier \n");
        $$ = (struct formal_parameter_section_t*) malloc(sizeof(struct formal_parameter_section_t));
        $$->il = $1;
	$$->id = $3;
        $$->is_var = 0;
	}
 ;

variable_parameter_specification : VAR identifier_list COLON identifier
	{
	printf("variable_parameter_specification : VAR identifier_list COLON identifier \n");
        $$ = (struct formal_parameter_section_t*) malloc(sizeof(struct formal_parameter_section_t));
        $$->il = $2;
        $$->id = $4;
        $$->is_var = 1;

	}
 ;

function_declaration : function_identification semicolon function_block
	{
	printf("function_declaration : function_identification semicolon function_block \n");
        $$ = (struct function_declaration_t*) malloc(sizeof(struct function_declaration_t));
        $$->fh = NULL;
        $$->fb = $3;
        $$->line_number = line_number;

	}
 | function_heading semicolon function_block
	{
	printf("function_declaration : function_heading semicolon function_block \n");
        $$ = (struct function_declaration_t*) malloc(sizeof(struct function_declaration_t));
        $$->fh = $1;
        $$->fb = $3;
        $$->line_number = line_number;

	}
 ;

function_heading : FUNCTION identifier COLON result_type
	{
	printf("function_heading : FUNCTION identifier COLON result_type \n");
        $$ = (struct function_heading_t*) malloc(sizeof(struct function_heading_t));
        $$->id = $2;
        $$->res = $4;
        $$->fpsl = NULL;
	}
 | FUNCTION identifier formal_parameter_list COLON result_type
	{
	printf("function_heading : FUNCTION identifier formal_parameter_list COLON result_type \n");
        $$ = (struct function_heading_t*) malloc(sizeof(struct function_heading_t));
        $$->id = $2;
        $$->res = $5;
        $$->fpsl = $3;
	}
 ;

result_type : identifier
	{
	printf("result_type : identifier \n");
        $$ = $1;
	}
 ;

function_identification : FUNCTION identifier
	{
	printf("function_identification : FUNCTION identifier \n");
        $$ = $2;
	}
;

function_block : variable_declaration_part statement_part
	{
	printf("function_block : variable_declaration_part statement_part \n");
        $$ = (struct function_block_t*) malloc(sizeof(struct function_block_t));
        $$->vdl = $1;
        $$->ss = $2;
	}
;

statement_part : compound_statement
	{
	printf("statement_part : compound_statement \n");
        $$ = $1;
	}
 ;

compound_statement : PBEGIN statement_sequence END
	{
	printf("compound_statement : PBEGIN statement_sequence END \n");
        $$ = $2;
	}
 ;

statement_sequence : statement
	{
	printf("statement_sequence : statement \n");
        $$ = (struct statement_sequence_t*) malloc(sizeof(struct statement_sequence_t));
        $$->s = $1;
        $$->next = NULL;
	}
 | statement_sequence semicolon statement
	{
	printf("statement_sequence : statement_sequence semicolon statement \n");
        $$ = (struct statement_sequence_t*) malloc(sizeof(struct statement_sequence_t));
        $$->s = $3;
        $$->next = $1;
	}
 ;

statement : assignment_statement
	{
	printf("statement : assignment_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));
        $$->data.as = $1;
        $$->type = STATEMENT_T_ASSIGNMENT;
        $$->line_number = line_number;
	}
 | compound_statement
	{
	printf("statement : compound_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));
        $$->data.ss = $1;
        $$->type = STATEMENT_T_SEQUENCE;
        $$->line_number = line_number;
	}
 | if_statement
	{
	printf("statement : if_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));
        $$->data.is = $1;
        $$->type = STATEMENT_T_IF;
        $$->line_number = line_number;
	}
 | while_statement
	{
	printf("statement : while_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));
        $$->data.ws = $1;
        $$->type = STATEMENT_T_WHILE;
        $$->line_number = line_number;
	}
 | print_statement
        {
	printf("statement : print_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));
        $$->data.ps = $1;
        $$->type = STATEMENT_T_PRINT;
        $$->line_number = line_number;
        }
 ;

while_statement : WHILE boolean_expression DO statement
	{
	printf("while_statement : WHILE boolean_expression DO statement \n");
        $$ = (struct while_statement_t*) malloc(sizeof(struct while_statement_t));
        $$->e = $2;
        $$->s = $4;
	}
 ;

if_statement : IF boolean_expression THEN statement ELSE statement
	{
	printf("if_statement : IF boolean_expression THEN statement ELSE statement \n");
        $$ = (struct if_statement_t*) malloc(sizeof(struct if_statement_t));
        $$->e = $2;
        $$->s1 = $4;
        $$->s2 = $6;
	}
 ;

assignment_statement : variable_access ASSIGNMENT expression
	{
	printf("assignment_statement : variable_access ASSIGNMENT expression \n");
        $$ = (struct assignment_statement_t*) malloc(sizeof(struct assignment_statement_t));
        $$->va = $1;
        $$->e = $3;
        $$->oe = NULL;
	}
 | variable_access ASSIGNMENT object_instantiation
	{
	printf("assignment_statement : variable_access ASSIGNMENT object_instantiation \n");
        $$ = (struct assignment_statement_t*) malloc(sizeof(struct assignment_statement_t));
        $$->va = $1;
        $$->e = NULL;
        $$->oe = $3;
	}
 ;

object_instantiation: NEW identifier
	{
	printf("object_instantiation: NEW identifier \n");
        $$ = (struct object_instantiation_t*) malloc(sizeof(struct object_instantiation_t));
        $$->id = $2;
        $$->apl = NULL;
	}
 | NEW identifier params
	{
	printf("object_instantiation: NEW identifier params \n");
        $$ = (struct object_instantiation_t*) malloc(sizeof(struct object_instantiation_t));
        $$->id = $2;
        $$->apl = $3;
	}
;

print_statement : PRINT variable_access
        {
	printf("print_statement : PRINT variable_access \n");
        $$ = (struct print_statement_t*) malloc(sizeof(struct print_statement_t));
        $$->va = $2;
        }
;

variable_access : identifier
	{
	printf("variable_access : identifier \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));
        $$->type = VARIABLE_ACCESS_T_IDENTIFIER;
        $$->data.id = $1;
        // $$->recordname = ?
        // $$->expr = ?

	}
 | indexed_variable
	{
	printf("variable_access : indexed_variable \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));
        $$->type = VARIABLE_ACCESS_T_INDEXED_VARIABLE;
        $$->data.iv = $1;

        // $$->recordname = ?
        // $$->expr = ?
	}
 | attribute_designator
	{
	printf("variable_access : attribute_designator \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));
        $$->type = VARIABLE_ACCESS_T_ATTRIBUTE_DESIGNATOR;
        $$->data.ad = $1;

        // $$->recordname = ?
        // $$->expr = ?
	}
 | method_designator
	{
	printf("variable_access : method_designator \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));
        $$->type = VARIABLE_ACCESS_T_METHOD_DESIGNATOR;
        $$->data.md = $1;

        // $$->recordname = ?
        // $$->expr = ?
	}
 ;

indexed_variable : variable_access LBRAC index_expression_list RBRAC
	{
	printf("indexed_variable : variable_access LBRAC index_expression_list RBRAC \n");
        $$ = (struct indexed_variable_t*) malloc(sizeof(struct indexed_variable_t));
        $$->va = $1;
        $$->iel = $3;
        // $$->expr = ?;
	}
 ;

index_expression_list : index_expression_list comma index_expression
	{
	printf("index_expression_list : index_expression_list comma index_expression \n");
        $$ = (struct index_expression_list_t*) malloc(sizeof(struct index_expression_list_t));
        $$->e = $3;
        $$->next = $1;
        // $$->expr = ?;
	}
 | index_expression
	{
	printf("index_expression_list : index_expression \n");
        $$ = (struct index_expression_list_t*) malloc(sizeof(struct index_expression_list_t));
        $$->e = $1;
        $$->next = NULL;
        // $$->expr = ?;
	}
 ;

index_expression : expression
	{
	printf("index_expression : expression \n");
        $$ = $1;
	} ;

attribute_designator : variable_access DOT identifier
	{
	printf("attribute_designator : variable_access DOT identifier \n");
        $$ = (struct attribute_designator_t*) malloc(sizeof(struct attribute_designator_t));
        $$->va = $1;
        $$->id = $3;
	}
;

method_designator: variable_access DOT function_designator
	{
	printf("method_designator: variable_access DOT function_designator \n");
        $$ = (struct method_designator_t*) malloc(sizeof(struct method_designator_t));
        $$->va = $1;
        $$->fd = $3;
	}
 ;


params : LPAREN actual_parameter_list RPAREN 
	{
	printf("params : LPAREN actual_parameter_list RPAREN  \n");
        $$ = (struct actual_parameter_list_t*) malloc(sizeof(struct actual_parameter_list_t));
        $$->ap = NULL;
        $$->next = $2;
	}
 ;

actual_parameter_list : actual_parameter_list comma actual_parameter
	{
	printf("actual_parameter_list : actual_parameter_list comma actual_parameter \n");
        $$ = (struct actual_parameter_list_t*) malloc(sizeof(struct actual_parameter_list_t));
        $$->ap = $3;
        $$->next = $1;
	}
 | actual_parameter 
	{
	printf("actual_parameter_list : actual_parameter \n");
        $$->ap = $1;
        $$->next = NULL;
	}
 ;

actual_parameter : expression
	{
	printf("actual_parameter : expression \n");
        $$ = (struct actual_parameter_t*) malloc(sizeof(struct actual_parameter_t));
        $$->e1 = $1;
        $$->e2 = NULL;
        $$->e3 = NULL;
	}
 | expression COLON expression
	{
	printf("actual_parameter : expression COLON expression \n");
        $$ = (struct actual_parameter_t*) malloc(sizeof(struct actual_parameter_t));
        $$->e1 = $1;
        $$->e2 = $3;
        $$->e3 = NULL;
	}
 | expression COLON expression COLON expression
	{
	printf("actual_parameter : expression COLON expression COLON expression \n");
        $$ = (struct actual_parameter_t*) malloc(sizeof(struct actual_parameter_t));
        $$->e1 = $1;
        $$->e2 = $3;
        $$->e3 = $5;
	}
 ;

boolean_expression : expression
	{
	printf("boolean_expression : expression \n");
        $$ = $1;
	} ;

expression : simple_expression
	{
	printf("expression : simple_expression \n");
        $$ = (struct expression_t*) malloc(sizeof(struct expression_t));
        $$->se1 = $1;
        $$->relop = 0;
        $$->se2 = NULL;
        $$->expr = $1->expr;
	}
 | simple_expression relop simple_expression
	{
	printf("expression : simple_expression relop simple_expression \n");
        $$ = (struct expression_t*) malloc(sizeof(struct expression_t));
        $$->se1 = $1;
        $$->relop = $2;
        $$->se2 = $3;
        // TODO - compute value and type of $$->expr
	}
 ;

simple_expression : term
	{
	printf("simple_expression : term \n");
        $$ = (struct simple_expression_t*) malloc(sizeof(struct simple_expression_t));
        $$->t = $1;
        $$->addop = 0;
        $$->expr = $1->expr;
        $$->next = NULL;
	}
 | simple_expression addop term
	{
	printf("simple_expression : simple_expression addop term \n");
        $$ = (struct simple_expression_t*) malloc(sizeof(struct simple_expression_t));
        $$->t = $3;
        $$->addop = $2;
        // TODO - compute value and type of $$->expr
        $$->next = $1;
	}
 ;

term : factor
	{
	printf("term : factor \n");
        $$ = (struct term_t*) malloc(sizeof(struct term_t));
        $$->f = $1;
        $$->mulop = 0;
        $$->expr = $1->expr;
        $$->next = NULL;
	}
 | term mulop factor
	{
	printf("term : term mulop factor \n");
        $$ = (struct term_t*) malloc(sizeof(struct term_t));
        $$->f = $3;
        $$->mulop = $2;
        // TODO - compute value and type of $$->expr
        $$->next = $1;
	}
 ;

sign : PLUS
	{
	printf("sign : PLUS \n");

	}
 | MINUS
	{
	printf("sign : MINUS \n");

	}
 ;

factor : sign factor
	{
	printf("factor : sign factor\n");
        $$ = (struct factor_t*) malloc(sizeof(struct factor_t));
        $$->type = FACTOR_T_SIGNFACTOR;
        $$->data.f.sign = $1;
        $$->data.f.next = $2;
        // TODO - $$->expr
	}
 | primary 
	{
	printf("factor : primary\n");
        $$ = (struct factor_t*) malloc(sizeof(struct factor_t));
        $$->type = FACTOR_T_PRIMARY;
        $$->data.p = $1;
        // TODO - $$->expr

	}
 ;

primary : variable_access
	{
	printf("primary : variable_access\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));
        $$->type = PRIMARY_T_VARIABLE_ACCESS;
        $$->data.va = $1;
        $$->expr = $1->expr;
	}
 | unsigned_constant
	{
	printf("primary : | unsigned_constant\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));
        $$->type = PRIMARY_T_UNSIGNED_CONSTANT;
        $$->data.un = $1;
        $$->expr = $1->expr;
	}
 | function_designator
	{
	printf("primary : | function_designator\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));
        $$->type = PRIMARY_T_FUNCTION_DESIGNATOR;
        $$->data.fd = $1;
        //$$->expr = $1->expr;
	}
 | LPAREN expression RPAREN
	{
	printf("primary : | LPAREN expression RPAREN\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));
        $$->type = PRIMARY_T_EXPRESSION;
        $$->data.e = $2;
        $$->expr = $2->expr;
	}
 | NOT primary
	{
	printf("primary :  | NOT primary\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));
        $$->type = PRIMARY_T_PRIMARY;
        $$->data.p.next = $2;
        // TODO - $$->expr
	}
 ;

unsigned_constant : unsigned_number
	{
	printf("unsigned_constant : unsigned_number\n");
        $$ = $1;
	}
 ;

unsigned_number : unsigned_integer 
{
	printf("unsigned_number : unsigned_integer\n");
        $$ = $1;
};

unsigned_integer : DIGSEQ
	{
	printf("unsigned_integer : DIGSEQ\nval = %s\n",yytext);
	$$ = (struct unsigned_number_t*) malloc (sizeof(struct unsigned_number_t));
	$$->ui = atoi(yytext);
	}
 ;

/* functions with no params will be handled by plain identifier */
function_designator : identifier params
	{
	printf("function_designator : identifier params\n");
        $$ = (struct function_designator_t*) malloc(sizeof(struct function_designator_t));
        $$->id = $1;
        $$->apl = $2;
	}
 ;

addop: PLUS
	{
	printf("addop: PLUS\n");

	}
 | MINUS
	{
	printf("addop: | MINUS\n");

	}
 | OR
	{
	printf("addop: | OR\n");

	}
 ;

mulop : STAR
	{
	printf("mulop : STAR\n");

	}
 | SLASH
	{
	printf("mulop :  | SLASH\n");

	}
 | MOD
	{
	printf("mulop :  | MOD\n");

	}
 | AND
	{
	printf("mulop :  | AND\n");

	}
 ;

relop : EQUAL
	{
	printf("relop : EQUAL\n");

	}
 | NOTEQUAL
	{
	printf("relop : | NOTEQUAL\n");

	}
 | LT
	{
	printf("relop : | LT\n");

	}
 | GT
	{
	printf("relop : | GT\n");

	}
 | LE
	{
	printf("relop : | LE\n");

	}
 | GE
	{
	printf("relop :  | GE\n");

	}
 ;

identifier : IDENTIFIER
	{
	printf("identifier : IDENTIFIER\nid = %s\n",yytext);
	$$ = (char*) malloc((strlen(yytext) + 1));
	strcpy($$, yytext);
	}
 ;

semicolon : SEMICOLON
	{
	printf("semicolon : SEMICOLON\n");

	}
 ;

comma : COMMA
	{

	printf("comma : COMMA\n");
	}
 ;

%%
