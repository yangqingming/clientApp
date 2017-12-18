using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace UnityGameFramework.Editor.AssetBundleTools
{
    class SetAssetBundle : IAssetBundleSetting
    {

        Dictionary<string, int> refCount = new Dictionary<string, int>();

        void addRef(string path)
        {
            if (!refCount.ContainsKey(path))
            {
                refCount.Add(path, 1);
            }
            else
                refCount[path] += 1;
        }

        int GetRef(string path)
        {
            if (!refCount.ContainsKey(path))
                return 0;
            return refCount[path];
        }

        public SetAssetBundle()
        {
            string[] files = Directory.GetFiles(GameFramework.Utility.Path.GetCombinePath(Application.dataPath, "ClientApp/BuildResources"), "*.prefab", SearchOption.AllDirectories);

            for (int i = 0; i < files.Length; ++i)
            {
                string file = files[i];

                string resFolder = "Assets/";
                int pos = file.IndexOf(resFolder);
                string assetpath = file.Substring(pos);

                string[] depends = AssetDatabase.GetDependencies(assetpath);
                for (int j = 0; j < depends.Length; ++j)
                {
                    addRef(depends[j]);
                }
            }
        }

        public void GetAssetBundleName(SourceAsset source, ref string AssetBundleName, ref string assetBundleVariant)
        {
            string[] folder = source.Folder.FromRootPath.Split('/');
            if (folder[0].CompareTo("LuaScripts") == 0)
            {
                AssetBundleName = GameFramework.Utility.Path.GetCombinePath(source.Folder.FromRootPath, "_") + ".folder";//按目录分类
            }
            else if (folder[0].CompareTo("UI") == 0)
            {
                string Extension = Path.GetExtension(source.FromRootPath);
                int dotIndex = source.FromRootPath.IndexOf('.');
                string assetBundleName = dotIndex > 0 ? source.FromRootPath.Substring(0, dotIndex) : source.FromRootPath;
                string[] names = assetBundleName.Split('@');
                AssetBundleName = names[0] + Extension;
            }
            else if (folder[0].CompareTo("Models") == 0)
            {
                string Extension = Path.GetExtension(source.FromRootPath);
                if (Extension.ToLower().CompareTo(".fbx") == 0 || Extension.ToLower().CompareTo(".mat") == 0)
                {
                    int count = GetRef(source.Path);
                    if (count > 1)
                    {
                        int dotIndex = source.FromRootPath.IndexOf('.');
                        string assetBundleName = dotIndex > 0 ? source.FromRootPath.Substring(0, dotIndex) : source.FromRootPath;
                        string[] names = assetBundleName.Split('@');
                        AssetBundleName = names[0] + Extension;
                    }
                    else
                        AssetBundleName = null;
                }
                else if(Extension.ToLower().CompareTo(".prefab") != 0)
                    AssetBundleName = null;
            }
        }

        public void OnFinished(UnityGameFramework.Editor.AssetBundleTools.AssetBundle[] assetBundles)
        {

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

