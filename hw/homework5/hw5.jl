### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 2b37ca3a-0970-11eb-3c3d-4f788b411d1a
begin
	using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 2dcb18d0-0970-11eb-048a-c1734c6db842
begin
	Pkg.add(["PlutoUI", "Plots"])

	using Plots
	gr()
	using PlutoUI
end

# ╔═╡ 19fe1ee8-0970-11eb-2a0d-7d25e7d773c6
md"_homework 5, version 0_"

# ╔═╡ 49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# WARNING FOR OLD PLUTO VERSIONS, DONT DELETE ME

html"""
<script>
const warning = html`
<h2 style="color: #800">Oopsie! You need to update Pluto to the latest version for this homework</h2>
<p>Close Pluto, go to the REPL, and type:
<pre><code>julia> import Pkg
julia> Pkg.update("Pluto")
</code></pre>
`

const super_old = window.version_info == null || window.version_info.pluto == null
if(super_old) {
	return warning
}
const version_str = window.version_info.pluto.substring(1)
const numbers = version_str.split(".").map(Number)
console.log(numbers)

if(numbers[0] > 0 || numbers[1] > 12 || numbers[2] > 1) {
	
} else {
	return warning
}

</script>

"""

# ╔═╡ ffb5a526-73e6-11eb-25ff-017cea96b3dd
md"Consider a geometric growth rate at `r1` fraction per unit time `t`"

# ╔═╡ b50c8f26-73e6-11eb-128b-c34ba3b91ca0
md"""$${(1+r)^t}$$"""

# ╔═╡ ec340396-73f3-11eb-0311-6d75d4ce2e5b
md"where each period the multiplicative factor $(1+r)$ is applied."

# ╔═╡ 777fccec-73f3-11eb-3727-ada098475e56
md"The discrete time multiperiod growth, from time 0 to t is"

# ╔═╡ 69c5e8da-73e8-11eb-035a-e9e896ec9d1b
md"$$A(t) = A_0 {(1+r)^t}, \forall t \in 1...T$$"

# ╔═╡ 48f20160-73e9-11eb-3f5a-837134d9c669
md"$$A(t+1) = A_0 (1+r)^{(t+1)}$$"

# ╔═╡ 9c7ee6fe-73f3-11eb-39e2-5f001d3ac7d6
md"So the single step discrete equation is:"

# ╔═╡ a2c57c58-73e9-11eb-134c-a754271920d8
md"$$A(t+1) = A(t){(1+r)}$$"

# ╔═╡ ad8a9880-73f3-11eb-05b3-4d68e630c806
md"And the period-to-period change equation, or _difference equation_, is"

# ╔═╡ efdccf28-73e9-11eb-05c0-4b679ead8340
md"$$\delta A(t) = A(t+1) - A(t) = A(t){(1+r)} - A(t) = r A(t)$$"

# ╔═╡ d611df84-73f3-11eb-31d5-53a466ab55aa
md"The analogous continuous growth equation is:"

# ╔═╡ a426ec40-73e8-11eb-3492-57220b642f3d
md"$$A(t) = A_0e^{+rt}$$"

# ╔═╡ 313a4fcc-73f4-11eb-3b54-e9fad50c4135
md"With the corresponding (continuous time) differential equation"

# ╔═╡ 13923c60-73e9-11eb-0dba-f597850cfc1d
md"$$\frac{dA(t)}{dt} = r A(t)$$"

# ╔═╡ 44ea15b6-73f4-11eb-35eb-dd50ae9b24b1
md"### Expectations"

# ╔═╡ 57278356-73f4-11eb-39e5-1de38470af7a
md"The expectation of a continuous random variable with probability density function $f(x)$ is defined as the integral, where possible observations x are weighted by their probability density:"

# ╔═╡ 6736b886-73ea-11eb-21f0-4db431d4cbca
md"$$E(X) = \int_\inf x f(x) dx$$"

# ╔═╡ 78d9774a-73f4-11eb-39f8-c5c657ff4e17


# ╔═╡ 2adeedbc-73eb-11eb-3042-67659cccf61c
md"""The important features of the probability density function are non-negativity ($f(x)\ge 0$) and that the total probability density must be 1.0:
"""

# ╔═╡ 09fefab0-73f5-11eb-198c-ffa95ba77565
md"$$\int_{-\infty}^{+\infty} f(x) dx = 1$$"

# ╔═╡ 487ac29c-73f5-11eb-1d39-893544c09124
md"The expectation of a discrete random variable $\tilde X$ with popssible values $x_i$ each with probability $p_i$ is defined as the probability-weighted sum, where possible observations $x_i$ are weighted by their probabilitie:"

# ╔═╡ 9d4fdbf2-73ea-11eb-1788-83d882e68681
md"$$E(\tilde X) = \sum_{i=1}^N x_i p_i$$"

# ╔═╡ 9d68af94-73f5-11eb-1ca8-757c4869b1ed
md"And the discrete probabilities must each be non-negative ($p_i \ge 0.0 \forall i$) and sum to 1.0:"

# ╔═╡ 44c03466-73eb-11eb-0d51-d568de70f72b
md"$$\sum_{i=1}^N p_i = 1.0$$"

# ╔═╡ cdcc0096-73f5-11eb-107d-719e2fcd9c31
md"Importantly/usefully, Expectation is a linear operator (additive constants $a$ just add to the expectation, and multiplicative constants $b$ just multiply it):"

# ╔═╡ e3818dbc-73ea-11eb-0257-6d2225423c17
md"$$E[a + b X] = a + b E[X]$$"

# ╔═╡ fc617486-73f5-11eb-3901-db923b9458d1
md"The expectation of a product of 2 random variables is the product of their expectations, _if_ they are independent:"

# ╔═╡ 5945b654-73eb-11eb-3eac-49a2efbb1a81
md"$$E[\tilde X \cdot \tilde Y] = E[\tilde X] E[\tilde Y]$$ iff independent"

# ╔═╡ dadae716-73eb-11eb-3b75-d93bdda88fb1
let
	t = 0:1:100
	# y = sin.(t)
	r = 0.02
	
	z(time) = exp(r*time)
	zz(t) = (1+r)^t
	y = z.(t)
	yy = zz.(t)
	p = plot(t,y, label = "continuous")
	plot!(p, t,yy, label = "discrete")
end

# ╔═╡ f78b16be-73ec-11eb-1bba-43ce6d1eb5b6
let
	t = 0:1:100
	# y = sin.(t)
	r = 0.02
	
	z(time) = exp(r*time)
	zz(t) = (1+r)^t
	y = z.(t)
	yy = zz.(t)
	p = plot(t,y, label = "continuous")
	pp = plot(t,yy, label = "discrete")
	plot(p, pp)
end

# ╔═╡ 181e156c-0970-11eb-0b77-49b143cc0fc0
md"""

# **Homework 5**: _Epidemic modeling II_
`18.S191`, fall 2020

This notebook contains _built-in, live answer checks_! In some exercises you will see a coloured box, which runs a test case on your code, and provides feedback based on the result. Simply edit the code, run it, and the check runs again.

_For MIT students:_ there will also be some additional (secret) test cases that will be run as part of the grading process, and we will look at your notebook and write comments.

Feel free to ask questions!
"""

# ╔═╡ 1f299cc6-0970-11eb-195b-3f951f92ceeb
# edit the code below to set your name and kerberos ID (i.e. email without @mit.edu)

student = (name = "Paul Leiby", kerberos_id = "pleiby")

# you might need to wait until all other cells in this notebook have completed running. 
# scroll around the page to see what's up

# ╔═╡ 1bba5552-0970-11eb-1b9a-87eeee0ecc36
md"""

Submission by: **_$(student.name)_** ($(student.kerberos_id)@mit.edu)
"""

# ╔═╡ 2848996c-0970-11eb-19eb-c719d797c322
md"_Let's create a package environment:_"

