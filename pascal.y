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
	program = $$;
	$$->ph = $1;
	$$->cl = $3;
	}
 ;

program_heading : PROGRAM identifier
	{
	$$->id = $2;
	}
 | PROGRAM identifier LPAREN identifier_list RPAREN
	{
	$$->id = $2;
	$$->il = $4;
	}
 ;

identifier_list : identifier_list comma identifier
        {
	$$->next = $1;
	$$->id = $3;
        }
 | identifier
        {
	$$->next = NULL;
	$$->id = $1;
        }
 ;

class_list: class_list class_identification PBEGIN class_block END
	{
	$$->next = $1;
	$$->ci = $2;
	$$->cb = $4;
	}
 | class_identification PBEGIN class_block END
	{
	$$->next = NULL;
	$$->ci = $1;
	$$->cb = $3;
	}
 ;

class_identification : CLASS identifier
	{
	$$->id = $2;
	$$->extend = NULL;
	$$->line_number = line_number;
	}
| CLASS identifier EXTENDS identifier
	{
	$$->id = $2;
	$$->extend = $4;
	$$->line_number = line_number;
	}
;

class_block:
 variable_declaration_part
 func_declaration_list
	{
	$$->vdl = $1;
	$$->fdl = $2;
	}
 ;

type_denoter : array_type
	{
	// 1 - array_type
	// 2 - class_type
	// 3 - base_type
	$$->type = 1;
	
	// $$->name = ?;
	$$->data.at = $1;

	}
 | identifier
	{
	// $$->type = ?;
	}
 ;

array_type : ARRAY LBRAC range RBRAC OF type_denoter
	{
	$$->r = $3;
	$$->td = $6;
	}
 ;

range : unsigned_integer DOTDOT unsigned_integer
	{
	$$->min = $1;
	$$->max = $3;
	// TODO: verify min <= max ?
	}
 ;

variable_declaration_part : VAR variable_declaration_list semicolon
	{
	$$->vd = $2->vd;
	$$->next = $2->next;
	}
 |
	{
	$$->vd = NULL;
	$$->next = NULL;
	}
 ;

variable_declaration_list : variable_declaration_list semicolon variable_declaration
	{
	$$->next = $1;
	$$->vd = $3;
	}
 | variable_declaration
	{
	$$->next = NULL;
	$$->vd = $1;
	}

 ;

variable_declaration : identifier_list COLON type_denoter
	{
	$$->il = $1;
	$$->tden = $3;
	$$->line_number = line_number;
	}
 ;

func_declaration_list : func_declaration_list semicolon function_declaration
	{
	$$->next = $1;
	$$->fd = $3;
	}
 | function_declaration
	{
	$$->next = NULL;
	$$->fd = $1;
	}
 |
	{
	$$->next = NULL;
	$$->fd = NULL;
	}
 ;

formal_parameter_list : LPAREN formal_parameter_section_list RPAREN 
	{
	// ?
	//printf(typeof($$) + "\n");
	}
;
formal_parameter_section_list : formal_parameter_section_list semicolon formal_parameter_section
	{
	$$->next = $1;
	$$->fps = $3;
	}
 | formal_parameter_section
	{
	$$->next = NULL;
	$$->fps = $1;
	}
 ;

formal_parameter_section : value_parameter_specification
 | variable_parameter_specification
 ;

value_parameter_specification : identifier_list COLON identifier
	{
	// The previous rule has nothing that needs to be done?

	// $$->next = ?
	$$->id = $3;
	}
 ;

variable_parameter_specification : VAR identifier_list COLON identifier
	{

	}
 ;

function_declaration : function_identification semicolon function_block
	{

	}
 | function_heading semicolon function_block
	{

	}
 ;

function_heading : FUNCTION identifier COLON result_type
	{

	}
 | FUNCTION identifier formal_parameter_list COLON result_type
	{

	}
 ;

result_type : identifier ;

function_identification : FUNCTION identifier
	{

	}
;

function_block : 
  variable_declaration_part
  statement_part
	{

	}
;

statement_part : compound_statement
 ;

compound_statement : PBEGIN statement_sequence END
	{

	}
 ;

statement_sequence : statement
	{

	}
 | statement_sequence semicolon statement
	{

	}
 ;

statement : assignment_statement
	{

	}
 | compound_statement
	{

	}
 | if_statement
	{

	}
 | while_statement
	{

	}
 | print_statement
        {

        }
 ;

while_statement : WHILE boolean_expression DO statement
	{

	}
 ;

if_statement : IF boolean_expression THEN statement ELSE statement
	{

	}
 ;

assignment_statement : variable_access ASSIGNMENT expression
	{

	}
 | variable_access ASSIGNMENT object_instantiation
	{

	}
 ;

object_instantiation: NEW identifier
	{

	}
 | NEW identifier params
	{

	}
;

print_statement : PRINT variable_access
        {

        }
;

variable_access : identifier
	{

	}
 | indexed_variable
	{

	}
 | attribute_designator
	{

	}
 | method_designator
	{

	}
 ;

indexed_variable : variable_access LBRAC index_expression_list RBRAC
	{

	}
 ;

index_expression_list : index_expression_list comma index_expression
	{

	}
 | index_expression
	{

	}
 ;

index_expression : expression ;

attribute_designator : variable_access DOT identifier
	{

	}
;

method_designator: variable_access DOT function_designator
	{

	}
 ;


params : LPAREN actual_parameter_list RPAREN 
	{

	}
 ;

actual_parameter_list : actual_parameter_list comma actual_parameter
	{

	}
 | actual_parameter 
	{

	}
 ;

actual_parameter : expression
	{

	}
 | expression COLON expression
	{

	}
 | expression COLON expression COLON expression
	{

	}
 ;

boolean_expression : expression ;

expression : simple_expression
	{

	}
 | simple_expression relop simple_expression
	{

	}
 ;

simple_expression : term
	{

	}
 | simple_expression addop term
	{

	}
 ;

term : factor
	{

	}
 | term mulop factor
	{

	}
 ;

sign : PLUS
	{

	}
 | MINUS
	{

	}
 ;

factor : sign factor
	{

	}
 | primary 
	{

	}
 ;

primary : variable_access
	{

	}
 | unsigned_constant
	{

	}
 | function_designator
	{

	}
 | LPAREN expression RPAREN
	{

	}
 | NOT primary
	{

	}
 ;

unsigned_constant : unsigned_number
 ;

unsigned_number : unsigned_integer ;

unsigned_integer : DIGSEQ
	{

	}
 ;

/* functions with no params will be handled by plain identifier */
function_designator : identifier params
	{

	}
 ;

addop: PLUS
	{

	}
 | MINUS
	{

	}
 | OR
	{

	}
 ;

mulop : STAR
	{

	}
 | SLASH
	{

	}
 | MOD
	{

	}
 | AND
	{

	}
 ;

relop : EQUAL
	{

	}
 | NOTEQUAL
	{

	}
 | LT
	{

	}
 | GT
	{

	}
 | LE
	{

	}
 | GE
	{

	}
 ;

identifier : IDENTIFIER
	{
	return yytext;
	}
 ;

semicolon : SEMICOLON
 ;

comma : COMMA
 ;

%%
