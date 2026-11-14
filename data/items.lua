-- rarity = 'uncommon' | 'rare' | 'epic' | 'legendary' (sin rarity = común). Se ve en el color del slot
return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		rarity = 'uncommon',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['prenda'] = {
		label = 'Prenda',
		weight = 250,
		stack = false,
		close = false,
		description = 'Arrástrala a una ranura de ropa para ponértela.',
	},

	['blueprint'] = {
		label = 'Plano',
		rarity = 'rare',
		weight = 10,
		stack = false,
		close = true,
		description = 'Úsalo para aprender una receta de crafteo.',
		server = { export = 'ox_inventory.rustLearnBlueprint' },
	},

	['mochila_pequena'] = {
		label = 'Mochila pequeña',
		rarity = 'rare',
		weight = 1000,
		stack = false,
		close = true,
		description = 'Ponla en el slot Mochila: +5 slots. Úsala para ver lo que tiene dentro.',
		server = { export = 'ox_inventory.rustOpenBackpack' },
	},

	['mochila_grande'] = {
		label = 'Mochila grande',
		rarity = 'epic',
		weight = 2000,
		stack = false,
		close = true,
		description = 'Ponla en el slot Mochila: +10 slots. Úsala para ver lo que tiene dentro.',
		server = { export = 'ox_inventory.rustOpenBackpack' },
	},

	['cloth'] = {
		label = 'Tela',
		weight = 20,
		stack = true,
		description = 'Material básico. Se usa para craftear vendas.',
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		rarity = 'rare',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		rarity = 'uncommon',
		weight = 160,
	},

	['phone'] = {
		label = 'Phone',
		rarity = 'uncommon',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		rarity = 'uncommon',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Chaleco antibalas',
		rarity = 'epic',
		weight = 3000,
		stack = false,
		description = 'Ponlo en la ranura Chaleco (o úsalo) para protegerte.',
		server = { export = 'ox_inventory.rustUseArmour' },
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		rarity = 'uncommon',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	-- ===== Items importados (items.lua del escritorio) =====
	['clothing_hat'] = {
		label = 'Hat',
		weight = 150,
		stack = false,
		close = false,
		description = 'Headwear. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_mask'] = {
		label = 'Mask',
		weight = 120,
		stack = false,
		close = false,
		description = 'A face mask. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_glasses'] = {
		label = 'Glasses',
		weight = 60,
		stack = false,
		close = false,
		description = 'Eyewear. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_ears'] = {
		label = 'Ear piece',
		weight = 40,
		stack = false,
		close = false,
		description = 'An ear accessory. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_chain'] = {
		label = 'Chain',
		weight = 90,
		stack = false,
		close = false,
		description = 'A neck chain. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_watch'] = {
		label = 'Watch',
		weight = 80,
		stack = false,
		close = false,
		description = 'A wrist watch. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_jacket'] = {
		label = 'Jacket',
		weight = 600,
		stack = false,
		close = false,
		description = 'A jacket. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_shirt'] = {
		label = 'Shirt',
		weight = 300,
		stack = false,
		close = false,
		description = 'A shirt. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_armor'] = {
		label = 'Body Armor',
		weight = 1200,
		stack = false,
		close = false,
		description = 'A protective vest. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_bag'] = {
		label = 'Bag',
		weight = 500,
		stack = false,
		close = false,
		description = 'A wearable bag. Use "Equip" to wear it.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_pants'] = {
		label = 'Pants',
		weight = 400,
		stack = false,
		close = false,
		description = 'A pair of pants. Use "Equip" to wear them.',
		-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
		client = { event = 'oxlyn:clothing:equipRequest' },
		buttons = {
			{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
		},
	},

	['clothing_shoes'] = {
	label = 'Shoes',
	weight = 350,
	stack = false,
	close = false,
	description = 'A pair of shoes. Use "Equip" to wear them.',
	-- 3.10.6: Use, the hotbar key and the Equip button all wear the piece
	client = { event = 'oxlyn:clothing:equipRequest' },
	buttons = {
		{ label = 'Equip', action = function(slot) TriggerEvent('oxlyn:clothing:equipRequest', slot) end },
	},
   },

	['backpack_level_1'] = {
     label = 'Scout Pack',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Compact backpack — 16 slots / 10 kg. Open it from your inventory.',
     client = {
         export = 'oxlyn_backpack.openBackpack'
     }
 },

	['backpack_level_2'] = {
     label = 'Courier Pack',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Mid-tier backpack — 24 slots / 15 kg. Open it from your inventory.',
     client = {
         export = 'oxlyn_backpack.openBackpack'
     }
 },

	['backpack_level_3'] = {
     label = 'Operator Pack',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Heavy-duty backpack — 32 slots / 20 kg. Open it from your inventory.',
     client = {
         export = 'oxlyn_backpack.openBackpack'
     }
 },

	['backpack_level_4'] = {
     label = 'Expedition Pack',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Top-tier backpack — 46 slots / 25 kg. Open it from your inventory.',
     client = {
         export = 'oxlyn_backpack.openBackpack'
     }
 },

	['backpack_padlock'] = {
     label = 'Padlock',
     weight = 200,
     stack = false,
     close = true,
     description = 'PIN padlock. Drag it into an open backpack to secure it with a 4-digit code.'
 },

	['backpack_fingerprint_padlock'] = {
     label = 'Fingerprint Padlock',
     weight = 250,
     stack = false,
     close = true,
     description = 'Biometric lock. Drag it into an open backpack to bind it to your fingerprint.'
 },

	['backpack_gps'] = {
     label = 'GPS Module',
     weight = 150,
     stack = false,
     close = true,
     description = 'Live GPS tracker. Drag it into an open backpack to follow it in real time — even if it is stolen.'
 },

	['backpack_multitool'] = {
     label = 'Multitool',
     weight = 300,
     stack = false,
     close = true,
     description = 'Lock-cracking multitool. Consumed by the crack minigame.'
 },

	['backpack_custom_1'] = {
     label = 'Custom Backpack 1',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_2'] = {
     label = 'Custom Backpack 2',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_3'] = {
     label = 'Custom Backpack 3',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_4'] = {
     label = 'Custom Backpack 4',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_5'] = {
     label = 'Custom Backpack 5',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_6'] = {
     label = 'Custom Backpack 6',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_7'] = {
     label = 'Custom Backpack 7',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_8'] = {
     label = 'Custom Backpack 8',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_9'] = {
     label = 'Custom Backpack 9',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	['backpack_custom_10'] = {
     label = 'Custom Backpack 10',
     weight = 1000,
     stack = false,
     close = true,
     description = 'Custom backpack slot — configure it in /backpackeditor.',
     client = { export = 'oxlyn_backpack.openBackpack' }
 },

	["engine_oil"] = {
   label = "Engine Oil",
   weight = 1000,
 },

	["tyre_replacement"] = {
   label = "Tyre Replacement",
   weight = 1000,
 },

	["clutch_replacement"] = {
   label = "Clutch Replacement",
   weight = 1000,
 },

	["air_filter"] = {
   label = "Air Filter",
   weight = 100,
 },

	["spark_plug"] = {
   label = "Spark Plug",
   weight = 1000,
 },

	["brakepad_replacement"] = {
   label = "Brakepad Replacement",
   weight = 1000,
 },

	["suspension_parts"] = {
   label = "Suspension Parts",
   weight = 1000,
 },

	["i4_engine"] = {
   label = "I4 Engine",
   weight = 1000,
 },

	["v6_engine"] = {
   label = "V6 Engine",
   weight = 1000,
 },

	["v8_engine"] = {
   label = "V8 Engine",
   weight = 1000,
 },

	["v12_engine"] = {
   label = "V12 Engine",
   weight = 1000,
 },

	["turbocharger"] = {
   label = "Turbocharger",
   weight = 1000,
 },

	["ev_motor"] = {
   label = "EV Motor",
   weight = 1000,
 },

	["ev_battery"] = {
   label = "EV Battery",
   weight = 1000,
 },

	["ev_coolant"] = {
   label = "EV Coolant",
   weight = 1000,
 },

	["awd_drivetrain"] = {
   label = "AWD Drivetrain",
   weight = 1000,
 },

	["rwd_drivetrain"] = {
   label = "RWD Drivetrain",
   weight = 1000,
 },

	["fwd_drivetrain"] = {
   label = "FWD Drivetrain",
   weight = 1000,
 },

	["slick_tyres"] = {
   label = "Slick Tyres",
   weight = 1000,
 },

	["semi_slick_tyres"] = {
   label = "Semi Slick Tyres",
   weight = 1000,
 },

	["offroad_tyres"] = {
   label = "Offroad Tyres",
   weight = 1000,
 },

	["drift_tuning_kit"] = {
   label = "Drift Tuning Kit",
   weight = 1000,
 },

	["ceramic_brakes"] = {
   label = "Ceramic Brakes",
   weight = 1000,
 },

	["lighting_controller"] = {
   label = "Lighting Controller",
   weight = 100,
   client = {
     event = "jg-mechanic:client:show-lighting-controller",
   }
 },

	["stancing_kit"] = {
   label = "Stancer Kit",
   weight = 100,
   client = {
     event = "jg-mechanic:client:show-stancer-kit",
   }
 },

	["cosmetic_part"] = {
   label = "Cosmetic Parts",
   weight = 100,
 },

	["respray_kit"] = {
   label = "Respray Kit",
   weight = 1000,
 },

	["vehicle_wheels"] = {
   label = "Vehicle Wheels Set",
   weight = 1000,
 },

	["tyre_smoke_kit"] = {
   label = "Tyre Smoke Kit",
   weight = 1000,
 },

	["bulletproof_tyres"] = {
   label = "Bulletproof Tyres",
   weight = 1000,
 },

	["extras_kit"] = {
   label = "Extras Kit",
   weight = 1000,
 },

	["nitrous_bottle"] = {
   label = "Nitrous Bottle",
   weight = 1000,
   client = {
     event = "jg-mechanic:client:use-nitrous-bottle",
   }
 },

	["empty_nitrous_bottle"] = {
   label = "Empty Nitrous Bottle",
   weight = 1000,
 },

	["nitrous_install_kit"] = {
   label = "Nitrous Install Kit",
   weight = 1000,
 },

	["cleaning_kit"] = {
   label = "Cleaning Kit",
   weight = 1000,
   client = {
     event = "jg-mechanic:client:clean-vehicle",
   }
 },

	["repair_kit"] = {
   label = "Repair Kit",
   weight = 1000,
   client = {
     event = "jg-mechanic:client:repair-vehicle",
   }
 },

	["duct_tape"] = {
   label = "Duct Tape",
   weight = 1000,
   client = {
     event = "jg-mechanic:client:use-duct-tape",
   }
 },

	["performance_part"] = {
   label = "Performance Parts",
   weight = 1000,
 },

	["mechanic_tablet"] = {
   label = "Mechanic Tablet",
   weight = 1000,
   client = {
     event = "jg-mechanic:client:use-tablet",
   }
 },

	["manual_gearbox"] = {
   label = "Manual Gearbox",
   weight = 1000,
 },

	["medkit"] = {
     label = 'Med-Kit',
     description = 'A medical kit for treating injuries',
     weight = 250,
     server = {
         export = "wasabi_ambulance_v2.medkit"
     }
 },

	["firstaidkit"] = {
     label = 'First Aid Kit',
     description = 'A comprehensive first aid kit for serious injuries',
     weight = 350,
     server = {
         export = "wasabi_ambulance_v2.firstaidkit"
     }
 },

	["painkillers"] = {
     label = 'Painkillers',
     description = 'Pills to temporarily relieve pain and reduce stun effects',
     weight = 10,
     server = {
         export = "wasabi_ambulance_v2.painkillers"
     }
 },

	["ifak"] = {
     label = 'IFAK',
     description = 'Individual First Aid Kit',
     weight = 150,
     server = {
         export = "wasabi_ambulance_v2.ifak"
     }
 },

	["sedative"] = {
     label = 'Sedative',
     description = 'A controlled sedative for EMS use',
     weight = 25,
     consume = 0,
     server = {
         export = "wasabi_ambulance_v2.sedative"
     }
 },

	["defibrillator"] = {
     label = 'Defibrillator',
     description = 'A reusable defibrillator for reviving downed patients',
     weight = 2500,
     stack = false,
     close = true,
     consume = 0,
     server = {
         export = "wasabi_ambulance_v2.defibrillator"
     }
 },

	["forceps"] = {
     label = 'Forceps',
     description = 'Used to treat gunshot wounds',
     weight = 100,
 },

	["pliers"] = {
     label = 'Pliers',
     description = 'Used to treat taser prong wounds',
     weight = 25,
 },

	["suture"] = {
     label = 'Suture',
     description = 'Used to treat cuts',
     weight = 25,
 },

	["splint"] = {
     label = 'Splint',
     description = 'Used to treat broken bones',
     weight = 50,
 },

	["icepack"] = {
     label = 'Ice Pack',
     description = 'Used to treat punches and bruises',
     weight = 25,
 },

	["traumakit"] = {
     label = 'Trauma Kit',
     description = 'Used to treat blunt force trauma',
     weight = 75,
 },

	["burncream"] = {
     label = 'Burn Cream',
     description = 'Used to treat burns',
     weight = 10,
 },

	["medbag"] = {
     label = 'Medbag',
     description = 'A portable medical bag containing supplies',
     weight = 50,
     stack = false,
     close = true,
     consume = 0,
     server = {
         export = "wasabi_ambulance_v2.medbag"
     }
 },

	['stone_pickaxe'] = {
     label = 'Stone Pickaxe',
     weight = 200,
     stack = false,
     close = true,
 },

	['iron_pickaxe'] = {
     label = 'Iron Pickaxe',
     weight = 250,
     stack = false,
     close = true,
 },

	['steel_pickaxe'] = {
     label = 'Steel Pickaxe',
     weight = 300,
     stack = false,
     close = true,
 },

	['titanium_pickaxe'] = {
     label = 'Titanium Pickaxe',
     weight = 350,
     stack = false,
     close = true,
 },

	['diamond_pickaxe'] = {
     label = 'Diamond Pickaxe',
     weight = 400,
     stack = false,
     close = true,
 },

	['quantum_pickaxe'] = {
     label = 'Quantum Pickaxe',
     weight = 450,
     stack = false,
     close = true,
 },

	['mining_drill'] = {
     label = 'Mining Drill',
     weight = 750,
     stack = false,
     close = true,
 },

	['laser_drill'] = {
     label = 'Laser Drill',
     weight = 750,
     stack = false,
     close = true,
 },

	['stone'] = {
     label = 'Stone',
     weight = 10,
     stack = true,
     close = true,
 },

	['coal_ore'] = {
     label = 'Coal Ore',
     weight = 25,
     stack = true,
     close = true,
 },

	['copper_ore'] = {
     label = 'Copper Ore',
     weight = 35,
     stack = true,
     close = true,
 },

	['iron_ore'] = {
     label = 'Iron Ore',
     weight = 45,
     stack = true,
     close = true,
 },

	['silver_ore'] = {
     label = 'Silver Ore',
     weight = 45,
     stack = true,
     close = true,
 },

	['gold_ore'] = {
     label = 'Gold Ore',
     weight = 55,
     stack = true,
     close = true,
 },

	['platinum_ore'] = {
     label = 'Platinum Ore',
     weight = 60,
     stack = true,
     close = true,
 },

	['titanium_ore'] = {
     label = 'Titanium Ore',
     weight = 70,
     stack = true,
     close = true,
 },

	['mithril_ore'] = {
     label = 'Mithril Ore',
     weight = 70,
     stack = true,
     close = true,
 },

	['adamantium_ore'] = {
     label = 'Adamantium Ore',
     weight = 70,
     stack = true,
     close = true,
 },

	['copper_ingot'] = {
     label = 'Copper ingot',
     weight = 30,
     stack = true,
     close = true,
 },

	['iron_ingot'] = {
     label = 'Iron ingot',
     weight = 40,
     stack = true,
     close = true,
 },

	['silver_ingot'] = {
     label = 'Silver ingot',
     weight = 40,
     stack = true,
     close = true,
 },

	['gold_ingot'] = {
     label = 'Gold ingot',
     weight = 50,
     stack = true,
     close = true,
 },

	['platinum_ingot'] = {
     label = 'Platinum ingot',
     weight = 55,
     stack = true,
     close = true,
 },

	['titanium_ingot'] = {
     label = 'Titanium ingot',
     weight = 60,
     stack = true,
     close = true,
 },

	['mithril_ingot'] = {
     label = 'Mithril ingot',
     weight = 70,
     stack = true,
     close = true,
 },

	['adamantium_ingot'] = {
     label = 'Adamantium ingot',
     weight = 70,
     stack = true,
     close = true,
 },

	['starterpack'] = {
     label = 'Starter Pack',
     weight = 0,
     stack = false,
     close = true,
     description = 'Open it to claim your starter pack.',
     client = {
         image = 'starterpack.png',
         export = 'qs-starterpack.UseItem',
     },
 },

	['handcuffs'] = {
     label = 'Handcuffs',
     weight = 200,
     stack = true,
 },

	['zipties'] = {
     label = 'Zipties',
     weight = 20,
     stack = true,
 },

	['blueprint_advancedrifle'] = {
     label = 'Blueprint - Advanced Rifle',
     description = 'Blueprint for the advanced rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_appistol'] = {
     label = 'Blueprint - APPistol',
     description = 'Blueprint for the APPistol.',
     weight = 100,
     stack = false
 },

	['blueprint_assaultrifle'] = {
     label = 'Blueprint - Assault Rifle',
     description = 'Blueprint for the Assault Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_assaultrifle_mk2'] = {
     label = 'Blueprint - Assault Rifle MK2',
     description = 'Blueprint for the Assault Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_assaultshotgun'] = {
     label = 'Blueprint - Assault Shotgun',
     description = 'Blueprint for the Assault Shotgun.',
     weight = 100,
     stack = false
 },

	['blueprint_assaultsmg'] = {
     label = 'Blueprint - Assault SMG',
     description = 'Blueprint for the Assault SMG.',
     weight = 100,
     stack = false
 },

	['blueprint_bullpuprifle'] = {
     label = 'Blueprint - Bullpup Rifle',
     description = 'Blueprint for the Bullpup Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_bullpuprifle_mk2'] = {
     label = 'Blueprint - Bullpup Rifle MK2',
     description = 'Blueprint for the Bullpup Rifle MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_bullpupshotgun'] = {
     label = 'Blueprint - Bullpup Shotgun',
     description = 'Blueprint for the Bullpup Shotgun.',
     weight = 100,
     stack = false
 },

	['blueprint_carbinerifle'] = {
     label = 'Blueprint - Carbine Rifle',
     description = 'Blueprint for the Carbine Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_carbinerifle_mk2'] = {
     label = 'Blueprint - Carbine Rifle MK2',
     description = 'Blueprint for the Carbine Rifle MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_combatmg'] = {
     label = 'Blueprint - Combat MG',
     description = 'Blueprint for the Combat MG.',
     weight = 100,
     stack = false
 },

	['blueprint_combatmg_mk2'] = {
     label = 'Blueprint - Combat MG MK2',
     description = 'Blueprint for the Combat MG MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_combatpdw'] = {
     label = 'Blueprint - Combat PDW',
     description = 'Blueprint for the Combat PDW.',
     weight = 100,
     stack = false
 },

	['blueprint_combatpistol'] = {
     label = 'Blueprint - Combat Pistol',
     description = 'Blueprint for the Combat Pistol.',
     weight = 100,
     stack = false
 },

	['blueprint_combatshotgun'] = {
     label = 'Blueprint - Combat Shotgun',
     description = 'Blueprint for the Combat Shotgun.',
     weight = 100,
     stack = false
 },

	['blueprint_compactrifle'] = {
     label = 'Blueprint - Compact Rifle',
     description = 'Blueprint for the Compact Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_digiscanner'] = {
     label = 'Blueprint - Digiscanner',
     description = 'Blueprint for the Digiscanner.',
     weight = 100,
     stack = false
 },

	['blueprint_gusenberg'] = {
     label = 'Blueprint - Gusenberg',
     description = 'Blueprint for the Gusenberg.',
     weight = 100,
     stack = false
 },

	['blueprint_heavypistol'] = {
     label = 'Blueprint - Heavy Pistol',
     description = 'Blueprint for the Heavy Pistol.',
     weight = 100,
     stack = false
 },

	['blueprint_heavyrifle'] = {
     label = 'Blueprint - Heavy Rifle',
     description = 'Blueprint for the Heavy Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_heavyshotgun'] = {
     label = 'Blueprint - Heavy Shotgun',
     description = 'Blueprint for the Heavy Shotgun.',
     weight = 100,
     stack = false
 },

	['blueprint_heavysniper'] = {
     label = 'Blueprint - Heavy Sniper',
     description = 'Blueprint for the Heavy Sniper.',
     weight = 100,
     stack = false
 },

	['blueprint_heavysniper_mk2'] = {
     label = 'Blueprint - Heavy Sniper MK2',
     description = 'Blueprint for the Heavy Sniper MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_machinepistol'] = {
     label = 'Blueprint - Machine Pistol',
     description = 'Blueprint for the Machine Pistol.',
     weight = 100,
     stack = false
 },

	['blueprint_marksmanpistol'] = {
     label = 'Blueprint - Marksman Pistol',
     description = 'Blueprint for the Marksman Pistol.',
     weight = 100,
     stack = false
 },

	['blueprint_marksmanrifle'] = {
     label = 'Blueprint - Marksman Rifle',
     description = 'Blueprint for the Marksman Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_marksmanrifle_mk2'] = {
     label = 'Blueprint - Marksman Rifle MK2',
     description = 'Blueprint for the Marksman Rifle MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_metaldetector'] = {
     label = 'Blueprint - Metal Detector',
     description = 'Blueprint for the Metal Detector.',
     weight = 100,
     stack = false
 },

	['blueprint_mg'] = {
     label = 'Blueprint - MG',
     description = 'Blueprint for the MG.',
     weight = 100,
     stack = false
 },

	['blueprint_militaryrifle'] = {
     label = 'Blueprint - Military Rifle',
     description = 'Blueprint for the Military Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_minismg'] = {
     label = 'Blueprint - Mini SMG',
     description = 'Blueprint for the Mini SMG.',
     weight = 100,
     stack = false
 },

	['blueprint_musket'] = {
     label = 'Blueprint - Musket',
     description = 'Blueprint for the Musket.',
     weight = 100,
     stack = false
 },

	['blueprint_pistol'] = {
     label = 'Blueprint - Pistol',
     description = 'Blueprint for the Pistol.',
     weight = 100,
     stack = false
 },

	['blueprint_pistol_mk2'] = {
     label = 'Blueprint - Pistol MK2',
     description = 'Blueprint for the Pistol MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_pistol50'] = {
     label = 'Blueprint - Pistol .50',
     description = 'Blueprint for the Pistol .50.',
     weight = 100,
     stack = false
 },

	['blueprint_precisionrifle'] = {
     label = 'Blueprint - Precision Rifle',
     description = 'Blueprint for the Precision Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_pumpshotgun'] = {
     label = 'Blueprint - Pump Shotgun',
     description = 'Blueprint for the Pump Shotgun.',
     weight = 100,
     stack = false
 },

	['blueprint_pumpshotgun_mk2'] = {
     label = 'Blueprint - Pump Shotgun MK2',
     description = 'Blueprint for the Pump Shotgun MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_revolver'] = {
     label = 'Blueprint - Revolver',
     description = 'Blueprint for the Revolver.',
     weight = 100,
     stack = false
 },

	['blueprint_revolver_mk2'] = {
     label = 'Blueprint - Revolver MK2',
     description = 'Blueprint for the Revolver MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_smg'] = {
     label = 'Blueprint - SMG',
     description = 'Blueprint for the SMG.',
     weight = 100,
     stack = false
 },

	['blueprint_smg_mk2'] = {
     label = 'Blueprint - SMG MK2',
     description = 'Blueprint for the SMG MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_snspistol'] = {
     label = 'Blueprint - SNS Pistol',
     description = 'Blueprint for the SNS Pistol.',
     weight = 100,
     stack = false
 },

	['blueprint_specialcarbine'] = {
     label = 'Blueprint - Special Carbine',
     description = 'Blueprint for the Special Carbine.',
     weight = 100,
     stack = false
 },

	['blueprint_specialcarbine_mk2'] = {
     label = 'Blueprint - Special Carbine MK2',
     description = 'Blueprint for the Special Carbine MK2.',
     weight = 100,
     stack = false
 },

	['blueprint_tacticalrifle'] = {
     label = 'Blueprint - Tactical Rifle',
     description = 'Blueprint for the Tactical Rifle.',
     weight = 100,
     stack = false
 },

	['blueprint_tecpistol'] = {
     label = 'Blueprint - Tec Pistol',
     description = 'Blueprint for the Tec Pistol.',
     weight = 100,
     stack = false
 },

	['red_grapes'] = {
     label = 'Red grapes',
     weight = 200,
     stack = true
 },

	['white_grapes'] = {
     label = 'White grapes',
     weight = 200,
     stack = true
 },

	['white_wine_juice'] = {
     label = 'White wine juice',
     weight = 1000,
     stack = true
 },

	['red_wine_juice'] = {
     label = 'Red wine juice',
     weight = 1000,
     stack = true
 },

	['empty_bottle'] = {
     label = 'Empty wine bottle',
     weight = 200,
     stack = true
 },

	['white_wine'] = {
     label = 'White wine',
     weight = 1200,
     stack = true
 },

	['red_wine'] = {
     label = 'Red wine',
     weight = 1200,
     stack = true
 },

	['grape_snips'] = {
     label = 'Grape snips',
     weight = 200,
     stack = false
 },

	['burger_bleeder'] = {
     label = 'Bleeder burger',
     weight = 300,
 },

	['burger_heartstopper'] = {
     label = 'Heart stopper burger',
     weight = 500,
 },

	['burger_torpedo'] = {
     label = 'Torpedo Sandwich',
     weight = 200,
 },

	['burger_meatfree'] = {
     label = 'Meat free burger',
     weight = 200,
 },

	['burger_moneyshot'] = {
     label = 'Money shot burger',
     weight = 300,
 },

	['burger_chickenwrap'] = {
     label = 'Chicken wrap',
     weight = 200,
 },

	['burger_donut'] = {
     label = 'Donut',
     weight = 300,
 },

	['burger_applepie'] = {
     label = 'Apple pie',
     weight = 300,
 },

	['burger_fries'] = {
     label = 'Freedom fries',
     weight = 200,
 },

	['burger_coffee'] = {
     label = 'Coffee',
     weight = 250,
 },

	['burger_ecola'] = {
     label = 'eCola',
     weight = 500,
 },

	['burger_sprunk'] = {
     label = 'Sprunk',
     weight = 500,
 },

	['burger_emptycup'] = {
     label = 'Empty cup',
     weight = 50,
 },

	['bacon'] = {
     label = 'Bacon',
     weight = 50
 },

	['bun'] = {
     label = 'Burger bun',
     weight = 50
 },

	['baguette'] = {
     label = 'Baguette',
     weight = 50
 },

	['cheddar'] = {
     label = 'Cheddar cheese',
     weight = 20
 },

	['raw_chicken'] = {
     label = 'Raw chicken',
     weight = 150
 },

	['chicken_strips'] = {
     label = 'Chicken strips',
     weight = 150
 },

	['cooked_patty'] = {
     label = 'Cooked patty',
     weight = 150
 },

	['patty'] = {
     label = 'Patty',
     weight = 150
 },

	['sliced_onion'] = {
     label = 'Sliced onion',
     weight = 30
 },

	['lettuce'] = {
     label = 'Fresh salad',
     weight = 50
 },

	['tomato'] = {
     label = 'Tomato',
     weight = 50
 },

	['wrap'] = {
     label = 'Tortilla wrap',
     weight = 50
 },

	['sliced_potato'] = {
     label = 'Potato',
     weight = 200
 },

	['mojito'] = {
     label = 'Mojito',
     weight = 300
 },

	['vodka'] = {
     label = 'Vodka',
     weight = 300
 },

	['champagne'] = {
     label = 'Champagne',
     weight = 300
 },

	['tequila'] = {
     label = 'Tequila',
     weight = 300
 },

	['martini'] = {
     label = 'Martini',
     weight = 300
 },

	['icetea'] = {
     label = 'Icetea',
     weight = 300
 },

	['lemonade'] = {
     label = 'Lemonade',
     weight = 300
 },

	['monster'] = {
     label = 'Monster Energy',
     weight = 350,
     stack = true,
     close = true,
     consume = 1,
     client = {
         export = 'dl_energy.useMonster'
     }
 },

	['redbull'] = {
     label = 'Red Bull',
     weight = 250,
     stack = true,
     close = true,
     consume = 1,
     client = {
         export = 'dl_energy.useRedbull'
     }
 },

	['model_door_wood'] = {label = 'Wood Door', weight = 100},

	['model_window_wood'] = {label = 'Wood Window', weight = 100},

	['model_windowway_wood'] = {label = 'Wood Window Frame', weight = 100},

	['model_wall_wood'] = {label = 'Wood Wall', weight = 100},

	['model_doorway_wood'] = {label = 'Wood Door Frame', weight = 100},

	['model_gateway_wood'] = {label = 'Wood Gate Frame', weight = 100},

	['model_base_wood'] = {label = 'Wood Foundation', weight = 100},

	['model_ceiling_wood'] = {label = 'Wood Ceiling', weight = 100},

	['model_ceilingstairs_wood'] = {label = 'Wood Ceiling Stairs', weight = 100},

	['model_pillar_wood'] = {label = 'Wood Pillar', weight = 100},

	['model_gate_wood'] = {label = 'Wood Gate', weight = 100},

	['model_bigwall_wood'] = {label = 'Big Wall Wood', weight = 100},

	['model_biggateway_wood'] = {label = 'Big Gate Frame Wood', weight = 100},

	['model_biggate_wood'] = {label = 'Big Gate Wood', weight = 100},

	['model_base_wood_triangle'] = {label = 'Wood Triangle Foundation', weight = 100},

	['model_ceiling_wood_triangle'] = {label = 'Wood Triangle Foundation', weight = 100},

	['model_wall_wood_roof'] = {label = 'Wood Roof', weight = 100},

	['model_wall_wood_roof_triangle'] = {label = 'Wood Triangle Roof', weight = 100},

	['model_wall_wood_small'] = {label = 'Wood Small Wall', weight = 100},

	['model_wall_wood_triangle'] = {label = 'Wood Triangle Wall', weight = 100},

	['model_ceilingladder_wood_triangle'] = {label = 'Wood Triangle Ceiling Ladder', weight = 100},

	['model_stairs_wood'] = {label = 'Wood stairs', weight = 100},

	['model_pillar2_wood'] = {label = 'Wood Pillar Base', weight = 100},

	['model_door_stone'] = {label = 'Stone Door', weight = 100},

	['model_window_stone'] = {label = 'Stone Window', weight = 100},

	['model_windowway_stone'] = {label = 'Stone Window Frame', weight = 100},

	['model_wall_stone'] = {label = 'Stone Wall', weight = 100},

	['model_doorway_stone'] = {label = 'Stone Door Frame', weight = 100},

	['model_gateway_stone'] = {label = 'Stone Gate Frame', weight = 100},

	['model_base_stone'] = {label = 'Stone Foundation', weight = 100},

	['model_ceiling_stone'] = {label = 'Stone Ceiling', weight = 100},

	['model_ceilingstairs_stone'] = {label = 'Stone Stairs', weight = 100},

	['model_pillar_stone'] = {label = 'Stone Pillar', weight = 100},

	['model_gate_stone'] = {label = 'Stone Gate', weight = 100},

	['model_base_stone_triangle'] = {label = 'Stone Triangle Foundation', weight = 100},

	['model_ceiling_stone_triangle'] = {label = 'Stone Triangle Ceiling', weight = 100},

	['model_wall_stone_roof'] = {label = 'Stone Roof', weight = 100},

	['model_wall_stone_roof_triangle'] = {label = 'Stone Triangle Roof', weight = 100},

	['model_wall_stone_small'] = {label = 'Stone Small Wall', weight = 100},

	['model_wall_stone_triangle'] = {label = 'Stone Triangle Wall', weight = 100},

	['model_ceilingladder_stone_triangle'] = {label = 'Stone Triangle Ceiling Ladder', weight = 100},

	['model_stairs_stone'] = {label = 'Stone stairs', weight = 100},

	['model_pillar2_stone'] = {label = 'Stone Pillar Base', weight = 100},

	['model_door_metal'] = {label = 'Metal Door', weight = 100},

	['model_window_metal'] = {label = 'Metal Window', weight = 100},

	['model_windowway_metal'] = {label = 'Metal Window', weight = 100},

	['model_wall_metal'] = {label = 'Metal Wall', weight = 100},

	['model_doorway_metal'] = {label = 'Metal Door Frame', weight = 100},

	['model_gateway_metal'] = {label = 'Metal Gate Frame', weight = 100},

	['model_base_metal'] = {label = 'Metal Foundation', weight = 100},

	['model_ceiling_metal'] = {label = 'Metal Ceiling', weight = 100},

	['model_ceilingstairs_metal'] = {label = 'Metal Ceiling Stairs', weight = 100},

	['model_pillar_metal'] = {label = 'Metal Pillar', weight = 100},

	['model_gate_metal'] = {label = 'Metal Gate', weight = 100},

	['model_base_metal_triangle'] = {label = 'Metal Triangle Foundation', weight = 100},

	['model_ceiling_metal_triangle'] = {label = 'Metal Triangle Ceiling', weight = 100},

	['model_wall_metal_roof'] = {label = 'Metal Roof', weight = 100},

	['model_wall_metal_roof_triangle'] = {label = 'Metal Triangle Roof', weight = 100},

	['model_wall_metal_small'] = {label = 'Metal Small Wall', weight = 100},

	['model_wall_metal_triangle'] = {label = 'Metal Triangle Wall', weight = 100},

	['model_ceilingladder_metal_triangle'] = {label = 'Metal Triangle Ceiling Ladder', weight = 100},

	['model_stairs_metal'] = {label = 'Metal stairs', weight = 100},

	['model_pillar2_metal'] = {label = 'Metal Pillar Base', weight = 100},

	['bkr_prop_biker_campbed_01'] = {label = 'Wood Bed', weight = 100},

	['v_tre_sofa_mess_b_s'] = {label = 'Wood Sofa', weight = 100},

	['prop_box_wood01a'] = {label = 'Wood Storage', weight = 100},

	['gr_prop_gr_gunlocker_01a'] = {label = 'Metal Storage', weight = 100},

	['p_v_43_safe_s'] = {label = 'Metal Storage Lv2', weight = 100},

	['prop_tool_bench02_ld'] = {label = 'Wood Crafting Table', weight = 100},

	['bkr_prop_meth_table01a'] = {label = 'Medical Table', weight = 100},

	['gr_prop_gr_bench_02a'] = {label = 'Weapons Table', weight = 100},

	['prop_planer_01'] = {label = 'Recycle Machine', weight = 100},

	['wood'] = {label = 'wood', weight = 100},

	['metalscrap'] = {label = 'Scrap Metal', weight = 100},

	['cable'] = {label = 'Cable', weight = 1},

	['prop_money_bag_01'] = {label = 'Bag', weight = 100},

	['xm3_prop_xm3_whshelf_03a'] = {label = 'Big Upkeep Box', weight = 100},

	['model_worklight_2'] = {label = 'WorkLight Small', weight = 100},

	['model_oldlight_ext'] = {label = 'Old Exterior Light', weight = 100},

	['model_worklight_1'] = {label = 'WorkLight Big', weight = 100},

	['model_biglight_1'] = {label = 'Big Light', weight = 100},

	['model_walllight_1'] = {label = 'Wall Light', weight = 100},

	['model_ceilinglight_1'] = {label = 'Ceiling Light', weight = 100},

	['model_generator_small'] = {label = 'Small Generator', weight = 100},

	['model_generator_big'] = {label = 'Big Generator', weight = 100},

	['model_generator_medium'] = {label = 'Medium Size Generator', weight = 100},

	['prop_solarpanel_02'] = {label = 'Big Solar Panel', weight = 100},

	['prop_solarpanel_03'] = {label = 'Solar Panel', weight = 100},

	['prop_rural_windmill'] = {label = 'Wind Turbine', weight = 100},

	['model_powerdist1_wall'] = {label = 'Power Distributor', weight = 100},

	['model_powercomb1_wall'] = {label = 'Power Combiner', weight = 100},

	['model_powerdist1_switch_wall'] = {label = 'Power Distributor [ON/OFF]', weight = 100},

	['prop_telegraph_06a'] = {label = 'Power Line', weight = 100},

	['model_battery_pack_6'] = {label = 'Battery Pack', weight = 100},

	['model_upkeep_1'] = {label = 'Upkeep Lvl 1', weight = 100},

	['model_upkeep_2'] = {label = 'Upkeep Lvl 2', weight = 100},

	['model_upkeep_3'] = {label = 'Ukeeep Lvl 3', weight = 100},

	['model_totem'] = {label = 'Totem', weight = 100},

	['base_blueprint'] = {label = "Base Blueprint", weight = 100},

	['model_campfire'] = {label = "Campfire", weight = 100},

	['model_hobo_stove'] = {label = "Hobo Stove", weight = 100},

	['model_doublebiggate_wood'] = {label = 'Wood Big Gate Door', weight = 100},

	['model_doublewindowway_stone'] = {label = 'Stone Double Window Frame', weight = 100},

	['model_doubledoorway_stone'] = {label = 'Stone Double Door Frame', weight = 100},

	['model_doublewindowway_metal'] = {label = 'Metal Double Window Frame', weight = 100},

	['model_doubledoorway_metal'] = {label = 'Metal Double Door Frame', weight = 100},

	['model_doublewindowway_wood'] = {label = 'Wood Double Window Frame', weight = 100},

	['model_doubledoorway_wood'] = { label = 'Wood Double Door Frame', weight = 100 },

	['zv_tire'] = { label = 'Llanta recuperada', weight = 100 },

	['zv_engine'] = { label = 'Motor recuperado', weight = 300 },

	['zv_transmission'] = { label = 'Transmisión recuperada', weight = 200 },

	['zv_battery'] = { label = 'Batería de vehículo', weight = 80 },

	['zv_radiator'] = { label = 'Radiador', weight = 100 },

	['zv_escape'] = { label = 'Escape', weight = 70 },

	['zv_hood'] = { label = 'Capó', weight = 200 },

	['zv_trunk'] = { label = 'Cajuela', weight = 200 },

	['zv_front_bumper'] = { label = 'Bumper delantero', weight = 150 },

	['zv_rear_bumper'] = { label = 'Bumper trasero', weight = 150 },

	['zv_door'] = { label = 'Puerta de vehículo', weight = 200 },

	['zv_seat'] = { label = 'Asiento de vehículo', weight = 200 },

	['zv_sparkplugs'] = { label = 'Bujías', weight = 20 },

	['zv_oil'] = { label = 'Aceite de motor', weight = 50 },

	['zv_refrigerant'] = { label = 'Refrigerante', weight = 50 },

zv_gold_chain = { label = 'Cadena de oro', weight = 120, stack = true, close = true, description = 'Cadena de oro recuperada. Puede fundirse para recuperar oro.' },

zv_gold_ring = { label = 'Anillo de oro', weight = 30, stack = true, close = true, description = 'Anillo de oro. Llévalo a la fundidora para recuperar metal.' },

zv_gold_watch = { label = 'Reloj de oro', weight = 180, stack = true, close = true, description = 'Reloj de lujo deteriorado con oro recuperable.' },

zv_silver_chain = { label = 'Cadena de plata', weight = 100, stack = true, close = true, description = 'Cadena de plata que puede procesarse en una fundidora.' },

zv_silver_ring = { label = 'Anillo de plata', weight = 25, stack = true, close = true, description = 'Anillo de plata recuperado de un vehículo abandonado.' },

zv_silver_earrings = { label = 'Aretes de plata', weight = 20, stack = true, close = true, description = 'Aretes de plata. Pueden fundirse para recuperar plata.' },

zv_broken_phone = { label = 'Teléfono roto', weight = 80, stack = true, close = true, description = 'No enciende; contiene plástico, cobre y componentes electrónicos.' },

zv_old_radio = { label = 'Radio vieja', weight = 90, stack = true, close = true, description = 'Radio deteriorada con piezas electrónicas recuperables.' },

zv_cracked_screen = { label = 'Pantalla quebrada', weight = 70, stack = true, close = true, description = 'Pantalla inservible que aún contiene vidrio y circuitos.' },

zv_car_stereo = { label = 'Estéreo de vehículo', weight = 100, stack = true, close = true, description = 'Estéreo antiguo; puede reciclarse para obtener cobre y plástico.' },

zv_damaged_pistol = { label = 'Pistola dañada', weight = 180, stack = false, close = true, description = 'Arma deteriorada e inutilizable. Requiere mesa de reparación, piezas y lubricante.' },

zv_damaged_revolver = { label = 'Revólver dañado', weight = 100, stack = false, close = true, description = 'Revólver oxidado y bloqueado. Debe repararse antes de usarse.' },

zv_damaged_shotgun = { label = 'Escopeta dañada', weight = 200, stack = false, close = true, description = 'Escopeta deteriorada. Necesita una reparación completa.' },

zv_damaged_smg = { label = 'Subfusil dañado', weight = 200, stack = false, close = true, description = 'Arma automática inutilizable; faltan componentes internos.' },

zv_wd40 = { label = 'Lubricante multiusos', weight = 30, stack = true, close = true, description = 'Lubricante para limpiar mecanismos oxidados durante una reparación.' },

zv_weapon_parts = { label = 'Piezas de arma', weight = 100, stack = true, close = true, description = 'Componentes internos recuperados para reparar armas dañadas.' },

zv_copper_wire = { label = 'Cable de cobre', weight = 150, stack = true, close = true, description = 'Cable recuperado; sirve para fabricar radios y teléfonos.' },

zv_circuit_board = { label = 'Placa electrónica', weight = 250, stack = true, close = true, description = 'Placa recuperada de un aparato electrónico.' },

zv_microchip = { label = 'Microchip', weight = 50, stack = true, close = true, description = 'Componente electrónico pequeño y poco común.' },

zv_antenna = { label = 'Antena recuperada', weight = 300, stack = true, close = true, description = 'Antena dañada, útil para fabricar una radio.' },

zv_speaker = { label = 'Altavoz pequeño', weight = 500, stack = true, close = true, description = 'Altavoz recuperado de una radio o estéreo.' },

zv_microphone = { label = 'Micrófono recuperado', weight = 100, stack = true, close = true, description = 'Micrófono pequeño para reparar radios.' },

zv_phone_screen = { label = 'Pantalla de teléfono', weight = 200, stack = true, close = true, description = 'Pantalla de repuesto para ensamblar un teléfono.' },

zv_phone_camera = { label = 'Cámara de teléfono', weight = 50, stack = true, close = true, description = 'Módulo de cámara recuperado de un teléfono.' },

zv_phone_case = { label = 'Carcasa de teléfono', weight = 150, stack = true, close = true, description = 'Carcasa vacía para ensamblar un teléfono.' },

zv_sim_card = { label = 'Tarjeta SIM', weight = 10, stack = true, close = true, description = 'Tarjeta SIM recuperada; componente para un teléfono funcional.' },

zv_small_battery = { label = 'Batería pequeña', weight = 100, stack = true, close = true, description = 'Batería compacta para aparatos electrónicos.' },

zv_fabric = { label = 'Tela resistente', weight = 250, stack = true, close = true, description = 'Tela resistente para fabricar mochilas o estuches.' },

zv_leather_scrap = { label = 'Retazo de cuero', weight = 200, stack = true, close = true, description = 'Cuero recuperado de un asiento viejo.' },

zv_nylon_strap = { label = 'Correa de nailon', weight = 150, stack = true, close = true, description = 'Correa resistente para mochilas.' },

zv_zipper = { label = 'Cierre metálico', weight = 50, stack = true, close = true, description = 'Cierre recuperado de ropa o equipaje.' },

zv_buckle = { label = 'Hebilla', weight = 80, stack = true, close = true, description = 'Hebilla metálica para correas y mochilas.' },

zv_plastic = { label = 'Plástico reciclado', weight = 100, stack = true, close = true, description = 'Plástico procesado, listo para fabricar objetos.' },

zv_glass = { label = 'Vidrio reciclado', weight = 250, stack = true, close = true, description = 'Fragmentos de vidrio procesados.' },

zv_metal = { label = 'Metal reciclado', weight = 400, stack = true, close = true, description = 'Metal recuperado y procesado.' },

zv_copper = { label = 'Cobre recuperado', weight = 120, stack = true, close = true, description = 'Cobre extraído de cables y aparatos.' },

zv_silver = { label = 'Plata recuperada', weight = 50, stack = true, close = true, description = 'Plata en bruto recuperada de objetos.' },

zv_scrap = { label = 'Chatarra', weight = 500, stack = true, close = true, description = 'Material mezclado para reparar o fabricar.' },

zv_metal_scrap = { label = 'Chatarra metálica', weight = 800, stack = true, close = true, description = 'Restos metálicos de vehículo para reciclar o reparar.' },

zv_gold_ingot = { label = 'Lingote de oro', weight = 500, stack = true, close = true, description = 'Oro fundido, valioso para comercio o fabricación.' },

zv_silver_ingot = { label = 'Lingote de plata', weight = 400, stack = true, close = true, description = 'Plata fundida, útil para comercio y crafteo.' },

zv_broken_tv = { label = 'Televisor roto', weight = 200, stack = true, close = true, description = 'Televisor inservible; puede reciclarse.' },

zv_old_jewelry = { label = 'Joyería vieja', weight = 100, stack = true, close = true, description = 'Joyería sin valor estético, con metal recuperable.' },

zv_old_photo = { label = 'Foto antigua', weight = 10, stack = true, close = true, description = 'Una fotografía descolorida de una familia desconocida.' },

zv_empty_wallet = { label = 'Cartera vacía', weight = 80, stack = true, close = true, description = 'Cartera desgastada sin dinero ni documentos.' },

zv_sunglasses = { label = 'Gafas de sol rayadas', weight = 60, stack = true, close = true, description = 'Gafas viejas sin valor práctico.' },

zv_broken_toy = { label = 'Juguete roto', weight = 10, stack = true, close = true, description = 'Juguete abandonado dentro de un vehículo.' },

zv_old_magazine = { label = 'Revista vieja', weight = 20, stack = true, close = true, description = 'Revista anterior al brote zombie.' },

zv_keychain = { label = 'Llavero viejo', weight = 40, stack = true, close = true, description = 'Llavero sin llaves ni utilidad.' },

zv_jumper_cables = { label = 'Cables para batería', weight = 80, stack = true, close = true, description = 'Cables para pasar corriente entre baterías.' },

zv_lug_wrench = { label = 'Llave de cruz', weight = 10, stack = true, close = true, description = 'Herramienta para cambiar llantas.' },

zv_air_filter = { label = 'Filtro de aire usado', weight = 50, stack = true, close = true, description = 'Filtro usado para reparaciones de motor.' },

zv_brake_pads = { label = 'Pastillas de freno', weight = 60, stack = true, close = true, description = 'Pastillas de freno recuperadas.' },

zv_brake_fluid = { label = 'Líquido de frenos', weight = 80, stack = true, close = true, description = 'Recipiente de líquido de frenos.' },

zv_alternator = { label = 'Alternador', weight = 100, stack = true, close = true, description = 'Alternador recuperado de un vehículo.' },

zv_windshield = { label = 'Parabrisas roto', weight = 100, stack = true, close = true, description = 'Parabrisas para reciclar en vidrio.' },

zv_license_plate = { label = 'Placa de vehículo', weight = 30, stack = true, close = true, description = 'Placa vieja sin utilidad.' },

zv_car_keys = { label = 'Llaves de auto', weight = 80, stack = true, close = true, description = 'Juego de llaves encontradas en un vehículo.' },

zv_usb_cable = { label = 'Cable USB', weight = 80, stack = true, close = true, description = 'Cable útil para fabricar dispositivos electrónicos.' },

zv_phone_charger = { label = 'Cargador de teléfono', weight = 180, stack = true, close = true, description = 'Cargador recuperado de un vehículo.' },

zv_powerbank = { label = 'Batería portátil', weight = 300, stack = true, close = true, description = 'Batería portátil para aparatos electrónicos.' },

zv_rope = { label = 'Cuerda resistente', weight = 100, stack = true, close = true, description = 'Cuerda para crafteo y reparaciones.' },

zv_tarp = { label = 'Lona vieja', weight = 20, stack = true, close = true, description = 'Lona resistente para refugios o mochilas.' },

zv_map = { label = 'Mapa viejo', weight = 10, stack = true, close = true, description = 'Mapa antiguo de la ciudad.' },

zv_car_documents = { label = 'Documentos del vehículo', weight = 10, stack = true, close = true, description = 'Documentos encontrados en la guantera.' },

zv_vehicle_manual = { label = 'Manual del vehículo', weight = 20, stack = true, close = true, description = 'Manual deteriorado de un automóvil.' },

dealer_card = { label = 'Dealer Card', weight = 10, stack = false, close = true, description = 'Tarjeta de acceso autorizada para el concesionario de vehículos.' },

zv_gold_coin={label='Moneda de oro',weight=30,stack=true,close=true,description='Moneda antigua de oro; puede fundirse.'},

zv_silver_coin={label='Moneda de plata',weight=25,stack=true,close=true,description='Moneda antigua de plata; puede fundirse.'},

zv_euro_notes={label='Billetes de euro',weight=10,stack=true,close=true,description='Billetes extranjeros encontrados en un viajero.'},

zv_won_notes={label='Billetes de won',weight=10,stack=true,close=true,description='Billetes extranjeros encontrados en un viajero.'},

zv_foreign_coins={label='Monedas extranjeras',weight=50,stack=true,close=true,description='Monedas de distintos países.'},

zv_passport={label='Pasaporte gastado',weight=80,stack=true,close=true,description='Pasaporte encontrado en un zombi viajero.'},

zv_boarding_pass={label='Pase de abordar',weight=10,stack=true,close=true,description='Boleto de avión antiguo.'},

zv_hotel_keycard={label='Tarjeta de hotel',weight=10,stack=true,close=true,description='Tarjeta de acceso de hotel.'},

zv_luggage_tag={label='Etiqueta de equipaje',weight=10,stack=true,close=true,description='Etiqueta encontrada en una maleta.'},

zv_travel_adapter={label='Adaptador de viaje',weight=20,stack=true,close=true,description='Adaptador eléctrico para enchufes extranjeros.'},

zv_foreign_sim={label='SIM extranjera',weight=5,stack=true,close=true,description='Tarjeta SIM de otro país.'},

zv_postcard={label='Postal vieja',weight=10,stack=true,close=true,description='Postal enviada antes del brote.'},

zv_souvenir={label='Recuerdo de viaje',weight=10,stack=true,close=true,description='Pequeño recuerdo de otro país.'},

zv_travel_journal={label='Diario de viaje',weight=10,stack=true,close=true,description='Diario personal de un viajero.'},

zv_compass={label='Brújula',weight=50,stack=true,close=true,description='Brújula vieja para orientación.'},

zv_torn_clothes={label='Ropa rota',weight=30,stack=true,close=true,description='Ropa rota, útil para obtener tela.'},

zv_dirty_rags={label='Trapos sucios',weight=50,stack=true,close=true,description='Trapos recuperables para crafteo.'},

zv_denim_scrap={label='Retazo de mezclilla',weight=50,stack=true,close=true,description='Tela de mezclilla resistente.'},

zv_canvas_scrap={label='Retazo de lona',weight=100,stack=true,close=true,description='Lona resistente para fabricar.'},

zv_pocket_lining={label='Forro de bolsillo',weight=50,stack=true,close=true,description='Forro de tela recuperado.'},

zv_torn_backpack={label='Mochila rota',weight=100,stack=true,close=true,description='Mochila dañada, fuente de materiales.'},

zv_watch_broken={label='Reloj roto',weight=50,stack=true,close=true,description='Reloj averiado con piezas pequeñas.'},

zv_camera_broken={label='Cámara rota',weight=100,stack=true,close=true,description='Cámara dañada para reciclar.'},

zv_lighter_empty={label='Encendedor vacío',weight=50,stack=true,close=true,description='Encendedor sin combustible.'},

zv_pocket_knife_broken={label='Navaja rota',weight=50,stack=true,close=true,description='Navaja rota, útil como chatarra.'},

zv_glasses_case={label='Estuche de gafas',weight=10,stack=true,close=true,description='Estuche vacío de gafas.'},

zv_old_receipt={label='Recibo viejo',weight=5,stack=true,close=true,description='Recibo arrugado sin valor.'},

zv_travel_brochure={label='Folleto de viaje',weight=5,stack=true,close=true,description='Folleto turístico antiguo.'},

raw_pork={label='Carne cruda de cerdo',weight=200},

raw_cat_meat={label='Carne cruda de gato',weight=250},

raw_bird_meat={label='Carne cruda de ave',weight=150},

raw_dog_meat={label='Carne cruda de perro',weight=200},

raw_beef={label='Carne cruda de vaca',weight=300},

raw_venison={label='Carne cruda de venado',weight=300},

raw_mtlion_meat={label='Carne cruda de puma',weight=150},

raw_rabbit_meat={label='Carne cruda de conejo',weight=100},

raw_rat_meat={label='Carne cruda de rata',weight=50},

pig_hide={label='Piel de cerdo',weight=50},

cat_hide={label='Piel de gato',weight=50},

bird_hide={label='Piel y plumas de ave',weight=50},

dog_hide={label='Piel de perro',weight=50},

cow_hide={label='Piel de vaca',weight=80},

deer_hide={label='Piel de venado',weight=50},

mtlion_pelt={label='Piel de puma',weight=50},

rabbit_hide={label='Piel de conejo',weight=20},

rat_pelt={label='Piel de rata',weight=10},

	['manchez3_item'] = {
   label = 'Manchez 3 desplegable',
   weight = 1500,
   stack = false,
   close = true,
   description = 'Despliega una moto Manchez 3 y súbete a ella.',
   client = {
       image = 'manchez3_item.png',
       export = 'qbx_manchez3_item.useVehicleItem',
   }
 },
}
