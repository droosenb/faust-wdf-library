pkg load symbolic;

function rmtx = resistor_stamp (inmtx, val, i, j)
  mtx = inmtx; 
  mtx(i, i) = 1/val + mtx(i, i);
  mtx(j, j) = 1/val + mtx(j, j); 
  mtx(i, j) = -1/val + mtx(i, j); 
  mtx(j, i) = -1/val + mtx(j, i); 
  rmtx = mtx; 
endfunction

function rmtx = resistor_MNA (inmtx, res_mtx)
  mtx = inmtx; 
  i = 1; 
  while (i <= rows(res_mtx))
    mtx = resistor_stamp(mtx, res_mtx(i, 1), res_mtx(i, 2), res_mtx(i,3));
    i++;
  endwhile
  rmtx = mtx;
endfunction

function rmtx = voltage_stamp (inmtx, val, i, j, nodes)
  mtx = inmtx;
  mtx(i, nodes+val) = 1 + mtx(i, nodes+val);
  mtx(j, nodes+val) = -1 + mtx(j, nodes+val);
  mtx(nodes+val, i) = 1 + mtx(nodes+val, i);
  mtx(nodes+val, j) = -1 + mtx(nodes+val, j);
  rmtx = mtx; 
endfunction
  
function rmtx = voltage_MNA (inmtx, volt_mtx, etc) 
  % need to input number of extra elements voltage sources, nullators, etc
  mtx = inmtx; 
  i = 1; 
  nodes = rows(inmtx) - rows(volt_mtx) - etc;
  while (i <= rows(volt_mtx))
    mtx = voltage_stamp(mtx, i, volt_mtx(i, 2), volt_mtx(i, 3), nodes);
    i++;
  endwhile
  rmtx = mtx;
endfunction

function rmtx = null_stamp (inmtx, val, i, j, k, l, start)
  mtx = inmtx;
  mtx(k, start+val) = 1 + mtx(k, start+val);
  mtx(l, start+val) = -1 + mtx(l, start+val);
  mtx(start+val, i) = 1 + mtx(start+val, i);
  mtx(start+val, j) = -1 + mtx(start+val, j);
  rmtx = mtx; 
endfunction
  
function rmtx = null_MNA (inmtx, null_mtx) 
  % need to input number of extra elements voltage sources, nullators, etc
  mtx = inmtx; 
  i = 1; 
  nodes = rows(inmtx) - rows(null_mtx);
  while (i <= rows(null_mtx))
    mtx = voltage(mtx, i, null_mtx(i, 2), null_mtx(i, 3), nodes);
    i++;
  endwhile
  rmtx = mtx;
endfunction
%simple op-amp inverter (+ to ground)
syms Rin Rg Rfb Rout Vin Vg Vfb Vout rho;  

MNA = sym(zeros(13, 13));

R_mtx = [Rin, 1, 6;
         Rg, 2, 5; 
         Rfb, 3, 7; 
         Rout, 4, 5; ];
V_mtx = [Vin, 1, 5;
         Vg, 2, 7;
         Vfb, 3, 8;
         Vout, 4, 8;];
         
%add stamps         
MNA = resistor_MNA(MNA, R_mtx);
MNA = voltage_MNA(MNA, V_mtx, 1);
MNA = null_stamp(MNA, 1, 6, 7, 8, 5, 12) % full MNA matrix

%remove ground nodes
MNA(:, [5]) = []; 
MNA([5], :) = [];

X_inv = simplify(inv(MNA))

%don't refer to initial matrix dimensions. it has been reduced since then
X_red = X_inv(8:11, 8:11) % reduce the matrix

R_eye = [Rin, 0, 0, 0; 
         0, Rg, 0, 0;
         0, 0, Rfb, 0;
         0, 0, 0,   Rout]; 
         
R_rho1 = R_eye^rho;;
R_rho2 = R_eye^(1-rho);

scatter = sym(eye(4, 4)) + 2*R_rho1*X_red*R_rho2; %calculate our scattering matrix using werner equation
scatter = simplify(scatter) %full scattering matrix
scatter_voltage = simplify(subs(scatter, rho, 1))

scatter_a = simplify(subs(scatter, Ra, (Rd + Rf))) %adapted matrix
scatter_a_voltage = simplify(subs(scatter_a, rho, 1)) %just for voltage waves

