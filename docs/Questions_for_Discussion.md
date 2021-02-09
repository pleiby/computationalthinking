Questions for Discussion - Computational Thinking
===================================================

#### Re MIT Course 18.S181 Computational Thinking, Fall 2020

### Comments on Pluto file format
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
### Questions on Course 18.S181 HW 1
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
#### Notes on Lecture 3 Seam Carving
- does seam cutting bias the presernvatoin of info in a particular (vertical) direction?
- re convolution: in what sense is convolution kernel "flipped," as Grant Sanderson says?
- re Dynamic Programming: this is closely related to graph shortest paths, and the Bellman Optimality Principle (subsections of shortest paths are also shortest paths between their origin and dest)
#### Notes on Array Slice and Views
- slices are copies (views are not)
    - are `reshape` and `vec` copies or views?
- arrays in Julia are column major
- Julia macros @ are really powerful, but somewhat cryptic

#### Notes on HW2
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

#### PCA
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

#### Comments on HW3
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
#### HW3 and HW4 Numerical Modeling notes
- - geometric growth versus exponential growth comment:
    - Comment: fitting exponential growth with least squares on c e to the RT will not give the same results necessarily as fitting they assumed underlying linear function log c plus TR. We can do this quickly and compare the numerical results. Speaking here of the first lecture on  COVID data analysis p
- generators versus arrays
    - @22:30  https://youtube.com/playlist?list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ 
- randomness in a sample distribution: how close should it be to theoretical distribution
    - @18:10 https://youtube.com/playlist?list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ 
    - for random sample from any distribution you do not expect the sample to precisely conform to the distribution. So for a uniform distribution if the sample were to indeed be uniform that should be surprising. Can we compare the observed standard deviation from uniformity with the expected standard deviation given the sample size to assess whether the degree of clumpiness is in fact consistent with randomness?
### Dataframes
- [Data Wrangling with DataFrames.jl Cheat Sheet](https://ahsmart.com/pub/data-wrangling-with-data-frames-jl-cheat-sheet/index.html)
    - Cheatsheet: https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v0.22_rev1.pdf
    - this parallels the Tidy R equivalent, and the [Data Wrangling with dplyr and tidyr Cheat Sheet](https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)

### Supplemental Information

- [MIT 6.0002 Introduction to Computational Thinking and Data Science](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-0002-introduction-to-computational-thinking-and-data-science-fall-2016/)
Instructor(s) Prof. Eric Grimson, Prof. John Guttag, Dr. Ana Bell, MIT Course Number 6.0002. As Taught In Fall 2016
    - 6.0002 is the continuation of [6.0001 Introduction to Computer Science and Programming in Python](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016) and is intended for students with little or no programming experience.
    - Taught in Python
- [MIT 18S190 Spring 2020 Introduction to Computational Thinking with Julia, with Applications to Modeling the COVID-19 Pandemic](https://ocw.mit.edu/courses/mathematics/18-s190-introduction-to-computational-thinking-with-julia-with-applications-to-modeling-the-covid-19-pandemic-spring-2020/) Instructor(s) Prof. Alan Edelman, Prof. David P. Sanders, MIT Course Number 18.S190 / 6.S083. As Taught In
Spring 2020
    - This half-semester course introduces computational thinking through applications of data science, artificial intelligence, and mathematical models using the Julia programming language. This Spring 2020 version is a fast-tracked curriculum adaptation to focus on applications to COVID-19 responses.
    - [MIT 18S190 Spring 2020 - Course Materials](https://ocw.mit.edu/courses/mathematics/18-s190-introduction-to-computational-thinking-with-julia-with-applications-to-modeling-the-covid-19-pandemic-spring-2020/course-materials/)

- [Julia A Concise Tutorial](https://syl1.gitbook.io/julia-language-a-concise-tutorial/) for a pretty good rapid overview
