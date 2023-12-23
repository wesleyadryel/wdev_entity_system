-------------------------------------------------------
------------ MENU VARIABLES  --------------------------
-------------------------------------------------------
local MENU_TITLE = 'Entity System'
local SUBTITLE = '~b~Wdev Solutions'
local LANG = Config.Lang or {}
local maximumItemsPerPage = type(Config.maximumItemsPerPage) == 'number' and Config.maximumItemsPerPage or 9
local LimitListEntitiesPool = (type(Config.LimitListEntitiesPool) == 'number' and Config.LimitListEntitiesPool > 0) and
                                  Config.LimitListEntitiesPool

local _menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu(MENU_TITLE, SUBTITLE, 0, 0, 'prop_screen_nhp_base3', '3_1_setup_02')
_menuPool:Add(mainMenu)

local enable_AllLinesThread = false
local enable_LineThread = false
local selectedEntity = false
local radius_mainMenu = 0
local listProps
local lastDataProp = false
local radiusItemMainMenu = false
local mainSubmenus = {}
local threadForceControl = false
local menu_active = false
local callbacksCloseMenu = {}
local inputThread = false

local mainMenuCallbacks = {}
mainMenuCallbacks.OnMenuChanged = {}
mainMenuCallbacks.OnCheckboxChange = {}
mainMenuCallbacks.OnListChange = {}

local forceControlOfEntity = function(entity, cb)
    if entity then
        if not threadForceControl then
            threadForceControl = true
            Citizen.CreateThread(function()
                while threadForceControl and DoesEntityExist(entity) do
                    NetworkRequestControlOfEntity(entity)
                    if NetworkHasControlOfEntity(entity) then
                        if type(cb) == 'function' then
                            cb(true)
                        end
                        threadForceControl = false
                    end
                    Citizen.Wait(0)
                end
                if threadForceControl then
                    threadForceControl = false
                    cb(false)
                end
            end)
        end
    else
        threadForceControl = false
    end
end

local cancelAllThreads = function()
    enable_AllLinesThread = false
    enable_LineThread = false
end

local defaultColor = {
    r = 255,
    g = 255,
    b = 255,
    a = 255
}
local getColor = function(conf)
    if type(conf) == 'table' and conf.r and conf.g and conf.b and conf.a then
        return conf
    end
    return defaultColor
end

-------------------------------------------------------
------------ NUI MESSAGE ------------------------------
-------------------------------------------------------


local function SendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

-------------------------------------------------------

local getPool = function(objectGamePool, radius_)
    local objects = GetGamePool(objectGamePool)
    local pId = PlayerPedId()
    local isPed = objectGamePool == 'CPed'

    local limit = function(list)
        local count = 0
        local newList = {}
        for __, v in ipairs(list) do
            if count <= LimitListEntitiesPool then
                table.insert(newList, v)
                count = count + 1
            else
                break
            end
        end
        return newList, #newList
    end

    if radius_ == 0 or pId == 0 then
        if not isPed then
            local num = #objects
            local validateLimit = LimitListEntitiesPool and (num > LimitListEntitiesPool)
            if validateLimit then
                return limit(objects)
            end
            return objects, num
        end
        local r = {}
        for __, v in ipairs(objects) do
            if v ~= ped then
                table.insert(r, v)
            end
        end
        local num = #r
        local validateLimit = LimitListEntitiesPool and (num > LimitListEntitiesPool)
        if validateLimit then
            return limit(r)
        end
        return r, num
    end

    local playerCds = GetEntityCoords(pId)
    local formatObjects = {}
    for __, object in ipairs(objects) do
        if not isPed or object ~= pId then
            local cds = GetEntityCoords(object)
            if #(playerCds - cds) <= radius_ then
                table.insert(formatObjects, object)
            end
        end
    end

    local num = #formatObjects
    local validateLimit = LimitListEntitiesPool and (num > LimitListEntitiesPool)
    if validateLimit then
        return limit(formatObjects)
    end
    return formatObjects, num
end

-------------------------------------------------------
------------ THREADS ----------------------------------
-------------------------------------------------------

