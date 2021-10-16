setwd('~/Documentos/JoaoVirgilio/pastaaux/tuning')
library('irace')
scenario <- readScenario(filename = 'scenario.txt', scenario = defaultScenario())

for(i in 1:96) {
  cat(toString(i),file="windfarms_prob.txt",sep="\n")
  #run irace
  scenario <- readScenario(filename = 'scenario.txt', scenario = defaultScenario())
  if(checkIraceScenario(scenario = scenario)) {
    #running irace
    irace.main(scenario = scenario)
    #changing name of result data
    aux_table<-iraceResults
    write.table(aux_table,file=paste('results',i,sep="_"))
  }
}
