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

function [ tmpMyBestPos, tmpMyBestPosFit, pos ] = CDEEPSO_COMPUTE_NEW_PERSONAL_BEST( D, CR, F, myBestPos, myBestPosFit, gbest, numGBestSaved, memGBest, memGBestFit , ...
    Xmin, Xmax, pos )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select subset of particles to sample myBestPos from
% Get the index of the best particles ever visited that have a fitness less
% than or equal to the fitness of particle i
global deType;
tmpMyBestPos = myBestPos;
tmpMyBestPosFit = myBestPosFit;
tmpMemoryVect = zeros( 1, numGBestSaved );
tmpMemoryVectSize = 0;
for i = 1 : numGBestSaved
    if ( memGBestFit( 1, i ) < myBestPosFit ) && ( ~isequal( myBestPos, memGBest( i, :) ) );
        tmpMemoryVectSize = tmpMemoryVectSize + 1;
        tmpMemoryVect( 1, tmpMemoryVectSize ) = i;
    end
end
tmpMemoryVect = tmpMemoryVect( 1, 1:tmpMemoryVectSize );

if deType == 2
    % DE/Rand/1/Bin
    if tmpMemoryVectSize >= 3
        tmpIndexMemoryVect = randsample( tmpMemoryVect, 3, false );
        tmpMyBestPos = memGBest( tmpIndexMemoryVect( 1 ), : ) + F * ( memGBest( tmpIndexMemoryVect( 2 ), : ) - memGBest( tmpIndexMemoryVect( 3 ), : ) );
        tmpIndexD = randsample( D, 1 );
        tmpRand = rand( 1, D );
        for i = 1 : D
            if ~( ( tmpRand( i ) < CR ) || ( i == tmpIndexD ) )
                tmpMyBestPos( i ) = myBestPos( i );
            end
            % check pos limits
            if tmpMyBestPos( i ) < Xmin( i )
                tmpMyBestPos( i ) = Xmin( i );
            elseif tmpMyBestPos( i ) > Xmax( i )
                tmpMyBestPos( i ) = Xmax( i );
            end
        end
        % select the position to use as memory
        tmpMyBestPosFit = FITNESS_FUNCTION( 1, tmpMyBestPos );
        if( tmpMyBestPosFit > myBestPosFit )
            tmpMyBestPos = myBestPos;
            tmpMyBestPosFit = myBestPosFit;
        end
    end
    
elseif deType == 3
       
    % DE/Current-to-pbest
     if tmpMemoryVectSize >= 4
     tmpIndexMemoryVect = randsample( tmpMemoryVect, 4, false );
%       %Rand/1/Bin
% 		tmpMyBestPos = memGBest( tmpIndexMemoryVect( 1 ), : ) + F* (memGBest( tmpIndexMemoryVect( 2 ), : ) - memGBest( tmpIndexMemoryVect( 3 ), : ));
% 		
% 		%Best/1/Bin
 		tmpMyBestPos = gbest + F* (memGBest( tmpIndexMemoryVect( 1 ), : ) - memGBest( tmpIndexMemoryVect( 2 ), : ));
% 		
% 		%Rand/2/Bin
% 		tmpMyBestPos = memGBest( tmpIndexMemoryVect( 1 ), : ) + F * ( ( memGBest( tmpIndexMemoryVect( 2 ), : ) - memGBest( tmpIndexMemoryVect( 3 ), : ) ) + ( memGBest( tmpIndexMemoryVect( 4 ), : ) - memGBest( tmpIndexMemoryVect( 5 ), : ) ) );
% 		
% 		%Best/2/Bin
% 		tmpMyBestPos = gbest + F * ( ( memGBest( tmpIndexMemoryVect( 1 ), : ) - memGBest( tmpIndexMemoryVect( 2 ), : ) ) + ( memGBest( tmpIndexMemoryVect( 3 ), : ) - memGBest( tmpIndexMemoryVect( 4 ), : ) ) );       
% 
% 		%Current-to-rand/1/Bin
% 		tmpMyBestPos = myBestPos + F * ( ( memGBest( tmpIndexMemoryVect( 1 ), : ) - memGBest( tmpIndexMemoryVect( 2 ), : ) ) + ( memGBest( tmpIndexMemoryVect( 3 ), : ) - myBestPos ) );       
% 		
% 		%Current-to-best/1/Bin
%		tmpMyBestPos = myBestPos + F * ( ( memGBest( tmpIndexMemoryVect( 1 ), : ) - memGBest( tmpIndexMemoryVect( 2 ), : ) ) + ( gbest - myBestPos ) );       
        
        
        %%Current-to-best/1/Bin %%%% CAROL  %%%
%         nx = size(pos);
%         nx = randsample(nx,2);
%         nx = nx';
%  		tmpMyBestPos = myBestPos + F * ( ( pos(nx(1)) -  memGBest( tmpIndexMemoryVect( 1 ), : )) + ( gbest - myBestPos ) );   
% 		
% 		%Rand-to-best/1/Bin
% 		tmpMyBestPos = memGBest( tmpIndexMemoryVect( 1 ), : ) + F * ( ( memGBest( tmpIndexMemoryVect( 2 ), : ) - memGBest( tmpIndexMemoryVect( 3 ), : ) ) + ( gbest - memGBest( tmpIndexMemoryVect( 1 ), : ) ) );  
          
        tmpIndexD = randsample( D, 1 );
        tmpRand = rand( 1, D );
        for i = 1 : D
            if ~( ( tmpRand( i ) < CR ) || ( i == tmpIndexD ) )
                tmpMyBestPos( i ) = gbest( i );
            end
            % check pos limits
            if tmpMyBestPos( i ) < Xmin( i )
                tmpMyBestPos( i ) = Xmin( i );
            elseif tmpMyBestPos( i ) > Xmax( i )
                tmpMyBestPos( i ) = Xmax( i );
            end
        end
        % select the position to use as memory
        tmpMyBestPosFit = FITNESS_FUNCTION( 1, tmpMyBestPos );
        if( tmpMyBestPosFit > myBestPosFit )
            tmpMyBestPos = myBestPos;
            tmpMyBestPosFit = myBestPosFit;
        end      
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%