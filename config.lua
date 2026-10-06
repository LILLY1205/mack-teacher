Config = {}

-- Debug Settings
Config.Debug = true

-- Job Settings
Config.TeacherJob = 'teacher'

-- Discord Webhook Settings
Config.Webhook = {
    Enabled = true,
    ClockInOut = 'https://discord.com/api/webhooks/1478471450213089373/RzXRbfhPUeLcuVvOy06IGtXbfcQj8w9Ne9F5Lh6eoQGNkTHVVDORV83CIkdeQj3ZIbTC', -- Paste your Discord webhook URL here
}

-- ============================================================================
-- SCHOOL LOCATION SETTINGS
-- ============================================================================

-- The teacher's desk location (ox_target will attach to p_desk04x props near here)
Config.School = {
    name = 'Valentine School',
    deskCoords = vector3(-232.48, 784.15, 118.43), -- CHANGE to your desk location
    blipCoords = vector3(-232.48, 784.15, 118.43), -- Blip location on map
}

-- Prop models
Config.DeskModel = 'p_desk04x'
Config.StoolModel = 'p_stool02x'

-- Stool locations where students can sit (CHANGE these to your stool positions)
Config.StoolLocations = {
    { coords = vector3(-230.50, 783.50, 118.43), heading = 180.0 },
    { coords = vector3(-231.50, 783.50, 118.43), heading = 180.0 },
    { coords = vector3(-232.50, 783.50, 118.43), heading = 180.0 },
    { coords = vector3(-233.50, 783.50, 118.43), heading = 180.0 },
    { coords = vector3(-230.50, 782.00, 118.43), heading = 180.0 },
    { coords = vector3(-231.50, 782.00, 118.43), heading = 180.0 },
}

-- ============================================================================
-- CLASS SETTINGS
-- ============================================================================

Config.ClassDuration = 100000 -- Duration of reading in ms (2 minutes)
Config.ClassCooldown = 120   -- Cooldown between classes in seconds

-- XP Settings (awarded via mack-xplevels-v3)
Config.XP = {
    TeacherAmount = 30,  -- XP the teacher earns per class
    StudentAmount = 20,  -- XP each student earns per class
}

-- Reading Animation (applied to seated students when class starts)
Config.ReadingAnim = {
    dict = 'amb_rest_sit@prop_human_seat_chair@read@book@male_a@idle_b',
    name = 'idle_d_book',
}

-- ============================================================================
-- BOOK CONTENT - SILLY WILD WEST WAYS YOU COULD DIE
-- ============================================================================

Config.WaysToDie = {
    "A cowboy in Dodge City, 1878, met his end when he tried to quick-draw against his own reflection in a saloon mirror. The ricochet was fatal.",
    "One unfortunate prospector in Nevada died after his mule kicked a stick of dynamite he had carelessly left on the ground. The mule survived.",
    "A rancher near Tombstone passed away after he fell asleep in the desert sun using a rattlesnake as what he thought was a coiled rope pillow.",
    "In 1882, a bartender in Deadwood choked to death on a gold nugget he was trying to bite-test for a customer. The nugget turned out to be brass.",
    "A trail cook in Texas was trampled by his own cattle stampede, caused by his terrible singing voice that spooked the herd every single night.",
    "One bank robber in Kansas died when the vault door he dynamited flew off its hinges and landed squarely on him. His partner collected no money.",
    "A frontier dentist in Colorado pulled his own tooth while drunk on whiskey, then bled out because nobody in town knew how to help a dentist.",
    "A man in Wyoming bet he could ride a longhorn bull through the main street. He made it exactly twelve feet before meeting his maker.",
    "A gambler in Abilene died of shock when he actually drew a Royal Flush for the first time. His heart simply gave out from the excitement.",
    "One miner in California died when his claim collapsed after he removed the only support beam to use as firewood on a cold night.",
    "A cowpoke near El Paso tried to lasso a tornado for a dare. His hat was found three counties away. The rest of him was never found.",
    "A blacksmith died when he sneezed while hammering a horseshoe. The red-hot iron flew up and landed in the water trough, which exploded into steam.",
    "A snake oil salesman in Missouri actually drank his own product to prove it worked. Turns out, turpentine and laudanum is not medicine.",
    "One outlaw died trying to rob a train that turned out to be carrying an entire regiment of cavalry soldiers returning from deployment.",
    "A farmer in Oklahoma was killed by a flying cow during a tornado. Witnesses said the cow looked equally surprised.",
    "A prospector celebrated finding gold by firing his pistol in the air inside a mine. The cave-in took three days to dig out. He did not survive.",
    "A buffalo hunter was sat on by a buffalo he thought was dead. It was merely napping. He was merely crushed.",
    "One unfortunate soul in Montana tried to ford a river on horseback while wearing a full suit of armor he bought from a traveling merchant.",
    "A telegraph operator died of fright when he received the first message ever sent to his remote station. He thought the machine was possessed.",
    "A stagecoach driver in Arizona died of thirst after getting lost. His cargo? Two hundred barrels of fresh water being delivered to a nearby town.",
    "A deputy in Wichita accidentally shot himself while showing off his fancy gun-twirling skills to impress a lady at the general store.",
    "One man died trying to break a wild horse by sitting on it backwards, reasoning the horse would not expect such a bold strategy.",
    "A barber in Virginia City cut his own throat while shaving, distracted by gossip about a gold strike. The gold strike was a rumor.",
    "A fur trapper died after a beaver he was trapping bit through his canoe, sinking him in a freezing river. The beaver watched from the bank.",
    "A piano player in a saloon was crushed when a brawl knocked the upstairs balcony loose. He was still playing when it came down.",
    "One cowboy died from eating a cactus on a bet. His friends told him it was a prickly pear. It was a barrel cactus. Full of needles.",
    "A gold panner drowned in six inches of creek water after slipping on a gold nugget. The nugget was worth three dollars.",
    "A frontier preacher was struck by lightning while declaring himself chosen by God during a thunderstorm sermon on a hilltop.",
    "A horse thief was killed when the horse he stole turned out to be a retired cavalry horse that obeyed the command 'charge' from a passing soldier.",
    "One man in Nevada tried to use nitroglycerin to clear a tree stump. The stump survived. The man, his barn, and his chicken coop did not.",
}

