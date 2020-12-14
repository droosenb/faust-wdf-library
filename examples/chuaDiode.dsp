//Chua's diode circuit
//original circuit featuring Chua's diode taken from Kurt Werner thesis
//for reference, see  Meerkotter and Scholz, "Digital Simulation of Nonlinear Circuits by Wave Digital Filter Principles"
wdf = library("wdmodels.lib");

import("stdfaust.lib");

//create circuit components
c1(i) = wdf.capacitor_output(i, 5.5*10^(-9));
r2(i) = wdf.resistor_output(i, 1.6*10^3); //resistance must be slightly higher than original document, currently unsure why. 
l3(i) = wdf.inductor_output(i, 7.07*10^(-3));
c4(i) = wdf.capacitor_output(i, 49.5*10^(-9));
d1(i) = wdf.u_chua(i, -500*10^-6, -800*10^-6, 1);
//I've added a voltage injection for agitation purposes. the system will always initialize with zeros, so adding an impulse will get oscillations started. 
vInject(i) = wdf.series_voltage(i, button("impulse")*5 : ba.impulsify);

//input tree structure
treeChua =  d1 : (wdf.parallel : (c1, (wdf.series : (r2, (wdf.parallel : (l3, (vInject :c4)))))));


chua = wdf.buildtree(treeChua);   

process = chua;