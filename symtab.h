/* symtab.h
 *
 * Holds function definitions for the symbol table. The symbol table
 * is implemented as a global hash table that contains local symbol
 * tables for each function
 */

#ifndef SYMTAB_H
#define SYMTAB_H

#include "shared.h"
#include "usrdef.h"
#include <stdlib.h>
#include <string.h>



/* ----------------------------------------------------------------
 * Function declarations
 * ----------------------------------------------------------------
 */


void symtab_init();
void symtab_print(int numOfTabs);
struct hash_table_t* new_hash_table(int size);
int hash(struct hash_table_t *hashtable, char *key);
void* get_hashtable_item(struct hash_table_t *hashtable, char *key);
int insert_item(struct hash_table_t *hashtable, char *key, void *value, int value_type);

struct ht_item_t {
    char *key;
    void *value;
    int value_type;
    struct ht_item_t *next;
};

struct hash_table_t {
    int size;
    struct ht_item_t **table;
};



#endif