local threadAllLines = function()
    if not enable_AllLinesThread then
        enable_AllLinesThread = true

        local vehicles, numVehicles = {}, 0
        local peds, numPeds = {}, 0
        local props, numProps = {}, 0
        local pedPlayer = PlayerPedId()

        local lineColors = type(Config.LineColors) == 'table' and Config.LineColors or {}
        lineColors = lineColors.all and lineColors.all or {}

        local color_vehicles = getColor(lineColors.vehicles)
        local color_props = getColor(lineColors.props)
        local color_peds = getColor(lineColors.peds)

        Citizen.CreateThread(function()
            while enable_AllLinesThread do
                peds, numPeds = getPool('CPed', radius_mainMenu)
                vehicles, numVehicles = getPool('CVehicle', radius_mainMenu)
                props, numProps = getPool('CObject', radius_mainMenu)
                pedPlayer = PlayerPedId()
                Citizen.Wait(800)
            end
        end)

        Citizen.CreateThread(function()
            while enable_AllLinesThread do
                local pCoords = GetEntityCoords(pedPlayer)
                if numVehicles > 0 then
                    for i = 1, numVehicles, 1 do
                        local entityCoords = GetEntityCoords(vehicles[i])
                        DrawLine(pCoords.x, pCoords.y, pCoords.z, entityCoords.x, entityCoords.y, entityCoords.z,
                            color_vehicles.r, color_vehicles.g, color_vehicles.b, color_vehicles.a)
                    end
                end
                if numPeds > 0 then
                    for i = 1, numPeds, 1 do
                        local entityCoords = GetEntityCoords(peds[i])
                        DrawLine(pCoords.x, pCoords.y, pCoords.z, entityCoords.x, entityCoords.y, entityCoords.z,
                            color_peds.r, color_peds.g, color_peds.b, color_peds.a)
                    end
                end
                if numProps > 0 then
                    for i = 1, numProps, 1 do
                        local entityCoords = GetEntityCoords(props[i])
                        DrawLine(pCoords.x, pCoords.y, pCoords.z, entityCoords.x, entityCoords.y, entityCoords.z,
                            color_props.r, color_props.g, color_props.b, color_props.a)
                    end
                end
                Citizen.Wait(1)
            end
            cancelAllThreads()
        end)
    end
end

local lineThread = function()
    if not enable_LineThread then
        enable_LineThread = true
        local cds = false
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        local lineColors = type(Config.LineColors) == 'table' and Config.LineColors or {}
        lineColors = lineColors.submenu and lineColors.submenu or {}
        local color = getColor(lineColors)

        Citizen.CreateThread(function()
            while enable_LineThread do
                if selectedEntity and pCoords then
                    if not DoesEntityExist(selectedEntity) then
                        selectedEntity = false
                        cds = false
                    else
                        ped = PlayerPedId()
                        pCoords = GetEntityCoords(ped)
                        cds = GetEntityCoords(selectedEntity)
                    end
                    if cds then
                        DrawLine(pCoords.x, pCoords.y, pCoords.z, cds.x, cds.y, cds.z, color.r, color.g, color.b,
                            color.a)
                    end
                end
                Citizen.Wait(1)
            end
        end)

    end
end

-------------------------------------------------------
------------ UTILS ------------------------------------
-------------------------------------------------------

local alert = function(text)
    if text then
        SendReactMessage('alert', text)
    end
end

local notifyCopyText = function()
    if LANG.notifyCopyText then
        alert(LANG.notifyCopyText)
    end
end

local copyText = function(value)
    if value then
        SendReactMessage('copyText', value)
    end
end

local function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-------------------------------------------------------
------------ MENU FUNCTIONS ---------------------------
-------------------------------------------------------
local function removeSpacesAroundString(inputString)
    local start, finish = inputString:find("^%s*")
    local result = inputString:sub(finish + 1, -1) -- Extrai a parte sem espaços iniciais

    start, finish = result:find("%s*$")
    result = result:sub(1, start - 1) -- Extrai a parte sem espaços finais

    return result
end

local validateInput = function(text)
    if not text or text == "" then
        return false
    end
    local formatText = removeSpacesAroundString(text)
    if not text or text == "" then
        return false
    end
    return formatText
end

local input = function()
    local getValue = function(cb)
        if LANG.entityModel then
            Citizen.CreateThread(function()
                if inputThread then
                    inputThread = false
                    Citizen.Wait(100)
                end
                if not inputThread then
                    inputThread = true
                    AddTextEntry('ENTITY_MODEL_INPUT', LANG.entityModel)
                    DisplayOnscreenKeyboard(1, "ENTITY_MODEL_INPUT", "", "", "", "", "", 30)
                    while inputThread and (UpdateOnscreenKeyboard() == 0) do
                        DisableAllControlActions(0);
                        Wait(0);
                    end
                    if inputThread then
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            result = validateInput(result)
                            if not result then
                                result = false
                            end
                            inputThread = false
                            return cb(result)
                        end
                    end
                end
                inputThread = false
                return cb(false)
            end)
        end
    end
    local p = promise.new()
    getValue(function(textResponse)
        p:resolve(textResponse)
    end)
    return Citizen.Await(p)
end

