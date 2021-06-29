import("stdfaust.lib");

pultec(in1) = wd.buildtree(tree)
with{
    //resistors and potentiometers
    p_HB_p(i) = wd.resistor(i, (10.0e4 - p_HB_ui + 1));
    p_HB_m(i) = wd.resistor(i, (p_HB_ui + 1));
    p_HBQ(i) = wd.resistor(i, (p_HBQ_ui+1));
    p_LC(i) = wd.resistor(i, (p_LC_ui +1));
    p_HC_p(i) = wd.resistor(i, (1.0e3 - p_HC_ui + 1));
    p_HC_m(i) = wd.resistor(i, (p_HC_ui + 1));
    p_BL(i) = wd.resistor(i, (p_BL_ui + 1));
    r_a(i) = wd.resistor(i, 570);
    r_b(i) = wd.resistor(i, 1.0e3);
    r_c(i) = wd.resistor(i, 75);
    r_d(i) = wd.resistor_Vout(i, 10.0e3);
    //capacitors
    c_HBF(i) = wd.capacitor(i, cl_HBF_ui(0));
    c_HCF(i) = wd.capacitor(i, c_HCF_ui);
    c_LF_a(i) = wd.capacitor(i, c_LF_ui(0));
    c_LF_b(i) = wd.capacitor(i, c_LF_ui(1));
    //inductor
    l_HBF(i) = wd.inductor(i, cl_HBF_ui(1));
    //voltage input
    vin(i) = wd.resVoltage(i, 10, in1);

    //connection tree parts
    tree = u_6port : (a, b, c, d, e, f)
    with{       
        a = wd.series : (p_HC_m, (wd.parallel : (p_LC, c_LF_a)));
        b = wd.series : (p_HC_p, (wd.parallel : (p_HC_m, (wd.series : (c_HCF, r_c))))); 
        c = r_b; 
        d = r_d; 
        e = wd.parallel : (c_LF_b, p_BL); 
        f = wd.series : ((wd.series : (p_HB_p, (wd.parallel : (vin, r_a)))), (wd.parallel : (p_HB_m, (wd.series : (p_HBQ, (wd.series : (l_HBF, c_HBF))))))); 
       
    };

    //approximate a potentiometer position as an audio taper (log) resistance (%)
    log_pot(slider) = 10^(slider/50) - 1; 
    //approximate a potentiometer postion as an inverse log resistance (%)
    invlog_pot(slider) = (slider+1) : log10*50;

    //ui-elements
    p_HB_ui = log_pot(hslider("h:PULTEC PROGRAM EQUALIZER/v:[2]HIGH FREQUENCY/h:[0]KNOBS/[0]BOOST[style:knob]", 0, 0, 100, 1))/100 * 10.0e4;
    p_HC_ui = invlog_pot(hslider("h:PULTEC PROGRAM EQUALIZER/v:[2]HIGH FREQUENCY/h:[0]KNOBS/[1]ATTEN[style:knob]", 0, 0, 100, 1))/100 * 1.0e3;

    p_HBQ_ui = log_pot(hslider("h:PULTEC PROGRAM EQUALIZER/v:[1]BANDWIDTH/ADJUST[style:knob]", 0, 0, 100, 1))/100 * 2.2e3;
    p_BL_ui = log_pot(hslider("h:PULTEC PROGRAM EQUALIZER/v:[0]LOW FREQUENCY/h:[0]KNOBS/[0]BOOST[style:knob]", 0, 0, 100, 1))/100 * 10.0e4;
    p_LC_ui = log_pot(hslider("h:PULTEC PROGRAM EQUALIZER/v:[0]LOW FREQUENCY/h:[0]KNOBS/[1]ATTEN[style:knob]", 0, 0, 100, 1))/100 * 100.0e1;
    cl_HBF_ui = 
    case{
        (0) => (15.0e-9, 15.0e-9, 10.0e-9, 10.0e-9, 6.8e-9, 6.8e-9, 15.0e-9) : ba.selectn(7, switch_HBF); //capacitor switched values
        (1) => (175.0e-3, 100.0e-3, 90.0e-3, 65.0e-3, 35.0e-3, 23.0e-3, 19.0e-3) : ba.selectn(7, switch_HBF);//inductor switched values
        //(3kHz, 4kHz, 5kHz, 6kHz, 10kHz, 12kHz, 16kHz)
        (x) => 5; 
    }with{
        switch_HBF = hslider("h:PULTEC PROGRAM EQUALIZER/v:[2]HIGH FREQUENCY/[1]CPS[style:menu{'3 kHz':0;'4 kHz':1;'5 kHz':2;'6 kHz':3;'10 kHz':4;'12 kHz':5;'16 kHz':6}]", 0, 0, 6, 1);
    };
    c_LF_ui = 
    case{
        (0) => (100.0e-9, 47.0e-9, 22.0e-9, 15.0e-9) : ba.selectn(4, switch_LF); //capacitor switched values
        (1) => (2.2e-6, 1.0e-6, 470.0e-9, 330.0e-9) : ba.selectn(4, switch_LF);//inductor switched values
        //(20hz, 30hz, 60hz, 100hz)
        (x) => 5; 
    }with{
        switch_LF = hslider("h:PULTEC PROGRAM EQUALIZER/v:[0]LOW FREQUENCY/[1]CPS[style:menu{'20 Hz':0;'30 Hz':1;'60 Hz':2;'100 Hz':3}]", 0, 0, 3, 1);
    };
    c_HCF_ui = (47.0e-9, 94.0e-9, 197.0e-9) : ba.selectn(3, switch_HCF) //capacitor switched values
            //(20hz, 30hz, 60hz, 100hz)
    with{
        switch_HCF = hslider("h:PULTEC PROGRAM EQUALIZER/v:[3]ATTEN SELECT/HI-CUT F[style:menu{'20':0;'10':1;'5':2}]", 0, 0, 2, 1);
    };

    u_6port(i) = wd.u_genericNode(i, sixport_scatter)
    with{
        sixport_scatter(Ra, Rb, Rc, Rd, Re, Rf) =  matrix(6, 6, scatter)
        with{
            scatter  =
            case{
                (1, 1) => ((-Ra)*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) 
                        + Rc*(Re*Rf   + Rd*(Re + Rf)) +   Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (1, 2) => (2*Ra*((Rc + Re)*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (1, 3) => (2*Ra*(Rb*Rd + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (1, 4) => (-1)*((2*Ra*(Rb*(Rc + Re) + Rc*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (1, 5) => (2*Ra*(Rb*Rd - Rc*Rf))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (1, 6) => (-1)*((2*Ra*(Rc*Re + Rb*(Rc + Rd + Re)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (2, 1) => (2*Rb*((Rc + Re)*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (2, 2) => (Ra*(Rd*Re - Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) - Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) 
                        + Rc*(Re*Rf + Rd*(Re + Rf)) +   Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (2, 3) => (-1)*((2*Rb*(Ra*Re + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (2, 4) => (-2*Ra*Rb*Re + 2*Rb*Rc*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (2, 5) => (2*Rb*(Ra*(Rc + Rd) + Rc*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (2, 6) => (-1)*((2*Rb*(Rc*Rd + Ra*(Rc + Rd + Re)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (3, 1) => (2*Rc*(Rb*Rd + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (3, 2) => (-1)*((2*Rc*(Ra*Re + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (3, 3) => 1 - (2*Rc*(Rd*Re + Rd*Rf + Re*Rf + Rb*(Rd + Rf) + Ra*(Rb + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (3, 4) => (-1)*((2*Rc*(Rb*Rf + Ra*(Rb + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (3, 5) => (-1)*((2*Rc*(Ra*(Rb + Rf) + Rb*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (3, 6) => (2*Rc*(Rb*Rd - Ra*Re))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (4, 1) => (-1)*((2*Rd*(Rb*(Rc + Re) + Rc*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (4, 2) => (-2*Ra*Rd*Re + 2*Rc*Rd*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (4, 3) => (-1)*((2*Rd*(Rb*Rf + Ra*(Rb + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (4, 4) => 1 - (2*Rd*(Rc*(Re + Rf) + Ra*(Rb + Re + Rf) + Rb*(Rc + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (4, 5) => (-1)*((2*Rd*((Rb + Rc)*Rf + Ra*(Rb + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (4, 6) => (-1)*((2*Rd*((Ra + Rc)*Re + Rb*(Rc + Re)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (5, 1) => (2*Re*(Rb*Rd - Rc*Rf))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (5, 2) => (2*Re*(Ra*(Rc + Rd) + Rc*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (5, 3) => (-1)*((2*Re*(Ra*(Rb + Rf) + Rb*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (5, 4) => (-1)*((2*Re*((Rb + Rc)*Rf + Ra*(Rb + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (5, 5) => 1 - (2*Re*((Rb + Rc)*(Rd + Rf) + Ra*(Rb + Rc + Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (5, 6) => (2*((Rb + Rc)*Rd + Ra*(Rc + Rd))*Re)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (6, 1) => (-1)*((2*(Rc*Re + Rb*(Rc + Rd + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (6, 2) => (-1)*((2*(Rc*Rd + Ra*(Rc + Rd + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (6, 3) => (2*(Rb*Rd - Ra*Re)*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (6, 4) => (-1)*((2*((Ra + Rc)*Re + Rb*(Rc + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))));
                (6, 5) => (2*((Rb + Rc)*Rd + Ra*(Rc + Rd))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (6, 6) => 1 - (2*(Rc*(Rd + Re) + Ra*(Rc + Rd + Re) + Rb*(Rc + Rd + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)));
                (i, j) => 10;
            };
            matrix(M,N,f) = si.bus(N) <: ro.interleave(N,M) : par(n,N, par(m,M,*(f(m+1,n+1)))) :> si.bus(M);
        };
    };
};


capacitorMobius(i, C, aM, bM, cM, dM) = genericNode_output_I(i, f, upPortRes)
with{
    f(a) = a*sF <: _, _'*sB : (_, _, _ :> _)~(_'*sB*sB)
    with{
        sB = (-1)*(aM*dM+bM*cM)/(2*aM*cM);
        sF = (aM*dM-bM*cM)/(2*aM*cM);
    };
    upPortRes = cM/C*aM; 
};

process = no.pink_noise <:  pultec*200 , pultec*200;

// process(Cv, a, b, c, d) = capacitorMobius(0, Cv, a, b, c, d), wd.capacitor_output(0, Cv);