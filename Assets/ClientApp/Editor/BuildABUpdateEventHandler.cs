using GameFramework;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityGameFramework.Editor.AssetBundleTools;

public sealed class BuildABUpdateEventHandler : IBuildEventHandler
{

    /// <summary>
    /// 所有生成开始前的预处理事件。
    /// </summary>
    /// <param name="productName">产品名称。</param>
    /// <param name="companyName">公司名称。</param>
    /// <param name="gameIdentifier">游戏识别号。</param>
    /// <param name="applicableGameVersion">适用游戏版本。</param>
    /// <param name="internalResourceVersion">内部资源版本。</param>
    /// <param name="unityVersion">Unity 版本。</param>
    /// <param name="buildOptions">生成选项。</param>
    /// <param name="zip">是否压缩。</param>
    /// <param name="outputDirectory">生成目录。</param>
    /// <param name="workingPath">生成时的工作路径。</param>
    /// <param name="outputPackagePath">为单机模式生成的文件存放于此路径。若游戏是单机游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    /// <param name="outputFullPath">为可更新模式生成的所有文件存放于此路径。若游戏是网络游戏，生成结束后应将此目录上传至 Web 服务器，供玩家下载用。</param>
    /// <param name="outputPackedPath">为可更新模式生成的文件存放于此路径。若游戏是网络游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    /// <param name="buildReportPath">生成报告路径。</param>
    public void PreProcessBuildAll(string productName, string companyName, string gameIdentifier,
        string applicableGameVersion, int internalResourceVersion, string unityVersion, BuildAssetBundleOptions buildOptions, bool zip,
        string outputDirectory, string workingPath, string outputPackagePath, string outputFullPath, string outputPackedPath, string buildReportPath)
    {

    }

    /// <summary>
    /// 所有生成结束后的后处理事件。
    /// </summary>
    /// <param name="productName">产品名称。</param>
    /// <param name="companyName">公司名称。</param>
    /// <param name="gameIdentifier">游戏识别号。</param>
    /// <param name="applicableGameVersion">适用游戏版本。</param>
    /// <param name="internalResourceVersion">内部资源版本。</param>
    /// <param name="unityVersion">Unity 版本。</param>
    /// <param name="buildOptions">生成选项。</param>
    /// <param name="zip">是否压缩。</param>
    /// <param name="outputDirectory">生成目录。</param>
    /// <param name="workingPath">生成时的工作路径。</param>
    /// <param name="outputPackagePath">为单机模式生成的文件存放于此路径。若游戏是单机游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    /// <param name="outputFullPath">为可更新模式生成的所有文件存放于此路径。若游戏是网络游戏，生成结束后应将此目录上传至 Web 服务器，供玩家下载用。</param>
    /// <param name="outputPackedPath">为可更新模式生成的文件存放于此路径。若游戏是网络游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    /// <param name="buildReportPath">生成报告路径。</param>
    public void PostProcessBuildAll(string productName, string companyName, string gameIdentifier,
        string applicableGameVersion, int internalResourceVersion, string unityVersion, BuildAssetBundleOptions buildOptions, bool zip,
        string outputDirectory, string workingPath, string outputPackagePath, string outputFullPath, string outputPackedPath, string buildReportPath)
    {
        string streamingAssetsPath = Utility.Path.GetCombinePath(Application.dataPath, "StreamingAssets");

        string[] fileNames = Directory.GetFiles(streamingAssetsPath, "*", SearchOption.AllDirectories);

        foreach (string fileName in fileNames)
        {
            if (fileName.Contains(".gitkeep"))
            {
                continue;
            }

            File.Delete(fileName);
        }

        Utility.Path.RemoveEmptyDirectory(streamingAssetsPath);
    }

    /// <summary>
    /// 生成某个平台开始前的预处理事件。
    /// </summary>
    /// <param name="buildTarget">生成平台。</param>
    /// <param name="workingPath">生成时的工作路径。</param>
    /// <param name="outputPackagePath">为单机模式生成的文件存放于此路径。若游戏是单机游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    /// <param name="outputFullPath">为可更新模式生成的所有文件存放于此路径。若游戏是网络游戏，生成结束后应将此目录上传至 Web 服务器，供玩家下载用。</param>
    /// <param name="outputPackedPath">为可更新模式生成的文件存放于此路径。若游戏是网络游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    public void PreProcessBuild(BuildTarget buildTarget, string workingPath, string outputPackagePath, string outputFullPath, string outputPackedPath)
    {

    }

    /// <summary>
    /// 生成某个平台结束后的后处理事件。
    /// </summary>
    /// <param name="buildTarget">生成平台。</param>
    /// <param name="workingPath">生成时的工作路径。</param>
    /// <param name="outputPackagePath">为单机模式生成的文件存放于此路径。若游戏是单机游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    /// <param name="outputFullPath">为可更新模式生成的所有文件存放于此路径。若游戏是网络游戏，生成结束后应将此目录上传至 Web 服务器，供玩家下载用。</param>
    /// <param name="outputPackedPath">为可更新模式生成的文件存放于此路径。若游戏是网络游戏，生成结束后将此目录中对应平台的文件拷贝至 StreamingAssets 后打包 App 即可。</param>
    public void PostProcessBuild(BuildTarget buildTarget, string workingPath, string outputPackagePath, string outputFullPath, string outputPackedPath)
    {
        string streamingAssetsPath = Utility.Path.GetCombinePath(Application.dataPath, "StreamingAssets");

        string[] fileNames = Directory.GetFiles(outputPackedPath, "*", SearchOption.AllDirectories);

        foreach (string fileName in fileNames)
        {
            string destFileName = Utility.Path.GetCombinePath(streamingAssetsPath, fileName.Substring(outputPackagePath.Length));
            FileInfo destFileInfo = new FileInfo(destFileName);
            if (!destFileInfo.Directory.Exists)
            {
                destFileInfo.Directory.Create();
            }

            File.Copy(fileName, destFileName);
        }
    }
}
