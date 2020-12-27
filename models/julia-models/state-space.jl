using Latexify;
using LaTeXStrings;
using LinearAlgebra;
using SparseArrays;
using ModelingToolkit;

#Manual Model Test (See p. 77 of notebook)

#simplify all elements of an array
function simplifyArray(arr)
    tmp = Array{Num, 2}(undef, size(arr)[1], size(arr)[2])
    for i = 1:size(arr)[1]
        for j = 1:size(arr)[2]
            tmp[i,j] = simplify(arr[i,j]);
        end
    end
    return tmp
end

set_default(cdot = false)

#preform the same substitution on each element of an array an simplify
function substituteArray(arr, subs)
    tmp = Array{Num, 2}(undef, size(arr)[1], size(arr)[2])
    for i = 1:size(arr)[1]
        for j = 1:size(arr)[2]
            tmp[i,j] = simplify(substitute(arr[i,j], subs));
        end
    end
    return tmp
end

function pretty_array(A::Array{Num, 2}; kw...)
    tmp = Array{Any, 2}(undef, size(A)[1], size(A)[2])
    for i = 1:size(A)[1]
        for j = 1:size(A)[2]
            tmp[i,j] = pretty_expr(A[i,j]; kw...);
        end
    end
    return tmp
end

# Some functions to cleanup equations to make latexify produce good results
function pretty_expr end

# single-argument
pretty_expr(x; kw...) = x
pretty_expr(s::Sym; kw...) = nameof(s)
pretty_expr(f::Function; kw...) = nameof(f)
pretty_expr(x::Num; kw...) = pretty_expr(toexpr(x); kw...)
pretty_expr(ex::Expr; kw...) = Expr(ex.head, pretty_expr.(ex.args; kw...)...)
pretty_expr(eq::Equation; kw...) = Expr(:(=), pretty_expr(eq.lhs; kw...), pretty_expr(eq.rhs; kw...))
pretty_expr(f::Term; kw...) = pretty_expr(f.f, f.args; kw...)


# double-argument
pretty_expr(f, args; kw...) = Expr(:call, pretty_expr(f; kw...), pretty_expr.(args; kw...)...)
pretty_expr(f::Function, args; kw...) = Expr(:call, nameof(f), pretty_expr.(args; kw...)...)

pretty_expr(A::Array{Num, 2}; kw...) = pretty_array(A; kw...)



#returns respective matrix partition
function d(U)
    return U[2: size(U)[1], 1:size(U)[2]]
end

function u(U)
    return  reshape(U[1 , 2:size(U)[2]], (1, :))
end

#returns the matrix with continued signals portion
function d(U, n) #matrix to partition, number of continued signals.
    tmp = d(U);
    return sparse([ tmp                     zeros(size(tmp)[1],n)
                    zeros(n,size(tmp)[2])   Diagonal(ones(n))    ])
end

function u(U, n) #matrix to partition, number of continued signals.
    tmp = u(U);
    ins = size(tmp)[2];
    return sparse([ tmp                     reshape(zeros(n), (1, :))
                    Diagonal(ones(ins))     zeros(ins, n)
                    zeros(n, ins)           Diagonal(ones(n)) ])
end

#return the routing matrix for a vector of connected matrix dimensions (dim_1, dim_2, ... , dim_n)
function R_down(V)
    tmp = zeros(sum(V), sum(V))
    output = 1
    input = 1
    for x in V #set the a inputs
        tmp[input, output] = 1
        output += x
        input+=1;
    end
    for i = 1:sum(V) #set the continued signals
        if sum(tmp[:, i]) == 0
            tmp[input, i] = 1
            input+=1;
        end
    end
    return sparse(tmp)
end