local createEntity = function(entityType, entityHash)
    if not entityType and not entityHash or not IsModelValid(entityHash) then
        return
    end
    local playerPed = PlayerPedId()
    local cdsPlayer = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local isNetwork = Config.createEntitiesWithNetwork and true or false
    RequestModel(entityHash)
    local attempt = 0
    while not HasModelLoaded(entityHash) and attempt < 120 do
        Wait(15)
        attempt = attempt + 1
    end
    if HasModelLoaded(entityHash) then

        if entityType == 'CPed' then
            local entity = CreatePed(4, entityHash, cdsPlayer.x, cdsPlayer.y, cdsPlayer.z, heading, isNetwork, 1)
            local c = 0
            while not DoesEntityExist(entity) and c < 10 do
                Citizen.Wait(100)
                c = c + 1
            end
            if DoesEntityExist(entity) then
                local posAttach = {
                    hand = 4103,
                    pos1 = 0.50,
                    pos2 = 0.38,
                    pos3 = 0.00,
                    pos4 = 0.00,
                    pos5 = 0.00,
                    pos6 = 0.00
                }

                AttachEntityToEntity(entity, playerPed, GetPedBoneIndex(playerPed, posAttach.hand), posAttach.pos1,
                    posAttach.pos2, posAttach.pos3, posAttach.pos4, posAttach.pos5, posAttach.pos6, 1, 1, 0, true, 2, 1)
                return entity
            end
            return
        end

        if entityType == 'CVehicle' then
            local entity = CreateVehicle(entityHash, cdsPlayer.x, cdsPlayer.y, cdsPlayer.z, heading, isNetwork, true)
            if entity then
                local c = 0
                while not DoesEntityExist(entity) and c < 30 do
                    Citizen.Wait(100)
                    c = c + 1
                end
                if DoesEntityExist(entity) then
                    local modelDimensions = GetModelDimensions(entityHash)
                    local modelX = modelDimensions.x or 0.0
                    local modelZ = modelDimensions.z or 0.0
                    local pos1 = math.abs(modelX)
                    local pos3 = math.abs(modelZ)

                    local posAttach = {
                        hand = 4103,
                        pos1 = pos1 + 0.7,
                        pos2 = 0.38,
                        pos3 = pos3 - 0.9,
                        pos4 = 0.00,
                        pos5 = 0.00,
                        pos6 = 0.00
                    }

                    AttachEntityToEntity(entity, playerPed, GetPedBoneIndex(playerPed, posAttach.hand), posAttach.pos1,
                        posAttach.pos2, posAttach.pos3, posAttach.pos4, posAttach.pos5, posAttach.pos6, 1, 1, 0, true,
                        2, 1)

                    return entity
                end
            end
            return
        end

        if entityType == 'CObject' then
            local entity = CreateObjectNoOffset(entityHash, cdsPlayer.x, cdsPlayer.y, cdsPlayer.z, isNetwork, false,
                false)
            if entity then
                local c = 0
                while not DoesEntityExist(entity) and c < 30 do
                    Citizen.Wait(100)
                    c = c + 1
                end
                if DoesEntityExist(entity) then
                    local modelDimensions = GetModelDimensions(entityHash)
                    local modelX = modelDimensions.x or 0.0
                    local modelZ = modelDimensions.z or 0.0
                    local pos1 = math.abs(modelX)
                    local pos3 = math.abs(modelZ)

                    local posAttach = {
                        hand = 4103,
                        pos1 = pos1 + 0.7,
                        pos2 = 0.38,
                        pos3 = pos3 - 0.9,
                        pos4 = 0.00,
                        pos5 = 0.00,
                        pos6 = 0.00
                    }

                    AttachEntityToEntity(entity, playerPed, GetPedBoneIndex(playerPed, posAttach.hand), posAttach.pos1,
                        posAttach.pos2, posAttach.pos3, posAttach.pos4, posAttach.pos5, posAttach.pos6, 1, 1, 0, true,
                        2, 1)

                    return entity
                end
            end
            return
        end

    end

end

