import("stdfaust.lib");

wdf = library("wavedigitalfilters.lib");

//second order rc filter with pink noise input

//first, set up our components which have inherent values
vs1(x) = wdf.u_voltage(x, no.pink_noise);

c1(x) = wdf.capacitor(x, 10*(10^-9)); 
r1(x) = wdf.resistor(x, 4.7*10^3); 
c2(x) = wdf.capacitor_output(x, 10*(10^-9));
r2(x) = wdf.resistor_output(x, 4.7*10^3);

//second, connect the elements in series and parallel to create our tree structure
tree1 = vs1: (wdf.series : (r1, (wdf.parallel : (c1, (wdf.series : (c2, r2))))));

//finally, build the tree using `buildtree` to produce the final function
//the first output will be the low-passed signal, the second output will be the high-passed signal
order2_noise = wdf.buildtree(tree1);




//to allow the function to have an input, we have to make a few changes. 

//first, redeclare our voltage source to have an open input, rather than input from a function
vsin(x) = wdf.u_voltage(x, _);
//second, redeclare our tree using the new input
tree2 = vsin: (wdf.series : (r1, (wdf.parallel : (c1, (wdf.series : (c2, r2))))));

//finally, we must add a crossover to our feedforward function to access the voltage input. 
//in order to access the internals of the feedforward, we use the seperate feedforward function `builddown`
//in this case, our desired input is the third input of vsin, so we cross over the next 6 signals to access it
order2_in = (_, ro.crossn1(6) : wdf.builddown(tree2))~wdf.buildup(tree2) : wdf.buildout(tree2); 

//change process to `order2_in` to run the filter with avalible inputs
process = order2_noise;
