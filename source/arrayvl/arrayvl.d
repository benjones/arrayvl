module arrayvl.arrayvl;

import std.algorithm : max;
import std.stdio;

///For now, a Set ADT, should be easy to turn in to a map or multiset/multimap
struct Arrayvl(T) {
@safe:
private:

struct Node{
    //ubyte nullance; //null and balance, optimization to be done later, maybe, but height seems easier
    byte height = -1; //signed byte, -1 height means null node
    T data;
    @safe:
    @nogc{
        bool isNull() const {
            //return (nullance & 0x80) == 0;
            return height == -1;
        }
        // balance = left - right, so balanced = 0
        // left heavy -> 1, so low 2 bits are 01
        // right heavy -> -1, so the low 2 bits would be 11, with value 3
        /*enum Balance { Balanced = 0, LeftHeavy = 1, RightHeavy = 3}
        Balance balance() const {

        }*/
        void nullify(){
            //nullance = 0;
            height = -1;
        }
        //void setBalance(ubyte balance){ nullance = balance | 0x80; }
        void makeLeaf(T val){
            data = val;
            height = 0;
        }
    }

    string toString() const {
        import std.conv : to;
        return isNull ? "null" : "Node(" ~ to!string(height) ~ " " ~ to!string(data) ~ ")";
    }


}

     //start the Node array off at this size, then scale by GrowthFactor
    enum MinSize = 16;
    enum GrowthFactor = 2;
    Node[] data;

    size_t parentIndex(size_t i) const{ return i == 0 ? 0 : (i -1)/2; }
    size_t leftIndex(size_t i) const{ return 2*i + 1; }
    size_t rightIndex(size_t i) const{ return 2*i + 2; }

    size_t predIndex(size_t i) const {
        i = leftIndex(i);
        while(hasRight(i)){
            i = rightIndex(i);
        }
        return i;
    }

    size_t succIndex(size_t i) const {
        i = rightIndex(i);
        while(hasLeft(i)){
            i = leftIndex(i);
        }
        return i;
    }

    bool hasRight(size_t i) const{
        const ri = rightIndex(i);
        return ri < data.length && !data[ri].isNull;
    }

    bool hasLeft(size_t i) const{
        const li = leftIndex(i);
        return li < data.length && !data[li].isNull;
    }

    bool isLeaf(size_t i) const {
        return !(hasRight(i) || hasLeft(i));
    }

    byte leftHeight(size_t i) const{
        return hasLeft(i) ? data[leftIndex(i)].height : -1;
    }

    byte rightHeight(size_t i) const{
        return hasRight(i) ? data[rightIndex(i)].height : -1;
    }

    byte balance(size_t i) const{
        return cast(byte)(leftHeight(i) - rightHeight(i));
    }

    byte computeHeight(size_t i) const{
        return cast(byte)(max(leftHeight(i), rightHeight(i)) + 1);
    }


    @safe:
    public:

    bool insert(T t){
        return insert(t, 0);
    }


    private bool insert(T t, size_t i){
        writeln("insert ", t, " at index ", i);
        while(true){
            if(i >= data.length){
                //grow "in place", and all future values will have nullance = 0, meaning they are considered "null"
                data.length = max(MinSize, data.length*GrowthFactor);
            }
            if(data[i].isNull()){
                data[i].makeLeaf(t);
                break;
            }
            if(data[i].data == t){
                return false;
            }
            const bal = balance(i);
            if(t < data[i].data){
                //want to go left
                if(bal > 0){
                    //left is taller, insert could break balance

                    //current root = data[i]
                    //steal the predecessor and stick it at i
                    //insert current root right
                    //now continue inserting left
                    assert(0, "not implemented yet");
                }
                i = leftIndex(i);
            } else {
                //want to go right

                if(bal < 0){
                    //but right is too tall already
                    auto currentRoot = data[i].data;

                    auto si = succIndex(i);
                    data[i].data = data[si].data;

                    remove(data[si].data, rightIndex(i));

                    insert(currentRoot, leftIndex(i));


                }
                i = rightIndex(i);
            }
        }

        updateHeight(parentIndex(i));
        return true;
    }

    //todo, auto ref this, probably
    private bool remove(T t, size_t i){
        writeln("remove ", t, " from index ", i);
        while(true){
            writeln("remove, i: ", i);
            if(i >= data.length || data[i].isNull()){
                return false; // not in here
            }
            if(data[i].data == t){
                //assuming we've preemptively made sure removing this won't cause imbalance up the tree
                //if it's not a leaf, we can't just nullify it
                if(isLeaf(i)){
                    data[i].nullify();
                    updateHeight(parentIndex(i));
                    writeln("just deleted a leaf: ", t);
                    printAsTree();
                    return true;
                } else {
                    //steal predecessor/successor, then delete that
                    //pick the taller subtree to delete from
                    //break ties arbitrarily?
                    const lh = leftHeight(i);
                    const rh = rightHeight(i);
                    if(lh > rh){
                        //steal predecessor
                        const pi = predIndex(i);
                        data[i].data = data[pi].data;
                        remove(data[pi].data, leftIndex(i));
                    } else {
                        const si = succIndex(i);
                        data[i].data = data[si].data;
                        remove(data[si].data, rightIndex(i));
                    }
                    writeln("just deleted a non leaf via stealing: ", t);
                    printAsTree();
                    return true;

                }
            }
            const bal = balance(i);
            writeln("balance: ", bal);
            if(t < data[i].data){ //delete from left side
                if(bal < 0){ //left side too short
                    writeln("deleting from left, and it's too short");
                    const oldRoot = data[i].data;
                    //steal successor
                    const si = succIndex(i);
                    data[i].data = data[si].data;
                    remove(data[si].data, rightIndex(i));
                    //insert oldRoot left
                    insert(oldRoot, leftIndex(i));
                }
                i = leftIndex(i);

            } else { //delete from right side
                if(bal > 0){ //right side is shorter, deleting right may cause imbalance here
                    //steal the predecessor from the left side, put it in the root
                    writeln("deleting from right, and it's too short");
                    const oldRoot = data[i].data;
                    const pi = predIndex(i);
                    data[i].data = data[pi].data;
                    remove(data[pi].data, leftIndex(i));
                    //insert the old root
                    insert(oldRoot, rightIndex(i));
                    //then continue deleting
                }
                i = rightIndex(i);
            }
        }
    }

    private void updateHeight(size_t i){
        //percolate height up
        while(true) {
            byte newHeight = computeHeight(i);
            if(newHeight == data[i].height){
                break;
            } else {
                data[i].height = newHeight;
            }
            const par = parentIndex(i);
            if(i == par){
                break;
            }
            i = par;
        }

    }

    string toString() const{
        import std.conv : to;
        return data.to!string();
    }

    void printAsTree() const {
        import std.conv : to;
        auto rowLength = 1;
        auto printedThisRow = 0;
        foreach(i; 0..data.length){
            write(data[i].isNull ? "null" :
                  "(data: " ~ to!string(data[i].data) ~ " height: " ~ to!string(data[i].height) ~ ")",
                  "    ");
            ++printedThisRow;
            if(printedThisRow == rowLength){
                writeln();
                rowLength *= 2;
                printedThisRow = 0;
            }
        }
        writeln();
    }

}

unittest {
    import std.stdio;

    Arrayvl!int tree;
    foreach(i; 0..10){
        assert(tree.insert(i));
        tree.printAsTree();
        writeln("\n\n");
    }
}
