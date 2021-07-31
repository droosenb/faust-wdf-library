#other state space models




#initialize scattering mtx for S
S1 = simplifyArray(S_series(R_C1, R_R1, 1))
#println(latexify(pretty_expr(S1)))
R1 = 0;
C1 = 1;

println(latexify(pretty_expr(S1)))
println(latexify(pretty_expr(simplifyArray(d(S1,0)))))
println(latexify(pretty_expr(simplifyArray(u(S1,0)))))

println("Array P")
#declare P (up-going waves)
P = u(S1, 0)*[C1 0; 0 R1]
P = simplifyArray(P)
println(latexify(pretty_expr(P)))



println("Array Q")
Q = [C1 0; 0 R1]*d(S1, 0)
Q = simplifyArray(Q)
println(latexify(pretty_expr(Q)))

Vs = -1;

U = [Vs             zeros(1, 2)
     zeros(2, 1)    Diagonal(ones(2))]

#initialize model shape
A = simplifyArray(Q*U*P)
println(latexify(pretty_expr(A)))

Vs = 2;

U_ins = [Vs             zeros(1, 2)
         zeros(2, 1)    Diagonal(zeros(2))]

B = simplifyArray(Q*U_ins)
println(latexify(pretty_expr(B)))

#swap Rs and Cs and repeat to confirm struture
#declare P (up-going waves)

S1 = simplifyArray(S_series(R_R1, R_C1, 1))

P = u(S1, 0)*[R1 0; 0 C1]
println("Array P")
P = simplifyArray(P)
println(latexify(pretty_expr(P)))


Q =[R1 0; 0 C1]*d(S1, 0)
println("Array Q")
Q = simplifyArray(Q)
println(latexify(pretty_expr(Q)))

Vs = -1;


U = [Vs             zeros(1, 2)
     zeros(2, 1)    Diagonal(ones(2))]

#initialize model shape
A = simplifyArray(Q*U*P)
println(latexify(pretty_expr(A)))

Vs = 2;

U_ins = [Vs             zeros(1, 2)
         zeros(2, 1)    Diagonal(zeros(2))]

B = simplifyArray(Q*U_ins)
println(latexify(pretty_expr(B)))



simple model test, see p. 77
connection tree Vs : St : ((Pb : (R1, C1)), (Sb : (R2, C2)))


U = [Vs             zeros(1, 6)
     zeros(6, 1)    Diagonal(ones(6))]


Q = [[R1 0; 0 C1]*d(Pb)     zeros(2, 3);
     zeros(2, 3)             [R2 0; 0 C2]*d(Sb)]*R_down([3,3])*d(St, 4)

Q = simplifyArray(Q)

#A
A = simplifyArray(Q*U*P)

Vs = 2;
U_ins = [Vs  zeros(1, 6)
        zeros(6, 1)                     zeros(6, 6)]
#B
B = simplifyArray(Q*U_ins)


println(latexify(pretty_expr(A)))
println(latexify(pretty_expr(B)))


P = u(St, 4)*R_up([3,3])*[ u(Sb, 0)*[C2 0; 0 R2]           zeros(3, 2);
                            zeros(3, 2 )    u(Pb, 0)*[C1 0; 0 R1]]
P = simplifyArray(P)

Vs = -1;

U = [Vs             zeros(1, 6)
     zeros(6, 1)    Diagonal(ones(6))]


Q = [[C1 0; 0 R1]*d(Pb)     zeros(2, 3);
     zeros(2, 3)             [C2 0; 0 R2]*d(Sb)]*R_down([3,3])*d(St, 4)

Q = simplifyArray(Q)

#A
A = simplifyArray(Q*U*P)

Vs = 2;
U_ins = [Vs  zeros(1, 6)
        zeros(6, 1)                     zeros(6, 6)]
#B
B = simplifyArray(Q*U_ins)


println(latexify(pretty_expr(A)))
println(latexify(pretty_expr(B)))
