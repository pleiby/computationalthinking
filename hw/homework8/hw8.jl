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

# ╔═╡ c3e52bf2-ca9a-11ea-13aa-03a4335f2906
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="Plots", version="1.6-1"),
        Pkg.PackageSpec(name="PlutoUI", version="0.6.8-0.6"),
        Pkg.PackageSpec(name="ImageMagick"),
        Pkg.PackageSpec(name="Images", version="0.23"),
    ])
    using Plots
    using PlutoUI
    using LinearAlgebra
    using Images
end

# ╔═╡ 1df32310-19c4-11eb-0824-6766cd21aaf4
md"_homework 8, version 1_"

# ╔═╡ 1e109620-19c4-11eb-013e-1bc95c14c2ba
md"""

# **Bonus homework 8**: _Raytracing in 3D_
`18.S191`, fall 2020

This week we will recreate the 3D raytracer from the lectures, building on what we wrote for the 2D case. Compared to the past weeks, you will notice that this homework is a little different! We have included fewer intermediate checks, it is up to you to decide how you:
- split up the problem is smaller functions
- check and visualize your progress

To guide you through the homework, you can follow along with this week's live coding session. Feel free to stay close to James's code, or to come up with your own solution.

With the raytracer done, we will be able to recreate an artwork by M.C. Escher, scroll down to have a sneak peek!

---

_For MIT students:_ this homework is **optional**.

Feel free to ask questions!
"""

# ╔═╡ 1e202680-19c4-11eb-29a7-99061b886b3c
# edit the code below to set your name and kerberos ID (i.e. email without @mit.edu)

student = (name="Paul Leiby", kerberos_id="pleiby@gmail")

# you might need to wait until all other cells in this notebook have completed running. 
# scroll around the page to see what's up

# ╔═╡ 1df82c20-19c4-11eb-0959-8543a0d5630d
md"""

Submission by: **_$(student.name)_** ($(student.kerberos_id)@mit.edu)
"""

# ╔═╡ e4d2f6f6-2089-11eb-0b4a-0d22f72f72ba
html"""
<h4>Lecture</h4>
<iframe width="100%" height="360" src="https://www.youtube.com/embed/JwyQezsQkkw" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
<h4>Live coding session</h4>
<iframe width="100%" height="360" src="https://www.youtube.com/embed/TGrqQEtudks" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

"""

# ╔═╡ 1e2cd0b0-19c4-11eb-3583-0b82092139aa
md"_Let's create a package environment:_"

# ╔═╡ 4e917968-1f87-11eb-371f-e3899b76dc24
md"""
## From the last homework

Below we have included some important functions from the last homework (_Raytracing in 2D_), which we will be able to re-use for the 3D case.

There are some small changes:
1. The concept of a `Photon` now carries **color information**.
2. The `Sphere` is no longer a pure lens, it contains a `Surface` property which describes the mixture between transmission, reflection and a pure color. More on this later!
3. The `refract` function is updated to handle two edge cases, but its behaviour is generally unchanged.

Outside of these changes, all functions from the previous homework can be taken "as-is" when converting to 3D, cool!
"""

# ╔═╡ 24b0d4ba-192c-11eb-0f66-e77b544b0510
"""
struct Photon

Photon is a Ray (position `p` and unit direction `l` vectors) with a 
color `c` and an
index of refraction `ior` for the current
media it travels through.
"""
struct Photon
    "Position vector"
    p::Vector{Float64}

    "Direction vector"
    l::Vector{Float64}

    "Color associated with the photon"
    c::RGB

    ior::Real
end

# ╔═╡ c6e8d30e-205c-11eb-271c-6165a164073d
md"""
#### Intersections:
"""

# ╔═╡ d851a202-1ca0-11eb-3da0-51fcb656783c
abstract type Object end

# ╔═╡ 8acef4b0-1a09-11eb-068d-79a259244ed1
struct Miss end

# ╔═╡ 8018fbf0-1a05-11eb-3032-95aae07ca78f
struct Intersection{T<:Object}
    object::T
    distance::Float64
    point::Vector{Float64}
end

# ╔═╡ fcde90ca-2048-11eb-3e96-f9f47b6154e8
begin
    Base.isless(a::Miss, b::Miss) = false
    Base.isless(a::Miss, b::Intersection) = false
    Base.isless(a::Intersection, b::Miss) = true
    Base.isless(a::Intersection, b::Intersection) = a.distance < b.distance
end

# ╔═╡ dc36ceaa-205c-11eb-169c-bb4c36aaec9f
md"""
#### Reflect and refract:
"""

# ╔═╡ 43306bd4-194d-11eb-2e30-07eabb8b29ef
"""
	reflect(ℓ₁::Vector, n̂::Vector)

returns the (unit-length) reflected vector
with the component normal to the surface reversed in direction
(subtracting 2 x component along surface normal).
"""
reflect(ℓ₁::Vector, n̂::Vector)::Vector = normalize(ℓ₁ - 2 * dot(ℓ₁, n̂) * n̂)

# ╔═╡ 5e9d35c4-8e6b-11eb-07e1-8f5a551d9c55
md"""
**Refraction:** Refraction of incident light ray with direction $\ell_1$ from medium 1 with index of refraction (ior) 
${\eta_1}$ passing through medium 2 with ior ${\eta_2}$ and surface normal $\hat n$

produces ray $\ell_2$

$\ell_2 = r\ell_1 + \left(rc-\sqrt{1-r^2(1-c^2)}\right)\hat n.$

where

$r = \frac{\eta_1}{\eta_2}$

and

$c = -\hat n \cdot \ell_1.$

(See derivation in HW7).
"""

# ╔═╡ 14dc73d2-1a0d-11eb-1a3c-0f793e74da9b
"""
	refract(ℓ₁::Vector, n̂::Vector, old_ior, new_ior)

Refracts incident light ray with direction ℓ₁ from medium 1 with index of refraction `old_ior` through medium with `new_ior` and surface normal n̂.
Returns refracted, unit-normalized, direction vector \ell_2
"""
function refract(
    ℓ₁::Vector, n̂::Vector,
    old_ior, new_ior
)
    # Note: assumes ℓ₁ has unit length
    r = old_ior / new_ior

    # account for entry and exiting of new medium with new_ior 
    n̂_oriented = if -dot(ℓ₁, n̂) < 0
        -n̂
    else
        n̂
    end

    c = -dot(ℓ₁, n̂_oriented)

    if abs(c) > 0.999 # incident direction parallel to normal n̂
        ℓ₁
    else
        f = 1 - r^2 * (1 - c^2)
        if f < 0
            ℓ₁
        else
            normalize(r * ℓ₁ + (r * c - sqrt(f)) * n̂_oriented)
        end
    end
end

# ╔═╡ 7f0bf286-2071-11eb-0cac-6d10c93bab6c
md"""
#### Surface (new)
"""

# ╔═╡ dbc195d8-8f3b-11eb-1e5c-0f0c08d464a9
md"`Surface` is one of the properties of objects in the scene. It has reflectivity `r`, 
transmission `t`
color `c`
and index of refraction `ior`."

