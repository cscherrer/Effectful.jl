using Effectful

struct Put <: Operation end
const put = Put()

struct Get <: Operation end
const get = Get()

@effectful function f(x)
    put(x)
    get()
end

###############################################################################

mutable struct Stateful{S} <: AbstractHandler
	state::S
end

function Effectful.runop(h::Stateful, ::Put, val, x)
    h.state = x
end

function Effectful.runop(h::Stateful, ::Get, val)
    h.state
end


###############################################################################
# Printer

struct Printer <: AbstractHandler end

function Effectful.runop(h::Printer, op::Operation, val, args...; kwargs...)
    @show op, args, kwargs, val
    return val
end



@effectful function f(a)
    x = get()
    put(x + a)
    y = get()
    put(2y + a)
    get()
end

runwith(Printer() ∘ Stateful(0), f, 3)
