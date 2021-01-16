#using Latexify;
#using LaTeXStrings;
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
    mtx[i, i] =  1/val + mtx[i, i]
    mtx[j, j] =  1/val + mtx[j, j]
    mtx[i, j] = 1/-val + mtx[i, j]
    mtx[j, i] = 1/-val + mtx[j, i]
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

function mathmatica2faustArray(str::String, f::String, dim::Int)

    str = replace(str, "{" => "")
    str = replace(str, "}" => "")
    tmp = tmp = "\n\n$f  = \ncase{\n\t(1, 1) => "
    entry = 1;
    while contains(str, ",")
        splitstr = split(str, ","; limit=2)
        tmp = tmp * splitstr[1] * "; \n\t($(Int(round(entry/6, RoundDown)+1)), $(entry%6+1)) => "
        str = splitstr[2]
        entry += 1
    end
    tmp = tmp * str * "; \n};"

    #replace bad negatives
    tmp = replace(tmp, "-(" => "(-1)*(");
    #cleanup a bit
    tmp = replace(tmp, "=>  \n" => "=>")
    tmp = replace(tmp, "\n " => "")
    tmp = replace(tmp, "=>(" => "=> (")
    tmp = replace(tmp, "=>  " => "=> ")

    println(tmp);
end

function reduce_mtx(vn, i, etc)
    Red =  Array(   [zeros(Num, vn, i)
                    Diagonal(ones(Num, i))
                    zeros(Num, etc, i)])
end


#tonestack MNA
@variables Ra Rb Rc Rd Re Rf Va Vb Vc Vd Ve Vf rho;

MNA = zeros(Num, 16, 16)

R_mtx = [Ra 1 7
         Rb 2 7
         Rc 3 9
         Rd 4 10
         Re 5 8
         Rf 6 8]
V_mtx = [Va 1 10
         Vb 2 9
         Vc 3 10
         Vd 4 8
         Ve 5 9
         Vf 6 7]

# add stamps
MNA = resistor_MNA(MNA, R_mtx)
MNA = voltage_MNA(MNA, V_mtx, 0)

# remove ground node
MNA = MNA[1:end .!= 10, 1:end .!= 10]

println(mathmaticaArray(MNA))

#perform remaining computations in Mathmatica
S = """{{((-Ra)*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) +
     Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))), (2*Ra*((Rc + Re)*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   (2*Ra*(Rb*Rd + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Ra*(Rb*(Rc + Re) + Rc*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   (2*Ra*(Rb*Rd - Rc*Rf))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Ra*(Rc*Re + Rb*(Rc + Rd + Re)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))))},
  {(2*Rb*((Rc + Re)*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   (Ra*(Rd*Re - Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) - Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) +
     Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))), -((2*Rb*(Ra*Re + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   (-2*Ra*Rb*Re + 2*Rb*Rc*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   (2*Rb*(Ra*(Rc + Rd) + Rc*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Rb*(Rc*Rd + Ra*(Rc + Rd + Re)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))))},
  {(2*Rc*(Rb*Rd + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Rc*(Ra*Re + Re*Rf + Rd*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   1 - (2*Rc*(Rd*Re + Rd*Rf + Re*Rf + Rb*(Rd + Rf) + Ra*(Rb + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Rc*(Rb*Rf + Ra*(Rb + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   -((2*Rc*(Ra*(Rb + Rf) + Rb*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   (2*Rc*(Rb*Rd - Ra*Re))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))},
  {-((2*Rd*(Rb*(Rc + Re) + Rc*(Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   (-2*Ra*Rd*Re + 2*Rc*Rd*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Rd*(Rb*Rf + Ra*(Rb + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   1 - (2*Rd*(Rc*(Re + Rf) + Ra*(Rb + Re + Rf) + Rb*(Rc + Re + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Rd*((Rb + Rc)*Rf + Ra*(Rb + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   -((2*Rd*((Ra + Rc)*Re + Rb*(Rc + Re)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))))},
  {(2*Re*(Rb*Rd - Rc*Rf))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   (2*Re*(Ra*(Rc + Rd) + Rc*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*Re*(Ra*(Rb + Rf) + Rb*(Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   -((2*Re*((Rb + Rc)*Rf + Ra*(Rb + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   1 - (2*Re*((Rb + Rc)*(Rd + Rf) + Ra*(Rb + Rc + Rd + Rf)))/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   (2*((Rb + Rc)*Rd + Ra*(Rc + Rd))*Re)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))},
  {-((2*(Rc*Re + Rb*(Rc + Rd + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   -((2*(Rc*Rd + Ra*(Rc + Rd + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   (2*(Rb*Rd - Ra*Re)*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   -((2*((Ra + Rc)*Re + Rb*(Rc + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))),
   (2*((Rb + Rc)*Rd + Ra*(Rc + Rd))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf))),
   1 - (2*(Rc*(Rd + Re) + Ra*(Rc + Rd + Re) + Rb*(Rc + Rd + Re))*Rf)/(Ra*(Rd*Re + Rb*(Rc + Rd + Re) + Rd*Rf + Re*Rf + Rc*(Re + Rf)) + Rc*(Re*Rf + Rd*(Re + Rf)) + Rb*(Re*Rf + Rc*(Rd + Rf) + Rd*(Re + Rf)))}}"""

mathmatica2faustArray(S, "s", 6)