# ╔═╡ fe9ddc72-8f4c-11eb-3ef4-e9a3e8130ab8
function Base.isapprox(n1::Nothing, n2::Nothing)
    return true
end

# ╔═╡ f0c0477c-8f4c-11eb-2c89-29b3e5bbe392
let
    n1 = nothing
    n2 = nothing
    isapprox(n1, n1)
end

# ╔═╡ 8a4e888c-1ef7-11eb-2a52-17db130458a5
"""
	struct Surface

has reflectivity `r`, 
transmission `t`
color `c`
and index of refraction `ior`.
"""
struct Surface
    # Reflectivity
    r::Float64

    # Transmission
    t::Float64

    # Color (RGB with alpha property)
    c::RGBA

    # index of refraction
    ior::Float64

    function Surface(in_r, in_t, in_c, in_ior)
        if !isapprox(in_r + in_t + in_c.alpha, 1)
            error("invalid Surface definition: RTC must total 1.0")
        end
        new(in_r, in_t, in_c, in_ior)
    end

    "Constructor for color as Float vs RGBA - assume black/transparent"
    function Surface(in_r, in_t, in_c::Float64, in_ior)
        new(in_r, in_t, RGBA(0, 0, 0, 0), in_ior)
    end
end

# ╔═╡ 9c3bdb62-1ef7-11eb-2204-417510bf0d72
html"""
<h4 id="sphere-defs">Sphere</h4>
<p>Aasdf</p>
"""

# ╔═╡ cb7ed97e-1ef7-11eb-192c-abfd66238378
"""
	struct Sphere <: Object

has (lens) position vector `p`,
and real radius `r`, and 
Surface `s` (non-refracting)
"""
struct Sphere <: Object
    # Lens position
    p::Vector{Float64}

    # Lens radius
    r::Float64

    s::Surface
end

# ╔═╡ fda4d41e-8f3e-11eb-324a-53236d6dca4e
"""
	Lens(p, r, ior)

returns a transparent sphere (zero-reflectivity or color)
with index-of-refraction `ior`
at location `p` with radius `r`
"""
function Lens(p, r, ior)
    Sphere(p, r, Surface(0, 1, RGBA(0, 0, 0, 0), ior))
end

# ╔═╡ 8f414efc-8f3f-11eb-3744-9722c269ce60
"""
	ReflectingSphere(p, r)

returns a perfectly reflecting sphere (zero-transmission/refraction or color)
with index-of-refraction 0.0,
at location `p` with radius `r`
"""
function ReflectingSphere(p, r)
    Sphere(p, r, Surface(1, 0, RGBA(0, 0, 0, 0), 0))
end

# ╔═╡ 48436c3c-8f40-11eb-0d44-69d240609b84
"""
	ReflectingSphere(p, r)

returns a perfectly opaque sphere (zero-transmission/refraction or reflection),
at location `p` with radius `r`
"""
function ColoredSphere(p, r, c::RGB)
    Sphere(p, r, Surface(0, 0, RGBA(c), 0))
end

# ╔═╡ 6fdf613c-193f-11eb-0029-957541d2ed4d
"""
   function sphere_normal_at(p::Vector{Float64}, s::Sphere)

return unit-normal to surface of sphere `s` at point `p`
(actually does not check if p is one the surface - this is the 
unit-direction from center of sphere to `p`)
"""
function sphere_normal_at(p::Vector{Float64}, s::Sphere)
    normalize(p - s.p) # this is the normalized vector from sphere center to point p
end

# ╔═╡ 452d6668-1ec7-11eb-3b0a-0b8f45b43fd5
md"""
## Camera and Skyboxes

Now we can begin looking into the 3D nature of raytracing to create visualizations similar to those in lecture.
The first step is setting up the camera and another stuct known as a *sky box* to collect all the rays of light.

Luckily, the transition from 2D to 3D for raytracing is relatively straightforward and we can use all of the functions and concepts we have built in 2D moving forward.

Firstly, the camera:

"""

# ╔═╡ 791f0bd2-1ed1-11eb-0925-13c394b901ce
md"""
### Camera

For the purposes of this homework, we will constrain ourselves to a camera pointing exclusively downward.

	- Q: does "downward" just mean that the 2D screen/window is a plane orthogonal to the vector from the center (`position`) of the camera sphere through the center of the aperture?
	- Or does this just define the image plane (screen) to be parallel to the x-y plane?

This is simply because camera positioning can be a bit tricky and there is no reason to make the homework more complicated than it needs to be!

So, what is the purpose of the camera?

Well, in reality, a camera is a device that collects the color information from all the rays of light that are refracting and reflecting off of various objects in some sort of scene.
Because there are a nearly infinite number of rays bouncing around the scene at any time, we will actually constrain ourselves only to rays that are entering our camera.
In particular, we will create a 2D screen just in front of the camera and send a ray from the camera to each pixel in the screen, as shown in the following image:

$(RemoteResource("https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Ray_trace_diagram.svg/1920px-Ray_trace_diagram.svg.png", :width=>400, :style=>"display: block; margin: auto;"))
"""

# ╔═╡ 1a446de6-1ec9-11eb-1e2f-6f4376005d24
md"""
Because we are not considering camera motion for this exercise, we will assume that the image plane is constrained to the horizontal plane, but that the camera, itself, can be some distance behind it.
This distance from the image plane to the camera is called the *focal length* and is used to determine the field of view.

From here, it's clear we need to construct:
1. A camera struct
2. A function to initialize all the rays being generated by the camera

Let's start with the struct
"""

# ╔═╡ 88576c6e-1ecb-11eb-3e34-830aeb433df1
"""
	struct Camera <: Object
	
`resolution::Tuple{Int64,Int64}` "Set of all pixels, counts as scene resolution"\n
`aperture_width::Float64` 	"Physical size of aperture"
`focal_length::Float64` 	"Camera's distance from screen"
`p::Vector{Float64}` 		"Camera's 3D position"
"""
struct Camera <: Object
    "Set of all pixels, counts as scene resolution"
    resolution::Tuple{Int64,Int64}

    "Physical size of aperture"
    aperture_width::Float64

    "Camera's distance from screen (<0 if camera above)"
    focal_length::Float64

    "Camera's position (3D)"
    p::Vector{Float64}
end

# ╔═╡ e774d6a8-2058-11eb-015a-83b4b6104e6e
test_cam = Camera((400, 300), 9, -10, [0, 00, 100])

# ╔═╡ 8f73824e-1ecb-11eb-0b28-4d1bc0eefbc3
md"""
Now we need to construct some method to create each individual ray extending from the camera to a pixel in the image plane.
"""

