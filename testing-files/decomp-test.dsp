import("stdfaust.lib");

//resistor(r0) = !; 

resistor = 
case {
    (0, R) => !, 0; 
    (1, R) => _; 
    (2, R) => !, R; 
};

u_resistor = 
case {
    (0, R) => !, 0; 
    (1, R) => _; 
    (2, R) => _ + R; 
};

res47k(x) = resistor(x, 46*10^3); //declaring a resistor
u_res47k(x) = u_resistor(x, 46*10^3);

getportres(A : As) = getportres(As) : getportres(A);
getportres(A) = A(2);
getportrespar(A, As) = A(2), getportrespar(As);
getportrespar(A, 0) = A(2); //dont ever do (A, !) - creates stack error

decomp(A : (As1, As2, As3)) = A : (decomp(As1), decomp(As2), decomp(As3));
decomp(A: As) = A: decomp(As);
decomp(A) = A; 

split = _ <: _*2, _*.5, _*3; 

tree = 5 : (split : (((_ + 2) : (_ + 3)), ((_+ 4 ) : (_+5)), (split : (((_ + 2) : (_ + 3)), ((_+ 4 ) : (_+5)), ((_ + 2) : (_ + 3))))));
process = decomp(tree); 
