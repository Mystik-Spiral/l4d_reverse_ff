#### Reverse Friendly-Fire (l4d_reverse_ff) by Mystik Spiral

This Left4Dead2 SourceMod plugin reverses friendly-fire... the attacker takes all of the damage and the victim takes none.
This forces players to be more precise with their shots... or they will spend a lot of time on the ground.

Although this plugin discourages griefers/team killers since they can only damage themselves and no one else, the first objective is to force players to improve their shooting tactics and aim. The second objective is to encourage new/inexperienced players to only join games with a difficulty that match their skillset, rather than trying to play at a difficulty above their ability and constantly incapping their teammates.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse explosion damage.
This plugin does not reverse molotov/gascan damage and I do not intend to add it, though I may make a separate plugin to handle molotov/gascan damage. Now reverses "friendly-fire" for infected team too.

- Option to specify extra damage if attacker used explosive/incendiary ammo. [reverseff_multiplier (default: 1.125 = 12.5%)]
- Option to give admin attacker immunity from reverse friendly-fire. [reverseff_immunity (default: true)]
- Option to reverse friendly-fire when victim is a bot. [reverseff_bot (default: false)]
- Option to reverse friendly-fire when victim is incapacitated. [reverseff_incapped (default: false)]
- Option to specify maximum survivor damage allowed per chapter before kick/ban. [reverseff_survivormaxdmg (default: 180)]
- Option to specify maximum infected damage allowed per chapter before kick/ban. [reverseff_infectedmaxdmg (default: 110)]
- Option to specify kick/ban duration in minutes (0=permanent, -1=kick). [reverseff_banduration (default: 10)]
- Option to treat friendly-fire as self-damage (or reverse accusations). [reverseff_self (default: false)]

Plugin discussion: https://forums.alliedmods.net/showthread.php?t=329035
