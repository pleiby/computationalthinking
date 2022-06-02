### A Pluto.jl notebook ###
# v0.14.3

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

# ╔═╡ 1e06178a-1fbf-11eb-32b3-61769a79b7c0
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
        "Plots",
        "PlutoUI",
        "LaTeXStrings",
        "Distributions",
        "Random",
    ])
    using LaTeXStrings
    using Plots
    using PlutoUI
    using Random, Distributions
end

# ╔═╡ 169727be-2433-11eb-07ae-ab7976b5be90
md"_homework 9, version 1_"

# ╔═╡ 21524c08-2433-11eb-0c55-47b1bdc9e459
md"""

# **Homework 9**: _Climate modeling I_
`18.S191`, fall 2020
"""

# ╔═╡ 23335418-2433-11eb-05e4-2b35dc6cca0e
# edit the code below to set your name and kerberos ID (i.e. email without @mit.edu)

student = (name="Paul Leiby", kerberos_id="pleiby@gmail")

# you might need to wait until all other cells in this notebook have completed running. 
# scroll around the page to see what's up

# ╔═╡ 18be4f7c-2433-11eb-33cb-8d90ca6f124c
md"""

Submission by: **_$(student.name)_** ($(student.kerberos_id)@mit.edu)
"""

# ╔═╡ 253f4da0-2433-11eb-1e48-4906059607d3
md"_Let's create a package environment:_"

# ╔═╡ 87e68a4a-2433-11eb-3e9d-21675850ed71
html"""
<iframe width="100%" height="300" src="https://www.youtube.com/embed/Gi4ZZVS2GLA" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ fe3304f8-2668-11eb-066d-fdacadce5a19
md"""
_Before working on the homework, make sure that you have watched the first lecture on climate modeling 👆. We have included the important functions from this lecture notebook in the next cell. Feel free to have a look!_
"""

# ╔═╡ 1a552400-04dd-4db1-bba3-56ebfe50ec4e
md"""
#### The Energy Balance Model (EBM) yields an ODE for the Rate of Temp Change
$$\frac{dT}{dt} = \frac{1}{C} \left [ \frac{\left( 1-\alpha \right) S}{4} - (A - BT(t)) + a \ln \left( \frac{[\text{CO}₂](t)}{[\text{CO}₂]_{\text{PI}}} \right) \right ].$$  \begin{align}
\text{change in temp} = \frac{1}{C}& \left [ \text{absorbed solar radiation}- \text{outgoing thermal radiation}  \right . 
\newline
& \left . + \text{greenhouse effect} \right ]
\end{align}

for 
- `T` ave Temperature [°C]
- `t` time, [years]
- `C` thermal capacity `C` ~ [(yr/sec) J/m^2/°C], i.e. `1/C` ~ [°C/yr]/[W/m^2] 
- `S` Solar insolation [W/m^2]
- `α` Earth surface albedo (fraction of insolation reflected) [unitless]
- `B` climate feedback parameter: Blackbody re-radiation change with `T`, [W/m^2/°C]. `B<0`
- `A` Blackbody re-radiation at `T = 0` (for `T` in °C) \[W/m^2\] 
- `a` CO2 forcing coefficient: greenhouse thermal capture rate per e-fold increase in CO2 concentration \[W/m^2\]

