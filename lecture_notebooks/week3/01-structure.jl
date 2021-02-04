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

# ╔═╡ ae24c8b2-f60b-11ea-2c7a-03857d1217b2
using Pkg

# ╔═╡ bc14fc1a-f60b-11ea-207a-91b967f28076
begin
	pkg"add Colors ColorSchemes Images ImageMagick PlutoUI Suppressor InteractiveUtils"
	using Colors, ColorSchemes, Images, ImageMagick
	using Suppressor, InteractiveUtils, PlutoUI
end

# ╔═╡ 0feb5674-f5d5-11ea-0714-7379a7d381a3
using LinearAlgebra

# ╔═╡ 20125236-f5d6-11ea-3877-6b332497be62
using SparseArrays

# ╔═╡ 0f6ecba6-f5da-11ea-22c2-2929e562f413
using Statistics

# ╔═╡ b0ba5b8c-f5d1-11ea-1304-3f0e47f935fe
md"# What do data structures, machine learning and the singular-value decomposition have in common?"

# ╔═╡ ffa95430-f5d1-11ea-3cb7-5bb8d8f13701
md"""Blurry Fons magic: Exploiting Structure!

ADD A HINT BOX HERE WITH THE ANSWER "STRUCTURE" """

# ╔═╡ 261c4df2-f5d2-11ea-2c72-7d4b09c46098
md"One-hot vectors:  Numbers and images

0s and 1s and colors"

# ╔═╡ b5177f70-f60b-11ea-14a9-f5a574cc5185
Pkg.activate(mktempdir())

# ╔═╡ 173587fc-65cd-11eb-0142-19d01d740764
v0 = ones(Int, 10)

# ╔═╡ 69be79ca-65cd-11eb-2e2e-a593a853c073
v0[4]=3

# ╔═╡ 74d66748-65cd-11eb-0a6b-c5c6cd3f4d55
v0

# ╔═╡ 20deb2ae-65cf-11eb-1c95-0b32b76762b8
v0[6:7] .= 2

# ╔═╡ 5d287d76-65cf-11eb-14ee-c1fd1da1ad1e
w = @view v0[3:5]

# ╔═╡ 01c5435a-65d0-11eb-2324-5fba7a350c29
typeof(w)

# ╔═╡ 96835a14-65cf-11eb-11a0-8f8eae632308
w[1] = 7

# ╔═╡ 9ee5c03e-65cf-11eb-2eeb-cd070a5cb183
v0

# ╔═╡ 4e00f836-65d0-11eb-1b4e-17fb3f317cb7
M0 = [5i + 2j for i in 1:4, j in 1:3]

# ╔═╡ 8963ea8c-65d0-11eb-1983-9bcb2970d6e4
M1 = reshape(M0, 2,6)	# turns out this is a view o M0!

# ╔═╡ a475f8c4-65d0-11eb-26af-575217377b47
M1[2, 3:4] .= -5

# ╔═╡ b968962e-65d0-11eb-372c-c9925c2ceeb9
M1

# ╔═╡ be07c93e-65d0-11eb-1f75-e70a55647d7a
M0

# ╔═╡ de0062d2-65d0-11eb-16a2-0b9d2293625d
vv0 = vec(M0) # not column major ordering

# ╔═╡ 032d9d22-65d1-11eb-1f38-9b887f27bfd6
vv0[6] = -10

# ╔═╡ 12df4d06-65d1-11eb-2925-e34340ca83dd
M0 # vec is also a view!

# ╔═╡ da8c55d4-65d5-11eb-19a5-ab8d0a441d88
md"### Defining New Types | Week 3 | 18.S191 MIT Fall 2020"

# ╔═╡ 0b86bbd2-65d3-11eb-1814-7f5998184a28
struct Rectangle
	height::Float64
	width::Float64
end

# ╔═╡ 5f87f9a8-65d3-11eb-0356-2be63dd430da
r = Rectangle(3, 4)

# ╔═╡ aa878ea0-65d3-11eb-209e-bdce0640d960
r.height

# ╔═╡ f2728092-65d5-11eb-0d17-235e9bc5dcab
md"### Functions and Types - Multiple Dipatch | Week 3 | 18.S191 MIT Fall 2020"

# ╔═╡ 06341b04-65d6-11eb-086b-cd2871ead5a5


# ╔═╡ c65ec13e-65d3-11eb-1abb-a7a078ce4590
width(rect::Rectangle) = rect.width

# ╔═╡ d72d5fe8-65d3-11eb-09f5-954b1df751e4
width(r)

# ╔═╡ f0ba416a-65d3-11eb-21a1-7539e41d7789
area(rect::Rectangle) = rect.width * rect.height

# ╔═╡ f041537c-65d3-11eb-0f1e-f12b66d8f739
+

# ╔═╡ bfdc328c-65d4-11eb-1341-9fd0b516e810
cc = 3 + 4im

# ╔═╡ efcb02e2-65d3-11eb-04f8-b3652fdf61f6
@which cc + cc

# ╔═╡ ca89bb84-65d5-11eb-3f41-471abd811a48
md"### Introduction to macros | Week 3 | 18.S191 MIT Fall 2020"

# ╔═╡ 265605ce-65d5-11eb-0565-4545092fcd28
peakflops()

# ╔═╡ 261b7c4c-65d5-11eb-37eb-b133fe08709e
@elapsed peakflops()

# ╔═╡ 25f094c8-65d5-11eb-302d-d7915457963f
@macroexpand @elapsed peakflops()

# ╔═╡ 931d370e-65d5-11eb-0125-39e6c0b17eff
Base.remove_linenums!(@macroexpand @elapsed peakflops())

