Questions for Discussion - Computational Thinking
===================================================

#### Re MIT Course 18.S181 Computational Thinking, Fall 2020

## Comments on Pluto file format
- note every cell begins with comment, a special symbol sequence, and cell hash number
    `# ╔═╡ 6aa73286-ede7-11ea-232b-63e052222ecd`
- content ordering in display vs. text (.jl) file
    - Note section (cell) in .jl file to provide "cell order":
    `# ╔═╡ Cell order:`
- this makes it look like some of the cell content is missing from the jl file, because is is located elsewhere in the file. E.g. this chunks

    ```julia
    if !@isdefined(vecvec_to_matrix)
        not_defined(:vecvec_to_matrix)
    else
        let
            input = [[6,7],[8,9]]

            result = vecvec_to_matrix(input)
            shouldbe = [6 7; 8 9]

            if ismissing(result)
                still_missing()
            elseif isnothing(result)
                keep_working(md"Did you forget to write `return`?")
            elseif !(result isa Matrix)
                keep_working(md"The result should be a `Matrix`")
            elseif result != shouldbe && result != shouldbe'
                keep_working()
            else
                correct()
            end
        end
    end
    ```

### Questions on Pluto file format
- is there an easy way to open multiple notebooks with pluto, other than launching Pluto from different terminal windows and julia sessions?
- when would you rather just work with an editor and a terminal to execute julia?
    - Note: Pluto is equivalent to having an edit window open, and a terminal with a compiler that runs automatically with each file save, except
        - editor file save is replace by the execution of any Pluto cell
        - Pluto _only_ reexecutes cells that are dependent on the recently changed cell
- Note on Debugging: I like that stack traces show line number with hyperlink to code line
## Questions on Course 18.S181 HW 1
- HW1 Ex.  Ex 1.1, why isapprox test fail:
    ```julia
    mean(demean(copy_of_random_vect)) ≈ 0
    #> false
    ```
- For HW1, Ex. 1.3, seek better solution for `matrix_to_vecvec()` function than hybrid comprehension/for-loop approach
- Scoping issues: In HW1, just before Ex 2.1, why `philip = let ... end` rather than `begin ... end` block?
- HW1, Ex. 2.1, `function mean_colors()`: better solution than awkward conversion of vector to tuple before return?
    - Confused about the type of the separate color components of RGBX (UInt or Float?). Fudged through it.
        ```julia
        typeof(philip[300,100].b )`
        #> Normed{UInt8,8}

        [philip[300,100].r,  philip[300,101].g]
        #> FixedPointNumbers.Normed{UInt8,8}`
        ```
    - HW1, Ex. 2.2 test provided for `quantize` were not any good (missed quantization to 0.01 rather than 0.1)
- HW1, Ex. 2.3 quantize(color::AbstractRGB): 
    - is there a way to broadcast quantize(x::Int) over the RGB color object?
        - ould also be useful for `function invert(color::AbstractRGB)`
    - RGB object is immutable, so have to return a new RGB element. But what about quantizing a Float - can you quantize the same float that is passed?
- HW1 Ex 2.4 `function quantize(image::AbstractMatrix)` was wonderfully easy!
- HW1 Ex 3 - not clear on Gaussian kernel

#### Continued Week 1
- note the multiple ways to do iteration for the `convolve_image()` fn
- what are the lessons re the application of convolution to different array types?
    - sometimes I got messages like
    `MethodError: no method matching +(::Float64, ::ColorTypes.RGB{Float64})`
    - problem was initialization of the convoluted matrix elements to the wrong type (Float64 rather than the type of the input matrix, in this case, RGB)

    ```julia
    celem = 0.0 # initialize the convoluted element
	
	for j in -l:l
		for k in -l:l
			celem += extend_mat(M, r+j, c+k) * K[j+l+1, k+l+1]
		end
	end
    ```
    - problem appears to be that the temporary storage array or even element needs to be initiaize to zero of the correct type
        - `convolve_image(philip, K_test)` works, when `convolve_point()` initializes `celem` appropriately
            ```julia
            celem = typeof(M[r,c])(0) # initialize the convoluted element to zero of desired
            ```
        - `convolve_image0(philip, K_test)` and `convolve_image1(philip, K_test)` still fail
    - **Solution for creating variables of matching type to arguments: `similar`**
        `similar(array, [element_type=eltype(array)], [dims=size(array)])`

        ```julia
        new_array = similar(M) # initialize the array of desired type matching array M
        # or
        new_elem = eltype(M)(0) # initialize the new element to zero of desired type matching array M
        # or
        accumulator = 0 * M[1, 1] # initialize accumulator to zero of desired type matching array M
        ```
    - For Sobel Edge - did you detect edge for each color/channel separately?
    - Re julia docstrings:
        - https://docs.julialang.org/en/v1/manual/documentation/

## Notes on Lecture 3 Seam Carving
- does seam cutting bias the presernvatoin of info in a particular (vertical) direction?
- re convolution: in what sense is convolution kernel "flipped," as Grant Sanderson says?
- re Dynamic Programming: this is closely related to graph shortest paths, and the Bellman Optimality Principle (subsections of shortest paths are also shortest paths between their origin and dest)
#### Notes on Array Slice and Views
- slices are copies (views are not)
    - are `reshape` and `vec` copies or views?
- arrays in Julia are column major
- Julia macros @ are really powerful, but somewhat cryptic

## Notes on HW2
- in `function remove_in_each_row`, very interesting that `vcat` is used rather than `hcat`
    - any slice that returns all or part of a single _row_, returns a _column_ vector
    - any slice that returns a 2-D object maintains original orientation
- in Ex. 1.2 test of `performance_experiment_without_vcat`, interesting operator ⧀, some kind of comparator over a union or struct
    - ⧀
    - No documentation found. 
- Q: in Ex. 1.3 fun `remove_in_each_row_views`, is the `img'` result returned now a view into the original `img`?  
- Q: in preamble to Ex 2, the function `convolve`, what is the role of applying `reflect` to the kernel?
- Q: in Hw2, Ex 2.1 or thereafter, did you use `reduce`? Need to understand that.

