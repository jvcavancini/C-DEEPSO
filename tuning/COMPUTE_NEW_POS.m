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
function [ new_pos, new_vel ] = COMPUTE_NEW_POS( pos, vel )
% Computes new position for the particles and updates its velocity
new_pos = pos + vel;
new_vel = vel;
end