# Load packages and raster files
using DynamicGridsGtk
using Revise, GeoData, ArchGDAL; const AG = ArchGDAL
using GeoData: Lat, Lon, Time
using HDF5, JLD2, Dates, DynamicGrids, Dispersal, CSV, Statistics
using Plots, Distributions


# Load simualtions for USA
datafile = "spread_inputs_Aus_SWD.h5"
starttime = DateTime(2008, 1)
timestep = Month(1)
stoptime = DateTime(2018, 12)
tspan = starttime, stoptime
tstop = length(starttime:timestep:stoptime)
include("setup_rulesets.jl")
sim_rulesets, init = setup_rulesets(datafile, starttime, timestep, stoptime);
init.dims
init .= 0 ;
init[Lat(Near(-37)), Lon(Near(145))] = 1e9;
DimensionalData.dims2indices(init, (Lat(Near(-37)), Lon(Near(145))))

ruleset = sim_rulesets[:full];
sum(output[tstop])
output = ArrayOutput(init, tstop);
sim!(output, ruleset; init=init, tspan=tspan);
heatmap(convert(Array, output[tstop]))
heatmap(reverse(convert(Array, output[4]), dims = 1))

# loop over all locations and reps
maxval = 1e9
spreadfileout = string("simout/spread_sim_Aus_save.h5")
isfile(spreadfileout) ? rm(spreadfileout) : false
data = h5open(datafile, "r")
extrainit = read(data["x_y_initial"])
locnames = collect(keys(extrainit))
reps = 1:10 # simulation replicates
for locname in locnames
      init = extrainit[locname] * maxval
      ruleset.init = init
      for rep in reps
            println(locname, rep)
            output = ArrayOutput(init, tstop)
            sim!(output, ruleset; init=init, tspan=tspan)
            out_array = zeros(size(init)...)
            for k = 1:tstop, i= 1:size(init)[1], j = 1:size(init)[2]
                  if out_array[i, j] == 0 && output[k][i, j] > 0
                        out_array[i, j] = k
                  end
            end
            # GtkOutput(out_array[:, :, tstop])
            h5write(spreadfileout, string(locname, "/", rep), out_array)
      end
end

# create grid
starttime = DateTime(2008, 7)
timestep = Month(1)
stoptime = DateTime(2009, 6)
tspan = starttime, stoptime
tstop = length(starttime:timestep:stoptime)

ausmask = read(data["x_y_month_intrinsicGrowthRate"])[:,:,1];
cellsinvaded = Array(init);
cellsinvaded .= 0;

stepsize = 50
nreplicates = 10
cellsinvaded = zeros(length(stepsize:stepsize:size(init)[1]),
      length(stepsize:stepsize:size(init)[2]))
for i = stepsize:stepsize:size(init)[1], j = stepsize:stepsize:size(init)[2]
      if !isnan(ausmask[i, j])
            println(i,", ", j)
            init .= 0
            init[i, j] = 1e9
            icells = 0
            for k in 1:nreplicates
                  sim!(output, ruleset; init=init, tspan=tspan)
                  icells += sum(convert(Array, output[tstop]) .> 0)
            end
            cellsinvaded[i ÷ stepsize, j ÷ stepsize] = icells / nreplicates
      end
end