# ╔═╡ 42d52ee0-65d6-11eb-2ecc-a1b8d1b54c93
md"##### Expressions | Week 3 | 18.S191 MIT Fall 2020"

# ╔═╡ 321f9284-65d6-11eb-3862-fd064484a3bc
# write expressions by "quoting" the code
expr0 = :(1 + 2)

# ╔═╡ 78a9474a-65d6-11eb-1680-ffcfd2d11c09
expr1 = quote
	1 + 2
end

# ╔═╡ c1648f4c-65d6-11eb-0808-7fcd36b0a15e
dump(expr1)

# ╔═╡ 0d454f44-65db-11eb-1cf3-7f75cbc37b83
md"#### Structure | Week3 | 18.S191 MIT Fall 2020"

# ╔═╡ 41128fc0-65dc-11eb-2402-bdd073b147b6
cs0 = distinguishable_colors(100)

# ╔═╡ 5eb8cfdc-65dd-11eb-3529-8102930afe06


# ╔═╡ 4b68e428-65dd-11eb-10b0-5f6909a916a8


# ╔═╡ 25a70ee8-65d5-11eb-36e2-cdd3773ef92c
md"### Introduction to macros | Week 3 | 18.S191 MIT Fall 2020"

# ╔═╡ ef8f44b2-f5fc-11ea-1e4d-bd873cd39d6c
@bind nn Slider(1:20, show_value=true)

# ╔═╡ fd9211c0-f5fc-11ea-1745-7f2dae88af9e
@bind kk Slider(1:nn, default=nn, show_value=true)

# ╔═╡ 3a1ed5b8-f5fd-11ea-2ecd-b9d08349651f
colors = [colorant"black", colorant"red"]

# ╔═╡ 77ae1146-f5d2-11ea-1226-27d15c90a8df
begin
	v = fill(1, nn)
	v[kk] = 2
	
	colors[v]'
end

# ╔═╡ 676f6e3a-f5fd-11ea-3552-e7e7c6382276
v

# ╔═╡ 3592648a-f5fd-11ea-2ed0-a1d4a4c14d07


# ╔═╡ 7ffa02f6-f5d2-11ea-1b41-15c21f92e9ee
Int.((1:10) .== 3)

# ╔═╡ 21a15906-f5d3-11ea-3a71-f53eabc31acc
md"Colors and sliders"

# ╔═╡ 3c5f0ba8-f5d3-11ea-22d3-4f7c513144bc
md"Data structure for a one-hot vector"

# ╔═╡ 4d2db24e-f5d4-11ea-10d4-b126f643abee


# ╔═╡ 4624cd26-f5d3-11ea-1cf8-7d6555eae5fa
struct OneHot <: AbstractVector{Int}
	n::Int
	k::Int
end

# ╔═╡ 397ac764-f5fe-11ea-20cc-8d7cab19d410
Base.size(x::OneHot) = (x.n, )

# ╔═╡ 82c7046c-f5d3-11ea-04e2-ef7c0f4db5da
Base.getindex(x::OneHot, i::Int) = Int(x.k == i)

# ╔═╡ 7a98f708-f5d3-11ea-2301-cde71ca469ff
x = OneHot(5, 3)

# ╔═╡ 60214c1a-f5fe-11ea-2d08-c59715bcedd0
x[1:2]

# ╔═╡ cf77d83c-f5fd-11ea-136e-8951de64e05e
show_vector(x::OneHot) = colors[x .+ 1]'