# ╔═╡ 4006566e-1ecd-11eb-2ce1-9d1107186784
"""
	function init_rays(cam::Camera)

Create an individual ray (`Photon`) extending from the camera 
center position `cam.p` to each pixel in the image plane (`cam.aperture`).
Returns an array of such Photons, each colored black,`ior`=1.
"""
function init_rays(cam::Camera)

    # Physical size of the aperture/image/grid
    aspect_ratio = cam.resolution[1] / cam.resolution[2]
    dim = (
        cam.aperture_width, # width is in Skybox-world distance units
        cam.aperture_width / aspect_ratio
    )

    # pixed width = dim ./ resolution

    # The x, y coordinates of every pixel in our image grid
    # relative to the image center (at [0, 0, cam.focal_length])
    xs = LinRange(-0.5 * dim[1], 0.5 * dim[1], cam.resolution[1])
    ys = LinRange(0.5 * dim[2], -0.5 * dim[2], cam.resolution[2])

    # pixel_positions are relative to camera center,
    #. hence they normalize to directions
    pixel_positions = [[x, y, cam.focal_length] for y in ys, x in xs]
    directions = normalize.(pixel_positions)

    # broadcast the Photon constructor with all photons needed for the 
    # full aperture array with camera `resolution`
    #.  Photons located at the camera position `p`,
    #.  each directed to position of one pixel in the aperture,
    #.  colored black
    Photon.([cam.p], directions, [zero(RGB)], [1.0])
end

# ╔═╡ 156c0d7a-2071-11eb-1551-4f2d393df6c8
tiny_resolution_camera = Camera((4, 3), 16, -5, [0, 20, 100])

# ╔═╡ 2838c1e4-2071-11eb-13d8-1da955fbf544
test_rays = init_rays(tiny_resolution_camera)

# ╔═╡ bca71e18-8f25-11eb-387f-1de578048acb
md"Confirming all the rays in the aperture (image plane) start out at black."

# ╔═╡ 595acf48-1ef6-11eb-0b46-934d17186e7b
"""
	extract_colors(rays)

takes `rays`, an array of rays, and 
returns an array of the ray colors
"""
extract_colors(rays) = map(ray -> ray.c, rays)

# ╔═╡ b7fa4512-2089-11eb-255d-4d6de9cdfb8e
extract_colors(test_rays)

# ╔═╡ 494687f6-1ecd-11eb-3ada-6f11f45aa74f
md"""
Nothing yet... time to add some objects!
### Skybox

Now that we have the concept of a camera, we can technically do a fully 3D raytracing example; however, we want to ensure that each pixel will actually *hit* something -- preferrably something with some color gradient so we can make sure our simulation is working!

For this, we will introduce the concept of a sky box, which is standard for most gaming applications.
Here, the idea is that our entire scene is held within some additional object, just like the mirrors we used in the 2D example.
The only difference here is that we will be using some texture instead of a reflective surface.
In addition, even though we are calling it a box, we'll actually be treating it as a sphere.

Because we have already worked out how to make sure we have hit the interior of a spherical lens, we will be using a similar function here.
For this part of the exercise, we will need to construct 2 things:

1. A skybox struct
2. A function that returns some color gradient to be called whenever a ray of light interacts with a sky box

So let's start with the sky box struct
"""

# ╔═╡ 9e71183c-1ef4-11eb-1802-3fc60b51ceba
"""
	struct SkyBox <: Object
	
SkyBox is a sphere with
`p::Vector{Float64}` "skybox position";
`r::Float64` "Skybox radius";
`c::Function` "Color function"
"""
struct SkyBox <: Object
    # Skybox position
    p::Vector{Float64}

    # Skybox radius
    r::Float64

    # Color function provides color at a position
    c::Function
end

# ╔═╡ 093b9e4a-1f8a-11eb-1d32-ad1d85ddaf42
"""
	intersection(photon::Photon, sphere::S; ϵ=1e-3) where {S <: Union{SkyBox, Sphere}}

returns either `Miss` or `Intersection(sphere, t, point)`
which indicates the sphere, 
nearest intersection time ("distance) `t` and 
location `point`.
"""
function intersection(photon::Photon, sphere::S; ϵ=1e-3) where {S<:Union{SkyBox,Sphere}}
    # coeffs of quatratic equation for photon intersection time 
    # with surface of sphere:
    #    a t^2 + bt + c = 0
    a = dot(photon.l, photon.l)
    b = 2 * dot(photon.l, photon.p - sphere.p)
    c = dot(photon.p - sphere.p, photon.p - sphere.p) - sphere.r^2

    d = b^2 - 4 * a * c # discriminant 

    if d <= 0
        Miss() # Miss if tangential (single root)
    else
        # quadratic roots
        t1 = (-b - sqrt(d)) / 2a
        t2 = (-b + sqrt(d)) / 2a

        t = if t1 > ϵ
            t1
        elseif t2 > ϵ
            t2
        else
            return Miss() # if negative or near 0 (already passed?)
        end

        point = photon.p + t * photon.l

        Intersection(sphere, t, point)
    end
end

# ╔═╡ 89e98868-1fb2-11eb-078d-c9298d8a9970
"""
	closest_hit(photon::Photon, objects::Vector{<:Object})

takes a `photon` and a 
`objects` vector of objects. 
Calculate the vector of `Intersection`s/`Miss`es, and return the `minimum`.
"""
function closest_hit(photon::Photon, objects::Vector{<:Object})
    hits = intersection.([photon], objects)

    minimum(hits)
end

# ╔═╡ aa9e61aa-1ef4-11eb-0b56-cd7ded52b640
md"""
Now we have the ability to create a skybox, the only thing left is to create some sort of texture function so that when the ray of light hits the sky box, we can return some form of color information.
So for this, we will basically create a function that returns back a smooth gradient in different directions depending on the position of the ray when it hits the skybox.

For the color information, we will be assigning a color to each cardinal axis.
That is to say that there will be a red gradient along $x$, a blue gradient along $y$, and a green gradient along $z$.
For this, we will need to define some extent $D$ over which the gradient will be active in 'real' units.
From there, we can say that the gradient is

$$\frac{r+D}{2D},$$

where $r$ is the ray's position when it hits the skybox, and $D$ is the extent over which the gradient is active.

So let's get to it and write the function!
"""

# ╔═╡ 86e661e4-8f27-11eb-0d94-db239128e3bb
sb = SkyBox()

# ╔═╡ c947f546-1ef5-11eb-0f02-054f4e7ae871
"""
	function gradient_skybox_color(position, skybox)

returns color `c` at given `position` in the `skybox`
"""
function gradient_skybox_color(position, skybox)
    extents = skybox.r
    c = zero(RGB)

    if -extents < position[1] < extents
        c += RGB((position[1] + extents) / (2.0 * extents), 0, 0)
    end

    if -extents < position[2] < extents
        c += RGB(0, 0, (position[2] + extents) / (2.0 * extents))
    end

    if -extents < position[3] < extents
        c += RGB(0, (position[3] + extents) / (2.0 * extents), 0)
    end

    return c
end

# ╔═╡ 2f8f27ba-8f29-11eb-2e8b-5f37fe9d1e83


# ╔═╡ de75a7ca-8efb-11eb-3fc8-33978482a0e2
md"Construct the sky with a `SkyBox` constructor, and use the new function `gradient_skybox_color(position, skybox)` as the coloring function `c`"

# ╔═╡ a919c880-206e-11eb-2796-55ccd9dbe619
sky = SkyBox([0.0, 0.0, 0.0], 1000, gradient_skybox_color)

