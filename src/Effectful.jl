module Effectful

export Operation, AbstractHandler, runwith, @effectful

using CompositionsBase

abstract type Operation end
abstract type AbstractHandler end

include("effectful_macro.jl")
include("composed.jl")


@inline (h::AbstractHandler)((@nospecialize x), (@nospecialize val=nothing)) = x

function runwith(handler, f, args...; kwargs...)
    f(args...; kwargs...)(handler)
end

runop(h, op, val, args...; kwargs...) = val


@inline function (@nospecialize h::AbstractHandler)((@nospecialize op::Operation), (@nospecialize val=nothing))
    @inline function(args...; kwargs...)
        runop(h, op, val, args...; kwargs...)
    end
end

end
