using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class ClientApp
{

    public static LuaComponent Lua
    {
        get;
        private set;
    }

    void InitGameComponentCustom()
    {
        Lua = UnityGameFramework.Runtime.GameEntry.GetComponent<LuaComponent>();
    }
}