# ╔═╡ 49651bc6-2071-11eb-1aa0-ff829f7b4350
md"""
Let's set up a basic scene and trace an image! Since our skybox is _spherical_ we can use **the same `intersect`** method as we use for `Sphere`s. Have a look at [the `intersect` method](#sphere-defs), we already added `SkyBox` as a possible type.
"""

# ╔═╡ f5196d3c-8f0c-11eb-34ea-9d4b4851a77d
md"Construct a `Camera` with given resolution, "

# ╔═╡ daf80644-2070-11eb-3363-c577ae5846b3
basic_camera = Camera((300, 200), 16, -5, [0, 20, 100])

# ╔═╡ df3f2178-1ef5-11eb-3098-b1c8c67cf136
md"""
To create this image, we used the ray tracing function below, which takes in a camera and a set of objects / scene, and...
1. Initilializes all the rays
2. Propagates the rays forward
3. Converts everything into an image
"""

# ╔═╡ 04a86366-208b-11eb-1977-ff7e4ae6b714
md"""
## Writing a ray tracer

It's your turn! Below is the code needed to trace just the sky box, but we still need to add the ability to trace spheres.

**We recommend** that you start by just implementing _reflection_ - make every sphere reflect, regardless of its surface. Make sure that this is working well - can you see the reflection of one sphere in another sphere? Does our program get stuck in a loop?

Once you have reflections working, you can add _refraction_ and _colored spheres_. In the 2D example, we dealt specifically with spheres that could either 100% reflect or refract. In reality, it is possible for objects to either reflect or refract, something in-between.
That is to say, a ray of light can *split* when hitting an object surface, creating at least 2 more rays of light that will both return separate color values.
The color that we _perceive_ for that ray is the combination both of these colors - they are mixed.

A third possibility explored in the lecture is that the objects can also have a color associated with them and just return the color value instead of reflecting or refracting.

**You can choose!** After implementing reflection, you can implement three different spheres (you can modify the existing code, create new types, add functions, and so on), a purely reflective, purely refractive or opaquely colored sphere. You can also go straight for the more photorealistic option, which is that every sphere is a combination of these three - this is what we did in the lecture.

Note: In this simulation, "all rays of light stop at the skybox."
"""

# ╔═╡ a9754410-204d-11eb-123e-e5c5f87ae1c5
"""
	interact(ray::Photon, hit::Intersection{SkyBox}, ::Any, ::Any)

given a Photon `ray` and `hit`, an intersection with a SkyBox,
return the Photon with position `p` at the hit location,
with the same direction `l` and ior, 
and new color `c`.
This models absorbtion/transmission of the photon by the skybox, and 
producing only color (no further reflection or refraction)

Incidentally: drags along two other unnamed args
"""
function interact(ray::Photon, hit::Intersection{SkyBox}, ::Any, ::Any)

    ray_color = hit.object.c(hit.point, hit.object)
    Photon(hit.point, ray.l, ray_color, ray.ior)
end

# ╔═╡ 086e1956-204e-11eb-2524-f719504fb95b
"""
	interact(ray::Photon, ::Miss, ::Any, ::Any)

given a Photon `ray` and `miss`,
just return the `ray` unchanged.

Incidentally: drags along two other unnamed args
"""
interact(photon::Photon, ::Miss, ::Any, ::Any) = photon

# ╔═╡ d1970a34-1ef7-11eb-3e1f-0fd3b8e9657f
md"""
Below, we create a scene with a number of balls inside of it.
While working on your code, work in small increments, and do frequent checks to see if your code is working. Feel free to modify this test scene, or to create a simpler one.
"""

# ╔═╡ cd2681a6-8f30-11eb-240d-cb980ace20a7
main_scene_small = [
    sky,
    Sphere([0, 0, -25], 20,
        Surface(1.0, 0.0, RGBA(1, 1, 1, 0.0), 1.5)), Sphere([0, 50, -100], 20,
        Surface(0.0, 1.0, RGBA(0, 0, 0, 0.0), 1.0)),
]

# ╔═╡ 16f4c8e6-2051-11eb-2f23-f7300abea642
main_scene = [
    sky,
    Sphere([0, 0, -25], 20,
        Surface(1.0, 0.0, RGBA(1, 1, 1, 0.0), 1.5)), Sphere([0, 50, -100], 20,
        Surface(0.0, 1.0, RGBA(0, 0, 0, 0.0), 1.0)), Sphere([-50, 0, -25], 20,
        Surface(0.0, 0.0, RGBA(0, 0.3, 0.8, 1), 1.0)), Sphere([30, 25, -60], 20,
        Surface(0.0, 0.75, RGBA(1, 0, 0, 0.25), 1.5)), Sphere([50, 0, -25], 20,
        Surface(0.5, 0.0, RGBA(0.1, 0.9, 0.1, 0.5), 1.5)), Sphere([-30, 25, -60], 20,
        Surface(0.5, 0.5, RGBA(1, 1, 1, 0), 1.5)),
]

# ╔═╡ 2fa4e1ac-8f58-11eb-0741-615eacf823a9
function propagate(ray::Photon, objects::Vector{O},
    num_intersections) where {O<:Object}
    for i = 1:num_intersections
        if ray.l != zeros(length(ray.l))
            intersect_final = [Inf, Inf]
            intersected_object = nothing
            for object in objects
                intersect = intersection(ray, object)
                # look for nearest intersected object
                if intersect != nothing &&
                   sum(intersect[:]^2) < sum(intersect_final^2)
                    intersect_final = intersect
                    intersected_object = object
                end
            end

            if intersect_final != nothing
                ray = Ray(ray.l, ray.p + intersect_final, ray.c, ray.ior)
                if typeof(intersected_object) == Sphere
                    reflected_ray = ray
                    refracted_ray = ray
                    colored_ray = ray
                    if !isapprox(intersected_object.s.t, 0) # some transmission
                        ior = 1 / intersected_object.s.ior
                        if dot(ray.l,
                            sphere_normal_at(ray, intersected_object)) > 0
                            ior = intersected_object.s.ior
                        end

                        refracted_ray = refract(ray, intersected_object, ior)
                        refracted_ray = propagate(refracted_ray, objects, num_intersections - 1)
                    end

                    if !isapprox(intersected_object.s.r, 0) # some Reflection
                        n = sphere_normal_at(ray, intersected_object)

                        reflected_ray = reflect(ray, n)
                        reflected_ray = propagate(reflected_ray, objects, num_intersections - 1)

                    end

                    if !isapprox(intersected_object.s.c.alpha, 0) # some Color response
                        ray_color = RGB(intersected_object.s.c)
                        ray_vel = zeros(length(ray.l)) # stopping photon, velocity l=0
                        colored_ray = Ray(ray_vel, ray.p, ray_color)
                        # colored ray is not propagated further
                    end

                    # eventually you return from all recursive calls to propagate,
                    #. either after hitting num_intersections objects, or 
                    #. being absorbed by a colored object or the SkyBox
                    # construct weighed average color, weighted by surface t, s, c
                    # Gather all the colors from all the refracted, reflected,
                    #  and absorbed photons/rays at this level of intersection
                    ray_color = intersected_object.s.t * refracted_ray.c +
                                intersected_object.s.r * reflected_ray.c +
                                intersected_object.s.c.alpha * colored_ray.c

                    ray = Ray(zeros(length(ray.l)), ray.p, ray_color)

                elseif typeof(intersected_object) = SkyBox
                    ray_color = pixel_color(ray.p, 1000)
                    ray_vel = zeros(length(ray.l)) # stopping photon, velocity l=0
                    ray = Ray(ray_val, ray.p, ray_color)
                end # interacting with sphere or SkyBox

            end # if intersected with something, intersect_final != nothing
        end # if ray not stopped, ray.l != zeros(length(ray.l))
    end # i = 1:num_intersections