function R_up(V)
    return sparse(R_down(V)')
end


#common adaptor declrations as found in Werner Dissertation
@variables R_1, R_2, rho

S_series  = [0                  -R_1^(1-rho)/(R_1+R_2)^(1-rho)      -R_2^(1-rho)/(R_1+R_2)^(1-rho)
            -R_1^rho/(R_1+R_2)   R_2/(R_1+R_2)                       -R_1^rho*R_2^(1-rho)/(R_1+R_2)
            -R_2^rho/(R_1+R_2)  -R_1^(1-rho)*R_2^rho/(R_1+R_2)      R_1/(R_1+R_2)]

S_parallel = [0                                 R_2^(rho)/(R_1+R_2)^(rho)       R_1^(rho)/(R_1+R_2)^(rho)
             R_2^(1-rho)/(R_1+R_2)^(1-rho)     -R_1/(R_1+R_2)                   R_1^rho*R_2^(1-rho)/(R_1+R_2)
             R_1^(1-rho)/(R_1+R_2)^(1-rho)      R_1^(1-rho)*R_2^rho/(R_1+R_2)   -R_2/(R_1+R_2)]

# very simple model test (first-order RC filter), see p. 82
# connection tree Vs : S1 : (R1, C1)

# Declare names for easy substitution
@variables Vs S1 R1 C1;

# component values
@parameters V_in R_R1 R_C1;
# state-space matricies
@parameters Q U P A B C;

#initialize scattering mtx for S
S1 = substituteArray(S_series, Dict([R_1 => R_C1, R_2 => R_R1, rho => 1]))

R1 = 0;
C1 = 1;

#declare P (up-going waves)
P = u(S1, 0)*[C1 0; 0 R1]

latexify(pretty_expr(u(S1, 0)))

Q =[C1 0; 0 R1]*d(S1, 0)

Vs = -1;


U = [Vs             zeros(1, 2)
     zeros(2, 1)    Diagonal(ones(2))]

#initialize model shape
A = simplifyArray(Q*U*P)
println(latexify(pretty_expr(A)))

Vs = V_in;

U_ins = [Vs             zeros(1, 2)
         zeros(2, 1)    Diagonal(zeros(2))]

B = simplifyArray(Q*U_ins)
println(latexify(pretty_expr(B)))

#swap Rs and Cs and repeat
#declare P (up-going waves)
P = u(S1, 0)*[R1 0; 0 C1]

latexify(pretty_expr(u(S1, 0)))

Q =[R1 0; 0 C1]*d(S1, 0)

Vs = -1;


U = [Vs             zeros(1, 2)
     zeros(2, 1)    Diagonal(ones(2))]

#initialize model shape
A = simplifyArray(Q*U*P)
println(latexify(pretty_expr(A)))

Vs = V_in;

U_ins = [Vs             zeros(1, 2)
         zeros(2, 1)    Diagonal(zeros(2))]

B = simplifyArray(Q*U_ins)
println(latexify(pretty_expr(B)))



# simple model test, see p. 77
# connection tree Vs : St : ((Pb : (R1, C1)), (Sb : (R2, C2)))
# too complex, need to go even simpler.
@variables Vs St[0:2,0:2] Pb[0:2, 0:2] Sb[0:2, 0:2] R1 C1 R2 C2 V_in x y;
@parameters n;

@variables R_R1 R_R2 R_C1 R_C2;

Sb = substituteArray(S_series, Dict([R_1 => R_R2, R_2 => R_C2, rho => 1]))
Pb = substituteArray(S_parallel, Dict([R_1 => R_R1, R_2 => R_C1, rho => 1]))
St = substituteArray(S_series, Dict([R_1 => 1/(1/R_R1+1/R_C1), R_2 => R_R2 + R_C2, rho => 1]))

Vs = -1;

R1 = 0;
R2 = 0;
C1 = 1;
C2 = 1;

Q = [[R1 0; 0 C2]*d(Pb)     zeros(2, 3);
    zeros(2, 3)             [R2 0; 0 C2]*d(Sb)]  *R_down([3,3])*d(St, 4)


P = u(St, 4)*R_up([3,3])*[  u(Pb, 0)*[R1 0; 0 C1]         zeros(3, 2);
                            zeros(3, 2 )     u(Sb, 0)*[R2  0; 0 C2]]


U = [Vs             zeros(1, 6)
     zeros(6, 1)    Diagonal(ones(6))]

#A
A = simplifyArray(Q*U*P)

ins = [1/(1/R_R1+1/R_C1) + R_R2 + R_C2  zeros(1, 6)
        zeros(6, 1)                     zeros(6, 6)]
#B
B = simplifyArray(Qzero*ins* [V_in; zeros(6, 1)])


println(latexify(simplify(pretty_expr(A[2,2]))))
println(latexify(pretty_expr(B)))
#scatter = simplifyArray(model)
#simplify(scatter[2,2])
#modified connection tree form
# connection tree Vs : St : ((Pb : (C1, C2)), (Sb : (R1, R2)))
# Q = [[R1 0; 0 C2]*d(Pb)     zeros(2, 3);
#     zeros(2, 3)             [R1 0; 0 R2]*d(Sb)]  *R_down([3,3])*d(St, 4)
#
#
# Qzero = substituteArray(Q, Dict([R1 => 0, R2 => 0, C1 => 1, C2 => 1]))
#
# P = u(St, 4)*R_up([3,3])*[  u(Pb, 0)*[C1 0; 0 C2]         zeros(3, 2);
#                             zeros(3, 2 )     u(Sb, 0)*[R1  0; 0 R2]]
#
# Pzero = substituteArray(P, Dict([R1 => 0, R2 => 0, C1 => 1, C2 => 1]))
#
# U = [Vs             zeros(1, 6)
#      zeros(6, 1)    Diagonal(ones(6))]
#
# A = Qzero*U*Pzero
# ins = [1/(1/R_R1+1/R_C1) + R_R2 + R_C2  zeros(1, 6)
#         zeros(6, 1)                     zeros(6, 6)]
# B = simplifyArray(Qzero*ins* [Vs; zeros(6, 1)])
# scatter = simplifyArray(model)
#
# simplify(scatter[2,2])
