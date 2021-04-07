### A Pluto.jl notebook ###
# v0.14.0

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

# ╔═╡ 5d63e746-7568-11eb-3d95-cd9c2e57056f
# create a package environment
begin
	using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 66a2e85c-7568-11eb-2ad3-c108d59ebcc2
# add the needed packages
begin
	Pkg.add(["PlutoUI", "Plots"])

	using Plots
	gr()
	using PlutoUI
	using Test
end

# ╔═╡ 12b41de4-7568-11eb-0869-adbc597546cf
md"### Heirarchical Analysis - Working file"

# ╔═╡ 9001dba4-9291-11eb-0871-3d8c95621eb3
md"Following lecture [Multigrid | Week 10 | MIT 18.S191 Fall 2020 | John Urschel](https://www.youtube.com/watch?v=rRCGNvMdLEY&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=43)"

# ╔═╡ 47246f1e-7568-11eb-2c3e-5d4ee2ad133f
md"Note: Necessary standard startup code for a scratch Pluto notebook: 

- Create a Pkg environment, and 
- `import`/`using` the needed packages, including e.g. `Plot`"

# ╔═╡ b42dd15f-6e32-4d0a-90a3-e8f7c47bdb98
function grid_add_boundary!(T::AbstractMatrix)

	
	m,n = size(T) .- (1,1)
	
	# Boundary conditions (for room with window and 1 heater on each side
	# RHS indicates temp in deg C at each grid point
	
	# Bottom
	T[1, 1:(n÷2 + 1)] .= range(13, 5, length=n÷2 +1)
	T[1, (n÷2 + 2):(3*n÷4)] .= 5
	T[1, (3*n÷4+1):(n+1)] .= range(5, 13, length=n÷4+1)
	
	# Top
	T[m+1, 1:n+1] .= 21
	
	# Left Side
	T[1:(3*m÷8+1), 1] .= range(13, 40, length=(3*m÷8+1))
	T[(m÷2+1):(m+1), 1] .= range(40, 21, length=(m÷2+1))
	
	# right Side
	T[1:(m÷2+1), n+1] .= range(13, 40, length=(m÷2+1))
	T[(5*m÷8+1):(m+1), n+1] .= range(40, 21, length=(3*m÷8+1))
	
	# heaters
	T[(3*m÷8+1):(m÷2+1), 1:(n÷8+1)] .= 40 # left
	T[(m÷2+1):(5*m÷8), (7*n÷8+1):(n+1)] .= 40 # right

	return T
end

# ╔═╡ ceefc7f4-9273-11eb-3694-217c36fb9140
function grid_with_boundary_OLD(k)

	n = 2^k # number of grid blocks per side in square grid
	
	# Grid
	f = zeros(n+1, n+1)
	
	# Boundary conditions (for room with window and 1 heater on each side
	# RHS indicates temp in deg C at each grid point
	
	# Bottom
	f[1, 1:(n÷2 + 1)] .= range(13, 5, length=n÷2 +1)
	f[1, (n÷2 + 2):(3*n÷4)] .= 5
	f[1, (3*n÷4+1):(n+1)] .= range(5, 13, length=n÷4+1)
	
	# Top
	f[n+1, 1:n+1] .= 21
	
	# Left Side
	f[1:(3*n÷8+1), 1] .= range(13, 40, length=(3*n÷8+1))
	f[(n÷2+1):(n+1), 1] .= range(40, 21, length=(n÷2+1))
	
	# right Side
	f[1:(n÷2+1), n+1] .= range(13, 40, length=(n÷2+1))
	f[(5*n÷8+1):(n+1), n+1] .= range(40, 21, length=(3*n÷8+1))
	
	# heaters
	f[(3*n÷8+1):(n÷2+1), 1:(n÷8+1)] .= 40 # left
	f[(n÷2+1):(5*n÷8), (7*n÷8+1):(n+1)] .= 40 # right
	
	return f
end
	

# ╔═╡ 7bdcb6f2-9277-11eb-025d-3fda31482a55
my_heatmap(T) = heatmap(T, yflip=true, ratio=1) # flip Y since pixels order y reverse from array

