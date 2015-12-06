Lora.jl
==============================

[![Build Status](https://travis-ci.org/JuliaStats/Lora.jl.svg?branch=master)](https://travis-ci.org/JuliaStats/Lora.jl)
[![Lora](http://pkg.julialang.org/badges/Lora_0.3.svg)](http://pkg.julialang.org/?pkg=Lora&ver=0.3)
[![Lora](http://pkg.julialang.org/badges/Lora_0.4.svg)](http://pkg.julialang.org/?pkg=Lora&ver=0.4)
[![Docs](https://readthedocs.org/projects/lorajl/badge/?version=latest)](http://lorajl.readthedocs.org/en/latest/)

The Julia *Lora* package provides a generic engine for Markov Chain Monte Carlo (MCMC) inference.

*Lora* has undergone a major upgrade. Model specification has been internally altered, and it is now based on graphs. New
functionality has been added, yet some of the old one has not been fully ported. The full porting of old functionality, as
well as further developments, will be completed shortly. Progress is being tracked systematically via issues and milestones.

The documentation is out of date, but will be brought up-to-date fairly soon. In the meantime, this README file provides a
few examples of the new interface, explaining how to get up to speed with the new face of Lora.

Example 1: sampling from an unnormalized normal target
------------------------------

```
using Lora

### Define the vector of keys referring to model variables
### For this naive example, the model consists of a single parameter represented by the :p key

vkeys = [:p]

### Define the log-target, which must be a generic function

plogtarget(z::Vector{Float64}) = -dot(z, z)

### Define the parameter via BasicContMuvParameter (it is a continuous multivariate variable)
### The input arguments for BasicContMuvParameter are:
### 1) vkeys, the vector of variable keys,
### 2) the index of the current variable in vkeys,
### 3) the log-target

p = BasicContMuvParameter(vkeys, 1, logtarget=plogtarget)

#### Define the model using the single_parameter_likelihood_model generator

model = single_parameter_likelihood_model(p)

### Define a Metropolis-Hastings sampler with an identity covariance matrix

sampler = MH(ones(2))

### Set MCMC sampling range

mcrange = BasicMCRange(nsteps=10000, burnin=1000)

### Set initial values for simulation

v0 = Dict(:p=>[5.1, -0.9])

### Specify job to be run

job = BasicMCJob(model, sampler, mcrange, v0)

### Run the simulation

chain = run(job)

### Get simulated values

chain.value

### Check that the simulated values are close to the zero-mean target

[mean(chain.value[i, :]) for i in 1:2]
```

To reset the job, using a new initial value for the targeted parameter, run

```
job.reset!([3.2, 9.4])

chain = run(job)
```

To see how the acceptance rate changes during burnin, set the vanilla tuner in verbose mode

```
job = BasicMCJob(model, sampler, mcrange, v0, tuner=VanillaMCTuner(verbose=true))

chain = run(job)
```

If apart from the simulated chain you also want to store the log-target, then pass an additional dictionary to the job to
specify the output options. In particular, the `:monitor` key indicates which items will be monitored. In the example below,
both `:value` and `:logtarget` will be monitored, referring to the chain and log-target respectively. These can then be
accessed by the corresponding fields `chain.value` and `chain.logtarget`:

```
outopts = Dict{Symbol, Any}(:monitor=>[:value, :logtarget])

job = BasicMCJob(model, sampler, mcrange, v0, tuner=VanillaMCTuner(verbose=true), outopts=outopts)

chain = run(job)

chain.logtarget
```

The acceptance ratio diagnostics can be stgored via the `:diagnostics=>[:accept]` entry of `outopts`:

```
outopts = Dict{Symbol, Any}(:monitor=>[:value, :logtarget], :diagnostics=>[:accept])

job = BasicMCJob(model, sampler, mcrange, v0, tuner=VanillaMCTuner(verbose=true), outopts=outopts)

chain = run(job)
```

Instead of saving the output in memory, it can be written in file via the output option `:destination=>:iostream`:

```
outopts = Dict{Symbol, Any}(
  :monitor=>[:value, :logtarget],
  :diagnostics=>[:accept],
  :destination=>:iostream
)

job = BasicMCJob(model, sampler, mcrange, v0, tuner=VanillaMCTuner(verbose=true), outopts=outopts)

run(job)
```

The chain, log-target and acceptance ratio diagnostics of the above example are stored in the respective CSV files
"value.csv", "logtarget.csv" and "diagnosticvalues.csv" of the current directory. To save the output in another directory,
use the `:filepath=>"myfullpath.csv"`, where "myfullpath.csv" is substituted by the full path of your choice:

```
outopts = Dict{Symbol, Any}(
  :monitor=>[:value, :logtarget],
  :diagnostics=>[:accept],
  :destination=>:iostream,
  :filepath=>"/Users/theodore/workspace/julia"
)

job = BasicMCJob(model, sampler, mcrange, v0, tuner=VanillaMCTuner(verbose=true), outopts=outopts)

run(job)
```

To use Julia tasks for running the job, set `plain=false`:

```
outopts = Dict{Symbol, Any}(:monitor=>[:value, :logtarget], :diagnostics=>[:accept])

job = BasicMCJob(model, sampler, mcrange, v0, tuner=VanillaMCTuner(verbose=true), outopts=outopts, plain=false)

chain = run(job)
```

Task-based jobs can also be reset:

```
job.reset!([-2.8, 3.4])

chain = run(job)
```

Documentation
------------------------------

Please note that the documentation needs to be updated and it does not reflect yet the current version of *Lora*.

* [User Guide](http://mcmcjl.readthedocs.org/en/latest/) ([PDF](https://readthedocs.org/projects/mcmcjl/downloads/pdf/latest/))
* Cheat Sheet (to appear soon)
