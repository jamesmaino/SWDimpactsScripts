# Ativate the Julia project

# Load dependencies
using Pkg
Pkg.activate(".")
using Revise, GeoData
using GeoData: Lat, Lon, Time
using HDF5, JLD2, Dates, DynamicGrids, Dispersal, CSV


# Load simualtions for USA
datafile = "spread_inputs_Au_SWD.h5"
starttime = DateTime(2008, 5)
timestep = Month(1) 
stoptime = DateTime(2013, 12)
tspan = starttime, stoptime
include("setup_rulesets.jl")
sim_rulesets, init = setup_rulesets(datafile, starttime, timestep, stoptime);

ruleset = sim_rulesets[:full];

output = ArrayOutput(init, length(starttime:timestep:stoptime))
sim!(output, ruleset; init=init, tspan=tspan)
