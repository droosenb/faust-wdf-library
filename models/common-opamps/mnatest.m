pkg load symbolic;

syms Ra Rb Rc Rd Re Rf rho Va Vb Vc Vd Ve Vf N1;  

MNA = sym(zeros(18, 18));

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


R_mtx = [Ra, 6, 2; 
         Rb, 7, 5; 
         Rc, 8, 5;
         Rd, 9, 2;
         Re, 11, 1;
         Rf, 10, 1; ];
V_mtx = [Va, 6, 4;
         Vb, 7, 4;
         Vc, 8, 3;
         Vd, 9, 1;
         Ve, 11, 1;
         Vf, 10, 4;];
         
%add stamps         
MNA = resistor_MNA(MNA, R_mtx);
MNA = voltage_MNA(MNA, V_mtx, 1);
MNA = null_stamp(MNA, 1, 2, 3, 5, 4, 17) % full MNA matrix

%remove ground nodes
MNA(:, [4]) = []; 
MNA([4], :) = [];

X_inv = simplify(inv(MNA))

X_red = X_inv(11:16, 11:16); % reduce the matrix

R_eye = [Ra, 0, 0, 0, 0, 0; 
         0, Rb, 0, 0, 0, 0;
         0, 0, Rc, 0, 0, 0;
         0, 0, 0, Rd, 0, 0;
         0, 0, 0, 0, Re, 0;
         0, 0, 0, 0,  0, Rf;]; 
         
R_rho1 = R_eye^rho;;
R_rho2 = R_eye^(1-rho);

scatter = sym(eye(6,6)) + 2*R_rho1*X_red*R_rho2; %calculate our scattering matrix using werner equation
scatter = simplify(scatter) %full scattering matrix

scatter_a = simplify(subs(scatter, Ra, (Rd + Rf))) %adapted matrix
scatter_a_voltage = simplify(subs(scatter_a, rho, 1)) %just for voltage waves