local function menu_item_createEntity(menu, entityText, objectGamePool)
    if LANG.createEntity and LANG.createEntityDescription and entityText then
        local titleText = string.format(LANG.createEntity, tostring(entityText))
        local itemsMenu = {}
        local createdEntity = false

        local mouseEnabled = false
        local submenu, newIndex, ItemMenu = _menuPool:AddSubMenu(menu, titleText, LANG.createEntityDescription, false,
            false, mouseEnabled)
        submenu:setTotalItemsPerPage(maximumItemsPerPage)
        local setAuxiliaryItemsState = function(state)
            if itemsMenu.cancel then
                NativeUI.toggleEnableComponent(itemsMenu.cancel, state)
            end
            if itemsMenu.confirm then
                if state then
                    itemsMenu.confirm:SetRightBadge(BadgeStyle.Star)
                    itemsMenu.confirm.Text = NativeUI.CreateText('~g~' .. LANG.createSystem_confirm, 8, 0, 0.33, 245,
                        245, 245, 255, 0)
                else
                    itemsMenu.confirm:SetRightBadge(BadgeStyle.None)
                    itemsMenu.confirm.Text = NativeUI.CreateText(LANG.createSystem_confirm, 8, 0, 0.33, 245, 245, 245,
                        255, 0)
                end
                NativeUI.toggleEnableComponent(itemsMenu.confirm, state)
            end
        end

        local onOpenMenu = function()
            submenu:Clear()

            if LANG.createSystem_create and LANG.createSystem_confirm and LANG.createSystem_cancel then

                itemsMenu.create = NativeUI.CreateItem(LANG.createSystem_create)
                submenu:AddItem(itemsMenu.create)

                itemsMenu.cancel = NativeUI.CreateItem(LANG.createSystem_cancel)
                submenu:AddItem(itemsMenu.cancel)

                itemsMenu.confirm = NativeUI.CreateItem(LANG.createSystem_confirm)
                submenu:AddItem(itemsMenu.confirm)

                setAuxiliaryItemsState(false)

                submenu:CurrentSelection(0)
                --  submenu.ActiveItem = 0
            end

        end

        local addCallbacks = function()
            table.insert(mainMenuCallbacks.OnMenuChanged, function(_menu, _newmenu, _forward)
                if menu == _newmenu then
                    onOpenMenu()
                end
            end)
            submenu.OnItemSelect = function(sender, _item, index)

                if _item == itemsMenu.create then
                    local entityModelResponse = input()
                    if entityModelResponse then
                        local hash = GetHashKey(entityModelResponse)
                        if hash and hash ~= 0 then
                            createdEntity = createEntity(objectGamePool, hash)
                            SetTimeout(1000, function()
                                if createdEntity and DoesEntityExist(createdEntity) then
                                    setAuxiliaryItemsState(true)
                                end
                            end)
                        end
                    end
                    return
                end

                if _item == itemsMenu.cancel then
                    if createdEntity and DoesEntityExist(createdEntity) then
                        forceControlOfEntity(createdEntity, function(success)
                            if success then
                                DeleteEntity(createdEntity)
                                if not createdEntity or not DoesEntityExist(createdEntity) then
                                    setAuxiliaryItemsState(false)
                                end
                            end
                        end)
                    end
                    return
                end

                if _item == itemsMenu.confirm then
                    if createdEntity and DoesEntityExist(createdEntity) then
                        forceControlOfEntity(createdEntity, function(success)
                            if success then
                                DetachEntity(createdEntity, true)
                            end
                            submenu:GoBack()
                        end)
                    else
                        submenu:GoBack()
                    end
                    return
                end
            end
        end

        addCallbacks()
        return ItemMenu
    end
end

