%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task Force on Modern Heuristic Optimization Test Beds
% Working Group on Modern Heuristic Optimization
% Intelligent Systems Subcommittee
% Power System Analysis, Computing, and Economic Committee
%
% Sebastian Wildenhues (E-Mail: sebastian.wildenhues@uni-due.de)
% 14th February 2014
%
% Application of Modern Heuristic Optimization Algorithms 
% for Solving Optimal Power Flow Problems
% 
% Incorporating basic Particle Swarm Optimization (PSO) algorithm as 
% optimization engine to solve test bed declarations V1.4.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function psopt(fhd,ii,jj,kk,args)
    % Paste and adapt the following 
    % parts to your implementation.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	global proc
    global ps
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
    % Size of the swarm.
    n_par=proc.pop_size;
    % For dynamic weight adaption.
    me=proc.n_eval;
    % Dimensionality of test case.
    D=ps.D;
    % Individuals' lower bounds.
    VRmin=ps.x_min;
    % Individuals' upper bounds.
    VRmax=ps.x_max;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cc=[2 2];
    iwt=0.9-(1:me).*(0.5./me);
    if length(VRmin)==1
        VRmin=repmat(VRmin,1,D);
        VRmax=repmat(VRmax,1,D);
    end
    VRmin=repmat(VRmin,n_par,1);
    VRmax=repmat(VRmax,n_par,1);
    Vmin=VRmin;
    Vmax=VRmax;
    pos=VRmin+(VRmax-VRmin).*rand(n_par,D);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	[fit,obj,g_sum,pos,fit_best]=feval(fhd,ii,jj,kk,args,pos);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vel=Vmin+2.*Vmax.*rand(n_par,D);
    pbest=pos;
    pbestval=fit;
    [gbestval,gbestid]=min(pbestval);
    gbest=pbest(gbestid,:);
    gbestrep=repmat(gbest,n_par,1);

    i=2;
    
    % Instead of your common stopping
    % criterion, use an undefined 
    % expression at this point.
    % Your implementation will be
    % cancelled intrinsically by flag
    % proc.finish from test bed
    % declarations in test_bed_OPF.p.
    %%%%%%%
    while 1
    %%%%%%%
        aa=cc(1).*rand(n_par,D).*(pbest-pos)+cc(2)...
            *rand(n_par,D).*(gbestrep-pos);
        vel=iwt(i).*vel+aa;
        vel=(vel>Vmax).*Vmax+(vel<=Vmax).*vel;
        vel=(vel<Vmin).*Vmin+(vel>=Vmin).*vel;
        pos=pos+vel;
        pos=((pos>=VRmin)&(pos<=VRmax)).*pos+...
            (pos<VRmin).*(VRmin+0.25.*(VRmax-VRmin).*rand(n_par,D))+...
            (pos>VRmax).*(VRmax-0.25.*(VRmax-VRmin).*rand(n_par,D));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [fit,obj,g_sum,pos,fit_best]=feval(fhd,ii,jj,kk,args,pos);
        fit_best
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        tmp=(pbestval<fit);
        temp=repmat(tmp',1,D);
        pbest=temp.*pbest+(1-temp).*pos;
        pbestval=tmp.*pbestval+(1-tmp).*fit;
        [gbestval,tmp]=min(pbestval);
        gbest=pbest(tmp,:);
        gbestrep=repmat(gbest,n_par,1);
        
        %%%%%%%%%%%%%%
        if proc.finish
            return;
        end
        %%%%%%%%%%%%%%
        
        % To prematurely stop
        % running the current trial,
        % you may use a statement
        % as the following.
        % However, note that
        % storage of intermediate 
        % results must be done 
        % manually since no ASCII
        % file output will be 
        % provided in that case.
        % As an example, retrieve
        % relevant information
        % from cell array res.
%         %%%%%%%%%%%%%%%%%%%%
%         if proc.i_eval>=1000
%             return;
%         end
%         %%%%%%%%%%%%%%%%%%%%
    end
end