import("stdfaust.lib");

wdf = library("waveDigitalFilters.lib");


//TESTING SECTION. NOT PART OF FINAL LIB. 

//set up our components which have inherent values
vs1(x) = wdf.u_Voltage(x, no.pink_noise);
vsin(x) = wdf.u_Voltage(x, _);

c1(x) = wdf.capacitor_output(x, 10*(10^-9)); 
r1(x) = wdf.resistor_output(x, 4.7*10^3); 

//some simple trees for testing
tree1 = vs1 : (series : ((series_2: c1), r1)); 
tree2 = vs1 : (series_2 : c1);

//second order lowpass/highpass filter tree
tree4 = vs1: (wdf.series : (r1, (wdf.parallel : (c1, (wdf.series : (c1, r1))))));
tree5 = vsin: (wdf.series : (r1, (wdf.parallel : (c1, (wdf.series : (c1, r1))))));

//second order hp/lp filter mono-in
//output 1 - first order high-pass
//output 2 - first order low-pass
//output 3 - second order low-pass
//output 4 - second order high-pass
order2_in = (_, ro.crossn1(6) : wdf.builddown(tree5))~wdf.buildup(tree5) : !, _, !, _, !, _, !, _; 

//second order hp/lp filter with pink noise input
order2_noise = wdf.builddown(tree4)~wdf.buildup(tree4) : !, _, !, _, !, _, !, _;

//chua's diode circuit
//original circuit featuring chua's diode taken from Kurt Werner thesis

//create initial components
c1(i) = wdf.capacitor_output(i, 5.5*10^(-9));
r2(i) = wdf.resistor_output(i, 1.122*10^3);
l3(i) = wdf.inductor_output(i, 7.07*10^(-3));
c4(i) = wdf.capacitor_output(i, 49.5*10^(-9));
d1(i) = wdf.u_chua(i, -500*10^-6, -800*10^-6, 1);
vInject(i) = wdf.series_voltage(i, button("impulse")*5 : ba.impulsify);

//input tree structure
treeChua =  d1 : (wdf.parallel : (c1, (wdf.series : (r2, (wdf.parallel : (l3, (vInject :c4)))))));

//process = builddown(treeChua)~buildup(treeChua): !, _, !, _, !, _, !, _;    


chua = wdf.builddown(treeChua)~wdf.buildup(treeChua);// : !, _, !, _, !, _, !, _;   
 

//

process = chua: !, _, !, _, !, _, !, _;