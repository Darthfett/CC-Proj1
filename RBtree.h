/*
 * RBtree.h
 *
 *  Created on: Oct 1, 2012
 *      Author: Joey Angell
 */

#ifndef RBTREE_H_
#define RBTREE_H_

enum node_color { RED, BLACK };
typedef struct NODE {
	struct NODE *parent;
	struct NODE *left;
	struct NODE *right;
	enum node_color	color;
	char *data;
	char *type;
	struct NODE *root;
} *Node;

typedef struct TREE {
	Node root;
} Tree;

Node insert(Tree *t,char*scope ,char* id);
Node createNode(char * data);
Node find(Tree t,char* scope,char * data);
void printTree(Node root);
void newTree(Tree *t);

#endif /* RBTREE_H_ */
