if SERVER then return end

function ENT:GetPlayerModel( name )
	if not istable( self._PlayerModels ) then return end

	return self._PlayerModels[ name ]
end

function ENT:RemovePlayerModel( name )
	if not istable( self._PlayerModels ) then return end

	for id, model in pairs( self._PlayerModels ) do
		if name and id ~= name then continue end

		if not IsValid( model ) then continue end

		model:Remove()
	end
end

function ENT:CreatePlayerModel( ply, name )
	if not isstring( name ) then return end

	if not istable( self._PlayerModels ) then
		self._PlayerModels  = {}
	end

	if IsValid( self._PlayerModels[ name ] ) then return self._PlayerModels[ name ] end

	local model = ClientsideModel( ply:GetModel() )
	model:SetNoDraw( true )

	model.GetPlayerColor = function() return ply:GetPlayerColor() end
	model:SetSkin( ply:GetSkin() )

	self._PlayerModels[ name ] = model

	return model
end

function ENT:OnRemoved()
	self:RemovePlayerModel()
end



function ENT:DrawDriver()
	local pod = self:GetDriverSeat()

	if not IsValid( pod ) then self:RemovePlayerModel( "driver" ) return end

	local plyL = LocalPlayer()
	local ply = pod:GetDriver()

	if not IsValid( ply ) or (ply == plyL and not pod:GetThirdPersonMode()) then self:RemovePlayerModel( "driver" ) return end

	local Pos = self:LocalToWorld( Vector(67,0,10) )
	local Ang = self:LocalToWorldAngles( Angle(0,0,0) )

	local model = self:CreatePlayerModel( ply, "driver" )

	model:SetSequence( "sit" )
	model:SetRenderOrigin( Pos )
	model:SetRenderAngles( Ang )
	model:DrawModel()
end


function ENT:DrawGunner()
	local pod = self:GetDriverSeat()

	if not IsValid( pod ) then self:RemovePlayerModel( "passenger" ) return end

	local plyL = LocalPlayer()
	local ply = pod:GetDriver()

	if not IsValid( ply ) or (ply == plyL and not pod:GetThirdPersonMode()) then self:RemovePlayerModel( "passenger" ) return end

	local Pos = self:LocalToWorld( Vector(130,0,0) )
	local Ang = self:LocalToWorldAngles( Angle(0,0,0) )

	local model = self:CreatePlayerModel( ply, "passenger" )

	model:SetSequence( "sit" )
	model:SetRenderOrigin( Pos )
	model:SetRenderAngles( Ang )
	model:DrawModel()
end

function ENT:PreDraw()
	self:DrawDriver()
	self:DrawGunner()

	return true
end