# ╔═╡ deb4b572-9283-11eb-1a77-79c2e78a71e8
"""
	jacobi_step(T::AbstractMatrix)

"""
function jacobi_step(T::AbstractMatrix)
	
	n, m = size(T)
	
	T′ = deepcopy(T) # need to copy all the boundary (non-interior) points
	
	for i = 2:n-1 # loop over interior rows
		for j = 2:m-1 # an interior columns
			# Jacobi update method (approx of Laplacian(T) = 0
			T′[i,j] = (T[i+1, j] + T[i-1, j] + T[i, j+1] + T[i, j-1])/4
		end
	end
	return(T′)
end

# ╔═╡ 27e91d4e-928b-11eb-2c9f-7363a196d77a
"""
	add_heaters!(T::AbstractMatrix)

"""
function add_heaters!(T::AbstractMatrix)
	n = size(T, 1) - 1
	
	# T′ = deepcopy(T)
	
	T[(3*n÷8+1):(n÷2+1), 1:(n÷8+1)] .= 40 # left
	T[(n÷2+1):(5*n÷8), (7*n÷8+1):(n+1)] .= 40 # right

	return T
end

# ╔═╡ 3debc989-7b28-4709-accb-f66d74fe4421
function grid_with_boundary(k)

	n = 2^k # number of grid blocks per side in square grid
	
	# Grid
	f = zeros(n+1, n+1)
	
	grid_add_boundary!(f)
	
	add_heaters!(f)
	
	return f
end

# ╔═╡ 46ffbc92-9277-11eb-338a-99e879f2b94e
T = grid_with_boundary(5)

# ╔═╡ 875988c2-9277-11eb-39aa-9bf744c68e3c
my_heatmap(T)

# ╔═╡ 54bd78ec-928b-11eb-14c8-8b567033ff94
size(T, 1) - 1

# ╔═╡ d56e3614-9283-11eb-14b9-55cc98597f80
"""
	simulation(T::AbstractMatrix, ϵ=1e-3, num_steps=200)

"""
function simulation(T::AbstractMatrix, ϵ=1e-3, num_steps=200)
	
	results = [T] # array of AbstractMatrix's
	
	# num_steps is maximum iterations. Also stop if 
	for i in 1:num_steps
		T′ = jacobi_step(T)
		add_heaters!(T′) # for boundary condition on any boundary pts not on exterior
		
		push!(results, copy(T′)) # save this iteration result for future review
		
		if maximum(abs.(T - T′)) < ϵ
			return(results)
		end
		
		T = copy(T′) # need to update with copy, not pointer
		
	end
	return results
end

# ╔═╡ 95d09288-9290-11eb-1611-955ae4e6a74f


# ╔═╡ 0754f290-928d-11eb-2d0c-e18658fadc7a
@elapsed results = simulation(T, 1e-10, 5000)

# ╔═╡ cf80d29a-9290-11eb-301c-db0240f54466
md"Slider to explore the room heatmap for each iteration of solution of Laplace Equation $\nabla^2 T = 0$ s.t. boundary conditions."

# ╔═╡ 77e4ad18-928d-11eb-3edd-67351d43659f
@bind i Slider(1:length(results); show_value=true)

# ╔═╡ f01874b8-928d-11eb-25d5-bf909fe8aebe
my_heatmap(results[i])

# ╔═╡ 24088bf6-9290-11eb-0de3-611ab9337ef5
# look at the max and min diff between the last and penultimate iteration
extrema(results[end] - results[end-1])

# ╔═╡ 440387b6-9291-11eb-3da7-fd53a06f6b35
md"Note: this is at 17:50 in lecture [Multigrid | Week 10 | MIT 18.S191 Fall 2020 | John Urschel](https://www.youtube.com/watch?v=rRCGNvMdLEY&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=43)"

# ╔═╡ c615936a-93a5-11eb-1ab9-a9a71526f8a8
function interpolate_interior(T)
	m,n = size(T)
	
	T′ = copy(T)
	
	# iterate over interior and interpolate from edge values
	for i in 2:m-1
		for j in 2:n-1
			T′[i,j] = ( T[i,1]*(n-j) + T[i,n]*(j) +
						T[1,j]*(m-i) + T[m,j]*(i))/(m+n)
		end
	end
	
	return T′
end

# ╔═╡ 68dc7c50-93a9-11eb-3797-81f297dfee34
TT′ = let
	TT = grid_with_boundary(10)
	TT′ = interpolate_interior(TT)
	add_heaters!(TT′)
	my_heatmap(TT′)
	TT′
	# @elapsed results = simulation(TT′, 1e-10, 5000)
end

# ╔═╡ 10e037e4-9426-11eb-03ec-e55aa42a9014
@elapsed results2 = simulation(TT′, 1e-2, 500)

