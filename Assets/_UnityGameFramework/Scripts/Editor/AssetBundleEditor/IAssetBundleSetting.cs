using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Editor.AssetBundleTools;

interface IAssetBundleSetting
{
    //设置assetbundle名字归类
    void GetAssetBundleName(SourceAsset source, ref string AssetBundleName, ref string assetBundleVariant);
    //设置资源在更新模式下是否在包内
    void GetAssetBundlePacked(SourceAsset source, ref bool packed);
}