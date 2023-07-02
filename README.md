# Effectful

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cscherrer.github.io/Effectful.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cscherrer.github.io/Effectful.jl/dev/)
[![Build Status](https://github.com/cscherrer/Effectful.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cscherrer/Effectful.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/cscherrer/Effectful.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cscherrer/Effectful.jl)

**Very exploratory, do not use**

## Example

Say we want to define `put` and `get` operations in a way that lets us provide semantics after the fact. Let's load the package and define these operations:
```julia
using Effectful

struct Put <: Operation end
const put = Put()

struct Get <: Operation end
const get = Get()
```

Now we can already write a program like
```julia
@effectful function f(x)
    put(x)
    get()
end
```

Semantics are defined in terms of _handlers_. Here's one that stores an internal state:
```julia
mutable struct Stateful{S} <: AbstractHandler
    state::S
end
```

Now we just need to define how `Stateful` handles operations:
```julia
function Effectful.runop(h::Stateful, op::Put, val, x)
    h.state = x
end

function Effectful.runop(h::Stateful, op::Get, val)
    h.state
end
```

Note that `x` here is an argument provided in the program. In our effectful function `f` this happens to also be called `x`. The `val` argument is the return value. This may seem strange, and it's mostly important when composing handlers. In that case, it allows a computed value to be passed through to other handlers or modified along the way.

Now we can run our program:
```julia
julia> runwith(Stateful(0), f, 3)
3
```

## Composing Handlers

Ok, that wasn't too exciting. Let's define a new `Printer` handler to see more of what's happening:
```julia
struct Printer <: AbstractHandler end

function Effectful.runop(h::Printer, op::Operation, val, args...)
    @show op, args, val
    return val
end
```

Here you can see the use of `val`. `Printer()` doesn't change anything, it just writes to screen and then passes along the incoming `val`. Now we can compose handlers to get
```julia
julia> runwith(Printer() ∘ Stateful(0), f, 3)
(op, args, val) = (Put(), (3,), 3)
(op, args, val) = (Get(), (), 3)
3
```

## How it works

When we write 
```julia
@effectful function f(x)
    put(x)
    get()
end
```
We get something equivalent to 
```julia
function f(x)
    handler -> begin
                  (handler(put)(nothing))(handler(x)(nothing))
                  (handler(get)(nothing))()
              end
end
```

That `handler(x)` is strange. There's a default method
```julia
(h::AbstractHandler)(x) = Returns(x)
```
allowing anything that's _not_ an operation to pass through unchanged. In this case, `handler(x)(nothing) == x`.

For `Operation`s, there's a different method
```julia
@inline function (@nospecialize h::AbstractHandler)(@nospecialize op::Operation)
    function f(val)
        function(args...; kwargs...)
            runop(h, op, val, args...; kwargs...)
        end
    end
end
```

## Performance

Type inference does just fine:
![image](https://github.com/cscherrer/Effectful.jl/assets/1184449/21e6e524-5abe-433b-9a3f-621b7641910b)

And despite all the hoop-jumping, performance seems pretty good:
![image](https://github.com/cscherrer/Effectful.jl/assets/1184449/1128d959-97da-41e6-bf6a-022686d24203)
