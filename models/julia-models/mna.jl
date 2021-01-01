using Latexify;
using LaTeXStrings;
using SparseArrays;
using LinearAlgebra;
using ModelingToolkit;

#using Reduce.Algebra;

function simplifyArray(arr)
    tmp = Array{Num, 2}(undef, size(arr)[1], size(arr)[2])
    for i = 1:size(arr)[1]
        for j = 1:size(arr)[2]
            tmp[i,j] = simplify(arr[i,j]);
        end
    end
    return tmp
end

# MNA functions

function resistor_stamp(inmtx, val, i, j)
    mtx = inmtx
    mtx[i, i] =  val + mtx[i, i]
    mtx[j, j] =  val + mtx[j, j]
    mtx[i, j] = -val + mtx[i, j]
    mtx[j, i] = -val + mtx[j, i]
    return mtx;
end

function resistor_MNA(inmtx, res_mtx)
    mtx = inmtx;
    i = 1;
    while (i <= size(res_mtx)[1])
        mtx = resistor_stamp(mtx, res_mtx[i, 1], toexpr(res_mtx[i, 2]), toexpr(res_mtx[i, 3]))
        i+=1
    end
    return mtx;
end

function voltage_stamp(inmtx, val, i, j, nodes)
    mtx = inmtx;
    mtx[i, nodes+val] =  1 + mtx[i, nodes+val];
    mtx[j, nodes+val] = -1 + mtx[j, nodes+val];
    mtx[nodes+val, i] =  1 + mtx[nodes+val, i];
    mtx[nodes+val, j] = -1 + mtx[nodes+val, j];
    return mtx;
end

function voltage_MNA(inmtx, volt_mtx, etc)
    # need to input number of extra elements voltage sources, nullators, etc
    mtx = inmtx;
    i = 1;
    nodes = size(inmtx)[1] - size(volt_mtx)[1] - etc;
    while (i <= size(volt_mtx)[1])
        mtx = voltage_stamp(mtx, i, toexpr(volt_mtx[i, 2]), toexpr(volt_mtx[i, 3]), nodes);
        i+=1;
    end
    return mtx;
end

function null_stamp(inmtx, val, i, j, k, l, start)
  mtx = inmtx;
  mtx[k, start+val] =  1 + mtx[k, start+val];
  mtx[l, start+val] = -1 + mtx[l, start+val];
  mtx[start+val, i] =  1 + mtx[start+val, i];
  mtx[start+val, j] = -1 + mtx[start+val, j];
  return mtx;
end

function vcvs_stamp(inmtx, val, i, j, k, l, start)
  mtx = inmtx;
  mtx[k, start+val] =  1 + mtx[k, start+val];
  mtx[l, start+val] = -1 + mtx[l, start+val];
  mtx[start+val, i] =  1 + mtx[start+val, i];
  mtx[start+val, j] = -1 + mtx[start+val, j];
  return mtx;
end


# @variables R1 R2 R3
# MNA = resistor_stamp(zeros(Num, 4, 4), R2, 1, 3)

@variables Ra Rb Rc Rd Re Rf Va Vb Vc Vd Ve Vf rho;

MNA = zeros(Num, 16, 16)

R_mtx = [Ra 2 3
         Rb 5 3
         Rc 6 4
         Rd 8 4
         Re 9 1
         Rf 10 7]
V_mtx = [Va 2 1
         Vb 5 4
         Vc 6 1
         Vd 8 7
         Ve 9 7
         Vf 10 3]

# add stamps
MNA = resistor_MNA(MNA, R_mtx)
MNA = voltage_MNA(MNA, V_mtx, 0)
# println(latexify(simplifyArray(MNA)))


# remove ground nodes
MNA = MNA[2:16, 2:16]

hold = simplifyArray(MNA)

MNA = toexpr(MNA)

Red =  [zeros(Num, 9, 6)
        Diagonal(ones(Num, 6))]
Red = toexpr(Matrix(Red))

using Reduce.Algebra

test = Red'

X_inv = Red'linearAlgebra./(MNA)

#don't refer to initial matrix dimensions. it has been reduced since then
X_red = X_inv[10:15, 10:15] # reduce the matrix

R_eye = [Ra 0 0 0 0 0
         0 Rb 0 0 0 0
         0 0 Rc 0 0 0
         0 0 0 Rd 0 0
         0 0 0 0 Re 0
         0 0 0 0 0 Rf]

R_rho1 = R_eye^rho
R_rho2 = R_eye^(1-rho)

scatter = sym(eye(6, 6)) + 2*R_rho1*X_red*R_rho2 # calculate our scattering matrix using werner equation
scatter = simplify(scatter) # full scattering matrixs
scatter_voltage = simplify(subs(scatter, rho, 1))

scatter_a_voltage = simplify(subs(scatter_voltage, Ra, oneone))

scatter_a = simplify(subs(scatter, Ra, (Rd + Rf))) # adapted matrix
scatter_a_voltage = simplify(subs(scatter_a, rho, 1)) # just for voltage waves
