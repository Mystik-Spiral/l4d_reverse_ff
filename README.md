### `Reverse Friendly-Fire`
(l4d_reverse_ff) by *_Mystik Spiral_*

Purpose:  
  
Left4Dead(2) SourceMod plugin that reverses friendly-fire.  
The attacker takes all of the damage and the victim takes none.  
  
  
Objectives:  
  
- Do not allow griefers to cause friendly-fire damage to other players.  
- Incentivize all players to improve their shooting tactics and aim.  
  
  
Description and options:  
  
  
Reverses friendly-fire weapon damage for survivors and claw attacks for infected.  
Does not reverse burn/blast damage, except for grenade launcher (see Suggestion section below).  
Supports client language translation, currently English and French.  
  
Please note the following for the true/false options below:  
Regardless of the setting, the victim never takes damage from the attacker.  
True means friendly-fire is reversed for that option and the attacker takes all of the damage.  
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
- Option to specify percentage of damage reversed for survivor (0=min, 2=max). [reverseff_dmgmodifier (default: 1.0=damage unmodified)]  
- Option to specify percentage of damage reversed for infected (0=min, 2=max). [reverseff_dmgmodinfected (default: 1.0=damage unmodified)]  
- Option to specify maximum survivor damage allowed per chapter before kick/ban (0=disable). [reverseff_survivormaxdmg (default: 200)]  
- Option to specify maximum infected damage allowed per chapter before kick/ban (0=disable). [reverseff_infectedmaxdmg (default: 50)]  
- Option to specify maximum tank damage allowed per chapter before kick/ban (0=disable).  [reverseff_tankmaxdmg (default: 300)]  
- Option to specify kick/ban duration in minutes. (0=permanent ban, -1=kick instead of ban). [reverseff_banduration (default: 10)]  
- Option to enable/disable plugin by game mode. [reverseff_modes_on, reverseff_modes_off, reverseff_modes_tog]  
  
  
Suggestion:  
  
To minimize griefer impact, use the Reverse Friendly-Fire plugin along with...  
  
ReverseBurn and ExplosionAnnouncer (l4d_ReverseBurn_and_ExplosionAnnouncer)  
- Smart reverse of burn damage from explodables, like gascans.  
- Option to reverse blast damage, like propane tanks.  
  
ReverseBurn and ThrowableAnnouncer (l4d_ReverseBurn_and_ThrowableAnnouncer)  
- Smart reverse of burn damage from throwables, specifically molotovs.  
- Option to reverse blast damage, like pipe bombs.  
  
When these three plugins are combined, griefers will usually get frustrated and leave since they cannot damage anyone other than themselves.  
Although griefers will take significant damage, other players may not notice any difference in game play (except laughing at stupid griefer fails).  
  
  
Credits:  
  
Chainsaw damage fix by pan0s  
Game modes on/off/tog by Silvers  
  
Want to contribute code enhancements?  
Create a pull request using this GitHub repository: https://github.com/Mystik-Spiral/l4d_reverse_ff  
  
Plugin discussion: https://forums.alliedmods.net/showthread.php?t=329035  
