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
} *Node;

typedef struct TREE {
	Node root;
} Tree;

int insert(Tree *t,char* tag);
Node createNode(char * data);
Node findNode(Tree t,char * data);
void printTree(Tree t);
void newTree(Tree *t);

#endif /* RBTREE_H_ */
