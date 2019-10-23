using LocallyWeightedRegression
using GeoStatsBase
using Variography
using Plots; gr()
using VisualRegressionTests
using Test, Pkg, Random

ENV["GKSwstype"] = "100"

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__,"data")
visualtests = !istravis || (istravis && islinux)
if !istravis
  Pkg.add("Gtk")
  using Gtk
end

@testset "1D regression problem" begin
  Random.seed!(2017)

  N = 100
  x = range(0, stop=1, length=N)
  y = x.^2 .+ [i/1000*randn() for i=1:N]

  sdata   = PointSetData(Dict(:y => y), reshape(x, 1, length(x)))
  sdomain = RegularGrid((0.,), (1.,), dims=(N,))
  problem = EstimationProblem(sdata, sdomain, :y)

  solver = LocalWeightRegress(:y => (variogram=ExponentialVariogram(range=3/10),))

  solution = solve(problem, solver)

  yhat, yvar = solution[:y]

  if visualtests
    @plottest begin
      scatter(x, y, label="data", size=(1000,400))
      plot!(x, yhat, ribbon=yvar, fillalpha=.5, label="LWR")
    end joinpath(datadir,"solution.png") !istravis
  end
end
