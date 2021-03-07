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
	Pkg.add(["PlutoUI", "Plots", "StatsBase"])

	using Plots
	gr()
	using PlutoUI
	using Random
	using StatsBase
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

student = (name = "Jazzy Doe", kerberos_id = "jazz")

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
begin
	struct Coordinate{T}
		x::T
		y::T
	end
	
	Coordinate() = Coordinate(0, 0)
end

# ╔═╡ 027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
md"""
👉 Construct a `Coordinate` located at the origin.
"""

# ╔═╡ b2f90634-0a68-11eb-1618-0b42f956b5a7
origin = Coordinate()

# ╔═╡ 3e858990-0954-11eb-3d10-d10175d8ca1c
md"""
👉 Write a function `make_tuple` that takes an object of type `Coordinate` and returns the corresponding tuple `(x, y)`. Boring, but useful later!
"""

# ╔═╡ 189bafac-0972-11eb-1893-094691b2073c
function make_tuple(c)
	return (c.x, c.y)
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
begin
	up = Coordinate(0, 1)
	down = Coordinate(0, -1)
	left = Coordinate(-1, 0)
	right = Coordinate(1, 0)
	
	possible_moves = [up, down, left, right]
end

# ╔═╡ 71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
md"""
👉 `rand(possible_moves)` gives a random possible move. Add this to the coordinate `Coordinate(4,5)` and see that it moves to a valid neighbor.
"""

# ╔═╡ 34eb47f0-7437-11eb-3d7d-d39ae2b87124
Coordinate(4, 5) + rand(possible_moves)

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
function trajectory(w::Coordinate, n::Int)
	moves = rand(possible_moves, n)
	
	return accumulate(+, moves; init=w)	
end

# ╔═╡ 478309f4-0a31-11eb-08ea-ade1755f53e0
function plot_trajectory!(p::Plots.Plot, trajectory::Vector; kwargs...)
	plot!(p, make_tuple.(trajectory); 
		label=nothing, 
		linewidth=2, 
		linealpha=LinRange(1.0, 0.2, length(trajectory)),
		kwargs...)
end

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

# ╔═╡ 18436540-7439-11eb-0ff8-a5fe563adb0c
function collide_boundary(x::Number, L::Number)
	if x > L
		return L
	elseif x < -L
		return -L
	end
	
	return x
end

# ╔═╡ 0237ebac-0a69-11eb-2272-35ea4e845d84
function collide_boundary(c::Coordinate, L::Number)
	x = collide_boundary(c.x, L)
	y = collide_boundary(c.y, L)
	
	return Coordinate(x, y)
end

# ╔═╡ ad832360-0a40-11eb-2857-e7f0350f3b12
collide_boundary(Coordinate(12,4), 10) # uncomment to test

# ╔═╡ b4ed2362-09a0-11eb-0be9-99c91623b28f
md"""
#### Exercise 1.6
👉  Implement a 3-argument method  of `trajectory` where the third argument is a size. The trajectory returned should be within the boundary (use `collide_boundary` from above). You can still use `accumulate` with an anonymous function that makes a move and then reflects the resulting coordinate, or use a for loop.

"""

# ╔═╡ 0665aa3e-0a69-11eb-2b5d-cd718e3c7432
function trajectory(c::Coordinate, n::Int, L::Number)
	moves = rand(possible_moves, n)
	
	return accumulate((c, move) -> collide_boundary(c + move, L), moves; init=c)
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
let
	p = plot(ratio=1)
	for i ∈ 1:10
		traj = trajectory(Coordinate(), 1000)
		plot_trajectory!(p, traj)
	end
	p
end

# ╔═╡ 873c8e30-743a-11eb-3250-f386cd311c0b
let
	p = plot(ratio=1)
	for i ∈ 1:10
		traj = trajectory(Coordinate(), 1000, 20)
		plot_trajectory!(p, traj)
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

# ╔═╡ ac912450-7e87-11eb-3de7-57409621597a
abstract type AbstractAgent end

# ╔═╡ 0d44e9c0-7547-11eb-3317-a1e0280af9e9
md"**Mathijs note:** So what I was going to say was the following:

I've found enums cumbersome to work with in this case. In this example we want to do different things depending on the infection status (e.g. only infect if agent is susceptible and source is infected). We know all the statuses beforehand, so what I would suggest is to use singleton types instead. This way we can just use dispatch.

Turns out that that approach doesn't work well if used in a mutable struct. If you define code like the following:
"

# ╔═╡ ceaed8c0-7554-11eb-3367-8dd46abfdaae
begin
	abstract type AbstractInfectionStatus end
	struct Susceptible <: AbstractInfectionStatus end
	struct Infected <: AbstractInfectionStatus end
	struct Recovered <: AbstractInfectionStatus end
end

# ╔═╡ ed1b15d2-7554-11eb-2ea6-dde55b2fe194
md"With the above setup, a susceptible agent is of type `AgentDispatch{S}` and an infected one of type `AgentDispatch{I}`. But then we cannot change the status because we cannot change these types in-place! I.e. the following will throw an error:"

# ╔═╡ 35537320-0a47-11eb-12b3-931310f18dec
begin
	@enum InfectionStatus S I R
end

# ╔═╡ cf2f3b98-09a0-11eb-032a-49cc8c15e89c
begin
	mutable struct Agent <: AbstractAgent
		position::Coordinate
		status::InfectionStatus
		num_infected::Int
	end
	
	Agent(position::Coordinate, status::InfectionStatus) = Agent(position, status, 0)
	Agent(position::Coordinate) = Agent(position, S)
	Agent() = Agent(Coordinate())
end

# ╔═╡ d879b68e-7554-11eb-3fea-298297ac8001
begin
	mutable struct AgentDispatch{TI<:AbstractInfectionStatus} <: AbstractAgent
		position::Coordinate
		status::TI
		num_infected::Int
	end
	
	AgentDispatch(position::Coordinate, status::AbstractInfectionStatus) = Agent(position, status, 0)
	AgentDispatch(position::Coordinate) = Agent(position, Susceptible())
	AgentDispatch() = Agent(Coordinate())
end

# ╔═╡ 658be8f0-7555-11eb-0b06-9982d08c5c7f
let
	a = AgentDispatch(Coordinate(), Susceptible())
	a.status = Infected()
end

# ╔═╡ 2f7ef9e0-7556-11eb-2770-4bd731ae08c5
begin
	is_susceptible(a::AbstractAgent) = a.status == S
	is_infected(a::AbstractAgent) = a.status == I
	is_recovered(a::AbstractAgent) = a.status == R
