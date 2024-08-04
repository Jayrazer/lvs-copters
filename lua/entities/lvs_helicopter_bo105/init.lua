AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
--AddCSLuaFile( "cl_attached_playermodels.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(48.898,-15,-15.513), Angle(0,-90,9.768) )
	DriverSeat:SetCameraDistance( -0.2 )
	DriverSeat:SetCameraHeight( 0 )
	DriverSeat.HidePlayer = false
	
	self:SetSkin(2)
	
	local PassengerSeats = {
		{
			pos = Vector(48.898,15,-15.513),
			ang = Angle(0,-90,9.768)
		}
	}
		for num, v in pairs( PassengerSeats ) do
		local Pod = self:AddPassengerSeat( v.pos, v.ang )
	end

	self:AddEngineSound( Vector(0,0,30) )

	--self:AddRotor( pos, angle, radius, turn_speed_and_direction )
	self.Rotor = self:AddRotor( Vector(0,0,60), Angle(0,0,0), 200, -400 )
	self.Rotor:SetHP( 30 )
	
	self.TailRotor = self:AddRotor( Vector( -260.762, 10.433, 65.754 ), Angle( 0, 0, 90 ), 35, 0 )
    self.TailRotor:SetHP( 30 )
    function self.TailRotor:OnDestroyed( rotor )
        local id = rotor:LookupBone( "rotor_tail" )
        --rotor:ManipulateBoneScale( id, Vector( 0, 0, 0 ) )
        rotor:EmitSound( "physics/metal/metal_box_break2.wav" )
        rotor:DestroySteering( -2.5 )
    end
	
	self:AddDS( {
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    mins = Vector(-100,-40,-30),
    maxs =  Vector(100,40,60),
    Callback = function( tbl, ent, dmginfo )
     dmginfo:ScaleDamage( 8 )
    end
} )
	
	function self.Rotor:OnDestroyed( base )
		base:SetBodygroup( 12, 2 )
		base:SetBodygroup( 13, 2 )
		base:DestroyEngine()
		
		self:EmitSound( "lvs_custom/shared/heli_break.wav" )
		self:EmitSound( "physics/metal/metal_box_break2.wav" )
	end

end

function ENT:CalcViewOverride( ply, pos, angles, fov, pod )
    return pos, angles, fov
end

function ENT:SetRotor( PhysRot )
	self:SetBodygroup( 12, PhysRot and 0 or 1 ) 
	self:SetBodygroup( 13, PhysRot and 0 or 1 ) 
end

function ENT:GetMissileOffset()
	return Vector(0,0,0)
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/helicopter/start.wav" )
	end
end

function ENT:OnTick()
	local PhysRot = self:GetThrottle() < 0.85

	if not self:IsEngineDestroyed() then
		self:SetRotor( PhysRot )
	end
end

function ENT:OnCollision( data, physobj )
	if self:IsPlayerHolding() then return false end

	if data.Speed > 60 and data.DeltaTime > 0.2 then
		local VelDif = data.OurOldVelocity:Length() - data.OurNewVelocity:Length()

		if VelDif > 200 then
			local part = self:FindDS( data.HitPos - data.OurOldVelocity:GetNormalized() * 25 )

			if part then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( 1000 )
				dmginfo:SetDamageType( DMG_CRUSH )
				part:Callback( self, dmginfo )
			end
		end
	end

	return false
end