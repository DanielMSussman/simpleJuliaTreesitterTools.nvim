# This file is stitched together from tree-sitter-julia (MIT license).
# In particular, I've taken various entries in the test/corpus directory.
# They are not exhaustive, and I've added a few extra cases

module A

baremodule B end

module C
end

end

abstract type AbstractT end
abstract type B <: S end
abstract type X{S} <: U end
abstract type w{S} end

primitive type T 8 end
primitive type T <: S 16 end
primitive type Ptr{T} 32 end

struct Unit end

struct MyInt field::Int end

mutable struct Foo
  bar
  baz::Float64
end

struct point{T}
  x::T
  y::T
end

struct rational{T<:Integer} <: Real
  num::T
  den::T
end

struct Rationale{T<:Integer}
  num::T
  den::T
end

struct Rationaley{T<:Integer} <: Rationale{T}
  num::T
  den::T
end

mutable struct MyVec <: AbstractArray
  foos::Vector{Foo}
end

function f end

function nop() end

function I(x) x end


const f = I(x)

function Γ(z)
    gamma(z)
end
function my_func(x::T) where{T}
    return x
end

Base.Int(x::MyType) = x

function my_func(x) where{T}
    return x
end
function ⊕(x, y)
    x + y
end

function fIx2(f, x)
    return function(y)
        f(x, y)
    end
end

function (foo::Foo)()
end

s(n) = n + 1


ι(n) = range(1, n)

⊗(x, y) = x * y

(+)(x, y) = x + y

my_FNcs(x) = x
x= otherfunction(z)

my_F = x-> 12*x

begin_function(x,y) = begin
    z = x+y
    2*z
end

#from https://docs.julialang.org/en/v1/manual/constructors/
struct OrderedPair
           x::Real
           y::Real
           OrderedPair(x,y) = x > y ? error("out of order") : new(x,y)
       end
const x = "asd"

const y,z = 1,2

const (y,z) = 1,2
const (Y,Z) = (AbstractArray,AbstractFloat)
