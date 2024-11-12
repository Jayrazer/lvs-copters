
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "AH-1Z Viper"
ENT.Category = "[LVS] - Helicopters"

ENT.VehicleCategory = "Helicopters"
ENT.VehicleSubCategory = "Heli Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lvs_copters/bf4/ah1z/viper.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 1000

ENT.MaxVelocity = 2100

ENT.ThrustUp = 1.2
ENT.ThrustDown = 0.8
ENT.ThrustRate = 1

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1.2
ENT.TurnRateYaw = 1.3
ENT.TurnRateRoll = 1.2

ENT.ForceLinearDampingMultiplier = 1.4

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.GibModels = {
	"models/lvs_copters/bf4/gibs/viper_body.mdl",
	"models/lvs_copters/bf4/gibs/viper_tail.mdl",
	"models/combine_apc_destroyed_gib04.mdl",
	"models/combine_apc_destroyed_gib04.mdl",
	"models/combine_apc_destroyed_gib03.mdl",
	"models/combine_apc_destroyed_gib03.mdl",
	"models/combine_apc_destroyed_gib03.mdl",
	"models/container_chunk05.mdl",
	"models/container_chunk05.mdl",
	"models/combine_apc_destroyed_gib05.mdl",
	"models/combine_apc_destroyed_gib05.mdl",
}

ENT.EngineSounds = {
	{
	    sound = "^lvs_copters/engine/rotor3.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel = 110,
		UseDoppler = true,
	},
	{
	    sound = "lvs_copters/engine/rpm2.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel = 105,
		UseDoppler = true,
	}
}

--ENT.FlyByAdvance = 1 -- how many second the flyby sound is advanced
--ENT.FlyBySound = "AH6_FLYBY" -- which sound to play on fly by

function ENT:OnSetupDataTables()
end

function ENT:GetAimAngles()
	local Gun = self:GetAttachment( self:LookupAttachment( "muzzle" ) )

	if not Gun then return end

	local trace = self:GetEyeTrace()

	local AimAngles = self:WorldToLocalAngles( (trace.HitPos - Gun.Pos):GetNormalized():Angle() )

	return AimAngles
end

function ENT:WeaponsInRange()
	local AimAngles = self:GetAimAngles()
	
	return math.abs( AimAngles.y ) < 102 and AimAngles.p < 62 and AimAngles.p > -22
end

function ENT:SetPoseParameterTurret()
	local AimAngles = self:GetAimAngles()

	self:SetPoseParameter("turret_yaw", -AimAngles.y )
	self:SetPoseParameter("turret_pitch", AimAngles.p )
end

