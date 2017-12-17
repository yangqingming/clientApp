using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameFramework.Procedure;
using ProcedureOwner = GameFramework.Fsm.IFsm<GameFramework.Procedure.IProcedureManager>;
using UnityGameFramework.Runtime;
using GameFramework.Resource;
using GameFramework.Event;

public class ProcedureMain : ProcedureBase
{
    protected override void OnEnter(ProcedureOwner procedureOwner)
    {
        base.OnEnter(procedureOwner);

        ClientApp.Event.Subscribe(ShowEntitySuccessEventArgs.EventId, OnShowEntitySuccess);
        ClientApp.Event.Subscribe(ShowEntityFailureEventArgs.EventId, OnShowEntityFail);
        ClientApp.Entity.ShowEntity<MyEntity>(0, AssetUtility.GetModelsPath("chuxinzhe_01"), "Actor", this);
    }

    protected override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds)
    {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        ChangeState<ProcedureLaunchLuaScripts>(procedureOwner);
    }

    void OnShowEntitySuccess(object sender, GameEventArgs e)
    {
        ShowEntitySuccessEventArgs args = e as ShowEntitySuccessEventArgs;

        if (args.UserData != this)
            return;


    }

    void OnShowEntityFail(object sender, GameEventArgs e)
    {
        ShowEntityFailureEventArgs args = e as ShowEntityFailureEventArgs;

        if (args.UserData != this)
            return;
        Debug.LogError("args.ErrorMessage: " + args.ErrorMessage);

    }
}
