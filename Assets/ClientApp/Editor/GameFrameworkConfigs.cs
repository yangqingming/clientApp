using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Editor.AssetBundleTools;
public static class GameFrameworkConfigs
{
    //[BuildSettingsConfigPath]
    //public static string BuildSettingsConfig = Utility.Path.GetCombinePath(Application.dataPath, "GameMain/Configs/BuildSettings.xml");

    [AssetBundleBuilderConfigPath]
    public static string AssetBundleBuilderConfig = Application.dataPath + "/ClientApp/Configs/AssetBundleBuilder.xml";

    [AssetBundleEditorConfigPath]
    public static string AssetBundleEditorConfig = Application.dataPath + "/ClientApp/Configs/AssetBundleEditor.xml";

    [AssetBundleCollectionConfigPath]
    public static string AssetBundleCollectionConfig = Application.dataPath + "/ClientApp/Configs/AssetBundleCollection.xml";
}