end

# ╔═╡ 3766ddda-8f35-11eb-3b67-e782bcfcf631
function reflect(ray, n)
    ray_vel = ray.l .- 2 * dot(ray.l, n)
    ray_pos = ray.p + 0.001 * ray.l # advance position slightly, to avoid repeat collision
end

# ╔═╡ 95ca879a-204d-11eb-3473-959811aa8320
begin

    function interact(ray::Photon, hit::Intersection{Sphere},
        num_intersections::Int, objects::Any)

        # ray_color = hit.object.c(hit.point, hit.object)
        # Photon(hit.point, ray.l, ray_color, ray.ior)

        n = sphere_normal_at(hit.point, hit.object)

        # if !isapprox(hit.object.s.r, 0) # non-zero reflection
        reflected_ray = Photon(hit.point, reflect(ray.l, n), ray.c, ray.ior)
        return step_ray(reflected_ray, objects, num_intersections - 1)
        # else
        #	return missing # need to handle absorbtion and refraction
        # end
    end

    """
    	step_ray(ray::Photon, objects::Vector{O},
    			   num_intersections) where {O <: Object}

    Step a single Photon `ray` forward `num_intersections`
    intersection events, given the vector of objects (scene)
    `objects`

    Return the ray after `interact` with the closest `hit`
    """
    function step_ray(ray::Photon, objects::Vector{O},
        num_intersections) where {O<:Object}

        if num_intersections == 0 # return unchanged
            return ray
        else
            hit = closest_hit(ray, objects)
            return interact(ray, hit, num_intersections, objects)
        end
    end
end

# ╔═╡ 6b91a58a-1ef6-11eb-1c36-2f44713905e1
"""
takes a vector of objects (scene) `objects`, 
and Camera `cam`, and
1. Initilializes all the rays
2. Steps the rays forward to record `num_intersections` intersections,
3. Converts everything into an image by extracting colors
"""
function ray_trace(objects::Vector{O}, cam::Camera;
    num_intersections=10) where {O<:Object}
    rays = init_rays(cam)

    new_rays = step_ray.(rays, [objects], [num_intersections])

    extract_colors(new_rays)
end

# ╔═╡ a0b84f62-2047-11eb-348c-db83f4e6c39c
let
    scene = [sky] # the vector of objects is just the spherical SkyBox `sky`
    ray_trace(scene, basic_camera; num_intersections=4)
end

# ╔═╡ 1f66ba6e-1ef8-11eb-10ba-4594f7c5ff19
let
    cam = Camera((600, 360), 16, -15, [0, 10, 100])

    ray_trace(main_scene, cam; num_intersections=3)
end

# ╔═╡ 4a7bfcca-8f5f-11eb-2091-11b339efd6ba
methods(interact)

# ╔═╡ a0ecae3a-8f2b-11eb-353e-a1a458e4f49f
methods(interact)

# ╔═╡ 27974e80-8f41-11eb-06f7-396743bd6540
function refract(ray, lens::Sphere, ior)
    n = sphere_normal_at(ray, lens)

    # account for entry and exiting of new medium with new_ior 
    if dot(n, ray.l) > 0
        n .*= -1 # reverse normal
    end

    c = dot(ray.l, -n)
    d = 1 - ior^2 * (1 - c^2)

    if d < 0
        return reflect(ray, n)
    end
    # Following skips normalize, and seems to reverse old_ior and new_ior
    # ray_vel = normalize(r * ray.l + (r*c - sqrt(d)) * n) # for r = old_ior / new_ior
    ray_vel = ior * ray.l + (ior * c - sqrt(d)) * n

    # can this be done with existing vector refraction function: ?
    # ray_vel = refract(ray.l, sphere_normal_at(ray, lens), 1, ior)

    return Ray(ray_vel, ray.p, ray.c)
end

# ╔═╡ ea7f0792-8f34-11eb-29cb-cb86aa84a804
function convert_to_image(rays::Array{Ray}, filename)
    color_array = Array{RGB}(undef, size(rays)[2], size(rays)[1])
    for i = 1:length(color_array)
        color_array[i] = rays[i].c # iterates across all dimensions
    end

    save(filename, color_array)
end

# ╔═╡ 29621cb4-8f4a-11eb-182c-2528f45496ca
md"XXX"

# ╔═╡ 67c0bd70-206a-11eb-3935-83d32c67f2eb
md"""
## **Bonus:** Escher

If you managed to get through the exercises, we have a fun bonus exercise! The goal is to recreate this self-portrait by M.C. Escher:

"""

# ╔═╡ 748cbaa2-206c-11eb-2cc9-7fa74308711b
Resource("https://www.researchgate.net/profile/Madhu_Gupta22/publication/3427377/figure/fig1/AS:663019482775553@1535087571714/A-self-portrait-of-MC-Escher-1898-1972-in-spherical-mirror-dating-from-1935-titled.png", :width => 300)

# ╔═╡ 981e6bd2-206c-11eb-116d-6fad4e04ce34
md"""
It looks like M.C. Escher is a skillful raytracer, but so are we! To recreate this image, we can simplify it by having just two objects in our scene:
- A purely reflective sphere
- A skybox, containing an image of us!

Let's start with our old skybox, and set up our scene:
"""

# ╔═╡ 7a12a99a-206d-11eb-2393-bf28b881087a
escher_sphere = Sphere([0, 0, 0], 20,
    Surface(1.0, 0.0, RGBA(1, 1, 1, 0.0), 1.5))

# ╔═╡ 373b6a26-206d-11eb-1e67-9debb032f69e
escher_cam = Camera((300, 300), 30, -10, [0, 00, 30])

# ╔═╡ 5dfec31c-206d-11eb-23a2-259f2c205cb5
md"""
👆 You can modify `escher_cam` to increase or descrease the resolution!
"""

# ╔═╡ 6f1dbf48-206d-11eb-24d3-5154703e1753
let
    scene = [sky, escher_sphere]
    ray_trace(scene, escher_cam; num_intersections=3)
end

# ╔═╡ dc786ccc-206e-11eb-29e2-99882e6613af
md"""
Awesome! Next, we want to set an _image_ as our skybox, instead of a gradient. To do so, we have written a function that converts the x,y,z coordinates of the intersection point with a skybox into a latitude/longitude pair, which we can use (after scaling, rounding & clamping) as pixel coordinates to index an image!
"""

