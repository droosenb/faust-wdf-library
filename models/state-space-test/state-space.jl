using Latexify;
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


function julia2mathmaticaArray(mtx::Array)
    println("")
    str::String = "{ "
    for i = 1:size(mtx)[1]
        str *= "{ $(mtx[i, 1])"
        for j = 2:size(mtx)[2]
            str *= ", $(mtx[i, j])"
        end
        str *= " }, "
    end
    str *= " }"
    println("")
    return str
end

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

S_series(R_1, R_2, rho)  =  [0                  -R_1^(1-rho)/(R_1+R_2)^(1-rho)      -R_2^(1-rho)/(R_1+R_2)^(1-rho)
                            -R_1^rho/(R_1+R_2)   R_2/(R_1+R_2)                      -R_1^rho*R_2^(1-rho)/(R_1+R_2)
                            -R_2^rho/(R_1+R_2)  -R_1^(1-rho)*R_2^rho/(R_1+R_2)       R_1/(R_1+R_2)]

S_parallel(R_1, R_2, rho) = [0                                 R_2^(rho)/(R_1+R_2)^(rho)       R_1^(rho)/(R_1+R_2)^(rho)
                            R_2^(1-rho)/(R_1+R_2)^(1-rho)     -R_1/(R_1+R_2)                   R_1^rho*R_2^(1-rho)/(R_1+R_2)
                            R_1^(1-rho)/(R_1+R_2)^(1-rho)      R_1^(1-rho)*R_2^rho/(R_1+R_2)   -R_2/(R_1+R_2)]

# very simple model test (first-order RC filter), see p. 82
# connection tree Vs : S1 : (R1, C1)

# Declare names for easy substitution
# state-space matricies
@parameters Q U P A B C;

@variables Vs S1[0:2,0:2] P1[0:2, 0:2] S2[0:2, 0:2] R_1 C_1 R_2 C_2 V_in x y;
@parameters n;

@variables R1 R2 C1 C2 T;

S1 = S_series(R1, 1/(1/(R2+T/(2*C2))+ 1/(T/(2*C1))), 1)
P1 = S_parallel(C1, R2+T/(2*C2),  1)
S2 = S_series(R2, T/(2*C2), 1)

Vs = -1

R_1 = 0
R_2 = 0
C_1 = 1
C_2 = 1

Pa = u(S2, 0)*[R_2  0; 0 C_2]
Pb = u(P1, 2)*[C_1    zeros(1, 2);
                zeros(3 ,1)      Pa]
Pc = u(S1, 4)*[R_1    zeros(1, 3);
        zeros(5, 1)      Pb]
P = simplifyArray(Pc)

println("Array P")
println("Array P")

println(latexify(pretty_expr(P)))
println(julia2mathmaticaArray(P))

U = [Vs             zeros(1, 6)
    zeros(6, 1)    Diagonal(ones(6))]

    println("Array U")

    println(latexify(pretty_expr(U)))
    println(julia2mathmaticaArray(U))

Qa = [R_2  0; 0 C_2]*d(S2, 0)
Qb = [  C_1    zeros(1, 3);
        zeros(2 ,1)      Qa]*d(P1, 2)
Qc = [  R_1    zeros(1, 5);
        zeros(3 ,1)      Qb]*d(S1, 4)
Q = simplifyArray(Qc)

println("Array Q")
println(latexify(pretty_expr(Q)))

println(julia2mathmaticaArray(Q))
#=
{ { -0.0, -0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }, { -1.0 * ((R1 + (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1)) ^ -1) * (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1), -1.0 * ((R1 + (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1)) ^ -1) * (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1), R1 * ((R1 + (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1)) ^ -1), -1 * (((0.5 * (C2 ^ -1) * T) + C1 + R2) ^ -1) * C1, (((0.5 * (C2 ^ -1) * T) + C1 + R2) ^ -1) * C1, 0.0, 0.0 }, { -0.0, -0.0, 0.0, 0.0, 0.0, 0, 0.0 }, { 0.5 * (C2 ^ -1) * T * (((0.5 * (C2 ^ -1) * T) + R2) ^ -1) * ((R1 + (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1)) ^ -1) * (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1), 0.5 * (C2 ^ -1) * T * (((0.5 * (C2 ^ -1) * T) + R2) ^ -1) * ((R1 + (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1)) ^ -1) * (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1), -0.5 * (C2 ^ -1) * R1 * T * (((0.5 * (C2 ^ -1) * T) + R2) ^ -1) * ((R1 + (((((0.5 * (C2 ^ -1) * T) + R2) ^ -1) + (2.0 * C1 * (T ^ -1))) ^ -1)) ^ -1), -0.5 * (((0.5 * (C2 ^ -1) * T) + C1 + R2) ^ -1) * (C2 ^ -1) * T, 0.5 * (((0.5 * (C2 ^ -1) * T) + C1 + R2) ^ -1) * (C2 ^ -1) * T, -0.5 * (C2 ^ -1) * T * (((0.5 * (C2 ^ -1) * T) + R2) ^ -1), R2 * (((0.5 * (C2 ^ -1) * T) + R2) ^ -1) }  }
=#
println("Array A")
A = simplifyArray(Q*U*P)
println(latexify(pretty_expr(A)))

println(julia2mathmaticaArray(A))


U_ins = [Vs  zeros(1, 6)
        zeros(6, 1)                     zeros(6, 6)]
#B
B = simplifyArray(Q*U_ins)

println(latexify(pretty_expr(B)))
println(julia2mathmaticaArray(B))

Ro = [zeros(3,3) zeros(3, 1);
    zeros(1, 3)  1/2]
C = Ro * (A +  Diagonal(ones(4)))
C = simplifyArray(C)

println(latexify(pretty_expr(C)))
println(julia2mathmaticaArray(C))

D = Ro * B
D = simplifyArray(D)

println(latexify(pretty_expr(D)))
println(julia2mathmaticaArray(D))
