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
function CDEEPSO(fhd,ii,jj,kk,args)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING PARAMETERS
global proc;
global ps;
% Reinitialization of local
% function evaluation counter.
proc.i_eval=0;
% Function evaluation at which
% the last update of the global
% best solution occurred.
% Refers to the internal evaluation
% using static penalty constraint
% handling method.
proc.last_improvement=1;
% Signalizing your
% to stop running.
proc.finish=0;
% Dimensionality of test case.
% Particles' lower bounds.
Xmin=ps.x_min;
% Particles' upper bounds.
Xmax=ps.x_max;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ngl = 1; %20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE strategic parameters of DEEPSO
global cdeepso_par;
global ff_par;
cdeepso_par.memGBestMaxSize = ceil( proc.pop_size * 0.1 );
switch proc.system
    case 41
        cdeepso_par.mutationRate = 0.7; %0.8;
        cdeepso_par.communicationProbability = 0.5; % 0.6;
        cdeepso_par.localSearchProbability = 0.3; %0.3;
        cdeepso_par.localSearchContinuousDiscrete = 0.15; %0.15;
        ff_par.excludeBranchViolations = 1; %1;
        ff_par.factor = 1;
    otherwise
end
if proc.test_case == 1
    ff_par.numCoefFF = 3;
else
    ff_par.numCoefFF = 4;
end
ff_par.avgCoefFF = zeros( 1, ff_par.numCoefFF );
ff_par.coefFF = ones( 1, ff_par.numCoefFF );
ff_par.numFFEval = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE generation counter
countGen = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANDOMLY INITIALIZE CURRENT population
if proc.system ~= 41
    for i = 1 + ps.D_cont : ps.D_cont + ps.n_OLTC
        Xmin( 1, i ) = Xmin( 1, i ) - 0.4999;
        Xmax( 1, i ) = Xmax( 1, i ) + 0.4999;
    end
else
    for i = 1 + ps.n_gen_VS : ps.n_gen_VS + ps.n_OLTC
        Xmin( 1, i ) = Xmin( 1, i ) - 0.4999;
        Xmax( 1, i ) = Xmax( 1, i ) + 0.4999;
    end
    Xmin( 1, ps.D ) = Xmin( 1, ps.D ) - 0.4999;
    Xmax( 1, ps.D ) = Xmax( 1, ps.D ) + 0.4999;
end
Vmin = -Xmax + Xmin;
Vmax = -Vmin;
pos = zeros( proc.pop_size, ps.D );
vel = zeros( proc.pop_size, ps.D );
for i = 1 : proc.pop_size
    pos( i, : ) = Xmin + ( Xmax - Xmin ) .* rand( 1, ps.D );
    vel( i, : ) = Vmin + ( Vmax - Vmin ) .* rand( 1, ps.D );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE strategic parameters of DEEPSO
communicationProbability = cdeepso_par.communicationProbability;
mutationRate = cdeepso_par.mutationRate;
% Weights matrix
% 1 - inertia
% 2 - memory
% 3 - cooperation
% 4 - perturbation
weights = rand( proc.pop_size, 5 );
weights( :, 6 ) =  (rand(proc.pop_size, 1)*0.6)+0.4;%2 * rand( proc.pop_size, 1 );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EVALUATE the CURRENT population
[ fit, ~, ~, pos, ~ ] = feval( fhd, ii, jj, kk, args, pos );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE GLOBAL BEST
[ gbestval, gbestid ] = min( fit );
gbest = pos( gbestid, : );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number particles saved in the memory of the DEEPSO
memGBestMaxSize = cdeepso_par.memGBestMaxSize;
memGBestSize = 1;
% Memory of the DEEPSO
memGBest( memGBestSize, : ) = gbest;
memGBestFit( 1, memGBestSize ) = gbestval;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE INDIVIDUAL BEST
% Individual best position ever of the particles of CURRENT population
myBestPos = pos;
% Fitness of the individual best position ever of the particles of CURRENT population
myBestPosFit = fit;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while 1  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COPY CURRENT population
    copyPos = pos;
    copyVel = vel;
    copyWeights = weights;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % UPDATE MEMORY (SgPB)
    tmpMemGBestSize = memGBestSize + proc.pop_size;
    tmpMemGBestFit = cat( 2, memGBestFit, fit );
    tmpMemGBest = cat( 1, memGBest, pos );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE PERSONAL BEST