# ╔═╡ 69d12414-0952-11eb-213d-2f9e13e4b418
md"""
In this problem set, we will look at a simple **spatial** agent-based epidemic model: agents can interact only with other agents that are *nearby*.  (In the previous homework any agent could interact with any other, which is not realistic.)

A simple approach is to use **discrete space**: each agent lives
in one cell of a square grid. For simplicity we will allow no more than
one agent in each cell, but this requires some care to
design the rules of the model to respect this.

We will adapt some functionality from the previous homework. You should copy and paste your code from that homework into this notebook.
"""

# ╔═╡ 3e54848a-0954-11eb-3948-f9d7f07f5e23
md"""
## **Exercise 1:** _Wandering at random in 2D_

In this exercise we will implement a **random walk** on a 2D lattice (grid). At each time step, a walker jumps to a neighbouring position at random (i.e. chosen with uniform probability from the available adjacent positions).

"""

# ╔═╡ 3e623454-0954-11eb-03f9-79c873d069a0
md"""
#### Exercise 1.1
We define a struct type `Coordinate` that contains integers `x` and `y`.
"""

# ╔═╡ 0ebd35c8-0972-11eb-2e67-698fd2d311d2
"""
	Coordinate(x::Int64, y::Int64)

a struct
"""
struct Coordinate
	x::Int64
	y::Int64
end

# ╔═╡ 027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
md"""
👉 Construct a `Coordinate` located at the origin.
"""

# ╔═╡ b2f90634-0a68-11eb-1618-0b42f956b5a7
origin = Coordinate(0,0)

# ╔═╡ 3e858990-0954-11eb-3d10-d10175d8ca1c
md"""
👉 Write a function `make_tuple` that takes an object of type `Coordinate` and returns the corresponding tuple `(x, y)`. Boring, but useful later!
"""

# ╔═╡ 189bafac-0972-11eb-1893-094691b2073c
function make_tuple(c::Coordinate)
   return(c.x, c.y)
end

# ╔═╡ 73ed1384-0a29-11eb-06bd-d3c441b8a5fc
md"""
#### Exercise 1.2
In Julia, operations like `+` and `*` are just functions, and they are treated like any other function in the language. The only special property you can use the _infix notation_: you can write
```julia
1 + 2
```
instead of 
```julia
+(1, 2)
```
_(There are [lots of special 'infixable' function names](https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm#L23-L24) that you can use for your own functions!)_

When you call it with the prefix notation, it becomes clear that it really is 'just another function', with lots of predefined methods.
"""

# ╔═╡ 96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
+(1, 2)

# ╔═╡ b0337d24-0a29-11eb-1fab-876a87c0973f
+

# ╔═╡ 9c9f53b2-09ea-11eb-0cda-639764250cee
md"""
> #### Extending + in the wild
> Because it is a function, we can add our own methods to it! This feature is super useful in general languages like Julia and Python, because it lets you use familiar syntax (`a + b*c`) on objects that are not necessarily numbers!
> 
> One example we've see before is the `RGB` type in Homework 1. You are able to do:
> ```julia
> 0.5 * RGB(0.1, 0.7, 0.6)
> ```
> to multiply each color channel by $0.5$. This is possible because `Images.jl` [wrote a method](https://github.com/JuliaGraphics/ColorVectorSpace.jl/blob/master/src/ColorVectorSpace.jl#L131):
> ```julia
> *(::Real, ::AbstractRGB)::AbstractRGB
> ```

👉 Implement addition on two `Coordinate` structs by adding a method to `Base.:+`
"""

# ╔═╡ e24d5796-0a68-11eb-23bb-d55d206f3c40
function Base.:+(a::Coordinate, b::Coordinate)
		
	return Coordinate(a.x + b.x, a.y + b.y)
end

# ╔═╡ ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
Coordinate(3,4) + Coordinate(10,10) # uncomment to check + works

# ╔═╡ e144e9d0-0a2d-11eb-016e-0b79eba4b2bb
md"""
_Pluto has some trouble here, you need to manually re-run the cell above!_
"""

# ╔═╡ 71c358d8-0a2f-11eb-29e1-57ff1915e84a
md"""
#### Exercise 1.3
In our model, agents will be able to walk in 4 directions: up, down, left and right. We can define these directions as `Coordinate`s.
"""

# ╔═╡ 5278e232-0972-11eb-19ff-a1a195127297
possible_moves = [
	Coordinate( 1, 0), 
	Coordinate( 0, 1), 
	Coordinate(-1, 0), 
	Coordinate( 0,-1),
]

# ╔═╡ 71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
md"""
👉 `rand(possible_moves)` gives a random possible move. Add this to the coordinate `Coordinate(4,5)` and see that it moves to a valid neighbor.
"""

# ╔═╡ 69151ce6-0aeb-11eb-3a53-290ba46add96
Coordinate(4,5) + rand(possible_moves)

# ╔═╡ 3eb46664-0954-11eb-31d8-d9c0b74cf62b
md"""
We are able to make a `Coordinate` perform one random step, by adding a move to it. Great!

👉 Write a function `trajectory` that calculates a trajectory of a `Wanderer` `w` when performing `n` steps., i.e. the sequence of positions that the walker finds itself in.

Possible steps:
- Use `rand(possible_moves, n)` to generate a vector of `n` random moves. Each possible move will be equally likely.
- To compute the trajectory you can use either of the following two approaches:
  1. 🆒 Use the function `accumulate` (see the live docs for `accumulate`). Use `+` as the function passed to `accumulate` and the `w` as the starting value (`init` keyword argument). 
  1. Use a `for` loop calling `+`. 

"""

# ╔═╡ edf86a0e-0a68-11eb-2ad3-dbf020037019
begin
	"""
		trajectory(w::Coordinate, n::Int)

	Uses `rand(possible_moves, n)` to generate a vector of n random moves.
	Returns the trajectory as a vector of successive Coordinates.
	"""
	function trajectory(w::Coordinate, n::Int)
		delta_x = rand(possible_moves, n)
		return accumulate(+, delta_x, init=w)
	end


end

# ╔═╡ 478309f4-0a31-11eb-08ea-ade1755f53e0
"""
	plot_trajectory!(p::Plots.Plot, trajectory::Vector; kwargs...)

takes a plot `p` and `trajectory` array of points,
and returns modified plot with trajectory points
connected by lines
"""
function plot_trajectory!(p::Plots.Plot, trajectory::Vector; kwargs...)
	plot!(p, make_tuple.(trajectory); 
		label=nothing, 
		linewidth=2, 
		linealpha=LinRange(1.0, 0.2, length(trajectory)),
		kwargs...)
end

# ╔═╡ 8e39d594-6a67-11eb-3d11-dd2e8628826c
md"Uncomment the following to plot a long trajectory."

# ╔═╡ 3ebd436c-0954-11eb-170d-1d468e2c7a37
md"""
#### Exercise 1.4
👉 Plot 10 trajectories of length 1000 on a single figure, all starting at the origin. Use the function `plot_trajectory!` as demonstrated above.

Remember from last week that you can compose plots like this:

```julia
let
	# Create a new plot with aspect ratio 1:1
	p = plot(ratio=1)

	plot_trajectory!(p, test_trajectory)      # plot one trajectory
	plot_trajectory!(p, another_trajectory)   # plot the second one
	...

	p
end
```
"""

# ╔═╡ b4d5da4a-09a0-11eb-1949-a5807c11c76c
md"""
#### Exercise 1.5
Agents live in a box of side length $2L$, centered at the origin. We need to decide (i.e. model) what happens when they reach the walls of the box (boundaries), in other words what kind of **boundary conditions** to use.

One relatively simple boundary condition is a **collision boundary**:

> Each wall of the box is a wall, modelled using "collision": if the walker tries to jump beyond the wall, it ends up at the position inside the box that is closest to the goal.

👉 Write a function `collide_boundary` which takes a `Coordinate` `c` and a size $L$, and returns a new coordinate that lies inside the box (i.e. ``[-L,L]\times [-L,L]``), but is closest to `c`. This is similar to `extend_mat` from Homework 1.
"""

