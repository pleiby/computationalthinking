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

# ╔═╡ 16acd2d8-7575-11eb-04d3-4930917344fb
let
	using Plots
	x = 1:10; y = rand(10); # These are the plotting data
	plot(x, y)
end

# ╔═╡ 58173e26-75d3-11eb-3037-fda5de319342
using StatsPlots

# ╔═╡ a063dcde-7574-11eb-2b1a-3daa62787f44
md"## Julia Graphics Tutorial"

# ╔═╡ ca2b2240-7574-11eb-3412-931387ef43bd
md"Following [JuliaPlots.org Tutorial](https://docs.juliaplots.org/latest/tutorial/)"

# ╔═╡ 12b41de4-7568-11eb-0869-adbc597546cf
md"_Pluto notebook template_"

# ╔═╡ 47246f1e-7568-11eb-2c3e-5d4ee2ad133f
md"Note: Necessary standard startup code for a scratch Pluto notebook: 

- Create a Pkg environment, and 
- `import`/`using` the needed packages, including e.g. `Plot`"

# ╔═╡ f0baf3f2-7574-11eb-3ba0-2be495dc491d
md"""### Basic Plotting: Line Plots

The most basic plots are line plots. Assuming you have installed Plots.jl via Pkg.add("Plots"), you can plot a line by calling plot on two vectors of numbers. For example:"""


# ╔═╡ 46fcb0fa-7575-11eb-0822-efa87bcdc3d3
md"In Plots.jl, every column is a series"

# ╔═╡ 5c5aecfc-7575-11eb-3f58-1bd73b3792d2
md"Calling `plot` on an array (matrix) will plot separate lines for each column"

# ╔═╡ 7c8789cc-7575-11eb-2405-f39ce140b813
typeof(rand(10, 2))

# ╔═╡ 7116944a-7575-11eb-098b-f567c927df60
begin
	n = 3
	x = 1:10; y = rand(10, n) # n columns means n lines
	plot(x, y)
end

# ╔═╡ c1ab2644-7575-11eb-14a3-292e20afccb3
md"We can add more lines (or attributes/features?) by mutating the plot object with `plot!`."

# ╔═╡ 40e62cec-7576-11eb-1ddf-cdaa6436f12d
begin
	z = 0.5 .* rand(10)
	plot!(x, z, title="Wiggly lines", lw = 2)
	# plot!(subtitle = "subhello")
	# plot!(lw = 2)
end

# ╔═╡ 1b040aca-7577-11eb-0b88-2b4088399988
md"### Plot Attributes

