### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 4c910f30-7526-11eb-27b6-4f8ef1222f7d
# create a package environment
begin
	using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 52f90274-7526-11eb-0a31-a751ccb9a0e0
# add the needed packages
begin
	Pkg.add(["PlutoUI", "Plots"])

	using Plots
	gr()
	using PlutoUI
end

# ╔═╡ 044e86fa-7524-11eb-1ee3-4bb50e7fca00
md"_Notes on homework 5, version 0_"

# ╔═╡ a8598c70-7526-11eb-0e34-f3cb7a44cbed
md"Note: Necessary standard startup code for a scratch Pluto notebook: 

- Create a Pkg environment, and 
- `import`/`using` the needed packages, including e.g. `Plot`"

# ╔═╡ 811db08c-7521-11eb-1eaa-45ec8e3153c3
md"### Discrete-time change Geometric growth models and Continuous-time change Exponential models - close analogs"

# ╔═╡ 99623cee-7521-11eb-19b1-4104baeb1a6c
md"Consider a discrete-time model with geometric growth rate at `r1` fraction per unit time `t`"

# ╔═╡ 9b900ca8-7521-11eb-3bf1-9555be242482
md"""$${(1+r)^t}$$"""

# ╔═╡ b0b4867c-7521-11eb-2e31-5de7f45e3653
md"where each period the multiplicative factor $(1+r)$ is applied."

# ╔═╡ b3485418-7521-11eb-3c63-a3ed99d92ef5
md"The discrete time multiperiod growth, from time 0 to t is"

# ╔═╡ bf1a1362-7521-11eb-1d26-213754d612b0
md"$$A(t) = A_0 {(1+r)^t}, \forall t \in 1...T$$"

# ╔═╡ d73a35b2-7521-11eb-13ab-ed3a9e30af87
md"So the single step discrete equation is:"

# ╔═╡ e162dc56-7521-11eb-2c16-9115ea25605d
md"$$A(t+1) = A(t){(1+r)}$$"

# ╔═╡ e9608dfe-7521-11eb-38fc-d1589529a074
md"And the period-to-period change equation, or _difference equation_, is"

# ╔═╡ f42bec74-7521-11eb-24d4-e7e1e809da77
md"$$\delta A(t) = A(t+1) - A(t) = A(t){(1+r)} - A(t) = r A(t)$$"

# ╔═╡ fc994816-7521-11eb-0f38-8bcc81d6353c
md"The analogous continuous growth equation is:"

# ╔═╡ 084e0796-7522-11eb-1314-fbb5a9bd787c
md"$$A(t) = A_0e^{+rt}$$"

# ╔═╡ 112d5602-7522-11eb-19e5-158f8ed82446
md"With the corresponding (continuous time) differential equation"

# ╔═╡ 1a675f7e-7522-11eb-26af-0115c945644f
md"$$\frac{dA(t)}{dt} = r A(t)$$"

# ╔═╡ 219e07be-7522-11eb-3a74-0759f30a4f94
md"### Expectations"

# ╔═╡ 35e063c2-7522-11eb-1fc5-8359fe9134c1
md"The expectation of a continuous random variable with probability density function $f(x)$ is defined as the integral, where possible observations x are weighted by their probability density:"

# ╔═╡ 49dc9874-7522-11eb-3370-ebe580d74230
md"$$E(X) = \int_\inf x f(x) dx$$"

# ╔═╡ 49478ff6-7522-11eb-0848-0f04d30fc247
md"""The important features of the probability density function are non-negativity ($f(x)\ge 0$) and that the total probability density must be 1.0:
"""

# ╔═╡ 5ff26d16-7522-11eb-2db6-f17f3042bfdf
md"$$\int_{-\infty}^{+\infty} f(x) dx = 1$$"

# ╔═╡ 9feec52a-7522-11eb-3b5f-0181de61a375
md"The expectation of a discrete random variable $\tilde X$ with popssible values $x_i$ each with probability $p_i$ is defined as the probability-weighted sum, where possible observations $x_i$ are weighted by their probabilitie:"

