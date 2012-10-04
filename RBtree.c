/*
 * RBtree.c
 *
 *  Created on: Oct 1, 2012
 *      Author: Joey Angell
 */
#include "RBtree.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define tnull NULL

Node insertNode ( Node p, Node n );
int compare ( Node first, Node second );
Node grandParent ( Node n );
Node getUncle(Node n);
Node fix(Node t, Node n);
void rotateLeft(Node n);
void rotateRight(Node n);
Node findNode(Node root, char * data);

Node insertTree(Node t, char* id);
Node insert(Tree *t,char* scope, char *id)
{
	// Default return value is 0 or failed to insert this node
		Node rval = tnull;
		Node n = createNode(scope);
		do {
			if ( t->root == tnull ) {
				// We do not have anything in our tree yet
				t->root = n;
				t->root->color = BLACK;
				rval = insertTree(n,id);
				break;
			}
			Node temp = findNode(t->root,scope);
			if ( temp == tnull ) {
				n = insertNode( t->root, createNode(scope) );
				if ( n != tnull ) {
					printf("new Tree node added to scopes\n\n");
					printTree(t->root);
					printf("---------------------------------\n");
					t->root=fix(t->root,n);
					rval = insertTree(n,id);
				}
				break;
			}
			n = insertTree(temp,id);

			rval = n;
		} while ( 0 );
		return rval;
}
Node insertTree(Node t, char* id)
{
	// Default return value is 0 or failed to insert this node
	Node rval = tnull;
	Node n = createNode(id);
	do {
		if ( t->root == tnull ) {
			// We do not have anything in our tree yet
			t->root = n;
			t->root->color = BLACK;
			rval = n;
			break;
		}

		n = insertNode( t->root, n );
		if ( n != tnull ) {
			t->root = fix(t->root,n);
		}
	} while ( 0 );
	return rval;
}
void newTree(Tree *t)
{
	t->root = tnull;
}
Node insertNode ( Node p, Node n )
{
	Node rval = tnull;
	do {
		int i = compare(p,n);
		if ( i == 0 ) {
			// we cannot insert the same name twice
			break;
		}
		if ( i > 0 ) {
			if ( p->left == tnull ) {
				p->left = n;
				n->parent = p;
				rval = n; // success
			} else {
				rval = insertNode(p->left,n);
			}
			break;
		}
		if ( i < 0) {
			if ( p->right == tnull ) {
				p->right = n;
				n->parent = p;
				rval = n;
			} else {
				rval = insertNode(p->right, n);
			}
		}
	} while (0);
	return rval;
}

Node fix(Node root, Node n)
{
	Node rval = root;
	Node u, g;
	while ( n->parent != tnull )
	{
		u = getUncle(n);
		g = grandParent(n);

		if ( n->parent->color == BLACK ) {
			break;
		}
		// check what color the Uncle is

		if ( u != tnull && u->color == RED ) {
			n->parent->color = BLACK;
			u->color = BLACK;
			g->color = RED;
			n = g;
			// re-evaluate the current node
			continue;
		}

		if ( (n == n->parent->right) && (n->parent == g->left) )
		{
			rotateLeft(n);
			n = n->left;
		} else if ( (n == n->parent->left) && (n->parent == g->right)) {
			rotateRight(n);
			n = n->right;
		}

		n->parent->color = BLACK;
		g->color = RED;
		if ( n == n->parent->left ) {
			rotateRight(n->parent);
		} else {
			rotateLeft(n->parent);
		}
		n = n->parent;
		break;
	}
	if ( n->parent == tnull ) {
		rval = n;
	}
	rval->color = BLACK;
	return rval;
}
Node grandParent ( Node n )
{
	Node g = tnull;
	do
	{
		if ( n->parent == tnull ) {
			break;
		}
		g = n->parent->parent;
	} while ( 0 );
	return g;
}
Node getUncle(Node n)
{
	Node u = tnull;
	Node g = grandParent(n);
	if ( g != tnull ) {
		if ( n->parent == g->right ) {
			u = g->left;
		} else {
			u = g->right;
		}
	}
	return u;
}

void rotateLeft(Node n)
{
	Node p = n->parent;
	Node g = grandParent(n);
	if ( p != tnull ) {
		p->right = n->left;
		n->left = p;
		n->parent = p->parent;
		if ( g != tnull ) {
			if ( p == g->right ) {
				g->right = n;
			} else {
				g->left = n;
			}
		}
		p->parent = n;
	}
}
void rotateRight(Node n)
{
	Node p = n->parent;
	Node g = grandParent(n);
	if ( p != tnull ) {
		p->left = n->right;
		n->right = p;
		n->parent = p->parent;
		if ( g != tnull ) {
			if ( p == g->right ) {
				g->right = n;
			} else {
				g->left = n;
			}
		}
		p->parent = n;
	}
}
int compare ( Node first, Node second )
{
	// The default return value is 0 or first and second are they are equal
	int i = 0;
	// returns negative than sencond is larger than first. if return value is positive
	// than the first value was larger than the second. If the returne value is 0 then
	// they are the same value.
	i = strcmp(first->data,second->data);
	return i;
}
Node createNode(char * data)
{
	Node rval;
	rval = (Node) malloc(sizeof(struct NODE));
	if ( rval == tnull ) {
		return tnull;
	}
	memset(rval,0,sizeof(rval));

	rval->color = RED;
	rval->parent = tnull;
	rval->left = tnull;
	rval->right = tnull;
	rval->data = data;
	rval->type = tnull;
	rval->root = tnull;
	return rval;
}
Node findNode(Node root, char * data)
{
	Node n = createNode(data);
	Node current = root;
	int diff = -1;
	while ( diff != 0 && current != tnull ) {
		diff = compare(current,n);
		if ( diff < 0 ) {
			current = current->right;
		} else if ( diff > 0 ) {
			current = current->left;
		}
	}
	n = current;
	return n;
}
Node leftMost( Node n)
{
	while ( n->left != tnull ) {
		n = n->left;
	}
	return n;
}
void printNode(Node n)
{
	printf("TAG: %s\nType: %s\nColor: %d\n",n->data,n->type,n->color);
	if ( n->parent == tnull ) {
		printf("parent: null\n");
	} else {
		printf("parent: %s\n",n->parent->data);
	}
	if ( n->left == tnull ) {
		printf ( "left: null\n" );
	} else {
		printf ( "left: %s\n",n->left->data);
	}
	if ( n->right == tnull ) {
		printf ( "right: null\n" );
	} else {
		printf ( "right: %s\n",n->right->data);
	}
	printf("\n");
}
Node nextRightChild(Node n)
{
	while ( n->parent != tnull && n == n->parent->left ) {
		n = n->parent;
		printNode(n);
		if ( n->right != tnull ) {
			return n->right;
		}
	}

	if ( n->parent != tnull && n->right == tnull ) {

		while ( n->parent != tnull && n == n->parent->right ) {
			n = n->parent;
		}
		n = nextRightChild(n);
	}
	return n;
}

void printTree(Node root) {
	Node n = root;
	int done = 0;
	if ( n != tnull ) {
		while ( !done ) {
			n = leftMost(n);
			printNode(n);
			if ( n->right != tnull ) {
				n = n->right;
				continue;
			}
			n = nextRightChild(n);
			if ( n->parent == tnull ) {
				done = 1;
			}
		}
	}
}

Node find(Tree t,char* scope,char * data)
{
	Node rval = tnull;
	do
	{
		Node s = findNode(t.root,scope);
		if ( s == tnull ) {
			break;
		}
		rval = findNode(s->root, data);
	} while (0);
	return rval;
}
