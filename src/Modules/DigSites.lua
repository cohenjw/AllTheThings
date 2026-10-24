local _, app = ...

-- Shows the collectables of an archaeology race when hovering one of its digsites on the world map.

-- Digsites only exist where the Research APIs do.
if not C_ResearchInfo then return end

-- Global locals
local GameTooltip, hooksecurefunc, setmetatable, InCombatLockdown
	= GameTooltip, hooksecurefunc, setmetatable, InCombatLockdown

-- Archaeology fragment currencies, the same IDs as the ARCH_CURRENCY_* constants used by the parser
local ARCH_CURRENCY_ARAKKOA = 829
local ARCH_CURRENCY_DEMONIC = 1174
local ARCH_CURRENCY_DRAENEI = 398
local ARCH_CURRENCY_DRAENORCLANS = 821
local ARCH_CURRENCY_DRUST = 1535
local ARCH_CURRENCY_DWARF = 384
local ARCH_CURRENCY_FOSSIL = 393
local ARCH_CURRENCY_HIGHBORNE = 1172
local ARCH_CURRENCY_HIGHMOUNTAIN = 1173
local ARCH_CURRENCY_MANTID = 754
local ARCH_CURRENCY_MOGU = 677
local ARCH_CURRENCY_NERUBIAN = 400
local ARCH_CURRENCY_NIGHTELF = 394
local ARCH_CURRENCY_OGRE = 828
local ARCH_CURRENCY_ORC = 397
local ARCH_CURRENCY_PANDAREN = 676
local ARCH_CURRENCY_TOLVIR = 401
local ARCH_CURRENCY_TROLL = 385
local ARCH_CURRENCY_VRYKUL = 399
local ARCH_CURRENCY_ZANDALARI = 1534