- ``{[\text{CO}₂]_{\text{PI}}}`` Pre-Industrial CO2 atmospheric concentration [ppm]
"""

# ╔═╡ 522c97e9-3ce7-4eaf-9191-3b090f0d3191
md"#### Equilibrium Temp Change is a Stationary Point $\frac{dT}{dt} = 0$:
$$0 = \frac{1}{C} \left [ \frac{\left( 1-\alpha \right) S}{4} - (A - BT(t)) + a \ln \left( \frac{[\text{CO}₂](t)}{[\text{CO}₂]_{\text{PI}}} \right) \right ].$$
$$T(t) = \frac{A}{B} - \frac{1}{B}\left [ \frac{\left( 1-\alpha \right) S}{4}  + a \ln \left( \frac{[\text{CO}₂](t)}{[\text{CO}₂]_{\text{PI}}} \right) \right ].$$"

# ╔═╡ 405399c0-e71e-4ee9-8306-0cdec4c2643f
md"$$T(t) = \frac{1}{B}\left [A -  \frac{\left( 1-\alpha \right) S}{4}   \right ].$$"

# ╔═╡ a4fab276-36d2-4f14-96b5-9c577da2cb6e
md"""**Aside:
Variation of Absorbed Solar Radiation over surface of Earth**: In terms of the climate Energy Balance Model (`EBM`), and the Absorbed Solar Radiation (`ASR`) component of the equation for rate of temperature change: `ASR = S*(1 - α)/4`, its really cool that we can divide solar insolation S by 4, because surface area of a sphere is $4 \pi r^2$, i.e. 4 times the area of its circular cross-section.  But of course a spinning globe will not distribute the incoming solar power (in W/m^2), which is uniform over the planet's cross section, uniformly over the spherical surface of the earth. Furthermore, there is the issue of axial tilt, or "obliquity", which changes the distribution of insolation over the surface of the earth with season, i.e. angle θ in earths annual orbit around the sun. Maybe they talk about this in the next lectures that focus on spatial effects. 
But I took a quick look at this discussion of the pattern of solar irradiation and its pretty interesting: <https://en.wikipedia.org/wiki/Solar_irradiance#Irradiation_at_the_top_of_the_atmosphere>.
"""


# ╔═╡ ca447661-c8d1-406e-b60a-b20529848343
md"![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/InsolationTopOfAtmosphere.png/660px-InsolationTopOfAtmosphere.png)"

# ╔═╡ f2c3b329-dfc3-4f1a-b80a-2d0d948cb95d
md"""
It involves spherical trig, so My Eyes Glaze Over, but the result is an awsome plot of relative irradiation as a function of time of year (polar angle θ of the Earth's orbit: θ = 0 at the vernal equinox, and θ = 90° at the summer solstice); and φ the latitude on the Earth. 

So, as expected, evenish insolation over the year for equator at latitude 0, max and mins for poles at summer and winter equinox (θ 90 or 270). For average S_0 = 1367 ``W m^{(-2)}``, S_0/4 would be  $(1367/4) ``W m^{(-2)}``, but the plot above shows variation from 0 to 550.
Furthermore, small variations in the earths orbit, over decades and millennia, lead to cycles in Total Solar Irradiation that explain climate cycles."""

# ╔═╡ 3170dc17-6cdd-4e8a-972b-b37213720469
md"""#### `Model` is a module
that includes data, selected functions, 
(`timestep`, `tendency` and `run!`), and the contructors for Energy Balance Models `EBM`.

- `tendency(ebm)` sums the various physical forcing mechanisms determining $\Delta T/\Delta t$.  This is a function of the present temperature $T_{n}$, as well as a number of other parameters.
- `timestep!(ebm)` updates Temperature `T` and time `t`, for an instance of an energy balance model `EBM`.
- `run!(ebm::EBM, end_year::Real)` function runs an `EBM` simulation by timestepping forward until a given `end_year`, storing the results in the `EBM`.
"""

# ╔═╡ 930d7154-1fbf-11eb-1c3a-b1970d291811
"""
	module `Model`

includes data, selected functions, 
(`timestep`, `tendency` and `run!`), and the contructors for Energy Balance Models `EBM`.

- `tendency(ebm)` sums the various physical forcing mechanisms determining `ΔT/Δt`.  This is a function of the present temperature `T_{n}`, as well as a number of other parameters.
- `run!(ebm::EBM, end_year::Real)` function runs an `EBM` simulation by timestepping forward until a given `end_year`, storing the results in the `EBM`.
"""
module Model

const S = 1368 # solar insolation [W/m^2]  (energy per unit time per unit area)
const α = 0.3 # albedo, or planetary reflectivity [unitless]
const B = -1.3 # climate feedback parameter [W/m^2/°C],
const T0 = 14.0 # preindustrial temperature [°C]

"""
	absorbed_solar_radiation(; α=α, S=S)

convert values of other (generally fixed) parameters to ASR
`α` Earth surface albedo (fraction of insolation reflected) [unitless]
`S` Solar insolation [W/m^2]
"""
absorbed_solar_radiation(; α=α, S=S) = S * (1 - α) / 4 # [W/m^2]
outgoing_thermal_radiation(T; A=A, B=B) = A - B * T

const A = S * (1.0 - α) / 4 + B * T0 # [W/m^2].

greenhouse_effect(CO2; a=a, CO2_PI=CO2_PI) = a * log(CO2 / CO2_PI)

const a = 5.0 # CO2 forcing coefficient [W/m^2]
const CO2_PI = 280.0 # preindustrial CO2 concentration [parts per million; ppm];
CO2_const(t) = CO2_PI # constant CO2 concentrations

const C = 51.0 # atmosphere and upper-ocean heat capacity [J/m^2/°C]

"""
	timestep!(ebm)

update Temperature `T`
and time `t`, 
for an instance of an energy balance model `EBM`
"""
function timestep!(ebm)
    append!(ebm.T, ebm.T[end] + ebm.Δt * tendency(ebm))
    append!(ebm.t, ebm.t[end] + ebm.Δt)
end

"""
	`tendency(ebm)`

sum the various physical forcing mechanisms determining ΔT/Δt.
This is a function of the present temperature `T_{n}`, as well as a number of other parameters."
"""
tendency(ebm) = (1.0 / ebm.C) * (
    +absorbed_solar_radiation(α=ebm.α, S=ebm.S)
    -
    outgoing_thermal_radiation(ebm.T[end], A=ebm.A, B=ebm.B)
    +
    greenhouse_effect(ebm.CO2(ebm.t[end]), a=ebm.a, CO2_PI=ebm.CO2_PI)
)

begin
    mutable struct EBM
        T::Array{Float64,1}

        t::Array{Float64,1}
        Δt::Float64

        CO2::Function

        C::Float64
        a::Float64
        A::Float64
        B::Float64
        CO2_PI::Float64

        α::Float64
        S::Float64
    end

    # Make constant parameters optional kwargs
    """
    	EBM(T::Array{Float64, 1}, t::Array{Float64, 1}, Δt::Real, CO2::Function;
    	C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S)

    """
    EBM(T::Array{Float64,1}, t::Array{Float64,1}, Δt::Real, CO2::Function;
        C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S) = (
        EBM(T, t, Δt, CO2, C, a, A, B, CO2_PI, α, S)
    )

    # Construct from (initial) float inputs for convenience
    """
    	T0::Real, t0::Real, Δt::Real, CO2::Function;
    	C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S)

    Construct Temp `T` and time `t arrays from (initial) float inputs for convenience
    """
    EBM(T0::Real, t0::Real, Δt::Real, CO2::Function;
        C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S) = (
        EBM(Float64[T0], Float64[t0], Δt, CO2;
        C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S)
    )
end

begin
    """
    	run!(ebm::EBM, end_year::Real)

    function that runs an `EBM` simulation by timestepping forward
    until a given `end_year`."
    """
    function run!(ebm::EBM, end_year::Real)
        while ebm.t[end] < end_year
            timestep!(ebm)
        end
    end

    run!(ebm) = run!(ebm, 200.0) # run for 200 years by default
end




CO2_hist(t) = CO2_PI * (1 .+ fractional_increase(t))
fractional_increase(t) = ((t .- 1850.0) / 220) .^ 3

begin
    CO2_RCP26(t) = CO2_PI * (1 .+ fractional_increase(t) .* min.(1.0, exp.(-((t .- 1850.0) .- 170) / 100)))
    RCP26 = EBM(T0, 1850.0, 1.0, CO2_RCP26)
    run!(RCP26, 2100.0)

    CO2_RCP85(t) = CO2_PI * (1 .+ fractional_increase(t) .* max.(1.0, exp.(((t .- 1850.0) .- 170) / 100)))
    RCP85 = EBM(T0, 1850.0, 1.0, CO2_RCP85)
    run!(RCP85, 2100.0)
end

end

# ╔═╡ f7fa1f6c-0271-4ca7-bcaa-889de7d98ea3


# ╔═╡ 1312525c-1fc0-11eb-2756-5bc3101d2260
md"""## **Exercise 1** - _policy goals under uncertainty_
A recent ground-breaking [review paper](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019RG000678) produced the most comprehensive and up-to-date estimate of the *climate feedback parameter*, which they find to be

$B \approx \mathcal{N}(-1.3, 0.4),$

i.e. our knowledge of the real value is normally distributed with a mean value $\overline{B} = -1.3$ W/m²/K and a standard deviation $\sigma = 0.4$ W/m²/K. These values are not very intuitive, so let us convert them into more policy-relevant numbers.

**Definition:** *Equilibrium climate sensitivity (ECS)* is defined as the amount of warming $\Delta T$ caused by a doubling of CO₂ (e.g. from the pre-industrial value 280 ppm to 560 ppm), at equilibrium.

At equilibrium, $dT/dt = 0$, and the energy balance model equation is:

$0 = \frac{S(1 - α)}{4} - (A - BT_{eq}) + a \ln\left( \frac{2\;\text{CO}₂_{\text{PI}}}{\text{CO}₂_{\text{PI}}} \right)$

From this, we subtract the preindustrial energy balance, which is given by:

$0 = \frac{S(1-α)}{4} - (A - BT_{0}),$

The result of this subtraction, after rearranging, is our definition of $\text{ECS}$:

$\text{ECS} \equiv T_{eq} - T_{0} = -\frac{a\ln(2)}{B}$
"""

# ╔═╡ 7f961bc0-1fc5-11eb-1f18-612aeff0d8df
md"""The plot below provides an example of an "abrupt 2xCO₂" experiment, a classic experimental treatment method in climate modelling which is used in practice to estimate ECS for a particular model. (Note: in complicated climate models the values of the parameters $a$ and $B$ are not specified *a priori*, but *emerge* as outputs of the simulation.)

The simulation begins at the preindustrial equilibrium, i.e. a temperature $T_{0} = 14$°C is in balance with the pre-industrial CO₂ concentration of 280 ppm until CO₂ is abruptly doubled from 280 ppm to 560 ppm. The climate responds by warming rapidly, and after a few hundred years approaches the equilibrium climate sensitivity value, by definition.
"""

# ╔═╡ fa7e6f7e-2434-11eb-1e61-1b1858bb0988
md"""
``B = `` $(@bind B_slider Slider(-2.5:.001:0; show_value=true, default=-1.3))
"""

# ╔═╡ 16348b6a-1fc2-11eb-0b9c-65df528db2a1
md"""
##### Exercise 1.1 - _Develop understanding for feedbacks and climate sensitivity_
"""

# ╔═╡ e296c6e8-259c-11eb-1385-53f757f4d585
md"""
👉 Change the value of $B$ using the slider above. What does it mean for a climate system to have a more negative value of $B$? Explain why we call $B$ the _climate feedback parameter_.
"""

# ╔═╡ a86f13de-259d-11eb-3f46-1f6fb40020ce
observations_from_changing_B = md"""
Ans: More negative `B` correspond to stronger negative feedback to temperature change,
that is the rate of Earth radiation rises more substantially with temperature `T`.
"""

# ╔═╡ 3d66bd30-259d-11eb-2694-471fb3a4a7be
md"""
👉 What happens when $B$ is greater than or equal to zero?
"""

# ╔═╡ 5f82dec8-259e-11eb-2f4f-4d661f44ef41
observations_from_nonnegative_B = md"""
Ans: `B` greater than or equal to zero means positive feedback, and Earth's re-radiation declines with temperature `T`. So warming inceases without limit.
"""

# ╔═╡ 56b68356-2601-11eb-39a9-5f4b8e580b87
md"Reveal answer: $(@bind reveal_nonnegative_B_answer CheckBox())"

# ╔═╡ 7d815988-1fc7-11eb-322a-4509e7128ce3
if reveal_nonnegative_B_answer
    md"""
   This is known as the "runaway greenhouse effect", where warming self-amplifies so strongly through *positive feedbacks* that the warming continues forever (or until the oceans boil away and there is no longer a reservoir or water to support a *water vapor feedback*. This is thought to explain Venus' extremely hot and hostile climate, but as you can see is extremely unlikely to occur on present-day Earth.
   """
end

# ╔═╡ aed8f00e-266b-11eb-156d-8bb09de0dc2b
md"""
👉 Create a graph to visualize ECS as a function of B. 
"""

# ╔═╡ 275861aa-1573-467a-828a-9c8b4aa9c1a3


# ╔═╡ 269200ec-259f-11eb-353b-0b73523ef71a
md"""
#### Exercise 1.2 - _Doubling CO₂_

To compute ECS, we doubled the CO₂ in our atmosphere. This factor 2 is not entirely arbitrary: without substantial effort to reduce CO₂ emissions, we are expected to **at least** double the CO₂ in our atmosphere by 2100. 

Right now, our CO₂ concentration is 415 ppm -- $(round(415 / 280, digits=3)) times the pre-industrial value of 280 ppm from 1850. 

The CO₂ concentrations in the _future_ depend on human action. There are several models for future concentrations, which are formed by assuming different _policy scenarios_. A baseline model is RCP8.5 - a "worst-case" high-emissions scenario. In our notebook, this model is given as a function of ``t``.
"""

# ╔═╡ 2dfab366-25a1-11eb-15c9-b3dd9cd6b96c
md"""
👉 In what year are we expected to have doubled the CO₂ concentration, under policy scenario RCP8.5?
"""

# ╔═╡ bade1372-25a1-11eb-35f4-4b43d4e8d156
md"""
#### Exercise 1.3 - _Uncertainty in B_

The climate feedback parameter ``B`` is not something that we can control– it is an emergent property of the global climate system. Unfortunately, ``B`` is also difficult to quantify empirically (the relevant processes are difficult or impossible to observe directly), so there remains uncertainty as to its exact value.

A value of ``B`` close to zero means that an increase in CO₂ concentrations will have a larger impact on global warming, and that more action is needed to stay below a maximum temperature. In answering such policy-related question, we need to take the uncertainty in ``B`` into account. In this exercise, we will do so using a Monte Carlo simulation: we generate a sample of values for ``B``, and use these values in our analysis.
"""

# ╔═╡ 02232964-2603-11eb-2c4c-c7b7e5fed7d1
B̅ = -1.3;
σ = 0.4;

# ╔═╡ c4398f9c-1fc4-11eb-0bbb-37f066c6027d
"""
	ECS(; B=B̅, a=Model.a)

*Equilibrium climate sensitivity (`ECS`)* is defined as the 
amount of warming `Delta T` caused by a doubling of CO₂ 
(e.g. from the pre-industrial value 280 ppm to 560 ppm), at equilibrium.
"""
ECS(; B=B̅, a=Model.a) = -a * log(2.0) ./ B;

# ╔═╡ 1d253abf-cbce-464f-a049-ae870f897c5b
"""
	ECS(ρ_CO2 ; B=B̅, a=Model.a)

*Equilibrium climate sensitivity (`ECS`)* is defined as the 
amount of warming `Delta T` caused by a doubling of CO₂ 
(e.g. from the pre-industrial value 280 ppm to 560 ppm), at equilibrium.
"""
ECS(ρ_CO2; B=B̅, a=Model.a) = -a * log(ρ_CO2) ./ B;

# ╔═╡ e5567637-dae7-4493-9f62-f19fcd7ef681
ECS(3)

# ╔═╡ 25f92dec-1fc4-11eb-055d-f34deea81d0e
let
    double_CO2(t) =
        if t >= 0
            2 * Model.CO2_PI
        else
            Model.CO2_PI
        end

    # the definition of A depends on B, so we recalculate:
    A = Model.S * (1.0 - Model.α) / 4 + B_slider * Model.T0
    # create the model
    ebm_ECS = Model.EBM(14.0, -100.0, 1.0, double_CO2, A=A, B=B_slider)
    Model.run!(ebm_ECS, 300)

    ecs = ECS(B=B_slider)

    p = plot(
        size=(500, 250), legend=:bottomright,
        title="Transient response to instant doubling of CO₂",
        ylabel="temperature change [°C]", xlabel="years after doubling",
        ylim=(-0.5, (isfinite(ecs) && ecs < 4) ? 4 : 10),
    )

    plot!(p, [ebm_ECS.t[1], ebm_ECS.t[end]], ecs .* [1, 1],
        ls=:dash, color=:darkred, label="ECS")

    plot!(p, ebm_ECS.t, ebm_ECS.T .- ebm_ECS.T[1],
        label="ΔT(t) = T(t) - T₀")
end |> as_svg

# ╔═╡ 193e9aa6-5319-4e13-a49d-43ba146c25e6
ecs = [ECS(B=b) for b in collect(-2.5:0.1:1.0)]

# ╔═╡ b9f882d8-266b-11eb-2998-75d6539088c7
let
    B_range = collect(-1.0:0.001:1.0)
    ecs = [ECS(B=b) for b in B_range]

    p = plot(
        size=(500, 250), legend=:bottomright,
        title="ECS Variation with Climate Feedback Parameter `B`",
        ylabel="temp change [°C]", xlabel="B [W/m²/K]",
        # ylim=(-100, maximum(ecs)),
    )

    plot!(p, B_range, ecs,
        ls=:dash, color=:darkred, label="ECS")

end |> as_svg

# ╔═╡ 736ed1b6-1fc2-11eb-359e-a1be0a188670
B_samples = let
    B_distribution = Normal(B̅, σ)
    Nsamples = 5000

    samples = rand(B_distribution, Nsamples)
    # we only sample negative values of B
    filter(x -> x < 0, samples)
end

# ╔═╡ 49cb5174-1fc3-11eb-3670-c3868c9b0255
histogram(B_samples, size=(600, 250), label=nothing, xlabel="B [W/m²/K]", ylabel="samples")

# ╔═╡ f3abc83c-1fc7-11eb-1aa8-01ce67c8bdde
md"""
👉 Generate a probability distribution for the ECS based on the probability distribution function for $B$ above. Plot a histogram.
"""

# ╔═╡ 3d72ab3a-2689-11eb-360d-9b3d829b78a9
ECS_samples = ECS.(B=B_samples)

# ╔═╡ b6d7a362-1fc8-11eb-03bc-89464b55c6fc
md"**Answer:**"

# ╔═╡ 6c87ac41-29ba-4ff4-9204-6b7aea7f1ff2
plot(B_samples, ECS_samples, seriestype=:scatter)

# ╔═╡ 1f148d9a-1fc8-11eb-158e-9d784e390b24
histogram(ECS_samples, size=(600, 250), label=nothing, xlabel="ΔT [K]", xlim=(0, 20), ylabel="samples")

# ╔═╡ cf8dca6c-1fc8-11eb-1f89-099e6ba53c22
md"It looks like the ECS distribution is **not normally distributed**, even though $B$ is. 

👉 How does $\overline{\text{ECS}(B)}$ compare to $\text{ECS}(\overline{B})$? What is the probability that $\text{ECS}(B)$ lies above $\text{ECS}(\overline{B})$?
"

# ╔═╡ e6a381c2-d0a1-4b5f-ba47-613d25951ac0
meanECS = trunc(mean(ECS_samples), digits=3)

# ╔═╡ dd398aaa-d960-4dd7-9eb9-90681d28deb8
ECSatmean = trunc(ECS(B=mean(B_samples)), digits=3)

# ╔═╡ 21c4ce27-2307-4df0-a1f9-115be566fa8a
md"**Question/Note:** The following shows the problems of the markdown parser, 
confusing interpolation with equation demarked by $. A key seems to be the numbber of dollar-signs for interpolation and the spacing around dollar-signs when used for interpolation."

# ╔═╡ 02173c7a-2695-11eb-251c-65efb5b4a45f
md"""
The mean of `ECS(B)` is ( $(trunc(mean(ECS_samples), digits=3)) ), 
while the value opf `ECS` at the mean `B` ($(trunc(mean(B_samples), digits=3)) ), is  """

# ╔═╡ 017b5a2d-45df-4a38-9102-d92798bf6dfd
md"""The mean of `ECS(B)` is $(meanECS),
while the value of `ECS` at the mean `B` ( $(trunc(mean(B_samples), digits=3)) ), is $(ECSatmean).
"""


# ╔═╡ 440271b6-25e8-11eb-26ce-1b80aa176aca
md"👉 Does accounting for uncertainty in feedbacks make our expectation of global warming better (less implied warming) or worse (more implied warming)?"

# ╔═╡ 74ec5163-363a-4aa8-a0d8-519cb0626ddb


# ╔═╡ c893d838-dfda-407b-97b0-e33daba2543a
# E ∘ ECS (\tilde B) ≠ ECS ∘ E (\tilde B) # is this meant to be executable?

# ╔═╡ cf276892-25e7-11eb-38f0-03f75c90dd9e
observations_from_the_order_of_averaging = md"""
Accounting for the uncertainty regarding the climate feedback parameter `B` makes our expectations (concerns) regarding potential warming worse, because of the nonlinearity (convexity) of adverse consequences in our uncertain parameters. Specifically, the convexity of `ECS(B)` in `B` means that uncertainty in B creates a higher mean $\Delta T$ than we would estimate from the mean $\bar B = E[\tilde B]$. Given convexity of `ECS`:

$$E[ECS(\tilde B)] \ge ECS(E[\tilde B])$$

This is a example of _Jensens Inequality_.
"""

# ╔═╡ 7df3548d-e909-4b13-a858-2223cc0e458b
md"""See [Jensens Inequality](https://en.wikipedia.org/wiki/Jensen%27s_inequality): 

> In its simplest form the inequality states that the convex transformation of a mean is less than or equal to the mean applied after convex transformation; it is a simple corollary that the opposite is true of concave transformations.
"""

# ╔═╡ 5b5f25f0-266c-11eb-25d4-17e411c850c9
md"""
#### Exercise 1.5 - _Running the model_

In the lecture notebook we introduced a _mutable struct_ `EBM` (_energy balance model_), which contains:
- the parameters of our climate simulation (`C`, `a`, `A`, `B`, `CO2_PI`, `α`, `S`, see details below)
- a function `CO2`, which maps a time `t` to the concentrations at that year. For example, we use the function `t -> 280` to simulate a model with concentrations fixed at 280 ppm.

`EBM` also contains the simulation results, in two arrays:
- `T` is the array of tempartures (°C, `Float64`).
- `t` is the array of timestamps (years, `Float64`), of the same size as `T`.
"""

# ╔═╡ 3f823490-266d-11eb-1ba4-d5a23975c335
html"""
<style>
.hello td {
	font-family: sans-serif; font-size: .8em;
	max-width: 300px
}

soft {
	opacity: .5;
}
</style>


<p>Properties of an <code>EBM</code> obect:</p>
<table class="hello">
<thead>

<tr><th>Name</th><th>Description</th></tr>
</thead>
<tbody>
<tr><th><code>A</code></th><td>Linearized outgoing thermal radiation: offset <soft>[W/m²]</soft></td></tr>
<tr><th><code>B</code></th><td>Linearized outgoing thermal radiation: slope. <em>or: </em><b>climate feedback parameter</b> <soft>[W/m²/°C]</soft></td></tr>
<tr><th><code>α</code></th><td>Planet albedo, 0.0-1.0 <soft>[unitless]</soft></td></tr>
<tr><th><code>S</code></th><td>Solar insulation <soft>[W/m²]</soft></td></tr>
<tr><th><code>C</code></th><td>Atmosphere and upper-ocean heat capacity <soft>[J/m²/°C]</soft></td></tr>
<tr><th><code>a</code></th><td>CO₂ forcing effect <soft>[W/m²]</soft></td></tr>
<tr><th><code>CO2_PI</code></th><td>Pre-industrial CO₂ concentration <soft>[ppm]</soft></td></tr>
</tbody>
</table>

"""

# ╔═╡ 971f401e-266c-11eb-3104-171ae299ef70
md"""

You can set up an instance of `EBM` like so, referencing the `EBM` structure in the module `Model`:
"""

# ╔═╡ 746aa5bc-266c-11eb-14c9-63ccc313f5de
empty_ebm = Model.EBM(
    14.0, # initial temperature
    1850, # initial year
    1, # Δt
    t -> 280.0, # CO2 function
)

# ╔═╡ 03b4f012-1702-4650-ba57-7068404dc374
md"Note that unspecified `EBM` parameters are taken from the global scope, 
in this case the module enclosing the definition of `EBM`."

# ╔═╡ a919d584-2670-11eb-1cf9-2327c8135d6d
md"""
Have look inside this object. We see that `T` and `t` are initialized to a 1-element array.

Let's run our model:
"""

# ╔═╡ bfb07a0a-2670-11eb-3938-772499c637b1
simulated_model = let
    ebm = Model.EBM(14.0, 1850, 1, t -> 280.0)
    Model.run!(ebm, 2020)
    ebm
end

# ╔═╡ 12cbbab0-2671-11eb-2b1f-038c206e84ce
md"""
Again, look inside `simulated_model` and notice that `T` and `t` have accumulated the simulation results.

In this simulation, we used `T0 = 14` and `CO2 = t -> 280`, which is why `T` is constant during our simulation. These parameters are the default, pre-industrial values, and our model is based on this equilibrium.

👉 Run a simulation with policy scenario RCP8.5, and plot the computed temperature graph. What is the global temperature at 2100?
"""

# ╔═╡ e174fa1b-239b-460e-a9d4-e136b5e2f724
round(pi; digits=5)

# ╔═╡ 9596c2dc-2671-11eb-36b9-c1af7e5f1089
simulated_rcp85_model = let
    ebm = Model.EBM(14.0, 1850, 1, Model.CO2_RCP85)
    Model.run!(ebm, 2150)

    t_index = t -> Int64(t - ebm.t[1] + 1) # map t to index?
    T_2100 = round(ebm.T[t_index(2100)]; digits=2)

    p = plot(ebm.t, ebm.T)
    plot!(p,
        xlabel="year",
        ylabel="Global temperature T [°C]",
        title="Earth's Temperature (CO2_RCP85 case)",
        legend=:topleft
    )

    plot!(p, 2100 .* [1, 1], [ebm.T[1], ebm.T[end]],
        # plot!(p, 2100 , [ebm.T[1], ebm.T[end]],  # v. bad result
        ls=:dash, color=:darkred, label="T_2100 = $T_2100")

end

# ╔═╡ 4b091fac-2672-11eb-0db8-75457788d85e
md"""
Additional parameters can be set using keyword arguments. For example:

```julia
Model.EBM(14, 1850, 1, t -> 280.0; B=-2.0)
```
Creates the same model as before, but with `B = -2.0`.
"""

# ╔═╡ 9cdc5f84-2671-11eb-3c78-e3495bc64d33
md"""
👉 Write a function `temperature_response` that takes a function `CO2` and an optional value `B` as parameters, and returns the temperature at 2100 according to our model.
"""

# ╔═╡ f688f9f2-2671-11eb-1d71-a57c9817433f
function temperature_response(CO2::Function, B::Float64=-1.3)
    ebm = Model.EBM(14, 1980, 1, CO2; B=B)

    Model.run!(ebm, 2100)
    # findfirst(t .== 2100)
    return ebm.T[end]
end

# ╔═╡ 049a866e-2672-11eb-29f7-bfea7ad8f572
temperature_response(t -> 280)

# ╔═╡ 09901de6-2672-11eb-3d50-05b176b729e7
temperature_response(Model.CO2_RCP85)

# ╔═╡ aea0d0b4-2672-11eb-231e-395c863827d3
temperature_response(Model.CO2_RCP85, -1.0)

# ╔═╡ 9c32db5c-1fc9-11eb-029a-d5d554de1067
md"""#### Exercise 1.6 - _Application to policy relevant questions_

We talked about two _emissions scenarios_: RCP2.6 (strong mitigation - controlled CO2 concentrations) and RCP8.5 (no mitigation - high CO2 concentrations). These are given by the following functions:
"""

# ╔═╡ ee1be5dc-252b-11eb-0865-291aa823b9e9
t = 1850:2100

# ╔═╡ e10a9b70-25a0-11eb-2aed-17ed8221c208
plot(t, Model.CO2_RCP85.(t),
    ylim=(0, 1200), ylabel="CO2 concentration [ppm]")

# ╔═╡ 08f440de-9b02-49e3-ae06-be0fa0c68670
t

# ╔═╡ 26d51210-74a6-44b3-9864-d0d2b7984308
frac_CO2_increase = Model.CO2_RCP85.(t) / Model.CO2_RCP85(first(t))

# ╔═╡ 50ea30ba-25a1-11eb-05d8-b3d579f85652
expected_double_CO2_year = let
    frac_CO2_increase = Model.CO2_RCP85.(t) / Model.CO2_RCP85(first(t))
    base_CO2 = Model.CO2_RCP85(0)
    y = missing
    for i in 1:length(frac_CO2_increase)
        if frac_CO2_increase[i] > 2.0
            y = t[i]
            break
        end
    end
    y
end

# ╔═╡ 354a9f46-adec-4709-aece-7adbf2018bd8
t[findfirst(Model.CO2_RCP85.(t) / Model.CO2_RCP85(first(t)) .> 2.0)]

# ╔═╡ 40f1e7d8-252d-11eb-0549-49ca4e806e16
@bind t_scenario_test Slider(t; show_value=true, default=1850)

# ╔═╡ 19957754-252d-11eb-1e0a-930b5208f5ac
Model.CO2_RCP26(t_scenario_test), Model.CO2_RCP85(t_scenario_test)

# ╔═╡ 06c5139e-252d-11eb-2645-8b324b24c405
md"""
We are interested in how the **uncertainty in our input** $B$ (the climate feedback paramter) *propagates* through our model to determine the **uncertainty in our output** $T(t)$, for a given emissions scenario. The goal of this exercise is to answer the following by using *Monte Carlo Simulation* for *uncertainty propagation*:

> 👉 What is the probability that we see more than 2°C of warming by 2100 under the low-emissions scenario RCP2.6? What about under the high-emissions scenario RCP8.5?

"""

# ╔═╡ eb1c639d-01eb-498e-baef-7dc06aa8dac7
length(B_samples)

# ╔═╡ f2e55166-25ff-11eb-0297-796e97c62b07
T_RCP26_samples = temperature_response.(Model.CO2_RCP26, B_samples)

# ╔═╡ 490bf73b-aa80-44a9-b747-a9119c154b66
"""
	probExceed(xlim, A)

probability that elements of A equal or exceed `xlim`
"""
function probExceed(xlim, A)
    length(filter(x -> x >= xlim, A)) / length(A)
end

# ╔═╡ b9dde842-da18-4033-9dcf-a3fa748dc265
md"Consider the probability of more than 2 degrees warming from Pre-Industrial level (`T0`):"

# ╔═╡ a6e506cf-539b-4c95-92fa-0fbabeef1f1b
round(probExceed(14 + 2.0, T_RCP26_samples); digits=4)

# ╔═╡ a58ca9e2-883b-4136-ba57-fc87a0db9549
round(probExceed(14 + 2.0,
        temperature_response.(Model.CO2_RCP85, B_samples));
    digits=4)

# ╔═╡ 1ea81214-1fca-11eb-2442-7b0b448b49d6
md"""
## **Exercise 2** - _How did Snowball Earth melt?_

In lecture 21 (see below), we discovered that increases in the brightness of the Sun are not sufficient to explain how Snowball Earth eventually melted.
"""

# ╔═╡ a0ef04b0-25e9-11eb-1110-cde93601f712
html"""
<iframe width="100%" height="300" src="https://www.youtube-nocookie.com/embed/Y68tnH0FIzc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ 3e310cf8-25ec-11eb-07da-cb4a2c71ae34
md"""
We talked about a second theory -- a large increase in CO₂ (by volcanoes) could have caused a strong enough greenhouse effect to melt the Snowball. If we imagine that the CO₂ then decreased (e.g. by getting sequestered by the now liquid ocean), we might be able to explain how we transitioned from a hostile Snowball Earth to today's habitable "Waterball" Earth.

In this exercise, you will estimate how much CO₂ would be needed to melt the Snowball and visualize a possible trajectory for Earth's climate over the past 700 million years by making an interactive *bifurcation diagram*.

#### Exercise 2.1

In the [lecture notebook](https://github.com/hdrake/simplEarth/blob/master/2_ebm_multiple_equilibria.jl) (video above), we had a bifurcation diagram of $S$ (solar insolation) vs $T$ (temperature). We increased $S$, watched our point move right in the diagram until we found the tipping point. This time we will do the same, but we vary the CO₂ concentration, and keep $S$ fixed at its default (present day) value.
"""

# ╔═╡ d6d1b312-2543-11eb-1cb2-e5b801686ffb
md"""
Below we have an empty diagram, which is already set up with a CO₂ vs $T$ diagram, with a logirthmic horizontal axis. Now it's your turn! We have written some pointers below to help you, but feel free to do it your own way.
"""

# ╔═╡ 3cbc95ba-2685-11eb-3810-3bf38aa33231
md"""
We used two helper functions:
"""

# ╔═╡ 68b2a560-2536-11eb-0cc4-27793b4d6a70
function add_cold_hot_areas!(p)

    left, right = xlims(p)

    plot!(p,
        [left, right], [-60, -60],
        fillrange=[-10.0, -10.0], fillalpha=0.3, c=:lightblue, label=nothing
    )
    annotate!(p,
        left + 12, -19,
        text("completely\nfrozen", 10, :darkblue, :left)
    )

    plot!(p,
        [left, right], [10, 10],
        fillrange=[80.0, 80.0], fillalpha=0.09, c=:red, lw=0.0, label=nothing
    )
    annotate!(p,
        left + 12, 15,
        text("no ice", 10, :darkred, :left)
    )
end

# ╔═╡ 0e19f82e-2685-11eb-2e99-0d094c1aa520
function add_reference_points!(p)
    plot!(p,
        [Model.CO2_PI, Model.CO2_PI], [-55, 75],
        color=:grey, alpha=0.3, lw=8,
        label="Pre-industrial CO2"
    )
    plot!(p,
        [Model.CO2_PI], [Model.T0],
        shape=:circle, color=:orange, markersize=8,
        label="Our preindustrial climate"
    )
    plot!(p,
        [Model.CO2_PI], [-38.3],
        shape=:circle, color=:aqua, markersize=8,
        label="Alternate preindustrial climate"
    )
end

# ╔═╡ 1eabe908-268b-11eb-329b-b35160ec951e
md"""
👉 Create a slider for `CO2` between `CO2min` and `CO2max`. Just like the horizontal axis of our plot, we want the slider to be _logarithmic_. 
"""

# ╔═╡ 4c9173ac-2685-11eb-2129-99071821ebeb
md"""
👉 Write a function `step_model!` that takes an existing `ebm` and `new_CO2`, which performs a step of our interactive process:
- Reset the model by setting the `ebm.t` and `ebm.T` arrays to a single element. _Which value?_
- Assign a new function to `ebm.CO2`. _What function?_
- Run the model.
"""

# ╔═╡ 736515ba-2685-11eb-38cb-65bfcf8d1b8d
function step_model!(ebm::Model.EBM, new_CO2::Real)

    # your code here
    ebm.t = [0.0]
    ebm.T = [ebm.T[end]]
    ebm.CO2 = t -> new_CO2

    Model.run!(ebm, 200)

    return ebm
end

# ╔═╡ 8b06b944-268c-11eb-0bfc-8d4dd21e1f02
md"""
👉 Inside the plot cell, call the function `step_model!`.
"""

# ╔═╡ 09ce27ca-268c-11eb-0cdd-c9801db876f8
md"""
##### Parameters
"""

# ╔═╡ 298deff4-2676-11eb-2595-e7e22f613ea1
CO2min = 10

# ╔═╡ 2bbf5a70-2676-11eb-1085-7130d4a30443
CO2max = 1_000_000

# ╔═╡ 52fd9868-2edb-40f5-ace0-89cb8a07777f
@bind log10_CO2 Slider(log10(CO2min):0.1:log10(CO2max); show_value=true, default=1)

# ╔═╡ 6de783ed-9245-4be7-ac42-d83ae37c9714
CO2 = 10^log10_CO2

# ╔═╡ 0495f43d-d780-4e4e-b6f7-862c32d5835b
log10(CO2max)

# ╔═╡ de95efae-2675-11eb-0909-73afcd68fd42
Tneo = -48

# ╔═╡ 06d28052-2531-11eb-39e2-e9613ab0401c
ebm = Model.EBM(Tneo, 0.0, 5.0, Model.CO2_const)

# ╔═╡ bf5b6397-173b-49c5-b86f-8cf2326b5d61
ebm.A

# ╔═╡ ef5439fd-60b1-4b06-bb0a-18d3b5e71330
(1 - ebm.α) * ebm.S / 4

# ╔═╡ c4b6e445-b121-4720-9928-42d7bdcc5960
# Net heat coming in at CO2_PI, T= 0
(1 - ebm.α) * ebm.S / 4 - ebm.A

# ╔═╡ 378aed18-252b-11eb-0b37-a3b511af2cb5
let
    step_model!(ebm, CO2)

    p = plot(
        xlims=(CO2min, CO2max), ylims=(-55, 75),
        xaxis=:log,
        xlabel="CO2 concentration [ppm]",
        ylabel="Global temperature T [°C]",
        title="Earth's CO2 concentration bifurcation diagram",
        legend=:topleft
    )

    add_cold_hot_areas!(p)
    add_reference_points!(p)

    # your code here 

    plot!(p,
        [ebm.CO2(ebm.t[end])], [ebm.T[end]],
        label=nothing,
        color=:black,
        shape=:circle,
    )


end |> as_svg

# ╔═╡ c78e02b4-268a-11eb-0af7-f7c7620fcc34
md"""
The albedo feedback is implemented by the methods below:
"""

# ╔═╡ d7801e88-2530-11eb-0b93-6f1c78d00eea
function α(T; α0=Model.α, αi=0.5, ΔT=10.0)
    if T < -ΔT
        return αi
    elseif -ΔT <= T < ΔT
        return αi + (α0 - αi) * (T + ΔT) / (2ΔT)
    elseif T >= ΔT
        return α0
    end
end

# ╔═╡ 607058ec-253c-11eb-0fb6-add8cfb73a4f
function Model.timestep!(ebm)
    ebm.α = α(ebm.T[end]) # Added this line
    append!(ebm.T, ebm.T[end] + ebm.Δt * Model.tendency(ebm))
    append!(ebm.t, ebm.t[end] + ebm.Δt)
end

# ╔═╡ 9c1f73e0-268a-11eb-2bf1-216a5d869568
md"""
If you like, make the visualization more informative! Like in the lecture notebook, you could add a trail behind the black dot, or you could plot the stable and unstable branches. It's up to you! 
"""

# ╔═╡ 11096250-2544-11eb-057b-d7112f20b05c
md"""
#### Exercise 2.2

👉 Find the **lowest CO₂ concentration** necessary to melt the Snowball, programatically.
"""

# ╔═╡ 406d5ce1-c2b3-436d-ae49-1ecd0cdaec69
Tneo

# ╔═╡ 9eb07a6e-2687-11eb-0de3-7bc6aa0eefb0
co2_to_melt_snowball = let
    ΔT = 10.0 # assumed threshold temp below freezing to begin some melt
    test_CO2 = 10 # very low ppm

    # start a model, very cold, year 0, Δt 5, very low CO2
    ebm_alt = Model.EBM(Tneo, 0.0, 5.0, x -> test_CO2)
    Model.run!(ebm_alt)# solve for default num years

    while ebm_alt.T[end] <= -ΔT # final Temp, degrees C still below iceball temp?
        if ebm_alt.T[end] <= -(ΔT + 2)
            test_CO2 = test_CO2 * 1.5 # doubling may be too big a step
        else
            test_CO2 = test_CO2 * 1.1 # smaller step, getting close
        end
        step_model!(ebm_alt, test_CO2)
    end
    test_CO2
end

# ╔═╡ 3a35598a-2527-11eb-37e5-3b3e4c63c4f7
md"""
## **Exercise XX:** _Lecture transcript_
_(MIT students only)_

Please see the link for hw 9 transcript document on [Canvas](https://canvas.mit.edu/courses/5637).
We want each of you to correct about 500 lines, but don’t spend more than 20 minutes on it.
See the the beginning of the document for more instructions.
:point_right: Please mention the name of the video(s) and the line ranges you edited:
"""

# ╔═╡ 5041cdee-2527-11eb-154f-0b0c68e11fe3
lines_i_edited = md"""
Abstraction, lines 1-219; Array Basics, lines 1-137; Course Intro, lines 1-144 (_for example_)
"""

# ╔═╡ 36e2dfea-2433-11eb-1c90-bb93ab25b33c
if student.name == "Jazzy Doe" || student.kerberos_id == "jazz"
    md"""
    !!! danger "Before you submit"
        Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
    """
end

# ╔═╡ 36ea4410-2433-11eb-1d98-ab4016245d95
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 36f8c1e8-2433-11eb-1f6e-69dc552a4a07
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 51e2e742-25a1-11eb-2511-ab3434eacc3e
hint(md"The function `findfirst` might be helpful.")

# ╔═╡ 53c2eaf6-268b-11eb-0899-b91c03713da4
hint(md"
```julia
@bind log_CO2 Slider(❓)
```

```julia
CO2 = 10^log_CO2
```

")

# ╔═╡ cb15cd88-25ed-11eb-2be4-f31500a726c8
hint(md"Use a condition on the albedo or temperature to check whether the Snowball has melted.")

# ╔═╡ 232b9bec-2544-11eb-0401-97a60bb172fc
hint(md"Start by writing a function `equilibrium_temperature(CO2)` which creates a new `EBM` at the Snowball Earth temperature T = $(Tneo) and returns the final temperature for a given CO2 level.")

# ╔═╡ 37061f1e-2433-11eb-3879-2d31dc70a771
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 371352ec-2433-11eb-153d-379afa8ed15e
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 372002e4-2433-11eb-0b25-39ce1b1dd3d1
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 372c1480-2433-11eb-3c4e-95a37d51835f
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 3737be8e-2433-11eb-2049-2d6d8a5e4753
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 374522c4-2433-11eb-3da3-17419949defc
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 37552044-2433-11eb-1984-d16e355a7c10
TODO = html"<span style='display: inline; font-size: 2em; color: purple; font-weight: 900;'>TODO</span>"

# ╔═╡ Cell order:
# ╟─169727be-2433-11eb-07ae-ab7976b5be90
# ╟─18be4f7c-2433-11eb-33cb-8d90ca6f124c
# ╟─21524c08-2433-11eb-0c55-47b1bdc9e459
# ╠═23335418-2433-11eb-05e4-2b35dc6cca0e
# ╟─253f4da0-2433-11eb-1e48-4906059607d3
# ╠═1e06178a-1fbf-11eb-32b3-61769a79b7c0
# ╟─87e68a4a-2433-11eb-3e9d-21675850ed71
# ╟─fe3304f8-2668-11eb-066d-fdacadce5a19
# ╟─1a552400-04dd-4db1-bba3-56ebfe50ec4e
# ╠═522c97e9-3ce7-4eaf-9191-3b090f0d3191
# ╠═405399c0-e71e-4ee9-8306-0cdec4c2643f
# ╠═bf5b6397-173b-49c5-b86f-8cf2326b5d61
# ╠═ef5439fd-60b1-4b06-bb0a-18d3b5e71330
# ╠═c4b6e445-b121-4720-9928-42d7bdcc5960
# ╟─a4fab276-36d2-4f14-96b5-9c577da2cb6e
# ╟─ca447661-c8d1-406e-b60a-b20529848343
# ╟─f2c3b329-dfc3-4f1a-b80a-2d0d948cb95d
# ╟─3170dc17-6cdd-4e8a-972b-b37213720469
# ╠═930d7154-1fbf-11eb-1c3a-b1970d291811
# ╠═f7fa1f6c-0271-4ca7-bcaa-889de7d98ea3
# ╟─1312525c-1fc0-11eb-2756-5bc3101d2260
# ╠═c4398f9c-1fc4-11eb-0bbb-37f066c6027d
# ╠═1d253abf-cbce-464f-a049-ae870f897c5b
# ╠═e5567637-dae7-4493-9f62-f19fcd7ef681
# ╟─7f961bc0-1fc5-11eb-1f18-612aeff0d8df
# ╠═25f92dec-1fc4-11eb-055d-f34deea81d0e
# ╟─fa7e6f7e-2434-11eb-1e61-1b1858bb0988
# ╟─16348b6a-1fc2-11eb-0b9c-65df528db2a1
# ╟─e296c6e8-259c-11eb-1385-53f757f4d585
# ╟─a86f13de-259d-11eb-3f46-1f6fb40020ce
# ╟─3d66bd30-259d-11eb-2694-471fb3a4a7be
# ╟─5f82dec8-259e-11eb-2f4f-4d661f44ef41
# ╟─56b68356-2601-11eb-39a9-5f4b8e580b87
# ╟─7d815988-1fc7-11eb-322a-4509e7128ce3
# ╟─aed8f00e-266b-11eb-156d-8bb09de0dc2b
# ╠═193e9aa6-5319-4e13-a49d-43ba146c25e6
# ╠═b9f882d8-266b-11eb-2998-75d6539088c7
# ╠═275861aa-1573-467a-828a-9c8b4aa9c1a3
# ╟─269200ec-259f-11eb-353b-0b73523ef71a
# ╠═e10a9b70-25a0-11eb-2aed-17ed8221c208
# ╠═08f440de-9b02-49e3-ae06-be0fa0c68670
# ╟─2dfab366-25a1-11eb-15c9-b3dd9cd6b96c
# ╠═26d51210-74a6-44b3-9864-d0d2b7984308
# ╠═50ea30ba-25a1-11eb-05d8-b3d579f85652
# ╠═354a9f46-adec-4709-aece-7adbf2018bd8
# ╟─51e2e742-25a1-11eb-2511-ab3434eacc3e
# ╟─bade1372-25a1-11eb-35f4-4b43d4e8d156
# ╠═02232964-2603-11eb-2c4c-c7b7e5fed7d1
# ╠═736ed1b6-1fc2-11eb-359e-a1be0a188670
# ╠═49cb5174-1fc3-11eb-3670-c3868c9b0255
# ╟─f3abc83c-1fc7-11eb-1aa8-01ce67c8bdde
# ╠═3d72ab3a-2689-11eb-360d-9b3d829b78a9
# ╟─b6d7a362-1fc8-11eb-03bc-89464b55c6fc
# ╠═6c87ac41-29ba-4ff4-9204-6b7aea7f1ff2
# ╠═1f148d9a-1fc8-11eb-158e-9d784e390b24
# ╟─cf8dca6c-1fc8-11eb-1f89-099e6ba53c22
# ╠═e6a381c2-d0a1-4b5f-ba47-613d25951ac0
# ╠═dd398aaa-d960-4dd7-9eb9-90681d28deb8
# ╠═21c4ce27-2307-4df0-a1f9-115be566fa8a
# ╠═02173c7a-2695-11eb-251c-65efb5b4a45f
# ╠═017b5a2d-45df-4a38-9102-d92798bf6dfd
# ╟─440271b6-25e8-11eb-26ce-1b80aa176aca
# ╠═74ec5163-363a-4aa8-a0d8-519cb0626ddb
# ╠═c893d838-dfda-407b-97b0-e33daba2543a
# ╟─cf276892-25e7-11eb-38f0-03f75c90dd9e
# ╟─7df3548d-e909-4b13-a858-2223cc0e458b
# ╟─5b5f25f0-266c-11eb-25d4-17e411c850c9
# ╟─3f823490-266d-11eb-1ba4-d5a23975c335
# ╟─971f401e-266c-11eb-3104-171ae299ef70
# ╠═746aa5bc-266c-11eb-14c9-63ccc313f5de
# ╟─03b4f012-1702-4650-ba57-7068404dc374
# ╟─a919d584-2670-11eb-1cf9-2327c8135d6d
# ╠═bfb07a0a-2670-11eb-3938-772499c637b1
# ╟─12cbbab0-2671-11eb-2b1f-038c206e84ce
# ╠═e174fa1b-239b-460e-a9d4-e136b5e2f724
# ╠═9596c2dc-2671-11eb-36b9-c1af7e5f1089
# ╟─4b091fac-2672-11eb-0db8-75457788d85e
# ╟─9cdc5f84-2671-11eb-3c78-e3495bc64d33
# ╠═f688f9f2-2671-11eb-1d71-a57c9817433f
# ╠═049a866e-2672-11eb-29f7-bfea7ad8f572
# ╠═09901de6-2672-11eb-3d50-05b176b729e7
# ╠═aea0d0b4-2672-11eb-231e-395c863827d3
# ╟─9c32db5c-1fc9-11eb-029a-d5d554de1067
# ╠═19957754-252d-11eb-1e0a-930b5208f5ac
# ╠═40f1e7d8-252d-11eb-0549-49ca4e806e16
# ╟─ee1be5dc-252b-11eb-0865-291aa823b9e9
# ╟─06c5139e-252d-11eb-2645-8b324b24c405
# ╠═eb1c639d-01eb-498e-baef-7dc06aa8dac7
# ╠═f2e55166-25ff-11eb-0297-796e97c62b07
# ╠═490bf73b-aa80-44a9-b747-a9119c154b66
# ╟─b9dde842-da18-4033-9dcf-a3fa748dc265
# ╠═a6e506cf-539b-4c95-92fa-0fbabeef1f1b
# ╠═a58ca9e2-883b-4136-ba57-fc87a0db9549
# ╟─1ea81214-1fca-11eb-2442-7b0b448b49d6
# ╟─a0ef04b0-25e9-11eb-1110-cde93601f712
# ╟─3e310cf8-25ec-11eb-07da-cb4a2c71ae34
# ╟─d6d1b312-2543-11eb-1cb2-e5b801686ffb
# ╠═378aed18-252b-11eb-0b37-a3b511af2cb5
# ╠═52fd9868-2edb-40f5-ace0-89cb8a07777f
# ╠═6de783ed-9245-4be7-ac42-d83ae37c9714
# ╟─3cbc95ba-2685-11eb-3810-3bf38aa33231
# ╟─68b2a560-2536-11eb-0cc4-27793b4d6a70
# ╟─0e19f82e-2685-11eb-2e99-0d094c1aa520
# ╟─1eabe908-268b-11eb-329b-b35160ec951e
# ╠═0495f43d-d780-4e4e-b6f7-862c32d5835b
# ╟─53c2eaf6-268b-11eb-0899-b91c03713da4
# ╠═06d28052-2531-11eb-39e2-e9613ab0401c
# ╟─4c9173ac-2685-11eb-2129-99071821ebeb
# ╠═736515ba-2685-11eb-38cb-65bfcf8d1b8d
# ╟─8b06b944-268c-11eb-0bfc-8d4dd21e1f02
# ╟─09ce27ca-268c-11eb-0cdd-c9801db876f8
# ╟─298deff4-2676-11eb-2595-e7e22f613ea1
# ╟─2bbf5a70-2676-11eb-1085-7130d4a30443
# ╟─de95efae-2675-11eb-0909-73afcd68fd42
# ╟─c78e02b4-268a-11eb-0af7-f7c7620fcc34
# ╠═d7801e88-2530-11eb-0b93-6f1c78d00eea
# ╠═607058ec-253c-11eb-0fb6-add8cfb73a4f
# ╟─9c1f73e0-268a-11eb-2bf1-216a5d869568
# ╟─11096250-2544-11eb-057b-d7112f20b05c
# ╠═406d5ce1-c2b3-436d-ae49-1ecd0cdaec69
# ╠═9eb07a6e-2687-11eb-0de3-7bc6aa0eefb0
# ╟─cb15cd88-25ed-11eb-2be4-f31500a726c8
# ╟─232b9bec-2544-11eb-0401-97a60bb172fc
# ╟─3a35598a-2527-11eb-37e5-3b3e4c63c4f7
# ╠═5041cdee-2527-11eb-154f-0b0c68e11fe3
# ╟─36e2dfea-2433-11eb-1c90-bb93ab25b33c
# ╟─36ea4410-2433-11eb-1d98-ab4016245d95
# ╟─36f8c1e8-2433-11eb-1f6e-69dc552a4a07
# ╟─37061f1e-2433-11eb-3879-2d31dc70a771
# ╟─371352ec-2433-11eb-153d-379afa8ed15e
# ╟─372002e4-2433-11eb-0b25-39ce1b1dd3d1
# ╟─372c1480-2433-11eb-3c4e-95a37d51835f
# ╟─3737be8e-2433-11eb-2049-2d6d8a5e4753
# ╟─374522c4-2433-11eb-3da3-17419949defc
# ╟─37552044-2433-11eb-1984-d16e355a7c10