In `Plots.jl`, the modifiers to plots are called attributes. These are documented at the [attributes page](https://docs.juliaplots.org/latest/attributes/#attributes). `Plots.jl` follows a simple rule with data vs attributes: 

- positional arguments are input data, and 
- keyword arguments are attributes."

# ╔═╡ 4e922ec8-7577-11eb-1577-7f21939cd64b
md"We can in the plot command specify it via xlabel=... like we did above. Or we can use the modifier function to add it after the plot has already been generated:"

# ╔═╡ 492b261c-7587-11eb-0ac3-57772156675c
md"#### Attributes as keyword args in function call to `plot`"

# ╔═╡ b92f88a4-7582-11eb-389a-f5a3703fe17b
md"`title`, `label` and `linewidth` (`lw`) attributes can be set in call to `plot`"

# ╔═╡ 6549a298-7581-11eb-29f1-fb2c88d4b487
let
	x = 1:10; y = rand(10, 2) # 2 columns means two lines
	plot(x, y, title = "Two Lines", label = ["Line 1" "Line 2"], lw = 3)
end

# ╔═╡ 6486120a-7587-11eb-3ceb-37230a2d7ebd
md"#### Attributes can be set with modifier functions"

# ╔═╡ 443192fe-7587-11eb-0e89-fb240c5f76a6
md"Every modifier function is the name of the attribute followed by `!`.

Note that this implicitly uses the global `Plots.CURRENT_PLOT` and we can apply it to other plot objects via `attribute!(p,value)`." 

# ╔═╡ 052b86d0-7589-11eb-2161-e5a9ac7ab68e
# for example, add axis labels
begin
	xlabel!("Obs number")
	ylabel!("Random value")
end

# ╔═╡ 1e6c2bc8-7588-11eb-23f6-7760a1f6d4fb
md"#### Lists of plot attributes available"

# ╔═╡ b853a938-7587-11eb-0993-056aac2faa51
md"`using Plots` in the REPL, one can use the function `plotattr()` to print a list of all attributes for either `series`, `plots`, `subplots`, or `axes`.


		plotattr(:Plot)
		plotattr(:Series)
		plotattr(:Subplot)
		plotattr(:Axis)
"

# ╔═╡ d1a0e284-7587-11eb-2d47-89962658d992
plotattr(:Plot) # shows nothing in the Pluto notebook, see REPL output

# ╔═╡ 719be158-7588-11eb-13a5-0d4ce50bc638
md"""Attributes are also listed in the following documentation pages (tables), giving attribute, alias, default, type and description:

- [`Plot` attributes](https://docs.juliaplots.org/latest/generated/https://docs.juliaplots.org/latest/generated/attributes_plot/)
- [`Series` attributes](https://docs.juliaplots.org/latest/generated/attributes_series/)
- [`Subplot` attributes](https://docs.juliaplots.org/latest/generated/attributes_subplot/)
- [`Axis` attributes](https://docs.juliaplots.org/latest/generated/attributes_axis/)
- [`Graph` attributes](https://docs.juliaplots.org/latest/generated/graph_attributes/)"""


# ╔═╡ 04ca0d7c-75d1-11eb-1c34-0dba3b9123ea
md"""#### Saving plots

is done by the `savefig` command. E.g:

	savefig("myplot.png") # Saves the CURRENT_PLOT as a .png
	savefig(p, "myplot.pdf") # Saves the plot from p as a .pdf vector graphic"""

# ╔═╡ 1d4274a4-75d4-11eb-288d-91177b055b03
md"### Changing the Plotting Series Type"

# ╔═╡ 6e507022-75d8-11eb-1f8a-b3688effcedc
md"For each built-in series type, there is a shorthand function for directly calling that series type which matches the name of the series type. It handles attributes just the same as the plot command, and have a mutating form which ends in `!`"

# ╔═╡ 571e9572-75d4-11eb-1491-4348d006fa50
md"Scatter plot type"

# ╔═╡ 45d2eac0-75d4-11eb-3de5-558484963c73
plot(x, y, seriestype = :scatter, title = "My Scatter Plot")

# ╔═╡ b0e04840-75d3-11eb-34a0-75a37d7cd6e8
md"#### StatsPlots.jl Series Recipes"

# ╔═╡ 692f2f16-75d3-11eb-21a7-9b926daecdec
let 
	y = rand(100, 4) # Four series of 100 points each
	violin(["Series 1" "Series 2" "Series 3" "Series 4"], y, leg = false)
end

# ╔═╡ Cell order:
# ╠═a063dcde-7574-11eb-2b1a-3daa62787f44
# ╟─ca2b2240-7574-11eb-3412-931387ef43bd
# ╠═12b41de4-7568-11eb-0869-adbc597546cf
# ╟─47246f1e-7568-11eb-2c3e-5d4ee2ad133f
# ╠═5d63e746-7568-11eb-3d95-cd9c2e57056f
# ╠═66a2e85c-7568-11eb-2ad3-c108d59ebcc2
# ╠═f0baf3f2-7574-11eb-3ba0-2be495dc491d
# ╠═16acd2d8-7575-11eb-04d3-4930917344fb
# ╠═46fcb0fa-7575-11eb-0822-efa87bcdc3d3
# ╠═5c5aecfc-7575-11eb-3f58-1bd73b3792d2
# ╠═7c8789cc-7575-11eb-2405-f39ce140b813
# ╠═7116944a-7575-11eb-098b-f567c927df60
# ╟─c1ab2644-7575-11eb-14a3-292e20afccb3
# ╠═40e62cec-7576-11eb-1ddf-cdaa6436f12d
# ╟─1b040aca-7577-11eb-0b88-2b4088399988
# ╠═4e922ec8-7577-11eb-1577-7f21939cd64b
# ╠═492b261c-7587-11eb-0ac3-57772156675c
# ╠═b92f88a4-7582-11eb-389a-f5a3703fe17b
# ╠═6549a298-7581-11eb-29f1-fb2c88d4b487
# ╠═6486120a-7587-11eb-3ceb-37230a2d7ebd
# ╠═443192fe-7587-11eb-0e89-fb240c5f76a6
# ╠═052b86d0-7589-11eb-2161-e5a9ac7ab68e
# ╟─1e6c2bc8-7588-11eb-23f6-7760a1f6d4fb
# ╟─b853a938-7587-11eb-0993-056aac2faa51
# ╠═d1a0e284-7587-11eb-2d47-89962658d992
# ╟─719be158-7588-11eb-13a5-0d4ce50bc638
# ╟─04ca0d7c-75d1-11eb-1c34-0dba3b9123ea
# ╠═1d4274a4-75d4-11eb-288d-91177b055b03
# ╠═6e507022-75d8-11eb-1f8a-b3688effcedc
# ╠═571e9572-75d4-11eb-1491-4348d006fa50
# ╠═45d2eac0-75d4-11eb-3de5-558484963c73
# ╠═b0e04840-75d3-11eb-34a0-75a37d7cd6e8
# ╠═58173e26-75d3-11eb-3037-fda5de319342
# ╠═692f2f16-75d3-11eb-21a7-9b926daecdec
