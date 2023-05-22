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

    size_t parentIndex(size_t i){ return i == 0 ? 0 : (i -1)/2; }
    size_t leftIndex(size_t i){ return 2*i + 1; }
    size_t rightIndex(size_t i){ return 2*i + 2; }

    size_t hasRight(size_t i){
        const ri = rightIndex(i);
        return ri < data.length && !data[ri].isNull;
    }

    size_t hasLeft(size_t i){
        const li = leftIndex(i);
        return li < data.length && !data[li].isNull;
    }


    byte balance(size_t i){
        byte lh = hasLeft(i) ? data[leftIndex(i)].height : -1;
        byte rh = hasRight(i) ? data[rightIndex(i)].height : -1;
        return cast(byte)(lh - rh);
    }

    byte computeHeight(size_t i){
        byte lh = hasLeft(i) ? data[leftIndex(i)].height : -1;
        byte rh = hasRight(i) ? data[rightIndex(i)].height : -1;
        return cast(byte)(max(lh, rh) + 1);
    }

    @safe:
    public:
    bool insert(T t){
        size_t i = 0;
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
            i = (t < data[i].data) ? leftIndex(i) : rightIndex(i);
        }

        //percolate height up
        while(true) {
            i = parentIndex(i);

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
        }
        return true;
    }

    string toString() const{
        import std.conv : to;
        return data.to!string();
    }

}

unittest {
    import std.stdio;

    Arrayvl!int tree;
    foreach(i; 0..5){
        assert(tree.insert(i));
        writeln(tree);
    }
}
