using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AssetUtility {
    public static string GetModelsPath(string assetName)
    {
        return string.Format("Assets/ClientApp/BuildResources/Models/Prefabs/{0}.prefab", assetName);
    }
}
