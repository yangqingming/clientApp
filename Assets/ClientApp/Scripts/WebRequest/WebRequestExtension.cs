using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameFramework;
using UnityGameFramework.Runtime;
using GameFramework.Event;

namespace GameComponentExtension
{
    public delegate void WebRequestExtensionStart(int SerialId);
    public delegate void WebRequestExtensionSuccess(int SerialId, byte[] bytes);
    public delegate void WebRequestExtensionFailure(int SerialId, string errorMsg);

    public class WebRequestEvent
    {
        public WebRequestExtensionStart OnStart = null;
        public WebRequestExtensionSuccess OnSuccess = null;
        public WebRequestExtensionFailure OnFailure = null;
    }

    public static class WebRequestExtension
    {
        public static void InitializationExtension(this WebRequestComponent webRequestComponent)
        {
            EventComponent eventComponent = GameEntry.GetComponent<EventComponent>();

            if (eventComponent == null)
            {
                Log.Fatal("Event component is invalid.");
                return;
            }

            eventComponent.Subscribe(WebRequestSuccessEventArgs.EventId, OnWebRequestSuccess);
            eventComponent.Subscribe(WebRequestFailureEventArgs.EventId, OnWebRequestFailure);
            eventComponent.Subscribe(WebRequestStartEventArgs.EventId, OnWebRequestStart);
        }

#region 监听web请求事件
        private static void OnWebRequestSuccess(object sender, GameEventArgs e)
        {
            WebRequestSuccessEventArgs args = (WebRequestSuccessEventArgs)e;

            WebRequestEvent webRequestEvent = args.UserData as WebRequestEvent;
            if (webRequestEvent == null)
                return;

            if (webRequestEvent.OnSuccess != null)
                webRequestEvent.OnSuccess(args.SerialId, args.GetWebResponseBytes());
        }

        private static void OnWebRequestStart(object sender, GameEventArgs e)
        {
            WebRequestStartEventArgs args = (WebRequestStartEventArgs)e;

            WebRequestEvent webRequestEvent = args.UserData as WebRequestEvent;
            if (webRequestEvent == null)
                return;


            if (webRequestEvent.OnStart != null)
                webRequestEvent.OnStart(args.SerialId);
        }

        private static void OnWebRequestFailure(object sender, GameEventArgs e)
        {
            WebRequestFailureEventArgs args = (WebRequestFailureEventArgs)e;
            WebRequestEvent webRequestEvent = args.UserData as WebRequestEvent;
            if (webRequestEvent == null)
                return;

            if (webRequestEvent.OnFailure != null)
                webRequestEvent.OnFailure(args.SerialId, args.ErrorMessage);
        }
#endregion
    }

}