-- ============================================================================
-- BOOK CONTENT - SILLY FRONTIER FACTS
-- ============================================================================

Config.SillyFacts = {
    "Cowboys rarely actually had gunfights at high noon. Most duels happened when both parties were too drunk to see straight, usually around 2 AM.",
    "The average cowboy spent more money on a good hat than on his horse. A Stetson could cost a full month's wages, and they guarded them with their lives.",
    "Tumbleweeds are not native to America. They came from Russia in contaminated flax seed shipments. The Wild West's most iconic plant is an immigrant.",
    "Camels were once used by the US Army in the American Southwest. When the Civil War started, they were released into the desert and roamed wild for decades.",
    "Frontier saloons often served drinks in communal cups that were never washed. Bartenders figured the whiskey killed any germs. They were mostly wrong.",
    "Cowboys called their boots 'coffins' because the pointed toes and high heels were terrible for walking but perfect for staying in stirrups.",
    "The average lifespan of a frontier town sheriff was about two years. Not because of gunfights, but because the pay was terrible and they quit.",
    "Bison were so numerous that trains would have to wait hours for herds to cross the tracks. Passengers would shoot them from the windows for sport.",
    "Dentists in the Old West often doubled as barbers, undertakers, and occasionally the town drunk. Dr. John Holliday was a dentist turned gunfighter.",
    "Cowboys would sometimes sleep with their horses for warmth. The horses tolerated it, but reportedly looked very judgmental about the whole arrangement.",
    "Wyatt Earp made more money as a real estate speculator than he ever did as a lawman. The gunfight at the O.K. Corral lasted only thirty seconds.",
    "The Pony Express, despite its legendary status, only operated for eighteen months before the telegraph put it out of business.",
    "Frontier towns had more lawyers per capita than modern cities. With all the land disputes, mining claims, and cattle feuds, legal help was in high demand.",
    "Cowboys could not actually spin their pistols like in the movies. The Colt Single Action Army was heavy and unwieldy, and spinning it was a good way to shoot your own foot.",
    "Beans were the most important food on the frontier. Cowboys ate them for breakfast, lunch, and dinner. The flatulence around a campfire was legendary.",
    "Outlaw gangs often had strict codes of conduct. The Dalton Gang had a rule against swearing in front of women and children, even during robberies.",
    "Native Americans taught settlers to put fish in the soil when planting corn. The settlers then overfished every nearby stream within a year.",
    "The first bank robbery in the Wild West was in 1866 in Liberty, Missouri. The robbers got away with sixty thousand dollars, which is millions in today's money.",
    "Frontier doctors often prescribed whiskey for everything from toothaches to broken legs. Patients rarely complained about the treatment.",
    "Cowboys used to judge the quality of a town by the number of piano players in its saloons. More pianos meant a more civilized settlement.",
    "The phrase 'the whole nine yards' may come from the length of a belt of ammunition. Running out mid-gunfight meant you literally gave it the whole nine yards.",
    "Sagebrush was used as toilet paper on the frontier. It was plentiful but scratchy. The Sears catalog was considered a luxury alternative.",
    "Wild Bill Hickok was killed while holding a pair of aces and a pair of eights, forever known as the 'Dead Man's Hand.' He was shot from behind by a coward.",
    "Frontier women were tougher than most cowboys. Calamity Jane could outshoot, outdrink, and outswear any man in Deadwood, and she was proud of it.",
    "Horses in the Old West were so valuable that stealing one was punishable by hanging. A good horse was worth more than a year's wages.",
    "The average cowboy made about a dollar a day, roughly thirty dollars a month. Room and board were included, which usually meant a bedroll and beans.",
    "Rattlesnake bites were treated by cutting the wound and sucking out the venom. This almost never worked and often gave the helper an infected mouth.",
    "Frontier saloons rarely had glass windows because glass had to be shipped from the East and cost a fortune. Most used oiled paper or nothing at all.",
    "The Wells Fargo stagecoach was robbed so often that the company hired shotgun riders, which is where the phrase 'riding shotgun' comes from.",
    "Cowboys would go months without bathing. When they finally did wash, it was usually in a river, and they used sand as soap. It was not very effective.",
}

-- ============================================================================
-- BOOK HEADLINES / TITLES
-- ============================================================================

Config.BookTitles = {
    waysToDie = {
        "Peculiar Perils of the Frontier",
        "Odd Ways to Meet Your Maker",
        "How NOT to Survive the West",
        "The Unluckiest Souls Out West",
        "Death by Misadventure",
        "Frontier Follies: Fatal Edition",
        "Ways the West Won... Against You",
        "The Darwin Awards: 1800s Edition",
        "When the West Bites Back",
        "Legends of Legendary Stupidity",
    },
    sillyFacts = {
        "Curious Facts of the Frontier",
        "Things They Never Taught You",
        "The Stranger Side of the West",
        "Believe It or Don't!",
        "Frontier Truths and Tall Tales",
        "The Wild West Almanac",
        "Peculiarities of Pioneer Life",
        "Strange But True: Western Edition",
        "Facts That'll Make You Spit Coffee",
        "A Schoolbook of Frontier Wisdom",
    },
}
