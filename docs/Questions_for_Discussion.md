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
    - For Sobel Edge - did you detect edge for each color/channel separately?

    
### Supplemental Information
- [MIT 6.0002 Introduction to Computational Thinking and Data Science](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-0002-introduction-to-computational-thinking-and-data-science-fall-2016/)
Instructor(s) Prof. Eric Grimson, Prof. John Guttag, Dr. Ana Bell, MIT Course Number 6.0002. As Taught In Fall 2016
    - 6.0002 is the continuation of [6.0001 Introduction to Computer Science and Programming in Python](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016) and is intended for students with little or no programming experience.
    - Taught in Python
- [MIT 18S190 Spring 2020 Introduction to Computational Thinking with Julia, with Applications to Modeling the COVID-19 Pandemic](https://ocw.mit.edu/courses/mathematics/18-s190-introduction-to-computational-thinking-with-julia-with-applications-to-modeling-the-covid-19-pandemic-spring-2020/) Instructor(s) Prof. Alan Edelman, Prof. David P. Sanders, MIT Course Number 18.S190 / 6.S083. As Taught In
Spring 2020
    - This half-semester course introduces computational thinking through applications of data science, artificial intelligence, and mathematical models using the Julia programming language. This Spring 2020 version is a fast-tracked curriculum adaptation to focus on applications to COVID-19 responses.
    - [MIT 18S190 Spring 2020 - Course Materials](https://ocw.mit.edu/courses/mathematics/18-s190-introduction-to-computational-thinking-with-julia-with-applications-to-modeling-the-covid-19-pandemic-spring-2020/course-materials/)

