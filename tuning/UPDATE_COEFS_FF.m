function UPDATE_COEFS_FF( tmpABC )
% Adds new observations to the memory used to update the coefficients of the fitness function
global ff_par;
if ff_par.numFFEval == 1
    ff_par.avgCoefFF = tmpABC;
else
    for i = 1 : ff_par.numCoefFF
        ff_par.avgCoefFF( i ) = ff_par.avgCoefFF( i ) * ( ( ff_par.numFFEval  - 1 ) / ff_par.numFFEval ) + tmpABC( i ) / ff_par.numFFEval;
    end
end
end