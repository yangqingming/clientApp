using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Linq;
using System.Text;
public class BuildDLLEditor : MonoBehaviour {

    static string WrapperName = "test.dll";
    [MenuItem("Build/dll")]
    static public void CompileDLL()
    {

        string GenPath = "Assets/_UnityGameFramework/";
        #region scripts
        List <string> scripts = new List<string>();
        string[] guids = AssetDatabase.FindAssets("t:Script", new string[1] { Path.GetDirectoryName(GenPath) }).Distinct().ToArray();
        int guidCount = guids.Length;
        for (int i = 0; i < guidCount; i++)
        {
            // path may contains space
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (!path.Contains("/Editor/"))
            {
                path = "\"" + path + "\"";

                if (!scripts.Contains(path))
                {

                    scripts.Add(path);
                }
            }
        }

        if (scripts.Count == 0)
        {
            Debug.LogError("No Scripts");
            return;
        }
        #endregion

        #region libraries
        List<string> libraries = new List<string>();
#if UNITY_2017_2_OR_NEWER
            string[] referenced = unityModule;
#else
        string[] referenced = new string[] { "UnityEngine", "UnityEngine.UI" };
#endif
        string projectPath = Path.GetFullPath(Application.dataPath + "/..").Replace("\\", "/");
        // http://stackoverflow.com/questions/52797/how-do-i-get-the-path-of-the-assembly-the-code-is-in
        foreach (var assem in AppDomain.CurrentDomain.GetAssemblies())
        {
            UriBuilder uri = new UriBuilder(assem.CodeBase);
            string path = Uri.UnescapeDataString(uri.Path).Replace("\\", "/");
            string name = Path.GetFileNameWithoutExtension(path);
            // ignore dll for Editor
            if ((path.StartsWith(projectPath) && !path.Contains("/Editor/") && !path.Contains("CSharp-Editor"))
                || referenced.Contains(name))
            {
                libraries.Add(path);
            }
        }
        #endregion

        //generate AssemblyInfo
        string AssemblyInfoFile = Application.dataPath + "/AssemblyInfo.cs";
        File.WriteAllText(AssemblyInfoFile, string.Format("[assembly: UnityEngine.UnityAPICompatibilityVersionAttribute(\"{0}\")]", Application.unityVersion));

        #region mono compile            
        string editorData = EditorApplication.applicationContentsPath;
#if UNITY_EDITOR_OSX && !UNITY_5_4_OR_NEWER
			editorData += "/Frameworks";
#endif
        List<string> arg = new List<string>();
        arg.Add("/target:library");
        arg.Add("/sdk:2");
        arg.Add("/w:0");
        arg.Add(string.Format("/out:\"{0}\"", WrapperName));
        arg.Add(string.Format("/r:\"{0}\"", string.Join(";", libraries.ToArray())));
        arg.AddRange(scripts);
        arg.Add(AssemblyInfoFile);

        const string ArgumentFile = "LuaCodeGen.txt";
        File.WriteAllLines(ArgumentFile, arg.ToArray());

        string mcs = editorData + "/MonoBleedingEdge/bin/mcs";
        // wrapping since we may have space
#if UNITY_EDITOR_WIN
        mcs += ".bat";
#endif
        #endregion

        #region execute bash
        StringBuilder output = new StringBuilder();
        StringBuilder error = new StringBuilder();
        bool success = false;
        try
        {
            var process = new System.Diagnostics.Process();
            process.StartInfo.FileName = mcs;
            process.StartInfo.Arguments = "@" + ArgumentFile;
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;

            using (var outputWaitHandle = new System.Threading.AutoResetEvent(false))
            using (var errorWaitHandle = new System.Threading.AutoResetEvent(false))
            {
                process.OutputDataReceived += (sender, e) =>
                {
                    if (e.Data == null)
                    {
                        outputWaitHandle.Set();
                    }
                    else
                    {
                        output.AppendLine(e.Data);
                    }
                };
                process.ErrorDataReceived += (sender, e) =>
                {
                    if (e.Data == null)
                    {
                        errorWaitHandle.Set();
                    }
                    else
                    {
                        error.AppendLine(e.Data);
                    }
                };
                // http://stackoverflow.com/questions/139593/processstartinfo-hanging-on-waitforexit-why
                process.Start();

                process.BeginOutputReadLine();
                process.BeginErrorReadLine();

                const int timeout = 300;
                if (process.WaitForExit(timeout * 1000) &&
                    outputWaitHandle.WaitOne(timeout * 1000) &&
                    errorWaitHandle.WaitOne(timeout * 1000))
                {
                    success = (process.ExitCode == 0);
                }
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex);
        }
        #endregion

        Debug.Log(output.ToString());
        if (success)
        {
            string dllPath = GenPath + "/Libraries";
            if (Directory.Exists(dllPath))
            {
                Directory.Delete(dllPath, true);
            }
            
            Directory.CreateDirectory(dllPath);
            File.Move(WrapperName, dllPath + WrapperName);
            // AssetDatabase.Refresh();
            File.Delete(ArgumentFile);
            File.Delete(AssemblyInfoFile);
        }
        else
        {
            Debug.LogError(error.ToString());
        }
    }
}
