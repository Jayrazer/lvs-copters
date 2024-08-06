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
	self:AnimRotor()
	self:DamageFX()
end

function ENT:AnimRotor()
	local RPM = self:GetThrottle() * 2500

	self.RPM = self.RPM and (self.RPM + RPM * RealFrameTime() * 0.5) or 0

	local Rot1 = Angle( -self.RPM,0,0)
	Rot1:Normalize() 
	

	self:ManipulateBoneAngles( 26, Rot1 )
	self:ManipulateBoneAngles( 27, Rot1 )
end

function ENT:RemoveLight()
	if IsValid( self.projector ) then
		self.projector:Remove()
		self.projector = nil
	end
end

function ENT:OnRemoved()
	self:RemoveLight()
end

ENT.Red = Color( 255, 0, 0, 255)
ENT.White = Color( 255, 255, 255, 255)
ENT.Green = Color( 0, 255, 0, 255)
ENT.SignalSprite = Material( "sprites/light_glow02_add" )
ENT.Spotlight = Material( "effects/lvs/spotlight_beam" )

function ENT:HandleLights()
	if not self:GetLightsEnabled() then 
		self:RemoveLight()
		return
	end

	if not IsValid( self.projector ) then
		local thelamp = ProjectedTexture()
		thelamp:SetBrightness( 20 ) 
		thelamp:SetTexture( "effects/flashlight/soft" )
		thelamp:SetColor( Color(255,255,255) ) 
		thelamp:SetEnableShadows( true ) 
		thelamp:SetFarZ( 7500 ) 
		thelamp:SetNearZ( 75 ) 
		thelamp:SetFOV(30 )
		self.projector = thelamp

		return
	end

	local StartPos = self:LocalToWorld( Vector(81.157,0,-55.892) )
	local Dir = self:LocalToWorldAngles( Angle(10,0,0) ):Forward()

	render.SetMaterial( self.SignalSprite )
	render.DrawSprite( StartPos + Dir * 5, 250, 250, Color( 255, 255, 255, 255) )

	render.SetMaterial( self.Spotlight )
	render.DrawBeam( StartPos - Dir * 10,  StartPos + Dir * 800, 250, 0, 0.99, Color( 255, 255, 255, 10) ) 

	self.projector:SetPos( StartPos )
	self.projector:SetAngles( Dir:Angle() )
	self.projector:Update()
end

function ENT:HandleSignals()
	if not self:GetSignalsEnabled() then return end

	local T4 = CurTime() * 4 + self:EntIndex() * 1337
	local T3 = CurTime() * 6 + self:EntIndex() * 1337
	local T2 = CurTime() * 7 + self:EntIndex() * 1337

	local OY = math.cos( T4 )
	local A = math.max( math.sin( T4 ), 0 )
	local C = math.max( math.sin( T3 ), 0 )
	local B= math.max( math.sin( T4 ), 1 )
	local D= math.max( math.sin( T2 ), 0 )

	local R = D * 22
	render.SetMaterial( self.SignalSprite )
	render.DrawSprite( self:LocalToWorld( Vector(33.4,-8.185,-89.078) ), R, R, self.Red )
	
	local D = C * 64
	render.SetMaterial( self.SignalSprite )
	render.DrawSprite( self:LocalToWorld( Vector(-208.014,-7.528,6.793) ), D, D, self.Red )
	
	local S = B * 52
	render.SetMaterial( self.SignalSprite )
	render.DrawSprite( self:LocalToWorld( Vector(22.175,36.425,-72.786) ), S, S, self.Green )
	render.DrawSprite( self:LocalToWorld( Vector(22.175,-36.425,-72.786) ), S, S, self.Red )
end

function ENT:PostDrawTranslucent()
	self:HandleSignals()
	self:HandleLights()
end