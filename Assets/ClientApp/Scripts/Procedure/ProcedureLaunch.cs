﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameFramework.Procedure;
using ProcedureOwner = GameFramework.Fsm.IFsm<GameFramework.Procedure.IProcedureManager>;

public class ProcedureLaunch : ProcedureBase
{

    protected override void OnEnter(ProcedureOwner procedureOwner)
    {

    }

    protected override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds)
    {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);
        if (ClientApp.Base.EditorResourceMode)
        {
            ChangeState<ProcedureLaunchLuaScripts>(procedureOwner);
        }
        else
        {
            if (ClientApp.Resource.ResourceMode == GameFramework.Resource.ResourceMode.Updatable) //更新模式
            {
                ChangeState<ProcedureUpdate>(procedureOwner);
            }
            else if (ClientApp.Resource.ResourceMode == GameFramework.Resource.ResourceMode.Package) //包内模式
            {
                ChangeState<ProcedurePackageInit>(procedureOwner);
            }
        }
        
    }
}