# ╔═╡ 67becf58-9291-11eb-15d0-cfac4cbbc982
my_heatmap(results2[i])

# ╔═╡ 73654b0b-500f-49e0-8393-962cf1acc014
md"""
This shows that starting the iterative solution with a fine grid may only move very slowly to the converged solution, for a local algorithm such as Jacobi's method for solving the Laplace equation.

After $(length(results2)) iterations of a $(size(TT′,1)) x $(size(TT′,2)) matrix, we are still a long way from solution.
"""

# ╔═╡ 30f8666f-d218-4641-89ae-e4ec8d348019
length(results2)

# ╔═╡ 8481e96b-c71b-40c1-ab6e-fd6c28883abe
md"### Heirarchical Approach

We can proceed from solutions of a coarse grid to a fine grid more efficiently than starting with a fine grid."

# ╔═╡ 0a132ca0-981d-4ffe-8178-21cd28121c85
coarsegrid = interpolate_interior(grid_with_boundary(4))

# ╔═╡ fa2b78db-104f-46cf-b9f1-5b4bdad34f50
add_heaters!(coarsegrid)

# ╔═╡ d825a8e3-70a1-46db-95f6-0601b8a042ac
my_heatmap(coarsegrid)

# ╔═╡ 01f0082d-b926-4eb6-90df-c53aa328b340
@elapsed coarse_results = simulation(coarsegrid, 1e-10, 1000)

# ╔═╡ 81e734bd-2d10-4f01-9413-78238f7eb023
length(coarse_results)

# ╔═╡ 39c8d010-6aff-4aff-9b36-f0586faf2dea
begin
	finegrid_size = (2^10)^2
	coarsegrid_size = (2^4)^2
	finegrid_size/coarsegrid_size
end

# ╔═╡ fc65fcb5-26a4-4428-8b52-a18d601e9036
md"Note: Each iteration of the finegrid problem ($(2^{10}) x (2^{10})) involves as many computations as $(( 2^{10} / 2^4 ) ^2) solutions of the coarsegrid problem ($(2^4) x $(2^4))."

# ╔═╡ 15ff4167-437d-4180-84ab-4d021a63f62a
md"So the full solution of the coarse grid problem may only involve as many calculations as one iteration of the fine grid."

# ╔═╡ 935b8bb1-3a0b-4de0-8abc-e0e328f5d278
md"""
A Heirarchical Algorithm:

1. Solve the problem on a coarse grid
2. Use the solution from the coarser grid as an approximation of the solution (startging point) for the next finer grid.
3. Solve the finer grid
4. Iterate back to step 2.
"""

# ╔═╡ c1a3ef1a-fe17-46cd-923b-bd9aeb83d0f3
"""
	grid_scaleup(gridin::AbstractMatrix, scalefactor::Int64)

given a coarse `gridin` grid with values (as a matrix),
return a scaled up (finer) version with double the size along each dimension,
and all values approximated by the coarser grid.
"""
function grid_scaleup(gridin::AbstractMatrix, scalefactor::Int64)
	
	# Fragile: works for scalefactor =2, not for arb scale
	#.  (refs invalid loc in gridin)

	# expect gridin is square? No such requirement

	# Note funky subtract one and add 1 to dimension, legacy of dim = 2^n +1
	if scalefactor > 1
		(out_r, out_c) = floor.(Int, (size(gridin) .- 1) .* scalefactor) .+ 1

		gridout = zeros(out_r, out_r)
		
		for r in 2:out_r-1 # do only internal points (start w/2, since ÷ 2)
			for c in 2:out_c-1
				# assign values to match gridin with "pixel" size scalefactor^2
				gridout[r,c] = gridin[r ÷ scalefactor, c ÷ scalefactor]
				
				gridout[r,c] = (
				gridin[Int(floor((r+1)/scalefactor)),Int(floor((c+1)/scalefactor))] +
				gridin[Int(ceil((r+1)/scalefactor)), Int(floor((c+1)/scalefactor))] +
				gridin[Int(floor((r+1)/scalefactor)),Int(ceil((c+1)/scalefactor))] +
				gridin[Int(ceil((r+1)/scalefactor)), Int(ceil((c+1)/scalefactor))]
					)/4
			end				
		end

		grid_add_boundary!(gridout) # make sure boundary conditions met
	end
	
	return gridout
end

