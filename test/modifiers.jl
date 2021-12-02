
using StringDistances, Unicode, Test

@testset "Modifiers" begin
	# Partial
	@test Partial(QGram(2))("martha", "marhta") == 6
	@test Partial(QGram(2))("martha", missing) === missing
	@test Partial(Levenshtein())("martha", "marhta") == 2
	@test Partial(RatcliffObershelp())("martha", "marhta") ≈ 0.16666666 atol = 1e-5
	@test Partial(RatcliffObershelp())("martha", "marhtaXXX") ≈ 0.16666666 atol = 1e-5
	@test Partial(RatcliffObershelp())("martha", missing) === missing

	# TokenSort
	@test TokenSort(QGram(2))("martha", "marhta") == 6
	@test TokenSort(QGram(2))("martha", missing) === missing
	@test TokenSort(Levenshtein())("martha", "marhta") == 2
	@test TokenSort(RatcliffObershelp())("martha", "marhta") ≈ 0.16666666 atol = 1e-5

	# TokenSet
	@test TokenSet(QGram(2))("martha", "marhta") == 6
	@test TokenSet(QGram(2))("martha", missing) === missing
	@test TokenSet(Levenshtein())("martha", "marhta") == 2
	@test TokenSet(RatcliffObershelp())("martha", "marhta") ≈ 0.16666666 atol = 1e-5

	# TokenMax
	@test TokenMax(QGram(2))("martha", "marhta") ≈ 0.6
	@test TokenMax(QGram(2))("martha", missing) === missing
	@test TokenMax(Levenshtein())("martha", "marhta") ≈ 1/3
	@test TokenMax(RatcliffObershelp())("martha", "marhta") ≈ 0.16666666 atol = 1e-5
end

@testset "Compare" begin
	# Qgram
	@test compare("", "abc", QGram(1)) ≈ 0.0 atol = 1e-4
	@test compare("abc", "cba", QGram(1)) ≈ 1.0 atol = 1e-4
	@test compare("abc", "ccc", QGram(1)) ≈ 1/3 atol = 1e-4
	compare("aüa", "aua", TokenMax(QGram(2)))
	@test compare("", "abc", Jaccard(2)) ≈ 0.0 atol = 1e-4
	@test compare("martha", "martha", Jaccard(2)) ≈ 1.0 atol = 1e-4
	@test compare("martha", "martha", Jaccard(2)) ≈ 1.0 atol = 1e-4
	@test compare("aa", "aa ", Partial(Jaccard(2))) ≈ 1.0
	@test compare("martha", "martha", Cosine(2)) ≈ 1.0 atol = 1e-4
	@test compare("martha", "martha", Overlap(2)) ≈ 1.0 atol = 1e-4
	@test compare("martha", "martha", SorensenDice(2)) ≈ 1.0 atol = 1e-4

	# Jaro
	@test compare("aüa", "aua", Hamming()) ≈ 2/3
	@test compare("aüa", "aua", Jaro()) ≈ 0.77777777 atol = 1e-4
	@test compare("New York Yankees",  "", Partial(Jaro())) ≈ 0.0

	# JaroWinkler
	@test compare("martha", "marhta", JaroWinkler()) ≈ 0.9611 atol = 1e-4
	@test compare("dwayne", "duane", JaroWinkler()) ≈ 0.84 atol = 1e-4
	@test compare("dixon", "dicksonx", JaroWinkler()) ≈ 0.81333 atol = 1e-4
	@test compare("william", "williams", JaroWinkler()) ≈ 0.975 atol = 1e-4
	@test compare("", "foo", JaroWinkler()) ≈ 0.0 atol = 1e-4
	@test compare("a", "a", JaroWinkler()) ≈ 1.0 atol = 1e-4
	@test compare("abc", "xyz", JaroWinkler()) ≈ 0.0 atol = 1e-4

	#Levenshtein
	compare("aüa", "aua", Levenshtein())
	@test compare("ok", missing, Levenshtein()) === missing
	compare("aüa", "aua", OptimalStringAlignment())
	@test StringDistances.Normalized(Partial(OptimalStringAlignment()))("ab", "cde") == 1.0
	@test compare("ab", "de", Partial(OptimalStringAlignment())) == 0

	# RatcliffObershelp
	@test compare("New York Mets vs Atlanta Braves", "", RatcliffObershelp())  ≈ 0.0
	@test round(Int, 100 * compare("为人子女者要堂堂正正做人，千万不可作奸犯科，致使父母蒙羞", "此前稍早些时候中国商务部发布消息称，中美经贸高级别磋商双方牵头人通话，中方就美拟9月1日加征关税进行了严正交涉。", RatcliffObershelp())) == 5
	compare("aüa", "aua", TokenMax(RatcliffObershelp()))
	@test compare("New York Yankees",  "Yankees", Partial(RatcliffObershelp())) ≈ 1.0
	@test compare("New York Yankees",  "", Partial(RatcliffObershelp())) ≈ 0.0
	#@test compare("mariners vs angels", "los angeles angels at seattle mariners", Partial(RatcliffObershelp())) ≈ 0.444444444444
	@test compare("HSINCHUANG", "SINJHUAN", Partial(RatcliffObershelp())) ≈ 0.875
	@test compare("HSINCHUANG", "LSINJHUANG DISTRIC", Partial(RatcliffObershelp())) ≈ 0.8
	@test compare("HSINCHUANG", "SINJHUANG DISTRICT", Partial(RatcliffObershelp())) ≈ 0.8
	@test compare("HSINCHUANG",  "SINJHUANG", Partial(RatcliffObershelp())) ≈ 0.8888888888888
	@test compare("New York Mets vs Atlanta Braves", "Atlanta Braves vs New York Mets", TokenSort(RatcliffObershelp())) ≈ 1.0
	@test compare(graphemes("New York Mets vs Atlanta Braves"), graphemes("Atlanta Braves vs New York Mets"), Partial(RatcliffObershelp()))  ≈ compare("New York Mets vs Atlanta Braves", "Atlanta Braves vs New York Mets", Partial(RatcliffObershelp()))
	@test compare("mariners vs angels", "los angeles angels of anaheim at seattle mariners", TokenSet(RatcliffObershelp())) ≈ 1.0 - 0.09090909090909094
	@test compare("New York Mets vs Atlanta Braves", "", TokenSort(RatcliffObershelp()))  ≈ 0.0
	@test compare("mariners vs angels", "", TokenSet(RatcliffObershelp())) ≈ 0.0
	@test compare("mariners vs angels", "los angeles angels at seattle mariners", TokenSet(Partial(RatcliffObershelp()))) ≈ 1.0
	@test compare("mariners", "mariner", TokenMax(RatcliffObershelp())) ≈ 0.933333333333333
	@test compare("为人子女者要堂堂正正做人，千万不可作奸犯科，致使父母蒙羞", "此前稍早些时候中国商务部发布消息称，中美经贸高级别磋商双方牵头人通话，中方就美拟9月1日加征关税进行了严正交涉。", RatcliffObershelp()) ≈ 5 / 100 atol = 1e-2
	@test compare("为人子女者要堂堂正正做人，千万不可作奸犯科，致使父母蒙羞", "此前稍早些时候中国商务部发布消息称，中美经贸高级别磋商双方牵头人通话，中方就美拟9月1日加征关税进行了严正交涉。", Partial(RatcliffObershelp())) ≈ 7 / 100 atol = 1e-2
	@test compare("mariners", "mariner are playing tomorrow", TokenMax(RatcliffObershelp())) ≈ 79 / 100 atol = 1e-2
	@test compare("mariners", "mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow", Partial(RatcliffObershelp())) ≈ 88 / 100 atol = 1e-2
	@test compare("mariners", "mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow", TokenSort(RatcliffObershelp())) ≈ 11 / 100 atol = 1e-2
	@test compare("mariners", "are mariner playing tomorrow", RatcliffObershelp()) ≈ 39 / 100 atol = 1e-2
	@test compare("mariners", "are mariner playing tomorrow", Partial(RatcliffObershelp())) ≈ 88 / 100 atol = 1e-2
	@test compare("mariners", "mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow", TokenSet(RatcliffObershelp())) ≈ 39 / 100 atol = 1e-2
	@test compare("mariners", "mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow", TokenSet(Partial(RatcliffObershelp()))) ≈ 88 / 100 atol = 1e-2
	# not exactly the same because tokenmax has uses the max of rounded tokenset etc
	@test compare("mariners", "mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow mariner are playing tomorrow", TokenMax(RatcliffObershelp())) ≈ 78.75 / 100 atol = 1e-2



	# check min
	strings = [
	("martha", "marhta"),
	("dwayne", "duane") ,
	("dixon", "dicksonx"),
	("william", "williams"),
	("", "foo"),
	("a", "a"),
	("abc", "xyz"),
	("abc", "ccc"),
	("kitten", "sitting"),
	("saturday", "sunday"),
	("hi, my name is", "my name is"),
	("alborgów", "amoniak"),
	("cape sand recycling ", "edith ann graham"),
	( "jellyifhs", "jellyfish"),
	("ifhs", "fish"),
	("leia", "leela"),
	]
	for dist in (Levenshtein, OptimalStringAlignment)
		for i in eachindex(strings)
			if compare(strings[i]..., dist()) <  1 / 3
				@test compare(strings[i]..., dist() ; min_score = 1/ 3) ≈ 0.0
			else
				@test compare(strings[i]..., dist() ; min_score = 1/ 3) ≈ compare(strings[i]..., dist())
			end
		end
	end
