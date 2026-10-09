local pending = "tokyonight-moon"
local scheme_to_pkg = {
	["tokyonight"] = "tokyonight.nvim",
	["rose-pine"] = "rose-pine",
	["github"] = "github-theme",
	["oxocarbon"] = "oxocarbon.nvim",
	["poimandres"] = "poimandres.nvim",
	["everforest"] = "everforest",
	["olive"] = "olive-crt.nvim",
	["vague"] = "vague.nvim",
	["nightfox"] = "nightfox.nvim",
}
local pkg
for k, v in pairs(scheme_to_pkg) do
	if pending:find(k) then
		pkg = v
		break
	end
end
print(pkg)
