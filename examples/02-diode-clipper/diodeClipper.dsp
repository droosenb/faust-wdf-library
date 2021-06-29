import("stdfaust.lib");
diode_clipper(in1) = wd.buildtree(tree)
with{
    // declare components
    d1(i) = wd.u_diodeAntiparallel(i, 2.52*10^-9, 25.85*10^-3, 1, 1); 
    vin(i) = wd.resVoltage(i, 4700, in1);
    c1(i) = wd.capacitor_Vout(i, 47.0e-9);
    // declare connection tree
    tree = d1 : (wd.parallel : (vin, c1));
};

process = diode_clipper; 
