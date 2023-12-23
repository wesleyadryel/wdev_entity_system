# Wdev Entity System


This project is a standalone interactive menu for FIVEM designed to control nearby entities. The menu provides users with information about vehicles, peds, and objects, enabling actions such as movement, deletion, and other interactions on these entities. Users can also create new entities through the menu.
The script operates with some limitations when there is more than one player on the server. However, it strives to request entity control when necessary.

Includes several exports, both for the client and server, allowing you to invoke the menu from within other scripts.

![image](https://github.com/wesleyadryel/wdev_entity_system/assets/44826120/7a96e3bc-d3d8-4ce2-bc79-af845e4a5fba)

![image](https://github.com/wesleyadryel/wdev_entity_system/assets/44826120/857a2ce3-9cbe-4c23-9f11-c190a45a9736)


# Exports
## Client Side:
```
-- =============================================================================
-- toggleMenu:
-- PARAMETERS:  state : BOOLEAN
-- exports[wdev_entity_system]:toggleMenu(state)
-- DESCRIPTION:  Enables/Disables Props System Menu
-- =============================================================================
```

## Server Side:
```
-- =============================================================================
-- toggleMenu:
-- PARAMETERS:  source: NUMBER, state : BOOLEAN
-- exports[wdev_entity_system]:toggleMenu(source, state)
-- DESCRIPTION:  Enables/Disables Props System Menu
-- =============================================================================
```

### Configuration
In the configuration file, you have the option to define an "ace" permission to open the menu or set it to false to disable it. You can customize it according to the permission system of your framework.
Feel free to explore and integrate these exports into your scripts to invoke the menu functionality from elsewhere in your project.
For any issues or suggestions, please refer to the Issues section of this repository.

# RELEASES
Check out the releases at [Releases](https://github.com/wesleyadryel/wdev_entity_system/releases). Download the FIVEM RESOURCE if you only need production files, or grab the source code for development files.

## DEV MODE
Go to the project dev folder
```cd web/dev```

Install dependencies
```yarn install``` or ```npm install```

Launch developer mode
```yarn dev``` or ```npm run dev```

Access developer mode in the browser
```http://localhost:5173```

Build the project with the command
```yarn build``` or ```npm run build```