# ╔═╡ b05bd058-7522-11eb-1a80-7d4755c4b041
md"$$E(\tilde X) = \sum_{i=1}^N x_i p_i$$"

# ╔═╡ bf7b5536-7522-11eb-25cd-59939e4fba2d
md"And the discrete probabilities must each be non-negative ($p_i \ge 0.0 ~\forall i$) and sum to 1.0:"

# ╔═╡ d294a9ec-7522-11eb-03aa-45d7d2ed6875
md"$$\sum_{i=1}^N p_i = 1.0$$"

# ╔═╡ d7e46fe0-7522-11eb-2404-ff82110357f8
md"Importantly/usefully, Expectation is a linear operator (additive constants $a$ just add to the expectation, and multiplicative constants $b$ just multiply it):"

# ╔═╡ dd6a013c-7522-11eb-06bb-31845e283e36
md"$$E[a + b X] = a + b E[X]$$"

# ╔═╡ e1bd8eac-7522-11eb-2696-d1566d1d4558
md"The expectation of a product of 2 random variables is the product of their expectations, _if_ they are independent:"

# ╔═╡ e75b16f4-7522-11eb-3549-8590966b6543
md"$$E[\tilde X \cdot \tilde Y] = E[\tilde X] E[\tilde Y]$$ iff independent"

# ╔═╡ df448886-7524-11eb-1ac2-ed1a3d36460f
md"This is actually almost a definition of [Independent Random Variable](https://www.probabilitycourse.com/chapter3/3_1_4_independent_random_var.php#:~:text=Intuitively%2C%20two%20random%20variables%20X,%2C%20for%20all%20x%2Cy.)"

# ╔═╡ 28337ef8-7525-11eb-3745-69d762f2a999
md"Perhaps a more intuitive (equivalent) definition of independent random variable \$\tilde X\$ is that its outcome does not depend on the outcome of the other random variable, in a probabilistic sense. That is, the probability of \$\tilde X\$ taking a particular value $x$ does not depend on the value taken by random variable \$\tilde Y\$."

# ╔═╡ 9231c26a-7525-11eb-14ba-c77412ebd36e
md"$$P(X=x|Y=y) ~= P(X=x), ~\forall x,y$$"

# ╔═╡ 0d107c2e-7526-11eb-20e4-878c41535162
md"i.e., the _conditional probability_ of \$\tilde X = x\$ given \$\tilde Y=y\$ is just the (marginal) probability of \$\tilde X=x\$ alone."

# ╔═╡ 5908df76-7527-11eb-340d-777f2516a7dd
md"More generally (without a known independence), the standard definition of conditional probability of event $A$ given event $B$ is:"

# ╔═╡ eaeea734-7527-11eb-08f0-1b74c6328b45
md"$$P(A|B) ~= \frac{P(A \cap B)}{P(B)}$$"

# ╔═╡ 314e57bc-7528-11eb-25ec-250aab2acd85
md"""In terms of random variables, where the random variable taking a particular value (or set of values) is an "event" with some probability, conditional probability is:"""

# ╔═╡ 8148dc40-7527-11eb-0491-5f4e4ce8c0ca
md"$$P(X=x|Y=y) ~= \frac{P(X=x \cap Y=y)}{P(Y=y)}$$"

# ╔═╡ 83facb26-7528-11eb-2c6f-230db4bb77f4
md"We can see now from this general expression for conditional probability, that if the events, or random variable outcomes, are not conditionally dependent on one another, "

# ╔═╡ f248b1d4-7522-11eb-10c8-350a98dde5cb
md"### Basic (Quick) Graphics"

# ╔═╡ 73cbae82-7526-11eb-015e-e18d579b75c0
md"Note: see the startup code at top, creating a Pkg envirionment, and `import`ing/`using` the needed packages, including `Plot`"

# ╔═╡ 56897c96-7523-11eb-3198-c946bcd2d21f
md"Graph comparing geometric and exponential growth, both at rate `r`"

