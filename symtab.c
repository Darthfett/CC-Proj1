/* symtab.c
 *
 * Implements the symbol table
 *
 * A flat symbol table is the root of all evil.
 */

#include <assert.h>
#include "symtab.h"
#include "shared.h"

#define SYMBOL_VARIABLE 1
#define SYMBOL_FUNCTION 2


struct hash_table_t* new_hash_table(int size)
{
    struct hash_table_t *table;
    int i;
    
    if (size <= 0) {
        return NULL;
    }
    
    table = (struct hash_table_t*) malloc(sizeof(struct hash_table_t));
    CHECK_MEM_ERROR(table);
    
    table->size = size;
    
    table->table = (struct ht_item_t**) malloc(sizeof(struct ht_item_t*) * size);
    CHECK_MEM_ERROR(table);
    
    for(i = 0; i < size; i++) {
        table->table[i] = NULL;
    }
    
    return table;
}

int hash(struct hash_table_t *hashtable, char *key)
{
    return makekey(key, hashtable->size);
}

void* get_hashtable_item(struct hash_table_t *hashtable, char *key)
{
    struct ht_item_t *item;
    int hashed_key = hash(hashtable, key);
    
    for(item = hashtable->table[hashed_key]; item != NULL; item = item->next) {
        if (strcmp(key, item->key) == 0) {
            return item->value;
        }
    }
    
    return NULL;
}

int insert_item(struct hash_table_t *hashtable, char *key, void *value, int value_type)
{
    // struct ht_item_t *item; // Necessary for handling of 'value already exists'
    struct ht_item_t *new_item;
    int hashed_key = hash(hashtable, key);
    
    if (get_hashtable_item(hashtable, key) == NULL) {
        // value already exists
        assert(!"Hash table already contains value for key, no mechanism implemented to handle this scenario.");
        return -1;
    }
    
    new_item = (struct ht_item_t*) malloc(sizeof(struct ht_item_t));
    strcpy(new_item->key, key);
    new_item->value = value;
    new_item->value_type = value_type;
    
    new_item->next = hashtable->table[hashed_key];
    hashtable->table[hashed_key] = new_item;
    return 0;
}

/* ------------------------------------------------------------
 * Initializes the symbol table
 * ------------------------------------------------------------
 */
void symtab_init()
{


}



/* ------------------------------------------------------------
 * Prints the contents of the symbol table
 * ------------------------------------------------------------
 */
void symtab_print(int numOfTabs)
{


}

