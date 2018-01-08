using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AssetUtility {
    public static string GetModelsPath(string assetName)
    {
        return string.Format("Assets/ClientApp/BuildResources/Models/Prefabs/{0}.prefab", assetName);
    }

    public static string GetLuaScriptsPath(string assetName)
    {
        return string.Format("Assets/ClientApp/BuildResources/LuaScripts/{0}.lua.txt", assetName);
    }

    public static string GetUIPath(string assetName)
    {
        return string.Format("Assets/ClientApp/BuildResources/UI/Prefabs/{0}.prefab", assetName);
    }

}
