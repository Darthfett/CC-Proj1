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
    
    table->table = (struct ht_node_t **) malloc(sizeof(struct ht_node_t *) * size);
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

struct ht_item_t* get_hashtable_item(struct hash_table_t *hashtable, char *key)
{
    struct ht_node_t *node;
    int hashed_key = hash(hashtable, key);
    
    for(node = hashtable->table[hashed_key]; node != NULL; node = node->next) {
        if (strcmp(key, node->key) == 0) {
            return node->value;
        }
    }
    
    return NULL;
}

int insert_item(struct hash_table_t *hashtable, char *key, struct ht_item_t *value, int value_type)
{
	// The default return value is 0 not found.
	int rval = 0;
	do
	{
		// struct ht_node_t *node; // Necessary for handling of 'value already exists'
		struct ht_node_t *new_node;
		int hashed_key = hash(hashtable, key);

		if (get_hashtable_item(hashtable, key) == NULL) {
			// value already exists
			assert(!"Hash table already contains value for key, no mechanism implemented to handle this scenario.");
			break; // we do not want to add this ke in because it already exists.
		}

		new_node = (struct ht_node_t*) malloc(sizeof(struct ht_node_t));
		strcpy(new_node->key, key);
		new_node->value = value;

		new_node->next = hashtable->table[hashed_key];
		hashtable->table[hashed_key] = new_node;
		// we have added the new tag into the structure so we are good
		rval = 1;
	} while (0);
	return rval;
}

// remove_item(struct hash_table_t* table, char *key

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

