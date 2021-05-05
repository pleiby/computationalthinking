### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ e9ef3194-5e83-11eb-02a7-cf21831f4d31
begin
	using Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 1eac504c-5e84-11eb-0474-4dff54c1c347
md"""
# _Exploring Kernels in Convolution_

### Questions

1. In what sense is the the kernel 'flipped' or 'reversed' when performing convolution?
2. Why is it reversed?
"""

# ╔═╡ 400a0bbe-5e87-11eb-38d7-5157032d1614
md"""
### Convolution
Convolution is the process of adding each element of the image to its local neighbors, weighted by the kernel. This is related to a form of mathematical convolution. The matrix operation being performed—convolution—is not traditional matrix multiplication, despite being similarly denoted by *.

Wikipedia, [Kernel (image processing), Convolution](https://en.wikipedia.org/wiki/Kernel_(image_processing)#Convolution)
"""

# ╔═╡ ef1ba838-5e82-11eb-1ecf-8f76e3c342ef
md"""
### Why do we need to flip the kernel in convolution
It's not meant to be a "benefit" or to avoid disastrous consequences. It's meant to be a definition. If you don't flip, then you violate the agreed upon definition of convolution. Convolution without the flip has a name of its own: correlation.[Note: this is consistent with the `Kernel.reverse` documentation in Julia]

Source [Mathworks/matlabcentral: Why do we need to flip the kernel in 2D convolution?](https://www.mathworks.com/matlabcentral/answers/74274-why-do-we-need-to-flip-the-kernel-in-2d-convolution)
"""

# ╔═╡ e9b75030-5e86-11eb-30da-1d4afdcd0e76
md"""
When the kernel/filter is symmetric, like a *Gaussian*, or a *Laplacian*, convolution and correlation are identical.
"""

# ╔═╡ Cell order:
# ╠═1eac504c-5e84-11eb-0474-4dff54c1c347
# ╠═e9ef3194-5e83-11eb-02a7-cf21831f4d31
# ╠═400a0bbe-5e87-11eb-38d7-5157032d1614
# ╠═ef1ba838-5e82-11eb-1ecf-8f76e3c342ef
# ╠═e9b75030-5e86-11eb-30da-1d4afdcd0e76
