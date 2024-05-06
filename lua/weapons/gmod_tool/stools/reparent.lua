
TOOL.Category = "Constraints"
TOOL.Name = "#tool.reparent.name"
TOOL.DP = {}

if CLIENT then

	TOOL.Information = {

		{ name = "left", icon = "gui/lmb.png",  stage = 0, op = 0 },
		{ name = "left_sec", con = "gui/lmb.png", stage = 1, op = 0 },
		{ name = "left_thi", con = "gui/lmb.png", stage = 1, op = 1 },
		{ name = "right", icon = "gui/rmb.png", stage = 1, op = 1 },
		{ name = "reload", icon = "gui/r.png" },

	}

	language.Add( "tool.reparent.name", "Re-Parent Tool" )
	language.Add( "tool.reparent.desc", "A tool designed to quickly move the children of a prop to another." )
	language.Add( "tool.reparent.left", "Select the current parent root you want to change." )
	language.Add( "tool.reparent.left_sec", "Now, select the new parent root." )
	language.Add( "tool.reparent.left_thi", "If you want, select a new parent root for the children." )
	language.Add( "tool.reparent.right", "Apply the changes." )
	language.Add( "tool.reparent.reload", "Clear selection." )

end

--=========== VALIDATORS ===========--
do

	local function IsReallyValid( ent )

		if not IsValid(ent) then return false end
		if ent:IsPlayer() then return false end
		if not IsValid(ent:GetPhysicsObject()) then return false end

		return true
	end

	local function HasChildren( ent )
		return next(ent:GetChildren())
	end

	--=========== MAIN ===========--
	do

		local FirstColor = Color(255,0,0,200)
		local SecondColor = Color(0,255,0,200)

		local function ApplyReparent( Old, New, Tool )

			local children = Old:GetChildren()
			if next(children) then
				for k, child in pairs(children) do
					if not IsValid(child) then continue end

					if child ~= Tool.DP.NewParent then
						child:SetParent( New )
					else
						local pos = child:GetPos()
						local ang = child:GetAngles()

						child:SetParent( nil )

						child:SetPos(pos)
						child:SetAngles(ang)
					end
				end
			end
		end

		local function RestoreAll( Tool )
			if IsValid(Tool.DP.OldParent) then
				Tool.DP.OldParent:SetColor(Tool.DP.OldParentColor)
				Tool.DP.OldParent:SetRenderMode(Tool.DP.OldParentRmode)
			end

			if IsValid(Tool.DP.NewParent) then
				Tool.DP.NewParent:SetColor(Tool.DP.NewParentColor)
				Tool.DP.NewParent:SetRenderMode(Tool.DP.NewParentRmode)
			end

			Tool.DP = {}
		end

		function TOOL:LeftClick( trace )
			if CLIENT then return true end
			local Ent = trace.Entity
			if not IsReallyValid( Ent ) then return end

			if IsValid(Ent) then
				if not IsValid(self.DP.OldParent) and HasChildren( Ent ) then
					self.DP.OldParent = Ent
					self.DP.OldParentColor = Ent:GetColor()
					self.DP.OldParentRmode = Ent:GetRenderMode()
					Ent:SetColor(FirstColor)
					Ent:SetRenderMode( RENDERMODE_TRANSCOLOR )

					self:SetStage(1)
				elseif IsValid(self.DP.OldParent) and (not IsValid(self.DP.NewParent) or Ent ~= self.DP.NewParent) and Ent ~= self.DP.OldParent then

					if IsColor(self.DP.NewParentColor) then
						self.DP.NewParent:SetColor(self.DP.NewParentColor)
						self.DP.NewParent:SetRenderMode(self.DP.NewParentRmode)
					end

					self.DP.NewParent = Ent
					self.DP.NewParentColor = Ent:GetColor()
					self.DP.NewParentRmode = Ent:GetRenderMode()
					Ent:SetColor(SecondColor)
					Ent:SetRenderMode( RENDERMODE_TRANSCOLOR )

					self:SetOperation( 1 )
				end
			end

			return true
		end

		function TOOL:RightClick( trace )
			if CLIENT then return true end

			if IsValid(self.DP.OldParent) and IsValid(self.DP.NewParent) then
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('Re-parent completed!',NOTIFY_GENERIC,7);" ) -- lazy moment
				ApplyReparent( self.DP.OldParent, self.DP.NewParent, self )
			end

			RestoreAll( self )
			self:ClearObjects()

			return true
		end

		function TOOL:Reload( trace )
			if CLIENT then return true end

			RestoreAll( self )
			self:ClearObjects()

			return true
		end

		function TOOL:Holster()
			RestoreAll( self )
			self:ClearObjects()
		end

	end

	do

		function TOOL.BuildCPanel( panel )

			panel:Help("#tool.reparent.desc")

		end

	end
end
