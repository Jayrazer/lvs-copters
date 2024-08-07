AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("sv_wheels.lua")
include("sv_landinggear.lua")
include("shared.lua")


ENT.WheelAutoRetract = false

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(115.898,0,49.513), Angle(0,-90,9.768) )
	DriverSeat:SetCameraDistance( 0.3 )
	DriverSeat:SetCameraHeight( 0.04 )
	DriverSeat.HidePlayer = false
	
	self:SetSkin(3)
	
	self:SetBodygroup( 5, 2 ) 
	
	--local PassengerSeats = {
		--{
			--pos = Vector(133.898,0,1.513),
			--ang = Angle(0,-90,9.768)
		--}
	--}
		--for num, v in pairs( PassengerSeats ) do
		--local Pod = self:AddPassengerSeat( v.pos, v.ang )
	--end

	self:AddEngineSound( Vector(0,0,60) )

	--self:AddRotor( pos, angle, radius, turn_speed_and_direction )
	self.Rotor = self:AddRotor( Vector(22,0,190), Angle(0,0,0), 300, 400 )
	self.Rotor:SetHP( 30 )
	
	self.TailRotor = self:AddRotor( Vector(22,0,130), Angle(0,0,0), 300, -400 )
	self.TailRotor:SetHP( 30 )
    function self.TailRotor:OnDestroyed( rotor )
        local id = rotor:LookupBone( "Tail Rotor" )
        --rotor:ManipulateBoneScale( id, Vector( 0, 0, 0 ) )
        rotor:EmitSound( "physics/metal/metal_box_break2.wav" )
        rotor:DestroySteering( -2.5 )
    end
	
	self:AddWheel( Vector(-24.1096,-52.0438,4.32579), 18.5, 200, LVS.WHEEL_BRAKE)
	self:AddWheel( Vector(-24.1096,52.0438,4.32579), 18.5, 200, LVS.WHEEL_BRAKE)
	self:AddWheel( Vector(167.812,0,-1.46369), 8.5, 200, LVS.WHEEL_BRAKE )
	
	self:AddDS( {
    pos = Vector(0,0,50),
    ang = Angle(0,0,0),
    mins = Vector(-100,-40,-30),
    maxs =  Vector(100,40,60),
    Callback = function( tbl, ent, dmginfo )
     dmginfo:ScaleDamage( 8 )
    end
} )
	
	function self.Rotor:OnDestroyed( base )
		base:SetBodygroup( 3, 2 )
		base:SetBodygroup( 4, 2 )
		base:DestroyEngine()
		
		self:EmitSound( "lvs_custom/shared/heli_break.wav" )
		self:EmitSound( "physics/metal/metal_box_break2.wav" )
	end

end

function ENT:CalcViewOverride( ply, pos, angles, fov, pod )
    return pos, angles, fov
end

function ENT:SetRotor( PhysRot )
	self:SetBodygroup( 3, PhysRot and 0 or 1 ) 
	self:SetBodygroup( 4, PhysRot and 0 or 1 ) 
end

function ENT:PhysicsSimulate( phys, deltatime )
	if self:GetEngineActive() then phys:Wake() end

	local EntTable = self:GetTable()

	local WorldGravity = self:GetWorldGravity()
	local WorldUp = self:GetWorldUp()

	local Up = self:GetUp()
	local Left = -self:GetRight()

	local Mul = self:GetThrottle()
	local InputThrust = math.min( self:GetThrust() , 0 ) * EntTable.ThrustDown + math.max( self:GetThrust(), 0 ) * EntTable.ThrustUp

	if self:HitGround() and InputThrust <= 0 then
		Mul = 0
	end

	-- mouse aim needs to run at high speed.
	if self:GetAI() then
		self:CalcAIMove( phys, deltatime )
	else
		local ply = self:GetDriver()
		if IsValid( ply ) and ply:lvsMouseAim() then
			self:PlayerMouseAim( ply, phys, deltatime )
		end
	end

	local Steer = self:GetSteer()

	local Vel = phys:GetVelocity()
	local VelL = phys:WorldToLocal( phys:GetPos() + Vel )

	local YawPull = (math.deg( math.acos( math.Clamp( WorldUp:Dot( Left ) ,-1,1) ) ) - 90) /  90

	local GravityYaw = math.abs( YawPull ) ^ 1.25 * self:Sign( YawPull ) * (WorldGravity / 100) * (math.min( Vector(VelL.x,VelL.y,0):Length() / EntTable.MaxVelocity,1) ^ 2)

	local Pitch = math.Clamp(Steer.y,-1,1) * EntTable.TurnRatePitch
	local Yaw = math.Clamp(Steer.z + GravityYaw * 0.25,-1,1) * EntTable.TurnRateYaw * 60
	local Roll = math.Clamp(Steer.x,-1,1) * 1.5 * EntTable.TurnRateRoll

	self:HandleLandingGear( deltatime )
	self:SetWheelSteer( Steer.z * self.WheelSteerAngle )

	local Ang = self:GetAngles()

	local FadeMul = (1 - math.max( (45 - self:AngleBetweenNormal( WorldUp, Up )) / 45,0)) ^ 2
	local ThrustMul = math.Clamp( 1 - (Vel:Length() / EntTable.MaxVelocity) * FadeMul, 0, 1 )

	local Thrust = self:LocalToWorldAngles( Angle(Pitch,0,Roll) ):Up() * (WorldGravity + InputThrust * 500 * ThrustMul) * Mul

	local Force, ForceAng = phys:CalculateForceOffset( Thrust, phys:LocalToWorld( phys:GetMassCenter() ) + self:GetUp() * 1000 )

	local ForceLinear = (Force - Vel * 0.15 * EntTable.ForceLinearDampingMultiplier) * Mul
	local ForceAngle = (ForceAng + (Vector(0,0,Yaw) - phys:GetAngleVelocity() * 1.5 * EntTable.ForceAngleDampingMultiplier) * deltatime * 250) * Mul

	if EntTable._SteerOverride then
		ForceAngle.z = (EntTable._SteerOverrideMove * math.max( self:GetThrust() * 2, 1 ) * 100 - phys:GetAngleVelocity().z) * Mul
	end

	return ForceAngle, ForceLinear, SIM_GLOBAL_ACCELERATION
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

function ENT:OnLandingGearToggled( bOn )
	if bOn then
		self:EmitSound( "lvs/vehicles/generic/gear.wav" )
	else
		self:EmitSound( "lvs/vehicles/generic/gear.wav" )
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

hook.Add("LoadFlareConfiguration", "lvs_blackshark", function ()
    UF:RegisterFlareVehicleConfiguration("lvs_helicopter_ka50",
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