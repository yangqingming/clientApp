using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameFramework.Procedure;
using ProcedureOwner = GameFramework.Fsm.IFsm<GameFramework.Procedure.IProcedureManager>;
using UnityGameFramework.Runtime;
using System;
using GameFramework.Event;
using GameComponentExtension;
using System.Xml;

public class ProcedureUpdate : ProcedureBase {

    private int serialId = -1;
    private bool IsDone = false; //更新完毕
    protected override void OnEnter(ProcedureOwner procedureOwner)
    {
        base.OnInit(procedureOwner);

        ClientApp.Event.Subscribe(ResourceCheckCompleteEventArgs.EventId, OnCheckComplete); //检查资源列表完成
        ClientApp.Event.Subscribe(VersionListUpdateSuccessEventArgs.EventId, OnListUpdateSuccess); //更新list成功
        ClientApp.Event.Subscribe(ResourceUpdateChangedEventArgs.EventId, OnResourceUpdateChanged); //更新单个资源进度
        ClientApp.Event.Subscribe(ResourceUpdateSuccessEventArgs.EventId, OnResourceUpdateSuccess); //更新单个资源成功
        ClientApp.Event.Subscribe(ResourceUpdateFailureEventArgs.EventId, OnResourceUpdateFailure); //更新单个资源失败
        ClientApp.Event.Subscribe(ResourceUpdateAllCompleteEventArgs.EventId, OnAllComplete); //全部更新完成

        string ver = Application.version.Replace('.', '_');
        string url = "http://eltsres.gulugames.cn/test/" + "GameResourceVersion_" + ver + ".xml";

        WebRequestEvent _event = new WebRequestEvent
        {
            OnSuccess = delegate (int SerialId, byte[] bytes)
            {
                System.Text.UTF8Encoding code = new System.Text.UTF8Encoding(false);
                bytes = CleanUTF8Bom(bytes);
                string str = code.GetString(bytes);
                Debug.Log(str);
                XmlDocument xml = new XmlDocument();
                xml.LoadXml(str);
                XmlNode node = xml.SelectSingleNode("ResourceVersionInfo");
                XmlAttribute LatestInternalResourceVersionNode = node.Attributes["LatestInternalResourceVersion"];
                int LatestInternalResourceVersion = int.Parse(LatestInternalResourceVersionNode.Value); //内部版本号

                node = node.SelectSingleNode("StandaloneWindows");
                XmlAttribute ZipHashCodeNode = node.Attributes["ZipHashCode"];
                int ZipHashCode = int.Parse(ZipHashCodeNode.Value);

                XmlAttribute ZipLengthNode = node.Attributes["ZipLength"];
                int ZipLength = int.Parse(ZipLengthNode.Value);

                XmlAttribute HashCodeNode = node.Attributes["HashCode"];
                int HashCode = int.Parse(HashCodeNode.Value);

                XmlAttribute LengthNode = node.Attributes["Length"];
                int Length = int.Parse(LengthNode.Value);

                if (ClientApp.Resource.CheckVersionList(LatestInternalResourceVersion) == GameFramework.Resource.CheckVersionListResult.NeedUpdate)
                {
                    ClientApp.Resource.UpdateVersionList(Length, HashCode, ZipLength, ZipHashCode);
                }
                else
                {
                    ClientApp.Resource.CheckResources();
                }
            }
        };
        ClientApp.Resource.UpdatePrefixUri = "http://eltsres.gulugames.cn/test/windows/";
        ClientApp.WebRequest.AddWebRequest(url, _event);
    }

    protected override void OnLeave(ProcedureOwner procedureOwner, bool isShutdown)
    {
        base.OnLeave(procedureOwner, isShutdown);

        ClientApp.Event.Unsubscribe(ResourceCheckCompleteEventArgs.EventId, OnCheckComplete);
        ClientApp.Event.Unsubscribe(VersionListUpdateSuccessEventArgs.EventId, OnListUpdateSuccess);
        ClientApp.Event.Unsubscribe(ResourceUpdateChangedEventArgs.EventId, OnResourceUpdateChanged);
        ClientApp.Event.Unsubscribe(ResourceUpdateSuccessEventArgs.EventId, OnResourceUpdateSuccess);
        ClientApp.Event.Unsubscribe(ResourceUpdateFailureEventArgs.EventId, OnResourceUpdateFailure);
        ClientApp.Event.Unsubscribe(ResourceUpdateAllCompleteEventArgs.EventId, OnAllComplete);
    }

    protected override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds)
    {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        if (IsDone)
            ChangeState<ProcedureMain>(procedureOwner);

    }

    public static byte[] CleanUTF8Bom(byte[] bytes)
    {
        if (bytes.Length > 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF)
        {
            var oldBytes = bytes;
            bytes = new byte[bytes.Length - 3];
            Array.Copy(oldBytes, 3, bytes, 0, bytes.Length);
        }
        return bytes;
    }


    private void OnListUpdateSuccess(object sender, GameEventArgs e)
    {
        VersionListUpdateSuccessEventArgs args = (VersionListUpdateSuccessEventArgs)e;
        ClientApp.Resource.CheckResources();

    }

    private int MaxUpdateCount = 0;
    private int MaxLength = 0;
    private int CurrentLength = 0;
    private void OnCheckComplete(object sender, GameEventArgs e)
    {
        ResourceCheckCompleteEventArgs args = (ResourceCheckCompleteEventArgs)e;
        if (args.UpdateCount == 0)
        { 
            IsDone = true;
            return;
        }
        Debug.Log("需要更新的数量有: " + args.UpdateCount);
        MaxUpdateCount = args.UpdateCount;
        MaxLength = args.UpdateTotalZipLength;
        ClientApp.Resource.UpdateResources();
    }


    private void OnResourceUpdateChanged(object sender, GameEventArgs e)
    {
        ResourceUpdateChangedEventArgs args = (ResourceUpdateChangedEventArgs)e;
        CurrentLength += args.ZipLength;
        Debug.Log("更新进度: " + CurrentLength + "/" + MaxLength + "  百分比: " + (float)CurrentLength / (float)MaxLength);
    }
    private void OnResourceUpdateSuccess(object sender, GameEventArgs e)
    {
        ResourceUpdateSuccessEventArgs args = (ResourceUpdateSuccessEventArgs)e;

        Debug.Log("更新成功: " + args.Name);
    }

    private void OnResourceUpdateFailure(object sender, GameEventArgs e)
    {
        ResourceUpdateFailureEventArgs args = (ResourceUpdateFailureEventArgs)e;

        Debug.Log("更新失败: " + args.Name + "  " + args.ErrorMessage);
    }
    private void OnAllComplete(object sender, GameEventArgs e)
    {
        ResourceUpdateAllCompleteEventArgs args = (ResourceUpdateAllCompleteEventArgs)e;
        
        IsDone = true;
        Debug.Log("更新完毕");
    }

}
