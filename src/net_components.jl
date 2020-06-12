using JuMP
using AutoHashEquals

export Layer, NeuralNet

JuMPLinearType = Union{JuMP.Variable,JuMP.AffExpr}
JuMPReal = Union{Real,JuMPLinearType}

include("net_components/core_ops.jl")

"""
$(TYPEDEF)

Supertype for all types storing the parameters of each layer. Inherit from this
to specify your own custom type of layer. Each implementation is expected to:

1. Implement a callable specifying the output when any input of type `JuMPReal` is provided.
"""
abstract type Layer end

"""
An array of `Layers` is interpreted as that array of layer being applied
to the input sequentially, starting from the leftmost layer. (In functional programming
terms, this can be thought of as a sort of `fold`).
"""
chain(x::Array{<:JuMPReal}, ps::Array{<:Layer,1}, layerId::Int64, filename::String) = length(ps) == 0 ? x : chain(ps[1](x, layerId, filename), ps[2:end], layerId + 1, filename)

(ps::Array{<:Layer,1})(x::Array{<:JuMPReal}; summary_file_name::String="") = chain(x, ps, 1, summary_file_name)

function check_size(input::AbstractArray, expected_size::NTuple{N,Int})::Nothing where {N}
    input_size = size(input)
    @assert input_size == expected_size "Input size $input_size did not match expected size $expected_size."
end

include("net_components/layers.jl")

"""
$(TYPEDEF)

Supertype for all types storing the parameters of a neural net. Inherit from this
to specify your own custom architecture. Each implementation
is expected to:

1. Implement a callable specifying the output when any input of type `JuMPReal` is provided
2. Have a `UUID` field for the name of the neural network.
"""
abstract type NeuralNet end

include("net_components/nets.jl")
