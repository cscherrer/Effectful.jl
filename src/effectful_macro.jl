function foldast(leaf, branch; kwargs...)
    f(ast::Expr; kwargs...) = branch(f, ast.head, ast.args; kwargs...)
    f(x; kwargs...) = leaf(x; kwargs...)
    return f
end

macro effectful(ex)
    _effectful(esc(ex))
end

function _effectful(ast)
    leaf(x) = x

    function branch(f, head, args)
        if head == :(=)
            Expr(:(=), first(args), f(last(args)))
        elseif head == :function
            Expr(:function, first(args), :(handle -> $(f(last(args)))))
        elseif head == :call 
            fun = args[1]
            fun_args = args[2:end]
            Expr(:call, :(handle($fun)(nothing)), map(f, fun_args)...)
        else
            Expr(head, map(f, args)...)
        end
    end

    foldast(leaf, branch)(ast)
end
