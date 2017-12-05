using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameFramework.Procedure;
using GameFramework.Resource;
using ProcedureOwner = GameFramework.Fsm.IFsm<GameFramework.Procedure.IProcedureManager>;

public class ProcedureLaunchLuaScripts : ProcedureBase
{

    protected override void OnEnter(ProcedureOwner procedureOwner)
    {
        LoadAssetSuccessCallback success = delegate (string assetName, object asset, float duration, object userData)
        {
            TextAsset text = asset as TextAsset;

            Debug.Log(text.text);

            ClientApp.Resource.UnloadAsset(asset);
        };
        
        ClientApp.Resource.LoadAsset(AssetUtility.GetLuaScriptsPath("main"), new LoadAssetCallbacks(success));
    }

    protected override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds)
    {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

       
    }
}
