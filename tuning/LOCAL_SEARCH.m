function [ new_pos ] = LOCAL_SEARCH( pos, Xmin, Xmax , a)
% Mutates the integer part of the particle
global proc
global ps
global deepso_par
new_pos = pos;
switch proc.system
    case 41
        % Select which type of variables will be mutated
        prob = deepso_par.localSearchContinuousDiscrete;
        if rand() > prob
            prob = 1 / ( ps.n_gen_VS + 1 );
            for i = 1 : ps.n_gen_VS
                tmpDim = i;
                if rand() < prob
                    new_pos( tmpDim ) = LOCAL_SEARCH_CONTINUOUS( new_pos( tmpDim ), Xmin( tmpDim ), Xmax( tmpDim ),a);
                end
            end
            if rand() < prob
                tmpDim = ps.n_gen_VS + ps.n_OLTC + 1;
                new_pos( tmpDim ) = LOCAL_SEARCH_CONTINUOUS( new_pos( tmpDim ), Xmin( tmpDim ), Xmax( tmpDim ),a );
            end
        else
            prob = 1 / ( ps.n_OLTC + 1 );
            for i = 1 : ps.n_OLTC;
                tmpDim = ps.n_gen_VS + i;
                if rand() < prob
                    new_pos( tmpDim ) = LOCAL_SEARCH_DISCRETE( new_pos( tmpDim ), Xmin( tmpDim ), Xmax( tmpDim ), a);
                end
            end
            if rand() < prob
                tmpDim = ps.n_gen_VS + ps.n_OLTC + ps.n_SH;
                new_pos( tmpDim ) = LOCAL_SEARCH_DISCRETE( new_pos( tmpDim ), Xmin( tmpDim ), Xmax( tmpDim ) ,a);
            end
        end
    otherwise
        prob = deepso_par.localSearchContinuousDiscrete;
        if rand() > prob
            prob = 1 / ps.D_cont;
            for i = 1 : ps.D_cont;
                tmpDim = i;
                if rand() < prob
                    new_pos( tmpDim ) = LOCAL_SEARCH_CONTINUOUS( new_pos( tmpDim ), Xmin( tmpDim ), Xmax( tmpDim ),a );
                end
            end
        else
            prob = 1 / ps.D_disc;
            for i = 1 : ps.D_disc;
                tmpDim = ps.D_cont + i;
                if rand() < prob
                    new_pos( tmpDim ) = LOCAL_SEARCH_DISCRETE( new_pos( tmpDim ), Xmin( tmpDim ), Xmax( tmpDim ), a);
                end
            end
        end
end
end