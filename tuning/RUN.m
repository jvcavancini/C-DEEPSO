%This function is the main function with adaptations in order to run irace

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carolina Marcelino, PhD (email: carolimarc@gmail.com)
% Joao Virgilio de Castro Avancini, Bsc (email: joaovirgilio123@gmail.com)
% 15th October 2021
%
% Solving security constrained optimal power flow problems: 
% a hybrid evolutionary approach
%
% Canonical Differential Evolutionary Particle Swarm Optimization (CDEEPSO) 
% algorithm as optimization engine to solve test bed declarations V1.1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem extract from:
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
% Test bed declarations V1.0
%
% Employing MATPOWER as underlying power flow and basic Particle Swarm
% Evoluation (PSO) algorithm as optimization engine, you can use the
% test bed declarations as the template shown below.
%
% Results will be buffered and agglomerated automatically for storage to
% formatted ASCII-files. Refer to problem definitions and implementation
% guidelines for details.
%
% Note:
% This implementation has been tested using various MATLAB versions and
% hardware platforms. Feel free to contact us in case of incompatibilities.
% A MATPOWER installation must be on the MATLAB search path.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RUN(mutationRate, communicationProbability)

close all
clc
format short

global proc
global ps
global mpc
global res
global deType

problem_number_file_J=fopen('windfarms_prob.txt','r');
problem_number_J=fscanf(problem_number_file_J,'%d');

algorithm_name='CDEEPSO';
algorithm_hd=str2func(algorithm_name);
test_bed_OPF_hd=str2func('test_bed_OPF');
run_in_parallel=0;
show_lf_info=0;
refresh=1000;
deType=3;
i=0;
system=41;
switch system
    case 41
        pop_size = 40; %60
end

args{1}=system;
args{2}=show_lf_info;
args{3}=pop_size;
args{4}=refresh;
args{5}=algorithm_name;
args{6}=run_in_parallel;
args{7}=[];
args{8}=[];

v=ver;
toolbox_installed=any(strcmp('Parallel Computing Toolbox',{v.Name}));
if toolbox_installed
    isOpen=parpool('local')>0;
    if isOpen
        parpool close
    end
else
    run_in_parallel=0;
end

if run_in_parallel
    NumWorkers=16;
    local_sched=findResource('scheduler','type','local');
    local_sched.ClusterSize=NumWorkers;
    isOpen=parpool('size')>0;
    if ~isOpen
        parpool(NumWorkers);
    end
end

number_runs=0;

stop_test_case=0;


while ~stop_test_case
    i=i+1;
    j=problem_number_J-1;
    stop_scenario=0;
    while and(~stop_scenario,j<problem_number_J)
        number_runs=number_runs+1;
        j=j+1;
        %j=j+90;
        [stop_test_case,stop_scenario,err,obs]=test_bed_OPF_hd(i,j,1,args);
        args{7}=stop_test_case;
        args{8}=stop_scenario;
        if ~err
            parfor k=1:1
                test_bed_OPF_hd(i,j,k,args);
                feval(algorithm_hd,test_bed_OPF_hd,i,j,k,args,mutationRate,communicationProbability);
                fprintf('Run %d finished.\n',k);
            end
        end
    end
end

results_file_J=fopen(strcat('CDEEPSO_Cluster_41_1_',int2str(problem_number_J),'_run_1_fitness.txt'),'r');
A=fscanf(results_file_J,'%f');
best_fitness=A(length(A));

fprintf('Result for irace=%g\n', best_fitness);

end