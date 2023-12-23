Config = {}

Config.validatePermission = false -- 'wdev_entity_system:admin' -- false to disable
Config.commandOpen = 'menu' -- or false to disable
Config.createEntitiesWithNetwork = true
Config.LimitListEntitiesPool = false -- number or false/0 to disable
Config.maximumItemsPerPage =  5
Config.LineColors = {
    all = {
        vehicles ={r=177, g=52, b=209, a=255},
        peds = {r=229, g=210, b=79, a=255},
        props = {r=120, g=210, b=9, a=255}
    },
    submenu = {r=209, g=52, b=78, a=255}
}

Config.Lang = {

    requetControlOfEntity = "It appears that this entity is under the control of another player. Requesting control... Try again in 1 second",

    props = 'Props',
    vehicles = 'Vehicles',
    peds = 'Peds',

    enableAllLines = 'Enable All Lines',
    enableAllLinesDescription = 'Enable Lines on all nearby entities',

    ListOfEntities = 'List of %s',
    ListOfEntitiesDescription = 'Use this option to list the [%s] around you',
    entitiesPool = '%s Game Pool',

    createEntity = 'Create %s',
    createEntityDescription = 'Create a new entity',
    createSystem_create = 'Create',
    createSystem_confirm = 'Confirm',
    createSystem_cancel = 'Cancel',
    entityModel = 'Enter the entity model',

    lineSelectEntity = 'Activate Entity Line',
    lineSelectEntityDescription = 'Activate line on selected entity',
    radiusListEntities = '%s List Radius',
    radiusListPropsDescription = 'Set here what radius you want to get entities from. Leave 0 for undefined',

    refreshList = '~y~Reload List',
    refreshListDescription = 'Use this option to reload the prop list',
    refreshListNotify = '~g~Prop list reloaded successfully!',

    entityInfo = 'Entity information',
    entityInfoDescription = 'View detailed entity information',

    pedDead = 'Dead',
    pedDeadDescription = 'Set ped dead',

    freezeEntity = 'Freeze Entity',
    freezeEntityDescription = 'Use this function to freeze the entity',
    
    moveEntity = 'Move Entity',
    moveEntityDescription = 'Use this function to move the entity',

    deleteEntity = 'Delete Entity',
    deleteEntityDescription = 'Use this function to delete the entity (only objects created by script)',

    notifyCopyText = 'Text copied to clipboard',
    enterCopyText = 'Click enter to copy the value to the clipboard',

    propInfoList = {
        id = '~b~Entity ID: ~r~',
        modelHash = '~b~Model Hash: ~r~',
        modelName = '~b~Model Name: ~r~',
        coords = '~b~Coordinates: ~r~',
        heading = '~b~Heading: ~r~',
        rotation = '~b~Rotation: ~r~',
        isNetworked = '~b~Networked: ~r~',
        isNetworkedYes = 'Yes',
        isNetworkedNo = 'No',
        plate = '~b~Vehicle Plate: ~r~',
        entityOwnerSource = '~b~Owner Source: ~r~',
        entityNetID = '~b~Entity Net ID: ~r~',
    }

}