local function menu_item_propInformation(menu)
    if LANG.entityInfo and LANG.entityInfoDescription then

        local itemsInfo = {}

        local mouseEnabled = false
        local submenu, newIndex, ItemMenu = _menuPool:AddSubMenu(menu, LANG.entityInfo, LANG.entityInfoDescription,
            false, false, mouseEnabled)
        submenu:setTotalItemsPerPage(maximumItemsPerPage)
        local onOpenMenu = function()
            submenu:Clear()
            if selectedEntity and DoesEntityExist(selectedEntity) then
                local addItemInfo = function(text)
                    if text then
                        local desc = LANG.enterCopyText or nil
                        local newitem = NativeUI.CreateItem(text, desc)
                        submenu:AddItem(newitem)
                        return newitem
                    end
                end

                local langInfo = LANG.propInfoList
                if langInfo then

                    if langInfo.id then
                        itemsInfo.id = {}
                        itemsInfo.id.menu = addItemInfo(langInfo.id .. tostring(selectedEntity))
                        itemsInfo.id.value = selectedEntity
                    end

                    local hash = GetEntityModel(selectedEntity)

                    if langInfo.modelHash and hash ~= 0 then
                        itemsInfo.modelHash = {}
                        itemsInfo.modelHash.menu = addItemInfo(langInfo.modelHash .. tostring(hash))
                        itemsInfo.modelHash.value = hash
                    end

                    if langInfo.modelName and PropList then
                        local modelName = PropList[tostring(hash)]
                        if modelName then
                            itemsInfo.modelName = {}
                            itemsInfo.modelName.menu = addItemInfo(langInfo.modelName .. tostring(modelName))
                            itemsInfo.modelName.value = modelName
                        end
                    end

                    if langInfo.coords then
                        local cds = GetEntityCoords(selectedEntity)
                        itemsInfo.coords = {}
                        local cdsStr = string.format('%.2f, %.2f, %.2f', tonumber(cds.x), tonumber(cds.y),
                            tonumber(cds.z))
                        itemsInfo.coords.menu = addItemInfo(langInfo.coords .. cdsStr)
                        itemsInfo.coords.value = cdsStr
                    end

                    if langInfo.heading then
                        local heading = GetEntityHeading(selectedEntity)
                        itemsInfo.heading = {}
                        itemsInfo.heading.menu = addItemInfo(langInfo.heading ..
                                                                 string.format("%.2f", tonumber(heading)))
                        itemsInfo.heading.value = heading
                    end

                    if langInfo.rotation then
                        local rotation = GetEntityRotation(selectedEntity)
                        itemsInfo.rotation = {}
                        local rotationStr = string.format('%.2f, %.2f, %.2f', tonumber(rotation.x),
                            tonumber(rotation.y), tonumber(rotation.z))
                        itemsInfo.rotation.menu = addItemInfo(langInfo.rotation .. rotationStr)
                        itemsInfo.rotation.value = rotationStr
                    end

                    if langInfo.entityOwnerSource then
                        local success, entityOwner = pcall(NetworkGetEntityOwner, selectedEntity)
                        local owner = success and entityOwner
                        if owner then
                            local pId = GetPlayerServerId(owner)
                            if pId then
                                itemsInfo.entityOwnerSource = {}
                                itemsInfo.entityOwnerSource.menu =
                                    addItemInfo(langInfo.entityOwnerSource .. tostring(pId))
                                itemsInfo.entityOwnerSource.value = pId
                            end
                        end
                    end

                    if IsEntityAVehicle(selectedEntity) then
                        if langInfo.plate then
                            local plate = GetVehicleNumberPlateText(selectedEntity)
                            itemsInfo.plate = {}
                            itemsInfo.plate.menu = addItemInfo(langInfo.plate .. plate)
                            itemsInfo.plate.value = plate
                        end
                    end

                    local success, isNetworked = pcall(NetworkGetEntityIsNetworked, selectedEntity)
                    if success then

                        if langInfo.isNetworked and langInfo.isNetworkedYes and langInfo.isNetworkedNo then
                            itemsInfo.isNetworked = {}
                            local text = isNetworked and langInfo.isNetworkedYes or langInfo.isNetworkedNo
                            itemsInfo.isNetworked.menu = addItemInfo(langInfo.isNetworked .. text)
                            itemsInfo.isNetworked.value = text
                        end

                        if isNetworked then

                            if langInfo.entityNetID then
                                local netId = NetworkGetNetworkIdFromEntity(selectedEntity)
                                itemsInfo.entityNetID = {}
                                itemsInfo.entityNetID.menu = addItemInfo(langInfo.entityNetID .. netId)
                                itemsInfo.entityNetID.value = netId
                            end

                        end
                    end

                end
            end
            _menuPool:goToFirstElementMenu()
        end

        local addCallbacks = function()

            table.insert(mainMenuCallbacks.OnMenuChanged, function(_menu, _newmenu, _forward)
                if menu == _newmenu then
                    onOpenMenu()
                end
            end)

            submenu.OnItemSelect = function(sender, item, index)

                for k, v in pairs(itemsInfo) do
                    if item == v.menu then
                        copyText(v.value)
                        notifyCopyText()
                        return
                    end
                end

            end

        end

        addCallbacks()
        return ItemMenu
    end
end

