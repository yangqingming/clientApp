using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityGameFramework.Editor.AssetBundleTools
{
    class SetAssetBundle : IAssetBundleSetting
    {
        public SetAssetBundle()
        {

        }

        public void GetAssetBundleName(SourceAsset source, ref string AssetBundleName, ref string assetBundleVariant)
        {
            string[] folder = source.Folder.FromRootPath.Split('/');
            if (folder[0].CompareTo("LuaScripts") == 0)
            {
                
                AssetBundleName = GameFramework.Utility.Path.GetCombinePath(source.Folder.FromRootPath, "_") + ".folder";//按目录分类

            }
        }

        public void GetAssetBundlePacked(SourceAsset source, ref bool packed)
        {
            string[] folder = source.Folder.FromRootPath.Split('/');

            if (folder[0].CompareTo("LuaScripts") == 0)
            {
                packed = true;
            }
        }
    }
}