-- ResearchSite ID => the archaeology currency of the race which is dug up there.
-- The client does not expose the race of a digsite until the player has dug there, so it is listed here.
-- ResearchSite IDs are from the ResearchSite DB2, races are from the digsite lists of each race.
local DigSiteRaces = {
	-- Dwarf
	[9] = ARCH_CURRENCY_DWARF,	-- Ironband's Excavation Site
	[10] = ARCH_CURRENCY_DWARF,	-- Ironbeard's Tomb
	[12] = ARCH_CURRENCY_DWARF,	-- Whelgar's Excavation Site
	[15] = ARCH_CURRENCY_DWARF,	-- Thoradin's Wall
	[19] = ARCH_CURRENCY_DWARF,	-- Thandol Span
	[20] = ARCH_CURRENCY_DWARF,	-- Dun Garok Digsite
	[22] = ARCH_CURRENCY_DWARF,	-- Aerie Peak Digsite
	[144] = ARCH_CURRENCY_DWARF,	-- Hammertoe's Digsite
	[146] = ARCH_CURRENCY_DWARF,	-- Tomb of the Watchers Digsite
	[150] = ARCH_CURRENCY_DWARF,	-- Uldaman Entrance Digsite
	[183] = ARCH_CURRENCY_DWARF,	-- Bael Modan Digsite
	[207] = ARCH_CURRENCY_DWARF,	-- Grimsilt Digsite
	[209] = ARCH_CURRENCY_DWARF,	-- Pyrox Flats Digsite
	[211] = ARCH_CURRENCY_DWARF,	-- Western Ruins of Thaurissan
	[213] = ARCH_CURRENCY_DWARF,	-- Eastern Ruins of Thaurissan
	[477] = ARCH_CURRENCY_DWARF,	-- Dunwald Ruins Digsite
	[479] = ARCH_CURRENCY_DWARF,	-- Thundermar Ruins Digsite
	[481] = ARCH_CURRENCY_DWARF,	-- Humboldt Conflagration Digsite

	-- Fossil
	[13] = ARCH_CURRENCY_FOSSIL,	-- Greenwarden's Fossil Bank
	[21] = ARCH_CURRENCY_FOSSIL,	-- Southshore Fossil Field
	[154] = ARCH_CURRENCY_FOSSIL,	-- Misty Reed Fossil Bank
	[165] = ARCH_CURRENCY_FOSSIL,	-- Vul'Gol Fossil Bank
	[181] = ARCH_CURRENCY_FOSSIL,	-- Unearthed Grounds
	[189] = ARCH_CURRENCY_FOSSIL,	-- Lakeridge Highway Fossil Bank
	[195] = ARCH_CURRENCY_FOSSIL,	-- Valley of Bones
	[199] = ARCH_CURRENCY_FOSSIL,	-- Kodo Graveyard
	[203] = ARCH_CURRENCY_FOSSIL,	-- Red Reaches Fossil Bank
	[205] = ARCH_CURRENCY_FOSSIL,	-- Dreadmaul Fossil Field
	[215] = ARCH_CURRENCY_FOSSIL,	-- Terror Wing Fossil Field
	[221] = ARCH_CURRENCY_FOSSIL,	-- Infectis Scar Fossil Field
	[237] = ARCH_CURRENCY_FOSSIL,	-- Savage Coast Raptor Fields
	[247] = ARCH_CURRENCY_FOSSIL,	-- Felstone Fossil Field
	[249] = ARCH_CURRENCY_FOSSIL,	-- Northridge Fossil Field
	[251] = ARCH_CURRENCY_FOSSIL,	-- Andorhal Fossil Bank
	[259] = ARCH_CURRENCY_FOSSIL,	-- Wyrmbog Fossil Field
	[261] = ARCH_CURRENCY_FOSSIL,	-- Quagmire Fossil Field
	[309] = ARCH_CURRENCY_FOSSIL,	-- Fields of Blood Fossil Bank
	[323] = ARCH_CURRENCY_FOSSIL,	-- Dunemaul Fossil Ridge
	[325] = ARCH_CURRENCY_FOSSIL,	-- Abyssal Sands Fossil Ridge
	[327] = ARCH_CURRENCY_FOSSIL,	-- Lower Lakkari Tar Pits
	[329] = ARCH_CURRENCY_FOSSIL,	-- Upper Lakkari Tar Pits
	[331] = ARCH_CURRENCY_FOSSIL,	-- Terror Run Fossil Field
	[333] = ARCH_CURRENCY_FOSSIL,	-- Screaming Reaches Fossil Field
	[335] = ARCH_CURRENCY_FOSSIL,	-- Marshlands Fossil Bank

	-- Night Elf
	[163] = ARCH_CURRENCY_NIGHTELF,	-- Twilight Grove Digsite
	[167] = ARCH_CURRENCY_NIGHTELF,	-- Nazj'vel Digsite
	[169] = ARCH_CURRENCY_NIGHTELF,	-- Zoram Strand Digsite
	[171] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Ordil'Aran
	[173] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Stardust
	[175] = ARCH_CURRENCY_NIGHTELF,	-- Forest Song Digsite
	[177] = ARCH_CURRENCY_NIGHTELF,	-- Stonetalon Peak
	[179] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Eldre'Thar
	[185] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Eldarath
	[187] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Arkkoran
	[191] = ARCH_CURRENCY_NIGHTELF,	-- Slitherblade Shore Digsite
	[193] = ARCH_CURRENCY_NIGHTELF,	-- Ethel Rethor Digsite
	[197] = ARCH_CURRENCY_NIGHTELF,	-- Mannoroc Coven Digsite
	[201] = ARCH_CURRENCY_NIGHTELF,	-- Sargeron Digsite
	[219] = ARCH_CURRENCY_NIGHTELF,	-- Quel'Lithien Lodge Digsite
	[279] = ARCH_CURRENCY_NIGHTELF,	-- Dire Maul Digsite
	[281] = ARCH_CURRENCY_NIGHTELF,	-- Broken Commons Digsite
	[283] = ARCH_CURRENCY_NIGHTELF,	-- Ravenwind Digsite
	[285] = ARCH_CURRENCY_NIGHTELF,	-- Oneiros Digsite
	[287] = ARCH_CURRENCY_NIGHTELF,	-- Solarsal Digsite
	[289] = ARCH_CURRENCY_NIGHTELF,	-- Darkmist Digsite
	[291] = ARCH_CURRENCY_NIGHTELF,	-- South Isildien Digsite
	[293] = ARCH_CURRENCY_NIGHTELF,	-- North Isildien Digsite
	[295] = ARCH_CURRENCY_NIGHTELF,	-- Constellas Digsite
	[297] = ARCH_CURRENCY_NIGHTELF,	-- Morlos'Aran Digsite
	[299] = ARCH_CURRENCY_NIGHTELF,	-- Jaedenar Digsite
	[301] = ARCH_CURRENCY_NIGHTELF,	-- Ironwood Digsite
	[303] = ARCH_CURRENCY_NIGHTELF,	-- Lake Kel'Theril Digsite
	[305] = ARCH_CURRENCY_NIGHTELF,	-- Owl Wing Thicket Digsite
	[307] = ARCH_CURRENCY_NIGHTELF,	-- Frostwhisper Gorge Digsite
	[313] = ARCH_CURRENCY_NIGHTELF,	-- Nightmare Scar Digsite
	[337] = ARCH_CURRENCY_NIGHTELF,	-- Southwind Village Digsite
	[417] = ARCH_CURRENCY_NIGHTELF,	-- Moonrest Gardens Digsite
	[423] = ARCH_CURRENCY_NIGHTELF,	-- Riplash Ruins Digsite
	[425] = ARCH_CURRENCY_NIGHTELF,	-- Violet Stand Digsite
	[427] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Shandaral Digsite
	[461] = ARCH_CURRENCY_NIGHTELF,	-- Ruins of Lar'donir Digsite
	[463] = ARCH_CURRENCY_NIGHTELF,	-- Shrine of Goldrinn Digsite
	[465] = ARCH_CURRENCY_NIGHTELF,	-- Grove of Aessina Digsite
	[467] = ARCH_CURRENCY_NIGHTELF,	-- Sanctuary of Malorne Digsite
	[469] = ARCH_CURRENCY_NIGHTELF,	-- Scorched Plain Digsite

	-- Troll
	[18] = ARCH_CURRENCY_TROLL,	-- Witherbark Digsite
	[23] = ARCH_CURRENCY_TROLL,	-- Shadra'Alor Digsite
	[24] = ARCH_CURRENCY_TROLL,	-- Altar of Zul Digsite
	[25] = ARCH_CURRENCY_TROLL,	-- Jintha'Alor Lower City Digsite
	[26] = ARCH_CURRENCY_TROLL,	-- Jintha'Alor Upper City Digsite
	[27] = ARCH_CURRENCY_TROLL,	-- Agol'watha Digsite
	[152] = ARCH_CURRENCY_TROLL,	-- Sunken Temple Digsite
	[217] = ARCH_CURRENCY_TROLL,	-- Zul'Mashar Digsite
	[223] = ARCH_CURRENCY_TROLL,	-- Eastern Zul'Kunda Digsite
	[225] = ARCH_CURRENCY_TROLL,	-- Western Zul'Kunda Digsite
	[227] = ARCH_CURRENCY_TROLL,	-- Bal'lal Ruins Digsite
	[229] = ARCH_CURRENCY_TROLL,	-- Balia'mah Digsite
	[231] = ARCH_CURRENCY_TROLL,	-- Ziata'jai Digsite
	[233] = ARCH_CURRENCY_TROLL,	-- Eastern Zul'Mamwe Digsite
	[235] = ARCH_CURRENCY_TROLL,	-- Western Zul'Mamwe Digsite
	[239] = ARCH_CURRENCY_TROLL,	-- Ruins of Aboraz
	[241] = ARCH_CURRENCY_TROLL,	-- Ruins of Jubuwal
	[243] = ARCH_CURRENCY_TROLL,	-- Gurubashi Arena Digsite
	[245] = ARCH_CURRENCY_TROLL,	-- Nek'mani Wellspring Digsite
	[315] = ARCH_CURRENCY_TROLL,	-- Zul'Farrak Digsite
	[317] = ARCH_CURRENCY_TROLL,	-- Broken Pillar Digsite
	[319] = ARCH_CURRENCY_TROLL,	-- Eastmoon Ruins Digsite
	[321] = ARCH_CURRENCY_TROLL,	-- Southmoon Ruins Digsite
	[429] = ARCH_CURRENCY_TROLL,	-- Altar of Sseratus Digsite
	[431] = ARCH_CURRENCY_TROLL,	-- Zim'Rhuk Digsite
	[433] = ARCH_CURRENCY_TROLL,	-- Zol'Heb Digsite
	[435] = ARCH_CURRENCY_TROLL,	-- Altar of Quetz'lun Digsite
	[443] = ARCH_CURRENCY_TROLL,	-- Drakil'Jin Ruins Digsite

	-- Draenei
	[347] = ARCH_CURRENCY_DRAENEI,	-- Sha'naar Digsite
	[349] = ARCH_CURRENCY_DRAENEI,	-- Boha'mu Ruins Digsite
	[351] = ARCH_CURRENCY_DRAENEI,	-- Twin Spire Ruins Digsite
	[353] = ARCH_CURRENCY_DRAENEI,	-- Ruins of Enkaat Digsite
	[355] = ARCH_CURRENCY_DRAENEI,	-- Arklon Ruins Digsite
	[357] = ARCH_CURRENCY_DRAENEI,	-- Ruins of Farahlon Digsite
	[369] = ARCH_CURRENCY_DRAENEI,	-- Halaa Digsite
	[373] = ARCH_CURRENCY_DRAENEI,	-- Tuurem Digsite
	[379] = ARCH_CURRENCY_DRAENEI,	-- Bone Wastes Digsite
	[381] = ARCH_CURRENCY_DRAENEI,	-- East Auchindoun Digsite
	[383] = ARCH_CURRENCY_DRAENEI,	-- West Auchindoun Digsite
	[385] = ARCH_CURRENCY_DRAENEI,	-- Illidari Point Digsite
	[387] = ARCH_CURRENCY_DRAENEI,	-- Coilskar Point Digsite
	[391] = ARCH_CURRENCY_DRAENEI,	-- Ruins of Baa'ri Digsite
	[393] = ARCH_CURRENCY_DRAENEI,	-- Eclipse Point Digsite

	-- Orc
	[339] = ARCH_CURRENCY_ORC,	-- Gor'gaz Outpost Digsite
	[341] = ARCH_CURRENCY_ORC,	-- Zeth'Gor Digsite
	[343] = ARCH_CURRENCY_ORC,	-- Hellfire Basin Digsite
	[345] = ARCH_CURRENCY_ORC,	-- Hellfire Citadel Digsite
	[359] = ARCH_CURRENCY_ORC,	-- Ancestral Grounds Digsite
	[363] = ARCH_CURRENCY_ORC,	-- Sunspring Post Digsite
	[365] = ARCH_CURRENCY_ORC,	-- Laughing Skull Digsite
	[367] = ARCH_CURRENCY_ORC,	-- Burning Blade Digsite
	[371] = ARCH_CURRENCY_ORC,	-- Grangol'var Village Digsite
	[375] = ARCH_CURRENCY_ORC,	-- Bleeding Hollow Ruins Digsite
	[377] = ARCH_CURRENCY_ORC,	-- Bonechewer Ruins Digsite
	[395] = ARCH_CURRENCY_ORC,	-- Warden's Cage Digsite
	[399] = ARCH_CURRENCY_ORC,	-- Dragonmaw Fortress

	-- Nerubian
	[415] = ARCH_CURRENCY_NERUBIAN,	-- Pit of Narjun Digsite
	[419] = ARCH_CURRENCY_NERUBIAN,	-- En'kilah Digsite
	[421] = ARCH_CURRENCY_NERUBIAN,	-- Kolramas Digsite
	[437] = ARCH_CURRENCY_NERUBIAN,	-- Talramas Digsite
	[451] = ARCH_CURRENCY_NERUBIAN,	-- Scourgeholme Digsite
	[587] = ARCH_CURRENCY_NERUBIAN,	-- Pit of Fiends Digsite
	[589] = ARCH_CURRENCY_NERUBIAN,	-- Sands of Nasam
	[615] = ARCH_CURRENCY_NERUBIAN,	-- Terrorweb Tunnel Digsite
	[617] = ARCH_CURRENCY_NERUBIAN,	-- Plaguewood Digsite

	-- Vrykul
	[401] = ARCH_CURRENCY_VRYKUL,	-- Skorn Digsite
	[403] = ARCH_CURRENCY_VRYKUL,	-- Halgrind Digsite
	[405] = ARCH_CURRENCY_VRYKUL,	-- Wyrmskull Digsite
	[407] = ARCH_CURRENCY_VRYKUL,	-- Shield Hill Digsite
	[409] = ARCH_CURRENCY_VRYKUL,	-- Baleheim Digsite
	[411] = ARCH_CURRENCY_VRYKUL,	-- Nifflevar Digsite
	[413] = ARCH_CURRENCY_VRYKUL,	-- Gjalerbron Digsite
	[439] = ARCH_CURRENCY_VRYKUL,	-- Voldrune Digsite
	[445] = ARCH_CURRENCY_VRYKUL,	-- Brunnhildar Village Digsite
	[447] = ARCH_CURRENCY_VRYKUL,	-- Sifreldar Village Digsite
	[449] = ARCH_CURRENCY_VRYKUL,	-- Valkyrion Digsite
	[455] = ARCH_CURRENCY_VRYKUL,	-- Ymirheim Digsite
	[457] = ARCH_CURRENCY_VRYKUL,	-- Jotunheim Digsite
	[459] = ARCH_CURRENCY_VRYKUL,	-- Njorndar Village Digsite

	-- Tol'vir
	[485] = ARCH_CURRENCY_TOLVIR,	-- Khartut's Tomb Digsite
	[487] = ARCH_CURRENCY_TOLVIR,	-- Tombs of the Precursors Digsite
	[489] = ARCH_CURRENCY_TOLVIR,	-- Steps of Fate Digsite
	[491] = ARCH_CURRENCY_TOLVIR,	-- Neferset Digsite
	[493] = ARCH_CURRENCY_TOLVIR,	-- Orsis Digsite
	[495] = ARCH_CURRENCY_TOLVIR,	-- Ruins of Ammon Digsite
	[497] = ARCH_CURRENCY_TOLVIR,	-- Ruins of Khintaset Digsite
	[499] = ARCH_CURRENCY_TOLVIR,	-- Temple of Uldum Digsite
	[501] = ARCH_CURRENCY_TOLVIR,	-- Ruins of Ahmtul Digsite
	[570] = ARCH_CURRENCY_TOLVIR,	-- River Delta Digsite
	[572] = ARCH_CURRENCY_TOLVIR,	-- Cursed Landing Digsite
	[574] = ARCH_CURRENCY_TOLVIR,	-- Keset Pass Digsite
	[576] = ARCH_CURRENCY_TOLVIR,	-- Akhenet Fields Digsite
	[578] = ARCH_CURRENCY_TOLVIR,	-- Obelisk of the Stars Digsite
	[581] = ARCH_CURRENCY_TOLVIR,	-- Sahket Wastes Digsite
	[583] = ARCH_CURRENCY_TOLVIR,	-- Schnottz's Landing

	-- Mantid
	[1352] = ARCH_CURRENCY_MANTID,	-- Writhingwood Digsite
	[1463] = ARCH_CURRENCY_MANTID,	-- Kor'vess Digsite
	[1465] = ARCH_CURRENCY_MANTID,	-- Sra'thik Swarmdock Digsite
	[1467] = ARCH_CURRENCY_MANTID,	-- West Sra'vess Digsite
	[1469] = ARCH_CURRENCY_MANTID,	-- The Feeding Pits Digsite
	[1471] = ARCH_CURRENCY_MANTID,	-- Kzzok Warcamp Digsite
	[1473] = ARCH_CURRENCY_MANTID,	-- East Sra'vess Digsite
	[1475] = ARCH_CURRENCY_MANTID,	-- The Underbough Digsite
	[1479] = ARCH_CURRENCY_MANTID,	-- Ikz'ka Ridge Digsite
	[1481] = ARCH_CURRENCY_MANTID,	-- Sik'vess Digsite
	[1483] = ARCH_CURRENCY_MANTID,	-- West Sik'vess Digsite
	[1485] = ARCH_CURRENCY_MANTID,	-- North Sik'vess Digsite
	[1487] = ARCH_CURRENCY_MANTID,	-- The Clutches of Shek'zeer Digsite
	[1489] = ARCH_CURRENCY_MANTID,	-- Kypari'ik Digsite
	[1493] = ARCH_CURRENCY_MANTID,	-- Venomous Ledge Digsite
	[1495] = ARCH_CURRENCY_MANTID,	-- Amber Quarry Digsite
	[1501] = ARCH_CURRENCY_MANTID,	-- Kypari'zar Digsite
	[1503] = ARCH_CURRENCY_MANTID,	-- Lake of Stars Digsite (race inferred: the wiki's Lake of Stars (north); north told from south by the datamined position, north has the larger X)
	[1507] = ARCH_CURRENCY_MANTID,	-- Kypari Vor Digsite

	-- Mogu
	[934] = ARCH_CURRENCY_MOGU,	-- Ruins of Gan Shi Digsite
	[941] = ARCH_CURRENCY_MOGU,	-- Thunderwood Digsite
	[955] = ARCH_CURRENCY_MOGU,	-- Singing Marshes Digsite
	[957] = ARCH_CURRENCY_MOGU,	-- North Great Wall Digsite
	[961] = ARCH_CURRENCY_MOGU,	-- South Great Wall Digsite
	[963] = ARCH_CURRENCY_MOGU,	-- Torjari Pit Digsite
	[967] = ARCH_CURRENCY_MOGU,	-- The Spring Road Digsite
	[981] = ARCH_CURRENCY_MOGU,	-- Fallsong Village Digsite
	[983] = ARCH_CURRENCY_MOGU,	-- Ruins of Korja Digsite
	[987] = ARCH_CURRENCY_MOGU,	-- Krasarang Wilds Digsite
	[989] = ARCH_CURRENCY_MOGU,	-- Lost Dynasty Digsite
	[1003] = ARCH_CURRENCY_MOGU,	-- Valley of Kings Digsite
	[1005] = ARCH_CURRENCY_MOGU,	-- Gate to Golden Valley Digsite
	[1007] = ARCH_CURRENCY_MOGU,	-- Snow Covered Hills Digsite
	[1009] = ARCH_CURRENCY_MOGU,	-- East Snow Covered Hills Digsite
	[1284] = ARCH_CURRENCY_MOGU,	-- Setting Sun Garrison Digsite
	[1294] = ARCH_CURRENCY_MOGU,	-- South Ruins of Guo-Lai Digsite
	[1300] = ARCH_CURRENCY_MOGU,	-- Tu Shen Digsite
	[1308] = ARCH_CURRENCY_MOGU,	-- West Ruins of Guo-Lai Digsite
	[1316] = ARCH_CURRENCY_MOGU,	-- Winterbough Digsite
	[1318] = ARCH_CURRENCY_MOGU,	-- Emperor's Approach Digsite
	[1322] = ARCH_CURRENCY_MOGU,	-- North Summer Fields Digsite
	[1326] = ARCH_CURRENCY_MOGU,	-- East Summer Fields Digsite
	[1338] = ARCH_CURRENCY_MOGU,	-- Fire Camp Osul Digsite
	[1340] = ARCH_CURRENCY_MOGU,	-- Hatred's Vice Digsite
	[1342] = ARCH_CURRENCY_MOGU,	-- Shanze'Dao Digsite
	[1346] = ARCH_CURRENCY_MOGU,	-- Lake of Stars Digsite (race inferred: the wiki's Lake of Stars (south); north told from south by the datamined position, north has the larger X)
	[1348] = ARCH_CURRENCY_MOGU,	-- Terrace of Gurthan Digsite
	[1356] = ARCH_CURRENCY_MOGU,	-- South Ruins of Dojan Digsite
	[1358] = ARCH_CURRENCY_MOGU,	-- North Ruins of Dojan Digsite
	[1491] = ARCH_CURRENCY_MOGU,	-- Zan'vess Digsite
	[1497] = ARCH_CURRENCY_MOGU,	-- The Briny Muck Digsite

	-- Pandaren
	[918] = ARCH_CURRENCY_PANDAREN,	-- Tiger's Wood Digsite (race inferred: spelling variant of the wiki's Tigers' Wood)
	[923] = ARCH_CURRENCY_PANDAREN,	-- Tian Digsite
	[928] = ARCH_CURRENCY_PANDAREN,	-- Shrine of the Dawn Digsite
	[936] = ARCH_CURRENCY_PANDAREN,	-- Emperor's Omen Digsite
	[938] = ARCH_CURRENCY_PANDAREN,	-- The Arboretum Digsite
	[971] = ARCH_CURRENCY_PANDAREN,	-- Paoquan Hollow Digsite
	[973] = ARCH_CURRENCY_PANDAREN,	-- North Fruited Fields Digsite
	[977] = ARCH_CURRENCY_PANDAREN,	-- South Fruited Fields Digsite
	[979] = ARCH_CURRENCY_PANDAREN,	-- Pools of Purity Digsite
	[995] = ARCH_CURRENCY_PANDAREN,	-- North Temple of the Red Crane Digsite
	[999] = ARCH_CURRENCY_PANDAREN,	-- Zhu Province Digsite
	[1011] = ARCH_CURRENCY_PANDAREN,	-- Remote Village Digsite
	[1015] = ARCH_CURRENCY_PANDAREN,	-- Destroyed Village Digsite
	[1017] = ARCH_CURRENCY_PANDAREN,	-- Old Village Digsite
	[1019] = ARCH_CURRENCY_PANDAREN,	-- Grumblepaw Ranch Digsite
	[1021] = ARCH_CURRENCY_PANDAREN,	-- Chow Farmstead Digsite
	[1023] = ARCH_CURRENCY_PANDAREN,	-- West Old Village Digsite
	[1025] = ARCH_CURRENCY_PANDAREN,	-- Small Gate Digsite
	[1029] = ARCH_CURRENCY_PANDAREN,	-- Kun-Lai Peak Digsite
	[1033] = ARCH_CURRENCY_PANDAREN,	-- Forest Heart Digsite
	[1035] = ARCH_CURRENCY_PANDAREN,	-- Gong of Hope Digsite
	[1037] = ARCH_CURRENCY_PANDAREN,	-- Great Bridge Digsite
	[1039] = ARCH_CURRENCY_PANDAREN,	-- Orchard Digsite
	[1043] = ARCH_CURRENCY_PANDAREN,	-- Jade Temple Grounds Digsite
	[1045] = ARCH_CURRENCY_PANDAREN,	-- South Orchard Digsite
	[1047] = ARCH_CURRENCY_PANDAREN,	-- Den of Sorrow Digsite
	[1049] = ARCH_CURRENCY_PANDAREN,	-- Shrine Meadow Digsite
	[1051] = ARCH_CURRENCY_PANDAREN,	-- Veridian Grove Digsite
	[1286] = ARCH_CURRENCY_PANDAREN,	-- Mistfall Village Digsite
	[1288] = ARCH_CURRENCY_PANDAREN,	-- Five Sisters Digsite
	[1292] = ARCH_CURRENCY_PANDAREN,	-- North Ruins of Guo-Lai Digsite
	[1332] = ARCH_CURRENCY_PANDAREN,	-- Sra'thik Digsite
	[1334] = ARCH_CURRENCY_PANDAREN,	-- Niuzao Temple Digsite

	-- Arakkoa
	[1752] = ARCH_CURRENCY_ARAKKOA,	-- Shimmering Moor Digsite
	[1758] = ARCH_CURRENCY_ARAKKOA,	-- Sethekk Hollow South Digsite
	[1760] = ARCH_CURRENCY_ARAKKOA,	-- Sethekk Hollow North Digsite
	[1762] = ARCH_CURRENCY_ARAKKOA,	-- Veil Akraz Digsite
	[1768] = ARCH_CURRENCY_ARAKKOA,	-- Pinchwhistle Point Digsite
	[1770] = ARCH_CURRENCY_ARAKKOA,	-- Bloodmane Valley Digsite
	[1778] = ARCH_CURRENCY_ARAKKOA,	-- Veil Shadar Digsite

	-- Draenor Clans
	[1681] = ARCH_CURRENCY_DRAENORCLANS,	-- Frozen Lake Digsite
	[1685] = ARCH_CURRENCY_DRAENORCLANS,	-- Daggermaw Flows Digsite
	[1687] = ARCH_CURRENCY_DRAENORCLANS,	-- Lashwind Cleft Digsite
	[1689] = ARCH_CURRENCY_DRAENORCLANS,	-- The Crackling Plains Digsite
	[1695] = ARCH_CURRENCY_DRAENORCLANS,	-- Stonefang Ridge Digsite
	[1732] = ARCH_CURRENCY_DRAENORCLANS,	-- Frostboar Drifts Digsite
	[1734] = ARCH_CURRENCY_DRAENORCLANS,	-- Icewind Drifts Digsite
	[1736] = ARCH_CURRENCY_DRAENORCLANS,	-- East Coldsnap Bluffs Digsite
	[1738] = ARCH_CURRENCY_DRAENORCLANS,	-- Coldsnap Bluffs Digsite
	[1742] = ARCH_CURRENCY_DRAENORCLANS,	-- Burial Fields Digsite
	[1744] = ARCH_CURRENCY_DRAENORCLANS,	-- Anguish Fortress Digsite
	[1746] = ARCH_CURRENCY_DRAENORCLANS,	-- Cursed Woods Digsite
	[1756] = ARCH_CURRENCY_DRAENORCLANS,	-- Gloomshade Digsite
	[1794] = ARCH_CURRENCY_DRAENORCLANS,	-- Razed Warsong Outpost Digsite
	[1800] = ARCH_CURRENCY_DRAENORCLANS,	-- Kag'ah Digsite
	[1802] = ARCH_CURRENCY_DRAENORCLANS,	-- Ancestral Grounds Digsite
	[1804] = ARCH_CURRENCY_DRAENORCLANS,	-- Ring of Trials Sludge Digsite
	[1806] = ARCH_CURRENCY_DRAENORCLANS,	-- Howling Plateau Digsite (race inferred: the fourth elemental plateau, with Burning, Rumbling and Drowning Plateau, all Draenor Clans)
	[1808] = ARCH_CURRENCY_DRAENORCLANS,	-- Rumbling Plateau Digsite
	[1810] = ARCH_CURRENCY_DRAENORCLANS,	-- Drowning Plateau Digsite
	[1812] = ARCH_CURRENCY_DRAENORCLANS,	-- Burning Plateau Digsite
	[1820] = ARCH_CURRENCY_DRAENORCLANS,	-- Deadgrin Ruins Digsite
	[1832] = ARCH_CURRENCY_DRAENORCLANS,	-- Southwind Cliffs Digsite

	-- Ogre
	[1750] = ARCH_CURRENCY_OGRE,	-- Umbrafen Digsite
	[1764] = ARCH_CURRENCY_OGRE,	-- Writhing Mire Digsite
	[1776] = ARCH_CURRENCY_OGRE,	-- Gordal Fortress Digsite
	[1780] = ARCH_CURRENCY_OGRE,	-- Duskfall Island Digsite (race inferred: name variant of the wiki's Duskfall)
	[1782] = ARCH_CURRENCY_OGRE,	-- Zangarra Digsite
	[1786] = ARCH_CURRENCY_OGRE,	-- Ango'rosh Digsite
	[1788] = ARCH_CURRENCY_OGRE,	-- Forgotten Ogre Ruin Digsite
	[1790] = ARCH_CURRENCY_OGRE,	-- Ruins of Na'gwa Digsite
	[1792] = ARCH_CURRENCY_OGRE,	-- Overgrown Highmaul Road Digsite
	[1796] = ARCH_CURRENCY_OGRE,	-- Stonecrag Excavation Digsite
	[1816] = ARCH_CURRENCY_OGRE,	-- Highmaul Watchtower Digsite
	[1818] = ARCH_CURRENCY_OGRE,	-- Mar'gok's Overwatch Digsite
	[1822] = ARCH_CURRENCY_OGRE,	-- The Broken Spine Digsite
	[1826] = ARCH_CURRENCY_OGRE,	-- Overlook Ruins Digsite
	[1830] = ARCH_CURRENCY_OGRE,	-- Ruins of the First Bastion Digsite

	-- Demonic
	[1880] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Aggramar's Vault
	[1882] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Stormdrake Peak
	[1884] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Southern Helmouth Shallows
	[1886] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Northern Helmouth Shallows (race taken from the zone, not from a site list)
	[1894] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Bradensbrook
	[1902] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Shala'nir
	[1904] = ARCH_CURRENCY_DEMONIC,	-- Digsite: The Crescent Vale
	[1906] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Legion Camp: Chaos
	[1910] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Feathermane Hunting Grounds
	[1933] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Gates of Valor
	[1937] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Warden's Bluff
	[1939] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Amberfall Mesa
	[1941] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Storm's Reach
	[1943] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Fallen Kings
	[1945] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Citrine Bay
	[1947] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Cliffpaw Ridge
	[1949] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Skold-Ashil
	[1969] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Llothien Highlands
	[1971] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Farondale
	[1973] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Rhut'van Passage
	[1978] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Northern Watcher Isle
	[1980] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Southern Watcher Isle
	[1982] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Makrana
	[2011] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Thas'talah
	[2013] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Wretched Hollow
	[2017] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Dreadroot
	[2041] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Felsoul Hold
	[2043] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Southern Suramar
	[2047] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Sundered Shoals
	[2049] = ARCH_CURRENCY_DEMONIC,	-- Digsite: Anora Hollow
	[2279] = ARCH_CURRENCY_DEMONIC,	-- Digsite: The Wildwood

	-- Highborne
	[1896] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Kal'delar
	[1898] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Lightsong
	[1900] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Andu'talah
	[1908] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Llothien
	[1912] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Moonwhisper Gulch
	[1984] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Garden of Elune
	[1986] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: The Ruined Sanctum
	[1988] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Old Coast Path
	[1990] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Temple of a Thousand Lights
	[1992] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Ruins of Zarkhenar
	[1994] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: The Tidal Marsh
	[1998] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Black Rook Hold
	[2000] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Sundersong Glade
	[2004] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Southern Wash
	[2027] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Eastern Ambervale
	[2029] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Northern Moonfall Retreat
	[2031] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Gates of the City
	[2075] = ARCH_CURRENCY_HIGHBORNE,	-- Digsite: Koralune Estate

	-- Highmountain Tauren
	[1877] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Whitewater Wash
	[1888] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Fields of An'she
	[1890] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Screeching Bend
	[1892] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Southern Snowblind Mesa
	[1951] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Prowler's Scratch
	[1953] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Pinerock Basin
	[1955] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: The Witchwood
	[1957] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Bloodhunt Highland
	[1959] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: The Haglands
	[1961] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Darkfeather Valley (race inferred: name variant of the wiki's Darkfeather Alley)
	[1963] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Sky Sepulcher
	[1965] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Northern Snowblind Mesa
	[1967] = ARCH_CURRENCY_HIGHMOUNTAIN,	-- Digsite: Dragon's Falls

	-- Drust
	[2399] = ARCH_CURRENCY_DRUST,	-- Digsite: Valley View
	[2401] = ARCH_CURRENCY_DRUST,	-- Digsite: Brokenbough Roost
	[2403] = ARCH_CURRENCY_DRUST,	-- Digsite: Fernwood Ridge (race taken from the continent, not from a site list)
	[2405] = ARCH_CURRENCY_DRUST,	-- Digsite: Rockslip Woodlands
	[2407] = ARCH_CURRENCY_DRUST,	-- Digsite: Vigil Hill
	[2409] = ARCH_CURRENCY_DRUST,	-- Digsite: Placid Springs
	[2411] = ARCH_CURRENCY_DRUST,	-- Digsite: Stagheart Cliffs
	[2413] = ARCH_CURRENCY_DRUST,	-- Digsite: Deathmist Hills (race taken from the continent, not from a site list)
	[2415] = ARCH_CURRENCY_DRUST,	-- Digsite: Gol Koval (race taken from the continent, not from a site list)
	[2417] = ARCH_CURRENCY_DRUST,	-- Digsite: Hunter's Run
	[2419] = ARCH_CURRENCY_DRUST,	-- Digsite: Brackish Coast
	[2421] = ARCH_CURRENCY_DRUST,	-- Digsite: Arom's Crossing
	[2423] = ARCH_CURRENCY_DRUST,	-- Digsite: Corlain (race taken from the continent, not from a site list)
	[2425] = ARCH_CURRENCY_DRUST,	-- Digsite: Whitegrove Chapel
	[2427] = ARCH_CURRENCY_DRUST,	-- Digsite: Crimson Forest
	[2429] = ARCH_CURRENCY_DRUST,	-- Digsite: Iceveil Glacier
	[2431] = ARCH_CURRENCY_DRUST,	-- Digsite: Seabreeze Shallows (race taken from the continent, not from a site list)
	[2433] = ARCH_CURRENCY_DRUST,	-- Digsite: Millstone Hills
	[2435] = ARCH_CURRENCY_DRUST,	-- Digsite: Goldfield Farmstead
	[2437] = ARCH_CURRENCY_DRUST,	-- Digsite: Roaming Hills
	[2439] = ARCH_CURRENCY_DRUST,	-- Digsite: Dire Hills
	[2441] = ARCH_CURRENCY_DRUST,	-- Digsite: Drowned Lands
	[2443] = ARCH_CURRENCY_DRUST,	-- Digsite: Briny Flats
	[2445] = ARCH_CURRENCY_DRUST,	-- Digsite: Windwhisper Summit

	-- Zandalari
	[2447] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Xibala (race taken from the continent, not from a site list)
	[2449] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Tusk Isle
	[2451] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Dreadpearl Shallows
	[2453] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Atal'Gral
	[2455] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Savagelands
	[2457] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Old Merchant Road
	[2459] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Zeb'ahari
	[2461] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: The Rivermarsh
	[2463] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Plains of Tojek
	[2465] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Terrace of Sorrows
	[2467] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: The Far Reach (race taken from the continent, not from a site list)
	[2469] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Natha'vor
	[2471] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Razorjaw River
	[2473] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Upper Frogmarsh
	[2475] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Xal'vor
	[2477] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Verdant Plateau
	[2479] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Arid Basin
	[2481] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: The Eternal Spring
	[2483] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Whistlebloom Oasis
	[2485] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Port of Zem'lan (race taken from the continent, not from a site list)
	[2487] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: The Cracked Coast
	[2489] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Court of Zak'rajan (race taken from the continent, not from a site list)
	[2491] = ARCH_CURRENCY_ZANDALARI,	-- Digsite: Terrace of the Fang (race taken from the continent, not from a site list)
}
app.DigSiteRaces = DigSiteRaces

local function ShouldShow()
	local settings = app.Settings
	return settings:GetTooltipSetting("DigSiteTooltip")
		and (not InCombatLockdown() or settings:GetTooltipSetting("DisplayInCombat"))
		and settings:GetTooltipSettingWithMod("Enabled")
end

-- Digsite pins have no tooltip of their own (only the map's area label), so ATT builds one
local function OnMouseEnter(pin)
	local poiInfo = pin.poiInfo
	local currencyID = poiInfo and DigSiteRaces[poiInfo.researchSiteID]
	if not currencyID or not ShouldShow() then return end

	GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
	GameTooltip:AddLine(pin.name or poiInfo.name, 1, 1, 1)
	app.AttachSearchResultsToTooltip(GameTooltip, "currencyID", currencyID)
	GameTooltip:Show()
end
local function OnMouseLeave(pin)
	if GameTooltip:GetOwner() == pin then GameTooltip:Hide() end
end

-- Pins are pooled frames which copy the pin mixin when created, so each one is hooked the first time it is acquired.
-- The map canvas sets the OnEnter/OnLeave scripts to the mixin functions when the pin is created, so hooking the
-- functions afterwards would never be called, the scripts have to be hooked instead
local HookedPins = setmetatable({}, { __mode = "k" })
local function OnPinAcquired(pin)
	if HookedPins[pin] then return end
	HookedPins[pin] = true
	pin:HookScript("OnEnter", OnMouseEnter)
	pin:HookScript("OnLeave", OnMouseLeave)
end

local function HookDigSitePins()
	if not DigSitePinMixin then return false end
	hooksecurefunc(DigSitePinMixin, "OnAcquired", OnPinAcquired)
	return true
end
app.AddEventHandler("OnReady", function()
	if HookDigSitePins() then return end
	-- the map data providers are not loaded yet, so wait for them
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self)
		if HookDigSitePins() then self:UnregisterAllEvents() end
	end)
end)
