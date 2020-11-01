import("stdfaust.lib");

//ABOUT THIS LIBRARY
/*
    This library is intended as a tool to help generating function DSP algorithims using Wave Digital Filters (WDF)
    The library includes both port elements with which to build symbolic WDF trees and the tools to turn those trees into DSP algorithims

    a simple use case of this library is shown at the bottom of the library. <- START HERE

    a description of how adaptors are structured is shown at the head of ONE PORT ELEMENTS
    
    a description of how the library builds the DSP algorithim from the user-given tree is shown at the head of //COMPILER/BUILDER

    Many of the more in depth comments within the library include jargon. I plan to create videos detailing the theory of WDF's
    For now I reccomend Kurt Werner's PhD, Virtual analog modeling of audio circuitry using wave digital filters, found here: 
    https://searchworks.stanford.edu/view/11891203    
    I have tried to maintain consistent syntax and notation to the thesis. This library currently includes the majority of the adaptors covered in chapter 1 and some from chapter 3. 
    
    I've included the definitions of some of the jargon/helpful context. 

*/

//SOME HELPFUL WDF TERMS
/*
    downward and upward going waves
    WDF's data/wave direction is often described in terms of downward and upward going waves described reletive to the tree structure. 
    Within the context of typical faust syntax, these can be understood as feedforward waves and feedback waves or forward-going and backward-going waves
    essentially downward-going = feedforward, upward-going = feedback. 

    port resistance
    each element within the tree structure passes a port resistance up to its parent, which the parent uses in calculations. 

*/

//HOW ADAPTORS ARE STRUCTURED
/*
    In order for adaptors to be interpretable by the compiler, they must be structured in a specific way. 
    Each adaptor is divided into three cases by their first parameter. This paramter, while accessible by the user, should only be set by the compiler/builder.
    All other parameters are value declarations (for components), inputs (for voltage or current ins), or parameter controls (for potentiometers/varible capicitors/varible inductors)

    (0, params) => downwardgoing(R1, ... Rn, a0, a1, ... an) --- first case --- function calculating downward going waves (b1, b2, ... bn)
        this function takes any number of port resistances, the downward going wave, and any number of upward going waves as inputs. 
        These values/waves are used to calculate the downward going waves coming from this adaptor

    (1, params) =>  upwardgoing(R1, ... Rn, a1, ... an) --- second case --- funciton calculating upward going wave (b0)
        this funciton takes any number of port resistances and any number of upward going waves as inputs
        these values/waves are used to calculate the upward going wave coming from this adaptor

    (2, params) => portresistance(R1, ... Rn) --- third case --- function calculating adaptor's port resitance (R0)
        this function takes any number of port resistances as inputs
        these values are used to calculate the upward going port resistance of the element

*/

//ONE PORT ELEMENTS
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
        R0 = (2*R)/t; 
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
        R0 = (2*R)/t; 
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

//NON-LINEAR ADAPTORS (1-PORT)

//ideal diode
u_idealDiode =
case{
    (0) => b1
    with{
        b1(R1, a0) = a0 : abs : *(-1);
    };
    (1) => !, !; 
    (2) => 0; 
};

//chua's diode, for use in chaotic oscillators
//currently not behaving correctly
u_chua = 
case{
    (0, G1, G2, V0) => b1
    with{
        b1(R1, a0) = g_1*a0 + 1/2*(g_2 - g_1)*(((a0 + a_0) : abs) - ((a0 - a_0): abs))
        with{
            g_1 = (1-G1*R1)/(1+G1*R1);
            g_2 = (1-G2*R1)/(1+G1*R1);
            a_0 = V0*(1+G2*R1);
        };
    };
    (1, G1, G2, V0) => !, !; 
    (2, G1, G2, V0) => 0; 
};

lambert(x) = x* (x : exp); //lambert function for schotkey ideal diode
sign(x) = (x>0) + -1*(x<0); //sign function. replaced by ma.signum