# ╔═╡ 0237ebac-0a69-11eb-2272-35ea4e845d84
begin
	"""
		myclamp(x::Number, lobnd = 0, upbnd = 1)
	
	return `x` clamped to `lobnd <= x <= upbnd`
	"""
	function myclamp(x::Number, lobnd::Number = 0, upbnd::Number = 1)
		return ((x > upbnd) ? upbnd :
			(x < lobnd) ? lobnd : x)
	end

	"""
		collide_boundary(c::Coordinate, L::Number)
	
	takes a Coordinate `c` and a size `L`, and returns a new coordinate that lies inside the box (i.e. [-L,L] x [-L,L]), but is closest to c.
	"""
	function collide_boundary(c::Coordinate, L::Number)
		c_lim = Coordinate(
			myclamp(c.x, -L, L), 
			myclamp(c.y, -L, L))
		
		return c_lim
	end

	"""
		extend_mat(M::AbstractMatrix, i, j)

	takes a matrix `M` and indices `i` and `j`, and returns the closest element of the matrix.
	"""
	function extend_mat(M::AbstractMatrix, i, j)

		num_rows, num_columns = size(M)

		return M[clamp(i, 1, num_rows), clamp(j, 1, num_columns)]
	end
end

# ╔═╡ ad832360-0a40-11eb-2857-e7f0350f3b12
collide_boundary(Coordinate(12,4), 9) # uncomment to test

# ╔═╡ b4ed2362-09a0-11eb-0be9-99c91623b28f
md"""
#### Exercise 1.6
👉  Implement a 3-argument method  of `trajectory` where the third argument is a size. The trajectory returned should be within the boundary (use `collide_boundary` from above). You can still use `accumulate` with an anonymous function that makes a move and then reflects the resulting coordinate, or use a for loop.

"""

# ╔═╡ 0665aa3e-0a69-11eb-2b5d-cd718e3c7432
"""
	trajectory(w::Coordinate, n::Int, L::Number)

Uses `rand(possible_moves, n)` to generate a vector of n random moves,
but constrained to stay withing square ranging `[-L, L]` in each dimension.
Returns the trajectory as a vector of successive Coordinates.
"""
function trajectory(w::Coordinate, n::Int, L::Number)
		
	delta_x = rand(possible_moves, n)


	# accumulate, but must both add and "reflect" (bound) at each step
	
	reflective_sum(x, y) = collide_boundary(x+y, L)
	# reflective_sum = collide_boundary(, L) ∘ + # does not work
	path = accumulate(reflective_sum, delta_x, init=w)

	return path
end

# ╔═╡ 44107808-096c-11eb-013f-7b79a90aaac8
test_trajectory = trajectory(Coordinate(4,4), 30) # uncomment to test

# ╔═╡ 87ea0868-0a35-11eb-0ea8-63e27d8eda6e
try
	p = plot(ratio=1, size=(650,200))
	plot_trajectory!(p, test_trajectory; color="black", showaxis=false, axis=nothing, linewidth=4)
	p
catch
end

# ╔═╡ 51788e8e-0a31-11eb-027e-fd9b0dc716b5
let
	long_trajectory = trajectory(Coordinate(4,4), 1000)

	p = plot(ratio=1)
	plot_trajectory!(p, long_trajectory)
	p
end

# ^ uncomment to visualize a trajectory

# ╔═╡ dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
# Plot 10 trajectories of length 1000 on a single figure, all starting at the origin. 
let
	
	p = plot(ratio=1)
	for i = 1:10
		plot_trajectory!(p, trajectory(Coordinate(0,0), 1000))
	end
	p
end

# ╔═╡ 5690f57e-73c1-11eb-3c81-29dd31a1ed37
# ??? Why does this fail? Is it a namespace/scoping problem for currpt
# Warning: only happens with begin- end
function testfoo(L)
	steps = rand(possible_moves, 5)
	
	currpt = Coordinate(0,0)
	
	path = [currpt] # starting point
	for pt in steps
		currpt = collide_boundary(currpt + pt, L) # next point with delta_x and bounded
		push!(path, currpt)
	end

	path
end

# ╔═╡ e5f9cd58-73f1-11eb-2b2e-5b8e22dab523
testfoo(6)

# ╔═╡ 7e75b27c-72ff-11eb-36c2-c30458d8219d
# Test of bounded trajectory, with "collide_boundary" at square radius 5 
# Plot k trajectories of length 1000 on a single figure, all starting at the origin. 
let
	k = 1
	p = plot(ratio=1)
	for i = 1:k
		plot_trajectory!(p, trajectory(Coordinate(0,0), 1000, 10))
	end
	p
end

# ╔═╡ 3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
md"""
## **Exercise 2:** _Wanderering Agents_

In this exercise we will create Agents which have a location as well as some infection state information.

Let's define a type `Agent`. `Agent` contains a `position` (of type `Coordinate`), as well as a `status` of type `InfectionStatus` (as in Homework 4).)

(For simplicity we will not use a `num_infected` field, but feel free to do so!)
"""

# ╔═╡ 35537320-0a47-11eb-12b3-931310f18dec
@enum InfectionStatus S I R

# ╔═╡ cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# define agent struct here:
begin
	
	mutable struct Agent
		position::Coordinate
		status::InfectionStatus
		num_infected::Int64
		num_interactions::Int64
	end
	
	Agent() = Agent(Coordinate(0,0), S, 0, 0) # basic constructor
	Agent(stat::InfectionStatus) = Agent(Coordinate(0,0), stat, 0, 0)
end

# ╔═╡ b0f78890-73c9-11eb-357c-4368669e3e3b
# utility functions for Agents
begin
	# Write functions `set_status!(a)` and `set_num_infected!(a)` which modify the respective fields of an `Agent`.

	function set_status!(agent::Agent, new_status::InfectionStatus)
		agent.status = new_status
	end

	function set_num_infected!(agent::Agent, new_num::Int64)
		agent.num_infected = new_num
	end

	function is_susceptible(agent::Agent)
		return agent.status == S
	end

	function is_infected(agent::Agent)
		return agent.status == I
	end

	"""
	 	bernoulli(p)
	
	returns `true` with probability `p` and `false` with probability `(1 - p)`.
	"""
	function bernoulli(p::Number)	
		return rand() < p
	end
end

# ╔═╡ 814e888a-0954-11eb-02e5-0964c7410d30
md"""
#### Exercise 2.1
👉 Write a function `initialize` that takes parameters $N$ and $L$, where $N$ is the number of agents abd $2L$ is the side length of the square box where the agents live.

It returns a `Vector` of `N` randomly generated `Agent`s. Their coordinates are randomly sampled in the ``[-L,L] \times [-L,L]`` box, and the agents are all susceptible, except one, chosen at random, which is infectious.
"""

# ╔═╡ 6e266dc4-73c7-11eb-331a-257c039be666
# Example Agent initialization
Agent(Coordinate(rand(-5:5),rand(-5:5)), S, 0, 0)

# ╔═╡ 0cfae7ba-0a69-11eb-3690-d973d70e47f4
"""
	initialize(N::Number, L::Number)

Initializes a population of SIR `Agents`.
Returns a Vector of `N` randomly generated `Agents`. 
Their coordinates are randomly sampled in the `[-L,L] x [-L,L]` box, 
and the agents are all susceptible, except one, chosen at random, which is infectious.
"""
function initialize(N::Number, L::Number)
	pop = [Agent(Coordinate(rand(-L:L),rand(-L:L)), S, 0, 0) for n in 1:N]
	pop[rand(1:N)].status = I # infect 1
	return pop
end

# ╔═╡ 1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
initialize(3, 10)

# ╔═╡ e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# Color based on infection status
color(s::InfectionStatus) = if s == S
	"blue"
