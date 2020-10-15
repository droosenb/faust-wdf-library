import("stdfaust.lib");


p = 1; //declare voltage waves. 
t = 1/ma.SR; //sampling rate reference for reactive elements

//resistors

resistor = 
case{
    (0, R) => !, 0; //a0 in, b0 out
    (1, R) => _; //b0 passthru
    (2, R) => R0 //port resistance. may replace this with dynamic allocation for port resistances. 
    with{
        R0 = R; 
    };
};

resistor_output = 
case{
    (0, R) => 0, _; //a0 in, b0 out
    (1, R) => _, !; //b0 passthru
    (2, R) => R0 //port resistance. may replace this with dynamic allocation for port resistances. 
    with{
        R0 = R; 
    };
};



//capacitors made with BLT

capacitor =
case{
    (0, R) => _*1; 
    (1, R) => _; 
    (2, R) => R0
    with {
        R0 = t/(2*R); 
    };
};

//resistive voltage sources

u_resVoltage =
case {
    (0, R, ein) => b0
    with{
        b0(a0, R0) = a0*(R - R0)/(R+R0) + ein*(2*R0^p)/(R + R0);
    };
    (1, R, ein) => !, !; 
    (2, R, ein) => 0; 

};

//3 port adaptors
parallel= 
case{
    (0) => par_down
    with{
        par_down = si.bus(5) <: b1, b2;
        b1(a0, a1, a2, R1, R2) = a0 +  a1 * -R1/(R1 + R2) + a2 * R1/(R1 + R2);
        b2(a0, a1, a2, R1, R2) = a0 +  a1 * R2/(R1 + R2) + a2 * -R2/(R1 + R2);
    };
    (1) => par_up
    with{
        par_up = b0;
        b0(a1, a2, R1, R2) = a1 * R2/(R1 + R2) + a2 * R1/(R1 + R2);
    };
    (2) => R0
    with{
        R0(R1, R2) = 1/(1/R1+1/R2); 
    };

};


series= 
case{

    (0) => ser_down
    with{
        ser_down = si.bus(5)<: b1, b2;
        b1(a0, a1, a2, R1, R2) = a0 * -R1/(R1+R2) + a1 * R2/(R1+R2) + a2 * -R1/(R1+R2);
        b2(a0, a1, a2, R1, R2) = a0 * -R2/(R1+R2) + a1 * -R2/(R1+R2) + a2 *R1/(R1+R2);
    };
    (1) => ser_up
    with{
        ser_up = b0;
        b0(a1, a2, R1, R2) = -a1 - a2;
    };
    (2) => R0
    with{
        R0(R1, R2) = R1 + R2; 
    };
};


addins = 
case{
    (0) => 0 : !; 
    (x) => si.bus(x);
};

//downtree constructor
builddown(A: (As1, As2)) = ((_, _, _, upPortRes): A(0)), addins(inputs(builddown(As1), builddown(As2)) - 2 ) : crossover : builddown(As1), builddown(As2)
with{
    crossover = _ , ro.cross1n(inputs(builddown(As1))-1), addins(inputs(builddown(As2))-1);
    upPortRes = getres(As1), getres(As2);
} ;

builddown(A: As) = (_, upPortRes :  A(0)) , addins(inputs(builddown(As)) - 1) :  builddown(As)
with{
    upPortRes = getres(As);
};


builddown(A) = A(0); 


//uptree constructor
buildup(A : (As1, As2)) = buildup(As1), buildup(As2): crossover: A(1), addins(outputs(buildup(As1))+outputs(buildup(As2)))
with{
    crossover = _ , ro.crossn1(outputs(buildup(As1)) -1), addins(outputs(buildup(As2))-1) : split_addres;
    upPortRes = getres(As1), getres(As2);
    split_addres(in1, in2) = in1, in2, upPortRes, in1, in2, addins(outputs(buildup(As1))+outputs(buildup(As2))-2);
};

buildup(A : As) = buildup(As): crossover : A(1), addins(outputs(buildup(As))) //this currently doesn't always use getres, may be able to simplify it to avoid computation. 
with{
    upPortRes = getres(As);
    crossover(in1) = in1, upPortRes, in1, addins(outputs(buildup(As))-1);
};

buildup(A) = A(1);

//resistance contructor. 
//maybe change this to a dynamic programming method as current method involves calculating port resistance for each element many times. 
getres(A : (As1, As2)) = (getres(As1) , getres(As2)) : A(2); 

getres(A: As) = getres(As) : A(2);

getres(A) = A(2); 

//consider adding an output constructor. then could just do construct(tree)



//set up our components which have inherent values
vs1(x) = u_resVoltage(x, 100, no.pink_noise*.7);

c1(x) = capacitor(x, 10*(10^-9)); 
r1(x) = resistor_output(x, 4.7*10^3); 

//an second order rc filter.
tree2 = vs1 : parallel : (series : c1, r1), (series : c1, r1); 

process = builddown(tree2)~buildup(tree2) : _, !, _, _, !, _;

