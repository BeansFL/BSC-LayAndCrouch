local crouched = false
local proned = false
local SetBack = false

CreateThread(function()
    while true do
        local player = PlayerId()
        local playerPed = GetPlayerPed(player)
        if IsEntityDead(playerPed) then
            DisableControlAction(0, 29) -- B 
        end
        Wait(0)
    end 
end)  

 
CreateThread( function()
	while true do 
		Wait(1)   
		local ped = PlayerPedId()
		if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
			SetPedUsingActionMode(GetPlayerPed(-1), false, -1, 0)
			if proned and  SetBack then
			ProneMovement()
			DisableControlAction( 0, ProneKey, true ) 
			DisableControlAction( 0, CrouchKey, true ) 
			if ( not IsPauseMenuActive() ) then 
				if ( IsDisabledControlJustPressed( 0, CrouchKey ) and not proned ) then 
					RequestAnimSet( "move_ped_crouched" ) 
					RequestAnimSet("MOVE_M@TOUGH_GUY@")
					 
					while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
						Wait( 100 ) 
					end 
					while ( not HasAnimSetLoaded( "MOVE_M@TOUGH_GUY@" ) ) do 
						Wait( 100 )
					end 		
					if ( crouched and not proned ) then 
						ResetPedMovementClipset( ped )
						ResetPedStrafeClipset(ped)
						SetPedMovementClipset( ped,"MOVE_M@TOUGH_GUY@", 0.5)
						crouched = false 
					elseif ( not crouched and not proned ) then
						SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
						SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
						crouched = true 
					end 
				elseif ( IsDisabledControlJustPressed(0, ProneKey) and not crouched and not IsPedInAnyVehicle(ped, true) and not IsPedFalling(ped) and not IsPedDiving(ped) and not IsPedInCover(ped, false) and not IsPedInParachuteFreeFall(ped) and (GetPedParachuteState(ped) == 0 or GetPedParachuteState(ped) == -1) ) then
					if proned then
						local me = GetEntityCoords(ped)
						SetEntityCoords(ped, me.x, me.y, me.z-0.5)
						proned = false
					elseif not proned then
						RequestAnimSet( "move_crawl" )
						while ( not HasAnimSetLoaded( "move_crawl" ) ) do 
							Wait( 100 )
						end  
						proned = true
						if IsPedSprinting(ped) or IsPedRunning(ped) or GetEntitySpeed(ped) > 5 then
							TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
							Wait(950)
						end
						SetProned() 
					end
				end
			end
			end
		else 
			proned = false
			crouched = false
		end
	end
end)



function SetProned()
    SetPedUsingActionMode(GetPlayerPed(-1), false, -1, 0)
    EnableControlAction(0, 32)
    EnableControlAction(0, 33)
    EnableControlAction(0, 34)
	EnableControlAction(0, 30)
    ped = PlayerPedId()
    TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 0.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
end



function SetBack()
	SetPedUsingActionMode(GetPlayerPed(-1), false, -1, 0)
	ped = PlayerPedId()
	DisableControlAction(0, 32) -- w
	DisableControlAction(0, 33) -- s
	DisableControlAction(0, 34) -- a
	DisableControlAction(0, 30) -- d
	TaskPlayAnimAdvanced(ped, "move_crawl", "onback_fwd", GetEntityCoords(ped), 0.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
end
 
function ProneMovement()
    if proned then
		EnableControlAction(0, 32)
		EnableControlAction(0, 33)
		EnableControlAction(0, 34)
		EnableControlAction(0, 30)
		EnableAllControlActions(0)
        SetPedUsingActionMode(GetPlayerPed(-1), false, -1, 0)
        local ped = PlayerPedId()
        DisableControlAction(0, 23)
        DisableControlAction(0, 21)

        -- Check if the player is firing while prone
        if IsControlPressed(0, 32) or IsControlPressed(0, 33) then
            DisablePlayerFiring(ped, true)
        elseif IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) then
            DisablePlayerFiring(ped, false)
        end

        -- Check if the player is moving forward or backward
		if IsControlJustPressed(0, 32) and not movefwd then
			movefwd = true
			TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 47, 1.0, 0, 0)
		elseif IsControlJustReleased(0, 32) and movefwd then
			movefwd = false
			TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
		end
		if IsControlJustPressed(0, 33) and not movefwd then
			movefwd = true
			TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 47, 1.0, 0, 0)
		elseif IsControlJustReleased(0, 33) and movefwd then 
			movefwd = false
			TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
		end

        -- Check if the player is turning left or right
        if IsControlPressed(0, 34) then
            SetEntityHeading(ped, GetEntityHeading(ped)+2.0 )
        elseif IsControlPressed(0, 35) then
            SetEntityHeading(ped, GetEntityHeading(ped)-2.0 )
        end
    end
end






RegisterCommand("crouch", function(source, args, rawCommand)
    local ped = PlayerPedId()
    if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
        RequestAnimSet( "move_ped_crouched" ) 
        RequestAnimSet("MOVE_M@TOUGH_GUY@")
        while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
            Wait( 100 ) 
        end 
        while ( not HasAnimSetLoaded( "MOVE_M@TOUGH_GUY@" ) ) do 
            Wait( 100 )
        end 		
        if ( crouched and not proned ) then 
            ResetPedMovementClipset( ped )
            ResetPedStrafeClipset(ped)
            SetPedMovementClipset( ped,"MOVE_M@TOUGH_GUY@", 0.5)
            crouched = false 
        elseif ( not crouched and not proned ) then
            SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
            SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
            crouched = true 
        end 
    end
end, false)
  

RegisterCommand("prone", function(source, args, rawCommand)
    local ped = PlayerPedId()
    if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) and not crouched and not IsPedInAnyVehicle(ped, true) and not IsPedFalling(ped) and not IsPedDiving(ped) and not IsPedInCover(ped, false) and not IsPedInParachuteFreeFall(ped) and (GetPedParachuteState(ped) == 0 or GetPedParachuteState(ped) == -1) ) then
        RequestAnimSet( "move_crawl" )
        while ( not HasAnimSetLoaded( "move_crawl" ) ) do 
            Wait( 100 )
        end  
        if proned then
            local me = GetEntityCoords(ped)
            SetEntityCoords(ped, me.x, me.y, me.z-0.5)
            proned = false
        elseif not proned then
            proned = true
            if IsPedSprinting(ped) or IsPedRunning(ped) or GetEntitySpeed(ped) > 5 then
                TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
                Wait(950)
            end
            SetProned() 
        end
    end
end, false) 

RegisterCommand("back", function(source, args, rawCommand)
    local ped = PlayerPedId()
    if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) and not crouched and not IsPedInAnyVehicle(ped, true) and not IsPedFalling(ped) and not IsPedDiving(ped) and not IsPedInCover(ped, false) and not IsPedInParachuteFreeFall(ped) and (GetPedParachuteState(ped) == 0 or GetPedParachuteState(ped) == -1) ) then

            Wait( 100 )
        end  
        if proned then
            local me = GetEntityCoords(ped)
            SetEntityCoords(ped, me.x, me.y, me.z-0.5)
            proned = false
        elseif not proned then
            proned = true
            if IsPedSprinting(ped) or IsPedRunning(ped) or GetEntitySpeed(ped) > 5 then
                TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
                Wait(950)
            end
            SetBack()
        end	 
end, false) 
 

RegisterKeyMapping("crouch", "Crouch", "keyboard", Config.CrouchKey)
RegisterKeyMapping("back", "Lay Back", "keyboard", Config.LayBackKey)
RegisterKeyMapping("prone", "Prone", "keyboard", Config.ProneKey)    




