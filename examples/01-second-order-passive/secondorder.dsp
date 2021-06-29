import("stdfaust.lib");

secondorder(R2, C2, Vin) = wd.buildtree(tree)
with{
    //declare components
    vin(i) = wd.u_voltage(i, Vin);   
    r1(i) = wd.resistor(i, 4700);
    c1(i) = wd.capacitor(i, 47*10^-9);
    r2(i) = wd.resistor(i, R2);
    c2(i) = wd.capacitor_Vout(i, C2);
    //form connection tree
    tree = vin : wd.series : (r1, (wd.parallel : (c1, (wd.series: (r2, c2)))));
};

process = secondorder(4700, 47*10^-9); 

