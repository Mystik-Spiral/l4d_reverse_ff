---
> ### `Reverse Friendly-Fire` <sub>(l4d_reverse_ff) by</sub> ***Mystik Spiral***
>
> - Reverses friendly-fire.
> - Attacker takes damage, victim does not.
---  

#### `Objectives`:<br />

- Do not allow griefers to cause friendly-fire damage to other players.<br />
- Incentivize all players to improve their shooting tactics and aim.<br /><br />

#### `Description`:<br />

- Reverses friendly-fire weapon damage on survivor team and claw attacks on infected team.<br />
- Does not reverse burn/blast damage, except for grenade launcher and incendiary/explosive ammo.<br />
- Supports client language translation: English, French, Spanish, Russian, and Traditional Chinese.<br /><br />

#### `Options for the true(1) / false(0) parameters below`:<br />

- 1: Friendly-fire is reversed for that option and the attacker takes damage.<br />
- 0: Friendly-fire is disabled for that option and the attacker does not take damage.<br />
- **The victim does not take damage from the attacker regardless of the setting**.<br /><br />
  - ReverseFF when attacker is an admin. \[reverseff_admin (default: 0)]
  - ReverseFF when victim is a bot. \[reverseff_bot default: 0)]
  - ReverseFF when victim is incapacitated. \[reverseff_incapped (default: 0)]
  - ReverseFF when attacker is incapacitated.  \[reverseff_attackerincapped (default: 0)]
  - ReverseFF when damage from mounted gun.  \[reverseff_mountedgun (default: 1)]
  - ReverseFF when damage from melee weapon.  \[reverseff_melee (default: 1)]
  - ReverseFF when damage from chainsaw.  \[reverseff_chainsaw (default: 1)]
  - ReverseFF during Smoker pull or Charger carry. \[reverseff_pullcarry (default: 0)]<br /><br />

#### `Options for the damage modifier parameters below`:<br />

- Range: 0.0 - 2.0<br />
- 0.0 = disabled<br />
- 0.1 = 10% of real damage<br />
- 0.5 = 50% of real damage<br />
- 1.0 = 100% of real damage<br />
- 1.125 = 112.5% of real damage (12.5% extra damage)<br />
- 2.0 = 200% of real damage<br /><br />
  - Infected attacker damage. \[reverseff_dmgmodinfected (default: 1.0)]<br />
  - Survivor attacker damage. \[reverseff_dmgmodifier (default: 1.0)]<br />
  - Survivor bot victim damage. \[reverseff_botdmgmodifier (default=0.0)]<br />
  - Survivor human victim damage. \[reverseff_humandmgmodifier (default=0.0)]<br />
  - Extra damage when using explosive/incendiary ammo. \[reverseff_multiplier (default: 1.125)]<br /><br />
  
#### `Additional parameters`:<br />

- Kick/ban duration in minutes. (0=permanent ban, -1=kick instead of ban). \[reverseff_banduration (default: 10)]<br />
- Maximum survivor damage allowed per chapter before kick/ban (0=disable). \[reverseff_survivormaxdmg (default: 200)]<br />
- Maximum infected damage allowed per chapter before kick/ban (0=disable). \[reverseff_infectedmaxdmg (default: 50)]<br />
- Maximum tank damage allowed per chapter before kick/ban (0=disable).  \[reverseff_tankmaxdmg (default: 300)]<br />
- ReverseFF based on distance between victim and attacker (0=disable). \[reverseff_proximity (default: 32)]<br />
- Enable/disable plugin (0=Plugin off, 1=Plugin on) \[reverseff_enable (default=1)]<br />
- Enable/disable plugin by game mode. \[reverseff_modes_on, reverseff_modes_off, reverseff_modes_tog]<br />
- Enable/disable plugin announcement (0=Announcement off, 1=Announcement on) \[reverseff_announcement (default=1)]<br />
- Display/suppress ReverseFF chat messages (0=Suppress chat messages, 1=Display chat messages) \[reverseff_chatmsg (default=1)]<br /><br />

#### `Code / Discussion`:<br />

[GitHub](https://github.com/Mystik-Spiral/l4d_reverse_ff)<br />
[AlliedModders](https://forums.alliedmods.net/showthread.php?t=329035)<br /><br />
