### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ bf557128-6dab-11eb-0062-a7e1136111a2
using CSV, DataFrames

# ╔═╡ dd55f950-6e77-11eb-1c0f-3393d1cb67a6
using Markdown

# ╔═╡ 1da7ebfc-6e79-11eb-35df-0d9033a84f36


# ╔═╡ 73dea9d0-6e78-11eb-16a5-231144312f32
begin
	import Pkg
	Pkg.add("CSV")
end

# ╔═╡ fe4ce02e-6e77-11eb-170c-0faa0edff59f
# create a random dataframe and write to CSV
CSV.write("random_file.csv", DataFrame(rand(100, 5)))

# ╔═╡ 9c4318d0-6e81-11eb-3c60-5b8d5368c7a3
Pkg.add("MarketData")

# ╔═╡ bf2949be-6e81-11eb-2dda-ab2615d6e2db
# `MarketData overview: https://juliaquant.github.io/MarketData.jl/stable/
import MarketData

# ╔═╡ cf6e35b4-6e81-11eb-0c1a-a78514db032b
AAPL = MarketData.yahoo(:AAPL) # MarketData fn

# ╔═╡ 8a35f4a4-6e82-11eb-20f3-87e42f59c650
start = DateTime(2018, 1, 1)

# ╔═╡ 1b033942-6e83-11eb-1e99-c3c9761c74e3
AAPL_df = DataFrames.DataFrame(AAPL)

# ╔═╡ bd43c4fe-6e82-11eb-232c-d72a7f29dda4
# describe(AAPL)
typeof(AAPL)

# ╔═╡ a900860a-6e79-11eb-1281-3de0e9d3a4de
typeof(AAPL_df)

# ╔═╡ fff4a29a-6e7e-11eb-1248-dfc45938a3c7
describe(AAPL_df)

# ╔═╡ e217a92a-6f44-11eb-0ac9-7908344e45f5
AMZN_df = DataFrames.DataFrame(MarketData.yahoo(:AMZN))

# ╔═╡ 180687c2-6f45-11eb-292c-31c574d579d1
describe(AMZN_df)

# ╔═╡ Cell order:
# ╠═1da7ebfc-6e79-11eb-35df-0d9033a84f36
# ╠═73dea9d0-6e78-11eb-16a5-231144312f32
# ╠═bf557128-6dab-11eb-0062-a7e1136111a2
# ╠═dd55f950-6e77-11eb-1c0f-3393d1cb67a6
# ╠═fe4ce02e-6e77-11eb-170c-0faa0edff59f
# ╠═9c4318d0-6e81-11eb-3c60-5b8d5368c7a3
# ╠═bf2949be-6e81-11eb-2dda-ab2615d6e2db
# ╠═cf6e35b4-6e81-11eb-0c1a-a78514db032b
# ╠═8a35f4a4-6e82-11eb-20f3-87e42f59c650
# ╠═1b033942-6e83-11eb-1e99-c3c9761c74e3
# ╠═bd43c4fe-6e82-11eb-232c-d72a7f29dda4
# ╠═a900860a-6e79-11eb-1281-3de0e9d3a4de
# ╠═fff4a29a-6e7e-11eb-1248-dfc45938a3c7
# ╠═e217a92a-6f44-11eb-0ac9-7908344e45f5
# ╠═180687c2-6f45-11eb-292c-31c574d579d1
