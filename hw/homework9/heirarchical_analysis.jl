### A Pluto.jl notebook ###
# v0.12.21

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
end

# ╔═╡ 12b41de4-7568-11eb-0869-adbc597546cf
md"### Heirarchical Analysis - Working file"

# ╔═╡ 9001dba4-9291-11eb-0871-3d8c95621eb3
md"Following lecture [Multigrid | Week 10 | MIT 18.S191 Fall 2020 | John Urschel](https://www.youtube.com/watch?v=rRCGNvMdLEY&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=43)"

# ╔═╡ 47246f1e-7568-11eb-2c3e-5d4ee2ad133f
md"Note: Necessary standard startup code for a scratch Pluto notebook: 

- Create a Pkg environment, and 
- `import`/`using` the needed packages, including e.g. `Plot`"

# ╔═╡ ceefc7f4-9273-11eb-3694-217c36fb9140
function grid_with_boundary(k)

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
	

# ╔═╡ 46ffbc92-9277-11eb-338a-99e879f2b94e
T = grid_with_boundary(5)

# ╔═╡ 7bdcb6f2-9277-11eb-025d-3fda31482a55
my_heatmap(T) = heatmap(T, yflip=true, ratio=1) # flip Y since pixels order y reverse from array

# ╔═╡ 875988c2-9277-11eb-39aa-9bf744c68e3c
my_heatmap(T)

# ╔═╡ 54bd78ec-928b-11eb-14c8-8b567033ff94
size(T, 1) - 1

# ╔═╡ deb4b572-9283-11eb-1a77-79c2e78a71e8
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
function add_heaters!(T::AbstractMatrix)
	n = size(T, 1) - 1
	
	# T′ = deepcopy(T)
	
	T[(3*n÷8+1):(n÷2+1), 1:(n÷8+1)] .= 40 # left
	T[(n÷2+1):(5*n÷8), (7*n÷8+1):(n+1)] .= 40 # right

	return T
end

# ╔═╡ d56e3614-9283-11eb-14b9-55cc98597f80
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
md"Note: stopping at 17:50 in lecture [Multigrid | Week 10 | MIT 18.S191 Fall 2020 | John Urschel](https://www.youtube.com/watch?v=rRCGNvMdLEY&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=43)"

# ╔═╡ 67becf58-9291-11eb-15d0-cfac4cbbc982


# ╔═╡ Cell order:
# ╟─12b41de4-7568-11eb-0869-adbc597546cf
# ╟─9001dba4-9291-11eb-0871-3d8c95621eb3
# ╟─47246f1e-7568-11eb-2c3e-5d4ee2ad133f
# ╠═5d63e746-7568-11eb-3d95-cd9c2e57056f
# ╠═66a2e85c-7568-11eb-2ad3-c108d59ebcc2
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
# ╠═67becf58-9291-11eb-15d0-cfac4cbbc982