elseif s == I
	"red"
else
	"green"
end

# ╔═╡ b5a88504-0a47-11eb-0eda-f125d419e909
position(a::Agent) = a.position # uncomment this line

# ╔═╡ 87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
color(a::Agent) = color(a.status) # uncomment this line

# ╔═╡ 49fa8092-0a43-11eb-0ba9-65785ac6a42f
md"""
#### Exercise 2.2
👉 Write a function `visualize` that takes in a collection of agents as argument, and the box size `L`. It should plot a point for each agent at its location, coloured according to its status.

You can use the keyword argument `c=color.(agents)` inside your call to the plotting function make the point colors correspond to the infection statuses. Don't forget to use `ratio=1`.
"""

# ╔═╡ bf5718b2-73cc-11eb-3208-d386a4e2476b
make_tuple.(position.(initialize(3,10)))

# ╔═╡ 1ccc961e-0a69-11eb-392b-915be07ef38d
"""
	visualize(agents::Vector, L)

takes a collection (Vector) of `agents` and the box size `L`,
and plots a point for each agent at its location,
coloured according to its status.
"""
function visualize(agents::Vector, L)
	# keyword argument `c=color.(agents)` inside call to the plotting function make the point colors correspond to the infection statuses. 

	# Don't forget to use `ratio=1`.
	p = plot(ratio=1)

	plot!(p, make_tuple.(position.(agents)),
		seriestype = :scatter,
		title = "My SIR Friends",
		label=nothing,
		c=color.(agents),
		linewidth=2, # irrelevant for scatterplot
		xlabel = "Position 1",
		ylabel = "Position 2",
		xlims = (-L,L),
		ylims = (-L,L)
		# linealpha=LinRange(1.0, 0.2, length(trajectory))
		)
	return p
end

# ╔═╡ 1f96c80a-0a46-11eb-0690-f51c60e57c3f
let
	N = 20
	L = 10
	visualize(initialize(N, L), L) # uncomment this line!
end

# ╔═╡ f953e06e-099f-11eb-3549-73f59fed8132
md"""

### Exercise 3: Spatial epidemic model -- Dynamics

Last week we wrote a function `interact!` that takes two agents, `agent` and `source`, and an infection of type `InfectionRecovery`, which models the interaction between two agent, and possibly modifies `agent` with a new status.

This week, we define a new infection type, `CollisionInfectionRecovery`, and a new method that is the same as last week, except it **only infects `agent` if `agents.position==source.position`**.
"""	

# ╔═╡ e6dd8258-0a4b-11eb-24cb-fd5b3554381b
abstract type AbstractInfection end

# ╔═╡ de88b530-0a4b-11eb-05f7-85171594a8e8
struct CollisionInfectionRecovery <: AbstractInfection
	p_infection::Float64
	p_recovery::Float64
end

# ╔═╡ 80f39140-0aef-11eb-21f7-b788c5eab5c9
md"""

Write a function `interact!` that takes two `Agent`s and a `CollisionInfectionRecovery`, and:

- If the agents are at the same spot, causes a susceptible agent to communicate the desease from an infectious one with the correct probability.
- if the first agent is infectious, it recovers with some probability
"""

# ╔═╡ 2bafa020-73d1-11eb-3f61-2120861ee90a
bernoulli(0.2)

# ╔═╡ d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
"""
	interact!(agent::Agent, source::Agent, infection::CollisionInfectionRecovery)

Takes an affected `agent` and `source`, both of type `Agent` and an `infection` of type `CollisionInfectionRecovery`.
It implements a single (one-sided) interaction between two agents: 

- If the `agent` is susceptible and the `source` is infectious, then the `source` infects our `agent` with the given infection probability. If the `source` successfully infects the other agent, then its `num_infected` record must be updated.
- If the `agent` is infected then it recovers with the relevant probability.
- Otherwise, nothing happens.
"""
function interact!(agent::Agent, source::Agent, infection::CollisionInfectionRecovery)
	if agent.position == source.position # no interaction unless at same location
		agent.num_interactions += 1
		source.num_interactions += 1
		if is_susceptible(agent) && is_infected(source)

			if bernoulli(infection.p_infection)			
				agent.status = I # set_status!(agent) = I
				source.num_infected += 1 # count how many infected
			end
			# elseif is_infected(agent) # ???		
		else
			# recover only of interact and possible transmission
			if bernoulli(infection.p_recovery)
				agent.status = R # set_status!(agent) = R
			end
		end
	end
end

# ╔═╡ 34778744-0a5f-11eb-22b6-abe8b8fc34fd
md"""
#### Exercise 3.1
Your turn!

👉 Write a function `step!` that takes a vector of `Agent`s, a box size `L` and an `infection`. This that does one step of the dynamics on a vector of agents. 

- Choose an Agent `source` at random.

- Move the `source` one step, and use `collide_boundary` to ensure that our agent stays within the box.

- For all _other_ agents, call `interact!(other_agent, source, infection)`.

- return the array `agents` again.
"""

# ╔═╡ 67b7a0b4-73d5-11eb-20e1-238933831c47
rand(possible_moves)

# ╔═╡ 0fdb9e86-73d5-11eb-208e-5df5441cd883
function move_agent_one_step(agent::Agent, L)
	move = rand(possible_moves) # this is single coordinate, rand(x, 1) is an array
	agent.position = collide_boundary(agent.position + move, L) # bounded move
	# return(agent) # not needed given passed agent by reference
end


# ╔═╡ 24fe0f1a-0a69-11eb-29fe-5fb6cbf281b8
"""
	step!(agents::Vector, L::Number, infection::AbstractInfection)

takes `agents` vector of Agents and an infection of type InfectionRecovery.
Implements a single step of the infection dynamics as follows:

- Choose a `source` Agent at random.
- Move the `source` one step, and use `collide_boundary` to ensure that agent stays within the box.
- For all _other_ agents, call `interact!(other_agent, source, infection)`.
- return the array `agents` again.
"""
function step!(agents::Vector, L::Number, infection::AbstractInfection)
# function step!(agents::Vector{Agent}, L::Number, infection::AbstractInfection)
	source = rand(agents) # Choose a `source` Agent at random.
	# Move the `source` one step
	move_agent_one_step(source, L)
	for agent in agents
		if (agent != source) # does this work if two identical agents are at same place: yes if they are diff struct
			interact!(agent, source, infection)
		end
	end
	return agents
end

# ╔═╡ 35c43e5a-73ee-11eb-10be-67ec7440d460
let
	s = Agent()
	t = Agent()
	u = s
	s.position == t.position
	w = deepcopy(s)
	w == s
end

# ╔═╡ cd7d9034-73ee-11eb-0cac-c989e4002940


# ╔═╡ 1fc3271e-0a45-11eb-0e8d-0fd355f5846b
md"""
#### Exercise 3.2
If we call `step!` `N` times, then every agent will have made one step, on average. Let's call this one _sweep_ of the simulation.

👉 Create a before-and-after plot of ``k_{sweeps}=1000`` sweeps. 

- Initialize a new vector of agents (`N=50`, `L=40`, `infection` is given as `pandemic` below). 
- Plot the state using `visualize`, and save the plot as a variable `plot_before`.
- Run `k_sweeps` sweeps.
- Plot the state again, and store as `plot_after`.
- Combine the two plots into a single figure using
```julia
plot(plot_before, plot_after)
```
"""

# ╔═╡ 5d45d5aa-73d6-11eb-35b1-45107b1b1928
"""
	sweep!(agents::Vector{Agent},  L::Number, infection::AbstractInfection)

Runs `step!`  times, where  is the number of agents.
Returns updated population
"""
function sweep!(agents::Vector{Agent},  L::Number, infection::AbstractInfection)
	for n = 1:length(agents)
		step!(agents, L, infection)
	end
end