local function menu_item_propsList(menu, entityText, objectGamePool)
    if LANG.ListOfEntities and LANG.ListOfEntitiesDescription then
        local radius_submenu = 0

        local propInformationItemMenu = false
        local createEntityItemMenu = false
        local menuItems = {}

        local mouseEnabled = false
        local submenu = _menuPool:AddSubMenu(menu, string.format(LANG.ListOfEntities, entityText),
            string.format(LANG.ListOfEntitiesDescription, entityText), false, false, mouseEnabled)

        submenu:setTotalItemsPerPage(maximumItemsPerPage)

        local toggleMutableMenuOptions = function(state)
            if menuItems.propMoveMenu then
                NativeUI.toggleEnableComponent(menuItems.propMoveMenu, state)
            end
            if menuItems.propDeleteMenu then
                NativeUI.toggleEnableComponent(menuItems.propDeleteMenu, state)
            end
            if menuItems.freezeEntity then
                NativeUI.toggleEnableComponent(menuItems.freezeEntity, state)
            end
            if menuItems.pedDead then
                NativeUI.toggleEnableComponent(menuItems.pedDead, state)
            end
            if menuItems.lineMenu then
                NativeUI.toggleEnableComponent(menuItems.lineMenu, state)
            end
            if propInformationItemMenu then
                NativeUI.toggleEnableComponent(propInformationItemMenu, state)
            end
        end

        local updateItems = function()
            listProps = getPool(objectGamePool, radius_submenu)
            if menuItems.propMenu then
                menuItems.propMenu:updateItems(listProps)
                selectedEntity = listProps[1] or nil
                menuItems.propMenu._Index = 1

                if selectedEntity then
                    toggleMutableMenuOptions(true)
                else
                    toggleMutableMenuOptions(false)
                end
            end
        end

        local function addPropMenu()
            if LANG.entitiesPool then
                listProps = getPool(objectGamePool, radius_submenu)
                table.insert(listProps, 1, 'N/A')
                local newitem = NativeUI.CreateListItem(string.format(LANG.entitiesPool, entityText), listProps, 1)
                menuItems.propMenu = newitem
                submenu:AddItem(newitem)
            end
        end
        local function lineSelectEntity()
            if LANG.lineSelectEntity and LANG.lineSelectEntityDescription then
                local newitem = NativeUI.CreateCheckboxItem(LANG.lineSelectEntity, enable_LineThread,
                    LANG.lineSelectEntityDescription)
                submenu:AddItem(newitem)
                menuItems.lineMenu = newitem
                NativeUI.toggleEnableComponent(newitem, false)
            end
        end
        local function addRadiusSelect()
            if LANG.radiusListEntities and LANG.radiusListPropsDescription then
                local radiusList = {}
                for i = 0, 500 do
                    table.insert(radiusList, i)
                end
                local newitem = NativeUI.CreateListItem(string.format(LANG.radiusListEntities, entityText), radiusList,
                    radius_submenu, LANG.radiusListPropsDescription)
                menuItems.radiusMenu = newitem
                submenu:AddItem(newitem)
            end
        end
        local setDead = function()
            if objectGamePool and objectGamePool == 'CPed' then
                if LANG.pedDead and LANG.pedDeadDescription then
                    local newitem = NativeUI.CreateCheckboxItem(LANG.pedDead, false, LANG.pedDeadDescription)
                    menuItems.pedDead = newitem
                    submenu:AddItem(newitem)
                    NativeUI.toggleEnableComponent(newitem, false)
                    NativeUI.checkedItem(newitem, false)
                end
            end
        end
        local addMove = function()
            if LANG.moveEntity and LANG.moveEntityDescription then
                local newitem = NativeUI.CreateItem(LANG.moveEntity, LANG.moveEntityDescription)
                submenu:AddItem(newitem)
                menuItems.propMoveMenu = newitem
                NativeUI.toggleEnableComponent(newitem, false)
            end
        end
        local addDelete = function()
            if LANG.deleteEntity and LANG.deleteEntityDescription then
                local newitem = NativeUI.CreateItem(LANG.deleteEntity, LANG.deleteEntityDescription)
                submenu:AddItem(newitem)
                menuItems.propDeleteMenu = newitem
                NativeUI.toggleEnableComponent(newitem, false)
            end
        end
        local addFreeze = function()
            if LANG.pedDead and LANG.freezeEntityDescription then
                local newitem = NativeUI.CreateCheckboxItem(LANG.freezeEntity, false, LANG.freezeEntityDescription)
                menuItems.freezeEntity = newitem
                submenu:AddItem(newitem)
                NativeUI.toggleEnableComponent(newitem, false)
            end
        end
        local addRefresh = function()
            if LANG.refreshList and LANG.refreshListDescription then
                local newitem = NativeUI.CreateItem(LANG.refreshList, LANG.refreshListDescription)
                submenu:AddItem(newitem)
                menuItems.refreshMenu = newitem
            end
        end

        local addCallbacks = function()

            submenu.OnCheckboxChange = function(_menu, _item, _checked)

                if _item == menuItems.lineMenu then
                    if _checked then
                        lineThread()
                    else
                        enable_LineThread = false
                    end
                    return
                end

                if _item == menuItems.pedDead then
                    if selectedEntity and DoesEntityExist(selectedEntity) and IsEntityAPed(selectedEntity) and
                        not IsPedAPlayer(selectedEntity) then
                        if _checked then
                            SetEntityHealth(selectedEntity, 0)
                        else
                            if IsEntityDead(selectedEntity) then
                                ClearPedTasksImmediately(selectedEntity)
                                ResurrectPed(selectedEntity)
                                local maxHealth = GetEntityMaxHealth(selectedEntity)
                                SetEntityHealth(selectedEntity, maxHealth)
                                ClearPedTasksImmediately(selectedEntity)
                                ClearPedBloodDamage(selectedEntity)
                            end
                            SetEntityHealth(selectedEntity, 300)
                        end
                    end
                    return
                end

                if _item == menuItems.freezeEntity then
                    forceControlOfEntity(selectedEntity, function(success)
                        if success then
                            if selectedEntity and DoesEntityExist(selectedEntity) and not IsPedAPlayer(selectedEntity) then
                                if _checked then
                                    FreezeEntityPosition(selectedEntity, true)
                                else
                                    FreezeEntityPosition(selectedEntity, false)
                                end
                            end
                        end
                    end)
                    return
                end

            end

            submenu.OnItemSelect = function(sender, item, index)

                if item == menuItems.refreshMenu then
                    updateItems()
                    if LANG.refreshListNotify then
                        ShowNotification(LANG.refreshListNotify)
                    end
                    return
                end

                if item == menuItems.propMoveMenu then
                    forceControlOfEntity(selectedEntity, function(success)
                        if success then
                            if selectedEntity and DoesEntityExist(selectedEntity) then

                                local camConfig = {
                                    position = GetFinalRenderedCamCoord(),
                                    rotation = GetFinalRenderedCamRot()
                                }
                                local data = {
                                    position = GetEntityCoords(selectedEntity),
                                    rotation = GetEntityRotation(selectedEntity),
                                    showNui = true
                                }

                                SendReactMessage('props:setcam', camConfig)
                                SendReactMessage('props:setObject', data)
                                lastDataProp = {
                                    position = GetEntityCoords(selectedEntity),
                                    rotation = GetEntityRotation(selectedEntity),
                                    freeze = IsEntityPositionFrozen(selectedEntity)
                                }
                                FreezeEntityPosition(selectedEntity, true)
                                SetNuiFocus(true, true)
                            end
                        end
                    end)
                end

                if item == menuItems.propDeleteMenu then
                    if selectedEntity and DoesEntityExist(selectedEntity) then
                        forceControlOfEntity(selectedEntity, function(success)
                            if success then
                                DeleteEntity(selectedEntity)
                            end
                        end)
                    end
                end

            end

            submenu.OnListChange = function(_menu, _list, _newindex)

                if _list == menuItems.propMenu then
                    local propId = _list:IndexToItem(_newindex)
                    selectedEntity = propId
                    if propId and propId ~= 'N/A' and type(propId) == 'number' and tonumber(propId) > 0 then
                        toggleMutableMenuOptions(true)
                    else
                        toggleMutableMenuOptions(false)
                    end
                    return
                end

                if _list == menuItems.radiusMenu then
                    local quantity = _list:IndexToItem(_newindex)
                    radius_submenu = tonumber(quantity)
                    updateItems()
                    return
                end

            end

            local onMenuClose = function()
                enable_LineThread = false
                if menuItems.lineMenu then
                    NativeUI.checkedItem(menuItems.lineMenu, false)
                end
                selectedEntity = false
                if menuItems.propMenu then
                    menuItems.propMenu._Index = 0
                end
                toggleMutableMenuOptions(false)
            end

            table.insert(callbacksCloseMenu, onMenuClose)

            submenu.OnMenuClosed = function(_menu)
                onMenuClose()
            end

        end

        createEntityItemMenu = menu_item_createEntity(submenu, entityText, objectGamePool)
        addPropMenu()
        addRadiusSelect()
        propInformationItemMenu = menu_item_propInformation(submenu)
        lineSelectEntity()
        setDead()
        addMove()
        addDelete()
        addFreeze()
        addRefresh()
        addCallbacks()

        toggleMutableMenuOptions(false)

        return submenu
    end