end

# ╔═╡ dff49f02-7556-11eb-051f-2195a55c3266
begin
	get_num_infected(a::AbstractAgent) = a.num_infected
	function set_num_infected!(a::AbstractAgent, num_infected)
		a.num_infected = num_infected
	end
end

# ╔═╡ 814e888a-0954-11eb-02e5-0964c7410d30
md"""
#### Exercise 2.1
👉 Write a function `initialize` that takes parameters $N$ and $L$, where $N$ is the number of agents abd $2L$ is the side length of the square box where the agents live.

It returns a `Vector` of `N` randomly generated `Agent`s. Their coordinates are randomly sampled in the ``[-L,L] \times [-L,L]`` box, and the agents are all susceptible, except one, chosen at random, which is infectious.
"""

# ╔═╡ 985da280-7449-11eb-16ba-7d60cc59f7dc
struct Box{T<:Number}
	L::T
end

# ╔═╡ ee7ac530-7449-11eb-1105-e9de20c924c5
"""Generate random coordinate in the box"""
function Random.rand(rng::AbstractRNG, box::Random.SamplerTrivial{Box{T}} where T)
	L = box[].L
	x, y = rand(rng, -L:L, 2)
	return Coordinate(x, y)
end

# ╔═╡ 0b3a6e40-744b-11eb-17a6-efe4381f6168
rand(Box(20))

# ╔═╡ 0cfae7ba-0a69-11eb-3690-d973d70e47f4
begin
	function initialize(N::Number, box::Box)
		agents = [Agent(rand(box), S) for i ∈ 1:N]
		rand(agents).status = I
		return agents
	end
	
	function initialize(N::Number, L::Number)
		return initialize(N, Box(L))
	end
end

# ╔═╡ 1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
initialize(3, 10)

# ╔═╡ 4bda8cd0-744d-11eb-0198-6bc9e0d233f2
@code_warntype initialize(3, Box(10))

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
position(a::AbstractAgent) = a.position # uncomment this line

# ╔═╡ b55bd702-7451-11eb-0bba-91c2bd80781b
get_status(a::AbstractAgent) = a.status

# ╔═╡ 92ec7240-7543-11eb-0d5a-59cad2763e85
function set_status!(agent::AbstractAgent, new_status::InfectionStatus)
	agent.status = new_status
end

# ╔═╡ 87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
color(a::AbstractAgent) = color(a.status) # uncomment this line

# ╔═╡ 4f0645a0-7ac1-11eb-2c62-19ac7cc43791


# ╔═╡ 49fa8092-0a43-11eb-0ba9-65785ac6a42f
md"""
#### Exercise 2.2
👉 Write a function `visualize` that takes in a collection of agents as argument, and the box size `L`. It should plot a point for each agent at its location, coloured according to its status.

You can use the keyword argument `c=color.(agents)` inside your call to the plotting function make the point colors correspond to the infection statuses. Don't forget to use `ratio=1`.
"""

# ╔═╡ d9df1900-744e-11eb-3ef8-3118046387b4
begin
	xlims(box::Box) = (-box.L, box.L)
	ylims(box::Box) = (-box.L, box.L)
end

# ╔═╡ 3f4f7b30-78fb-11eb-24f9-911ebdcd5e95
floor(Int, 0.5)

# ╔═╡ ec79eb20-7454-11eb-2652-637794295267
begin
	rectangle(xb, yb, xt, yt) = [
		(xb, yb)
		(xt, yb)
		(xt, yt)
		(xb, yt)
		(xb, yb)
		(NaN, NaN)
	]
	rectangle(box::Box) = rectangle(-box.L, -box.L, box.L, box.L)
end


# ╔═╡ fed9ea10-744d-11eb-122d-712b18137086
begin
	function visualize!(p::Plots.Plot, agents::Vector, box::Box)
		plot!(rectangle(box), alpha=0.1, linecolor="black", label=nothing)
		scatter!(p, make_tuple.(position.(agents)),
			group = get_status.(agents),
			# c=[:blue :red :green],
			# color_palette=[:blue, :red, :green],
			# markercolor=:match,
			c=color.(agents),
			# xlims=xlims(box) .+ (-1, 1), 
			# ylims=ylims(box) .+ (-1, 1),
			legend=false
		)
	end
	
	visualize!(p, agents, L) = visualize!(p, agents, Box(L))
end

# ╔═╡ 1f96c80a-0a46-11eb-0690-f51c60e57c3f
let
	N = 20
	L = 10
	# visualize(initialize(N, L), L) # uncomment this line!
	get_status.(initialize(N, L))
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

# ╔═╡ b1779e70-7542-11eb-2422-5558bd99dbfd
begin
	get_p_infection(infection) = infection.p_infection
	get_p_recovery(infection) = infection.p_recovery
end

# ╔═╡ 80f39140-0aef-11eb-21f7-b788c5eab5c9
md"""

Write a function `interact!` that takes two `Agent`s and a `CollisionInfectionRecovery`, and:

- If the agents are at the same spot, causes a susceptible agent to communicate the desease from an infectious one with the correct probability.
- if the first agent is infectious, it recovers with some probability
"""

# ╔═╡ 9aedf730-7542-11eb-1834-7505b82c682f
function bernoulli(p::Number)
	
	return rand() < p
end

# ╔═╡ 4cf889a0-7542-11eb-3616-4d834e52ee4c
function infect!(agent::AbstractAgent, source::AbstractAgent)
	set_status!(agent, I)
	set_num_infected!(source, get_num_infected(source) + 1)
end

# ╔═╡ 55aa7d60-7542-11eb-075b-43faad33820b
begin
	function recover!(agent::AbstractAgent)
		set_status!(agent, R)
	end

	function recover!(agent::AbstractAgent, infection::AbstractInfection)
		recover!(agent::AbstractAgent)
	end
end

# ╔═╡ 5abba3b0-7542-11eb-3a7d-4d01597f636b
begin
	function try_infect!(agent::AbstractAgent, source::AbstractAgent, 
			infection::AbstractInfection)
		if bernoulli(get_p_infection(infection))
			infect!(agent, source)
		end
	end
	
	function try_recover!(agent::AbstractAgent, infection::AbstractInfection)
		if bernoulli(get_p_recovery(infection))
			recover!(agent, infection)
		end
	end
end

