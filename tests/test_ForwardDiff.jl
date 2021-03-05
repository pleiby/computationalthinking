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
	Pkg.add("ForwardDiff")
	using Plots
	gr()
	using PlutoUI
end

# ╔═╡ 9bbcf498-7de6-11eb-3977-8facaf6042f7
using ForwardDiff

# ╔═╡ c2aa1236-7dcb-11eb-2216-c36ae99f3a8a
md"# Test `ForwardDiff`"

# ╔═╡ 3af050c0-7dcc-11eb-0f5e-a9e2d51acbfa
md"""See: [JuliaCon 2016 | ForwardDiff.jl: Fast Derivatives Made Easy | Jarrett Revels](https://www.youtube.com/watch?v=r2hhRSHiQwY) The "Complex Step Method" @4:30 is so clever! The graph @8:45 has some very interesting insights."""

# ╔═╡ 12b41de4-7568-11eb-0869-adbc597546cf
md"_Pluto notebook template_"

# ╔═╡ 47246f1e-7568-11eb-2c3e-5d4ee2ad133f
md"Note: Necessary standard startup code for a scratch Pluto notebook: 

- Create a Pkg environment, and 
- `import`/`using` the needed packages, including e.g. `Plot`"

# ╔═╡ f1e556aa-7de4-11eb-28a1-ff7e2d54a091
md"#### Construct Test Functions to Differentiate with `ForwardDiff`"

# ╔═╡ 5e38503a-7dcc-11eb-283c-a5153539353b
# Cumulative Product: a test multi-valued function of multiple variables x
function cumprod_test(x) # distinct from base.cumprod(), but same function
	y = similar(x)
	if length(y) < 1
		return y # fails because y is uninitialized
	else
		y[1] = x[1]
		for i in 2:length(y)
			y[i] = y[i-1]*x[i]
		end
	end
	return y
end

# ╔═╡ 06013bec-7dcf-11eb-303b-0547ceb7b3e5
# Productr: a test single-valued function of multiple variables x
function prod_test(x) # distinct from base.prod(), but same function
	y = similar(x, 1)
	y = x[1]
	if length(x) > 1
		for i in 2:length(x)
			y = y*x[i]
		end
	end
	return y
end

# ╔═╡ ab7b2768-7dcd-11eb-2489-3fca9e509166
x = [1, 2, 3]

# ╔═╡ c34821a4-7dcd-11eb-2a0c-19efc78695b2
cumprod(x)

# ╔═╡ c8a70656-7dcd-11eb-2b68-b7be47395740
cumprod_test(x)

# ╔═╡ 63a87f44-7dcf-11eb-0fb3-d3d6124d0835
prod(x)

# ╔═╡ 685fc722-7dcf-11eb-39b1-ad183fc25e3c
prod_test(x)

# ╔═╡ 450cb0c6-7dcc-11eb-2030-1583dc584fe6
md"""**Aside:** Note small algebra error at 18:32 in the video where is shows equations show for Jacobian. 

$$cumprod(\begin{bmatrix}
    x_{1}  \\
    x_{3}\\
    x_{3}\\
\end{bmatrix}) = \begin{bmatrix}
    x_{1}  \\
    x_{1}x_{2}\\
    x_{1}x_{2}x_{3}\\
\end{bmatrix}$$
The correct Jacobian for the `cumprod` function is:
$$J(cumprod(\begin{bmatrix}
    x_{1}  \\
    x_{3}\\
    x_{3}\\
\end{bmatrix})) = \begin{bmatrix}
    1       & 0 &  0 \\
    x_{2}       & x_{1} & 0 \\
    x_{2}x_{3}       & x_{1}x_{3} & x_{1}x_{2} \\
\end{bmatrix}$$
"""

# ╔═╡ feb7e5c8-7ddf-11eb-0229-0b779f897cef
md"This algebraic expression for the Jacobian, differs from that in the video in rows 1 and 2. The example numerical differentiation result for Jacobian matches both the above and the expression in the video only by chance (since the chosen example values include $x_1 = 1$, so $x_2 x_1 = x_1$ in this instance."

# ╔═╡ cb5b8230-7dcf-11eb-1de1-018e456b11f2
md"""Note that the following cumbersome `Dual` variable specification (as in the above-referenced lecture at time 19:25) is not necessary or working."""

# ╔═╡ eb60da3e-7dcd-11eb-2083-dfe3f9cda118
x_test = [
	ForwardDiff.Dual(1, 1, 0, 0), # 1 + ϵ_1
	ForwardDiff.Dual(2, 0, 1, 0), # 2 + ϵ_2
	ForwardDiff.Dual(3, 0, 0, 1)  # 3 + ϵ_3
	]

