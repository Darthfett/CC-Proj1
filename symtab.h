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

struct ht_item_t {
    void *value;
    int value_type;
};

struct ht_node_t {
    char *key;
    struct ht_item_t *value;

    struct ht_node_t *next;
};

struct hash_table_t {
    int size;
    struct ht_node_t **table;
};

void symtab_init();
void symtab_print(int numOfTabs);
struct hash_table_t* new_hash_table(int size);
int hash(struct hash_table_t *hashtable, char *key);
struct ht_item_t* get_hashtable_item(struct hash_table_t *hashtable, char *key);
int insert_item(struct hash_table_t *hashtable, char *key, struct ht_item_t *value);
void* findElement(char* id, char* scope);
struct ht_item_t* remote_item(struct hash_table_t *hashtable, char *key);

#endif