# ╔═╡ d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
begin
	function interact!(agent::AbstractAgent, source::AbstractAgent, infection::AbstractInfection)
		if is_susceptible(agent) && is_infected(source)
			try_infect!(agent, source, infection)		
		elseif is_infected(agent)
			try_recover!(agent, infection)
		end
	end
	
	function interact!(agent::AbstractAgent, source::AbstractAgent, infection::CollisionInfectionRecovery)
		if is_susceptible(agent) && is_infected(source) && position(agent) == position(source)
			try_infect!(agent, source, infection)
		elseif is_infected(agent)
			try_recover!(agent, infection)
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

# ╔═╡ 18552c36-0a4d-11eb-19a0-d7d26897af36
pandemic = CollisionInfectionRecovery(0.5, 0.00001)

# ╔═╡ 4e7fd58a-0a62-11eb-1596-c717e0845bd5
@bind k_sweeps Slider(1:10000, default=1000, show_value=true)

# ╔═╡ e964c7f0-0a61-11eb-1782-0b728fab1db0
md"""
#### Exercise 3.3

Every time that you move the slider, a completely new simulation is created an run. This makes it hard to view the progress of a single simulation over time. So in this exercise, we we look at a single simulation, and plot the S, I and R curves.

👉 Plot the SIR curves of a single simulation, with the same parameters as in the previous exercise. Use `k_sweep_max = 10000` as the total number of sweeps.
"""

# ╔═╡ 4d83dbd0-0a63-11eb-0bdc-757f0e721221
k_sweep_max = 10000

# ╔═╡ ef27de84-0a63-11eb-177f-2197439374c5
# sim33 = let
# 	N = 50
# 	L = 30
# 	agents = initialize(N, L)
	
# 	sim33 = Vector{Vector{Agent}}(undef, k_sweep_max + 1)
# 	sim33[1] = agents
	
# 	for k_s in 1:k_sweep_max
# 		agents = copy(agents)
# 		sweep!(agents, L, pandemic)
# 		sim33[k_s+1] = agents
# 	end
	
# 	sim33
# end

# ╔═╡ 3686e8a0-78ef-11eb-27bf-df870be6fc67
# @bind k_sweeps33 Slider(0:10000, default=1000, show_value=true)

# ╔═╡ 2a113620-78ef-11eb-24dd-87bf3f74fe7d
# visualize(sim33[k_sweeps33+1], 30)

# ╔═╡ 9f156740-7ac8-11eb-1b19-81425f434f27
abstract type AbstractSimulation end

# ╔═╡ 1356ecc0-7ac2-11eb-0d7b-1d303a8191b1
struct Simulation{T<:AbstractVector} <: AbstractSimulation
	S_counts::Vector{Int64}
	I_counts::Vector{Int64}
	R_counts::Vector{Int64}
	index::T  # Indicates what 'key' each count belongs to. E.g. `index=0:T` means the counts are observed at time points 0:T
	
	function Simulation(S_counts, I_counts, R_counts, index::T) where T
		length(S_counts) == length(I_counts) == length(R_counts) == length(index) || error("The lengths of the  S, I, R status counts (`S_counts`, `I_counts` and `R_counts`), as well as the `index` must be equal")
		
		return new{T}(S_counts, I_counts, R_counts, index)
	end
end

# ╔═╡ bbcd1680-7ac8-11eb-0bbb-f5bcd8d406f7
begin
	get_S_counts(sim::Simulation) = sim.S_counts
	get_I_counts(sim::Simulation) = sim.I_counts
	get_R_counts(sim::Simulation) = sim.R_counts
	Base.length(sim::Simulation) = length(sim.index)
	Base.getindex(sim::Simulation, inds) = Simulation(
		sim.S_counts[inds], sim.I_counts[inds], sim.R_counts[inds], sim.index[inds]
	)
end

# ╔═╡ 75377e30-7f7e-11eb-3867-9780a54b6a55


# ╔═╡ 6aa88270-78ee-11eb-28b5-edaa698dc6db
countmap([1, 1, 3, 4, 3])

# ╔═╡ 201a3810-0a45-11eb-0ac9-a90419d0b723
md"""
#### Exercise 3.4 (optional)
Let's make our plot come alive! There are two options to make our visualization dynamic:

👉1️⃣ Precompute one simulation run and save its intermediate states using `deepcopy`. You can then write an interactive visualization that shows both the state at time $t$ (using `visualize`) and the history of $S$, $I$ and $R$ from time $0$ up to time $t$. $t$ is controlled by a slider.

👉2️⃣ Use `@gif` from Plots.jl to turn a sequence of plots into an animation. Be careful to skip about 50 sweeps between each animation frame, otherwise the GIF becomes too large.

This an optional exercise, and our solution to 2️⃣ is given below.
"""

# ╔═╡ 083ea330-7ac9-11eb-2836-8964e6056026
"""Stores all intermediate states rather than just the `S_counts`, `I_counts` and `R_counts`"""
struct FullSimulation{TA<:AbstractAgent, TI<:AbstractVector} <: AbstractSimulation
	states::Vector{Vector{TA}}
	index::TI
end

# ╔═╡ cb3aaf70-7acc-11eb-1503-2d30395fec65
md"Not the most efficient implementation here: every time we want the count of one status we have to go through all of them. Better would be to cache the counts of all statuses at once. But for now this works."

# ╔═╡ 736b3e50-7acb-11eb-041a-01593f058052
begin
	get_S_counts(sim::FullSimulation) = [count(get_status.(agents) .== S) for agents in sim.states]
	get_I_counts(sim::FullSimulation) = [count(get_status.(agents) .== I) for agents in sim.states]
	get_R_counts(sim::FullSimulation) = [count(get_status.(agents) .== R) for agents in sim.states]
	Base.length(sim::FullSimulation) = length(sim.index)
	Base.getindex(sim::FullSimulation, inds) = FullSimulation(
		sim.states[inds], sim.index[inds]
	)
end

# ╔═╡ b7dd9100-7ac1-11eb-342b-0df45dda99da
begin
	function Plots.plot(sim::AbstractSimulation, args...; kw...)
		sir = [get_S_counts(sim), get_I_counts(sim), get_R_counts(sim)]
		
		plot(sim.index, sir, args...; label=[S I R],  kw...)
	end

	function Plots.plot!(plt::Plots.Plot, sim::AbstractSimulation, args...; kw...)
		sir = [get_S_counts(sim), get_I_counts(sim), get_R_counts(sim)]
		
		plot!(plt, sim.index, sir, args...; label=[S I R], kw...)
	end
end

# ╔═╡ 8f54e7d0-7ace-11eb-3ace-69b23953d99f
@bind t Slider(0:k_sweep_max, show_value=true)