end


@testset "Find*" begin
	# findnearest
	@test findnearest("New York", ["NewYork", "Newark", "San Francisco"], Levenshtein()) == ("NewYork", 1)
	@test findnearest("New York", ["San Francisco", "NewYork", "Newark"], Levenshtein()) == ("NewYork", 2)
	@test findnearest("New York", ["Newark", "San Francisco", "NewYork"], Levenshtein()) == ("NewYork", 3)
	@test findnearest("New York", ["NewYork", "Newark", "San Francisco"], Jaro()) == ("NewYork", 1)
	@test findnearest("New York", ["NewYork", "Newark", "San Francisco"], QGram(2)) == ("NewYork", 1)
	@test findnearest("New York", ["Newark", "San Francisco", "NewYork"], QGram(2)) == ("NewYork", 3)

	# findall
	@test findall("New York", ["NewYork", "Newark", "San Francisco"], Levenshtein()) == [1]
	@test findall("New York", ["NewYork", "Newark", "San Francisco"], Jaro()) == [1, 2]
	@test findall("New York", ["NewYork", "Newark", "San Francisco"], Jaro(); min_score = 0.99) == Int[]
	@test findall("New York", ["NewYork", "Newark", "San Francisco"], QGram(2); min_score = 0.99) == Int[]



	if VERSION >= v"1.2.0"
		@test findnearest("New York", skipmissing(["NewYork", "Newark", missing]), Levenshtein()) == ("NewYork", 1)
		@test findnearest("New York", skipmissing(Union{AbstractString, Missing}[missing, missing]), Levenshtein()) == (nothing, nothing)
		@test findall("New York", skipmissing(["NewYork", "Newark", missing]), Levenshtein()) == [1]
		@test findall("New York", skipmissing(Union{AbstractString, Missing}[missing, missing]), Levenshtein()) == []
	end
end