# ╔═╡ 8ebe4cd6-2061-11eb-396b-45745bd7ec55
earth = load(download("https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Whole_world_-_land_and_oceans_12000.jpg/1280px-Whole_world_-_land_and_oceans_12000.jpg"))

# ╔═╡ 12d3b806-2062-11eb-20a8-7d1a33e4b073
function get_index_rational(A, x, y)
    a, b = size(A)

    u = clamp(floor(Int, x * (a - 1)) + 1, 1, a)
    v = clamp(floor(Int, y * (b - 1)) + 1, 1, b)
    A[u, v]
end

# ╔═╡ cc492966-2061-11eb-1000-d90c279c4668
function image_skybox(img)
    f = function (position, skybox)
        lon = atan(-position[1], position[3])
        lat = -atan(position[2], norm(position[[1, 3]]))

        get_index_rational(img, (lat / (pi)) + 0.5, (lon / 2pi) + 0.5)
    end

    SkyBox([0.0, 0.0, 0.0], 1000, f)
end

# ╔═╡ 137834d4-206d-11eb-0082-7b87bf222808
earth_skybox = image_skybox(earth)

# ╔═╡ bff27890-206e-11eb-2e40-696424a0b8be
let
    scene = [earth_skybox, escher_sphere]
    ray_trace(scene, escher_cam; num_intersections=3)
end

# ╔═╡ b0bc76f8-206d-11eb-0cad-4bde96565fed
md"""
Great! It's like the Earth, but distorted. Notice that the continents are mirrored, and that you can see both poles at the same time. 

Okay, self portrait time! Let's take a picture using your webcam, and we will use it as the skybox texture:
"""

# ╔═╡ 48166866-2070-11eb-2722-556a6719c2a2
md"""
👀 wow! It's _Planet $(student.name)_, surrounded by even more $(student.name). 

When you look at the drawing by Escher, you see that he only occupies a small section of the 'skybox'. Behind Escher, you can see his cozy house, and in _front_ of him (i.e. _behind_ the glass sphere, from his persective), you see a gray background. 

What we need is a 360° panoramic image of our room. One option is that you make one! There are great tutorials online, and maybe you can use an app to do this with your phone.

Another option is that we approximate the panaroma by _padding_ the image of your face. You can pad the image with a solid color, you can use a gradient, you can use the earth satellite image, you can add noise, and so on. [Here](https://user-images.githubusercontent.com/6933510/98426463-31a64f00-2099-11eb-96dd-9f0f065e0da4.png) is an example of what I made.
"""

# ╔═╡ 6480b85c-2067-11eb-0262-f752d306d8ae
function padded(img)

    return missing
end

# ╔═╡ 3de614da-2091-11eb-361a-83bcf357c394
md"""
Let's put it all together!
"""

# ╔═╡ ebd05bf0-19c3-11eb-2559-7d0745a84025
if student.name == "Jazzy Doe" || student.kerberos_id == "jazz"
    md"""
    !!! danger "Before you submit"
        Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
    """
end

# ╔═╡ ec275590-19c3-11eb-23d0-cb3d9f62ba92
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 2c36d3e8-2065-11eb-3a12-8382f8539ea6

function process_raw_camera_data(raw_camera_data)
    # the raw image data is a long byte array, we need to transform it into something
    # more "Julian" - something with more _structure_.

    # The encoding of the raw byte stream is:
    # every 4 bytes is a single pixel
    # every pixel has 4 values: Red, Green, Blue, Alpha
    # (we ignore alpha for this notebook)

    # So to get the red values for each pixel, we take every 4th value, starting at 
    # the 1st:
    reds_flat = UInt8.(raw_camera_data["data"][1:4:end])
    greens_flat = UInt8.(raw_camera_data["data"][2:4:end])
    blues_flat = UInt8.(raw_camera_data["data"][3:4:end])

    # but these are still 1-dimensional arrays, nicknamed 'flat' arrays
    # We will 'reshape' this into 2D arrays:

    width = raw_camera_data["width"]
    height = raw_camera_data["height"]

    # shuffle and flip to get it in the right shape
    reds = reshape(reds_flat, (width, height))' / 255.0
    greens = reshape(greens_flat, (width, height))' / 255.0
    blues = reshape(blues_flat, (width, height))' / 255.0

    # we have our 2D array for each color
    # Let's create a single 2D array, where each value contains the R, G and B value of 
    # that pixel

    RGB.(reds, greens, blues)
end

# ╔═╡ f7b5ff68-2064-11eb-3be3-554519ca4847
function camera_input(; max_size=200, default_url="https://i.imgur.com/SUmi94P.png")
    """
    <span class="pl-image waiting-for-permission">
    <style>
    	
    	.pl-image.popped-out {
    		position: fixed;
    		top: 0;
    		right: 0;
    		z-index: 5;
    	}

    	.pl-image #video-container {
    		width: 250px;
    	}

    	.pl-image video {
    		border-radius: 1rem 1rem 0 0;
    	}
    	.pl-image.waiting-for-permission #video-container {
    		display: none;
    	}
    	.pl-image #prompt {
    		display: none;
    	}
    	.pl-image.waiting-for-permission #prompt {
    		width: 250px;
    		height: 200px;
    		display: grid;
    		place-items: center;
    		font-family: monospace;
    		font-weight: bold;
    		text-decoration: underline;
    		cursor: pointer;
    		border: 5px dashed rgba(0,0,0,.5);
    	}

    	.pl-image video {
    		display: block;
    	}
    	.pl-image .bar {
    		width: inherit;
    		display: flex;
    		z-index: 6;
    	}
    	.pl-image .bar#top {
    		position: absolute;
    		flex-direction: column;
    	}
    	
    	.pl-image .bar#bottom {
    		background: black;
    		border-radius: 0 0 1rem 1rem;
    	}
    	.pl-image .bar button {
    		flex: 0 0 auto;
    		background: rgba(255,255,255,.8);
    		border: none;
    		width: 2rem;
    		height: 2rem;
    		border-radius: 100%;
    		cursor: pointer;
    		z-index: 7;
    	}
    	.pl-image .bar button#shutter {
    		width: 3rem;
    		height: 3rem;
    		margin: -1.5rem auto .2rem auto;
    	}

    	.pl-image video.takepicture {
    		animation: pictureflash 200ms linear;
    	}

    	@keyframes pictureflash {
    		0% {
    			filter: grayscale(1.0) contrast(2.0);
    		}

    		100% {
    			filter: grayscale(0.0) contrast(1.0);
    		}
    	}
    </style>

    	<div id="video-container">
    		<div id="top" class="bar">
    			<button id="stop" title="Stop video">✖</button>
    			<button id="pop-out" title="Pop out/pop in">⏏</button>
    		</div>
    		<video playsinline autoplay></video>
    		<div id="bottom" class="bar">
    		<button id="shutter" title="Click to take a picture">📷</button>
    		</div>
    	</div>
    		
    	<div id="prompt">
    		<span>
    		Enable webcam
    		</span>
    	</div>

    <script>
    	// based on https://github.com/fonsp/printi-static (by the same author)

    	const span = currentScript.parentElement
    	const video = span.querySelector("video")
    	const popout = span.querySelector("button#pop-out")
    	const stop = span.querySelector("button#stop")
    	const shutter = span.querySelector("button#shutter")
    	const prompt = span.querySelector(".pl-image #prompt")

    	const maxsize = $(max_size)

    	const send_source = (source, src_width, src_height) => {
    		const scale = Math.min(1.0, maxsize / src_width, maxsize / src_height)

    		const width = Math.floor(src_width * scale)
    		const height = Math.floor(src_height * scale)

    		const canvas = html`<canvas width=\${width} height=\${height}>`
    		const ctx = canvas.getContext("2d")
    		ctx.drawImage(source, 0, 0, width, height)

    		span.value = {
    			width: width,
    			height: height,
    			data: ctx.getImageData(0, 0, width, height).data,
    		}
    		span.dispatchEvent(new CustomEvent("input"))
    	}
    	
    	const clear_camera = () => {
    		window.stream.getTracks().forEach(s => s.stop());
    		video.srcObject = null;

    		span.classList.add("waiting-for-permission");
    	}

    	prompt.onclick = () => {
    		navigator.mediaDevices.getUserMedia({
    			audio: false,
    			video: {
    				facingMode: "environment",
    			},
    		}).then(function(stream) {

    			stream.onend = console.log

    			window.stream = stream
    			video.srcObject = stream
    			window.cameraConnected = true
    			video.controls = false
    			video.play()
    			video.controls = false

    			span.classList.remove("waiting-for-permission");

    		}).catch(function(error) {
    			console.log(error)
    		});
    	}
    	stop.onclick = () => {
    		clear_camera()
    	}
    	popout.onclick = () => {
    		span.classList.toggle("popped-out")
    	}

    	shutter.onclick = () => {
    		const cl = video.classList
    		cl.remove("takepicture")
    		void video.offsetHeight
    		cl.add("takepicture")
    		video.play()
    		video.controls = false
    		console.log(video)
    		send_source(video, video.videoWidth, video.videoHeight)
    	}
    	
    	
    	document.addEventListener("visibilitychange", () => {
    		if (document.visibilityState != "visible") {
    			clear_camera()
    		}
    	})


    	// Set a default image

    	const img = html`<img crossOrigin="anonymous">`

    	img.onload = () => {
    	console.log("helloo")
    		send_source(img, img.width, img.height)
    	}
    	img.src = "$(default_url)"
    	console.log(img)
    </script>
    </span>
    """ |> HTML
