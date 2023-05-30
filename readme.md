# ArrayVL Tree

A CS 2420 student asked why we don't use the implicit binary tree representation that we use for heaps for BSTs.  It took me a second to realize that rotations are potentially O(N).  There are some nice features though: no storage for child/parent pointers, and for a balanced BST, I estimate that less than half array slots would be empty, so memory usage might be "probing hash table"-ish.

This is an attempt to create a balanced, AVL-like BST without rotations.  The main idea is to when we want to insert into the heavy side, steal a node from it and insert it into the other side so we don't imbalance it.  I got that idea from single-pass B-Tree algorithms

## Attempt 1: just that

Every time you insert to the taller subtree of a node, steal the predecessor/successor from that side and stick it at the root.  Stick that value in this node and insert the old root value into the other subtree.  Then continue inserting into the side you wanted to.

This guarantees that you will be able to perform the subtree into that side without increasing the height, causing an imbalance (there's at least one open slot)

Delete is similar.  When deleting from the short side, steal a value from the "tall side" and make it the root, insert the old root in the side you're deleting form.  Unlike a normal BST, deleting from an internal node with 1 child now sucks and requires stealing the predecessor/successor, like when deleting an internal node with 2 children

This worked and kept the tree at lg(N) height, but apparently required 2^height operations worst case to maintain the balance (profile trace showed most time was spent in remove).  Inserting N integers in order took O(N^2) time total, so O(N) per insert even with a perpetually short tree...


## Attempt 2: track subtree size

Attempt 2 is to track the size of each subtree so we don't pre-emptively re-balance if there's space to insert into a subtree without making it taller.  I'm hoping this means we do fewer rebalancing operations, and that they're close to the leaves of the tree.
