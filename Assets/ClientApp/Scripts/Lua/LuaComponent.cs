using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;
using XLua;

public class LuaComponent : GameFrameworkComponent
{
    LuaEnv luaEnv = null;
    protected override void Awake()
    {
        base.Awake();
        luaEnv = new LuaEnv();

        luaEnv.customLoaders.Add(customLoader);
    }

    private byte[] customLoader(ref string filepath)
    {
        return null;
    }

    private void OnDestroy()
    {
        luaEnv.Dispose();
    }

    public void Dispose()
    {
        if (luaEnv != null)
        {
            luaEnv.Dispose();
            luaEnv = null;
        }
    }
}
