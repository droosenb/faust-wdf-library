import("stdfaust.lib");



//seq(i, ba.count(mtx), (addins(i), ro.cross1n(ba.subseq(mtx, 0, i) :> _*ma.signum(i)), addins(ba.subseq(mtx, i, ba.count(mtx)):> _-1 )))

crossover_bad(mtx, bus) = par(i, ba.count(mtx), (select(bus, i), addins(ba.take(i+1-ma.signum(i), mtx)-1))), addins(ba.take(ba.count(mtx), mtx))
with{
    select(bus, i) = bus : ba.selector(i, outputs(bus));
};

crossover(mtx) = bottom
with{
    top = (1, 1), par(i, ba.count(mtx)-1, (i+2, mtxsum(ba.subseq(mtx, 0, i+1))+1)); //generate the routed crossover points
    mtxsum(t_mtx) = sum(i, ba.count(t_mtx), ba.take(i+1, t_mtx));
    top_mtx = 1, par(i, ba.count(mtx)-1, (mtxsum(ba.subseq(mtx, 0, i+1))+1));
    bottom = par(i, (mtxsum(mtx) - ba.count(mtx)), ((ba.count(mtx)+1+i), ba.take(1 , ba.take(i, (complement(top_mtx, mtxsum(mtx)))))));
};

complement(mtx, N) = par(i, ba.count(mtx)-1, between((ba.take(i+2, mtx) - ba.take(i+1, mtx) -1), i)), par(g, N - ba.take(ba.count(mtx), mtx)+1, (ba.take(ba.count(mtx), mtx) + g + 1))
with{
    between = 
    case{
        (0, i) => 0 : !; 
        (x, i) => par(h,  x, ba.take(i+1, mtx)+h+1);
    };
};

crossover_seq(mtx) = seq(i, ba.count(mtx), (addins((i)), ro.cross1n(ba.subseq(mtx, 0, i) :> (_-1)*ma.signum(i)), addins(ba.subseq(mtx, i, ba.count(mtx)-i):> _ - (i/2:int))));

gencross = 
case{
    ((0), (xs, xxs)) => (1, 1), gencross((2, xs+1, ba.count((xs, xxs))-1, mtxsum((xs, xxs))), (xs, xxs));
    //((out, next, norm_index, spec_index, sum), (xs, xxs))
    ((next, next, count, fcount, msum), (xs, xxs)) => (fcount, out), gencross((out+1, next + xs, count-1, fcount+1,  msum), (xxs));
    ((out, next, count, fcount, msum), (xs, xxs)) => (count+(out), out), gencross((out+1, next, count, fcount, msum), (xs, xxs));
    ((out, next, count, fcount, msum), (xxs)) => (count+(out), out), gencross((out+1, next, count, fcount, msum), (xxs));
    ((msum, next, count, fcount, msum), (xxs)) => (count+msum, msum);
}
with{
     mtxsum(t_mtx) = sum(i, ba.count(t_mtx), ba.take(i+1, t_mtx));
};

gencross = 
case{
    (0, 0, 0, 0, 0, (1, 1)) => 1, 1, 2, 2; 
    (0, 0, 0, 0, 0, (xs, xxs)) => (1, 1), gencross(2, xs+1, ba.count((xs, xxs))-1, 2, mtxsum((xs, xxs)), xxs);
    (0, 0, 0, 0, 0, 0) => 0: !;
    (0, 0, 0, 0, 0, x) => si.bus(x);
    //((out, next, norm_index, spec_index, sum), (xs, xxs))

    (msum, msum, count, fcount, msum, xs) => (fcount, msum);  //output is a special output
    (msum, next, count, fcount, msum, xs) => (msum, msum-count); //escape case, reached end of bus

    (out, out, count, fcount, msum, (xs, xxs)) => (fcount, out), gencross(out+1, xs+out, count-1, fcount+1, msum, xxs);
    (out, out, count, fcount, msum, xs) => (fcount, out), gencross(out+1, xs+out, count-1, fcount+1, msum, 0);  //output is a special output

    (out, next, count, fcount, msum, xs) => ((count+out), out), gencross(out+1, next, count, fcount, msum, xs); //output is not a special output

};

gencross_up = 
case{
    (0, 0, 0, 0, 0, (1, 1)) => 1, 1, 2, 2; 
    (0, 0, 0, 0, 0, (xs, xxs)) => (1, 1), gencross_up(2, xs+1, ba.count((xs, xxs))-1, 2, mtxsum((xs, xxs)), xxs);
    (0, 0, 0, 0, 0, 0) => 0: !;
    (0, 0, 0, 0, 0, x) => par(i, x, i+1, i+1);
    //((out, next, norm_index, spec_index, sum), (xs, xxs))

    (msum, msum, count, fcount, msum, xs) => (msum, fcount);  //output is a special output
    (msum, next, count, fcount, msum, xs) => (msum-count, msum); //escape case, reached end of bus

    (out, out, count, fcount, msum, (xs, xxs)) => (out, fcount), gencross_up(out+1, xs+out, count-1, fcount+1, msum, xxs);
    (out, out, count, fcount, msum, xs) => (out, fcount), gencross_up(out+1, xs+out, count-1, fcount+1, msum, 0);  //output is a special output

    (out, next, count, fcount, msum, xs) => (out, (count+out)), gencross_up(out+1, next, count, fcount, msum, xs); //output is not a special output

};

mtxsum(t_mtx) = sum(i, ba.count(t_mtx), ba.take(i+1, t_mtx));


test_rec=
case{
    ((x, x)) => x;
    ((y, x)) => y, test_rec((y+1, x)); 
    ((x)) => test_rec((0, x));
};

test_mtx = (1, 1);

test((next, next, count, fcount, msum), (xs, xxs)) = (fcount, next), gencross((next+1, next+xs, count-1, fcount+1, msum), xxs);

// process = test((1, 1, 4, 5, 6), test_mtx);

process =   gencross((2, 3, 4)) ;