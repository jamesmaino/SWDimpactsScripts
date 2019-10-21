# Ativate the Julia project

# Load dependencies
using Pkg
Pkg.activate(".")
using Revise, GeoData
using GeoData: Lat, Lon, Time
using HDF5, JLD2, Dates, DynamicGrids, Dispersal, CSV
Threads.nthreads()


# Load simualtions for USA
datafile = "spread_inputs_US_SWD.h5"
starttime = DateTime(2008, 5)
timestep = Month(1) 
stoptime = DateTime(2013, 12)
include("setup_rulesets.jl")
sim_rulesets, init, objective, output = setup_rulesets(datafile, starttime, timestep, stoptime);

# Optimiser setting (also needed for EU replicates)
# threading = Dispersal.SingleCoreReplicates()
threading = Dispersal.ThreadedReplicates()
groupsize = 10 
ngroups = 5 # should be roughly physical cpus - 1
iterations = 2

filename = "optimresults_latest.jld2"
runoptim = true
typeof(output)
ruleset = sim_rulesets[:full]
