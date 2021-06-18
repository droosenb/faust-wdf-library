import("stdfaust.lib");

tonestack(in1) = wd.buildtree(tree)
with{
    r1p(i) = wd.resistor(i, 250*10^3-pot1+.00001);
    r1m(i) = wd.resistor_Vout(i, pot1+.00001);
    r2(i) = wd.resistor_Vout(i, pot2+.00001);
    r3p(i) = wd.resistor_Vout(i, 25*10^3-pot3+.00001);
    r3m(i) = wd.resistor_Vout(i, pot3+.00001);
    r4(i) = wd.resistor(i, 56*10^3);
    c1(i) = wd.capacitor(i, .25*10^-9);
    c2(i) = wd.capacitor(i, 20*10^-9);
    c3(i) = wd.capacitor(i, 20*10^-9);

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

    vIn(i) = wd.resVoltage(i, .00001, in1);

    pot1 = hslider("treble", 5, 0, 10, .01)*250*10^2;
    pot2 = hslider("bass", 5, 0, 10, .01)*1*10^5;
    pot3 = hslider("mids", 5, 0, 10, .01)*25*10^2;

    tree = u_6port : ((wd.series : (r3m, vIn)), r4, c3, (wd.series : (r3p, r2)), c2, (wd.series : (c1, (wd.series : (r1p, r1m)))));
};

genericNode =
case{
    (0, scatter, upRes) => down(inputs(scatter))
    with{
        down(1) = scatter; //leaf node case
        down(n) = scatter : !, bus(outputs(scatter)-1); //internal node case
    };
    (1, scatter, upRes) => up(inputs(scatter))
    with{
        up(1) = _; //leaf node case
        up(n) = bus(inputs(upRes)), 0 , bus(outputs(scatter)-1) : scatter : _, block(outputs(scatter)-1); //internal node case
    };
    (2, scatter, upRes) => upRes;
}
with{
    bus(0) = 0:!;
    bus(x) = si.bus(x);
    block(0) = 0:!;
    block(x) = si.block(x);
};

genericNode_output_V =
case{
    (0, scatter, upRes) => _ <: b, voltage
    with{
        b(a) = a : scatter;
        voltage(a) = 1/2*(a + b(a)');
    };
    (1, scatter, upRes) => _, !;
    (2, scatter, upRes) => upRes;
};

genericNode_output_I =
case{
    (0, scatter, upRes) => _ <: b, current
    with{
        b(a) = a : scatter;
        current(a) = 1/2/upRes*(a - b(a)');
    };
    (1, scatter, upRes) => _, !;
    (2, scatter, upRes) => upRes;
};


u_genericNode =
case{
    (0, scatter) => scatter;
    (1, scatter) => block(inputs(scatter));
    (2, scatter) => 1000;
}
with{
    block(0) = 0:!;
    block(x) = si.block(x);
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

process = _ : tonestack : _*-1, _, _*-1, _ :> _ ;

// process(Cv, a, b, c, d) = capacitorMobius(0, Cv, a, b, c, d), wd.capacitor_output(0, Cv);