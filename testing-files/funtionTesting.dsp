import("stdfaust.lib");

Fader(in)		= ba.db2linear(vslider("Input %in", -10, -96, 4, 0.1));
Mixer(N,out) 	= hgroup("Output %out", par(in, N, *(Fader(in)) ) :> _ );
Matrix(N,M) 	= tgroup("Matrix %N x %M", par(in, N, _) <: par(out, M, Mixer(N, out)));

funct = _ + 1,  r0
with{
    r0 = 3.14; 
};

funct2(f1) = _, f1 : calc 
with{
    calc(a0, a1, r1) = a0 * (r1 + r0) + a1, r0
    with{
        r0 =  r1*2; 
    };
};
length = 1;
pluckPosition = .5; 

funct3(a , b) = _ + a + b; 




//old attempt at application based WDF
//2 port devices
par_2port(f1) = _ :  f1 : _, ! , r0
with{ 
    r0 = 0 : f1 : !, _; 
};

serVoltage_2port(f1, ein) =  _ + ein : f1 : _ , ! : _ + ein : _, r0
with{
    r1 = 0 : f1 : !, _;
    r0 = r1; 
};


//attempt at reverse stuff

rev_resistor(R, p0) = 0 : p0(R0) : !
with{
    R0 = R; 
};

rev_capacitor(R, p0) =  p0 ~ !
with{
    R0 = R;
};

switchfunct= 
case{
    (0, x) => _, x;
    (1, x) =>  10 + x, _; 
    //(x, y) => _, ; 
};

grabfunct(a : as) = a(1) , as(0); 

f10(x, y) = switchfunct; 


f1 = _ , _ , _; 
f2 = _, _, _; 
//crossover = _, ro.crossn1(2), _, _; 

//casefucnt((Ap1, Ap2)) = Ap1(0) , Ap2(0); 
funct5(switchfunct(x)) =  switchfunct(0, x);

// builddown(A: (As1, As2)) = ((_, _, _, upPortRes): A(0)), addins(inputs(builddown(As1), builddown(As2)) - 2 ) : crossover : builddown(As1), builddown(As2)
// with{ 
    // crossover = _ , ro.cross1n(inputs(builddown{(As1))-1), addins(inputs(builddown(As2))-1);
//     upPortRes = getres(As1), getres(As2);
// };

builddown(A : As) = ((addins(inputs(A(0)) - outputs(upPortRes))), upPortRes :  A(0)) , addins(inputs(pardown(As)) - outputs(A(0))) :  pardown(As)
with{
    pardown = 
    case{
        ((Ap1, Ap2)) => crossover : builddown(Ap1), builddown(Ap2)
        with {
            crossover = _ , ro.cross1n(inputs(builddown(Ap1))-1), addins(inputs(builddown(Ap2))-1);
        };
        (Ap) => builddown(Ap);
    }; 
    upPortRes = getres(As);
};

builddown(A) = A(0); 

sign(x) = (x>0) + -1*(x<0);

addins = 
case{
    (0) => 0 : !; 
    (x) => si.bus(x);
};

//crossover.  feed a matrix with the dimensions of the buss. 
crossover_5(inl) =  par(i, ba.count(inl), ba.selector((ba.subseq(inl, 0, i):> _)*ma.signum(i), (inl:> _))), par(i, ba.count(inl), (!, addins(ba.take(i+1, inl) - 1)));

//split the first n signals from a bus size of s
splitn(n, s) = (si.bus(n) <: si.bus(n), si.bus(n)), (addins(s-n));

funct10 = 
case{
    (0) => 5;
    (1) => 6; 
    (2) => 7; 
};

givezero(f : x) = f(0) ;

array1 = (funct10 : _), (funct10 : _), (funct10 : _);
array2 = funct10, funct10, funct10; 

builddown(A : As) = ((addins(inputs(A(0)) - outputs(upPortRes))), upPortRes :  A(0)) , addins(inputs(pardown(As)) - outputs(A(0))) :  pardown(As)
with{
    pardown = 
    case{
        ((Ap1, Ap2)) => crossover : builddown(Ap1), builddown(Ap2)
        with {
            crossover = _ , ro.cross1n(inputs(builddown(Ap1))-1), addins(inputs(builddown(Ap2))-1);
        };
        (Ap) => builddown(Ap);
    }; 
    upPortRes = getres(As);
};

builddown(A) = A(0); 

process = funct5(switchfunct(5));