using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameFramework.Procedure;
using GameFramework.Event;
using ProcedureOwner = GameFramework.Fsm.IFsm<GameFramework.Procedure.IProcedureManager>;
using UnityGameFramework.Runtime;

public class ProcedurePackageInit : ProcedureBase
{
    bool isDone = false;
    protected override void OnEnter(ProcedureOwner procedureOwner)
    {
        base.OnEnter(procedureOwner);

        ClientApp.Event.Subscribe(ResourceInitCompleteEventArgs.EventId, InitResourcesComplete);

        ClientApp.Resource.InitResources();
        
    }

    protected override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds)
    {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);
        if (isDone)
        {
            ChangeState<ProcedureMain>(procedureOwner);
        }
    }

    private void InitResourcesComplete(object sender, GameEventArgs e)
    {
        ResourceInitCompleteEventArgs args = e as ResourceInitCompleteEventArgs;

        isDone = true;
    }

    protected override void OnLeave(ProcedureOwner procedureOwner, bool isShutdown)
    {
        base.OnLeave(procedureOwner, isShutdown);

        ClientApp.Event.Unsubscribe(ResourceInitCompleteEventArgs.EventId, InitResourcesComplete);
    }
}
