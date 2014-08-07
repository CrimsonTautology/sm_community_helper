/**
 * vim: set ts=4 :
 * =============================================================================
 * Steam Group Invite
 * Allows users to invite other players on the
 * server to invite them to the server's
 * community steam group. 
 * NOTE:  This is not an invite bot, users must
 * still manually invite other players;  this
 * just saves them the trouble of having to
 * find their steam id and tabbing out of the
 * game to invite the player.
 *
 * Copyright 2014 CrimsonTautology
 * =============================================================================
 *
 */

#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "0.1"

public Plugin:myinfo =
{
    name = "Steam Group Inviter",
    author = "CrimsonTautology",
    description = "Allow players to invite other players to your steam group",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/sm_group_invite"
};

#define MAX_STEAMID_LENGTH 21
#define MAX_COMMUNITYID_LENGTH 18 

new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_GroupID = INVALID_HANDLE;

public OnPluginStart()
{
    LoadTranslations("group_invite.phrases");

    g_Cvar_Enabled = CreateConVar("sm_group_invite_enabled", "1", "Enabled");
    g_Cvar_GroupID = CreateConVar("sm_group_invite_group_id", "", "Your Steam Group's ID you wish to invite to");

    RegConsoleCmd("sm_invite", Command_Invite, "Invite player to steam group");
}

public Action:Command_Invite(client, args)
{
    decl String:group_id64[32];
    GetConVarString(g_Cvar_GroupID, group_id64, sizeof(group_id64));

    InvitePopUp(inviter, 0, group_id64);
    return Plugin_Handled;
}

stock bool:GetCommunityIDString(client, String:CommunityID[], const CommunityIDSize) 
{ 
    decl String:SteamID[MAX_STEAMID_LENGTH];
    GetClientAuthString(client, SteamID, sizeof(SteamID));

    decl String:SteamIDParts[3][11]; 
    new const String:Identifier[] = "76561197960265728"; 

    if ((CommunityIDSize < 1) || (ExplodeString(SteamID, ":", SteamIDParts, sizeof(SteamIDParts), sizeof(SteamIDParts[])) != 3)) 
    { 
        CommunityID[0] = '\0'; 
        return false; 
    } 

    new Current, CarryOver = (SteamIDParts[1][0] == '1'); 
    for (new i = (CommunityIDSize - 2), j = (strlen(SteamIDParts[2]) - 1), k = (strlen(Identifier) - 1); i >= 0; i--, j--, k--) 
    { 
        Current = (j >= 0 ? (2 * (SteamIDParts[2][j] - '0')) : 0) + CarryOver + (k >= 0 ? ((Identifier[k] - '0') * 1) : 0); 
        CarryOver = Current / 10; 
        CommunityID[i] = (Current % 10) + '0'; 
    } 

    CommunityID[CommunityIDSize - 1] = '\0'; 
    return true; 
}  

InvitePopUp(inviter, invitee, String:group_id64[])
{
    decl String:inviter_id64[MAX_COMMUNITYID_LENGTH], invitee_id64[MAX_COMMUNITYID_LENGTH], String:base_url[128];
    GetCommunityIDString(inviter, inviter_id64, sizeof(inviter_id64));
    GetCommunityIDString(invitee, invitee_id64, sizeof(invitee_id64));


    Format(url, sizeof(url),
            "http://steamcommunity.com/actions/GroupInvite?type=groupInvite&inviter=%s&invitee=%s&group=%s",
            inviter_id64, invitee_id64, group_id64
          );

    new Handle:panel = CreateKeyValues("data");
    KvSetString(panel, "title", "Steam Inviter");
    KvSetNum(panel, "type", MOTDPANEL_TYPE_URL);
    KvSetString(panel, "msg", url);
    KvSetNum(panel, "customsvr", 1); //Sets motd to be fullscreen

    ShowVGUIPanel(client, "info", panel, true);
    CloseHandle(panel);
}
