using ModelingToolkit;
using LinearAlgebra;
using SparseArrays;
using Latexify;

#Manual Model Test (See p. 77 of notebook)

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

@variables Vs[0:1, 0:1] St[0:2,0:2] Pb[0:2, 0:2] Sb[0:2, 0:2] R1 C1 R2 C2;

Q = [[  R1  0;
        0   C1]*d(Pb)   zeros(2, 3);

        zeros(2, 3)    [R2  0;
                        0   C1]*d(Sb)]*R_down([3,3])*d(St, 4)

Qsimp = simplifyArray(Q)
Qzero = substituteArray(Qsimp, Dict([R1 => 0, R2 => 0, C1 => 1, C2 => 1]))

P = u(St, 4)*R_up([3,3])*[  u(Pb, 0)*[R1 0; 0 C1]         zeros(3, 2);
                            zeros(3, 2 )     u(Sb, 0)*[R2  0; 0 C1]]

Pzero = substituteArray(P, Dict([R1 => 0, R2 => 0, C1 => 1, C2 => 1]))

U =

model = Qzero*U*Pzero
