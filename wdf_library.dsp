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
    (0, R) => 0, _*.5; //a0 in, b0 out
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

capacitor_output = 
case{
    (0, R) => b0
    with{
        b0(a1) =  a1*1, a1*.5 + (a1')*.5; 
    };
    (1, R) => _, !; 
    (2, R) => R0
    with {
        R0 = t/(2*R); 
    };
};

//inductors made with BLT
inductor =
case{
    (0, R) => _*(-1); 
    (1, R) => _; 
    (2, R) => R0
    with {
        R0 = t/(2*R); 
    };
};

inductor_output = 
case{
    (0, R) => b0
    with{
        b0(a1) = a1*(-1), a1*.5 - (a1')*.5; 
    };
    (1, R) => _, !; 
    (2, R) => R0
    with {
        R0 = t/(2*R); 
    };
};

//resistive voltage sources
//adapted
resVoltage = 
case{
    (0, R, ein) => R^(1-p)*ein;
    (1, R, ein) => _; 
    (2, R, ein) => R0
    with {
        R0 = R; 
    };
}; 

//unadapted
u_resVoltage =
case {
    (0, R, ein) => b0
    with{
        b0(R0, a0) = a0*(R - R0)/(R+R0) + ein*(2*R0^p)/(R + R0);
    };
    (1, R, ein) => !, !; 
    (2, R, ein) => 0; 

};

//resistive current source 

resCurrent =
case {
    (0, R, jin) => 2*R^(p-1)*jin;
    (1, R, jin) => _; 
    (2, R, jin) => R0
    with {
        R0 = R; 
    };
}; 

u_resCurrent =
case {
    (0, R, jin) => b0
    with{
        b0(R0, a0) = a0*(R - R0)/(R + R0) + jin*(2*R*R0^p)/(R + R0);
    };
    (1, R, jin) => !, !; 
    (2, R, jin) => 0; 

};

//simple unadaptable elements. can only exist as root elements

//voltage source
u_Voltage = 
case{
    (0 , ein) => b0
    with{
        b0(R0, a0) = 2*R0^(p-1)*ein -a0;
    };
    (1, ein) => !, !; 
    (2, ein) => 0; 
};

//current source
u_Current = 
case{
    (0 , iin) => b0
    with{
        b0(R0, a0) = 2*R0^(p)*iin + a0;
    };
    (1, iin) => !, !; 
    (2, iin) => 0; 
};

//switch. 
//lambda = -1 for closed switch, lambda = 1 for open switch
u_Switch = 
case {
    (0, lambda) => b0
    with{
        b0(R0, a0) = a0*lambda; 
    };
    (1, lambda) => !, !; 
    (2, lambda) => 0; 
};

//2 port adaptors
//parallel
u_parallel_2 = 
case{
    (0) => u_par
    with{ 
        u_par = si.bus(4) <: b1, b2;
        b0(R0, R1, a0, a1) = (-a0*(R0-R1) + a1*(2*R0^p*R1^(1-p)))/(R0+R1);
        b1(R0, R1, a0, a1) = (a1*(R0-R1) + a0*(2*R0^(1-p)*R1^p))/(R0+R1);
    };
    (1) => !, !, !, !;
    (2) => 0; 
};

parallel_2 = 
case{
    (0) => par_down
    with{
        par_down = b1; 
        b1(R1, a0, a1) = a0;  
    };
    (1) => par_up
    with{
        par_up = b0; 
        b0(R1, a1) = a1; 
    };
    (2) => R0
    with{
        R0(R1) = R1; 
    };
};

//series/inverter
u_series_2 = 
case{
    (0) => u_ser
    with{ 
        u_ser = si.bus(4) <: b1, b2;
        b0(R0, R1, a0, a1) = (-a0*(R0-R1) - a1*(2*R0^p*R1^(1-p)))/(R0+R1);
        b1(R0, R1, a0, a1) = (a1*(R0-R1) - a0*(2*R0^(1-p)*R1^p))/(R0+R1);
    };
    (1) => !, !, !, !;
    (2) => 0; 
};

series_2 = 
case{
    (0) => ser_down
    with{
        ser_down = b1; 
        b1(R1, a0, a1) = -a0;  
    };
    (1) => ser_up
    with{
        ser_up = b0; 
        b0(R1, a1) = -a1; 
    };
    (2) => R0
    with{
        R0(R1) = R1; 
    };
};

//adapted two ports with subsumed elements

//parallel + current source
parallel_current = 
case{
    (0, jin) => par_current_down
    with{
        par_current_down = b1; 
        b1(R1, a0, a1) = a0 + R1^p*jin;  
    };
    (1, jin) => par_current_up
    with{
        par_current_up = b0; 
        b0(R1, a1) = a1 + R1^p*jin; 
    };
    (2, jin) => R0
    with{
        R0(R1) = R1; 
    };
};

//series + voltage source
series_voltage = 
case{
    (0, vin) => ser_down
    with{
        ser_down = b1; 
        b1(R1, a0, a1) = -a0 - R1^(p-1)*vin;  
    };
    (1, vin) => ser_up
    with{
        ser_up = b0; 
        b0(R1, a1) = -a1 - R1^(p-1)*vin; 
    };
    (2, vin) => R0
    with{
        R0(R1) = R1; 
    };
};

//3 port adaptors
//paralell 3 port
parallel= 
case{
    (0) => par_down
    with{
        par_down = si.bus(5) <: b1, b2;
        b1(R1, R2, a0, a1, a2) = a0 +  a1 * -R1/(R1 + R2) + a2 * R1/(R1 + R2);
        b2(R1, R2, a0, a1, a2) = a0 +  a1 * R2/(R1 + R2) + a2 * -R2/(R1 + R2);
    };
    (1) => par_up
    with{
        par_up = b0;
        b0(R1, R2, a1, a2) = a1 * R2/(R1 + R2) + a2 * R1/(R1 + R2);
    };
    (2) => R0
    with{
        R0(R1, R2) = 1/(1/R1+1/R2); 
    };

};

//series 3 port
series= 
case{

    (0) => ser_down
    with{
        ser_down = si.bus(5)<: b1, b2;
        b1(R1, R2, a0, a1, a2) = a0 * -R1/(R1+R2) + a1 * R2/(R1+R2) + a2 * -R1/(R1+R2);
        b2(R1, R2, a0, a1, a2) = a0 * -R2/(R1+R2) + a1 * -R2/(R1+R2) + a2 *R1/(R1+R2);
    };
    (1) => ser_up
    with{
        ser_up = b0;
        b0(R1, R2, a1, a2) = -a1 - a2;
    };
    (2) => R0
    with{
        R0(R1, R2) = R1 + R2; 
    };
};

//constructor private functions

addins = 
case{
    (0) => 0 : !; 
    (x) => si.bus(x);
};

//downtree constructor
/*
builddown(A: (As1, As2)) = ((_, _, _, upPortRes): A(0)), addins(inputs(builddown(As1), builddown(As2)) - 2 ) : crossover : builddown(As1), builddown(As2)
with{
    crossover = _ , ro.cross1n(inputs(builddown(As1))-1), addins(inputs(builddown(As2))-1);
    upPortRes = getres(As1), getres(As2);
};

builddown(A: As) = (addins(inputs(A(0))-1), upPortRes :  A(0)) , addins(inputs(builddown(As)) - 1) :  builddown(As)
with{
    upPortRes = getres(As);
};


builddown(A) = A(0); 
*/
builddown(A : As) =   ((upPortRes, addins(inputs(A(0)) - outputs(upPortRes))) :  A(0)) , addins(inputs(pardown(As)) - outputs(A(0))) :  pardown(As)
with{
    pardown = 
    case{
        ((Ap1, Ap2)) => crossover : builddown(Ap1), builddown(Ap2)
        with {
            crossover = _ , ro.cross1n(inputs(builddown(Ap1))-1), addins(inputs(builddown(Ap2))-1);
        };
        (Ap) => builddown(Ap);
    }; 
    upPortRes = parres(As);
};

builddown(A) = A(0); 



//uptree constructor
/*
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
*/
//uptree constructor


buildup(A : As) = upPortRes, parup(As) : A(1), addins(outputs(parup(As)) + outputs(upPortRes) - inputs(A(1))) //this currently doesn't always use getres, may be able to simplify it to avoid computation. 
with{
    parup = 
    case {
       ((Ap1, Ap2, Ap3)) => buildup(Ap1) , buildup(Ap2), buildup(Ap3) : crossover
       with{
           crossover = _ , ro.crossn1(outputs(buildup(Ap1)) - 1), ro.crossn1(outputs(buildup(Ap2))-1), addins(outputs(builup(Ap3))-1) : split;
           split(in1, in2, in3) = in1, in2, in3,  in1, in2, in3, addins(outputs(buildup(Ap1)) + outputs(buildup(Ap2)) + outputs(buildup(Ap3)) - 3);
       };
        ((Ap1, Ap2)) => buildup(Ap1), buildup(Ap2) : crossover
        with{
            crossover = _ , ro.crossn1(outputs(buildup(Ap1)) - 1), addins(outputs(buildup(Ap2))-1) : split;
            split(in1, in2) = in1, in2, in1, in2, addins(outputs(buildup(Ap1)) + outputs(buildup(Ap2))-2);
        };
        (Ap1) => buildup(Ap1) : crossover
        with{
            crossover(in1) = in1, in1, addins(outputs(buildup(Ap1))-1);
        };
    };
    upPortRes = parres(As);
};

buildup(A) = A(1);

//resistance contructor. 
//maybe change this to a dynamic programming method as current method involves calculating port resistance for each element many times. 
//getres(A : (As1, As2)) = (getres(As1) , getres(As2)) : A(2); 

getres(A: As) = parres(As) : A(2);
getres(A) = A(2); 

parres((Ap1, Ap2, Ap3, Ap4)) = getres(Ap1) , getres(Ap2), getres(Ap3), getres(Ap4);
parres((Ap1, Ap2, Ap3)) = getres(Ap1) , getres(Ap2), getres(Ap3);
parres((Ap1, Ap2)) = getres(Ap1) , getres(Ap2);
parres(Ap) = getres(Ap);

//consider adding an output constructor. then could just do construct(tree)



//set up our components which have inherent values
vs1(x) = u_resVoltage(x, 100, no.pink_noise);

c1(x) = capacitor_output(x, 10*(10^-10)); 
r1(x) = resistor_output(x, 4.7*10^3); 

//an second order rc filter.
tree2 = vs1 : (parallel : (series : (c1, r1)), (series : (c1, r1))); 
tree1 = vs1 : (series : ((series_2: c1), r1)); 
tree3 = vs1 : (series_2 : c1);


process = builddown(tree2)~buildup(tree2) : !, _, !, _, !, _, !, _; 