# ╔═╡ f7155242-7dd0-11eb-3395-013e507f24aa
md"""#### Improved numerical differentiation with `ForwardDiff.jl`

see https://juliadiff.org/ForwardDiff.jl/stable/user/api/ for current use syntax."""

# ╔═╡ 2c47c06a-7dd0-11eb-1d95-4353bcc94972
md"""`ForwardDiff.gradient` "just works" for $f: \mathbb R^n \rightarrow \mathbb R^1$, single-real-valued function of multiple variables, like `prod_test`:"""

# ╔═╡ b9182af6-7dcf-11eb-20d2-adaccfe1d412
ForwardDiff.gradient(prod_test, x)

# ╔═╡ 32617fec-7dd1-11eb-0467-8be4d706bc06
md"""`ForwardDiff.gradient` fails, of course for $f: \mathbb R^n \rightarrow  \mathbb R^m$, multiple-real-valued function of multiple real variables, like `cumprod_test`:"""

# ╔═╡ 3d2e88b6-7dd1-11eb-10c2-5f4b117dbfe2
ForwardDiff.gradient(cumprod_test, x)

# ╔═╡ 6e11478a-7dd0-11eb-217a-6d322964ac96
md"""`ForwardDiff.jacobian` "just works" however, for $f: \mathbb R^n \rightarrow \mathbb R^m$, multiple-real-valued function of multiple real variables:"""

# ╔═╡ 98015266-7dcf-11eb-12ba-510c2f2bd7ca
ForwardDiff.jacobian(cumprod_test, x)

# ╔═╡ e4f0de92-7dd0-11eb-293f-11c9b62bec09
md"Note this above result matches the one in the Revels video presentation @19:25"

# ╔═╡ 67ba822a-7dd5-11eb-39ed-fb83d71e7ee7
ForwardDiff.jacobian(cumprod_test, [2, 3, 4])

# ╔═╡ ad325024-7de6-11eb-3c7a-8764f2d7d47a
md"And of course, for autodifferentiation of single-valued function of a scalar variable, we have `ForwardDiff.derivative`:"

# ╔═╡ ded067a6-7de6-11eb-08e1-2fbc1785e5ae
ForwardDiff.derivative(sin, pi) # Woohoo!

# ╔═╡ Cell order:
# ╟─c2aa1236-7dcb-11eb-2216-c36ae99f3a8a
# ╟─3af050c0-7dcc-11eb-0f5e-a9e2d51acbfa
# ╟─12b41de4-7568-11eb-0869-adbc597546cf
# ╟─47246f1e-7568-11eb-2c3e-5d4ee2ad133f
# ╠═5d63e746-7568-11eb-3d95-cd9c2e57056f
# ╠═66a2e85c-7568-11eb-2ad3-c108d59ebcc2
# ╠═9bbcf498-7de6-11eb-3977-8facaf6042f7
# ╠═f1e556aa-7de4-11eb-28a1-ff7e2d54a091
# ╠═5e38503a-7dcc-11eb-283c-a5153539353b
# ╠═06013bec-7dcf-11eb-303b-0547ceb7b3e5
# ╠═ab7b2768-7dcd-11eb-2489-3fca9e509166
# ╠═c34821a4-7dcd-11eb-2a0c-19efc78695b2
# ╠═c8a70656-7dcd-11eb-2b68-b7be47395740
# ╠═63a87f44-7dcf-11eb-0fb3-d3d6124d0835
# ╠═685fc722-7dcf-11eb-39b1-ad183fc25e3c
# ╟─450cb0c6-7dcc-11eb-2030-1583dc584fe6
# ╟─feb7e5c8-7ddf-11eb-0229-0b779f897cef
# ╟─cb5b8230-7dcf-11eb-1de1-018e456b11f2
# ╠═eb60da3e-7dcd-11eb-2083-dfe3f9cda118
# ╟─f7155242-7dd0-11eb-3395-013e507f24aa
# ╟─2c47c06a-7dd0-11eb-1d95-4353bcc94972
# ╠═b9182af6-7dcf-11eb-20d2-adaccfe1d412
# ╟─32617fec-7dd1-11eb-0467-8be4d706bc06
# ╠═3d2e88b6-7dd1-11eb-10c2-5f4b117dbfe2
# ╟─6e11478a-7dd0-11eb-217a-6d322964ac96
# ╠═98015266-7dcf-11eb-12ba-510c2f2bd7ca
# ╟─e4f0de92-7dd0-11eb-293f-11c9b62bec09
# ╠═67ba822a-7dd5-11eb-39ed-fb83d71e7ee7
# ╟─ad325024-7de6-11eb-3c7a-8764f2d7d47a
# ╠═ded067a6-7de6-11eb-08e1-2fbc1785e5ae
