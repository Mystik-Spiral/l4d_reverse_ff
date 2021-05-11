### `Reverse Friendly-Fire`
(l4d_reverse_ff) by *_Mystik Spiral_*

Left4Dead(2) SourceMod plugin that reverses friendly-fire.  
The attacker takes all of the damage and the victim takes none.  
This forces players to be more precise with their shots or they will spend a lot of time on the ground.

Although this plugin discourages griefers/team killers since they can only damage themselves and no one else...

- The first objective is to force players to improve their shooting tactics and aim.  
- The second objective is to encourage inexperienced players not to join Expert games.

This plugin reverses damage from the grenade launcher, but does not otherwise reverse explosion damage.  
It does not reverse burn/explosion damage (I have a separate plugin for that, see Suggestion section below).  
Reverses friendly-fire for survivors and team attacks for infected.  
Supports language translations using "l4d_reverse_ff.phrases.txt" file.

Please note the following for the true/false options below:  
Regardless of the setting, the victim never takes damage from the attacker.  
True means friendly-fire is reversed for that option and the attacker takes the damage they caused.  
False means friendy-fire is disabled for that option and the attacker does not take any damage.

- Option to ReverseFF when attacker is an admin. [reverseff_admin (default: 0/false)]  
- Option to ReverseFF when victim is a bot. [reverseff_bot (default: 0/false)]  
- Option to ReverseFF when victim is incapacitated. [reverseff_incapped (default: 0/false)]  
- Option to ReverseFF when attacker is incapacitated.  [reverseff_attackerincapped (default: 0/false)]  
- Option to ReverseFF when damage from mounted gun.  [reverseff_mountedgun (default: 1/true)]  
- Option to ReverseFF when damage from melee weapon.  [reverseff_melee (default: 1/true)]  
- Option to ReverseFF when damage from chainsaw.  [reverseff_chainsaw (default: 1/true)]  
- Option to ReverseFF during Smoker pull or Charger carry. [reverseff_pullcarry (default: 0/false)]  
- Option to specify extra damage if attacker used explosive/incendiary ammo. [reverseff_multiplier (default: 1.125 = 12.5%)]  
- Option to specify maximum survivor damage allowed per chapter before kick/ban (0=disable). [reverseff_survivormaxdmg (default: 200)]  
- Option to specify maximum infected damage allowed per chapter before kick/ban (0=disable). [reverseff_infectedmaxdmg (default: 50)]  
- Option to specify maximum tank damage allowed per chapter before kick/ban (0=disable).  [reverseff_tankmaxdmg (default: 300)]  
- Option to specify kick/ban duration in minutes. (0=permanent ban, -1=kick instead of ban). [reverseff_banduration (default: 10)]  
- Option to enable/disable plugin by game mode. [reverseff_modes_on, reverseff_modes_off, reverseff_modes_tog]


Suggestion:

To minimize griefer impact, use this plugin along with...

ReverseBurn and ExplosionAnnouncer (l4d_ReverseBurn_and_ExplosionAnnouncer)  
...and...  
ReverseBurn and ThrowableAnnouncer (l4d_ReverseBurn_and_ThrowableAnnouncer)

When these plugins are combined, griefers cannot inflict friendly-fire or explosion damage, and it minimizes burn damage for victims.  
Although griefers will take significant damage, other players may not notice any difference in game play (other than laughing at stupid griefer fails).


Credits:  
Chainsaw damage bug fixed by pan0s

Want to contribute code enhancements?  
Create a pull request using this GitHub repository: https://github.com/Mystik-Spiral/l4d_reverse_ff

Plugin discussion: https://forums.alliedmods.net/showthread.php?t=329035
