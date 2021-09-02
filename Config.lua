Config = {
    Locker = {X= -144.06, Y= -576.14, Z= 32.42}, -- Position of the locker
    Uniforms = { -- Work uniforms (Make {} for none)
        Male= {
            tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 50,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 33,
			pants_1 = 4,   pants_2 = 0,
			shoes_1 = 25,   shoes_2 = 0,
            helmet_1 = -1,  helmet_2 = 0,
            mask_1 = 35,     emask_2 = 0,
			chain_1 = 0,    chain_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			bags_1 = 44
        },
        FeMale= {
            tshirt_1 = 14,  tshirt_2 = 0,
			torso_1 = 43,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 18,
			pants_1 = 27,   pants_2 = 0,
			shoes_1 = 25,   shoes_2 = 0,
            helmet_1 = -1,  helmet_2 = 0,
            mask_1 = 35,     emask_2 = 0,
			chain_1 = 0,    chain_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			bags_1 = 44
        }
    },
		

    Garage = {X= -143.0, Y= -583.20, Z= 32.42}, -- Position of the garage
    VehicleSpawn = {X= -139.25, Y= -586.48, Z= 32.42, Heading= 66.80}, -- Position where the vehicle will spawn
    VehicleDelete = {X= -139.68, Y= -590.69, Z= 32.42}, -- Position where the vehicle can despawn

    Vehicles = { -- All vehicles that can be spawned from the menu
        {Name= "Burrito", SpawnName= "burrito3"}
    },
    LicensePlate = "Thief", -- Make "" for random text

    BlipName = "Burglar", -- Name of the marker on the map
    JobBlipName = "Burglary Job", -- Name of the marker on the map

    MoneyType = true, -- True= Cash | False= Bank
    MoneyAmount = math.random(800, 2500), -- Money you get for completing 1 job

    Translation = "EN", -- Translation to use

    Jobs = { -- Positions of available jobs
        {X= -1165.13, Y= -1566.85, Z= 4.45, H= 122.24},
        {X= -1152.70, Y= -1517.34, Z= 10.63, H= 39.28},
		{X= -993.02, Y= -519.20, Z= 37.51, H= 123.13},
		{X= -1316.80, Y= -817.17, Z= 17.10, H= 45.37},
        {X= -675.24, Y= -881.06, Z= 24.48, H= 279.65},
		{X= 116.71, Y= -761.06, Z= 45.75, H= 70.53},
		{X= -1170.28, Y= -238.16, Z= 437.94, H= 224.43}
    },

    TranslationList = { -- List of all translation which you car choose
        ["EN"] = {
            ["LOCKER_HELP"] = "Press ~INPUT_CONTEXT~ to open the locker!",
            ["LOCKER_MENU"] = "Locker Menu",
            ["WORK_CLOTHES"] = "Work Clothes",
            ["NORMAL_CLOTHES"] = "Normal Clothes",

            ["GARAGE_HELP"] = "Press ~INPUT_CONTEXT~ to open the garage!",
            ["GARAGE_MENU"] = "Garage Menu",
            ["GARAGE_PROBLEM"] = "~r~ Something went wrong while spawning the vehicle. (Stopped to prevent crash!)",
            
            ["DELETE_HELP"] = "Press ~INPUT_CONTEXT~ to delete your vehicle!",

            ["MENU_HELP"] = "Press ~g~PgUp ~w~to open your menu!",
            ["MENU_MENU"] = "Menu",
            ["MENU_NEW"] = "Get new job",
            ["MENU_CREATED"] = "~g~ Succesfully created a new job!",
            ["MENU_CANCEL"] = "Cancel current job",
            ["MENU_CANCELED"] = "~g~ Succesfully canceled your job!",
            ["MENU_ALREADY"] = "~r~ You are already doing a job! You first need to cancel it.",
            ["MENU_NONE"] = "~r~ You have no active job!",
			["NOT_NIGHT"] = "~r~ You can only burgle from 7PM to 5AM!",

            ["JOB_HELP"] = "Press ~INPUT_CONTEXT~ to take a look!",
            ["JOB_DONE"] = "~g~ Succesfully burgled the safe.",
			["JOB_FAIL"] = "~g~ You Failed to open the safe, try again!"
        }
    }
}