function ENT:InitWeapons()
local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 750
	weapon.Delay = 60 / 800
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.2
	weapon.StartAttack = function( ent )
		if not IsValid( self.SoundEmitter ) then
			local ID = self:LookupAttachment( "muzzle" )
			local Attachment = self:GetAttachment( ID )
			self.SoundEmitter = self:AddSoundEmitter( self:WorldToLocal( Attachment.Pos ), "M197_LOOP", "M197_LOOP" )
			self.SoundEmitter:SetSoundLevel( 95 )
		end

		self.SoundEmitter:Play()
	end
	
	weapon.FinishAttack = function( ent)
		if IsValid( self.SoundEmitter ) then
			self.SoundEmitter:Stop()
			self:EmitSound( "GUNPODS_STOP" )
		end
	end
	
	
	weapon.Attack = function( ent )
		if !ent:WeaponsInRange() then
		
			self.SoundEmitter:Stop()
		
			return true
		end
		
		self.SoundEmitter:Play()
		
		local ID = ent:LookupAttachment( "muzzle" )
		local Muzzle = ent:GetAttachment ( ID )
		if not Muzzle then return end
		local effectdata = EffectData()
		effectdata:SetOrigin( Muzzle.Pos ) --( ent:LocalToWorld( Vector(250.005,0.804,-25.79) ) )
		effectdata:SetNormal( Muzzle.Ang:Forward() ) --( ent:GetForward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

 	 	ent.FireLeft = not ent.FireLeft	
		
	local trace = self:GetEyeTrace()
			
	local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= (trace.HitPos - Muzzle.Pos):GetNormalized()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_white"
		bullet.Force	= 3500
		bullet.HullSize 	= 15
		bullet.Damage	= 65
		bullet.DamageType	= DMG_AIRBOAT
		bullet.Velocity = 12000
		bullet.SplashDamage = 40
		bullet.SplashDamageRadius = 50
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_bullet_impact", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		weapon.OnSelect = function( ent ) 
			ent:EmitSound("weapons/shotgun/shotgun_cock.wav") 
		end
	    weapon.OnOverheat = function( ent ) ent:EmitSound("30MM_STOP") end
		end
	
	weapon.OnThink = function( ent, active )
		ent:SetPoseParameterTurret()
	end
	
	self:AddWeapon( weapon )
	
	
	-- Hydras
	local weapon = {}
		weapon.Icon = Material("lvs/weapons/rocket.png")
	weapon.Ammo = 40
	weapon.Delay = 0.2
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	
	weapon.Attack = function( ent )

		local pod = ent:GetDriverSeat()
		if not IsValid( pod ) then return end
		
		ent.FireLeft = not ent.FireLeft
			
		local bullet = {}
		bullet.Src 	= ( ent:LocalToWorld( Vector(22.73,62.76 * (self.FireLeft and 1 or -1),-12.74) ) )
		bullet.Dir 	=  ent:GetForward()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_missile"
		bullet.Force	= 18000
		bullet.HullSize 	= 30
		bullet.Damage	= 400
		bullet.DamageType	= DMG_AIRBOAT
		bullet.Velocity = 6000
		bullet.SplashDamage = 200
		bullet.SplashDamageRadius = 300
		bullet.SplashDamageType = DMG_AIRBOAT
		bullet.Attacker 	= ent:GetDriver()
		
		ent:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
		
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_explosion_small", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	   -- weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		end
		self:AddWeapon( weapon )
	

	-- hellfire
	-- local weapon = {}
		-- weapon.Icon = Material("lvs/weapons/hellfire.png")
	-- weapon.Ammo = 16
	-- weapon.Delay = 0.5
	-- weapon.HeatRateUp = 0
	-- weapon.HeatRateDown = 0
	
	-- weapon.Attack = function( ent )

		-- local pod = ent:GetDriverSeat()
		-- if not IsValid( pod ) then return end
		-- local startpos = pod:LocalToWorld( pod:OBBCenter() )
		-- local trace = util.TraceHull( {
			-- start = startpos,
			-- endpos = (startpos + ent:GetForward() * 50000),
			-- mins = Vector( -10, -10, -10 ),
			-- maxs = Vector( 10, 10, 10 ),
			-- filter = ent:GetCrosshairFilterEnts()
		-- } )
		
		-- ent.FireLeft = not ent.FireLeft
			
		-- local bullet = {}
		-- bullet.Src 	= ( ent:LocalToWorld( Vector(18.12,99.57 * (self.FireLeft and 1 or -1),-21.45) ) )
		-- bullet.Dir 	= (trace.HitPos - bullet.Src):GetNormalized()
		-- bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		-- bullet.TracerName = "lvs_tracer_missile"
		-- bullet.Force	= 28000
		-- bullet.HullSize 	= 30
		-- bullet.Damage	= 600
		-- bullet.Velocity = 3000
		-- bullet.SplashDamage = 400
		-- bullet.SplashDamageRadius = 250
		-- bullet.Attacker 	= ent:GetDriver()
		
		-- ent:EmitSound( "weapons/stinger_fire1.wav" )
		
		-- bullet.Callback = function(att, tr, dmginfo)
		-- local effectdata = EffectData()
		-- effectdata:SetOrigin( tr.HitPos )
		-- effectdata:SetNormal( tr.HitNormal )
		-- util.Effect( "lvs_explosion_bomb", effectdata, true, true )
	-- end

		-- ent:LVSFireBullet( bullet )

		-- ent:TakeAmmo( 1 )
		
		-- local Ammo = self:GetAmmo()
		-- self:SetBodygroup(3, Ammo )
		
		-- weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	    -- weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		-- end
		-- self:AddWeapon( weapon )
		
		
	-- Stand-in laser guided missiles (we'll just say someone on the ground is guiding them)
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/hellfire.png")
	weapon.Ammo = 8
	weapon.Delay = 0 -- this will turn weapon.Attack to a somewhat think function
	weapon.HeatRateUp = -0.6 -- cool down when attack key is held. This system fires on key-release.
	weapon.HeatRateDown = 0.6
	weapon.Attack = function( ent )
		local T = CurTime()

		if IsValid( ent._Missile ) then
			if (ent._nextMissleTracking or 0) > T then return end

			ent._nextMissleTracking = T + 0.1 -- 0.1 second interval because those find functions can be expensive

			ent._Missile:FindTarget( ent:GetPos(), ent:GetForward(), 30, 7500 )

			return
		end

		local T = CurTime()

		if (ent._nextMissle or 0) > T then return end

		ent._nextMissle = T + 0.75

		ent._swapMissile = not ent._swapMissile

		local Pos = Vector( 36.6, (ent._swapMissile and 99.77 or -99.77), -20.34 )

		local Driver = self:GetDriver()

		local projectile = ents.Create( "lvs_missile" )
		projectile:SetPos( ent:LocalToWorld( Pos ) )
		projectile:SetAngles( ent:LocalToWorldAngles( Angle(0,ent._swapMissile and 2 or -2,0) ) )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		projectile:SetDamage( 800 )
		projectile:SetRadius( 300 )

		ent._Missile = projectile

		ent:SetNextAttack( CurTime() + 0.1 ) -- wait 0.1 second before starting to track
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent._Missile ) then return end

		local projectile = ent._Missile

		projectile:Enable()
		projectile:EmitSound( "weapons/stinger_fire1.wav", 125 )
		ent:TakeAmmo()

		ent._Missile = nil

		local NewHeat = ent:GetHeat() + 0.3

		ent:SetHeat( NewHeat )
		if NewHeat >= 1 then
			ent:SetOverheated( true )
		end
		
		local Ammo = self:GetAmmo()
		self:SetBodygroup(3, Ammo )
		
	end
	weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon )


	--sidewinder
	-- local weapon = {}
	-- weapon.Icon = Material("lvs/weapons/missile.png")
	-- weapon.Ammo = 6
	-- weapon.Delay = 0 -- this will turn weapon.Attack to a somewhat think function
	-- weapon.HeatRateUp = -0.5 -- cool down when attack key is held. This system fires on key-release.
	-- weapon.HeatRateDown = 0.25
	
	-- weapon.Attack = function( ent )
		-- local T = CurTime()

		-- if IsValid( ent._Missile ) then
			-- if (ent._nextMissleTracking or 0) > T then return end

			-- ent._nextMissleTracking = T + 0.1 -- 0.1 second interval because those find functions can be expensive

			-- ent._Missile:FindTarget( ent:GetPos(), ent:GetForward(), 30, 7500 )

			-- return
		-- end

		-- local T = CurTime()

		-- if (ent._nextMissle or 0) > T then return end

		-- ent._nextMissle = T + 0.5

		-- ent._swapMissile = not ent._swapMissile

		-- local Pos = Vector( -4, (ent._swapMissile and -104 or 104), 13 )

		-- local Driver = self:GetDriver()

		-- local projectile = ents.Create( "lvs_missile" )
		-- projectile:SetPos( ent:LocalToWorld( Pos ) )
		-- projectile:SetAngles( ent:LocalToWorldAngles( Angle(0,ent._swapMissile and 2 or -2,0) ) )
		-- projectile:SetParent( ent )
		-- projectile:Spawn()
		-- projectile:Activate()
		-- projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		-- projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		-- projectile:SetDamage( 800 ) -- these are more for air-to-air
		-- projectile:SetRadius( 200 )

		-- ent._Missile = projectile

		-- ent:SetNextAttack( CurTime() + 0.1 ) -- wait 0.1 second before starting to track
	-- end
	-- weapon.FinishAttack = function( ent )
		-- if not IsValid( ent._Missile ) then return end

		-- local projectile = ent._Missile

		-- projectile:Enable()
		-- projectile:EmitSound( "weapons/stinger_fire1.wav", 125 )
		-- ent:TakeAmmo()

		-- ent._Missile = nil

		-- local NewHeat = ent:GetHeat() + 0.5

		-- ent:SetHeat( NewHeat )
		-- if NewHeat >= 1 then
			-- ent:SetOverheated( true )
		-- end
		
		-- local Ammo = self:GetAmmo()
		-- self:SetBodygroup(4, Ammo )
		
	-- end
	-- weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	-- weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	-- self:AddWeapon( weapon )

end

sound.Add( {
	name = "M197_LOOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {90,100},
	sound = "^lvs_copters/weapons/m197_loop_750.wav"
} )