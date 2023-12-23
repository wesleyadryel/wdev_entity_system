
-- insert in server.cfg: 
-- add_ace group.admin wdev_entity_system:admin allow

local validatePermission = function(src)
    if not Config.validatePermission or IsPlayerAceAllowed(src, Config.validatePermission) then
        return true
    end
end

local toggleMenu = function(src, state)
    if src then
        if validatePermission(src) then
            TriggerClientEvent('wdev_entity_system:menu', src, true)
        end
    end
end

if Config and Config.commandOpen then
    RegisterCommand(Config.commandOpen, function(src)
        toggleMenu(src)
    end)
end

-------------------------------------------------------
------------ SERVER EXPORTS ---------------------------
-------------------------------------------------------
exports("toggleMenu", toggleMenu)

--     -- =============================================================================
--     toggleMenu:
--     PARAMETERS:  source: NUMBER, state : BOOLEAN
--     exports[wdev_entity_system]:toggleMenu(source, state)
--     DESCRIPTION:  Enables/Disables Props System Menu
--    -- =============================================================================