end

# ╔═╡ 27d64432-2065-11eb-3795-e99b1d6718d2
@bind wow camera_input()

# ╔═╡ 64ce8106-2065-11eb-226c-0bcaf7e3f871
face = process_raw_camera_data(wow)

# ╔═╡ 06ac2efc-206f-11eb-1a73-9306bf5f7a9c
let
    face_skybox = image_skybox(face)
    scene = [face_skybox, escher_sphere]
    ray_trace(scene, escher_cam; num_intersections=3)
end

# ╔═╡ 7d03b258-2067-11eb-3070-1168e282b2ea
padded(face)

# ╔═╡ aa597a16-2066-11eb-35ae-3170468a90ed
@bind escher_face_data camera_input()

# ╔═╡ c68dbe1c-2066-11eb-048d-038df2c68a8b
let
    img = process_raw_camera_data(escher_face_data)
    img_padded = padded(img)

    scene = [
        image_skybox(padded(img)), escher_sphere,
    ]

    ray_trace(scene, escher_cam; num_intersections=20)
end

# ╔═╡ ec31dce0-19c3-11eb-1487-23cc20cd5277
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 7c804c30-208d-11eb-307c-076f2086ae73
hint(md"""If you are getting a _"Circular Defintions"_ error - this could be because of a Pluto limitation. If two functions call each other, they need to be contained in a single cell, using a `begin end` block.""")

# ╔═╡ ec3ed530-19c3-11eb-10bb-a55e77550d1f
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ ec4abc12-19c3-11eb-1ca4-b5e9d3cd100b
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ ec57b460-19c3-11eb-2142-07cf28dcf02b
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ ec5d59b0-19c3-11eb-0206-cbd1a5415c28
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section.", md"Whew! About time.", md"Good Gawd, yes."]

# ╔═╡ ec698eb0-19c3-11eb-340a-e319abb8ebb5
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ ec7638e0-19c3-11eb-1ca1-0b3aa3b40240
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ ec85c940-19c3-11eb-3375-a90735beaec1
TODO = html"<span style='display: inline; font-size: 2em; color: purple; font-weight: 900;'>TODO</span>"

# ╔═╡ 8cfa4902-1ad3-11eb-03a1-736898ff9cef
TODO_note(text) = Markdown.MD(Markdown.Admonition("warning", "TODO note", [text]))

# ╔═╡ b3899eda-8f31-11eb-3283-3bf0c7062dd5
TODO_note("Need a `interact` function for a sphere. Start with reflection")

# ╔═╡ c8e755e4-8f34-11eb-0b8b-41fd005961d4
TODO_note("Need functions `reflect` and `refract` dispatching for Photons (Rays) on Spheres")

