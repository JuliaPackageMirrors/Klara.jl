tests =
  [
    "VariableStates",
    "ParameterStates",
    "VariableNStates",
    "ParameterNStates",
    "VariableIOStreams",
    "ParameterIOStreams",
    "variables",
    "ContinuousUnivariateParameter",
    "ContinuousMultivariateParameter",
    "dependencies",
    "GenericModel",
    "generators"
  ]

println("Running tests:")

for t in tests
  tfile = t*".jl"
  println("  * $(tfile) *")
  include(tfile)
end