#### Continued Exploration of Single-Row slicing

```julia
julia> a = rand(2,2)
2×2 Array{Float64,2}:
0.467499  0.481851
0.727308  0.210967

julia> a[1,:] == a[1:1,:] # two slicing operations yielding diff results
false

julia> typeof(a[1:1,:])
Array{Float64,2}

julia> typeof(a[1,:]) # the julia REPL frustratingly indicates the same type (Pluto does better) 
Array{Float64,1}

julia> ndims(a[1,:]) # but one is 1-Dimensional
1

julia> ndims(a[1:1,:]) # and the other 2-D
2

julia> size(a[1,:]) # this is just a 1-D vector
(2,)

julia> size(a[1:1,:]) # this row vector is 2D
(1, 2)

julia> a[1,:]' == a[1:1,:] # transposing the 1D vector gives a "row-vec", a 2-D array with one row
true

julia> a[1,:] == a[1:1,:]' # conversely, a bit strange
false

julia> size(a[1:1,:]') # this is a 2-D array with one column
(2, 1)

julia> # the two versions of row-slicing give diff answers b.c. their arg-types differ, so they dispatch to different function calls

julia> 1:1 == 1
false

julia> typeof(1:1)
UnitRange{Int64}

julia> typeof(1)
Int64
```

### PCA
- returned type from indexing by integer rater than range https://youtu.be/Pt8Iz4Udg2E  at 8:45
- PCA as directions along which the data vary the most and very the least colon this is not seem to describe what I believed PCA does. Does it not identify an orthogonal directions which most completely capture the variation in all dimensions?
    - https://youtu.be/KrQV6mZ8hvI  at 19:30