# ╔═╡ 4e5592ce-73d6-11eb-0086-7db6559c0cd6
"""
	simulation(N::Integer, L::Number, T::Integer, infection::AbstractInfection)

- Generates the `N` agents, one infected, in the box of side `2L+1`.
- Run `sweep!` a number `T` of times. Calculate and store the total number of agents with each status at each step in variables S_counts, I_counts and R_counts.
- Return the vectors S_counts, I_counts and R_counts in a named tuple, with keys `S, I, R)`.
"""
function simulation(N::Integer,  L::Number, T::Integer, infection::AbstractInfection)
	agents = initialize(N, L)
	S_counts = []
	I_counts = []
	R_counts = []
	X_counts = [] # number of interactions
	
	# your code here
	for i in 1:T
		sweep!(agents, L, infection)
		push!(S_counts, sum([is_susceptible(agent) for agent in agents]))
		push!(I_counts, sum([is_infected(agent) for agent in agents]))
		push!(R_counts, N - S_counts[i] - I_counts[i])
		push!(X_counts, sum([agent.num_interactions for agent in agents]))
	end
	return (S=S_counts, I=I_counts, R=R_counts, X=X_counts)
end


# ╔═╡ 18552c36-0a4d-11eb-19a0-d7d26897af36
pandemic = CollisionInfectionRecovery(0.5, 0.00001)

# ╔═╡ 1bac88b2-73dd-11eb-059e-e9bcb002aeeb
md"Select p: $(@bind p_interactive Slider(0.01:0.01:1.0; default=0.01, show_value=true))"

# ╔═╡ adef838a-73dd-11eb-34a7-47654619efef
md"Select num sweeps: $(@bind k_sweeps Slider(1:10000; default=1000, show_value=true))"

# ╔═╡ eb10e374-73d7-11eb-3b15-c984b62e2384
let
	N = 50
 	L = 40
	T = k_sweeps
	sim = simulation(N, L, T, pandemic)
	
	result = plot(1:T, sim.S, ylim=(0, N), label="Susceptible")
	plot!(result, 1:T, sim.I, ylim=(0, N), label="Infectious")
	plot!(result, 1:T, sim.R, ylim=(0, N), label="Recovered")
	plot!(result, 1:T, sim.X/N, ylim=(0, N), label="Interactions/person")
	
end

# ╔═╡ 778c2490-0a62-11eb-2a6c-e7fab01c6822
let
	N = 50
 	L = 40
	
	agents = initialize(N, L)
 	plot_before = visualize(agents::Vector, L)
	
	for i in 1:k_sweeps
		sweep!(agents, L, pandemic)
	end	
	plot_after = visualize(agents::Vector, L)
	
	plot(plot_before, plot_after)
end

# ╔═╡ e964c7f0-0a61-11eb-1782-0b728fab1db0
md"""
#### Exercise 3.3

Every time that you move the slider, a completely new simulation is created an run. This makes it hard to view the progress of a single simulation over time. So in this exercise, we we look at a single simulation, and plot the S, I and R curves.

👉 Plot the SIR curves of a single simulation, with the same parameters as in the previous exercise. Use `k_sweep_max = 10000` as the total number of sweeps.
"""

# ╔═╡ 4d83dbd0-0a63-11eb-0bdc-757f0e721221
k_sweep_max = 10000

# ╔═╡ ef27de84-0a63-11eb-177f-2197439374c5
let
	N = 50
	L = 30
	
	T = k_sweep_max
	# initialize agents (initialize(N, L)) and
	# compute k_sweep_max number of sweeps and plot the SIR
	sim = simulation(N, L, T, pandemic)
	
	result = plot(1:T, sim.S, ylim=(0, N), label="Susceptible")
	plot!(result, 1:T, sim.I, ylim=(0, N), label="Infectious")
	plot!(result, 1:T, sim.R, ylim=(0, N), label="Recovered")
	plot!(result, 1:T, sim.X/N, ylim=(0, N), label="Interactions/person")
	
end

# ╔═╡ 201a3810-0a45-11eb-0ac9-a90419d0b723
md"""
#### Exercise 3.4 (optional)
Let's make our plot come alive! There are two options to make our visualization dynamic:

👉1️⃣ Precompute one simulation run and save its intermediate states using `deepcopy`. You can then write an interactive visualization that shows both the state at time $t$ (using `visualize`) and the history of $S$, $I$ and $R$ from time $0$ up to time $t$. $t$ is controlled by a slider.

👉2️⃣ Use `@gif` from Plots.jl to turn a sequence of plots into an animation. Be careful to skip about 50 sweeps between each animation frame, otherwise the GIF becomes too large.

This an optional exercise, and our solution to 2️⃣ is given below.
"""

# ╔═╡ e5040c9e-0a65-11eb-0f45-270ab8161871
# let
# 	N = 50
# 	L = 30
	
# 	missing
# end

# ╔═╡ 2031246c-0a45-11eb-18d3-573f336044bf
md"""
#### Exercise 3.5
👉  Using $L=20$ and $N=100$, experiment with the infection and recovery probabilities until you find an epidemic outbreak. (Take the recovery probability quite small.) Modify the two infections below to match your observations.
"""

# ╔═╡ 63dd9478-0a45-11eb-2340-6d3d00f9bb5f
causes_outbreak = CollisionInfectionRecovery(0.04, 0.001)

# ╔═╡ 269955e4-0a46-11eb-02cc-1946dc918bfa
does_not_cause_outbreak = CollisionInfectionRecovery(0.01, 0.001)

# ╔═╡ 4d4548fe-0a66-11eb-375a-9313dc6c423d
let
	N = 50
	L = 30
	
	T = k_sweep_max
	# initialize agents (initialize(N, L)) and
	# compute k_sweep_max number of sweeps and plot the SIR
	sim = simulation(N, L, T, causes_outbreak)
	
	result = plot(1:T, sim.S, ylim=(0, N), label="Susceptible")
	plot!(result, 1:T, sim.I, ylim=(0, N), label="Infectious")
	plot!(result, 1:T, sim.R, ylim=(0, N), label="Recovered")
	plot!(result, 1:T, sim.X/N, ylim=(0, N), label="Interactions/person")
	
end

# ╔═╡ 20477a78-0a45-11eb-39d7-93918212a8bc
md"""
#### Exercise 3.6
👉 With the parameters of Exercise 3.2, run 50 simulations. Plot $S$, $I$ and $R$ as a function of time for each of them (with transparency!). This should look qualitatively similar to what you saw in the previous homework. You probably need different `p_infection` and `p_recovery` values from last week. Why?
"""

# ╔═╡ 601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
"""
	repeat_simulations(N, L, T, infection, num_simulations)

N = pop size
L = dimension
T = (time) iterations
	
"""
function repeat_simulations(N, L, T, infection, num_simulations)
	map(1:num_simulations) do _
		simulation(N, L, T, infection)
	end
end


# ╔═╡ 2e444a22-73e3-11eb-07ab-970a5c59e008
simulations = repeat_simulations(50, 40, 1000, pandemic, 50)

# ╔═╡ 5f5aa2b4-73e3-11eb-2088-dd733d084586
begin
	#T = length(first(simulations).I) # 
	#N = length(simulations)
	totI = zeros(length(first(simulations).I)) # init array for number of iterations
	for sim in simulations
		totI = totI .+ sim.I
	end
	aveI = totI ./ length(simulations) # to get average divide by num simulations
end

# ╔═╡ 218e569c-73e3-11eb-1cb9-4fa912eef6c9
let
	p = plot()
	
	for sim in simulations
		plot!(p, 1:1000, sim.I, alpha=.5, label=nothing)
	end
	
	plot!(p, 1:1000, aveI, label="Mean I", lw=3)
	p
end

# ╔═╡ b1b1afda-0a66-11eb-2988-752405815f95
need_different_parameters_because = md"""
The spatial representation implies less contagion than full-mizing-
"""

