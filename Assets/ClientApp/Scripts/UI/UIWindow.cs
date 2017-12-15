using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FairyGUI;

public class UIWindow : Window, IUISource
{
#region IUISource

    public string fileName { get; set; }

    public bool loaded {
        get
        {
            return true;
        }
    }

    public void Load(UILoadCallback callback)
    {
        ClientApp.Resource.LoadAsset(AssetUtility.GetUIBytesPath(fileName), null);
        ClientApp.Resource.LoadAsset(AssetUtility.GetUIBytesPath(fileName), null);
    }
#endregion

    public UIWindow(string fileName)
    {
        this.fileName = fileName;
        AddUISource(this);
    }

    protected override void OnInit()
    {
        base.OnInit();
    }

    protected override void DoShowAnimation()
    {
        base.DoShowAnimation();
    }

    protected override void OnShown()
    {
        base.OnShown();
    }

    protected override void DoHideAnimation()
    {
        base.DoHideAnimation();
    }

    protected override void OnHide()
    {
        base.OnHide();
    }

}
