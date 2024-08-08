AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_attached_playermodels.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(69.898,0,10.513), Angle(0,-90,9.768) )
	DriverSeat:SetCameraDistance( 0.5 )
	DriverSeat:SetCameraHeight( 0 )
	DriverSeat.HidePlayer = true
	
	self:SetBodygroup( 3, 8 ) 
	self:SetBodygroup( 4, 2 ) 
	
	--local PassengerSeats = {
		--{
			--pos = Vector(133.898,0,1.513),
			--ang = Angle(0,-90,9.768)
		--}
	--}
		--for num, v in pairs( PassengerSeats ) do
		--local Pod = self:AddPassengerSeat( v.pos, v.ang )
	--end

	self:AddEngineSound( Vector(-50,0,40) )

	--self:AddRotor( pos, angle, radius, turn_speed_and_direction )
	self.Rotor = self:AddRotor( Vector(0,0,110), Angle(0,0,0), 320, -400 )
	self.Rotor:SetHP( 30 )
	
	self.TailRotor = self:AddRotor( Vector( -400.762, 30.433, 80.754 ), Angle( 0, 0, 90 ), 35, 0 )
    self.TailRotor:SetHP( 30 )
    function self.TailRotor:OnDestroyed( rotor )
        local id = rotor:LookupBone( "Tail Rotor" )
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
		base:SetBodygroup( 1, 2 )
		base:SetBodygroup( 2, 2 )
		base:DestroyEngine()
		
		self:EmitSound( "lvs_custom/shared/heli_break.wav" )
		self:EmitSound( "physics/metal/metal_box_break2.wav" )
	end

end

function ENT:CalcViewOverride( ply, pos, angles, fov, pod )
    return pos, angles, fov
end

function ENT:SetRotor( PhysRot )
	self:SetBodygroup( 1, PhysRot and 0 or 1 ) 
	self:SetBodygroup( 2, PhysRot and 0 or 1 ) 
end

function ENT:GetMissileOffset()
	return Vector(0,0,0)
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs_copters/engine/start.wav" )
	else
		self:EmitSound( "lvs_copters/engine/stop.wav" )		
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

hook.Add("LoadFlareConfiguration", "lvs_viper", function ()
    UF:RegisterFlareVehicleConfiguration("lvs_helicopter_ah1z",
            {
                {
                    pos = Vector(-90.54, 0, -50.59), -- Position where to eject flares.
                    dir = UF.CONST.BACKWARDS, -- In which direction to eject flares, defaults available: UF.CONST.BACKWARDS, UF.CONST.RIGHT, UF.CONST.LEFT.
                    dirMulti = 1000, -- Optional velocity multiplier for ejecting flares.
                },
            },
            1, -- Which seat should control the flares. Default 0.
            16, -- The total times the flares can be used. Default 16.
            5 -- The amount of individual flares that should be deployed per burst. Default 5.
    )
end)