# ╔═╡ ba95a3be-7acf-11eb-33a8-0b50577145d1
# Takes about 3 min, uncomment to get a cool gif!
# @gif for t ∈ 0:k_sweep_max
#     p_vis = visualize(simulation.states[t+1], 30)
# 	p_sir = plot(simulation[1:t+1])
	
# 	plot(p_vis, p_sir)
# end every 50

# ╔═╡ 2031246c-0a45-11eb-18d3-573f336044bf
md"""
#### Exercise 3.5
👉  Using $L=20$ and $N=100$, experiment with the infection and recovery probabilities until you find an epidemic outbreak. (Take the recovery probability quite small.) Modify the two infections below to match your observations.
"""

# ╔═╡ f4e88890-7b8c-11eb-086d-07bfd284ce5c
@bind causes_outbreak_p_infection Slider(0.001:0.001:0.5, default=0.01, 
	show_value=true)

# ╔═╡ b5a385d0-7b8d-11eb-386a-ef00c57f12da
@bind causes_outbreak_p_recovery Slider(1.0e-5:1.0e-5:1.0e-3, default=1.0e-4, 
	show_value=true)

# ╔═╡ 63dd9478-0a45-11eb-2340-6d3d00f9bb5f
causes_outbreak = CollisionInfectionRecovery(0.2, 3.0e-5)
# causes_outbreak = CollisionInfectionRecovery(0.319, 5.0e-5)
# causes_outbreak = CollisionInfectionRecovery(causes_outbreak_p_infection, 
# 	causes_outbreak_p_recovery)

# ╔═╡ 5983d090-7b90-11eb-2d92-15cc560a7223
@bind does_not_cause_outbreak_p_infection Slider(0.001:0.001:0.5, default=0.01, 
	show_value=true)

# ╔═╡ 5e8f518e-7b90-11eb-1f09-45599163b062
@bind does_not_cause_outbreak_p_recovery Slider(1.0e-5:1.0e-5:1.0e-3, default=1.0e-4, 
	show_value=true)

# ╔═╡ 6151f400-7b90-11eb-3e0b-b1f7e7d355db
does_not_cause_outbreak = CollisionInfectionRecovery(0.147, 8.0e-5)
# does_not_cause_outbreak = CollisionInfectionRecovery(0.213, 0.00012)
# does_not_cause_outbreak = CollisionInfectionRecovery(
# 	does_not_cause_outbreak_p_infection, does_not_cause_outbreak_p_recovery
# )

# ╔═╡ 20477a78-0a45-11eb-39d7-93918212a8bc
md"""
#### Exercise 3.6
👉 With the parameters of Exercise 3.2, run 50 simulations. Plot $S$, $I$ and $R$ as a function of time for each of them (with transparency!). This should look qualitatively similar to what you saw in the previous homework. You probably need different `p_infection` and `p_recovery` values from last week. Why?
"""

