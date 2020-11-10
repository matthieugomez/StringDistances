[![Build Status](https://travis-ci.org/matthieugomez/StringDistances.jl.svg?branch=master)](https://travis-ci.org/matthieugomez/StringDistances.jl)
[![Coverage Status](https://coveralls.io/repos/matthieugomez/StringDistances.jl/badge.svg?branch=master)](https://coveralls.io/r/matthieugomez/StringDistances.jl?branch=master)

## Installation
The package is registered in the [`General`](https://github.com/JuliaRegistries/General) registry and so can be installed at the REPL with `] add StringDistances`.

## Supported Distances

Distances are defined for `AbstractStrings`, and any iterator that define `length()` (e.g. `graphemes`, `AbstractVector`...)

The available distances are:

- Edit Distances
	- Hamming Distance `Hamming()`
	- [Jaro Distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) `Jaro()`
	- [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance) `Levenshtein()`
	- [Damerau-Levenshtein Distance](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance) `DamerauLevenshtein()`
	- [RatcliffObershelp Distance](https://xlinux.nist.gov/dads/HTML/ratcliffObershelp.html) `RatcliffObershelp()`
- Q-gram distances compare the set of all substrings of length `q` in each string.
	- QGram Distance `Qgram(q::Int)`
	- [Cosine Distance](https://en.wikipedia.org/wiki/Cosine_similarity) `Cosine(q::Int)`
	- [Jaccard Distance](https://en.wikipedia.org/wiki/Jaccard_index) `Jaccard(q::Int)`
	- [Overlap Distance](https://en.wikipedia.org/wiki/Overlap_coefficient) `Overlap(q::Int)`
	- [Sorensen-Dice Distance](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient) `SorensenDice(q::Int)`
	- [MorisitaOverlap Distance](https://en.wikipedia.org/wiki/Morisita%27s_overlap_index) `MorisitaOverlap(q::Int)`
	- [NormalizedMultisetDistance](https://www.sciencedirect.com/science/article/pii/S1047320313001417) `NormalizedMultisetDistance(q::Int)` or `NMD(q::Int)`
- Distance "modifiers" that can be applied to any distance:
	- [Partial](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) returns the minimum of the normalized distance between the shorter string and substrings of the longer string.
	- [TokenSort](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) adjusts for differences in word orders by returning the normalized distance of the two strings, after re-ordering words alphabetically. 
	- [TokenSet](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) adjusts for differences in word orders and word numbers by returning the normalized distance between the intersection of two strings with each string.
	- [TokenMax](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) combines the normalized distance, the `Partial`, `TokenSort` and `TokenSet` modifiers, with penalty terms depending on string lengths. This is a good distance to match strings composed of multiple words, like addresses.   `TokenMax(Levenshtein())` corresponds to the distance defined in [fuzzywuzzy](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/)
	- [Winkler](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) diminishes the normalized distance of strings with common prefixes.  The Winkler adjustment was originally defined for the Jaro similarity score but it can be defined for any string distance.

## Basic Use

### evaluate
You can always compute a certain distance between two strings using the following syntax:

```julia
evaluate(dist, s1, s2)
dist(s1, s2)
```

For instance, with the `Levenshtein` distance,

```julia
evaluate(Levenshtein(), "martha", "marhta")
Levenshtein()("martha", "marhta")
```

### pairwise
`pairwise` returns the matrix of distance between two `AbstractVectors`

```julia
pairwise(Jaccard(3), ["martha", "kitten"], ["marhta", "sitting"])
```
It is particularly fast for QGram-distances (each element is processed once).

### compare
The function `compare` is defined as 1 minus the normalized distance between two strings. It always returns a `Float64` between 0.0 and 1.0: a value of 0 means completely different and a value of 1 means completely similar.

```julia
evaluate(Levenshtein(),  "martha", "martha")
#> 0.0
compare("martha", "martha", Levenshtein())
#> 1.0
```


### find
- `findnearest` returns the value and index of the element in `itr` with the lowest distance with `s`. Its syntax is:
	```julia
	findnearest(s, itr, dist::StringDistance; min_score = 0.0)
	```

- `findall` returns the indices of all elements in `itr` with a similarity score with `s` higher than a minimum value (default to 0.8). Its syntax is:
	```julia
	findall(s, itr, dist::StringDistance; min_score = 0.8)
	```

The functions `findnearest` and `findall` are particularly optimized for `Levenshtein` and `DamerauLevenshtein` distances (as well as their modifications via `Partial`, `TokenSort`, `TokenSet`, or `TokenMax`).


## References
- [The stringdist Package for Approximate String Matching](https://journal.r-project.org/archive/2014-1/loo.pdf) Mark P.J. van der Loo
- [fuzzywuzzy](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/)