end

local function menu_item_enabled(menu)
    if LANG.enableAllLines and LANG.enableAllLinesDescription then
        local newitem = NativeUI.CreateCheckboxItem(LANG.enableAllLines, false, LANG.enableAllLinesDescription)
        menu:AddItem(newitem)
        table.insert(mainMenuCallbacks.OnCheckboxChange, function(_sender, _item, _checked)
            if _item == newitem then
                if _checked then
                    threadAllLines()
                else
                    enable_AllLinesThread = false
                end
            end
        end)
    end
end

local function addRadiusSelectDefaultMenu()
    if LANG.radiusListEntities and LANG.radiusListPropsDescription then
        local radiusList = {}
        for i = 0, 500 do
            table.insert(radiusList, i)
        end
        local newitem = NativeUI.CreateListItem(string.format(LANG.radiusListEntities, 'All'), radiusList,
            radius_mainMenu, LANG.radiusListPropsDescription)
        mainMenu:AddItem(newitem)
        radiusItemMainMenu = newitem
    end
end

-------------------------------------------------------
------------ INITIALIZE MENU --------------------------
-------------------------------------------------------
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)
_menuPool:RefreshIndex()
_menuPool:TotalItemsPerPage(maximumItemsPerPage)


menu_item_enabled(mainMenu)
addRadiusSelectDefaultMenu()

if LANG.props then
    mainSubmenus.props = menu_item_propsList(mainMenu, LANG.props, 'CObject')
end
if LANG.vehicles then
    mainSubmenus.vehicles = menu_item_propsList(mainMenu, LANG.vehicles, 'CVehicle')
