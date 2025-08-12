# This file is stiched together from tree-sitter-julia (MIT license).
# In particular, I've taken various entries in the test/corpus directory.
# They are not exhaustive, and I've added a few extra cases

module A

baremodule B end

module C
end

end

abstract type T end
abstract type T <: S end
abstract type T{S} <: U end
abstract type W{S} end

primitive type T 8 end
primitive type T <: S 16 end
primitive type Ptr{T} 32 end

struct Unit end

struct MyInt field::Int end

mutable struct Foo
  bar
  baz::Float64
end

struct Point{T}
  x::T
  y::T
end

struct Rational{T<:Integer} <: Real
  num::T
  den::T
end

struct Rationale{T<:Integer}
  num::T
  den::T
end

mutable struct MyVec <: AbstractArray
  foos::Vector{Foo}
end

function f end

function nop() end

function I(x) x end

function Base.rand(n::MyInt)
    return 4
end

function Γ(z)
    gamma(z)
end

function ⊕(x, y)
    x + y
end

function fix2(f, x)
    return function(y)
        f(x, y)
    end
end

function (foo::Foo)()
end

s(n) = n + 1

Base.foo(x) = x

ι(n) = range(1, n)

⊗(x, y) = x * y

(+)(x, y) = x + y


const x = "asd"

const y,z = 1,2

const (y,z) = 1,2
