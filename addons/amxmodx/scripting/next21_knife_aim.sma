#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>


new bot_check=false;
#define TASK_REGBOT	9876

#define KNIFE_CHECKDIST	64


// AMXX
public plugin_init()
{
	register_plugin("Knife Aim","1.0","Chrescoe1 (Next21.ru)");

	RegisterHam(Ham_TraceAttack,"player","HookHam_TraceAttack");
}

public client_connect(id)
{
	if(!bot_check && is_user_bot(id))
	{
		bot_check=true;
		set_task(1.0,"register_bot",TASK_REGBOT+id);
	}
}

// Try register bot entity
public register_bot(taskid){
	
	// botid = taskid-taskkey*
	new botid=taskid-TASK_REGBOT;
	
	if(is_user_connected(botid)&&is_user_bot(botid))
	{
		RegisterHamFromEntity(Ham_TraceAttack,botid,"HookHam_TraceAttack");
	}
	else 
		bot_check=false;	// mission failed ???
}


// HAMSANDWICH
public HookHam_TraceAttack(const iVictim,const iAttacker,const Float:fDamage,const Float:vDir[3],const iTraceId,const DMG_BYTES){
	
	if(!is_user_connected(iAttacker)||get_user_weapon(iAttacker)!=CSW_KNIFE)
		return HAM_IGNORED;
	
	
	static Float:vOrigin[3];
	pev(iAttacker,pev_origin,vOrigin);

	static Float:vOfs[3];
	pev(iAttacker,pev_view_ofs,vOfs);
	
	
	// Set in vOrigin user GunPosition
	vOrigin[0]+=vOfs[0];
	vOrigin[1]+=vOfs[1];
	vOrigin[2]+=vOfs[2];

	
	static Float:vFow[3];
	velocity_by_aim(iAttacker,KNIFE_CHECKDIST,vFow);	// with other functions vAngles work incorrect by Z' ?
	
	// And lets check forward
	vFow[0]+=vOrigin[0];
	vFow[1]+=vOrigin[1];
	vFow[2]+=vOrigin[2];
	
	static iNewTrace;
	iNewTrace=create_tr2();

	
	// Trace from GumPosition to forward by aim
	engfunc(EngFunc_TraceLine,vOrigin,vFow,DONT_IGNORE_MONSTERS,iAttacker,iNewTrace);

	// If hitgroup by aim - set it as main in hitgroup
	new iNewHitGroup=get_tr2(iNewTrace,TR_iHitgroup);
	if(get_tr2(iNewTrace,TR_pHit)==iVictim && iNewHitGroup!=HIT_GENERIC)
	{
		set_tr2(iTraceId,TR_iHitgroup,iNewHitGroup);
	}
	
	free_tr2(iNewTrace);
	
	return HAM_IGNORED;
}