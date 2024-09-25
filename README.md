### `Reverse Friendly-Fire`
(l4d_reverse_ff) by *_Mystik Spiral_*

Purpose:  
  
Left4Dead(2) SourceMod plugin that reverses friendly-fire...attacker takes damage, victim does not.  
  
  
Objectives:  
  
- Do not allow griefers to cause friendly-fire damage to other players.  
- Incentivize all players to improve their shooting tactics and aim.  
  
  
Description and options:  
  
Reverses friendly-fire weapon damage on survivor team and claw attacks on infected team.  
Does not reverse burn/blast damage, except for grenade launcher (see Suggestion section below).  
Supports client language translation, currently English, French, Spanish, Russian, and Traditional Chinese.  
  
Please note the following for the true(1) / false(0) options below:  
· The victim never takes damage from the attacker.  
· 1 = friendly-fire is reversed for that option and the attacker takes damage.  
· 0 = friendly-fire is disabled for that option and the attacker does not take damage.  
  
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
- Option to specify no ReverseFF based on distance between victim and attacker (0=disable). [reverseff_proximity (default: 32)]  
- Option to enable/disable plugin (0=Plugin off, 1=Plugin on) [reverseff_enable (default=1)]  
- Option to enable/disable plugin by game mode. [reverseff_modes_on, reverseff_modes_off, reverseff_modes_tog]  
- Option to enable/disable plugin announcement (0=Announcement off, 1=Announcement on) [reverseff_announcement (default=1)]  
- Option to display/suppress ReverseFF chat messages (0=Suppress chat messages, 1=Display chat messages) [reverseff_chatmsg (default=1)]
  
  
Want to contribute code enhancements?  
Create a pull request using this GitHub repository: https://github.com/Mystik-Spiral/l4d_reverse_ff  
  
Plugin discussion: https://forums.alliedmods.net/showthread.php?t=329035  
