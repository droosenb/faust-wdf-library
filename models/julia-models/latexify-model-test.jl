using Latexify;
using LaTeXStrings;
using LinearAlgebra;
using SparseArrays;
using ModelingToolkit;

# From ModelingToolkit/test/latexify.jl
# Works normally
@parameters t σ ρ β
@variables x(t) y(t) z(t) A B C


eqs = [A ~ σ*(y-x)*(x-y)/(z),
       B ~ σ*x*(ρ-z)/10-y,
       C ~ x*y^(2//3) - β*z]

latexify(eqs)
# Latexify.@generate_test latexify(eqs)
@test latexify(eqs) == replace(
raw"\begin{align}
\frac{dx(t)}{dt} =& \frac{\sigma \left( y\left( t \right) - x\left( t \right) \right) \frac{d\left(x\left( t \right) - y\left( t \right)\right)}{dt}}{\frac{dz(t)}{dt}} \\
0 =& \frac{\sigma x\left( t \right) \left( \rho - z\left( t \right) \right)}{10} - y\left( t \right) \\
\frac{dz(t)}{dt} =& x\left( t \right) \left( y\left( t \right) \right)^{\frac{2}{3}} - \beta z\left( t \right)
\end{align}
", "\r\n"=>"\n")



b21_expr = simplify(toexpr(B[2,1]))

latexify(b21_expr)
b21 = B[2,1]
latexraw(b21_expr; symbolic=true)
latexify(value(b2))

exp = :(sqrt(t))
test1 = inv(t)
toe =
latexify(toe)

Equation(A_mtx, A)

@variables x y
ex = ((x + x*y*y)/(x-y))
