import("stdfaust.lib");

wdf = library("waveDigitalFilters.lib");
wnl = library("nonlinearwdf.lib");

vinA(i) = wdf.u_resVoltage(i, 1, _);
c2(i) = wdf.capacitor(i, 1*10^-6);
vB(i) = wdf.resVoltage_output(i, 10*10^3, 4.5);
rA(i) = wdf.resistor(i, 220);

tree_a = vinA : wdf.series : (c2, (wdf.series : (rA, vB))); 
stage_a = ((_, ro.crossn1(4)): wdf.builddown(tree_a))~wdf.buildup(tree_a) : !, !, !, _;

vinB(i) = wdf.u_voltage(i, _);
c3(i) = wdf.capacitor(i, .047*10^-6);
r4(i) = wdf.resistor_output_current(i, 4.7*10^3);

tree_b = vinB : wdf.series : (c3, r4); 
stage_b = ((_, ro.crossn1(2)): wdf.builddown(tree_b))~wdf.buildup(tree_b) : !, !, _;

pot1 = hslider("distortion 0 - 500k", 250, 0, 500, .1);
jinC(i) = wdf.resCurrent(i, 51*10^3+pot1*10^3, _);
d1(i) = wnl.u_diode_antiparallel(i, 2.52*10^-9, 25.85*10^-3, 1, 1); 
c4(i) = wdf.capacitor_output(i, 41*10^-12);

tree_c = d1 : wdf.parallel : (c4, jinC); 
stage_c = wdf.builddown(tree_c)~wdf.buildup(tree_c);

ingain = hslider("input gain", 1, 0, 20, .01);


process =  _/100*ingain : stage_a <: _, stage_b * ba.toggle(button("on")): _, stage_c: _, !, _, ! : _ - _ - 4.5 <: _, _ ; 
