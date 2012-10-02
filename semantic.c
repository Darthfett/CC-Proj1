/*
 * semantic.c
 *
 * Implements all functions that participate in semantic analysis.
 */


#include "shared.h"
#include "semantic.h"
#include "rulefuncs.h"
#include "usrdef.h"
#include "symtab.h"



/* ----------------------------------------------------------------------- 
 * Carries out semantic analysis on a program
 * ----------------------------------------------------------------------- 
 */
void semantic_analysis(struct program_t *p)
{
  struct class_list_t *temp_cl;
  
  if (p == NULL) {
    printf("p is NULL\n");
  } else {
    printf("p is not NULL\n");
  }
  return;
  temp_cl = p->cl;
  while (temp_cl != NULL) {

    /* process the variable_declaration_list */

    /* process the func_declaration_list */

    temp_cl = temp_cl->next;
  }
}
