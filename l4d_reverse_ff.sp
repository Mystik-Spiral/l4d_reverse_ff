/*

Reverse Friendly-Fire plugin by Mystik Spiral

This plugin reverses all friendly-fire... the attacker takes all of the damage and the victim takes none.
This forces players to be more precise with their shots... or they will spend a lot of time on the ground.
This also discourages griefers/team killers since they can only damage themselves and no one else.

This plugin does not reverse molotov, bomb, or other damage, and I do not intend to add this.

*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[L4D2] Reverse Friendly-Fire",
	author = "Mystic Spiral",
	description = "Team attacker takes friendly-fire damage, victim takes no damage.",
	version = "1.0",
	url = "tbd"
}

public void OnPluginStart()
{
	PrintToServer("\n\nOnPluginStart\n\n");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	PrintToServer("OnClientPutInServer %i", client);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (IsValidClient(attacker) && IsClientInGame(attacker) && GetClientTeam(attacker) == 2)// && !IsClientAdmin(attacker))
	{
		if (IsValidClient(victim) && IsClientInGame(victim) && GetClientTeam(victim) == 2 && victim != attacker)
		{
			int iVictimHealth = GetClientHealth(victim);
			int fVictimTempHealth = GetTempHealth(victim);
			int iAttackerHealth = GetClientHealth(attacker);
			int fAttackerTempHealth = GetTempHealth(attacker);

			PrintToServer("%N attacked %N for %f damage", attacker, victim, damage);
			PrintToServer("Damage Type %i, Weapon %i", damagetype, weapon);
			PrintToServer("  Victim health: %i,   Victim temporary health: %f", iVictimHealth, fVictimTempHealth);
			PrintToServer("Attacker health: %i, Attacker temporary health: %f", iAttackerHealth, fAttackerTempHealth);

			//reduce attacker health (if not an admin)
			if (!IsClientAdmin(attacker))
			{
				PrintToServer("Reduce attacker health");
			}
			//restore victim health
			PrintToServer("Restore victim health");
		}
	}
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients);
}

stock bool IsClientAdmin(int client)
{
    return CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false);
}

public void GetTempHealth(int client)
{
	float decay = GetConVarFloat(FindConVar("pain_pills_decay_rate"));
	float buffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	float time = (GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime"));
	float TempHealth = buffer - (time * decay)
	if (TempHealth < 0) return 0.0;
	else return TempHealth;
}
