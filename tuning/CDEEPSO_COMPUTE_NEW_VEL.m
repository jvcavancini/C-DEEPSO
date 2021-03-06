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
function [ new_vel ] = CDEEPSO_COMPUTE_NEW_VEL(pos, gbest, fit, numGBestSaved, memGBestFit, memGBest, vel, Vmin, Vmax, weights, communicationProbability)
% Computes new velocity according to the DEEPSO movement rule
global ps


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute inertial term
inertiaTerm = weights( 1 ) * vel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select subset of particles to sample myBestPos from
% Get the index of the best particles ever visited that have a fitness less
% than or equal to the fitness of particle i
tmpMemoryVect = zeros( 1, numGBestSaved );
tmpMemoryVectSize = 0;
for i = 1 : numGBestSaved
    if memGBestFit( 1, i ) <= fit
        tmpMemoryVectSize = tmpMemoryVectSize + 1;
        tmpMemoryVect( 1, tmpMemoryVectSize ) = i;
    end
end
tmpMemoryVect = tmpMemoryVect( 1, 1:tmpMemoryVectSize );
% Sample every entry of myBestPos using the subset - Pb-rnd
myBestPos = zeros( 1, ps.D );
tmpIndexMemoryVect = randsample( tmpMemoryVectSize, ps.D, true );
for i = 1 : ps.D
    myBestPos( 1, i ) = memGBest( tmpMemoryVect( 1, tmpIndexMemoryVect( i ) ), i );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute memory term % mexido
memoryTerm = weights( 2 ) * (myBestPos - pos );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute cooperation term
% Sample normally distributed number to perturbate the best position
cooperationTerm = weights( 3 ) * ( (gbest) * ( 1 + weights( 4 ) * normrnd( 0, 1 ) ) - pos );
communicationProbabilityMatrix = rand( 1, ps.D ) < communicationProbability;
cooperationTerm = cooperationTerm .* communicationProbabilityMatrix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute velocity
new_vel = inertiaTerm + memoryTerm + cooperationTerm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check velocity limits
new_vel = ( new_vel > Vmax ) .* Vmax + ( new_vel <= Vmax ) .* new_vel;
new_vel = ( new_vel < Vmin ) .* Vmin + ( new_vel >= Vmin ) .* new_vel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end