//simple diode pair as outlined in Werner
//params: Is = saturation current, Vt = thermal voltage
u_diode_pair = 
case{
    (0, Is, Vt) => b1
    with{
        b1(R1, a1) = a1 + 2*R1*Is - 2*Vt*lambert(R1*Is/Vt*(((a1+R1*Is)/Vt) : exp));
    };
    (1, Is, Vt) => !, !; 
    (2, Is, Vt) => 0; 
};

//single diode as outlined in Werner
u_diode_single = 
case{
    (0, Is, Vt) => b1
    with{
        b1(R1, a1) = ma.signum(a1)*( (a1 : abs) + 2*R1*Is - 2*Vt*(lambert(R1*Is/Vt*((((a1 : abs)+R1*Is)/Vt) : exp)) + lambert(-R1*Is/Vt*(((-1*(a1 : abs)+R1*Is)/Vt) : exp))));
    };
    (1, Is, Vt) => !, !; 
    (2, Is, Vt) => 0; 
};

//2 PORT ADAPTORS

//parallel/echo/pass
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

//3 PORT ADAPTORS

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

//constant declrations for library. don't alter these (for now)
p = 1; //declare voltage waves. 
t = 1/ma.SR; //sampling rate reference for reactive elements


//constructor private functions
addins = 
case{
    (0) => 0 : !; 
    (x) => si.bus(x);
};

//downtree constructor
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
getres(A: As) = parres(As) : A(2);
getres(A) = A(2); 

parres((Ap1, Ap2, Ap3, Ap4)) = getres(Ap1) , getres(Ap2), getres(Ap3), getres(Ap4);
parres((Ap1, Ap2, Ap3)) = getres(Ap1) , getres(Ap2), getres(Ap3);
parres((Ap1, Ap2)) = getres(Ap1) , getres(Ap2);
parres(Ap) = getres(Ap);


//TODO
//add input and output constructor. currently just performed manually. 
//this will likely include adding additional param options. 

//TESTING SECTION. NOT PART OF FINAL LIB. 

//set up our components which have inherent values
vs1(x) = u_Voltage(x, no.pink_noise);
vsin(x) = u_Voltage(x, _);

c1(x) = capacitor_output(x, 10*(10^-9)); 
r1(x) = resistor_output(x, 4.7*10^3); 

//some simple trees for testing
tree1 = vs1 : (series : ((series_2: c1), r1)); 
tree2 = vs1 : (series_2 : c1);

//second order lowpass/highpass filter tree
tree4 = vs1: (series : (r1, (parallel : (c1, (series : (c1, r1))))));
tree5 = vsin: (series : (r1, (parallel : (c1, (series : (c1, r1))))));

//second order hp/lp filter mono-in
//output 1 - first order high-pass
//output 2 - first order low-pass
//output 3 - second order low-pass
//output 4 - second order high-pass
order2_in = (_, ro.crossn1(6) : builddown(tree5))~buildup(tree5) : !, _, !, _, !, _, !, _; 

//second order hp/lp filter with pink noise input
order2_noise = builddown(tree4)~buildup(tree4) : !, _, !, _, !, _, !, _;

//chua's diode circuit
//original circuit featuring chua's diode taken from Kurt Werner thesis

//create initial components
c1(i) = capacitor_output(i, 5.5*10^(-9));
r2(i) = resistor_output(i, 1.428*10^3);
l3(i) = inductor_output(i, 7.07*10^(-3));
c4(i) = capacitor_output(i, 49.5*10^(-9));
d1(i) = u_chua(i, -500*10^-6, -800*10^-6, 1);
vInject(i) = series_voltage(i, button("impulse")*5 : ba.impulsify);

//input tree structure
treeChua =  d1 : (parallel : (c1, (series : ((vInject : r2), (parallel : (l3, c4))))));

//process = builddown(treeChua)~buildup(treeChua): !, _, !, _, !, _, !, _;   

process = u_diode_pair(0, 2.52*10-9, 25.85*10^-6);
