functions {
  real growth_model(real I0, real alpha0, real beta, real t) {
    return I0 * exp((alpha0 - beta * t) * t);
  }
}
data { 
  int N; 
  real cases[N];
  real deaths[N];
  int day[N];
  real<lower=0> tau_t;
  real<lower=0> tau_delta;
  real<lower=0> delta;
} 
parameters {
  real<lower=0,upper=1> gamma;
  real<lower=0,upper=1> alpha0;
  real<lower=0,upper=1> beta;
  real<lower=0,upper=1e6> I0;
} 
model {
    for(i in 1:N) {
      real nc = growth_model(I0, alpha0, beta, day[i] - tau_t);
      cases[i] ~ normal(nc * gamma, nc * gamma * (1 - gamma));
      real nd = growth_model(I0, alpha0, beta, day[i] - tau_delta); 
      deaths[i] ~ normal(nd * delta, nd * delta * (1 - delta));
    }
}
