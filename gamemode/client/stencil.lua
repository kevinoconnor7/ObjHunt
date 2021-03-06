local function stencilColor( ply, ent )
	-- make sure we're living props
	if( !ply:Alive() || ply:Team() != TEAM_PROPS ) then return false end

	-- make sure it's a valid object
	if(	!IsValid(ent) ) then return false end

	-- must not be a chosenProp
	if( ent:IsPlayer() ) then return false end
	if( ent:GetOwner():IsPlayer() ) then return false end

	-- must have a bounding box
	if( !ent:GetHitBoxBounds(0,0) ) then return false end

	-- make sure the distance is beneath the max
	local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
	local distVec = (pos - ent:GetPos())
	local distBetween = distVec:Length()
	if( distBetween > PROP_SELECT_DISTANCE ) then return false end

	gCol = Color(0,255,0,255)
	bCol = Color(255,0,0,255)

	-- make sure ent is a valid prop type
	if(	!table.HasValue( USABLE_PROP_ENTITIES, ent:GetClass() ) ) then return bCol end

	-- make sure ent is a valid prop type
	if( WouldBeStuck( ply, ent, ply.chosenProp ) ) then return bCol end

	-- cooldown on switching props
	if( ply.lastPropChange &&
		os.time() - ply.lastPropChange < PROP_CHOOSE_COOLDOWN ) then return bCol end

	return gCol
end

local function getViewEnt(ply)
	local Trace = {}
	Trace.start = ply.viewOrigin
	Trace.endpos = Trace.start + ply:GetAngles():Forward() * 1000
	Trace.filter = {ply.chosenProp}
	tr = util.TraceLine(Trace)
	return tr.Entity
end

hook.Add( "PreDrawHalos", "Selectable Prop Halos", function()
	if( LocalPlayer():Team() != TEAM_PROPS ) then return end
	local prop = getViewEnt( LocalPlayer() )
	sColor = stencilColor( LocalPlayer(), prop ) 
	if( !sColor ) then return end
	halo.Add( {prop}, sColor, 3, 3, 1 )
end )
