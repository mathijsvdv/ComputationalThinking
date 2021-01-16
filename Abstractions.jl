### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ b2f02100-576f-11eb-3453-ff071cb563df
begin
	using Pkg; Pkg.add(["Images", "ImageIO", "ImageMagick"])
	using Images
end

# ╔═╡ 19b34ee0-576f-11eb-350f-2bbb4050b1db
element = 1 // 1

# ╔═╡ 33005be0-576f-11eb-06d7-0d2df9299f71
fill(element, 3, 4)

# ╔═╡ 41dd7170-576f-11eb-1ae2-cb1e4b6a63bc
typeof(element)

# ╔═╡ 491d1080-576f-11eb-2ce6-fd4f20efecda
keeptrack = (typeof(1), typeof(1.0), typeof("one"), typeof(1 // 1))

# ╔═╡ 5a3b1560-576f-11eb-2584-ad4e0fa643b8
typeof(keeptrack)

# ╔═╡ a84b36e0-576f-11eb-208a-e7b829b847a9
A1 = rand(1:9, 3, 4)

# ╔═╡ 8f3617e0-5771-11eb-23ff-b1f1f5f85951


# ╔═╡ Cell order:
# ╠═b2f02100-576f-11eb-3453-ff071cb563df
# ╠═19b34ee0-576f-11eb-350f-2bbb4050b1db
# ╠═33005be0-576f-11eb-06d7-0d2df9299f71
# ╠═41dd7170-576f-11eb-1ae2-cb1e4b6a63bc
# ╠═491d1080-576f-11eb-2ce6-fd4f20efecda
# ╠═5a3b1560-576f-11eb-2584-ad4e0fa643b8
# ╠═a84b36e0-576f-11eb-208a-e7b829b847a9
# ╠═8f3617e0-5771-11eb-23ff-b1f1f5f85951