# ╔═╡ Cell order:
# ╟─1df32310-19c4-11eb-0824-6766cd21aaf4
# ╟─1df82c20-19c4-11eb-0959-8543a0d5630d
# ╟─1e109620-19c4-11eb-013e-1bc95c14c2ba
# ╠═1e202680-19c4-11eb-29a7-99061b886b3c
# ╟─e4d2f6f6-2089-11eb-0b4a-0d22f72f72ba
# ╟─1e2cd0b0-19c4-11eb-3583-0b82092139aa
# ╠═c3e52bf2-ca9a-11ea-13aa-03a4335f2906
# ╟─4e917968-1f87-11eb-371f-e3899b76dc24
# ╠═24b0d4ba-192c-11eb-0f66-e77b544b0510
# ╟─c6e8d30e-205c-11eb-271c-6165a164073d
# ╠═d851a202-1ca0-11eb-3da0-51fcb656783c
# ╠═8acef4b0-1a09-11eb-068d-79a259244ed1
# ╠═8018fbf0-1a05-11eb-3032-95aae07ca78f
# ╠═fcde90ca-2048-11eb-3e96-f9f47b6154e8
# ╠═89e98868-1fb2-11eb-078d-c9298d8a9970
# ╟─dc36ceaa-205c-11eb-169c-bb4c36aaec9f
# ╠═43306bd4-194d-11eb-2e30-07eabb8b29ef
# ╠═5e9d35c4-8e6b-11eb-07e1-8f5a551d9c55
# ╠═14dc73d2-1a0d-11eb-1a3c-0f793e74da9b
# ╟─7f0bf286-2071-11eb-0cac-6d10c93bab6c
# ╟─dbc195d8-8f3b-11eb-1e5c-0f0c08d464a9
# ╠═fe9ddc72-8f4c-11eb-3ef4-e9a3e8130ab8
# ╠═f0c0477c-8f4c-11eb-2c89-29b3e5bbe392
# ╠═8a4e888c-1ef7-11eb-2a52-17db130458a5
# ╠═9c3bdb62-1ef7-11eb-2204-417510bf0d72
# ╠═cb7ed97e-1ef7-11eb-192c-abfd66238378
# ╠═fda4d41e-8f3e-11eb-324a-53236d6dca4e
# ╠═8f414efc-8f3f-11eb-3744-9722c269ce60
# ╠═48436c3c-8f40-11eb-0d44-69d240609b84
# ╠═093b9e4a-1f8a-11eb-1d32-ad1d85ddaf42
# ╠═6fdf613c-193f-11eb-0029-957541d2ed4d
# ╟─452d6668-1ec7-11eb-3b0a-0b8f45b43fd5
# ╟─791f0bd2-1ed1-11eb-0925-13c394b901ce
# ╟─1a446de6-1ec9-11eb-1e2f-6f4376005d24
# ╠═88576c6e-1ecb-11eb-3e34-830aeb433df1
# ╠═e774d6a8-2058-11eb-015a-83b4b6104e6e
# ╟─8f73824e-1ecb-11eb-0b28-4d1bc0eefbc3
# ╠═4006566e-1ecd-11eb-2ce1-9d1107186784
# ╠═156c0d7a-2071-11eb-1551-4f2d393df6c8
# ╠═2838c1e4-2071-11eb-13d8-1da955fbf544
# ╠═bca71e18-8f25-11eb-387f-1de578048acb
# ╠═595acf48-1ef6-11eb-0b46-934d17186e7b
# ╠═b7fa4512-2089-11eb-255d-4d6de9cdfb8e
# ╟─494687f6-1ecd-11eb-3ada-6f11f45aa74f
# ╠═9e71183c-1ef4-11eb-1802-3fc60b51ceba
# ╟─aa9e61aa-1ef4-11eb-0b56-cd7ded52b640
# ╠═86e661e4-8f27-11eb-0d94-db239128e3bb
# ╠═c947f546-1ef5-11eb-0f02-054f4e7ae871
# ╠═2f8f27ba-8f29-11eb-2e8b-5f37fe9d1e83
# ╟─de75a7ca-8efb-11eb-3fc8-33978482a0e2
# ╠═a919c880-206e-11eb-2796-55ccd9dbe619
# ╟─49651bc6-2071-11eb-1aa0-ff829f7b4350
# ╠═f5196d3c-8f0c-11eb-34ea-9d4b4851a77d
# ╠═daf80644-2070-11eb-3363-c577ae5846b3
# ╠═a0b84f62-2047-11eb-348c-db83f4e6c39c
# ╟─df3f2178-1ef5-11eb-3098-b1c8c67cf136
# ╠═6b91a58a-1ef6-11eb-1c36-2f44713905e1
# ╠═4a7bfcca-8f5f-11eb-2091-11b339efd6ba
# ╠═04a86366-208b-11eb-1977-ff7e4ae6b714
# ╠═a9754410-204d-11eb-123e-e5c5f87ae1c5
# ╠═086e1956-204e-11eb-2524-f719504fb95b
# ╠═b3899eda-8f31-11eb-3283-3bf0c7062dd5
# ╠═a0ecae3a-8f2b-11eb-353e-a1a458e4f49f
# ╠═95ca879a-204d-11eb-3473-959811aa8320
# ╠═1f66ba6e-1ef8-11eb-10ba-4594f7c5ff19
# ╟─d1970a34-1ef7-11eb-3e1f-0fd3b8e9657f
# ╠═cd2681a6-8f30-11eb-240d-cb980ace20a7
# ╠═16f4c8e6-2051-11eb-2f23-f7300abea642
# ╟─7c804c30-208d-11eb-307c-076f2086ae73
# ╠═2fa4e1ac-8f58-11eb-0741-615eacf823a9
# ╠═c8e755e4-8f34-11eb-0b8b-41fd005961d4
# ╠═27974e80-8f41-11eb-06f7-396743bd6540
# ╠═3766ddda-8f35-11eb-3b67-e782bcfcf631
# ╠═ea7f0792-8f34-11eb-29cb-cb86aa84a804
# ╠═29621cb4-8f4a-11eb-182c-2528f45496ca
# ╟─67c0bd70-206a-11eb-3935-83d32c67f2eb
# ╟─748cbaa2-206c-11eb-2cc9-7fa74308711b
# ╟─981e6bd2-206c-11eb-116d-6fad4e04ce34
# ╠═7a12a99a-206d-11eb-2393-bf28b881087a
# ╠═373b6a26-206d-11eb-1e67-9debb032f69e
# ╟─5dfec31c-206d-11eb-23a2-259f2c205cb5
# ╠═6f1dbf48-206d-11eb-24d3-5154703e1753
# ╟─dc786ccc-206e-11eb-29e2-99882e6613af
# ╟─8ebe4cd6-2061-11eb-396b-45745bd7ec55
# ╠═cc492966-2061-11eb-1000-d90c279c4668
# ╠═12d3b806-2062-11eb-20a8-7d1a33e4b073
# ╠═137834d4-206d-11eb-0082-7b87bf222808
# ╠═bff27890-206e-11eb-2e40-696424a0b8be
# ╟─b0bc76f8-206d-11eb-0cad-4bde96565fed
# ╠═27d64432-2065-11eb-3795-e99b1d6718d2
# ╟─64ce8106-2065-11eb-226c-0bcaf7e3f871
# ╠═06ac2efc-206f-11eb-1a73-9306bf5f7a9c
# ╟─48166866-2070-11eb-2722-556a6719c2a2
# ╠═6480b85c-2067-11eb-0262-f752d306d8ae
# ╠═7d03b258-2067-11eb-3070-1168e282b2ea
# ╟─3de614da-2091-11eb-361a-83bcf357c394
# ╟─aa597a16-2066-11eb-35ae-3170468a90ed
# ╠═c68dbe1c-2066-11eb-048d-038df2c68a8b
# ╟─ebd05bf0-19c3-11eb-2559-7d0745a84025
# ╟─ec275590-19c3-11eb-23d0-cb3d9f62ba92
# ╟─2c36d3e8-2065-11eb-3a12-8382f8539ea6
# ╟─f7b5ff68-2064-11eb-3be3-554519ca4847
# ╟─ec31dce0-19c3-11eb-1487-23cc20cd5277
# ╟─ec3ed530-19c3-11eb-10bb-a55e77550d1f
# ╟─ec4abc12-19c3-11eb-1ca4-b5e9d3cd100b
# ╟─ec57b460-19c3-11eb-2142-07cf28dcf02b
# ╠═ec5d59b0-19c3-11eb-0206-cbd1a5415c28
# ╠═ec698eb0-19c3-11eb-340a-e319abb8ebb5
# ╟─ec7638e0-19c3-11eb-1ca1-0b3aa3b40240
# ╟─ec85c940-19c3-11eb-3375-a90735beaec1
# ╠═8cfa4902-1ad3-11eb-03a1-736898ff9cef