for i = 1 : proc.pop_size
    [ tmpMyBestPos, tmpMyBestPosFit ] = CDEEPSO_COMPUTE_NEW_PERSONAL_BEST( ps.D, weights( i, 5 ), weights( i, 6 ), ...
    myBestPos( i, : ), myBestPosFit( i ), gbest, tmpMemGBestSize, tmpMemGBest, tmpMemGBestFit, Xmin, Xmax );
    myBestPos( i, : ) = tmpMyBestPos;
    myBestPosFit( i ) = tmpMyBestPosFit;
    if myBestPosFit( i ) < fit( i )
        pos( i, : ) = myBestPos( i, : );
        fit( i ) = myBestPosFit( i );
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if rand() > cdeepso_par.localSearchProbability; % com chance
         
        for i = 1 : proc.pop_size
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CDEEPSO movement rule
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE NEW VELOCITY for the particles of the CURRENT population
            vel( i, : ) = CDEEPSO_COMPUTE_NEW_VEL(pos( i, : ), gbest, fit( i ), tmpMemGBestSize, tmpMemGBestFit, tmpMemGBest, vel( i, : ), Vmin, Vmax, weights( i, : ), communicationProbability);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE NEW POSITION for the particles of the CURRENT population
            [ pos( i, : ), vel( i, : ) ] = COMPUTE_NEW_POS( pos( i, : ), vel( i, : ) );
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % DEEPSO movement rule
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % MUTATE WEIGHTS of the particles of the COPIED population
            copyWeights( i, : ) = MUTATE_WEIGHTS( weights( i, : ), mutationRate );
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE NEW VELOCITY for the particles of the COPIED population
            copyVel( i, : ) = CDEEPSO_COMPUTE_NEW_VEL( copyPos( i, : ), gbest, fit( i ), tmpMemGBestSize, tmpMemGBestFit, tmpMemGBest, copyVel( i, : ), Vmin, Vmax, copyWeights( i, : ), communicationProbability );
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE NEW POSITION for the particles of the COPIED population
            [ copyPos( i, : ), copyVel( i, : ) ] = COMPUTE_NEW_POS( copyPos( i, : ), copyVel( i, : ) );
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ENFORCE search space limits of the COPIED population
        [ copyPos, copyVel ] = ENFORCE_POS_LIMITS( copyPos, Xmin, Xmax, copyVel, Vmin, Vmax );
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ENFORCE search space limits of the CURRENT population
        [ pos, vel ] = ENFORCE_POS_LIMITS( pos, Xmin, Xmax, vel, Vmin, Vmax );
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % EVALUATE the COPIED population
        [ copyFit, ~, ~, copyPos, ~ ] = feval( fhd, ii, jj, kk, args, copyPos );
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % EVALUATE the CURRENT population
        [ fit, ~, ~, pos, ~ ] = feval( fhd, ii, jj, kk, args, pos );
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CREATE NEW population to replace CURRENT population
        selParNewSwarm = ( copyFit < fit );
        for i = 1 : proc.pop_size
            if selParNewSwarm( i )
                fit( i ) = copyFit( i );
                pos( i, : ) = copyPos( i, : );
                vel( i, : ) = copyVel( i, : );
                weights( i, : ) = copyWeights( i, : );
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if countGen < ngl %30
            disp('aqui')
            Y=[];
            P=pos(1,:);
            for ind=1 : size(fit,2)
                t=rand()*2*pi;
                r=rand();
                a=cos(t);
                b=sin(t);
                M1=eye(size(pos,2));
                M=eye(size(pos,2));
                M(1,1)=a;
                M(1,2)=-b;
                M(2,2)=a;
                M(2,1)=b;
                
                for i=1 : size(pos,2)/4
                    for j=(i+1) : size(pos,2)
                        M1=eye(size(pos,2));
                        if ~(i == 1 && j == 2)
                            M1(i,i)=a;
                            M1(i,j)=-b;
                            M1(j,j)=a;
                            M1(j,i)=b;
                            M=M*M1;
                        end
                    end
                end
            %   Y=[Y; P*r*M];
                Y=[Y; -P*r*M];
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [ Y,~ ] = ENFORCE_POS_LIMITS( Y, Xmin, Xmax, zeros(size(Y,1)), Vmin, Vmax );   
            [ fitaux, ~, ~, Y, ~ ] = feval( fhd, ii, jj, kk, args, Y );
            [fitaux, sortindex]=sort(fitaux);
            Y=Y(sortindex,:);
            troca = 1; % troca eh a quantidade de gente que troca
            fitaux=fitaux(1:troca); 
            Y=Y(1:troca,:); % 
            populacaoaux=[pos;Y];
            fitaux=[fit,fitaux];
            [fitsorted, sortindex]=sort(fitaux);
            posaux=populacaoaux(sortindex,:);
            pos=posaux(1:size(pos,1),:);
            fit=fitsorted(1:size(pos,1));
        else                            
            posmat=[pos,pos,pos];
            fitmat=[fit,fit,fit];
            for ind=1 : size(fit,2)
                for dim=1 : size(pos,2)/4
                    media= (sqrt(5)-1)/2*mean(pos(ind,dim)-pos(:,dim)); % Best: pos(ind,dim)-pos(1,dim) - Rand: round(pos(ind,dim)-fit(1,dim))+1 - Media: mean(pos(ind,dim)-pos(:,dim));
                    cand=2;                
                    posmat(ind,((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2))=posmat(ind,((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2))+media;
                    cand=3;
                    posmat(ind,((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2))=posmat(ind,((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2))-media;
                end
            end

            for cand=2 : 3
                [ posmat(1:size(pos,1),((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2)), vel ] = ENFORCE_POS_LIMITS( posmat(1:size(pos,1),((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2)), Xmin, Xmax, vel, Vmin, Vmax );
                [ fitmat((cand-1)*size(fit,2)+1:(cand)*size(fit,2)), ~, ~, posmat(1:size(pos,1),((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2)), ~ ] = feval( fhd, ii, jj, kk, args, posmat(1:size(pos,1),((cand-1)*size(pos,2))+1:(cand-1)*size(pos,2)+size(pos,2)) );
            end
            for ind=1 : size(fit,2)
                menorit=1;
                for it=1 : 3
                    if fitmat((it-1)*size(fit,2)+ind) < fitmat((menorit-1)*size(fit,2)+ind)
                        menorit=it;
                    end
                end
                if rand() > 0.05 
                    pos(ind, :) = posmat(ind,((menorit-1)*size(pos,2))+1:(menorit-1)*size(pos,2)+size(pos,2));
                    fit(ind) = fitmat((menorit-1)*size(fit,2)+ind);
                else
                    itrand=round(rand()*2+1);
                    pos(ind, :) = posmat(ind,((itrand-1)*size(pos,2))+1:(itrand-1)*size(pos,2)+size(pos,2));
                    fit(ind) = fitmat((itrand-1)*size(fit,2)+ind);
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % UPDATE GLOBAL BEST
    [ tmpgbestval, gbestid ] = min( fit );
    if tmpgbestval < gbestval
        gbestval = tmpgbestval;
        gbest = pos( gbestid, : );
        % UPDATE MEMORY DEEPSO
        if memGBestSize < memGBestMaxSize
            memGBestSize = memGBestSize + 1;
            memGBest( memGBestSize, : ) = gbest;
            memGBestFit( 1, memGBestSize ) = gbestval;
        else
            [ ~, tmpgworstid ] = max( memGBestFit );
            memGBest( tmpgworstid, : ) = gbest;
            memGBestFit( 1, tmpgworstid ) = gbestval;
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % RE-CALCULATES NEW COEFFICIENTS for the fitness function
    CALC_COEFS_FF();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % UPDATE generation counter
    countGen = countGen + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%
    if proc.finish
        return;
    end
    %%%%%%%%%%%%%%
end
end