# ╔═╡ 05c80a0c-09a0-11eb-04dc-f97e306f1603
md"""
## **Exercise 4:** _Effect of socialization_

In this exercise we'll modify the simple mixing model. Instead of a constant mixing probability, i.e. a constant probability that any pair of people interact on a given day, we will have a variable probability associated with each agent, modelling the fact that some people are more or less social or contagious than others.
"""

# ╔═╡ b53d5608-0a41-11eb-2325-016636a22f71
md"""
#### Exercise 4.1
We create a new agent type `SocialAgent` with fields `position`, `status`, `num_infected`, and `social_score`. The attribute `social_score` represents an agent's probability of interacting with any other agent in the population.
"""

# ╔═╡ 1b5e72c6-0a42-11eb-3884-a377c72270c7
# struct SocialAgent here...

# ╔═╡ c704ea4c-0aec-11eb-2f2c-859c954aa520
md"""define the `position` and `color` methods for `SocialAgent` as we did for `Agent`. This will allow the `visualize` function to work. on both kinds of Agents"""

# ╔═╡ e97e39aa-0a5d-11eb-3d5f-f90a0acfe5a2
# begin
# 	position(a::SocialAgent) = ...
# 	color(a::SocialAgent) = ...
# end

# ╔═╡ b554b654-0a41-11eb-0e0d-e57ff68ced33
md"""
👉 Create a function `initialize_social` that takes `N` and `L`, and creates N agents  within a 2L x 2L box, with `social_score`s chosen from 10 equally-spaced between 0.1 and 0.5. (see LinRange)
"""

# ╔═╡ 40c1c1d6-0a69-11eb-3913-59e9b9ec4332
# function initialize_social(N, L)
# 	return missing
# end

# ╔═╡ 18ac9926-0aed-11eb-034f-e9849b71c9ac
md"""
Now that we have 2 agent types

1. let's create an AbstractAgent type
2. Go back in the notebook and make the agent types a subtype of AbstractAgent.

"""

# ╔═╡ b56ba420-0a41-11eb-266c-719d39580fa9
md"""
#### Exercise 4.2
Not all two agents who end up in the same grid point may actually interact in an infectious way -- they may just be passing by and do not create enough exposure for communicating the disease.

👉 Write a new `interact!` method on `SocialAgent` which adds together the social_scores for two agents and uses that as the probability that they interact in a risky way. Only if they interact in a risky way, the infection is transmitted with the usual probability.
"""

# ╔═╡ 465e918a-0a69-11eb-1b59-01150b4b0f36
# function interact!(agent::SocialAgent, source::SocialAgent, infection::CollisionInfectionRecovery)
	
# 	# your code here
# end

# ╔═╡ a885bf78-0a5c-11eb-2383-9d74c8765847
md"""
Make sure `step!`, `position`, `color`, work on the type `SocialAgent`. If `step!` takes an untyped first argument, it should work for both Agent and SocialAgent types without any changes. We actually only need to specialize `interact!` on SocialAgent.

#### Exercise 4.3
👉 Plot the SIR curves of the resulting simulation.

N = 50;
L = 40;
number of steps = 200

In each step call `step!` 50N times.
"""

# ╔═╡ 1f172700-0a42-11eb-353b-87c0039788bd
let
	N = 50
	L = 40

	#global social_agents = initialize_social(N, L)
	Ss, Is, Rs = [], [], []
	
	Tmax = 200
	
	@gif for t in 1:Tmax

		# 1. Step! a lot
		# 2. Count S, I and R, push them to Ss Is Rs
		# 3. call visualize on the agents,
		# 4. place the SIR plot next to visualize.
		# plot(left, right, size=(600,300)) # final plot
	end
end

# ╔═╡ b59de26c-0a41-11eb-2c67-b5f3c7780c91
md"""
#### Exercise 4.4
👉 Make a scatter plot showing each agent's `social_score` on one axis, and the `num_infected` from the simulation in the other axis. Run this simulation several times and comment on the results.
"""

# ╔═╡ faec52a8-0a60-11eb-082a-f5787b09d88c


# ╔═╡ b5b4d834-0a41-11eb-1b18-1bd626d18934
md"""
👉 Run a simulation for 100 steps, and then apply a "lockdown" where every agent's social score gets multiplied by 0.25, and then run a second simulation which runs on that same population from there.  What do you notice?  How does changing this factor form 0.25 to other numbers affect things?
"""

# ╔═╡ a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2


# ╔═╡ 05fc5634-09a0-11eb-038e-53d63c3edaf2
md"""
## **Exercise 5:** (Optional) _Effect of distancing_

We can use a variant of the above model to investigate the effect of the
mis-named "social distancing"  
(we want people to be *socially* close, but *physically* distant).

In this variant, we separate out the two effects "infection" and
"movement": an infected agent chooses a
neighbouring site, and if it finds a susceptible there then it infects it
with probability $p_I$. For simplicity we can ignore recovery.

Separately, an agent chooses a neighbouring site to move to,
and moves there with probability $p_M$ if the site is vacant. (Otherwise it
stays where it is.)

When $p_M = 0$, the agents cannot move, and hence are
completely quarantined in their original locations.

👉 How does the disease spread in this case?

"""

# ╔═╡ 24c2fb0c-0a42-11eb-1a1a-f1246f3420ff


# ╔═╡ c7649966-0a41-11eb-3a3a-57363cea7b06
md"""
👉 Run the dynamics repeatedly, and plot the sites which become infected.
"""

# ╔═╡ 2635b574-0a42-11eb-1daa-971b2596ce44


# ╔═╡ c77b085e-0a41-11eb-2fcb-534238cd3c49
md"""
👉 How does this change as you increase the *density*
    $\rho = N / (L^2)$ of agents?  Start with a small density.

This is basically the [**site percolation**](https://en.wikipedia.org/wiki/Percolation_theory) model.

When we increase $p_M$, we allow some local motion via random walks.
"""

# ╔═╡ 274fe006-0a42-11eb-1869-29193bb84957


# ╔═╡ c792374a-0a41-11eb-1e5b-89d9de2cf1f9
md"""
👉 Investigate how this leaky quarantine affects the infection dynamics with
different densities.

"""

# ╔═╡ d147f7f0-0a66-11eb-2877-2bc6680e396d


# ╔═╡ 0e6b60f6-0970-11eb-0485-636624a0f9d7
if student.name == "Jazzy Doe"
	md"""
	!!! danger "Before you submit"
	    Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
	"""
end

# ╔═╡ 0a82a274-0970-11eb-20a2-1f590be0e576
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 0aa666dc-0970-11eb-2568-99a6340c5ebd
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 8475baf0-0a63-11eb-1207-23f789d00802
hint(md"""
After every sweep, count the values $S$, $I$ and $R$ and push! them to 3 arrays. 
""")

# ╔═╡ f9b9e242-0a53-11eb-0c6a-4d9985ef1687
hint(md"""
```julia
let
	N = 50
	L = 40

	x = initialize(N, L)
	
	# initialize to empty arrays
	Ss, Is, Rs = Int[], Int[], Int[]
	
	Tmax = 200
	
	@gif for t in 1:Tmax
		for i in 1:50N
			step!(x, L, pandemic)
		end

		#... track S, I, R in Ss Is and Rs
		
		left = visualize(x, L)
	
		right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
		plot!(right, 1:t, Ss, color=color(S), label="S")
		plot!(right, 1:t, Is, color=color(I), label="I")
		plot!(right, 1:t, Rs, color=color(R), label="R")
	
		plot(left, right)
	end
end
```
""")