# ╔═╡ b1b1afda-0a66-11eb-2988-752405815f95
need_different_parameters_because = md"""
Compare parameters of HW4: InfectionRecovery(0.02, 0.002).

In this simulation we see the pandemic spreads slower with the same parameters than in HW4: infectious agents have to be in the same position as susceptible ones to infect, making it so that the infection probability has to be much higher (0.5) and recovery much lower (1e-5) to get a similar result. The pandemic is much more variable as well,  depending on how many susceptible agents the infected encounter.
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

# ╔═╡ e0b81550-7e86-11eb-0e16-5d22a85ddd4c
begin
	mutable struct SocialAgent <: AbstractAgent
		position::Coordinate
		status::InfectionStatus
		num_infected::Int64
		social_score::Float64
	end
	
	SocialAgent(position::Coordinate, status::InfectionStatus, social_score::Float64) = SocialAgent(position, status, 0, social_score)
	SocialAgent(position::Coordinate, social_score::Float64) = SocialAgent(position, S, social_score)
	SocialAgent(social_score::Float64) = SocialAgent(Coordinate(), social_score)
end

# ╔═╡ c704ea4c-0aec-11eb-2f2c-859c954aa520
md"""define the `position` and `color` methods for `SocialAgent` as we did for `Agent`. This will allow the `visualize` function to work. on both kinds of Agents"""

# ╔═╡ ea248f60-7e9a-11eb-20e9-693fe26f692a
md"Not needed, `position` and `color` have now been defined taking `AbstractAgent` as input"

# ╔═╡ f9ab7980-7e9a-11eb-0957-fb31aec07307
get_social_score(a::SocialAgent) = a.social_score

# ╔═╡ b554b654-0a41-11eb-0e0d-e57ff68ced33
md"""
👉 Create a function `initialize_social` that takes `N` and `L`, and creates N agents  within a 2L x 2L box, with `social_score`s chosen from 10 equally-spaced between 0.1 and 0.5. (see LinRange)
"""

# ╔═╡ c6a1c4de-7e86-11eb-221b-8fb2e5288f87
begin
	function initialize_social(N::Number, box::Box)
		social_scores = LinRange(0.1, 0.5, 10)
		agents = [SocialAgent(rand(box), S, rand(social_scores)) for i ∈ 1:N]
		rand(agents).status = I
		return agents
	end
	
	function initialize_social(N::Number, L::Number)
		return initialize_social(N, Box(L))
	end
end

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

# ╔═╡ 0bfe5a10-7e89-11eb-12de-b33e38014545
get_p_risky_interaction(agent::SocialAgent, source::SocialAgent) = 
	agent.social_score + source.social_score

# ╔═╡ 5f6c3b40-7e89-11eb-3f7d-151c87891daf
is_risky_interaction(agent::SocialAgent, source::SocialAgent) = 	
	bernoulli(get_p_risky_interaction(agent, source))

# ╔═╡ f627af22-7e88-11eb-1257-dd5d91ca2818
	function interact!(agent::SocialAgent, source::SocialAgent, infection::CollisionInfectionRecovery)
		if is_susceptible(agent) && is_infected(source) && position(agent) == position(source) && is_risky_interaction(agent, source)
			try_infect!(agent, source, infection)
		elseif is_infected(agent)
			try_recover!(agent, infection)
		end
	end 

# ╔═╡ d0f6dcb2-7543-11eb-175b-efa4ab8e858a
let
	agent = Agent(Coordinate(), S)
	source = Agent(Coordinate(), I)
	infection = CollisionInfectionRecovery(0.5, 0.002)
	interact!(agent, source, infection)
	agent
end

# ╔═╡ f3f3b0d2-78e5-11eb-392a-2fde7fb451eb
begin
	function step!(source::AbstractAgent, move::Coordinate, L::Number)
		source.position = collide_boundary(source.position + move, L)
	end
	
	function step!(source, L::Number)
		step!(source, rand(possible_moves), L)
	end
	
	function step!(agents::Vector, L::Number, infection::AbstractInfection)
		i_source = rand(1:length(agents))
		source = agents[i_source]
		step!(source, L)
		
		other_agents = agents[1:end .!= i_source]
		for other_agent in other_agents
			interact!(other_agent, source, infection)
		end
		
		return agents
	end
end


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

# ╔═╡ 2c950880-7e9a-11eb-375b-f70d2ac630c2
md"Interesting... I got two peaks in the outbreak"

# ╔═╡ b59de26c-0a41-11eb-2c67-b5f3c7780c91
md"""
#### Exercise 4.4
👉 Make a scatter plot showing each agent's `social_score` on one axis, and the `num_infected` from the simulation in the other axis. Run this simulation several times and comment on the results.
"""

# ╔═╡ 376998b0-7e9b-11eb-3b9b-23f8c8e0773c
md"As the social score gets higher, agents tend to infect more people"

# ╔═╡ b5b4d834-0a41-11eb-1b18-1bd626d18934
md"""
👉 Run a simulation for 100 steps, and then apply a "lockdown" where every agent's social score gets multiplied by 0.25, and then run a second simulation which runs on that same population from there.  What do you notice?  How does changing this factor form 0.25 to other numbers affect things?
"""

# ╔═╡ a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
function lockdown!(agents::AbstractVector{SocialAgent})
	for a in agents
		a.social_score *= 0.25
	end
	
	return
end

# ╔═╡ 20c7b910-7e9c-11eb-3a73-730fb1c5783f
function lift_lockdown!(agents::AbstractVector{SocialAgent})
	for a in agents
		a.social_score *= 4
	end
	
	return
end

# ╔═╡ 62c9f520-7e9d-11eb-2bdb-d317ce2293a5
md"After lockdown, the infections no longer rise"

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

# ╔═╡ 7f3823ee-7f7c-11eb-18a2-015a42915706
md"If $p_M=0$ then only neighbouring agents can infect each other. So what will happen is there will be hubs of infections that stay in one place."

# ╔═╡ b0e1c040-7f78-11eb-2d5d-390bd2347ec0
begin
	mutable struct MobileAgent <: AbstractAgent
		position::Coordinate
		status::InfectionStatus
		num_infected::Int64
		p_move::Float64
	end
	
	MobileAgent(position::Coordinate, status::InfectionStatus, p_move::Float64) = MobileAgent(position, status, 0, p_move)
	MobileAgent(position::Coordinate, p_move::Float64) = MobileAgent(position, S, p_move)
	MobileAgent(social_score::Float64) = MobileAgent(Coordinate(), p_move)
end

# ╔═╡ 372364e0-7f80-11eb-028b-91aa1639cf09
begin
	function initialize_mobile(N::Number, box::Box, p_move::Float64)
		agent_by_position = Dict{Coordinate, MobileAgent}()
		
		i = 0
		while i < N
			pos = rand(box)
			if !haskey(agent_by_position, pos)
				agent_by_position[pos] = MobileAgent(pos, S, p_move)
				i += 1
			end
		end
		
		infected_agent = rand(agent_by_position).second
		infected_agent.status = I
				
		return agent_by_position
	end
	
	function initialize_mobile(N::Number, L::Number, p_move::Float64)
		return initialize_mobile(N, Box(L), p_move)
	end
end

# ╔═╡ 24c2fb0c-0a42-11eb-1a1a-f1246f3420ff
begin
	function try_infect_neighbour!(source::AbstractAgent, 
			agent_by_position::Dict{Coordinate, T}, L::Number,
			infection::AbstractInfection) where {T<:AbstractAgent}
		
		try_infect_neighbour!(
			source, agent_by_position, rand(possible_moves), L, infection
		)
	end
	
	function try_infect_neighbour!(source::AbstractAgent, 
			agent_by_position::Dict{Coordinate, T}, 
			move::Coordinate,
			L::Number,
			infection::AbstractInfection) where {T<:AbstractAgent}
		
		new_position = collide_boundary(source.position + move, L)
		if haskey(agent_by_position, new_position) && 
			bernoulli(get_p_infection(infection))
			infect!(source, agent_by_position[new_position])
		end
	end
	
	function step!(agent::MobileAgent, 
			agent_by_position::AbstractDict{Coordinate, T}, 
			move::Coordinate, 
			L::Number) where {T<:AbstractAgent}
		
		new_position = collide_boundary(agent.position + move, L)
		if !haskey(agent_by_position, new_position) && bernoulli(agent.p_move)
			delete!(agent_by_position, agent.position)
			agent_by_position[new_position] = agent
			agent.position = new_position
		end
	end
	
	function step!(agent, agent_by_position::AbstractDict{Coordinate, T}, 
			L::Number) where {T<:AbstractAgent}
		
		step!(agent, agent_by_position, rand(possible_moves), L)
	end
	
	function step!(agent_by_position::AbstractDict{Coordinate, T}, 
			L::Number, infection::AbstractInfection) where {T<:AbstractAgent}
		
		maybe_infected_agent = rand(agent_by_position).second
		if is_infected(maybe_infected_agent)
			try_infect_neighbour!(
				maybe_infected_agent, agent_by_position, L, infection
			)
		end
		
		moving_agent = rand(agent_by_position).second
		step!(moving_agent, agent_by_position, L)
		
		return agent_by_position
	end
end

# ╔═╡ e372c460-78e7-11eb-1c68-53cf521ff221
function sweep!(agents, L::Number, infection::AbstractInfection)
	for i in 1:length(agents)
		step!(agents, L, infection)
	end
end

# ╔═╡ 86f3f0b0-7ac2-11eb-2727-87853e0f38d0
begin
	function simulate_sir(agents::AbstractVector{T}, L::Int64,
			k_sweeps::Int64, infection::AbstractInfection
		) where {T<:AbstractAgent}
		
		S_counts = Vector{Int64}(undef, k_sweeps + 1)
		I_counts = Vector{Int64}(undef, k_sweeps + 1)
		R_counts = Vector{Int64}(undef, k_sweeps + 1)
		
		counts = countmap(get_status.(agents))
		S_counts[1] = get(counts, S, 0)
		I_counts[1] = get(counts, I, 0)
		R_counts[1] = get(counts, R, 0)

		for i in 1:k_sweeps
			sweep!(agents, L, infection)

			counts = countmap(get_status.(agents))
			S_counts[i+1] = get(counts, S, 0)
			I_counts[i+1] = get(counts, I, 0)
			R_counts[i+1] = get(counts, R, 0)
		end

		return Simulation(S_counts, I_counts, R_counts, 0:k_sweeps)
	end
	
	function simulate_sir(N::Int64, L::Int64, k_sweeps::Int64, 
			infection::AbstractInfection, initialize
		)

		agents = initialize(N, L)
		return simulate_sir(agents, L, k_sweeps, infection)
	end
	
	function simulate_sir(N::Int64, L::Int64, k_sweeps::Int64, 
			infection::AbstractInfection
		)
		
		return simulate_sir(N, L, k_sweeps, infection, initialize)
	end
end

# ╔═╡ eb1d072e-7acb-11eb-0b10-21946f29f662
begin
	function simulate_full_sir(agents::AbstractVector{T},
			L::Int64, k_sweeps::Int64, infection::AbstractInfection
		) where {T<:AbstractAgent}
		
		states = Vector{Vector{T}}(undef, k_sweeps + 1)
		states[1] = agents

		for i in 1:k_sweeps
			agents = deepcopy(agents)
			sweep!(agents, L, infection)
			states[i+1] = agents
		end

		return FullSimulation(states, 0:k_sweeps)
	end
	
	function simulate_full_sir(N::Int64, L::Int64, k_sweeps::Int64, 
			infection::AbstractInfection, initialize
		)

		agents = initialize(N, L)
		return simulate_full_sir(agents, L, k_sweeps, infection)
	end
	
	function simulate_full_sir(N::Int64, L::Int64, k_sweeps::Int64, 
			infection::AbstractInfection
		)

		return simulate_full_sir(N, L, k_sweeps, infection, initialize)
	end
end

# ╔═╡ e5040c9e-0a65-11eb-0f45-270ab8161871
simulation = let
	N = 50
	L = 30
	simulation = simulate_full_sir(N, L, k_sweep_max, pandemic)
end

# ╔═╡ 12a3a220-7f7f-11eb-2ca5-d31fd4c50956
let
	d = Dict("a" => 2, "b" => 3)
	values(d) .* 2
end

# ╔═╡ cba2c0e0-7f7e-11eb-08e3-498f4678662b
begin
	function visualize!(p::Plots.Plot, 
			agents::AbstractDict{Coordinate, T}, box::Box) where {T<:AbstractAgent}
		
		visualize!(p, values(agents), box)
	end
end

# ╔═╡ 1ccc961e-0a69-11eb-392b-915be07ef38d
function visualize(agents, box)
	p = plot(ratio=1)
	visualize!(p, agents, box)

	return p
end

# ╔═╡ 778c2490-0a62-11eb-2a6c-e7fab01c6822
let
	N = 50
	L = 40
	agents = initialize(N, L)
	
	plot_before = visualize(agents, L)
	
	for i in 1:k_sweeps
		sweep!(agents, L, pandemic)
	end
	
	plot_after = visualize(agents, L)
	
	plot(plot_before, plot_after)
end

# ╔═╡ 5f3cef60-7acf-11eb-13fc-f73f4a813fb9
let
	p_vis = visualize(simulation.states[t+1], 30)
	p_sir = plot(simulation[1:t+1])
	
	plot(p_vis, p_sir)
end

# ╔═╡ 1f172700-0a42-11eb-353b-87c0039788bd
let
	N = 50
	L = 40	
	Tmax = 10_000
	
	simulation = simulate_full_sir(N, L, Tmax, pandemic, initialize_social)
	
	@gif for t in 0:50:Tmax  # This simulation runs from 0:Tmax rather than 1:Tmax
		
		left = visualize(simulation.states[t+1], L)
		right = plot(simulation[1:t+1])
		
		plot(left, right, size=(600,300))
		
		# 1. Step! a lot
		# 2. Count S, I and R, push them to Ss Is Rs
		# 3. call visualize on the agents,
		# 4. place the SIR plot next to visualize.
		# plot(left, right, size=(600,300)) # final plot
	end
end

# ╔═╡ c7649966-0a41-11eb-3a3a-57363cea7b06
md"""
👉 Run the dynamics repeatedly, and plot the sites which become infected.
"""

# ╔═╡ 2635b574-0a42-11eb-1daa-971b2596ce44
function simulate_sir(agent_by_position::AbstractDict{Coordinate, T}, L::Int64,
		k_sweeps::Int64, infection::AbstractInfection
	) where {T<:AbstractAgent}
	
	agents = values(agent_by_position)
	
	S_counts = Vector{Int64}(undef, k_sweeps + 1)
	I_counts = Vector{Int64}(undef, k_sweeps + 1)
	R_counts = Vector{Int64}(undef, k_sweeps + 1)

	counts = countmap(get_status.(agents))
	S_counts[1] = get(counts, S, 0)
	I_counts[1] = get(counts, I, 0)
	R_counts[1] = get(counts, R, 0)

	for i in 1:k_sweeps
		sweep!(agent_by_position, L, infection)

		counts = countmap(get_status.(agents))
		S_counts[i+1] = get(counts, S, 0)
		I_counts[i+1] = get(counts, I, 0)
		R_counts[i+1] = get(counts, R, 0)
	end

	return Simulation(S_counts, I_counts, R_counts, 0:k_sweeps)
end

# ╔═╡ ecd1c042-7ac4-11eb-2446-87fe06e6c67f
let
	N = 50
	L = 30
	simulation = simulate_sir(N, L, k_sweep_max, pandemic)
	plot(simulation)
end

# ╔═╡ 4d4548fe-0a66-11eb-375a-9313dc6c423d
let
	N = 100
	L = 20
	simulation = simulate_sir(N, L, k_sweep_max, causes_outbreak)
	plot(simulation)
end

# ╔═╡ 74301f70-7b90-11eb-1cba-9fd97d1d17a9
let
	N = 100
	L = 20
	simulation = simulate_sir(N, L, k_sweep_max, does_not_cause_outbreak)
	plot(simulation)
end

# ╔═╡ 601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
let
	N = 50
	L = 40
	p = plot()

	for i ∈ 1:50
		simulation = simulate_sir(N, L, k_sweep_max, pandemic)
		plot!(p, simulation, linealpha=0.5, c=[:blue :red :green])
	end
	
	p
end

# ╔═╡ faec52a8-0a60-11eb-082a-f5787b09d88c
let
	N = 50
	L = 40
	Tmax = 10_000
	
	agents = initialize_social(N, L)
	simulation = simulate_sir(agents, L, Tmax, pandemic)
	
	
	scatter(get_social_score.(agents), get_num_infected.(agents), legend=false,
		xlabel="Social score", ylabel="Number of people infected by agent"
	)
end

# ╔═╡ 3bf7ddf0-7e9c-11eb-0403-8d4455419126
let
	N = 50
	L = 40
	Tmax = 5_000
	
	agents = initialize_social(N, L)
	simulation1 = simulate_sir(agents, L, Tmax ÷ 2, pandemic)
	
	lockdown!(agents)
	
	simulation2 = simulate_sir(agents, L, Tmax ÷ 2, pandemic)
	
	left = plot(simulation1)
	right = plot(simulation2)
	
	plot(left, right)
end

# ╔═╡ 34eb0110-7f80-11eb-3b74-897c2a8598d7


# ╔═╡ 1486eba2-7f80-11eb-01b5-8518dfdcc840
let
	N = 50
	L = 40
	Tmax = 5_000
	p_move = 0.0
	
	agent_by_position = initialize_mobile(N, L, p_move)
	simulation = simulate_sir(agent_by_position, L, Tmax ÷ 2, pandemic)
	
	visualize(agent_by_position, L)
end

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
# ╟─181e156c-0970-11eb-0b77-49b143cc0fc0
# ╠═1f299cc6-0970-11eb-195b-3f951f92ceeb
# ╟─2848996c-0970-11eb-19eb-c719d797c322
# ╠═2b37ca3a-0970-11eb-3c3d-4f788b411d1a
# ╠═2dcb18d0-0970-11eb-048a-c1734c6db842
# ╟─69d12414-0952-11eb-213d-2f9e13e4b418
# ╟─fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
# ╟─3e54848a-0954-11eb-3948-f9d7f07f5e23
# ╟─3e623454-0954-11eb-03f9-79c873d069a0
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
# ╟─71c358d8-0a2f-11eb-29e1-57ff1915e84a
# ╠═5278e232-0972-11eb-19ff-a1a195127297
# ╟─71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
# ╠═34eb47f0-7437-11eb-3d7d-d39ae2b87124
# ╟─3eb46664-0954-11eb-31d8-d9c0b74cf62b
# ╠═edf86a0e-0a68-11eb-2ad3-dbf020037019
# ╠═44107808-096c-11eb-013f-7b79a90aaac8
# ╟─87ea0868-0a35-11eb-0ea8-63e27d8eda6e
# ╟─058e3f84-0a34-11eb-3f87-7118f14e107b
# ╠═478309f4-0a31-11eb-08ea-ade1755f53e0
# ╠═51788e8e-0a31-11eb-027e-fd9b0dc716b5
# ╟─3ebd436c-0954-11eb-170d-1d468e2c7a37
# ╠═dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
# ╟─b4d5da4a-09a0-11eb-1949-a5807c11c76c
# ╠═18436540-7439-11eb-0ff8-a5fe563adb0c
# ╠═0237ebac-0a69-11eb-2272-35ea4e845d84
# ╠═ad832360-0a40-11eb-2857-e7f0350f3b12
# ╟─b4ed2362-09a0-11eb-0be9-99c91623b28f
# ╠═0665aa3e-0a69-11eb-2b5d-cd718e3c7432
# ╠═873c8e30-743a-11eb-3250-f386cd311c0b
# ╟─ed2d616c-0a66-11eb-1839-edf8d15cf82a
# ╟─3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
# ╠═ac912450-7e87-11eb-3de7-57409621597a
# ╟─0d44e9c0-7547-11eb-3317-a1e0280af9e9
# ╠═ceaed8c0-7554-11eb-3367-8dd46abfdaae
# ╠═d879b68e-7554-11eb-3fea-298297ac8001
# ╟─ed1b15d2-7554-11eb-2ea6-dde55b2fe194
# ╠═658be8f0-7555-11eb-0b06-9982d08c5c7f
# ╠═35537320-0a47-11eb-12b3-931310f18dec
# ╠═cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# ╠═2f7ef9e0-7556-11eb-2770-4bd731ae08c5
# ╠═dff49f02-7556-11eb-051f-2195a55c3266
# ╟─814e888a-0954-11eb-02e5-0964c7410d30
# ╠═985da280-7449-11eb-16ba-7d60cc59f7dc
# ╠═ee7ac530-7449-11eb-1105-e9de20c924c5
# ╠═0b3a6e40-744b-11eb-17a6-efe4381f6168
# ╠═0cfae7ba-0a69-11eb-3690-d973d70e47f4
# ╠═1d0f8eb4-0a46-11eb-38e7-63ecbadbfa20
# ╠═4bda8cd0-744d-11eb-0198-6bc9e0d233f2
# ╟─4fac0f36-0a59-11eb-03d0-632dc9db063a
# ╠═e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# ╠═b5a88504-0a47-11eb-0eda-f125d419e909
# ╠═b55bd702-7451-11eb-0bba-91c2bd80781b
# ╠═92ec7240-7543-11eb-0d5a-59cad2763e85
# ╠═87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
# ╠═4f0645a0-7ac1-11eb-2c62-19ac7cc43791
# ╟─49fa8092-0a43-11eb-0ba9-65785ac6a42f
# ╠═d9df1900-744e-11eb-3ef8-3118046387b4
# ╠═3f4f7b30-78fb-11eb-24f9-911ebdcd5e95
# ╠═fed9ea10-744d-11eb-122d-712b18137086
# ╠═ec79eb20-7454-11eb-2652-637794295267
# ╠═1ccc961e-0a69-11eb-392b-915be07ef38d
# ╠═1f96c80a-0a46-11eb-0690-f51c60e57c3f
# ╟─f953e06e-099f-11eb-3549-73f59fed8132
# ╠═e6dd8258-0a4b-11eb-24cb-fd5b3554381b
# ╠═de88b530-0a4b-11eb-05f7-85171594a8e8
# ╠═b1779e70-7542-11eb-2422-5558bd99dbfd
# ╟─80f39140-0aef-11eb-21f7-b788c5eab5c9
# ╠═9aedf730-7542-11eb-1834-7505b82c682f
# ╠═4cf889a0-7542-11eb-3616-4d834e52ee4c
# ╠═55aa7d60-7542-11eb-075b-43faad33820b
# ╠═5abba3b0-7542-11eb-3a7d-4d01597f636b
# ╠═d1bcd5c4-0a4b-11eb-1218-7531e367a7ff
# ╠═d0f6dcb2-7543-11eb-175b-efa4ab8e858a
# ╟─34778744-0a5f-11eb-22b6-abe8b8fc34fd
# ╠═f3f3b0d2-78e5-11eb-392a-2fde7fb451eb
# ╟─1fc3271e-0a45-11eb-0e8d-0fd355f5846b
# ╠═e372c460-78e7-11eb-1c68-53cf521ff221
# ╟─18552c36-0a4d-11eb-19a0-d7d26897af36
# ╠═4e7fd58a-0a62-11eb-1596-c717e0845bd5
# ╠═778c2490-0a62-11eb-2a6c-e7fab01c6822
# ╟─e964c7f0-0a61-11eb-1782-0b728fab1db0
# ╠═4d83dbd0-0a63-11eb-0bdc-757f0e721221
# ╠═ef27de84-0a63-11eb-177f-2197439374c5
# ╠═3686e8a0-78ef-11eb-27bf-df870be6fc67
# ╠═2a113620-78ef-11eb-24dd-87bf3f74fe7d
# ╠═9f156740-7ac8-11eb-1b19-81425f434f27
# ╠═1356ecc0-7ac2-11eb-0d7b-1d303a8191b1
# ╠═bbcd1680-7ac8-11eb-0bbb-f5bcd8d406f7
# ╠═75377e30-7f7e-11eb-3867-9780a54b6a55
# ╠═86f3f0b0-7ac2-11eb-2727-87853e0f38d0
# ╠═b7dd9100-7ac1-11eb-342b-0df45dda99da
# ╠═ecd1c042-7ac4-11eb-2446-87fe06e6c67f
# ╠═6aa88270-78ee-11eb-28b5-edaa698dc6db
# ╟─8475baf0-0a63-11eb-1207-23f789d00802
# ╟─201a3810-0a45-11eb-0ac9-a90419d0b723
# ╠═083ea330-7ac9-11eb-2836-8964e6056026
# ╟─cb3aaf70-7acc-11eb-1503-2d30395fec65
# ╠═736b3e50-7acb-11eb-041a-01593f058052
# ╠═eb1d072e-7acb-11eb-0b10-21946f29f662
# ╠═e5040c9e-0a65-11eb-0f45-270ab8161871
# ╠═8f54e7d0-7ace-11eb-3ace-69b23953d99f
# ╠═5f3cef60-7acf-11eb-13fc-f73f4a813fb9
# ╠═ba95a3be-7acf-11eb-33a8-0b50577145d1
# ╟─f9b9e242-0a53-11eb-0c6a-4d9985ef1687
# ╟─2031246c-0a45-11eb-18d3-573f336044bf
# ╠═f4e88890-7b8c-11eb-086d-07bfd284ce5c
# ╠═b5a385d0-7b8d-11eb-386a-ef00c57f12da
# ╠═63dd9478-0a45-11eb-2340-6d3d00f9bb5f
# ╠═4d4548fe-0a66-11eb-375a-9313dc6c423d
# ╠═5983d090-7b90-11eb-2d92-15cc560a7223
# ╠═5e8f518e-7b90-11eb-1f09-45599163b062
# ╠═6151f400-7b90-11eb-3e0b-b1f7e7d355db
# ╠═74301f70-7b90-11eb-1cba-9fd97d1d17a9
# ╟─20477a78-0a45-11eb-39d7-93918212a8bc
# ╠═601f4f54-0a45-11eb-3d6c-6b9ec75c6d4a
# ╠═b1b1afda-0a66-11eb-2988-752405815f95
# ╟─e84e0944-0a66-11eb-12d3-e12ae10f39a6
# ╟─05c80a0c-09a0-11eb-04dc-f97e306f1603
# ╟─b53d5608-0a41-11eb-2325-016636a22f71
# ╠═e0b81550-7e86-11eb-0e16-5d22a85ddd4c
# ╟─c704ea4c-0aec-11eb-2f2c-859c954aa520
# ╠═ea248f60-7e9a-11eb-20e9-693fe26f692a
# ╠═f9ab7980-7e9a-11eb-0957-fb31aec07307
# ╟─b554b654-0a41-11eb-0e0d-e57ff68ced33
# ╠═c6a1c4de-7e86-11eb-221b-8fb2e5288f87
# ╟─18ac9926-0aed-11eb-034f-e9849b71c9ac
# ╟─b56ba420-0a41-11eb-266c-719d39580fa9
# ╠═0bfe5a10-7e89-11eb-12de-b33e38014545
# ╠═5f6c3b40-7e89-11eb-3f7d-151c87891daf
# ╠═f627af22-7e88-11eb-1257-dd5d91ca2818
# ╟─a885bf78-0a5c-11eb-2383-9d74c8765847
# ╠═1f172700-0a42-11eb-353b-87c0039788bd
# ╠═2c950880-7e9a-11eb-375b-f70d2ac630c2
# ╟─b59de26c-0a41-11eb-2c67-b5f3c7780c91
# ╠═faec52a8-0a60-11eb-082a-f5787b09d88c
# ╠═376998b0-7e9b-11eb-3b9b-23f8c8e0773c
# ╟─b5b4d834-0a41-11eb-1b18-1bd626d18934
# ╠═a83c96e2-0a5a-11eb-0e58-15b5dda7d2d2
# ╠═20c7b910-7e9c-11eb-3a73-730fb1c5783f
# ╠═3bf7ddf0-7e9c-11eb-0403-8d4455419126
# ╠═62c9f520-7e9d-11eb-2bdb-d317ce2293a5
# ╟─05fc5634-09a0-11eb-038e-53d63c3edaf2
# ╠═7f3823ee-7f7c-11eb-18a2-015a42915706
# ╠═b0e1c040-7f78-11eb-2d5d-390bd2347ec0
# ╠═372364e0-7f80-11eb-028b-91aa1639cf09
# ╠═24c2fb0c-0a42-11eb-1a1a-f1246f3420ff
# ╠═12a3a220-7f7f-11eb-2ca5-d31fd4c50956
# ╠═cba2c0e0-7f7e-11eb-08e3-498f4678662b
# ╟─c7649966-0a41-11eb-3a3a-57363cea7b06
# ╠═2635b574-0a42-11eb-1daa-971b2596ce44
# ╠═34eb0110-7f80-11eb-3b74-897c2a8598d7
# ╠═1486eba2-7f80-11eb-01b5-8518dfdcc840
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
