import("stdfaust.lib");

//wd = library("wdmodels.lib");

stage_a(in1) = wd.buildtree(tree_a) 
with{
    vinA(i) = wd.u_resVoltage(i, 1, in1);
    c2(i) = wd.capacitor(i, 1*10^-6);
    vB(i) = wd.resVoltage_Vout(i, 10*10^3, 4.5);
    rA(i) = wd.resistor(i, 220);

    tree_a = vinA : wd.series : (c2, (wd.series : (rA, vB))); 
};

stage_b(in1) = wd.buildtree(tree_b)
with{
    vinB(i) = wd.u_voltage(i, in1);
    c3(i) = wd.capacitor(i, .047*10^-6);
    r4(i) = wd.resistor_Iout(i, 4.7*10^3);

    tree_b = vinB : wd.series : (c3, r4); 
};

stage_c(in1) = wd.buildtree(tree_c)
with{
    pot1 = hslider("distortion 0 - 500k", 250, 0, 500, .1);
    jinC(i) = wd.resCurrent(i, 51*10^3+pot1*10^3, in1);
    d1(i) = wd.u_diodeAntiparallel(i, 2.52*10^-9, 25.85*10^-3, 1, 1); 
    c4(i) = wd.capacitor_Vout(i, 41*10^-12);

    tree_c = d1 : wd.parallel : (c4, jinC); 
};

ingain = hslider("input gain", 1, 0, 1, .01);

inputprotect(in) = in*((in < clip) & (in > -clip)) + clip*(in > clip) + -clip*(in < -clip)
with{
    clip = .016;
}; 

onState = checkbox("ON");
gaincorrect(in) =  in*(onState*-1 + 1)*12 + in;

process =   _*.015*ingain : inputprotect :  stage_a <: _, stage_b * onState: _, stage_c : _ - _ - 4.5 : gaincorrect; 



 