# ╔═╡ 3c4b8dd8-7523-11eb-1181-037364147d13
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

# ╔═╡ 4b4486c0-7523-11eb-05d7-9f94c77fac6d
md"Side by side graphs:"

# ╔═╡ 3ed7e4a2-7523-11eb-2392-3fc7c957d82e
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

# ╔═╡ Cell order:
# ╟─044e86fa-7524-11eb-1ee3-4bb50e7fca00
# ╟─a8598c70-7526-11eb-0e34-f3cb7a44cbed
# ╠═4c910f30-7526-11eb-27b6-4f8ef1222f7d
# ╠═52f90274-7526-11eb-0a31-a751ccb9a0e0
# ╟─811db08c-7521-11eb-1eaa-45ec8e3153c3
# ╟─99623cee-7521-11eb-19b1-4104baeb1a6c
# ╟─9b900ca8-7521-11eb-3bf1-9555be242482
# ╟─b0b4867c-7521-11eb-2e31-5de7f45e3653
# ╟─b3485418-7521-11eb-3c63-a3ed99d92ef5
# ╟─bf1a1362-7521-11eb-1d26-213754d612b0
# ╟─d73a35b2-7521-11eb-13ab-ed3a9e30af87
# ╟─e162dc56-7521-11eb-2c16-9115ea25605d
# ╟─e9608dfe-7521-11eb-38fc-d1589529a074
# ╟─f42bec74-7521-11eb-24d4-e7e1e809da77
# ╟─fc994816-7521-11eb-0f38-8bcc81d6353c
# ╟─084e0796-7522-11eb-1314-fbb5a9bd787c
# ╟─112d5602-7522-11eb-19e5-158f8ed82446
# ╟─1a675f7e-7522-11eb-26af-0115c945644f
# ╟─219e07be-7522-11eb-3a74-0759f30a4f94
# ╟─35e063c2-7522-11eb-1fc5-8359fe9134c1
# ╟─49dc9874-7522-11eb-3370-ebe580d74230
# ╟─49478ff6-7522-11eb-0848-0f04d30fc247
# ╟─5ff26d16-7522-11eb-2db6-f17f3042bfdf
# ╟─9feec52a-7522-11eb-3b5f-0181de61a375
# ╟─b05bd058-7522-11eb-1a80-7d4755c4b041
# ╟─bf7b5536-7522-11eb-25cd-59939e4fba2d
# ╟─d294a9ec-7522-11eb-03aa-45d7d2ed6875
# ╟─d7e46fe0-7522-11eb-2404-ff82110357f8
# ╟─dd6a013c-7522-11eb-06bb-31845e283e36
# ╟─e1bd8eac-7522-11eb-2696-d1566d1d4558
# ╟─e75b16f4-7522-11eb-3549-8590966b6543
# ╠═df448886-7524-11eb-1ac2-ed1a3d36460f
# ╟─28337ef8-7525-11eb-3745-69d762f2a999
# ╟─9231c26a-7525-11eb-14ba-c77412ebd36e
# ╟─0d107c2e-7526-11eb-20e4-878c41535162
# ╟─5908df76-7527-11eb-340d-777f2516a7dd
# ╟─eaeea734-7527-11eb-08f0-1b74c6328b45
# ╟─314e57bc-7528-11eb-25ec-250aab2acd85
# ╠═8148dc40-7527-11eb-0491-5f4e4ce8c0ca
# ╠═83facb26-7528-11eb-2c6f-230db4bb77f4
# ╟─f248b1d4-7522-11eb-10c8-350a98dde5cb
# ╟─73cbae82-7526-11eb-015e-e18d579b75c0
# ╟─56897c96-7523-11eb-3198-c946bcd2d21f
# ╠═3c4b8dd8-7523-11eb-1181-037364147d13
# ╟─4b4486c0-7523-11eb-05d7-9f94c77fac6d
# ╠═3ed7e4a2-7523-11eb-2392-3fc7c957d82e
