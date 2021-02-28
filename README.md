### `Reverse Friendly-Fire`
(l4d_reverse_ff) by *_Mystik Spiral_*

Left4Dead(2) SourceMod plugin that reverses friendly-fire.  
The attacker takes all of the damage and the victim takes none.  
This forces players to be more precise with their shots or they will spend a lot of time on the ground.

Although this plugin discourages griefers/team killers since they can only damage themselves and no one else...

- The first objective is to force players to improve their shooting tactics and aim.

- The second objective is to encourage new/inexperienced players to only join games with a difficulty that match their skillset.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse explosion damage.  
It does not reverse molotov/gascan damage (I plan to make a separate plugin to handle that).  
Reverses friendly-fire for survivors and team attacks for infected.  
Supports language translations using "l4d_reverse_ff_phrases.txt" file.  

- Option to ReverseFF if attacker is admin. [reverseff_admin (default: false)]
- Option to ReverseFF when victim is a bot. [reverseff_bot (default: false)]
- Option to ReverseFF when victim is incapacitated. [reverseff_incapped (default: false)]
- Option to specify extra damage if attacker used explosive/incendiary ammo. [reverseff_multiplier (default: 1.125 = 12.5%)]
- Option to specify maximum survivor damage allowed per chapter before kick/ban. [reverseff_survivormaxdmg (default: 200)]
- Option to specify maximum infected damage allowed per chapter before kick/ban. [reverseff_infectedmaxdmg (default: 50)]
- Option to specify maximum tank damage allowed per chapter before kick/ban.  [reverseff_tankdmg (default: 300)]
- Option to specify kick/ban duration in minutes. (0=permanent, -1=kick). [reverseff_banduration (default: 10)]
- Option to treat ReverseFF as self-damage. (or reverse accusations). [reverseff_self (default: false)]
- Option to enable/disable plugin by game mode. [reverseff_modes_on, reverseff_modes_off, reverseff_modes_tog]

Want to contribute code enhancements?  
Create a pull request using this GitHub repository: https://github.com/Mystik-Spiral/l4d_reverse_ff

Plugin discussion: https://forums.alliedmods.net/showthread.php?t=329035
