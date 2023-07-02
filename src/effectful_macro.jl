function foldast(leaf, branch; kwargs...)
    f(ast::Expr; kwargs...) = branch(f, ast.head, ast.args; kwargs...)
    f(x; kwargs...) = leaf(x; kwargs...)
    return f
end

macro effectful(ex)
    _effectful(esc(ex))
end

function _effectful(ast)
    leaf(x::LineNumberNode) = x
    leaf(x) = :(handle($x)(nothing))

    function branch(f, head, args)
        if head == :(=)
            Expr(:(=), first(args), f(last(args)))
        elseif head == :function
            Expr(:function, first(args), :(handle -> $(f(last(args)))))
        else
            Expr(head, f.(args)...)
        end
    end

    foldast(leaf, branch)(ast)
end