end
if LANG.peds then
    mainSubmenus.peds = menu_item_propsList(mainMenu, LANG.peds, 'CPed')
end

local closeMenu = function()
    _menuPool:CloseAllMenus()
    menu_active = false
    if type(callbacksCloseMenu) == 'table' then
        for k, v in pairs(callbacksCloseMenu) do
            if type(v) == 'function' then
                pcall(v)
            end
        end
    end
end

local proccessCallbacksMainMenu = function()
    mainMenu.OnMenuClosed = function(_menu)
        if _menu == mainMenu then
            closeMenu()
        end
    end

    mainMenu.OnMenuChanged = function(menu, newmenu, forward)
        if type(mainMenuCallbacks.OnMenuChanged) == 'table' then
            for k, v in pairs(mainMenuCallbacks.OnMenuChanged) do
                if type(v) == 'function' then
                    pcall(v, menu, newmenu, forward)
                end
            end
        end
    end
    mainMenu.OnCheckboxChange = function(menu, item, checked)
        if type(mainMenuCallbacks.OnCheckboxChange) == 'table' then
            for k, v in pairs(mainMenuCallbacks.OnCheckboxChange) do
                if type(v) == 'function' then
                    pcall(v, menu, item, checked)
                end
            end
        end
    end

    mainMenu.OnListChange = function(menu, list, newindex)

        if radiusItemMainMenu and list == radiusItemMainMenu then
            local quantity = list:IndexToItem(newindex)
            radius_mainMenu = tonumber(quantity)
            return
        end

        if type(mainMenuCallbacks.OnListChange) == 'table' then
            for k, v in pairs(mainMenuCallbacks.OnListChange) do
                if type(v) == 'function' then
                    pcall(v, menu, list, newindex)
                end
            end
        end

    end

end
proccessCallbacksMainMenu()
-------------------------------------------------------
------------ MENU CONTROLLER ----------------------------
-------------------------------------------------------
local toggleMenu = function(state)
    if not IsPauseMenuActive() then
        if state then
            if not menu_active then
                menu_active = true
                mainMenu:Visible(true)
                _menuPool:goToFirstElementMenu()
                Citizen.CreateThread(function()
                    while menu_active do
                        _menuPool:ProcessMenus()
                        Citizen.Wait(1)
                    end
                    closeMenu()
                end)
            end
        else
            if menu_active then
                closeMenu()
            end
        end
    end
end
RegisterNetEvent("wdev_entity_system:menu", toggleMenu)

-------------------------------------------------------
------------ NUI CALLBACKS ----------------------------
-------------------------------------------------------

RegisterNUICallback('updateObject', function(data, cb)
    if type(data) == 'table' then
        if selectedEntity and DoesEntityExist(selectedEntity) then
            local position = data.position
            local rotation = data.rotation
            if position and rotation then
                forceControlOfEntity(selectedEntity, function(success)
                    if success then
                        SetEntityCoords(selectedEntity, position.x, position.y, position.z)
                        SetEntityRotation(selectedEntity, rotation.x, rotation.y, rotation.z)
                    end
                end)
            end
        end
    end
end)

RegisterNUICallback('props:cancel', function(data, cb)
    if selectedEntity and DoesEntityExist(selectedEntity) then
        if type(lastDataProp) == 'table' then
            local position = lastDataProp.position
            local rotation = lastDataProp.rotation
            SetEntityCoords(selectedEntity, position)
            SetEntityRotation(selectedEntity, rotation)

            local camConfig = {
                position = GetFinalRenderedCamCoord(),
                rotation = GetFinalRenderedCamRot()
            }
            local data = {
                position = GetEntityCoords(selectedEntity),
                rotation = GetEntityRotation(selectedEntity)
            }

            SendReactMessage('props:setcam', camConfig)
            SendReactMessage('props:setObject', data)

            if lastDataProp.freeze then
                FreezeEntityPosition(selectedEntity, true)
            else
                FreezeEntityPosition(selectedEntity, false)
            end
        end
    end
end)

RegisterNUICallback('props:close', function(data, cb)
    SetNuiFocus(false, false)
    if selectedEntity and type(lastDataProp) == 'table' then
        if lastDataProp.freeze then
            FreezeEntityPosition(selectedEntity, true)
        else
            FreezeEntityPosition(selectedEntity, false)
        end
    end
end)

-------------------------------------------------------
------------ CLIENT EXPORTS ---------------------------
-------------------------------------------------------
exports("toggleMenu", toggleMenu)

--     -- =============================================================================
--     toggleMenu:
--     PARAMETERS:  state : BOOLEAN
--     exports[wdev_entity_system]:toggleMenu(state)
--     DESCRIPTION:  Enables/Disables Props System Menu
--    -- =============================================================================

