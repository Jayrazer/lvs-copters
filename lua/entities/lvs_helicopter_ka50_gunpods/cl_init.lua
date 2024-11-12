include("shared.lua")
--include("cl_attached_playermodels.lua")

function ENT:DamageFX()
	self.nextDFX = self.nextDFX or 0

	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.01

		local HP = self:GetHP()
		local MaxHP = self:GetMaxHP()

		if HP > MaxHP * 0.25 then return end

		local effectdata = EffectData()
			effectdata:SetOrigin( self:LocalToWorld( Vector(-78.314,-0.264,-65.724) ) )
			effectdata:SetNormal( self:GetUp() )
			effectdata:SetMagnitude( math.Rand(0.5,2.5) )
			effectdata:SetEntity( self )
		util.Effect( "lvs_exhaust_fire", effectdata )
	end
end

function ENT:OnFrame()
	local FT = RealFrameTime()

	self:AnimLandingGear( FT )
	self:AnimRotor( FT )
	self:DamageFX( FT )
end

function ENT:AnimRotor()
	local RPM = self:GetThrottle() * 2500

	self.RPM = self.RPM and (self.RPM + RPM * RealFrameTime() * 0.5) or 0

	local Rot1 = Angle( 0,-self.RPM,0)
	Rot1:Normalize() 
	
	local Rot2 = Angle( 0,self.RPM,0)
	Rot2:Normalize() 
	

	self:ManipulateBoneAngles( 11, Rot1 )
	self:ManipulateBoneAngles( 12, Rot2 )
end

function ENT:AnimLandingGear( frametime )
	self._smLandingGear = self._smLandingGear and self._smLandingGear + ((1 - self:GetLandingGear()) - self._smLandingGear) * frametime * 4 or 0
	local gExp = self._smLandingGear ^ 15
	
	self:ManipulateBoneAngles( 1, Angle( 90,0,0) * self._smLandingGear )
	self:ManipulateBoneAngles( 2, Angle( 55,-10,0) * self._smLandingGear )
	self:ManipulateBoneAngles( 3, Angle( 55,10,0) * self._smLandingGear )
	self:ManipulateBonePosition( 2, Vector( -5,10,0) * self._smLandingGear )
	self:ManipulateBonePosition( 3, Vector( -5,-10,0) * self._smLandingGear )
	
	self:ManipulateBoneAngles( 7, Angle(0,0,90) * (1 - gExp) )
	self:ManipulateBoneAngles( 8, Angle(0,0,-90) * (1 - gExp) )
	
	self:ManipulateBoneAngles( 9, Angle(0,0,35) * (1 - gExp) )
	self:ManipulateBoneAngles( 10, Angle(0,0,-35) * (1 - gExp) )
end