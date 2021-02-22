### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

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
md"_Pluto notebook template_"

# ╔═╡ 47246f1e-7568-11eb-2c3e-5d4ee2ad133f
md"Note: Necessary standard startup code for a scratch Pluto notebook: 

- Create a Pkg environment, and 
- `import`/`using` the needed packages, including e.g. `Plot`"

# ╔═╡ Cell order:
# ╟─12b41de4-7568-11eb-0869-adbc597546cf
# ╟─47246f1e-7568-11eb-2c3e-5d4ee2ad133f
# ╠═5d63e746-7568-11eb-3d95-cd9c2e57056f
# ╠═66a2e85c-7568-11eb-2ad3-c108d59ebcc2