- [A layman's introduction to principal component analysis](https://www.youtube.com/watch?v=BfTMmoDFXyE&feature=emb_logo)
- [tutorial8.pdf Principal Component Analysis](https://www.cs.toronto.edu/~urtasun/courses/CSC411/tutorial8.pdf)

- **`do` function syntax**: What do you think of the "`do block" syntax for function definition, how do you read it?
    - https://docs.julialang.org/en/v1/manual/functions/
    - is it mainly for applications of multiline anonymous functions by `map`?
    - particularly in the case of a multi-arg function

- Found this playlist, and figured how to add it to YouTube so that YouTube will play the lectures in order.
https://www.youtube.com/playlist?list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ

### Comments on HW3
- **pipe**
    - Ex 1.2 the `clean` function (a series of maps and filters, i.e. unaccent, isinalphabet, tolower) is a great example of utility of pipe operator

    ```julia
    function clean(text)
	    text |> unaccent |> map_lc |> filter_inal
    end
    ```
    - HOWEVER, Julia pipe operator is hobbled by only working with single-valued functions of one variable.
    - see Pipe.jl or extension
- Exercise 1.2 - Letter frequencies
    ```julia
    # this was compact way to select letters not appearing (count 0)
    # following works if you remember to broadcast == (can index by Boolean array)
    alphabet[sample_freqs .== 0]
    ```
    - does this work with base pipe?
    ```julia
    filter(x->x.age > 7, data) |> f->map(x->x.photo,f)
    ```
- **function composition**
    - function composition `∘` (entered with "\circ<tab>") seems equivalent to pipe
    - i.e. function nesting/chaining, but it only defines the composed function, does not apply it
- does not seem one can define a function as a piped operation

    ```julia
    transition_frequencies = normalize_array ∘ transition_counts;
    transition_frequencies(first_sample)

    # composing more than two this way works, but not sure about ordering
    transition_frequencies_alt = normalize_array ∘ transition_counts ∘ identity
    # or

    ∘(f, g, h) = f ∘ g ∘ h  # multi-function composition
    ```

- Splatting. e.g. in context of function composition? Need to understand better
    - splatting `∘(fs...)` for composing an iterable collection of functions.
- Problem with `begin ... end` block in Pluto: scoping prevents result from being visible in other Pluto cells?
- Two solutions to "Which letter is most likely to precede a W?"
    - one with and argmax, and indexing:
    ```julia
    # terse but hard to read:
    most_likely_to_precede_w = alphabet[argmax(sample_freq_matrix[:, index_of_letter('w')])]
    ```
    - one with Pipe (need Pipe.jl package)

    ```julia
    # Can this be done more clealy with a chain of operations or a pipe?
    #   see https://juliapackages.com/p/pipe
    most_likely_to_precede_w_alt = @pipe sample_freq_matrix |> 
        _[:,index_of_letter('w')] |>
        argmax(_) |>
        alphabet[_]
    ```
- cost of this more flexible `pipe` from `Pipe.jl`?: one evaluation for each ref to `_` in a step?
- **Exercise 2.4 - write a novel**
    - can we compare our results using the same random seed?
    ```julia
    import Random
    Random.seek(3)
    ```
- Q in `function generate_from_ngrams(grams, num_words)`
    - what is the difference between
        - `sequence = [rand(grams)...]`
        - and
        - `sequence = [rand(grams)...]`
    - Q: is this a potential off-by-one type error?
    ```julia
    sequence = [rand(grams)...]
	
	# we iteratively add one more word at a time
	for i ∈ n+1:num_words
		# the previous n-1 words
		tail = sequence[end-(n-2):end]
		
		# possible next words
		# Q: this is guaranteed to be in cache by construction UNLESS it is the tail of the last ngram in the original sample in the cache. E.g. "Happily every after"
		completions = cache[tail]
    ```
    - Oops - now I see this is to be addressed with circular ngrams_circular!

### Comments on HW4
- Julia packages: did you `import` or `using` any?
    - `StatsBase`
- Pluto help:
    - wish that the source package of functions was indicated
    - links to full docmentation would be great (e.g. `bar`)
- I found the specification of docstrings for all functions defined to be very helpful in building the simulation
- In Ex. 3.1
    - what is `run_basic_sir`
    - important distinction between scope of variables in `function`, `begin`, `let`:
        - "So like `begin`, `let` is just a block of code, but like `function`, it has a local variable scope."
        - Q: is a `let` good for anything but side effects (nothing is returned from `let` block)

- In Ex 3.2, 
    - this null `map` over an iteration index, rather than `for` was interesting:
    ```julia
    map(1:num_simulations) do _
		simulation(N, T, infection)
    end
    ```
    - advantage over for loop: it returns an array of the iteration results
    ```julia
    map(1:10) do _
	    rand()
    end
    ## Float64[0.553734, 0.447052, 0.919346, 0.86072, 0.451468, 0.460716, 0.342783, 0.9844, 0.802388, 0.727907]
    for i in (1:10)
	    rand()
    end
    ## # (returns nothing)
    ```
- How did your error-bar graph look?
    - works if one replaces `yerror` with `ribbon`
- Ex 4.2 Qualitative behavior with Reinfection model of AbstractInfection
    - new model required only the 
        - new `Refinfection::AbstractInfection` type definition, 
        - new method for the `interact!` function and 
        - different call to `RepeatSimulations`, which is cool:
    ```julia
    repeat_simulations(100, 1000, Reinfection(p_infection, p_recovery), 20)
    ```
### HW3 and HW4 Numerical Modeling notes
-  geometric growth versus exponential growth comment:
    - Comment: fitting exponential growth with least squares on c e to the RT will not give the same results necessarily as fitting they assumed underlying linear function log c plus TR. We can do this quickly and compare the numerical results. Speaking here of the first lecture on  COVID data analysis p
- generators versus arrays
    - @22:30  https://youtube.com/playlist?list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ 
- randomness in a sample distribution: how close should it be to theoretical distribution
    - @18:10 https://youtube.com/playlist?list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ 
    - for random sample from any distribution you do not expect the sample to precisely conform to the distribution. So for a uniform distribution if the sample were to indeed be uniform that should be surprising. Can we compare the observed standard deviation from uniformity with the expected standard deviation given the sample size to assess whether the degree of clumpiness is in fact consistent with randomness?

### HW5
- Doc strings for Structs: work OK. Doc strings are mean to be applicable to any Julia object
- function overloading (extension?) in Pluto: surprising that `trajectory(w::Coordinate, n::Int, L::Number)` can be defined in separate Pluto cell from `trajectory(w::Coordinate, n::Int, L::Number)`?
- Keyword Args in functions:
    - R lets you designate parameters in order OR with keywords.
        - `foo(x=1, y=2, z=3) {return} # function definition`
        - `foo(13, 11, 9) # OK call, foo(x=13, y=11, z=9)`
        - `foo(y=64) # OK call, foo(x=1, y=64, z=3)`
    - Julia requires explicit use of keywords in a function call to designate their non-default value.
- Ex. 1.6 How can one use a (2-arg) anonymous function as accumulator operation in `accumulate`
    - Implement a 3-argument method  of `trajectory` where the third argument is a size. The trajectory returned should be within the boundary (use `collide_boundary` from above). You can still use `accumulate` with an anonymous function that makes a move and then reflects the resulting coordinate, or use a for loop.
- Ex 3.1 in `interact!`, infected source recovers only if interact and possible transmission, or only if interact??
- In Ex 3.2 why did `set_status!` not work in `interact!`

### Notes and Comments on HW6 (and associated lectures)
- in HW6, `function euler_integrate_step`
    - I'm confused by the problem statement
    - why is solution `fa + fprime(a+h)*h` rather than `fa + fprime(a)*h` (the latter being the classical Euler Method)
    - apparently this is a common error
- in HW6,   `euler_test` of `euler_integrate`, got error

        euler_test
        InexactError: Int64(0.012000000000000004)

    - "InexactError happens when you try to convert a value to an exact type (like integer types, but unlike floating-point types) in which the original value cannot be exactly represented."
    - got this because I did not properly initialize the type of the storage array (pythonic error)
    - Broad insight: If you need a (possibly local) variable or vector Y of the same type and dimension as another X, use

        `Y = similar(X)`

        similar(array, [element_type=eltype(array)], [dims=size(array)])

        Create an _uninitialized_ mutable array with the given element type and size, based upon the given source array. The second and third arguments are both optional, defaulting to the given array's eltype and size. The dimensions may be specified either as a single tuple argument or as a series of integer arguments.

    
- awkward programming in function `function euler_SIR`

## Notes and Comments on HW7 Raytracing in 2D (and associated lectures)

#### Light Propagation, Relection and Refraction
- Index of refraction, $\eta = IOR$ and the speed of light in a medium
    - for any medium *i*, the speed of light in the medium $s_i$ is equal to *c*, the speed of light in a vacuum, divided by the Index of Refraction for medium *i*
        - $s_i = c/\eta_i = s_{vacuum}/\eta_i$
        - The index of refraction for a vacuum is 1.0, and for air it is close to 1.0
            - for water, the index of refraction is greater than 1 (light is slower than *c*)
    $$\eta_{air}  s_{air} = \eta_{water} s_{water}$$
    - more generally, the speed of light in a medium is inversely proportional to the index of refraction in the medium
    $$\eta_{air}  s_{air} = \eta_{water} s_{water}$$
    $$\eta_{x}  s_{x} = \eta_{y} s_{y}$$
    - for $s_i$ the speed of light in the mdium
- stepwise simulation/advancement of a ray

    ```julia
    mutable struct Ray
        l::Vector{Float64} # ray direction velocity vector
        p::Vector{Float64} # ray position
        ior::Float64 # index of refraction
    end


    function step!(ray::Ray, dt)
        ray.p .+= ray.l .* dt /ray.ior
    end
    ```

    ```julia
    """
        propagate!(rays::Vector{Ray}, positions, n, dt)

    `positions` is an array for length(rays) x n-steps x d-dimension position coordinates
    (the positions of all rays at all steps in the propagation)
    `n` is the number of steps the rays are to be propagated
    """
    function propagate!(rays::Vector{Ray}, positions, n, dt)
        ior = 1.0
        for i = 1:n
            for j = 1:length(rays)
                step!(rays[j], dt)
                positions[j, i, :] .= rays[j].p
            end
        end
    end

    function parallel_propagate(num_rays, n; filename = "check.png", dt = 0.1)
        rays = [ray([1, 0], # velocity l
            [0.1, float(i)], # position p
            1.0) for i in 1:num_rays] # ior
        positions = zeros[num_rays, n, 2] # storage for 2-d positions of num_rays rays for n steps

        propagate(rays, positions, n, dt) # move

        plot_rays(positions, filename) # display paths

        return(rays)
    end
    ```

- Reflection of a ray
    - Dot product: $\bold a \cdot \bold b$ is the projection of $\bold a$ onto $\bold b$.
        - $\bold a \cdot \bold b = |a| |b| cos(\theta)$ 
        - what is the intuition?
    
    ```julia
    """
        reflect!(ray, n)

    returns `ray` reflected off plane with normal `n`
    """
    function reflect!(ray, n)
        # just subtract 2 times component of ray along normal (parallel component unchanged)
        ray.l = ray.l - 2 * dot(ray.l, n) .* n # this is the same as reversing the sign of the normal component
        # ray.l .-= 2 * dot(ray.l, n) .* n # equivalently
    end
    ```

- Refraction of a ray
    - $c = s_i \eta_i$ for light speed $s_i$ in medium $i$ with index of refraction $ior = \eta_i$
        - speed $s_i$ in medium $i$ is inversely proportional to the index of refraction $s_i = c/\eta_i ~\propto ~ 1/\eta_i$
    - so the ratio of the index of refraction of two media is equal to the inverse ratio of the speeds in the two media
    $$\frac {\eta_i}{\eta_j} = \frac {s_j}{s_i}$$
    - **Snell's law** says, further that the ratio of speeds is equal to the ratio of sines of the angles (from normal) in each medium
    $$\frac {\eta_i}{\eta_j} = \frac {s_j}{s_i} = \frac {sin(\theta_j)}{sin(\theta_i)}$$
        - Intuition: as the light passes through the more refractive medium, it is bent toward the normal, and the lateral (parallel to the surface) component of its velocity/direction is foreshortened. Thus, with the direction as the hypotenuse and the normal as one side, the parallel component is to opposite side, and its shortening is proportional to $sin(\theta)$
            - this would imply that it is not all components of the speed, but the speed in the lateral direction parallel to the surface, that is reduced in proportion to the `IOR`, $\eta_j$
            - 
    - We wish to solve for the refracted angle in the second medium, $\theta_j$ given the indices of refraction, $\eta_i, \eta_j$ and the angle of incidence at the boundary (w.r.t. normal $\hat n$) of $\theta_i$
    $$\frac {\eta_i}{\eta_j} = \frac {sin(\theta_j)}{sin(\theta_i)}$$
    $${sin(\theta_j)} = \frac {\eta_i}{\eta_j} {sin(\theta_i)}$$
    $$\theta_j = sin^{-1} \left ( \frac {\eta_i}{\eta_j} {sin(\theta_i)} \right )$$
    - But, more usefully we also know the trig identity
    $$cos(\theta_j) = \sqrt {1 - sin^2(\theta_j)}$$
        - this allows us to eliminate refs to $sin$ with $cos$ expressions, and then replace references $cos$ with vector dot-product expressions.
    - so we can solve for $cos(\theta_j)$, substituting Snells law into the trig identity
    $$cos(\theta_j) = \sqrt {1 - \left (\frac {\eta_i}{\eta_j} sin(\theta_i) \right)^2}$$
    $$cos(\theta_j) = \sqrt {1 - \left (\frac {\eta_i}{\eta_j} \right)^2 (1- cos(\theta_i)^2)}$$
    $$cos(\theta_j) = \sqrt {1 - \left (\frac {\eta_i}{\eta_j} \right)^2 ( 1- (l_i \cdot \hat n |l_i| |\hat n|)^2)}$$
    - if both the normal vector and the direction vector $l_j$ are standardized/normalized to unit length (which is the case here).
        $$cos(\theta_j) = \sqrt {1 - \left (\frac {\eta_i}{\eta_j} \right)^2 (1 - (l_i \cdot \hat n)^2}$$
    - c.f the result shown @20:33 (what is $l$ here - its the vector, and it's the unit directional vector in water $w$, $\vec l_w$, right?s)
    $$cos(\theta_j) = \sqrt {1 - \left (\frac {\eta_i}{\eta_j} \right)^2 (1- cos(\theta_i)^2)} = -\hat n \cdot \vec l_w$$

    - puzzling at 15:35 in lecture 1 Wk 8 "Ray Tracing in 2D"
        - ??? says "$l_w = -n/cos(\theta_w)$"
            - he seems to be confusing vectors and their lengths in the notation, and confusing $l_w$ with its component along the normal ($n$).
        - ??? but "$cos(\theta_w) = -n/l_w$ (@15:57) only if $n$ and $l_w$ are lengths, not vectors, and if $n$ is the length of the projection of $l_w$ along $n$ (i.e. they are opposite and adjacent sides of a right triangle). I thought $n$ was the unit-length normal?
            - in the definition of `Ray` (@3:16, and as shown @11:08), `Ray.l` is the (2D) direction vector. 
                - Apparently also, something I missed, the direction vector $l$ also is meant to be of unit magnitude (speed, or the magnitude of motion in the direction $l$, is simply $c/n_i$ for light). Later, when the ray motion is not for light, the objects should have different speeds.
                - given the both $l$ and $n$ are defined to be of unit length (note they are not drawn as such), it is true the *projection of $l_w$ along $n$* is $cos(\theta_w) |l_w| = (l \cdot n)/|n|$.
        - draws line and restsarts at @16:30, for air and water
        - now confusing vector normal $n_i$ and scalar Index of Refraction $n_i$, ugh, for which we will use $\eta_i$
            - Note: the "hat" symbol is usually used to indicate the _unit-length_ vector $\hat x: |\hat x| =1$, and either bold or a little arrow above is used to denote a vector of arbitrary length ($\bold x$ or $\vec x$ = $\overrightarrow x$)
                - a normal vector is orthogonal (normal to the surface), and may, or may not be a unit normal (orthogonal and of length 1.0)
                    - e.g. "a normal vector can be divided by its length to get a unit normal vector." http://sites.math.washington.edu/~king/coursedir/m445w04/notes/vector/normals-planes.html
                    - @19:30 says "if A and B are normalized and therefor [of length] 1": note/warning: "normalized" length is not the same a "normal"
                - but the hat doesn't help: I still dont see that $l_w = - \hat n / cos(\theta_w$, because the adjacent over hypotenuse interpretation of cos only applies for vector magnitudes, and now he has an explict vector term on the RHS.)
        - says (Eq PX): $\eta_w l_w = \eta_a l_a + (\eta_a cos(\theta_a) - \eta_w cos(\theta_w) \cdot n$
            - Explanation???
            - $\eta_a cost(\theta_a) \hat n$ is a projection onto the normal above (the water in the air), and 
            - $-\eta_w cost(\theta_w) \hat n$ is a projection onto the normal below (in the water) 
            - to solve this (for $cos(\theta_w$ or $l_w$), need to know $l_w$ or $cos(\theta_w$)
        - @18:12 "We can't use any wishy-washy math to kind of wave them away like a lot of physicists do." Ouch

    - define this *cos* of refracted $\theta_j$ as $u$ (James Schloss proposes $c$, but that is speed of light)
            $$u \equiv cos(\theta_j) = -\hat n \cdot \vec l_w$$
    - define: ratio of index of refration in incident media over refracted media 
            $$r \equiv \eta_i/\eta_j = \eta_a/\eta_w$$
    - From Eq. PX: (this equation also uses "dot" for the scalar mult of a vector - ugh)
        - $\eta_w \vec l_w = \eta_a \vec l_a + (\eta_a cos(\theta_a) - \eta_w cos(\theta_w) \hat n$
        - $\vec l_w = \frac {\eta_a} {\eta_w } \vec l_a + (\frac {\eta_a} {\eta_w } cos(\theta_a) - cos(\theta_w) \hat n$
        - $\vec l_w = r \vec l_a + (r cos(\theta_a) -  cos(\theta_w) \hat n$
    - and James S. says (but the algebra looks sketchy) that the final equation to solve for refracted $l_w$ is
        - $\vec l_w = r \vec l_a + (r u -  \sqrt {1 - r^2 u^2}) \hat n$
        - this does not match the equation used below in the code snippet (which uses $(1-u^2)$ vs $u^2$).
        - its pretty clear that $u = cos(\theta_a)$, the *cos* of the incident angle w.r.t. normal, not what he has written @21:38 

    - in code

        ```julia
        """
            refract!(ray, n)

        ray::Ray is incident ray 
        n is a 2-D vector normal to incident surface
        """ 
        refract!(ray, n)
            u = - dot(ray.l, n) # cos of incident angle
            d = 1.0 - ior^2 * (1-u^2)) # ior is the ratio of incident to refracting media refractive indices
            if (d < 0.0) # need to check the sign of the discriminant from the quadratic eqn
                # Note this corresponds to complete reflection (total internal reflection),
                #  for large incidence angle (u~0) or big increase in refractive index (low ratio)
                return zeros(2); # why the semicolon? 
            end
            ray.l = ior * ray.l + (ior * u - sqrt(d)) * n
        end 
        ```

#### Lenses: Spherical Lenses
- treat entering and leaving the refracting medium (lens) separately
- whether ray is entering or leaving is indicated by the direction of the normal
- convention for defining the normal based on the difference between the Ray position (tip) and lens position (center):
    $$\hat n = normalized(Ray.p - lens.p)$$
    - this convention means normal is projected outward from the refracting medium at both surfaces, entering and exiting
    - thus $sign(\hat n \cdot \vec l)$, dot product of normal with ray _direction_ $l$ indicates whether ray entering (<0) or leaving (> 0)





#### In the Billiard Model and Event-driven Simulations Lecture (week 8)
- Time stepping of dynamic physical models is inefficient, so look for next intersection/collision time of objects
    - "Event" is a collision with a boundary
    - **Event Driven Simulation**: simulation goes from event to event, rather then time step to time step. Time between events (and identity/nature of next event) is calculated.
- formula for determining time of colliion between point-size particle with constant velocity (linear motion) and wall was very clever, with good intuitive insight (@10:14 in video)
    - moving particle (point-sized object) with velocity $\bold v$ and initial position $\bold x_0$ has position at time $t$ of $\bold x(t) = \bold x_0 + t \bold v$
    - a (hyper)plane $H$ going through point $\bold p$ with normal $\bold n$ can be described by 
    $$H(\bold p, \bold n) = \{ \bold x: \bold x \cdot \bold n = c, ~where~ c = \bold p \cdot \bold n \}$$
        - i.e. if point $\bold p$ lies on a plane with normal $\bold n$, then all other points on the plane satisfy $(\bold x - \bold p) \cdot \bold n = 0$ (the vector from $\bold p$ to $\bold x$ must be along the plane and therefor orthogonal to the normal)
    - so we know that a moving particle on trajectory $\bold x(t)$ will collide with the plane $H$ (be on the plane) at time $t^*$ when it satisfies the condition for points on the plane $(\bold x(t^*) - \bold p) \cdot \bold n = 0$
        - for a linear trajectory $\bold x(t) = \bold x_0 + t \bold v$ we can solve for collision time
        $$(\bold x_0 + t^* \bold v - \bold p) \cdot \bold n = 0$$
        - that is, solving for $t^*$:
        $$\bold x_0 \cdot \bold n + t^* \bold v \cdot \bold n - \bold p \cdot \bold n = 0$$
        $$t^*  = \frac {(\bold p - \bold x_0) \cdot \bold n}{\bold v \cdot \bold n}$$
        - This has the intuitive interpretation that time to collision is (shortest) distance to the plane in the perpendicular direction from the initial position $\bold x_0$ divided by the velocity component that is normal to the plane
            - Detail: we did not assert that the normal vector $\bold n$ was a unit vector $|\bold n|=1$, which is necessary for $\bold v \cdot \bold n = cos(\theta) |\bold v||\bold n|$ to be the length of the velocity component normal to the plane and $(\bold p - \bold x_0) \cdot \bold n$ the distance to the plane. But in the solution for $t^*$ the length of $\bold n$ cancels out, so the interpertation of the ratio is still valid.

#### Collision Reflection Modeling
- Good discussion of reflection after collision in Wk 8 Lect 15 (@15:40)
    - for wall/plane unit normal $\bold n$, after collision velocity vector has the same component parallel to the plane, and the negative of its previous component perpendicular/normal to the plane:
    $$\bold v = \bold v_p + \bold v_n$$
    $$\bold v' = \bold v_p - \bold v_n = \bold v - 2 \bold v_n$$
    $$\bold v' = \bold v - 2 (\bold v \cdot \bold n) \bold n$$

#### Deterministic Chaos in Particle Motion
- in particle motion, in billiard ball system with stadium-shaped bounds, and particle starting at same point and direction with slightly different velocities (Lect 15 @15:46-17:12)
    - interesting diffusion of particles when reflected off curved surface, but not when reflected off planar surface.
        - Why? Not yet explained at that point
    - chaotic, [ergodic](https://en.wikipedia.org/wiki/Ergodicity) system "fills the phase space" of velocities and positions
        - "ergodicity expresses the idea that a point of a moving system, either a dynamical system or a stochastic process, will eventually visit all parts of the space that the system moves in, in a uniform and random sense." https://en.wikipedia.org/wiki/Ergodicity
        - Sanders: "two nearby initial conditions spread out exponentially fast in time"
    - `InteractiveChaos`, `DynamicalBilliards`, `Makie::visualize3d`

- Collisions with Curved Surfaces (Spheres)
    - def of boundary of sphere $S(\bold c, r)$ centered at $\bold c$ with radius r:
        $$S(\bold c, r) = \{\bold x: ||\bold x - \bold c|| = r \}$$
        $$S(\bold c, r) = \{\bold x: (\bold x - \bold c) \cdot (\bold x - \bold c) = r^2 \}$$
    - collision of point particle in linear motion $\bold x(t) =  \bold x_0 + t \bold v$ occurs when $\bold x(t)$ is on boundary of sphere $S(\bold c, r)$
        $$(\bold x(t^*) - \bold c) \cdot (\bold x(t^*) - \bold c) = r^2$$
        $$(\bold x_0 + t^* \bold v - \bold c) \cdot (\bold x_0 + t^* \bold v - \bold c) = r^2$$
    - solving for $t^*$
        $$(\bold x_0 - \bold c) \cdot (\bold x_0 - \bold c) - r^2 -2 t^* \bold v \cdot (\bold x_0 - \bold c) +  (t^*)^2 (\bold v \cdot \bold v)  = 0$$
        - solve for roots of this quadratic equation in $t^*$: $a t^2 + b t + c = 0$
            - $a = (\bold v \cdot \bold v)$
            - $b = -2 \bold v \cdot (\bold x_0 - \bold c)$
            - $c = ((\bold x_0 - \bold c) \cdot (\bold x_0 - \bold c) - r^2)$

### Notes on HW7 itself
- in the lectures and in the homework, they blur the [distinction between a "normal vector" and a "unit normal" vector.](https://www.khanacademy.org/math/multivariable-calculus/integrating-multivariable-functions/flux-in-3d-articles/a/unit-normal-vector-of-a-surface) That is, the do computations that imply the normal (orthogonal) vector has length 1, but that is not part of the definition of a normal vector.
    - in the initialization of `Wall.normal` in the `struct Wall`, they call the function `normalize(normal)` which "normalizes" or standardizes the length of a vector to 1.0, but that function does _not_ make the vector `normal` orthogonal to anything. So this is a bit confusing.
    - [Etymology of the word “normal” (perpendicular)](https://math.stackexchange.com/questions/328662/etymology-of-the-word-normal-perpendicular)

    ```julia
    # note that the function `normalize` just rescales a vector/array to unit length
    #  (nothing to do with normal-as-in-orthogonal)
    transpose(normalize([3,1]))*normalize([3,1]) ≈ 1.0 # true
    # or
    dot(normalize([3,1]), normalize([3,1]))y ≈ 1.0 # true
    ```


## Notes on 3-D Ray TRracing and HW 8
- James says "Camera: For the purposes of this homework, we will constrain ourselves to a camera pointing exclusively downward."
    - does "downward" just mean that the 2D screen/window (image plane) is a plane orthogonal to the shortest vector from the center of the camera sphere?
    - Or does this just define the image plane (screen) to be parallel to the x-y plane, and place the camera in the positive direction on the z-axis (camera center location is [0, 0, -focal_length]) relative to center screen?
- Important to clarify: 
    - the camera "image plane" is the camera aperture, of specified `Camera.aperture_width` and `Camera.resolution` (pixel dimensions)
    - `focal_length::Float64` "Camera's distance from screen" is <0 if camera "above" on z axis
- `HW8 function `init_rays()` uses broadcasting in interesting ways
    - Q: in `function init_rays(cam::Camera)`, why do the pixel x-coords (xs) go from pos to neg, while y-coords (ys) gofrom neg to pos?
    - in function
        - rather than 
        ```julia
        function gradient_skybox_color(position, skybox) 
        ...
            if position[1] < extents && position[1] > -extents
        ```
        - how about more Julianic and elegant
        ```julia
        function gradient_skybox_color(position, skybox)
        ...
            if -extents < position[1] < extents 
        ```
- *Aside*: the VSCode preview of markdown is top notch, preview text in the buffer (need not save), rendering many features (equations, tables, syntax-highlighted code) and moving the focus to follow the cursor in the text window.
- **Q re `methods`:** did you notice that `methods(foobar)` shows all the methods and a hyperlink to their location in a file (but not a link to the open Pluto notebook).

        methods(interact)

        # 2 methods for generic function interact:
        interact(photon::Main.workspace16.Photon, ::Main.workspace3.Miss, ::Any, ::Any) in Main.workspace16 at /Users/paulleiby/Documents/Programming/Julia/computationalthinking/hw/homework8/hw8.jl#==#086e1956-204e-11eb-2524-f719504fb95b:1
        interact(ray::Main.workspace16.Photon, hit::Main.workspace3.Intersection{Main.workspace121.SkyBox}, ::Any, ::Any) in Main.workspace121 at /Users/paulleiby/Documents/Programming/Julia/computationalthinking/hw/homework8/hw8.jl#==#a9754410-204d-11eb-123e-e5c5f87ae1c5:1

- `interact(ray::Photon, hit::Intersection{SkyBox}` This models absorbtion/transmission of the photon by the skybox, and producing only color (no reflection or refraction)

- **Q re compound type declarations:** How do we understand these
    ```julia
    function intersection(photon::Photon, sphere::S; ϵ=1e-3) where {S <: Union{SkyBox, Sphere}}

    function step_ray(ray::Photon, objects::Vector{O},
			   num_intersections) where {O <: Object}
    ```
## Dataframes
- [Data Wrangling with DataFrames.jl Cheat Sheet](https://ahsmart.com/pub/data-wrangling-with-data-frames-jl-cheat-sheet/index.html)
    - Cheatsheet: https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v0.22_rev1.pdf
    - this parallels the Tidy R equivalent, and the [Data Wrangling with dplyr and tidyr Cheat Sheet](https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)

## Supplemental Information

- [MIT 6.0002 Introduction to Computational Thinking and Data Science](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-0002-introduction-to-computational-thinking-and-data-science-fall-2016/)
Instructor(s) Prof. Eric Grimson, Prof. John Guttag, Dr. Ana Bell, MIT Course Number 6.0002. As Taught In Fall 2016
    - 6.0002 is the continuation of [6.0001 Introduction to Computer Science and Programming in Python](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016) and is intended for students with little or no programming experience.
    - Taught in Python
- [MIT 18S190 Spring 2020 Introduction to Computational Thinking with Julia, with Applications to Modeling the COVID-19 Pandemic](https://ocw.mit.edu/courses/mathematics/18-s190-introduction-to-computational-thinking-with-julia-with-applications-to-modeling-the-covid-19-pandemic-spring-2020/) Instructor(s) Prof. Alan Edelman, Prof. David P. Sanders, MIT Course Number 18.S190 / 6.S083. As Taught In
Spring 2020
    - This half-semester course introduces computational thinking through applications of data science, artificial intelligence, and mathematical models using the Julia programming language. This Spring 2020 version is a fast-tracked curriculum adaptation to focus on applications to COVID-19 responses.
    - [MIT 18S190 Spring 2020 - Course Materials](https://ocw.mit.edu/courses/mathematics/18-s190-introduction-to-computational-thinking-with-julia-with-applications-to-modeling-the-covid-19-pandemic-spring-2020/course-materials/)

- [Julia A Concise Tutorial](https://syl1.gitbook.io/julia-language-a-concise-tutorial/) for a pretty good rapid overview
