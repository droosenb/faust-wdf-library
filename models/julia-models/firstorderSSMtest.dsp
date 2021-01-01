// Compare first order RC low-pass filter written in direct and state-space forms


import("stdfaust.lib");

wd = library("wdmodels.lib");

//process =  no.pink_noise <: _ , rc_direct(4.7*10^3, 4.7*10^-9); // direct form
//process = no.pink_noise <: _ , rc_ssm(4.7*10^3, 4.7*10^-9);   // state-space form
//Test to compare outputs of the two:
process = 1-1' <: rc_direct(4.7*10^3, 4.7*10^-9), rc_ssm(4.7*10^3, 4.7*10^-9) <: (_-_)*10^8, _, _; // ~0
//process = (_+10)~(_) ;  

// direct form implemented in wdmodels.lib 
rc_direct(R1, C1, in1) = wd.builddown(tree)~wd.buildup(tree) : wd.buildout(tree)
with{

    r1(i) = wd.resistor(i, R1);
    c1(i) = wd.capacitor_output(i, C1);
    vs1(i) = wd.u_voltage(i, in1);

    tree = vs1 : wd.series : (c1, r1);
};

matrix(M,N,f) = si.bus(N) <: ro.interleave(N,M) 
                : par(n,N, par(m,M,*(f(m+1,n+1)))) :> si.bus(M);
                     
vsum(N) = si.bus(2*N) :> si.bus(N); // vector sum of two N-vectors

// State Space Model for Direct Form as derived by julia code
rc_ssm(R1, C1) = si.bus(p) <: D, (Bd : vsum(N)~(A) : C) :> si.bus(q)
// rc_ssm(R1, C1) = _ <: (B : Ad) , si.bus(p) : C + D
//rc_ssm(R1, C1) = B : Ad
with{
    p = 1; // number of inputs
    q = 1; // number of outputs
    N = 1; // number of states

    //correct values into port resistances
    R_C1 = 1/(ma.SR*2*C1);
    R_R1 = R1; 

    a(1,1) = (R_R1-R_C1)/(R_R1+R_C1);  

    b(1,1) = -2*R_C1/(R_R1+R_C1);
    
    c(1,1) = .5*(a(1,1)+1);      

    d(1,1)= .5*b(1,1);

    // We presently also need these catch-all rules (which are not used):
    a(m,n) = 10*m+n;        b(m,n) = a(m,n);
    c(m,n) = a(m,n);        d(m,n) = a(m,n);

    A = matrix(N,N,a);      B = matrix(N,p,b);
    C = matrix(q,N,c);      D = matrix(q,p,d);

    Ad = vsum(N)~(A) : par(i, N, mem);
    Bd = par(i, p, mem) : B;
    Dd = par(i, p, mem) : D; 
};

