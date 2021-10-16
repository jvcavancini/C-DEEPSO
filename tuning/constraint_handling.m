%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carolina Marcelino, PhD (email: carolimarc@gmail.com)
% 15th October 2021
%
% Solving security constrained optimal power flow problems: 
% a hybrid evolutionary approach
%
% Canonical Differential Evolutionary Particle Swarm Optimization (CDEEPSO) 
% algorithm as optimization engine to solve test bed declarations V1.1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task Force on Modern Heuristic Optimization Test Beds
% Working Group on Modern Heuristic Optimization
% Intelligent Systems Subcommittee
% Power System Analysis, Computing, and Economic Committee
%
% Sebastian Wildenhues (E-Mail: sebastian.wildenhues@uni-due.de)
% 18th September 2013
%
% Application of Modern Heuristic Optimization Algorithms
% for Solving Optimal Power Flow Problems
%
% Incorporating static penalty constraint handling method.
%
% This routine is called subsequent to every function evaluation,
% i.e. power flow calculation. It does not affect the calculations
% done in test_bed_OPF.p, which calculates internally the fitness by
% using static penalty constraint handling method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,g]=constraint_handling(o,g)
global proc;
global ps;
global ff_par;
py=1e-7;
dimG = length( g );
a = 2 * ps.n_load;
b = dimG - 2 * ps.n_gen_VS;
ff_par.numFFEval = ff_par.numFFEval + 1;
switch proc.system
    case 41
        tmpA = sum( g( 1 : a )  );
        tmpB = sum( g( 1 + b : dimG ) );
        tmpC = sum( g( 1 + a : b ) );
        tmpABC = [ tmpA, tmpB, 1e5 * tmpC ];
        UPDATE_COEFS_FF( tmpABC );
        g = ff_par.factor * ff_par.coefFF * tmpABC';
        o = o*o*o;
        g = g*g*g;
        
    otherwise
     % This must never happen!
end
% Fitness function.
f=o+g;
end