import arrayvl.arrayvl;

import std.stdio;
import std.algorithm;
import std.datetime.stopwatch;
import std.container.rbtree;
import std.functional;
import std.math : pow;
import std.meta;
import std.format;
import std.range;

void iotaInsertTest(DS,int n)(){
    static if(is(DS == class)){
        auto ds = new DS();
    } else {
        auto ds = DS();
    }
    foreach(i; 0..n){
        ds.insert(i);
    }
}

void main(string[] args){

    alias types = AliasSeq!(Arrayvl!int, RedBlackTree!int);
    enum toName(T) = T.stringof;
    alias typenames = staticMap!(toName, types);
    enum names = format("%(%s, %)",["N", typenames]);
    writeln(names);

    enum maxN = 20000;
    enum start = 100;
    enum nRange = sequence!((a, n) => cast(int)(pow(1.5,n)*start))().take(10);
    static foreach(n; nRange){{
        const repeats = 10*maxN/n;

        alias evalWithN(alias T) = iotaInsertTest!(T, n);
        alias funcs = staticMap!(evalWithN, types);

        const durations = benchmark!funcs(repeats);

        writeln(n,", ", format("%(%s, %)", durations[].map!(x => x.total!"nsecs"/repeats)));
        }}

}