# ╔═╡ 0acaf3b2-0970-11eb-1d98-bf9a718deaee
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 0afab53c-0970-11eb-3e43-834513e4632e
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 0b21c93a-0970-11eb-33b0-550a39ba0843
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 0b470eb6-0970-11eb-182f-7dfb4662f827
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 0b6b27ec-0970-11eb-20c2-89515ee3ab88
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
let
	# we need to call Base.:+ instead of + to make Pluto understand what's going on
	# oops
	if @isdefined(Coordinate)
		result = Base.:+(Coordinate(3,4), Coordinate(10,10))

		if result isa Missing
			still_missing()
		elseif !(result isa Coordinate)
			keep_working(md"Make sure that your return a `Coordinate`. 🧭")
		elseif result.x != 13 || result.y != 14
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ 0b901714-0970-11eb-0b6a-ebe739db8037
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 66663fcc-0a58-11eb-3568-c1f990c75bf2
if !@isdefined(origin)
	not_defined(:origin)
else
	let
		if origin isa Missing
			still_missing()
		elseif !(origin isa Coordinate)
			keep_working(md"Make sure that `origin` is a `Coordinate`.")
		else
			if origin == Coordinate(0,0)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ ad1253f8-0a34-11eb-265e-fffda9b6473f
if !@isdefined(make_tuple)
	not_defined(:make_tuple)
else
	let
		result = make_tuple(Coordinate(2,1))
		if result isa Missing
			still_missing()
		elseif !(result isa Tuple)
			keep_working(md"Make sure that you return a `Tuple`, like so: `return (1, 2)`.")
		else
			if result == (2,1)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ 058e3f84-0a34-11eb-3f87-7118f14e107b
if !@isdefined(trajectory)
	not_defined(:trajectory)
else
	let
		c = Coordinate(8,8)
		t = trajectory(c, 100)
		
		if t isa Missing
			still_missing()
		elseif !(t isa Vector)
			keep_working(md"Make sure that you return a `Vector`.")
		elseif !(all(x -> isa(x, Coordinate), t))
			keep_working(md"Make sure that you return a `Vector` of `Coordinate`s.")
		else
			if length(t) != 100
				almost(md"Make sure that you return `n` elements.")
			elseif 1 < length(Set(t)) < 90
				correct()
			else
				keep_working(md"Are you sure that you chose each step randomly?")
			end
		end
	end
end

# ╔═╡ 4fac0f36-0a59-11eb-03d0-632dc9db063a
if !@isdefined(initialize)
	not_defined(:initialize)
else
	let
		N = 200
		result = initialize(N, 1)
		
		if result isa Missing
			still_missing()
		elseif !(result isa Vector) || length(result) != N
			keep_working(md"Make sure that you return a `Vector` of length `N`.")
		elseif any(e -> !(e isa Agent), result)
			keep_working(md"Make sure that you return a `Vector` of `Agent`s.")
		elseif length(Set(result)) != N
			keep_working(md"Make sure that you create `N` **new** `Agent`s. Do not repeat the same agent multiple times.")
		elseif sum(a -> a.status == S, result) == N-1 && sum(a -> a.status == I, result) == 1
			if 8 <= length(Set(a.position for a in result)) <= 9
				correct()
			else
				keep_working(md"The coordinates are not correctly sampled within the box.")
			end
		else
			keep_working(md"`N-1` agents should be Susceptible, 1 should be Infectious.")
		end
	end
end

# ╔═╡ d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
bigbreak = html"<br><br><br><br>";

# ╔═╡ fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
bigbreak

# ╔═╡ ed2d616c-0a66-11eb-1839-edf8d15cf82a
bigbreak

# ╔═╡ e84e0944-0a66-11eb-12d3-e12ae10f39a6
bigbreak

# ╔═╡ e0baf75a-0a66-11eb-0562-938b64a473ac
bigbreak