# ╔═╡ 495ea9a2-9354-11eb-014a-17f210528305
test = reshape(1:33*33, (33,33))

# ╔═╡ 60d7d505-02e8-4125-a11a-4f3926ca7917
floor.(Int, (size(test) .- 1) .* 2) .+ 1

# ╔═╡ a91a72e2-9357-11eb-3ba7-9f6ebc1eb5c1
my_heatmap(grid_scaleup(coarsegrid, 2))

# ╔═╡ f4559a08-0e50-4f99-97eb-94aa362704d2
my_heatmap(grid_scaleup(grid_scaleup(coarsegrid, 2), 2))

# ╔═╡ 1125cba1-b6c9-4ae0-938b-0874db912a06
md"Note: stopping at 17:50 in lecture [Multigrid | Week 10 | MIT 18.S191 Fall 2020 | John Urschel](https://www.youtube.com/watch?v=rRCGNvMdLEY&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=43)"

# ╔═╡ Cell order:
# ╟─12b41de4-7568-11eb-0869-adbc597546cf
# ╟─9001dba4-9291-11eb-0871-3d8c95621eb3
# ╟─47246f1e-7568-11eb-2c3e-5d4ee2ad133f
# ╠═5d63e746-7568-11eb-3d95-cd9c2e57056f
# ╠═66a2e85c-7568-11eb-2ad3-c108d59ebcc2
# ╠═b42dd15f-6e32-4d0a-90a3-e8f7c47bdb98
# ╠═3debc989-7b28-4709-accb-f66d74fe4421
# ╠═ceefc7f4-9273-11eb-3694-217c36fb9140
# ╠═46ffbc92-9277-11eb-338a-99e879f2b94e
# ╠═7bdcb6f2-9277-11eb-025d-3fda31482a55
# ╠═875988c2-9277-11eb-39aa-9bf744c68e3c
# ╠═54bd78ec-928b-11eb-14c8-8b567033ff94
# ╠═d56e3614-9283-11eb-14b9-55cc98597f80
# ╠═deb4b572-9283-11eb-1a77-79c2e78a71e8
# ╠═27e91d4e-928b-11eb-2c9f-7363a196d77a
# ╠═95d09288-9290-11eb-1611-955ae4e6a74f
# ╠═0754f290-928d-11eb-2d0c-e18658fadc7a
# ╟─cf80d29a-9290-11eb-301c-db0240f54466
# ╠═77e4ad18-928d-11eb-3edd-67351d43659f
# ╠═f01874b8-928d-11eb-25d5-bf909fe8aebe
# ╠═24088bf6-9290-11eb-0de3-611ab9337ef5
# ╟─440387b6-9291-11eb-3da7-fd53a06f6b35
# ╠═c615936a-93a5-11eb-1ab9-a9a71526f8a8
# ╠═68dc7c50-93a9-11eb-3797-81f297dfee34
# ╠═10e037e4-9426-11eb-03ec-e55aa42a9014
# ╠═67becf58-9291-11eb-15d0-cfac4cbbc982
# ╠═73654b0b-500f-49e0-8393-962cf1acc014
# ╠═30f8666f-d218-4641-89ae-e4ec8d348019
# ╟─8481e96b-c71b-40c1-ab6e-fd6c28883abe
# ╠═0a132ca0-981d-4ffe-8178-21cd28121c85
# ╠═fa2b78db-104f-46cf-b9f1-5b4bdad34f50
# ╠═d825a8e3-70a1-46db-95f6-0601b8a042ac
# ╠═01f0082d-b926-4eb6-90df-c53aa328b340
# ╠═81e734bd-2d10-4f01-9413-78238f7eb023
# ╠═39c8d010-6aff-4aff-9b36-f0586faf2dea
# ╠═fc65fcb5-26a4-4428-8b52-a18d601e9036
# ╟─15ff4167-437d-4180-84ab-4d021a63f62a
# ╟─935b8bb1-3a0b-4de0-8abc-e0e328f5d278
# ╠═c1a3ef1a-fe17-46cd-923b-bd9aeb83d0f3
# ╠═495ea9a2-9354-11eb-014a-17f210528305
# ╠═60d7d505-02e8-4125-a11a-4f3926ca7917
# ╠═a91a72e2-9357-11eb-3ba7-9f6ebc1eb5c1
# ╠═f4559a08-0e50-4f99-97eb-94aa362704d2
# ╠═1125cba1-b6c9-4ae0-938b-0874db912a06
