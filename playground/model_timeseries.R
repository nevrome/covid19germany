## globals:
MIN.CASES=5
N.DAYS.FUTURE=7

## read data:
df = get_RKI_timeseries()

## aggregate case-counts by regions:
ag=aggregate(df$AnzahlFall,by=list(Bundesland=df$Bundesland,Meldedatum=df$Meldedatum),sum)

## split data by regions:
ag.split=split(ag,ag$Bundesland)

## plot
par(mfrow=c(4,4))
for (this.ag in ag.split){
  keep=(this.ag$x>=MIN.CASES)
  this.ag=this.ag[keep,]
  this.region=unique(this.ag$Bundesland)
  
  ## create model
  this.ag = this.ag[order(this.ag$Meldedatum),]
  this.ag[,"x.log"]=log(this.ag[,"x"])
  mdl=lm("x.log ~ Meldedatum",data=this.ag)

  ## append N.DAYS.FUTURE to data
  n=(nrow(this.ag)+1)
  last.date=as.Date(max(this.ag$Meldedatum))
  this.ag[n:(n+N.DAYS.FUTURE-1),]=NA
  this.ag[n:(n+N.DAYS.FUTURE-1),"Meldedatum"]=seq(last.date+1,by=1,length.out=N.DAYS.FUTURE)

  ## predict on all dates (including future dates)
  this.ag[,"x.pred"]=exp(predict(mdl,newdata=this.ag))

  ## plot data and prediction
  ymax=max(this.ag[,c("x.pred","x")],na.rm=TRUE)
  plot(this.ag[,"Meldedatum"],this.ag[,"x"],type="b",col="black",pch=20,main=this.region,xlab="date",ylab="cases",ylim=c(0,ymax))
  points(this.ag[,"Meldedatum"],this.ag[,"x.pred"],type="b",col="red")
}
