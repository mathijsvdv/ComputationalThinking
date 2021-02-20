import Pkg
using MuladdMacro

a = 1

a > 2

# Function calls are expensive: 15-60 clock cycles. 
# Can use `@inline` to force the compiler to 'delete' the function and paste its body 
# there. This removes the function call but makes it so you have to compile a larger
# amount of code. That's the tradeoff.

# fma (fused multiply add) computes the expression x*y + z in one operation.
# Use it to speed up your code and make it more accurate (fewer rounding errors)
@code_llvm fma(2.0, 5.0, 3.0)
"a: $a"

function myfma(x, y, z)
    return x*y + z
end

struct MyType <: Float64
end

2.0*5.0 + 3.0

@code_llvm myfma(2.0, 5.0, 3.0)

# The Julia function `muladd` will automatically choose between FMA and the original 
# form depending on the availability of the routine in the processor.

@code_llvm muladd(2.0, 5.0, 3.0)

@muladd (2.0*5.0 + 3.0)*0.5 + 1

@macroexpand @muladd (2.0*5.0 + 3.0)*0.5 + 1 
peakflops()

@macroexpand @elapsed peakflops()

fma(x) = 2

# There's also the macro `@muladd` which will take an expression of multiplications
# and additions to add `muladd` where appropriate.

# We can prevent Julia from evaluating an expression by *quoting* it:
expr = :(1 + 2)


struct Point{T}
    x::T
    y::T
end

isabstracttype(Point)