# ╔═╡ Cell order:
# ╟─19fe1ee8-0970-11eb-2a0d-7d25e7d773c6
# ╟─1bba5552-0970-11eb-1b9a-87eeee0ecc36
# ╟─49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# ╠═ffb5a526-73e6-11eb-25ff-017cea96b3dd
# ╠═b50c8f26-73e6-11eb-128b-c34ba3b91ca0
# ╠═ec340396-73f3-11eb-0311-6d75d4ce2e5b
# ╠═777fccec-73f3-11eb-3727-ada098475e56
# ╠═69c5e8da-73e8-11eb-035a-e9e896ec9d1b
# ╠═48f20160-73e9-11eb-3f5a-837134d9c669
# ╠═9c7ee6fe-73f3-11eb-39e2-5f001d3ac7d6
# ╠═a2c57c58-73e9-11eb-134c-a754271920d8
# ╠═ad8a9880-73f3-11eb-05b3-4d68e630c806
# ╠═efdccf28-73e9-11eb-05c0-4b679ead8340
# ╠═d611df84-73f3-11eb-31d5-53a466ab55aa
# ╠═a426ec40-73e8-11eb-3492-57220b642f3d
# ╠═313a4fcc-73f4-11eb-3b54-e9fad50c4135
# ╠═13923c60-73e9-11eb-0dba-f597850cfc1d
# ╠═44ea15b6-73f4-11eb-35eb-dd50ae9b24b1
# ╠═57278356-73f4-11eb-39e5-1de38470af7a
# ╠═6736b886-73ea-11eb-21f0-4db431d4cbca
# ╠═78d9774a-73f4-11eb-39f8-c5c657ff4e17
# ╠═2adeedbc-73eb-11eb-3042-67659cccf61c
# ╠═09fefab0-73f5-11eb-198c-ffa95ba77565
# ╠═487ac29c-73f5-11eb-1d39-893544c09124
# ╠═9d4fdbf2-73ea-11eb-1788-83d882e68681
# ╠═9d68af94-73f5-11eb-1ca8-757c4869b1ed
# ╠═44c03466-73eb-11eb-0d51-d568de70f72b
# ╠═cdcc0096-73f5-11eb-107d-719e2fcd9c31
# ╠═e3818dbc-73ea-11eb-0257-6d2225423c17
# ╠═fc617486-73f5-11eb-3901-db923b9458d1
# ╠═5945b654-73eb-11eb-3eac-49a2efbb1a81
# ╠═dadae716-73eb-11eb-3b75-d93bdda88fb1
# ╠═f78b16be-73ec-11eb-1bba-43ce6d1eb5b6
# ╠═181e156c-0970-11eb-0b77-49b143cc0fc0
# ╠═1f299cc6-0970-11eb-195b-3f951f92ceeb
# ╠═2848996c-0970-11eb-19eb-c719d797c322
# ╠═2b37ca3a-0970-11eb-3c3d-4f788b411d1a
# ╠═2dcb18d0-0970-11eb-048a-c1734c6db842
# ╠═69d12414-0952-11eb-213d-2f9e13e4b418
# ╠═fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
# ╠═3e54848a-0954-11eb-3948-f9d7f07f5e23
# ╠═3e623454-0954-11eb-03f9-79c873d069a0
# ╠═0ebd35c8-0972-11eb-2e67-698fd2d311d2
# ╟─027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
# ╠═b2f90634-0a68-11eb-1618-0b42f956b5a7
# ╟─66663fcc-0a58-11eb-3568-c1f990c75bf2
# ╟─3e858990-0954-11eb-3d10-d10175d8ca1c
# ╠═189bafac-0972-11eb-1893-094691b2073c
# ╟─ad1253f8-0a34-11eb-265e-fffda9b6473f
# ╟─73ed1384-0a29-11eb-06bd-d3c441b8a5fc
# ╠═96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
# ╠═b0337d24-0a29-11eb-1fab-876a87c0973f
# ╟─9c9f53b2-09ea-11eb-0cda-639764250cee
# ╠═e24d5796-0a68-11eb-23bb-d55d206f3c40
# ╠═ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
# ╟─e144e9d0-0a2d-11eb-016e-0b79eba4b2bb
# ╟─ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
# ╠═71c358d8-0a2f-11eb-29e1-57ff1915e84a
# ╠═5278e232-0972-11eb-19ff-a1a195127297
# ╟─71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
# ╠═69151ce6-0aeb-11eb-3a53-290ba46add96
# ╟─3eb46664-0954-11eb-31d8-d9c0b74cf62b
# ╠═edf86a0e-0a68-11eb-2ad3-dbf020037019
# ╟─44107808-096c-11eb-013f-7b79a90aaac8
# ╠═87ea0868-0a35-11eb-0ea8-63e27d8eda6e
# ╠═058e3f84-0a34-11eb-3f87-7118f14e107b
# ╠═478309f4-0a31-11eb-08ea-ade1755f53e0
# ╠═8e39d594-6a67-11eb-3d11-dd2e8628826c
# ╠═51788e8e-0a31-11eb-027e-fd9b0dc716b5
# ╟─3ebd436c-0954-11eb-170d-1d468e2c7a37
# ╠═dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
# ╟─b4d5da4a-09a0-11eb-1949-a5807c11c76c
# ╠═0237ebac-0a69-11eb-2272-35ea4e845d84
# ╠═ad832360-0a40-11eb-2857-e7f0350f3b12
# ╠═b4ed2362-09a0-11eb-0be9-99c91623b28f
# ╠═0665aa3e-0a69-11eb-2b5d-cd718e3c7432
# ╠═5690f57e-73c1-11eb-3c81-29dd31a1ed37
# ╠═e5f9cd58-73f1-11eb-2b2e-5b8e22dab523
# ╠═7e75b27c-72ff-11eb-36c2-c30458d8219d
# ╟─ed2d616c-0a66-11eb-1839-edf8d15cf82a
# ╟─3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
# ╠═35537320-0a47-11eb-12b3-931310f18dec
# ╠═cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# ╠═b0f78890-73c9-11eb-357c-4368669e3e3b
# ╟─814e888a-0954-11eb-02e5-0964c7410d30
# ╠═6e266dc4-73c7-11eb-331a-257c039be666
# ╠═0cfae7ba-0a69-11eb-3690-d973d70e47f4
# ╠═1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
# ╟─4fac0f36-0a59-11eb-03d0-632dc9db063a
# ╠═e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# ╠═b5a88504-0a47-11eb-0eda-f125d419e909
# ╠═87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
# ╠═49fa8092-0a43-11eb-0ba9-65785ac6a42f
# ╠═bf5718b2-73cc-11eb-3208-d386a4e2476b
# ╠═1ccc961e-0a69-11eb-392b-915be07ef38d
# ╠═1f96c80a-0a46-11eb-0690-f51c60e57c3f
# ╠═f953e06e-099f-11eb-3549-73f59fed8132
# ╠═e6dd8258-0a4b-11eb-24cb-fd5b3554381b
# ╠═de88b530-0a4b-11eb-05f7-85171594a8e8
# ╠═80f39140-0aef-11eb-21f7-b788c5eab5c9
# ╠═2bafa020-73d1-11eb-3f61-2120861ee90a
# ╠═d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
# ╟─34778744-0a5f-11eb-22b6-abe8b8fc34fd
# ╠═67b7a0b4-73d5-11eb-20e1-238933831c47
# ╠═0fdb9e86-73d5-11eb-208e-5df5441cd883
# ╠═24fe0f1a-0a69-11eb-29fe-5fb6cbf281b8
# ╠═35c43e5a-73ee-11eb-10be-67ec7440d460
# ╠═cd7d9034-73ee-11eb-0cac-c989e4002940
# ╟─1fc3271e-0a45-11eb-0e8d-0fd355f5846b
# ╠═5d45d5aa-73d6-11eb-35b1-45107b1b1928
# ╠═4e5592ce-73d6-11eb-0086-7db6559c0cd6
# ╠═eb10e374-73d7-11eb-3b15-c984b62e2384
# ╠═18552c36-0a4d-11eb-19a0-d7d26897af36
# ╠═1bac88b2-73dd-11eb-059e-e9bcb002aeeb
# ╠═adef838a-73dd-11eb-34a7-47654619efef
# ╠═778c2490-0a62-11eb-2a6c-e7fab01c6822
# ╟─e964c7f0-0a61-11eb-1782-0b728fab1db0
# ╠═4d83dbd0-0a63-11eb-0bdc-757f0e721221
# ╠═ef27de84-0a63-11eb-177f-2197439374c5
# ╟─8475baf0-0a63-11eb-1207-23f789d00802
# ╟─201a3810-0a45-11eb-0ac9-a90419d0b723
# ╠═e5040c9e-0a65-11eb-0f45-270ab8161871
# ╟─f9b9e242-0a53-11eb-0c6a-4d9985ef1687
# ╟─2031246c-0a45-11eb-18d3-573f336044bf
# ╠═63dd9478-0a45-11eb-2340-6d3d00f9bb5f
# ╠═269955e4-0a46-11eb-02cc-1946dc918bfa
# ╠═4d4548fe-0a66-11eb-375a-9313dc6c423d
# ╟─20477a78-0a45-11eb-39d7-93918212a8bc
# ╠═601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
# ╠═2e444a22-73e3-11eb-07ab-970a5c59e008
# ╠═5f5aa2b4-73e3-11eb-2088-dd733d084586
# ╠═218e569c-73e3-11eb-1cb9-4fa912eef6c9
# ╠═b1b1afda-0a66-11eb-2988-752405815f95
# ╟─e84e0944-0a66-11eb-12d3-e12ae10f39a6
# ╟─05c80a0c-09a0-11eb-04dc-f97e306f1603
# ╟─b53d5608-0a41-11eb-2325-016636a22f71
# ╠═1b5e72c6-0a42-11eb-3884-a377c72270c7
# ╟─c704ea4c-0aec-11eb-2f2c-859c954aa520
# ╠═e97e39aa-0a5d-11eb-3d5f-f90a0acfe5a2
# ╟─b554b654-0a41-11eb-0e0d-e57ff68ced33
# ╠═40c1c1d6-0a69-11eb-3913-59e9b9ec4332
# ╟─18ac9926-0aed-11eb-034f-e9849b71c9ac
# ╟─b56ba420-0a41-11eb-266c-719d39580fa9
# ╠═465e918a-0a69-11eb-1b59-01150b4b0f36
# ╟─a885bf78-0a5c-11eb-2383-9d74c8765847
# ╠═1f172700-0a42-11eb-353b-87c0039788bd
# ╟─b59de26c-0a41-11eb-2c67-b5f3c7780c91
# ╠═faec52a8-0a60-11eb-082a-f5787b09d88c
# ╟─b5b4d834-0a41-11eb-1b18-1bd626d18934
# ╠═a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
# ╟─05fc5634-09a0-11eb-038e-53d63c3edaf2
# ╠═24c2fb0c-0a42-11eb-1a1a-f1246f3420ff
# ╟─c7649966-0a41-11eb-3a3a-57363cea7b06
# ╠═2635b574-0a42-11eb-1daa-971b2596ce44
# ╟─c77b085e-0a41-11eb-2fcb-534238cd3c49
# ╠═274fe006-0a42-11eb-1869-29193bb84957
# ╟─c792374a-0a41-11eb-1e5b-89d9de2cf1f9
# ╠═d147f7f0-0a66-11eb-2877-2bc6680e396d
# ╟─e0baf75a-0a66-11eb-0562-938b64a473ac
# ╟─0e6b60f6-0970-11eb-0485-636624a0f9d7
# ╟─0a82a274-0970-11eb-20a2-1f590be0e576
# ╟─0aa666dc-0970-11eb-2568-99a6340c5ebd
# ╟─0acaf3b2-0970-11eb-1d98-bf9a718deaee
# ╟─0afab53c-0970-11eb-3e43-834513e4632e
# ╟─0b21c93a-0970-11eb-33b0-550a39ba0843
# ╟─0b470eb6-0970-11eb-182f-7dfb4662f827
# ╟─0b6b27ec-0970-11eb-20c2-89515ee3ab88
# ╟─0b901714-0970-11eb-0b6a-ebe739db8037
# ╟─d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
