local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddServices(script.Parent.Server.Services)

Knit.Start():andThen(function()
	print("Server-Side: Knit Started!")	
end)