# ╔═╡ 5813e1b2-f5ff-11ea-2849-a1def74fc065
begin
	imshow(M) = get.(Ref(ColorSchemes.rainbow), M ./ maximum(M))
	imshow(x::AbstractVector) = imshow(x')
end

# ╔═╡ e51d4ef6-f5fd-11ea-28f1-a1616e17f715
imshow(rand(5, 5))

# ╔═╡ 982590d4-f5ff-11ea-3802-73292c75ad6c
imshow(x)

# ╔═╡ c3f70e18-f5ff-11ea-35aa-31b22ca506b8
get.([ColorSchemes.rainbow], x)'

# ╔═╡ c200deb0-f5fd-11ea-32e1-d96596b16ebc
x[3]

# ╔═╡ a5989a76-f5d3-11ea-3fe5-5f9959199fe8
typeof(x)

# ╔═╡ b0bd6c6a-f5d3-11ea-00ee-b7c155f23481
x[3:5]

# ╔═╡ bd94f82c-f5d3-11ea-2a1e-77ddaadbfeb9
collect(x)

# ╔═╡ 8d2c6910-f5d4-11ea-1928-1baf09815687
md"""How much "information" (numbers) do you need to represent a one-hot vector? Is it $n$ or is it two?
"""

# ╔═╡ 81c35324-f5d4-11ea-2338-9f982d38732c
md"# Diagonal matrices"

# ╔═╡ 2cfda0dc-f5d5-11ea-16c4-b5a33b90e37f
md"As you might see in high school:"

# ╔═╡ 150432d4-f5d5-11ea-32b2-19a2a91d9637
M = [5 0 0 
	 0 6 0
	 0 0 -10]	

# ╔═╡ 21328d1c-f5d5-11ea-288e-4171ad35326d
Diagonal(M)

# ╔═╡ d8f36278-f5d5-11ea-3338-8573ce40e65e
md"How much information do you need for a diagonal matrix?"

# ╔═╡ e90c55fc-f5d5-11ea-10f1-470ff772985d
md"""We should always look for *structure* where it exists"""

# ╔═╡ 19775c3c-f5d6-11ea-15c2-89618e654a1e
md"## Sparse matrices"

# ╔═╡ 232d1dcc-f5d6-11ea-2710-658c75b9c7a4
sparse(M)

# ╔═╡ 2b2feb9c-f5d6-11ea-191c-df20360b12a9
M2 = spzeros(10^6, 10^6)

# ╔═╡ 50c74f6c-f5d6-11ea-29f1-5de9997d5d9f
M2[1, 2] = 1

# ╔═╡ 5de72b7c-f5d6-11ea-1b6f-35b830b5fb34
M3 = sparse([1, 2, 10^6], [4, 10, 10^6], [7, 8, 9])

# ╔═╡ 2fd7e52e-f5d7-11ea-3b5a-1f338e2451e0
M4 = [1 0 2 0 10; 0 3 4 0 9; 0 0 0 5 8; 0 0 0 0 7] .* 0

# ╔═╡ aa09c008-f5d8-11ea-1bdc-b51ee6eb2478
sparse(M4)

# ╔═╡ d941cd66-f5d8-11ea-26ff-47ba7779ab20
md"Sparse matrix dictionaries? Before CSC"

# ╔═╡ 62a6ec62-f5d9-11ea-071e-ed33c5dea0cd
md"## Rand: Where is the structure?"

# ╔═╡ 67274c3c-f5d9-11ea-3475-c9d228e3bd5a
# join(rand("ACGT", 100))

vv = rand(1:9, 1000000)

# ╔═╡ b6c7a918-f600-11ea-18ff-6521507358c6
md"Mention lossless compression e.g. run-length encoding"

# ╔═╡ 765c6552-f5d9-11ea-29d3-bfe7b4b04612
md"""Some might guess that there is "no structure"

Take mean and standard deviation -- some would say that's the structure 

"""

# ╔═╡ 126fb3ea-f5da-11ea-2f7d-0b3259a296ce
mean(vv), std(vv), 5, sqrt(10 * 2/3)

# ╔═╡ 5f79e8f4-f5da-11ea-2b55-ef344b8a3ba2
var(vv)

# ╔═╡ 9b9e2c2a-f5da-11ea-369b-b513b196515b
md"Statisticians (and professors who've just graded exams) might say that under certain circumstances the mean and the variance give you the necessary structure, and the rest can be thrown away"

# ╔═╡ e68b98ea-f5da-11ea-1a9d-db45e4f80241
m = sum(vv) / length(vv)  # mean

# ╔═╡ f20ccac4-f5da-11ea-0e69-413b5e49f423
σ² = sum( (vv .- m) .^ 2 ) / (length(vv) - 1)

# ╔═╡ 0bc792e8-f5db-11ea-0b7a-1502ddc8008e
var(vv)

# ╔═╡ 12a2e96c-f5db-11ea-1c3e-494ae7446886
σ = sqrt(σ²)

# ╔═╡ 22487ce2-f5db-11ea-32e9-6f70ab2c0353
std(vv)

# ╔═╡ 389ae62e-f5db-11ea-1557-c3adbbee0e5c
md"Sometimes the summary statistics are all you want. (But sometimes not)"

# ╔═╡ 0c2b6408-f5d9-11ea-2b7f-7fece2eecc1f
md"## Multiplication tables"

# ╔═╡ 542a9556-f5db-11ea-0375-99f52416f6e4
md"How do you make a multiplication table?"

# ╔═╡ 165788b2-f601-11ea-3e69-cdbbb6558e54
md"Do you recognise this?"

# ╔═╡ 22941bb8-f601-11ea-1d6e-0d955297bc2e
rand(3) .* rand(4)'

# ╔═╡ 2f75df7e-f601-11ea-2fc2-aff4f335af33
imshow(rand(3) .* rand(4)')

# ╔═╡ 53e6b612-f601-11ea-05a9-5395e69b3c41
svd(rand(3) .* rand(4)')

# ╔═╡ 3e919766-f601-11ea-0485-05f45484bf8d
md"It's not easy to see the structure!"

# ╔═╡ 1052993e-f601-11ea-2c55-0d67e31b670e
M5 = 
[1  2  3   4
 2  4  6   8
 3  6  9  12
]

# ╔═╡ 68190822-f5db-11ea-117f-d10a161208c3
md"Comprehension:"

# ╔═╡ 71b44874-f5db-11ea-1f67-47bad9295e03
md"Slider"

# ╔═╡ 6c51eddc-f5db-11ea-1235-332cdbb072fa
[i * j for i in 1:3, j in 1:4]

# ╔═╡ 86fb49ee-f5db-11ea-3bfa-c95c3b8775a3
md"Explain '"

# ╔═╡ 173cfab4-f5d9-11ea-0c7c-bf8b0888f6e7
(1:3) .* (1:4)'

# ╔═╡ 8bab3e36-f5db-11ea-187a-f31fa8cf357d
reshape([1, 2, 3], 3, 1)

# ╔═╡ e64291e8-f5db-11ea-0cab-8567b781408f
[1
 2
 3]

# ╔═╡ 0111a124-f5dc-11ea-0904-fdd88d7acac4
MM = rand(3, 3)

# ╔═╡ 06406158-f5dc-11ea-02b1-2519a0176993
MM[:, 1]

# ╔═╡ 12051f06-f5dc-11ea-2f6c-0fdc50eeff01
vvv = [1, 2, 3]

# ╔═╡ 195854e6-f5dc-11ea-114b-2333f87173f7
a = reshape([1, 2, 3], 3, 1)

# ╔═╡ 768116f6-f5dc-11ea-1cfe-b3016c574725
b = reshape([4, 5, 6], 3, 1)

# ╔═╡ 9050426e-f5dc-11ea-373c-65456732bd34
a * b'

# ╔═╡ 965bd07e-f5dc-11ea-2e85-d34996cf2fae
v4 = [1, 2, 3]

# ╔═╡ a9daf4cc-f5dc-11ea-270b-2566f89f168c
v4 * v4'

# ╔═╡ dc0c8b72-f5dc-11ea-3e6f-0f43cbf58f56
v4 .* v4'

# ╔═╡ 0ed78e76-f5dd-11ea-2ad8-a35a69c0ef9a
v4

# ╔═╡ 1648a0fa-f5dd-11ea-0292-495207e83de9
[v4 v4]

# ╔═╡ 1e9cefea-f5dd-11ea-3e5f-a189fd41c42e
[1*v4 5*v4 6*v4]

# ╔═╡ 24664f20-f5dd-11ea-2a69-cd3e0ebd5c39
v4 * [1, 5, 6]'

# ╔═╡ 43a4920c-f5dd-11ea-1ab1-0b3d673c0f1e
v4 .* [1, 5, 6]'

# ╔═╡ 5d767290-f5dd-11ea-2189-81198fd216ce
outer(v, w) = [x * y for x in v, y in w]  # just a multiplication table

# ╔═╡ b51607a0-65da-11eb-3e51-4f61010cf19c
A = sum(outer(rand(3), rand(3)) for i=1:2)

# ╔═╡ f6e8c26a-65da-11eb-3c68-cf11f5fca718
U, Σ, V = svd(A)

# ╔═╡ 4d5ab1d2-65db-11eb-22f7-854756cc49a1
# approximate original matric with outer product of cols of SVD mats
outer(U[:,1], V[:,1]) * Σ[1]

# ╔═╡ 8257aa70-65db-11eb-32d8-cd68bb4988d9
# Increasingly good approx
outer(U[:,1], V[:,1]) * Σ[1] + outer(U[:,2], V[:,2]) * Σ[2]

# ╔═╡ 9e82860c-65db-11eb-0940-8d1d8f38337a
(outer(U[:,1], V[:,1]) * Σ[1] + outer(U[:,2], V[:,2]) * Σ[2]) ./ A

# ╔═╡ 18445dda-65dc-11eb-0b00-f93944578fb5
flag0 = outer([1, 1, 1, 2, 2, 2, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1])

# ╔═╡ 5a493052-f601-11ea-2f5f-f940412905f2
begin
	v6 = rand(3)
	w6 = rand(4)
	
	U6, Σ6, V6 = svd( outer(v6, w6) )
end

# ╔═╡ 8633afb2-f601-11ea-206b-e9c4b9621c2a
outer(U6[:,1], V6[:, 1]) .* Σ6[1]

# ╔═╡ 9918c4fa-f601-11ea-3bf1-3506dcb437f7
outer(v6, w6)

# ╔═╡ 6aae805e-f5dd-11ea-108c-733daae313dc
outer(v4, [1, 5, 6])

# ╔═╡ 9a023cf8-f5dd-11ea-3016-f95d433e6df0
outer(1:10, 1:10)  # works with things other than Vectors

# ╔═╡ b4c82246-f5dd-11ea-068f-2f63a5a382e2
md"Did you memorize this in third grade?"

# ╔═╡ d1f87b22-f5dd-11ea-3bc3-471d5b3a5202
md"Slider: 12 is the standard in the UK"

# ╔═╡ d790281e-f5dd-11ea-0d1c-f57da5018a6b
md"How much information do I need to store a multiplication table?"

# ╔═╡ d1578d4c-f601-11ea-2983-27dc131d39b8
md"### Scaled multiplication table"

# ╔═╡ d9556f32-f601-11ea-3dd8-1bc876b7b719
10 .* outer(1:10, 1:10)

# ╔═╡ e36e4ec2-f5dd-11ea-34ea-1bcf5fd7c16d
md"In the context of 1:n times 1:n, just one number n is needed.

But given arbitrary vectors v and w,  we need to store the whole of v and w"

# ╔═╡ 52e857ca-f5de-11ea-14bb-bdc0ac24ab90
md"Toeplitz in hw"

# ╔═╡ 98f08990-f5de-11ea-1f56-1f2d73649773
"Add mult tables to make flag"

# ╔═╡ 21bbb60a-f5df-11ea-2c1b-dd716a657df8
cs = distinguishable_colors(100)

# ╔═╡ 8c4f5342-65dc-11eb-1c93-0f39330be8e2
cs[flag0]

# ╔═╡ a5d637ea-f5de-11ea-3b70-877e876bc9c9
flag = outer([1, 1, 1, 2, 2, 2, 1, 1, 1], ones(Int, 9))

# ╔═╡ 8c1938f2-65dc-11eb-2f5e-85b5b2cb386d
cs[flag + flag']

# ╔═╡ 2668e100-f5df-11ea-12b0-073a578a5edb
cs[flag]

# ╔═╡ e8d727f2-f5de-11ea-1456-f72602e81e0d
cs[flag + flag']

# ╔═╡ 4c80c786-f5df-11ea-31ec-318439349648
cs[outer(rand(1:10, 3), rand(1:10, 5))]

# ╔═╡ 8d2bae22-f5df-11ea-10d3-859f4c3aa6c7
Gray.((100 .- outer(1:10, 1:10)) ./ 100)

# ╔═╡ e23debc8-f5df-11ea-2c1e-b58a64f9acd3
ColorSchemes.rainbow[floor.(Int, (1:10, 1:10) ./ 10)]

# ╔═╡ 70b8918e-f5e0-11ea-3c86-6fa72df5a28e
ColorSchemes.rainbow.colors[floor.(Int, outer(1:10, 1:10) ./ 10)]

# ╔═╡ a0934122-f5e0-11ea-1f3b-ab0021ac6906
ColorSchemes.rainbow.colors[ceil.(Int, outer(1:10, 1:10) ./ 10)]

# ╔═╡ b9381b8a-f5e0-11ea-1f84-e39325203038


# ╔═╡ 4cf96558-f5e0-11ea-19be-db4c59a41120
ColorSchemes.rainbow

# ╔═╡ 11de523c-f5e0-11ea-2f3d-c981c1b6a1fe
outer(1:10, 1:10) ./ 100

# ╔═╡ fb0c6c7e-f5df-11ea-38d0-2d98c9dc232f


# ╔═╡ ebd72fb8-f5e0-11ea-0630-573337dff753
md"## SVD"

# ╔═╡ f00d1eaa-f5e0-11ea-21df-d9cf6f7af9b9
md"Grab the rank-1 approx of an image.

First multiplication table"

# ╔═╡ b6478e1a-f5f6-11ea-3b92-6d4f067285f4
url = "https://arbordayblog.org/wp-content/uploads/2018/06/oak-tree-sunset-iStock-477164218.jpg"

# ╔═╡ d4a049a2-f5f8-11ea-2f34-4bc0e3a5954a
download(url, "tree.jpg")

# ╔═╡ f2c11f88-f5f8-11ea-3e02-c1d4fa22031e
begin
	image = load("tree.jpg")
	image = image[1:5:end, 1:5:end]
end

# ╔═╡ 8be53660-65dc-11eb-39eb-4d1f34979be5
begin
	image0 = load("tree.jpg")
	image0 = image[1:3:end, 1:3:end] # reduce size by skippind pixels
end

# ╔═╡ 826c52c0-65dd-11eb-3bd0-452c558e8a0d
size(image0)

# ╔═╡ 5f5b70cc-65dd-11eb-251f-1dadf109365f
picture0 = Float64.(channelview(image0));

# ╔═╡ 5f273f3a-65dd-11eb-21b9-a97cbcdf2d81
size(picture0)

# ╔═╡ 4b96e328-65dd-11eb-1a86-f17e9085fa1c
size(image0)

# ╔═╡ f7e38aaa-f5f8-11ea-002f-09dd1fa21181
reds = [Float64(c.r) for c in image]

# ╔═╡ 29062f7a-f5f9-11ea-2682-1374e7694e32
picture = Float64.(channelview(image));

# ╔═╡ 6156fd1e-f5f9-11ea-06a9-211c7ab813a4
pr, pg, pb = eachslice(picture, dims=1)

# ╔═╡ a9766e68-f5f9-11ea-0019-6f9d02050521
[RGB.(pr, 0, 0) RGB.(0, pg, 0) RGB.(0, 0, pb)]

# ╔═╡ fee66076-f5f9-11ea-2316-abc57b62a57c
RGB.(image

# ╔═╡ 6532b388-f5f9-11ea-2ae2-f9b12e441bb3
pr

# ╔═╡ 0c0ee362-f5f9-11ea-0f75-2d2810c88d65
begin
	Ur, Σr, Vr = svd(pr)
	Ug, Σg, Vg = svd(pg)
	Ub, Σb, Vb = svd(pb)
end

# ╔═╡ 3c28c4c2-f5fa-11ea-1947-9dfe91ea1535
RGB.(sum(outer(Ur[:,i], Vr[:,i]) .* Σr[i] for i in 1:5), 0, 0)

# ╔═╡ f56f40e4-f5fa-11ea-3a99-156565445c2e
@bind n Slider(1:100, show_value=true)

# ╔═╡ 7ba6e6a6-f5fa-11ea-2bcd-616d5a3c898b
RGB.(sum(outer(Ur[:,i], Vr[:,i]) .* Σr[i] for i in 1:n), 
	sum(outer(Ug[:,i], Vg[:,i]) .* Σg[i] for i in 1:n),
	sum(outer(Ub[:,i], Vb[:,i]) .* Σb[i] for i in 1:n))

# ╔═╡ 8a22387e-f5fb-11ea-249b-435af5c0a6b6


# ╔═╡ 8df84fcc-f5d5-11ea-312f-bf2a3b3ce2ce
md"## Appendix"

# ╔═╡ 91980bcc-f5d5-11ea-211f-e9a08ff0fb19
function with_terminal(f)
	local spam_out, spam_err
	@color_output false begin
		spam_out = @capture_out begin
			spam_err = @capture_err begin
				f()
			end
		end
	end
	spam_out, spam_err
	
	HTML("""
		<style>
		div.vintage_terminal {
			
		}
		div.vintage_terminal pre {
			color: #ddd;
			background-color: #333;
			border: 5px solid pink;
			font-size: .75rem;
		}
		
		</style>
	<div class="vintage_terminal">
		<pre>$(Markdown.htmlesc(spam_out))</pre>
	</div>
	""")
end

# ╔═╡ 466901ea-f5d5-11ea-1db5-abf82c96eabf
with_terminal() do
	dump(M)
end

# ╔═╡ b38c4aae-f5d5-11ea-39b6-7b0c7d529019
with_terminal() do
	dump(Diagonal(M))
end

# ╔═╡ 8b60629e-f5d6-11ea-27c8-d934460d3a57
with_terminal() do
	dump(M3)
end

# ╔═╡ cde79f38-f5d6-11ea-3297-0b5b240f7b9e
with_terminal() do
	dump(sparse(M4))
end

# ╔═╡ 4f8684ea-f5fb-11ea-07be-11d8046f35df
with_terminal() do
	@time @inbounds RGB.(sum(outer(Ur[:,i], Vr[:,i]) .* Σr[i] for i in 1:20), 
	sum(outer(Ug[:,i], Vg[:,i]) .* Σg[i] for i in 1:20),
	sum(outer(Ub[:,i], Vb[:,i]) .* Σb[i] for i in 1:20));
end

# ╔═╡ Cell order:
# ╟─b0ba5b8c-f5d1-11ea-1304-3f0e47f935fe
# ╟─ffa95430-f5d1-11ea-3cb7-5bb8d8f13701
# ╟─261c4df2-f5d2-11ea-2c72-7d4b09c46098
# ╠═ae24c8b2-f60b-11ea-2c7a-03857d1217b2
# ╠═b5177f70-f60b-11ea-14a9-f5a574cc5185
# ╠═173587fc-65cd-11eb-0142-19d01d740764
# ╠═69be79ca-65cd-11eb-2e2e-a593a853c073
# ╠═74d66748-65cd-11eb-0a6b-c5c6cd3f4d55
# ╠═20deb2ae-65cf-11eb-1c95-0b32b76762b8
# ╠═5d287d76-65cf-11eb-14ee-c1fd1da1ad1e
# ╠═01c5435a-65d0-11eb-2324-5fba7a350c29
# ╠═96835a14-65cf-11eb-11a0-8f8eae632308
# ╠═9ee5c03e-65cf-11eb-2eeb-cd070a5cb183
# ╠═4e00f836-65d0-11eb-1b4e-17fb3f317cb7
# ╠═8963ea8c-65d0-11eb-1983-9bcb2970d6e4
# ╠═a475f8c4-65d0-11eb-26af-575217377b47
# ╠═b968962e-65d0-11eb-372c-c9925c2ceeb9
# ╠═be07c93e-65d0-11eb-1f75-e70a55647d7a
# ╠═de0062d2-65d0-11eb-16a2-0b9d2293625d
# ╠═032d9d22-65d1-11eb-1f38-9b887f27bfd6
# ╠═12df4d06-65d1-11eb-2925-e34340ca83dd
# ╠═da8c55d4-65d5-11eb-19a5-ab8d0a441d88
# ╠═0b86bbd2-65d3-11eb-1814-7f5998184a28
# ╠═5f87f9a8-65d3-11eb-0356-2be63dd430da
# ╠═aa878ea0-65d3-11eb-209e-bdce0640d960
# ╠═f2728092-65d5-11eb-0d17-235e9bc5dcab
# ╠═06341b04-65d6-11eb-086b-cd2871ead5a5
# ╠═c65ec13e-65d3-11eb-1abb-a7a078ce4590
# ╠═d72d5fe8-65d3-11eb-09f5-954b1df751e4
# ╠═f0ba416a-65d3-11eb-21a1-7539e41d7789
# ╠═f041537c-65d3-11eb-0f1e-f12b66d8f739
# ╠═bfdc328c-65d4-11eb-1341-9fd0b516e810
# ╠═efcb02e2-65d3-11eb-04f8-b3652fdf61f6
# ╠═ca89bb84-65d5-11eb-3f41-471abd811a48
# ╠═265605ce-65d5-11eb-0565-4545092fcd28
# ╠═261b7c4c-65d5-11eb-37eb-b133fe08709e
# ╠═25f094c8-65d5-11eb-302d-d7915457963f
# ╠═931d370e-65d5-11eb-0125-39e6c0b17eff
# ╠═42d52ee0-65d6-11eb-2ecc-a1b8d1b54c93
# ╠═321f9284-65d6-11eb-3862-fd064484a3bc
# ╠═78a9474a-65d6-11eb-1680-ffcfd2d11c09
# ╠═c1648f4c-65d6-11eb-0808-7fcd36b0a15e
# ╠═0d454f44-65db-11eb-1cf3-7f75cbc37b83
# ╠═b51607a0-65da-11eb-3e51-4f61010cf19c
# ╠═f6e8c26a-65da-11eb-3c68-cf11f5fca718
# ╠═4d5ab1d2-65db-11eb-22f7-854756cc49a1
# ╠═8257aa70-65db-11eb-32d8-cd68bb4988d9
# ╠═9e82860c-65db-11eb-0940-8d1d8f38337a
# ╠═18445dda-65dc-11eb-0b00-f93944578fb5
# ╠═41128fc0-65dc-11eb-2402-bdd073b147b6
# ╠═8c4f5342-65dc-11eb-1c93-0f39330be8e2
# ╠═8c1938f2-65dc-11eb-2f5e-85b5b2cb386d
# ╠═8be53660-65dc-11eb-39eb-4d1f34979be5
# ╠═826c52c0-65dd-11eb-3bd0-452c558e8a0d
# ╠═5f5b70cc-65dd-11eb-251f-1dadf109365f
# ╠═5f273f3a-65dd-11eb-21b9-a97cbcdf2d81
# ╠═5eb8cfdc-65dd-11eb-3529-8102930afe06
# ╠═4b96e328-65dd-11eb-1a86-f17e9085fa1c
# ╠═4b68e428-65dd-11eb-10b0-5f6909a916a8
# ╠═25a70ee8-65d5-11eb-36e2-cdd3773ef92c
# ╠═bc14fc1a-f60b-11ea-207a-91b967f28076
# ╠═ef8f44b2-f5fc-11ea-1e4d-bd873cd39d6c
# ╠═fd9211c0-f5fc-11ea-1745-7f2dae88af9e
# ╠═3a1ed5b8-f5fd-11ea-2ecd-b9d08349651f
# ╠═676f6e3a-f5fd-11ea-3552-e7e7c6382276
# ╠═77ae1146-f5d2-11ea-1226-27d15c90a8df
# ╠═3592648a-f5fd-11ea-2ed0-a1d4a4c14d07
# ╠═7ffa02f6-f5d2-11ea-1b41-15c21f92e9ee
# ╟─21a15906-f5d3-11ea-3a71-f53eabc31acc
# ╟─3c5f0ba8-f5d3-11ea-22d3-4f7c513144bc
# ╠═4d2db24e-f5d4-11ea-10d4-b126f643abee
# ╠═4624cd26-f5d3-11ea-1cf8-7d6555eae5fa
# ╠═397ac764-f5fe-11ea-20cc-8d7cab19d410
# ╠═82c7046c-f5d3-11ea-04e2-ef7c0f4db5da
# ╠═60214c1a-f5fe-11ea-2d08-c59715bcedd0
# ╠═7a98f708-f5d3-11ea-2301-cde71ca469ff
# ╠═cf77d83c-f5fd-11ea-136e-8951de64e05e
# ╠═5813e1b2-f5ff-11ea-2849-a1def74fc065
# ╠═e51d4ef6-f5fd-11ea-28f1-a1616e17f715
# ╠═982590d4-f5ff-11ea-3802-73292c75ad6c
# ╠═c3f70e18-f5ff-11ea-35aa-31b22ca506b8
# ╠═c200deb0-f5fd-11ea-32e1-d96596b16ebc
# ╠═a5989a76-f5d3-11ea-3fe5-5f9959199fe8
# ╠═b0bd6c6a-f5d3-11ea-00ee-b7c155f23481
# ╠═bd94f82c-f5d3-11ea-2a1e-77ddaadbfeb9
# ╠═8d2c6910-f5d4-11ea-1928-1baf09815687
# ╟─81c35324-f5d4-11ea-2338-9f982d38732c
# ╟─2cfda0dc-f5d5-11ea-16c4-b5a33b90e37f
# ╠═0feb5674-f5d5-11ea-0714-7379a7d381a3
# ╠═150432d4-f5d5-11ea-32b2-19a2a91d9637
# ╠═21328d1c-f5d5-11ea-288e-4171ad35326d
# ╠═466901ea-f5d5-11ea-1db5-abf82c96eabf
# ╠═b38c4aae-f5d5-11ea-39b6-7b0c7d529019
# ╟─d8f36278-f5d5-11ea-3338-8573ce40e65e
# ╟─e90c55fc-f5d5-11ea-10f1-470ff772985d
# ╠═19775c3c-f5d6-11ea-15c2-89618e654a1e
# ╠═20125236-f5d6-11ea-3877-6b332497be62
# ╠═232d1dcc-f5d6-11ea-2710-658c75b9c7a4
# ╠═2b2feb9c-f5d6-11ea-191c-df20360b12a9
# ╠═50c74f6c-f5d6-11ea-29f1-5de9997d5d9f
# ╠═5de72b7c-f5d6-11ea-1b6f-35b830b5fb34
# ╠═8b60629e-f5d6-11ea-27c8-d934460d3a57
# ╠═2fd7e52e-f5d7-11ea-3b5a-1f338e2451e0
# ╠═cde79f38-f5d6-11ea-3297-0b5b240f7b9e
# ╠═aa09c008-f5d8-11ea-1bdc-b51ee6eb2478
# ╟─d941cd66-f5d8-11ea-26ff-47ba7779ab20
# ╟─62a6ec62-f5d9-11ea-071e-ed33c5dea0cd
# ╠═67274c3c-f5d9-11ea-3475-c9d228e3bd5a
# ╟─b6c7a918-f600-11ea-18ff-6521507358c6
# ╟─765c6552-f5d9-11ea-29d3-bfe7b4b04612
# ╠═0f6ecba6-f5da-11ea-22c2-2929e562f413
# ╠═126fb3ea-f5da-11ea-2f7d-0b3259a296ce
# ╠═5f79e8f4-f5da-11ea-2b55-ef344b8a3ba2
# ╟─9b9e2c2a-f5da-11ea-369b-b513b196515b
# ╠═e68b98ea-f5da-11ea-1a9d-db45e4f80241
# ╠═f20ccac4-f5da-11ea-0e69-413b5e49f423
# ╠═0bc792e8-f5db-11ea-0b7a-1502ddc8008e
# ╠═12a2e96c-f5db-11ea-1c3e-494ae7446886
# ╠═22487ce2-f5db-11ea-32e9-6f70ab2c0353
# ╠═389ae62e-f5db-11ea-1557-c3adbbee0e5c
# ╟─0c2b6408-f5d9-11ea-2b7f-7fece2eecc1f
# ╟─542a9556-f5db-11ea-0375-99f52416f6e4
# ╠═165788b2-f601-11ea-3e69-cdbbb6558e54
# ╠═22941bb8-f601-11ea-1d6e-0d955297bc2e
# ╠═2f75df7e-f601-11ea-2fc2-aff4f335af33
# ╠═53e6b612-f601-11ea-05a9-5395e69b3c41
# ╠═5a493052-f601-11ea-2f5f-f940412905f2
# ╠═8633afb2-f601-11ea-206b-e9c4b9621c2a
# ╠═9918c4fa-f601-11ea-3bf1-3506dcb437f7
# ╟─3e919766-f601-11ea-0485-05f45484bf8d
# ╠═1052993e-f601-11ea-2c55-0d67e31b670e
# ╠═68190822-f5db-11ea-117f-d10a161208c3
# ╠═71b44874-f5db-11ea-1f67-47bad9295e03
# ╠═6c51eddc-f5db-11ea-1235-332cdbb072fa
# ╠═86fb49ee-f5db-11ea-3bfa-c95c3b8775a3
# ╠═173cfab4-f5d9-11ea-0c7c-bf8b0888f6e7
# ╠═8bab3e36-f5db-11ea-187a-f31fa8cf357d
# ╠═e64291e8-f5db-11ea-0cab-8567b781408f
# ╠═0111a124-f5dc-11ea-0904-fdd88d7acac4
# ╠═06406158-f5dc-11ea-02b1-2519a0176993
# ╠═12051f06-f5dc-11ea-2f6c-0fdc50eeff01
# ╠═195854e6-f5dc-11ea-114b-2333f87173f7
# ╠═768116f6-f5dc-11ea-1cfe-b3016c574725
# ╠═9050426e-f5dc-11ea-373c-65456732bd34
# ╠═965bd07e-f5dc-11ea-2e85-d34996cf2fae
# ╠═a9daf4cc-f5dc-11ea-270b-2566f89f168c
# ╠═dc0c8b72-f5dc-11ea-3e6f-0f43cbf58f56
# ╠═0ed78e76-f5dd-11ea-2ad8-a35a69c0ef9a
# ╠═1648a0fa-f5dd-11ea-0292-495207e83de9
# ╠═1e9cefea-f5dd-11ea-3e5f-a189fd41c42e
# ╠═24664f20-f5dd-11ea-2a69-cd3e0ebd5c39
# ╠═43a4920c-f5dd-11ea-1ab1-0b3d673c0f1e
# ╠═5d767290-f5dd-11ea-2189-81198fd216ce
# ╠═6aae805e-f5dd-11ea-108c-733daae313dc
# ╠═9a023cf8-f5dd-11ea-3016-f95d433e6df0
# ╠═b4c82246-f5dd-11ea-068f-2f63a5a382e2
# ╠═d1f87b22-f5dd-11ea-3bc3-471d5b3a5202
# ╠═d790281e-f5dd-11ea-0d1c-f57da5018a6b
# ╠═d1578d4c-f601-11ea-2983-27dc131d39b8
# ╠═d9556f32-f601-11ea-3dd8-1bc876b7b719
# ╠═e36e4ec2-f5dd-11ea-34ea-1bcf5fd7c16d
# ╠═52e857ca-f5de-11ea-14bb-bdc0ac24ab90
# ╠═98f08990-f5de-11ea-1f56-1f2d73649773
# ╠═21bbb60a-f5df-11ea-2c1b-dd716a657df8
# ╠═a5d637ea-f5de-11ea-3b70-877e876bc9c9
# ╠═2668e100-f5df-11ea-12b0-073a578a5edb
# ╠═e8d727f2-f5de-11ea-1456-f72602e81e0d
# ╠═4c80c786-f5df-11ea-31ec-318439349648
# ╠═8d2bae22-f5df-11ea-10d3-859f4c3aa6c7
# ╠═e23debc8-f5df-11ea-2c1e-b58a64f9acd3
# ╠═70b8918e-f5e0-11ea-3c86-6fa72df5a28e
# ╠═a0934122-f5e0-11ea-1f3b-ab0021ac6906
# ╠═b9381b8a-f5e0-11ea-1f84-e39325203038
# ╠═4cf96558-f5e0-11ea-19be-db4c59a41120
# ╠═11de523c-f5e0-11ea-2f3d-c981c1b6a1fe
# ╠═fb0c6c7e-f5df-11ea-38d0-2d98c9dc232f
# ╠═ebd72fb8-f5e0-11ea-0630-573337dff753
# ╠═f00d1eaa-f5e0-11ea-21df-d9cf6f7af9b9
# ╠═b6478e1a-f5f6-11ea-3b92-6d4f067285f4
# ╠═d4a049a2-f5f8-11ea-2f34-4bc0e3a5954a
# ╠═f2c11f88-f5f8-11ea-3e02-c1d4fa22031e
# ╠═f7e38aaa-f5f8-11ea-002f-09dd1fa21181
# ╠═29062f7a-f5f9-11ea-2682-1374e7694e32
# ╠═6156fd1e-f5f9-11ea-06a9-211c7ab813a4
# ╠═a9766e68-f5f9-11ea-0019-6f9d02050521
# ╠═fee66076-f5f9-11ea-2316-abc57b62a57c
# ╠═6532b388-f5f9-11ea-2ae2-f9b12e441bb3
# ╠═0c0ee362-f5f9-11ea-0f75-2d2810c88d65
# ╠═3c28c4c2-f5fa-11ea-1947-9dfe91ea1535
# ╠═f56f40e4-f5fa-11ea-3a99-156565445c2e
# ╠═7ba6e6a6-f5fa-11ea-2bcd-616d5a3c898b
# ╠═8a22387e-f5fb-11ea-249b-435af5c0a6b6
# ╠═4f8684ea-f5fb-11ea-07be-11d8046f35df
# ╠═8df84fcc-f5d5-11ea-312f-bf2a3b3ce2ce
# ╠═91980bcc-f5d5-11ea-211f-e9a08ff0fb19
