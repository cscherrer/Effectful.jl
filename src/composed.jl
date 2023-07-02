
struct ComposedHandler{T} <: AbstractHandler
    handlers::T
end

function runop(c::ComposedHandler, op::Operation, val, args...; kwargs...)
    _run_composed_handler(c.handlers, op, val, args...; kwargs...)
end


function _run_composed_handler(handlers, op, val, args...; kwargs...)
    val_0 = val
    for h in handlers
        val = runop(h, op, val, args...; kwargs...)
    end
    val
end


# @generated function _run_composed_handler(h::NTuple{N, <:AbstractHandler}, op::Operation, val, args...; kwargs...) where N
#     quote
#         println("N = ", $N)
#         val_0 = $val
#         Base.Cartesian.@nexprs $N i -> begin
#             val_{i} = runop(h[i], op, val_{i-1}, args...; kwargs...)
#         end
#     end
# end


# Base.:∘(h::AbstractHandler...) = ComposedHandler(reverse(h))
CompositionsBase.compose(h::AbstractHandler...) = ComposedHandler(reverse(h))
CompositionsBase.opcompose(h::AbstractHandler...) = ComposedHandler(h)
