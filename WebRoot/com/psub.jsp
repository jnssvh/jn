<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@page import="com.jaguar.Config"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
//<script type="text/javascript">
var gRootPath = "<%=Config.getItem("ContextPath") %>";
var oFocus; 
var psubdir = GetWebDir("psub.jsp");

// Electron lxt 2017.5.26
window.g_isElectron=window.navigator.userAgent.indexOf("Electron")>-1;
if(window.g_isElectron){
	open=top.open;
	showModalDialog=top.showModalDialog;
	confirm=top.confirm;
	alert=top.alert;
	close=top.close;
	if(!gRootPath) gRootPath="/";
	if(gRootPath.indexOf("http")!=0)
	gRootPath=location.protocol+"//"+location.hostname+gRootPath;
} 
window.g_isChrome=window.navigator.userAgent.indexOf("Chrome")>-1;
if(window.g_isChrome && !window.g_isElectron){
	window.showModalDialog=function(a, b, c){
		var w=parseInt(c.replace(/.*dialogWidth[:=]([^;]+);.*/, "$1").replace("px",""));
		var h=parseInt(c.replace(/.*dialogHeight[:=]([^;]+);.*/, "$1").replace("px",""));
		if(isNaN(w)) w=screen.availWidth/2;
		if(isNaN(h)) h=screen.availHeight/2;
		c='height='+h+', width='+w+', top='+(screen.availHeight-h)/2+', left='+(screen.availWidth-w)/2+', toolbar=no,menubar=no,scrollbars=no,resizable=yes,location=no,status=no';
		return top.open(a, b, c, true);
	};
}


function getEvent()     //同时兼容ie和ff的写法
{
	if(document.all)
		return window.event;
	for (var f = getEvent.caller; f != null; f = f.caller)
	{
		var e = f.arguments[0];
		if(e && ((e.constructor == Event || e.constructor == MouseEvent)
				 || (typeof e == "object" && e.preventDefault && e.stopPropagation)))
		{
				e.srcElement = e.target;
				return e;
		}
	}
	return null;
}

function idobj(id, d)
{
	if (typeof d != "object" && d == null)
		d = document;
	var objx=d.getElementById(id);
	if(objx==undefined) objx=d.getElementsByName(id)[0];
	return objx;
}

function objattr(obj, attr, value)
{
	if (typeof value == "undefined")
		return obj.getAttribute(attr);
	if (value == null)
		obj.removeAttribute(attr);
	else
		obj.setAttribute(attr, value);
}

function objcss(obj, css)
{
	for (var key in css)
		obj.style[key] = css[key];
}

function objall(obj, id)
{
	var tag = "*";
	if (typeof obj == "string")
		tag = obj;
	if (typeof obj != "object")
		obj = document;
	var all = obj.getElementsByTagName(tag);
	if (typeof id != "string")
		return all;
	var objs = [];
	for (var x = 0; x < all.length; x++)
	{
		if ((all[x].id == id) || (all[x].name == id))
			objs[objs.length] = all[x];
	}
	if (objs.length > 1)
		return objs;
	if (objs.length == 1)
		return objs[0];
	return null;
}

function objsbyname(id, tag, obj)
{
	if (typeof tag != "string")
		tag = "*";
	if (typeof obj != "object")
		obj = document;
	var all = obj.getElementsByTagName(tag);
	if (typeof id != "string")
		return all;
	var objs = [];
	for (var x = 0; x < all.length; x++)
	{
		if ((all[x].id == id) || (all[x].name == id))
			objs[objs.length] = all[x];
	}
	return objs;
}

function objevent(obj, evt, fun, removeflag)
{
	if (obj == null) {
		return;
	}
	if (window.attachEvent)
	{
		if (removeflag == 1)
			obj.detachEvent("on" + evt, fun);
		else
			obj.attachEvent("on" + evt, fun); 
	}
	else if (window.addEventListener)
	{ 
		if (removeflag == 1)
			document.removeEventListener(evt, fun,true);
  		else
			obj.addEventListener(evt, fun, false);   
	}
}

function fireobjevt(obj, evt)
{
	if(obj.fireEvent)
    	obj.fireEvent("on" + evt);
	else
	{
		var e = document.createEvent("HTMLEvents");
		e.initEvent(evt,true,true);
		obj.dispatchEvent(e);
	}
}

function objtext(obj, text)
{
	if (typeof text == "undefined")
	{
		if (typeof obj.innerText != "undefined")
			return obj.innerText;
		return obj.textContent;
	}
	else
	{
		if (typeof obj.innerText != "undefined")
			obj.innerText = text;
		else
			obj.textContent = text;
     }
 }

function objstyle(obj, style)
{
	if (typeof obj.currentStyle == "object")
		return obj.currentStyle[style];
	else
		return window.getComputedStyle(obj,null).getPropertyValue(style);
}

function GetWebDir(jsname)
{
	var s = document.getElementsByTagName("SCRIPT");
	for (var x = 0; x < s.length; x++)
	{
		if (new RegExp(jsname + "$", "i").test(s[x].src))
			return s[x].src.substr(0, s[x].src.length - jsname.length);
	}
	return "";
}

function GetRootPath()
{
	var href = location.protocol + "//" + location.hostname + "/";
	if (location.port != "")
		href = location.protocol + "//" + location.hostname + ":" + location.port + "/";
	var ss = location.pathname.split("/");
	// w3c lxt 2017.11.13
	var isChrome=navigator.userAgent.indexOf("Chrome");
	if (psubdir.substr(0, 3) == "../" || (isChrome&&psubdir.indexOf("http")==0) )
		href += ss[ss.length - 3];
	else 
		href += ss[ss.length - 2];
	return href;
}

function SelectObj(obj, bclr, fclr, border, flag)
{
	if (typeof bclr == "undefined")
		return SelObject(obj);
	if ((typeof(bclr) == "undefined") || (bclr == ""))
		bclr = "navy";
	if ((typeof(fclr) == "undefined") || (fclr == ""))
		fclr = "white";
		
	if (typeof(oFocus) == "object")
	{
		oFocus.style.backgroundColor = oFocus.getAttribute("oldbclr");
		oFocus.style.color = oFocus.getAttribute("oldfclr");
		if (typeof(oFocus.getAttribute("oldborder")) == "string")
			oFocus.style.border = oFocus.getAttribute("oldborder");
		var all = objall(oFocus);
		for (var x = 0; x < all.length; x++)
		{
			if (typeof(all[x].getAttribute("oldcolor")) != "undefined")
				all[x].style.color = all[x].getAttribute("oldcolor");
		}
	}
	oFocus = obj;
	if (typeof(oFocus) != "object")
		return;
//	if (typeof oFocus.node == "undefined")
//		HTMLElement.prototype.node = objattr(oFocus, "node");
	fireobjevt(obj, "mouseout");
	oFocus.setAttribute("oldbclr", oFocus.style.backgroundColor);
	oFocus.setAttribute("oldfclr", oFocus.style.color);
	oFocus.style.backgroundColor = bclr;
	oFocus.style.color = fclr;
	if (flag == 1)
	{
		var all = objall(oFocus);
		for (var x = 0; x < all.length; x++)
		{
			all[x].setAttribute("oldcolor", all[x].style.color);
			all[x].style.color = fclr;
		}
	}		
	if ((typeof(border) == "string") && (border != ""))
	{
		oFocus.setAttribute("oldborder", oFocus.style.border);
		oFocus.style.border = border;
	}
	if (event != null)
		event.cancelBubble = true;
}

function SelObject(obj, classname)
{
	if (typeof(oFocus) == "object") {
		oFocus.className = oFocus.getAttribute("className0")==undefined?"":oFocus.getAttribute("className0");
	}
	oFocus = obj;
	if (typeof(oFocus) != "object")
		return;
//	if (typeof oFocus.node == "undefined")
//		HTMLElement.prototype.node = objattr(oFocus, "node");
	if (typeof(classname) == "undefined")
		classname = "SelectObj";
	oFocus.setAttribute("className0", oFocus.className);
	oFocus.className = classname;	
	if (typeof(oRollObj) == "object")
		oRollObj = 0;
}

function FormatObjvalue(objf, obj)
{
	if (obj == null || typeof obj != "object")
		return objf;
	for (var key in objf)
	{
		if (typeof obj[key] == "undefined")
			obj[key] = objf[key];
	}
	return obj
}

function GoHref(href)
{
	location.href = href;	
}

function ParentHref(href, target)
{
	parent.location.href = href;
}

function GetChar(ch, n)
{
	var str = "";
	for (var x = 0; x < n; x++)
		str += ch;
	return str;
}

function NewInlineWindow(href, sFeatures, sName, nReplace)
{
var objs;
	var evt = getEvent();
	if (nReplace == 2)
	{
		if (evt.shiftKey)
			nReplace = 0;
		else
			nReplace = 1;
	}
	if (nReplace == 1)
	{
		objs = document.getElementsByName("InLineWinTable");
		if (objs.length > 0)
		{
			objall(objs[objs.length - 1], "WinTitle").innerHTML = sName;
			objall(objs[objs.length - 1], "ContentFrame").src = href;
		}
		else
			nReplace = 0;
	}
	if (nReplace == 0)
	{
		document.body.insertAdjacentHTML("beforeEnd", "<table id=InLineWinTable cellpadding=0 cellspacing=0 " +
			"onmousedown=BeginDragObj(this) onmousemove=ResizeCursorObj(this) border=0 " +
			"style='cursor:hand;position:absolute;left:200px;top:100px;width:640px;height:480px;table-layout:fixed;'>" +
			"<tr height=23 style=cursor:hand;><td width=5><img src=" + psubdir + "pic/tbl.gif></td>" +
			"<td width=100% nowrap style='background:url(" + psubdir + "pic/tbc.bmp) repeat-x;'><b id=WinTitle>" + sName + 
			"</b></td><td align=right width=14 style='background:url(" + psubdir + "pic/tbc.bmp) repeat-x;'>" +
			"<span style='width:14px;height:14px;background:url(" + psubdir + "pic/btrect.gif);padding-top:1px;'>" +
			"<img src=" + psubdir + "pic/closewin.gif onclick=CloseInlineWindow(this)></span></td>" +
			"<td width=5><img src=" + psubdir + "pic/tbr.gif></td></tr>" +
			"<tr height=100%><td colspan=4 style='border-left:1px solid gray;border-right:1px solid gray;'>" +
			"<iframe id=ContentFrame src='" + href + "' width=100% height=100% frameborder=0></iframe></td></tr>" +
			"<tr height=23><td colspan=4 bgcolor=white style='border-left:1px solid gray;border-right:1px solid gray;border-bottom:1px solid gray;padding:2px;'>" +
			"<span style='width:100%;height:100%;background:url(" + psubdir + "pic/winb.gif) no-repeat bottom right;'>" +
			"</span></td></tr></table>");
		objs = document.getElementsByName("InLineWinTable");
	}
	if (objs.length > 0)
	{
		BeginDragObj(objs[objs.length - 1]);
		EndDragObj(objs[objs.length - 1]);
	}
}

function CloseInlineWindow(obj)
{
	obj.parentNode.parentNode.parentNode.parentNode.parentNode.removeNode(true);
}

function NewWindow(href, sFeatures, sName)
{
	if (typeof(sName) == "undefined")
		sName = "_blank";
	return window.open("/go.asp?href=" + escape(href), sName, sFeatures);
}

function CloseWin(w)
{
	if (typeof(w) == "undefined")
		w = window;
	if (IsNetBoxRunning())
		return w.external.close();
	else
		return w.close();
}

function NewNBWin(href, sFeatures, sName, argument)
{
	if (typeof(sName) != "string")
		sName = "_blank";
	href = CheckHref(href);

	var NetBox = new ActiveXObject("NetBox");
	for (var x = NetBox("HTMLWin_Dict").Count - 1; x >= 0; x--)
	{
		if (NetBox("HTMLWin_Dict")(NetBox("HTMLWin_Dict").Key(x)).isClosed())
			NetBox("HTMLWin_Dict").Remove(NetBox("HTMLWin_Dict").Key(x));
	}
	if ((sName != "_blank") && (sName != ""))
	{
		if (typeof(NetBox("HTMLWin_Dict")(sName)) == "object")
		{
			if (NetBox("HTMLWin_Dict")(sName).isClosed() == false)
			{
				window.setTimeout(function()
				{
					if (NetBox("HTMLWin_Dict")(sName).Visible == false)
						NetBox("HTMLWin_Dict")(sName).Visible = true;
					if (NetBox("HTMLWin_Dict")(sName).Minimized == true)
						NetBox("HTMLWin_Dict")(sName).Minimized = false;
					NetBox("HTMLWin_Dict")(sName).focus();
					try {
						NetBox("HTMLWin_Dict")(sName).Browser.Document.body.fireEvent("onactivate");
					} catch (e) {}
				}, 10);
				return NetBox("HTMLWin_Dict")(sName);
			}
		}
	}

	var hwd = new ActiveXObject("NetBox.HtmlWindow");
	if ((sName != "_blank") && (sName != ""))
		NetBox("HTMLWin_Dict").Add(sName, hwd);
	else
		NetBox("HTMLWin_Dict").Add("win" + hwd.HWND, hwd);
	hwd.scrollbar = false;
	hwd.Width = 800;
	hwd.Height = 600;
	hwd.ContextMenu = false;
	hwd.center();
//	hwd.Icon = "netbox:/pic/JoFo16.gif"
	var visible = SetNetBoxHTMLWindow(hwd, sFeatures);
	hwd.open(href, argument);
	if (visible)
	{
		hwd.Visible = true;
		hwd.focus();
		var Shell = new ActiveXObject("Shell");
		Shell.DoEvents();
	}
	hwd.Browser.PutProperty("HTMLWinParent", window);
	return hwd;
}

function NewNBUserWin(href, sFeatures, sName, nStyle, argument, bdlg)
{
var tag;
	if (typeof sFeatures == "string")
		sFeatures = sFeatures.replace(/scrollbars=.+,/g, "");
	var hwd = NewNBWin("about:blank", sFeatures, sName, argument);
	if (hwd.Browser.Document.URL != "about:blank")
		return hwd;
	hwd.scrollbar = false;
	hwd.Visible = false;
	if (typeof bdlg == "undefined")
		bdlg = "false";
	switch (nStyle)
	{
	case 1:
//		hwd.Icon = "netbox:/pic/nsoft16.gif";
		tag = "<html><head><title>" + (!/[a-zA-Z]+/.test(sName)?sName:hwd.Title) +
			"</title></head><body bgcolor=#9ADDF5 style='margin:0;line-height:24px;'>" + 
			"<div style='width:100%;border:1px solid #1170b2;border-top:0px;'>"+
			"<div id=MainWindow style='height:100%;margin:1px;margin-top:0px;'>" +
			"<iframe id=WorkFrame onload=SetTitle() SCROLLING=no FRAMEBORDER=0" +
			" style=width:100%;height:100%; src='"+href+"'></iframe></div><div></body>\n" +
			"<scrip" + "t language=javascript src=" + psubdir + "psub.jsp></" + "script>\n" +
			"<scrip" + "t language=javascript src=" + psubdir + "nbwin.js></" + "script>\n" +
			"<scrip" + "t language=javascript>\n" +
			"window.counterx=0;"+
			"function SetTitle()\n{\n" +
			"	window.onloadOKx=1;"+
			"	if ((document.title == \"\") && (idobj(\"WorkFrame\").contentWindow.document.title !=\"\"))\n{\n" +
			"		if (typeof window.nbwin == \"object\"){\n" +
			"			window.nbwin.SetCaption(idobj(\"WorkFrame\").contentWindow.document.title);\n"+
			"		}else{if(++window.counterx<200)setTimeout('SetTitle()', 20);return;\n}"+
			"		external.Title = idobj(\"WorkFrame\").contentWindow.document.title;\n	}\n}\n" +
			"function window.onload()\n{\n" +
			"	window.nbwin = new NBWindow('" + (!/[a-zA-Z]+/.test(sName)?sName:hwd.Title) + 
			"',{ModalDialog:" + bdlg + ",oFrame:idobj(\"WorkFrame\")},0," + nStyle + ");\n" +
			"	try{idobj(\"WorkFrame\").contentWindow.ResizeFlowForm();"+
			"		var fstr='"+sFeatures+"'.toUpperCase();"+
			"	if(fstr.indexOf('LEFT')<0&&fstr.indexOf('TOP')<0&&fstr.indexOf('CENTER=NO')<0"+
			"&&fstr.indexOf('CENTER=0')<0){external.center();}"+
			"	}catch(ex){};\n"+
			"	/*idobj(\"WorkFrame\").src = \"" + href + "\";*/\n}\n" +
			"</script" + "></html>";
			// 加入try catch 让用户看不见自动适应大小的”动画“过程 lxt 2012.4.16
			//==对iframe的src直接赋值加快显示页不会出现“空白”情况并通过timeout解决onload到setTitle的同步问题
			break;
	default:
		tag = "<html><head><title>" + hwd.Title +
			"</title></head><body bgcolor=#70716C style='margin:0;line-height:24px;" +
			"border-right:1px solid #3F403B;border-bottom:1px solid #3F403B;'>" +
			"<div id=MainWindow style='height:100%;margin:0 4px 4px 4px;'>" +
			"<iframe id=WorkFrame onload=SetTitle() SCROLLING=no FRAMEBORDER=0" +
			" style=width:100%;height:100%;></iframe></div></body>\n" +
			"<scrip" + "t language=javascript src=" + psubdir + "psub.jsp></" + "script>\n" +
			"<scrip" + "t language=javascript src=" + psubdir + "nbwin.js></" + "script>\n" +
			"<scrip" + "t language=javascript>\n" +
			"function SetTitle()\n{\n" +
			"	if ((document.title == \"\") && (idobj(\"WorkFrame\").contentWindow.document.title !=\"\"))\n{\n" +
			"		if (typeof window.nbwin == \"object\")\n" +
			"			window.nbwin.SetCaption(idobj(\"WorkFrame\").contentWindow.document.title);\n"+
			"		external.Title = idobj(\"WorkFrame\").contentWindow.document.title;\n	}\n}\n" +
			"function window.onload()\n{\n" +
			"	window.nbwin = new NBWindow('" + hwd.Title + "',0,0," + nStyle + ");\n" +
			"	idobj(\"WorkFrame\").src = \"" + href + "\";\n" +
			"window.onresize();\n}\n" +
			"function window.onresize()\n{\n" +
			"	idobj(\"WorkFrame\").style.height = document.body.clientHeight - 36;\n}\n" +
			"</scri" + "pt></html>";
		break;
	}
	hwd.Browser.Document.write(tag);
	hwd.Browser.Document.close();
	if ((bdlg == 1) || (bdlg == true))
	{
		hwd.ToolWindow = true;
		if(nStyle==1){/*==eut==*/
			hwd.LayeredAlpha=0;/*==防止加载和显示同步进行的“卡屏”lxt 2012.1.9==*/
			window.counterx1=0;
			var funcx=function(){
				if(++window.counterx1<50&&hwd.browser.document.parentWindow.onloadOKx!=1)
					setTimeout(function(){funcx();}, 100);
				else hwd.LayeredAlpha=255;
			};
			setTimeout(function(){funcx();}, 300);
		}
		return hwd.showDialog();
	}
	return hwd;
}

function GetNBWinName(wnd)
{
	var NetBox = new ActiveXObject("NetBox");
	for (var x = NetBox("HTMLWin_Dict").Count - 1; x >= 0; x--)
	{
		if (NetBox("HTMLWin_Dict")(NetBox("HTMLWin_Dict").Key(x)).isClosed())
		{
			NetBox("HTMLWin_Dict").Remove(NetBox("HTMLWin_Dict").Key(x));
			continue;
		}
		if (wnd == NetBox("HTMLWin_Dict")(NetBox("HTMLWin_Dict").Key(x)))
			return NetBox("HTMLWin_Dict").Key(x);
	}
	return "";
}

var ht;
function NewNBDlg(href, sFeatures, sName, argument, nWinMode)
{
	if ((typeof nDefaultWinMode != "undefined") && (nWinMode == undefined))
		nWinMode = nDefaultWinMode;

	switch (nWinMode)
	{
	case 4:				//JNET WIN
		return NewNBUserWin(href, sFeatures, sName, 0, argument, 1);
	case 5: 			//EUT QQ
		return NewNBUserWin(href, sFeatures, sName, 1, argument, 1);
	}

	ht = new ActiveXObject("NetBox.HtmlWindow");
	SetNetBoxHTMLWindow(ht, sFeatures);
	ht.Icon = psubdir + "pic/jofo16.gif";
//	ht.DropShadow = true;
//	ht.border = true;
//	ht.WindowEdge = true;
	ht.ContextMenu = false;
	if (sName == 0)
		ht.Caption = false;
	if (typeof(caption) == "string")
		ht.Title = sName;
	href = CheckHref(href);
	ht.open(href, argument);
	window.setTimeout("SetNetBoxHTMLParent()", 300);
	return ht.showDialog();
}

function CheckHref(href)
{
	if ((href != "about:blank") && (href.substr(0, 4) != "http") && (href.substr(0, 5) != "https"))
	{
		if (href.substr(0, 1) == "/")
			return location.protocol + "//" + location.host + href;
		else
		{
			var ss = location.href.split("/");
			ss[ss.length - 1] = href;
			return ss.join("/");
		}
	}
	return href;
}

function SetNetBoxHTMLParent()
{
	try
	{
		if (typeof(ht.Browser.Document) == "object" && (ht.Browser.Document != null))
		{
			if (typeof(ht.Browser.Document.parentWindow) == "object")
			{
				ht.Browser.Document.parentWindow.opener = window;
				return;
			}
		}
	}
	catch(e)
	{
		return false;
	}
	window.setTimeout("SetNetBoxHTMLParent()", 300);
}

function SetNetBoxHTMLWindow(ht, sFeatures)
{
var s1, s2, x;
	var visible = false;
	if (typeof(sFeatures) == "undefined")
	{
		ht.resizable = true;
		ht.scrollbar = true;
		return true;
	}
	s1 = sFeatures.split(",");
	if (s1.length == 1)
		s1 = sFeatures.split(";");
	for (x = 0; x < s1.length; x++)
	{
		s2 = s1[x].split("=");
		if (s2.length == 1)
			s2 = s1[x].split(":");
		switch (Trim(s2[0].toLowerCase()))
		{
		case "height":
		case "dialogheight":
			if (ht.Caption)
				ht.Height = parseInt(s2[1]) + 30;
			else
				ht.Height = parseInt(s2[1]);
			break;
		case "width":
		case "dialogwidth":
			if (ht.Caption)
				ht.Width = parseInt(s2[1]) + 10;
			else
				ht.Width = parseInt(s2[1]);
			break;
		case "scrollbars":
		case "scrollbar":
		case "scroll":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no"))
				ht.scrollbar = false;
			else
				ht.scrollbar = true;
			break;
		case "left":
		case "dialogleft":
			ht.Left = s2[1];
			break;
		case "top":
		case "dialogtop":
			ht.Top = s2[1];
			break;
		case "resizable":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no"))
				ht.resizable = false;
			else
				ht.resizable = true;
			break;
		case "border":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.border = false;
			else
				ht.border = true;
			break;
		case "dropshadow":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.DropShadow = false;
			else
				ht.DropShadow = true;
			break;
		case "icon":
			ht.Icon = s2[1];
			break;
		case "maximizebox":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.MaximizeBox = false;
			else
				ht.MaximizeBox = true;
			break;
		case "minimizebox":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.MinimizeBox = false;
			else
				ht.MinimizeBox = true;
			break;
		case "title":
			ht.Title  = s2[1];
			break;
		case "center":
			if ((s2[1] == "1") || (s2[1].toLowerCase() == "yes") || (s2[1].toLowerCase() == "true"))
				ht.center();
			break;
		case "toolwindow":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.ToolWindow = false;
			else
				ht.ToolWindow = true;
			break;
		case "topmost":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
			{
				ht.TopMost = false;
			}
			else
			{
				ht.TopMost = true;
			}
			break;
		case "windowedge":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.WindowEdge = false;
			else
				ht.WindowEdge = true;
			break;
		case "caption":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.Caption = false;
			else
				ht.Caption = true;
			break;
		case "layeredalpha":
			ht.LayeredAlpha = s2[1];
			break;
		case "transparentmask":
			ht.SetTransparentMask(s2[1]);
			break;
		case "visible":
			if ((s2[1] == "1") || (s2[1].toLowerCase() == "yes") || (s2[1].toLowerCase() == "true"))
				visible = true;
			break;
		case "fullscreen":
			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
				ht.Maximized = false;
			else
				ht.Maximized = true;
			break;
		}
	}
	//==默认是定位中间的，但是在没定位大小前就调用的，导致大小改变后实际不中间了 lxt 2011.12.30
	var fstr=sFeatures.toUpperCase();
	if(fstr.indexOf("LEFT")<0&&fstr.indexOf("TOP")<0&&fstr.indexOf("CENTER")<0)
		ht.center();
	return visible;
}

function NewHref(href, sFeatures, sName, nWinMode)
{
	// Electron 路径问题 lxt 2017.12.14
	if(window.g_isElectron && href.indexOf("/")==0){
		if(location.href.indexOf("http")==0){
			var basePath=location.href.replace(/(https?:\/\/[^\/]+\/).*/, "$1");
			if(location.href.indexOf("/eut/")>-1)
				 basePath=basePath+"eut/";
			href=basePath+href;
		}
	}
	
	if ((typeof nDefaultWinMode != "undefined") && (nWinMode == undefined))
		nWinMode = nDefaultWinMode;

	if (typeof(sName) == "undefined")
		sName = "_blank";
	
	if (nWinMode == 2)
		return NewFrameWin(href, sFeatures, sName);

	if (nWinMode == 3)
		return SelectDialog(0, href, sFeatures);

	if (IsNetBoxRunning())
	{
		switch (nWinMode)
		{
		case 0:
			return NewWindow(href, sFeatures, sName);
		case 4:				//JNET WIN
			return NewNBUserWin(href, sFeatures, sName);
		case 5: 			//EUT QQ
			return NewNBUserWin(href, sFeatures, sName, 1);
		default:
			return NewNBWin(href, sFeatures, sName);
		}
	}
	else
	{
		var isElectron=window.navigator.userAgent.indexOf("Electron")>-1;
		var w;
		if(isElectron){
			// Electron用top打开导致的路径问题 lxt 2017.5.26
			var urlbase=location.href;
			if(location.href.lastIndexOf("/")>-1) 
				urlbase=location.href.substring(0,location.href.lastIndexOf("/")+1);
			var href2=href.indexOf("/")==0||href.indexOf("http")==0?href:urlbase+href;
			w = top.open(href2, sName, sFeatures);
		}
		else w =window.open(href, sName, sFeatures);
		w.focus();
		return w;
	}
}

function NewFrameWin(href, sFeatures, title)
{
	var s1, s2, scroll = "no", titlebar;
	if ((typeof(title) == "undefined") || (title == "") || (title == "_blank"))
			title = "正在载入...";
	s1 = sFeatures.split(",");
	
	for (x = 0; x < s1.length; x++)
	{
		var s2 = s1[x].split("=");
		switch (s2[0].toLowerCase())
		{
		case "scrollbars":
		case "scrollbar":
			if ((s2[1] == "1") || (s2[1].toLowerCase() == "yes") || (s2[1].toLowerCase() == "true"))
				scroll = "yes";
			break;
//		case "titlebar":
//			if ((s2[1] == "0") || (s2[1].toLowerCase() == "no") || (s2[1].toLowerCase() == "false"))
//				titlebar = 0;
			break;
		}
	}
	var tag = "<iframe name=IFrameDlg onload=LoadFrameWinOK(this) frameborder=0 scrolling=" + scroll + " style='width:100%;height:100%' src=" + href + "></iframe>";
	HTMLDlgBox(title, tag, sFeatures);
}

function LoadFrameWinOK(obj)
{
	var dlg = idobj("InDlgDiv");
	if ( dlg == null)
		return;
	if (objall(dlg, "titlebar").innerText == "正在载入...")
		objall(dlg, "titlebar").innerHTML = obj.contentWindow.document.title;
	if (idobj("ActionSave", obj.contentWindow.document) != null)
	{
		var h = idobj("ActionSave", obj.contentWindow.document).scrollHeight + 40;
		var t = document.body.scrollTop + (document.body.clientHeight - h) / 2;
		if (t < 0)
			t = 0;
		if (h + t > document.body.scrollTop + document.body.clientHeight) {
			h = document.body.clientHeight - t;
			t = document.body.scrollTop + (document.body.clientHeight - h) / 2;
			if (t < 0)
				t = 0;
		}
		if (h < 100) {
			h = 100;
		}
		var screenHeight = window.screen.height;
		if (h > screenHeight) {
			h = screenHeight;
		}
		objall(dlg, "InDlgBox").style.height = h + "px";
		objall(dlg, "InDlgBox").style.top = t + "px";
		var w = idobj("ActionSave", obj.contentWindow.document).scrollWidth;
		var l = document.body.scrollLeft + (document.body.clientWidth - w) / 2;
		if (l < 0)
			l = 0;
		if (w > document.body.clientWidth) {
			w = document.body.clientWidth;
		}
		var screenWidth = window.screen.width;
		if (w > screenWidth) {
			w = screenWidth;
		}
		objall(dlg, "InDlgBox").style.width = w + "px";
		objall(dlg, "InDlgBox").style.left = l + "px";
		h = h - 30;
		objall(dlg, "RDiv").style.height = h + "px";
return;
		//==处理表单原本蓝色条没的情况
		if (idobj("UserFormHeadDiv", obj.contentWindow.document) != null)
		{
			idobj("UserFormHeadDiv", obj.contentWindow.document).onmousedown = function()
			{	
				fireobjevt(objall(dlg, "RTDiv"), "mousedown");
			}
		}
	}
}

function InlineDlg(title, dlgBar, inputType, defaultvalue)
{
	if (idobj("InlineInputObj") != null)
		return;
	if (typeof(defaultvalue) == "string")
		defaultvalue = " value=" + defaultvalue;
	else
		defaultvalue = "";
	var fun = /function\s+(.+?)\(/.exec(InlineDlg.caller)[1];
	InlineHTMLDlg(dlgBar, "<BR>" + title + "：<BR><center><input id=InlineInputObj type=text" + defaultvalue + 
		"><BR><BR><input type=submit node=" + fun + " onclick=ConfirmInlineDlg(this) value=确定>&nbsp;&nbsp;" +
		"<input type=button onclick=CloseInlineDlg() value=取消></center>", 300, 200);
	idobj("InlineInputObj").focus();
	idobj("InlineInputObj").select();
}

function InlineHTMLDlg(dlgBar, htmlText, width, height)
{
	var s = "resizable=0";
	if (typeof(width) != "undefined")
		s += ",width=" + width;
	if (typeof(height) != "undefined")
		s += ",height=" + height;
	HTMLDlgBox(dlgBar, htmlText, s);
}

function HTMLDlgBox(title, htmlText, sFeatures, css)
{
var x, s1, s2, t, l, tb = "", resizeevt = "", maxevt = "";
var w = 300,h = 350;
var top = document.body.scrollTop;
var left = document.body.scrollLeft;
var modelmask = "<iframe style='position:absolute;left:" + left + "px;top:" + top + "px;width:100%;height:100%;filter:alpha(opacity=0);opacity:0.0;z-index:10'></iframe>" +
	"<div style='position:absolute;left:" + left + "px;top:" + top + "px;width:100%;height:100%;z-index:11;filter:alpha(opacity=70);opacity:0.7;background-color:gray;'></div>";
	if (typeof css == "undefined")
		css = "InlineDlg";
	if (idobj("InDlgDiv") != null)
		CloseInlineDlg();

	s1 = sFeatures.split(",");
	for (x = 0; x < s1.length; x++)
	{
		s2 = s1[x].split("=");
		switch (s2[0].toLowerCase())
		{
		case "height":
		case "dialogheight":
			if(s2[1].indexOf('%')>-1) h=document.body.clientHeight*parseInt(s2[1])/100;
			else h = parseInt(s2[1]);
			break;
		case "width":
		case "dialogwidth":
			if(s2[1].indexOf('%')>-1) w=document.body.clientWidth*parseInt(s2[1])/100;
			else w = parseInt(s2[1]);
			break;
		case "modeless":
			if ((s2[1] == "1") || (s2[1].toLowerCase() == "yes") || (s2[1].toLowerCase() == "true"))
				modelmask = "";
			break;
		case "resizable":
			if ((s2[1] == "1") || (s2[1].toLowerCase() == "yes") || (s2[1].toLowerCase() == "true"))
			{
				resizeevt = "onmousedown=BeginResizeDlgObj(this) onmouseover=ResizeCursorObj(this) ";
				maxevt = " ondblclick=MaxInlineDlg()";
			}
			break;
		}
	}
	t = top + (document.body.clientHeight - h) / 2;
	l = left + (document.body.clientWidth - w) / 2;
	if (t < 0)
		t = 0;
	if (l < 0)
		l = 0;
	document.body.scrollsave = document.body.scroll;
	document.body.scroll = "no";
	document.body.insertAdjacentHTML("beforeEnd", "<div align=left id=InDlgDiv>" + modelmask +
		"<div id=InDlgBox " + resizeevt + "class=" + css + " style='left:" + l + "px;top:" + t + "px;width:" + w + "px;height:" + h +
		"px;'><div nowrap onmousedown=BeginDragObj(this.parentNode) id=RTDiv" + maxevt + "><div id=LTDiv><div id=TDiv>" +
		"<div id=CloseButton onclick=CloseInlineDlg() onmouseover=this.className='ClsBox_Roll'; onmouseout=this.className='ClsBox'; class=ClsBox></div>" +
		"<b id=titlebar style=width:100%;overflow:hidden>" + title + "</b></div></div></div><div id=RDiv style=height:" + (h - 30) + "px;><div id=LDiv><div id=MDiv>" + htmlText +
		"</div></div></div><div id=RBDiv><div id=LBDiv><div id=BDiv></div></div></div></div></div>");

//	try{
//			correctPNG2(document.getElementById('InDlgDiv'));
//		}catch(ex){}
}

function BeginResizeDlgObj(obj)
{
	ResizeCursorObj(obj);
	if (obj.nSize <= 0)
		return;
	g_nResize = obj.nSize;
	document.onmousemove = function ()
	{
		ResizingObj();
		var dlg = idobj("InDlgDiv");
		if (parseInt(obj.style.height) > 30)
			objall(dlg, "RDiv").style.height = (parseInt(obj.style.height) - 30) + "px";
	}
	DragInit(obj);
}

function ConfirmInlineDlg(obj)
{
	var value = obj.previousSibling.previousSibling.previousSibling.value;
	var fun = objattr(obj, "node");
	CloseInlineDlg();
	eval(fun + "('" + value + "')");
}

function MaxInlineDlg()
{
	var obj = idobj("InDlgBox");
	if (obj.style.width != "100%")
	{
		obj.oldleft = obj.style.left;
		obj.oldtop = obj.style.top;
		obj.oldwidth = obj.style.width;
		obj.oldheight = obj.style.height;
		obj.style.left = "0px";
		obj.style.top = "0px";
		obj.style.width = "100%";
		obj.style.height = document.body.clientHeight + "px";//"100%";
	}
	else
	{
		obj.style.left = obj.oldleft;
		obj.style.top = obj.oldtop;
		obj.style.width = obj.oldwidth;
		obj.style.height = obj.oldheight;	
	}
	if (parseInt(obj.style.height) > 30)
		objall(obj, "RDiv").style.height = (parseInt(obj.style.height) - 30) + "px";
}

function CloseInlineDlg()
{
	if (typeof document.body.scrollsave != "undefined")
		document.body.scroll = document.body.scrollsave;
	document.body.focus();
	var dlg = idobj("InDlgDiv");
	dlg.parentNode.removeChild(dlg);
}


function BodyAlert(msg)
{
	oDiv = document.getElementById("TempAlertDiv");
	if (oDiv != null)
		oDiv.parentNode.removeChild(oDiv);
	document.body.insertAdjacentHTML("beforeEnd", "<div id=TempAlertDiv style='background-color:#ffffa2;border:1px solid #caa700;position:absolute;padding:4px;'>" + msg + "</div>");
	oDiv = document.getElementById("TempAlertDiv");
	oDiv.style.left = (document.body.clientWidth - oDiv.clientWidth) / 2 + "px";
	oDiv.style.top = (document.body.clientHeight - oDiv.clientHeight) / 2 + "px";
	objevent(document.body, "mousedown", function()
	{
		var evt = getEvent();
		if (oDiv.contains(evt.srcElement))
			return;
		oDiv.parentNode.removeChild(oDiv);
		objevent(document.body, "mousedown", arguments.callee, 1);
	});
}

function ExpandItem(oImg, bIcon)
{
	var oTR = oImg.parentNode.parentNode.nextSibling;
	if (oTR.style.display == "none")
	{
		oTR.style.display = "";
		if (typeof(bIcon) == "undefined")
			oImg.src = psubdir + "pic/uparrow.gif";
	}
	else
	{
		oTR.style.display = "none";
		if (typeof(bIcon) == "undefined")
			oImg.src = psubdir + "pic/downarrow.gif";
	}
}

function ExpandAll(oImg, bIcon)
{
	var oTRs = document.getElementsByName("Detail");
	var Buttons = document.getElementsByName("ButtonEx");
	if (oImg.value == 0)
	{
		oImg.value = 1;
		if (typeof(bIcon) == "undefined")
			oImg.src = psubdir + "pic/uparrow.gif";
		for (x = 0; x < oTRs.length; x++)
		{
			oTRs(x).style.display = "inline";
			if (typeof(bIcon) == "undefined")
				Buttons(x).src = psubdir + "pic/uparrow.gif";
		}
	}
	else
	{
		oImg.value = 0;
		if (typeof(bIcon) == "undefined")
			oImg.src = psubdir + "pic/downarrow.gif";
		for (x = 0; x < oTRs.length; x++)
		{
			oTRs(x).style.display = "none";
			if (typeof(bIcon) == "undefined")
				Buttons(x).src = psubdir + "pic/downarrow.gif";
		}
	}
	var evt = getEvent();
	evt.cancelBubble = true;
}


function GetDate(value)
{
	var s = value.split(" ");
	var d = s[0].split("-");
	switch (s.length)
	{
	case 1:
		switch (d.length)
		{
		case 1:
			return new Date(d[0], 0, 1);
		case 2:
			return new Date(d[0], d[1] - 1, 1);
		case 3:
			return new Date(d[0], d[1] - 1, d[2]);
		}
	case 2:
		var t = s[1].split(":");
		if (t.length < 3)
			return new Date(d[0], d[1] - 1, d[2], t[0], t[1]);
		return new Date(d[0], d[1] - 1, d[2], t[0], t[1], t[2]);
	default:
		return null;
	}
}

function GetWorkDate(beginDate, days)
{
	var dd = GetDate(beginDate);
	var nWeekdays = days % 5;
	var nWeek = Math.floor(days / 5);
	var nDay = nWeek * 7 + nWeekdays;
	var nBegin = dd.getDay();
	if (nBegin == 0) 
		nDay ++;
	else
	{
		if (nBegin + nWeekdays > 5)
			nDay += 2;
	}
	
	dd.setDate(dd.getDate() + nDay);
	return dd.getFullYear() + "-" + (dd.getMonth() + 1) + "-" + dd.getDate();
}

function SelectDate(oImg, nType)
{
	var value = "";
	var oInput =oImg.parentNode.getElementsByTagName("INPUT");
	if (oInput.length == 1)
		value = oInput[0].value;
	var ss = value.split(" ");
	if ((typeof(nType) == "undefined") || (nType == 0))
		value = ss[0];
	else
	{
		if (ss.length == 1)
			value = ss[0] + " 00:00:00";
	}
	return SelectDialog(oImg, psubdir + "seledatetime.jsp", "dialogWidth:200px;dialogHeight=240px;scroll:no;help:no;status:no", value);
}

function SelectMember(oImg)
{
	var value = "";
	var oInput =oImg.parentNode.getElementsByTagName("INPUT");
	if (oInput.length == 1)
		value = oInput[0].value;
	return SelectDialog(oImg, "../selmember.jsp?selone=1","dialogWidth:650px;dialogHeight:510px;caption:0;border:0;scroll:0;help:0;status:0", value);
}

function SelectMembers(oImg)
{
	var value = "";
	var oInput =oImg.parentNode.getElementsByTagName("INPUT");
	if (oInput.length == 1)
		value = oInput[0].value;
	else 
	{
		oInput = oImg.parentNode.getElementsByTagName("textarea");
		if(oInput.length == 1)
			value = oInput[0].innerHTML;
	}
	// 解决Chrome和Electron不弹模态窗的问题  lxt 2017.6.8
	var rValue=SelectDialog(oImg, "../selmember.jsp","dialogWidth:650px;dialogHeight:510px;caption:0;border:0;scroll:0;help:0;status:0", value);
	if(window.navigator.userAgent.indexOf("Chrome")<0) return rValue;
	window.g_selmembersLoopTimes=0;
	window.localStorage.removeItem("diglogReturnValue");
	var func=function(){
		var dialogReturnValue=window.localStorage["diglogReturnValue"];
		if(dialogReturnValue&&(dialogReturnValue+"").length>0){
			if(oImg.previousSibling) oImg.previousSibling.value=window.localStorage["diglogReturnValue"];
		}
		else if(window.g_selmembersLoopTimes++<200) setTimeout(func, 500);
	};
	setTimeout(func, 500);
}

function CBSelectDateTime(obj)
{
	var ss = obj.firstChild.value.split(" ");
	if (ss.length == 1)
		obj.firstChild.value += " 00:00:00";
	SelectCombo(obj, psubdir + "seledatetime.jsp", 220, 220);
}

function CBSelectDate(obj)
{
	SelectCombo(obj, psubdir + "seledatetime.jsp", 190, 180);
}
/*=这里加上interValTimex参数，并不是所有的页面都加载都很慢 lxt 2012.3.6=*/
function SelectCombo(obj, url, width, height, interValTimex)
{
	var evt = getEvent();
	if ((evt != null) && (evt.offsetX < obj.clientWidth - 20))
		return;
	
	var oFrame = document.getElementById("ComboTempIFrame");
	if (oFrame != null)
		oFrame.parentNode.removeChild(oFrame);

	document.body.insertAdjacentHTML("beforeEnd", "<iframe ID=ComboTempIFrame src=" +
		url + " frameborder=0 style='position:absolute;border:1px solid black;display:none;'></iframe>");
	var oInteval = window.setInterval(function()
	{
		var oFrame = document.getElementById("ComboTempIFrame");
		if (oFrame == null)
			return;
		if (oFrame.contentWindow.document.readyState == "complete")
		{
			window.clearInterval(oInteval);
			var pos = GetObjPos(obj.parentNode, document.body);
			if (typeof(width) == "undefined")
				oFrame.style.width = (pos.right - pos.left) + "px";
			else
				oFrame.style.width = width + "px";
			if (typeof(height) == "undefined")
				oFrame.style.height = 200 + "px";
			else
				oFrame.style.height = height + "px";
			if (pos.left + parseInt(oFrame.style.width) >= document.body.clientWidth + document.body.scrollLeft)
				oFrame.style.left = (pos.left - parseInt(oFrame.style.width) - document.body.scrollLeft) + "px";
			else
				oFrame.style.left = pos.left + "px";
			if (pos.bottom + parseInt(oFrame.style.height) >= document.body.clientHeight + document.body.scrollTop)
				oFrame.style.top = (pos.top - parseInt(oFrame.style.height) - document.body.scrollTop) + "px";
			else
				oFrame.style.top = pos.bottom + "px";
			if (parseInt(oFrame.style.top) < 0)
				oFrame.style.top = "0px";
			if (parseInt(oFrame.style.left) < 0)
				oFrame.style.left = "0px";
			oFrame.style.display = "block";
			objevent(document.body, "mousedown", function()
			{
				var evt = getEvent();
				if (evt.srcElement == obj.previousSibling)
					return;
				oFrame.parentNode.removeChild(oFrame);
				objevent(document.body, "mousedown", arguments.callee, 1);
			});
			if (typeof(oFrame.contentWindow.InitComboValue) == "function")
			{
				if (obj.firstChild == null)
					oFrame.contentWindow.InitComboValue(obj.previousSibling);
				else
					oFrame.contentWindow.InitComboValue(obj.firstChild);
			}
		}
	}, interValTimex?interValTimex:500);
}

function SetComboPos(obj, width, height)
{
	var oFrame = document.getElementById("ComboTempIFrame");
	var pos = GetObjPos(obj, document.body);
	oFrame.style.left = pos.left + "px";
	oFrame.style.top = pos.bottom - 1;
	if (typeof(width) == "undefined")
		width = pos.right - pos.left - 2;
	if (width > document.body.clientWidth)
		width = document.body.clientWidth;
	oFrame.style.width = width;
	if (typeof(height) == "undefined")
		height = 200;
	if (pos.bottom + height > document.body.clientHeight)
	{
		if (pos.top > height)
			oFrame.style.top = pos.top - height - 2;
		else
			height = document.body.clientHeight - pos.bottom;
	}
	oFrame.style.height = height;
	oFrame.style.display = "block";
			
	if (pos.left + oFrame.clientWidth > document.body.clientWidth - 4)
		oFrame.style.left = (document.body.clientWidth - oFrame.clientWidth - 4) + "px";
//	if (pos.top + oFrame.clientHeight > document.body.clientHeight - 2)
//		oFrame.style.top = document.body.clientHeight - oFrame.clientHeight - 2;
}


function GetDateTimeString(t, fmt)
{
	if (typeof t == "string")
		t = GetDate(t);
	switch (fmt)
	{
	case 1:		//2008-3-15
		return t.getFullYear() + "-" + (t.getMonth() + 1) + "-" + t.getDate();
	case 2:		//9:18:5
		return t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
	case 3:		//9:18
		return t.getHours() + ":" + LStrFill(t.getMinutes(), 2, "0");
	case 4:		//2008-03-15
		return t.getFullYear() + "-" + LStrFill((t.getMonth() + 1), 2, "0") + "-" + LStrFill(t.getDate(), 2, "0")
	case 5:		//09:18:05
		return LStrFill(t.getHours(), 2, "0") + ":" + LStrFill(t.getMinutes(), 2, "0") + ":" + LStrFill(t.getSeconds(), 2, "0");
	case 6:		//3-15 9:18:5
		return (t.getMonth() + 1)+ "-" + t.getDate() + " " + t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
	case 7:		//2008-03-15 09:18:05
		return t.getFullYear() + "-" + LStrFill((t.getMonth() + 1), 2, "0") + "-" + LStrFill(t.getDate(), 2, "0") + " " +
			LStrFill(t.getHours(), 2, "0") + ":" + LStrFill(t.getMinutes(), 2, "0") + ":" + LStrFill(t.getSeconds(), 2, "0");
	case 8:		//2008-03-15 09:18
		return t.getFullYear() + "-" + LStrFill((t.getMonth() + 1), 2, "0") + "-" + LStrFill(t.getDate(), 2, "0") + " " +
			LStrFill(t.getHours(), 2, "0") + ":" + LStrFill(t.getMinutes(), 2, "0");
	case 9:		//3-15
		return (t.getMonth() + 1) + "-" + t.getDate();
	case 10:	//2011
		return t.getFullYear();
	default:	//2008-3-15 9:18:5
		return t.getFullYear() + "-" + (t.getMonth() + 1) + "-" + t.getDate() + " " +
			t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
	}
}

function LStrFill(n, length, ch)
{
	
	var value = n;
	for (var x = 0; x < length; x++)
	{
		value = ch + value;
	}
	return value.substr(value.length - length);
}

function SelectDateTime(oImg)
{
	var oInput =oImg.parentNode.getElementsByTagName("INPUT");
	if (oInput.length == 1)
		var value = oInput[0].value;
	return SelectDialog(oImg, psubdir + "seledatetime.jsp?type=datetime", "dialogWidth:200px;dialogHeight=260px;scroll:no;help:no;status:no", 
		value);
} 


function SelectField(oImg, TableName, FieldName)
{
	return SelectDialog(oImg, psubdir + "selefield.jsp?TableName=" + TableName + "&FieldName=" + FieldName);
}

function CBSelectField(obj, TableName, FieldName)
{
	SelectCombo(obj, psubdir + "selefield.jsp?TableName=" + TableName + "&FieldName=" + FieldName);
}

function SelectEnumData(oImg, EnumType)
{
	var str = showModalDialog(psubdir + "seleenum.jsp?EnumType=" + EnumType, "", "dialogWidth:300px;scroll:0;help:0;status:0");
	// Chrome lxt 2017.12.27
	if(window.g_isChrome){
		if(window.g_selenumCrmTimer){
			window.clearInterval(window.g_selenumCrmTimer);
			window.g_selenumCrmTimer=0;
		}
		var func=function(){
			if(window.localStorage["crmSelenumReturnValue"]){
				str=window.localStorage["crmSelenumReturnValue"]+"";
				window.localStorage.removeItem("crmSelenumReturnValue");
				if ((typeof(str) == "string") && (typeof(oImg) == "object"))
				{
					var oInput =oImg.parentNode.getElementsByTagName("INPUT");
					var s = str.split(":");
					oInput[0].value = s[0];
					oInput[1].value = s[1];
				}
				window.clearInterval(window.g_selenumCrmTimer);
				window.g_selenumCrmTimer=0;
			}
		};
		window.g_selenumCrmTimer=setInterval(func, 1000);
	}
	
	if ((typeof(str) == "string") && (typeof(oImg) == "object"))
	{
		var oInput =oImg.parentNode.getElementsByTagName("INPUT");
		var s = str.split(":");
		oInput[0].value = s[0];
		oInput[1].value = s[1];
	}
	return str;
}

function SelectInlineEnumData(oImg, values)
{
	var ss = values.substr(1, values.length - 2).split(",");
	var tag = "<select id=InlineEnumSelect size=10 style=width=100%>"; 
	for (var x = 0; x < ss.length; x++)
	{
		var sss = ss[x].split(":");
		tag += "<option value=" + sss[0] + ">" + sss[1] + "</option>"
	}
	tag += "<select><center><input id=InlineEnumButton type=button value=确定></center>"
	InlineHTMLDlg("选择枚举量", tag, 300, 200);
	var oInput = oImg.parentNode.getElementsByTagName("INPUT");
	document.all.InlineEnumSelect.value = oInput[0].value;
	document.all.InlineEnumButton.onclick = function ()
	{
		if (document.all.InlineEnumSelect.selectedIndex >=0)
		{
			oInput[0].value = document.all.InlineEnumSelect.value;
			oInput[1].value = document.all.InlineEnumSelect.options[document.all.InlineEnumSelect.selectedIndex].text;
		}
		else
		{
			oInput[0].value = 0;
			oInput[1].value = "";
		}
		CloseInlineDlg();
	}
}

function SelectUsers(oImg)
{
	return SelectDialog(oImg, "/SeleUsers.asp");
}

function SelectDialog(oImg, dlgURL, dlgProp, dlgParam, bAppend)
{
	if (typeof(dlgProp) == "undefined")
		dlgProp = "dialogWidth:300px;dialogHeight:510px;caption:0;border:0;scroll:0;help:0;status:0";
	if (typeof(dlgParam) == "undefined")
		dlgParam = "";
		
	

	if (IsNetBoxRunning())
		var data = NewNBDlg(dlgURL, dlgProp, "", dlgParam);
	else
		var data = showModalDialog(dlgURL, dlgParam, dlgProp);
		
	// Chrome lxt 2017.11.17
	if(navigator.userAgent.indexOf("Chrome")>-1){
		window.g_SelectDialogChromeTimes=0;
		var func=function(){
			if(window.localStorage["crmSelectDialogRValue"]){
				data=window.localStorage["crmSelectDialogRValue"]+"";
				window.localStorage.removeItem("crmSelectDialogRValue");
				if (typeof(data) == "string")
				{
					if (typeof(oImg) == "object")
					{
						var oInput =oImg.parentNode.getElementsByTagName("INPUT");
						if (oInput.length == 1)
						{
							if ((bAppend == 1) && (oInput[0].value == ""))
							{
								oInput[0].value += "," + data;
								fireobjevt(oInput[0], "change");
							}
							else
							{
								if (oInput[0].value != data)
								{
									oInput[0].value = data;
									fireobjevt(oInput[0], "change");
								}
							}
						}
						else
						{
							var oInput =oImg.parentNode.getElementsByTagName("TEXTAREA");
							if (oInput.length == 1)
							{
								if ((bAppend == 1) && (oInput[0].value == ""))
								{
									oInput[0].value += "," + data;
									fireobjevt(oInput[0], "change");
								}
								else
									if (oInput[0].value != data)
									{
										oInput[0].value = data;
										fireobjevt(oInput[0], "change");
									}
							}
							else
							{
								var pObj = oImg.previousSibling;
								if (pObj != null) {
									pObj.value = data;
								}
							}
						}
					}
				}
				
				return;
			}
			if(window.g_SelectDialogChromeTimes++<1000) setTimeout(func, 200);
		};
		setTimeout(func, 200);
		return;
	}
		
	if (typeof(data) == "string")
	{
		if (typeof(oImg) == "object")
		{
			var oInput =oImg.parentNode.getElementsByTagName("INPUT");
			if (oInput.length == 1)
			{
				if ((bAppend == 1) && (oInput[0].value == ""))
				{
					oInput[0].value += "," + data;
					fireobjevt(oInput[0], "change");
				}
				else
				{
					if (oInput[0].value != data)
					{
						oInput[0].value = data;
						fireobjevt(oInput[0], "change");
					}
				}
			}
			else
			{
				var oInput =oImg.parentNode.getElementsByTagName("TEXTAREA");
				if (oInput.length == 1)
				{
					if ((bAppend == 1) && (oInput[0].value == ""))
					{
						oInput[0].value += "," + data;
						fireobjevt(oInput[0], "change");
					}
					else
						if (oInput[0].value != data)
						{
							oInput[0].value = data;
							fireobjevt(oInput[0], "change");
						}
				}
				else
				{
					var pObj = oImg.previousSibling;
					if (pObj != null) {
						pObj.value = data;
					}
				}
			}
		}
	}
	return data;
}

function SelectDialogValue(oImg, dlgURL, dlgProp)
{
	if (typeof(dlgProp) == "undefined")
		dlgProp = "dialogWidth:300px;scroll:0;help:0;status:0";
	var data = showModalDialog(dlgURL, "", dlgProp);
	if (typeof(data) == "string")
	{
		if (typeof(oImg) == "object")
		{
			var oInput =oImg.parentNode.getElementsByTagName("INPUT");
			if (oInput.length == 1)
			{
				if (oInput[0].value == "")
					oInput[0].value = data;
				else
					oInput[0].value += "," + data;
			}
		}	
	}
	return data;
}


function ShowDetail(oImg)
{
	var oDiv = oImg.nextSibling;
	if (oDiv.tagName != "DIV")
		oDiv = oDiv.nextSibling;
		
	if (oImg.value == 0)
	{
		oDiv.style.display = "inline";
		oImg.src = psubdir + "pic/uparrow.gif";
		oImg.value = 1;
	}
	else	
	{
		oDiv.style.display = "none";
		oImg.src = psubdir + "pic/downarrow.gif";
		oImg.value = 0;
	}
}

function ShowSubMenu(oMenu)
{
var oSub, obj, to, oSrc;
	oMenu.style.margin = "0px";
	if (oMenu.PushReq == 1)
	{
		if (document.onfocusout != null)
		{
			PopMenuItem();
			PushMenuItem(oMenu);
		}
		else
			oMenu.style.border = "1px outset";
		return;
	}
	if (oMenu.PushReq != 2)
		oMenu.style.border = "1px inset";
	obj = oMenu.getElementsByTagName("DIV");
	if (obj.length > 0)
		oSub = obj[0];
	else
		return;
	to = GetObjPos(oMenu);
	oSub.style.display = "inline";
	oSub.style.top = to.bottom + "px";
	if (to.left + oSub.clientWidth > document.body.clientWidth + 2)
		oSub.style.left = (document.body.clientWidth - oSub.clientWidth - 2) + "px";
	else
		oSub.style.left = to.left + "px";
	
	var evt = getEvent();
	oSrc = FindParentObject(evt.srcElement, oMenu, "TR");
	if ((typeof(oSrc) == "object") && (oSrc.tagName == "TR") && (oSrc.height > 3))
		HighlightTR(oSrc, "");
	evt.cancelBubble = true;
	DrawShadow(oSub, "gray", 5);
}

function ShowSubMenu2(oMenu)
{
var oSub, obj, to;
	obj = oMenu.getElementsByTagName("DIV");
	if (obj.length > 0)
		oSub = obj[0];
	to = GetObjPos(oMenu, "DIV");
	oSub.style.top = (to.top - 1) + "px";
	oSub.style.left = to.right + "px";
	oSub.style.display = "inline";
	objall(oMenu)[0].oldcolor = objall(oMenu)[0].color;
	objall(oMenu)[0].color = "red";
//	oMenu.all[0].oldborder = oMenu.all[0].style.border;
//	oMenu.all[0].style.border = "1px solid blue";
	DrawShadow(oSub, "gray", 5);
}

function HideSubMenu(oMenu)
{
var oSrc;
	if (oMenu.PushReq != 0)
	{
		oMenu.style.margin = "1px";
		oMenu.style.border = "none";
	
		oSubs = oMenu.getElementsByTagName("DIV");
		for (x = 0; x < oSubs.length; x++)
			oSubs[x].style.display="none";
	}
	var evt = getEvent();
	if (evt == null)
		return;
	oSrc = FindParentObject(evt.srcElement, oMenu, "TR");
	if (typeof(oSrc) == "object")
	{
//		try
		{
			HighlightTR(oSrc);
		}
//		catch (e)
//		{
//		}
	}
}

function HideSubMenu2(oMenu)
{
	objall(oMenu)[0].color = objall(oMenu)[0].oldcolor;
//	oMenu.all[0].style.border = oMenu.all[0].oldborder;

	var evt = getEvent();
	if (evt.srcElement.tagName == "TD")
		evt.srcElement.style.color = objall(oMenu)[0].color;
	oSubs = oMenu.getElementsByTagName("DIV");
	for (x = 0; x < oSubs.length; x++)
		oSubs[x].style.display="none";
}

function PushMenuItem(obj)
{

	if (obj.disabled)
		return;
	var all = objall(obj);
	for (x = 0; x < all.length; x++)
		all[x].UNSELECTABLE = "on";
	if (obj.onclick != null)
	{
		obj.style.border = "1px inset";
		return;
	}
	var evt = getEvent();
	if (typeof(window.dialogWidth) != "undefined")
		evt.srcElement.click();
	if (document.onfocusout != null)
		PopMenuItem();
	obj.PushReq = 0;
	ShowSubMenu(obj);
	dragObj = obj;
	obj.focus();
	document.onfocusout = PopMenuItem;
}

function PopMenuItem()
{
	document.onfocusout = null;
	if (typeof(dragObj) == "object")
	{
		dragObj.PushReq = 1;
		HideSubMenu(dragObj);
	}
	dragObj = 0;
}

function HighlightTR(oTR, bgcolor, border)
{
	if (typeof(bgcolor) == "undefined")
	{
		if (typeof(oTR.cells[0].oldbgcolor) != "undefined")
		{
			for (var x = 0; x < oTR.cells.length; x++)
			{
				oTR.cells[x].bgColor = oTR.cells[x].oldbgcolor;
				oTR.cells[x].style.borderTop = "1px solid " + oTR.cells[x].oldbgcolor;
				oTR.cells[x].style.borderBottom = "1px solid " + oTR.cells[x].oldbgcolor;
			}
			oTR.cells[0].style.borderLeft = "1px solid " + oTR.cells[0].oldbgcolor;
			oTR.cells[oTR.cells.length - 1].style.borderRight = "1px solid " + oTR.cells[oTR.cells.length - 1].oldbgcolor;
		}
		return;
	}
	if (bgcolor == "")
		bgcolor = "gainsboro";
	if ((typeof(border) == "undefined") || (border == ""))
		border = "1px solid darkgray";
	for (var x = 0; x < oTR.cells.length; x++)
	{
		oTR.cells[x].oldbgcolor = oTR.cells[x].bgColor;
		oTR.cells[x].style.borderTop = border;
		oTR.cells[x].style.borderBottom = border;
		oTR.cells[x].bgColor = bgcolor;
	}
	oTR.cells[0].style.borderLeft = border;
	oTR.cells[oTR.cells.length - 1].style.borderRight = border;
}

function ShowToolbarMenu(obj)
{
	ShowBorder(obj);
	ShowSubMenu(obj.parentNode.parentNode.parentNode.parentNode);	
}

function HideToolbarMenu(obj)
{
	HideBorder(obj);
	HideSubMenu(obj.parentNode.parentNode.parentNode.parentNode);	
}

function DisplayToolBarButton(obj, dis)
{
	obj.style.display = dis;
	if (obj.nextSibling != null)
		obj.nextSibling.style.display = dis;
}

function FindParentObject(oStart, oEnd, tagName)
{
	for (var obj = oStart; obj != oEnd; obj = obj.parentNode)
	{
		if (obj == null)
			return;
		if (obj.tagName == tagName)
			return obj;
	}
}

function isParentObj(obj1, obj2)
{
	for (var obj = obj1; obj != document.body; obj = obj.parentNode)
	{
		if (obj == null)
			break;
		if (obj == obj2)
			return true;
	}
	return false;
}

function GetObjPos(obj, p)	
{
	var to = new Object();
	to.left = to.right = to.top = to.bottom = 0;
	var twidth = obj.offsetWidth;
	var theight = obj.offsetHeight;
	if (typeof(p) == "undefined")
		p = obj.ownerDocument.body;
	while (obj != p)
	{
		to.left += obj.offsetLeft - obj.scrollLeft;
		to.top += obj.offsetTop - obj.scrollTop;
		obj = obj.offsetParent;
		if (obj == null)
			break;
		if ((typeof(p) == "string") && (obj.tagName.toUpperCase() == p.toUpperCase()))
			break;
	}
	to.right = to.left + twidth;
	to.bottom = to.top + theight;
	return to;
}


function IsChild(child, obj)
{
	var all = objall(obj);
	for (var x = 0; x < all.length; x++)
	{
		if (all[x] == child)
			return true;
	}
	return false;
}


function GetHTMLSelectText(oSel)
{
var x, value;	

	if (oSel.length > 0)
	{
		value = oSel.options(0).text
		for (x = 1; x < oSel.length; x++)
			value += "|" + oSel.options(x).text
	}
	else
		value = ""
	return value;
}

function SelectQuoteTable(oImg, TableName, QuoteField, AliasField, value)
{
var oAlias, str,sEvalStr,nDot,sTemp,sTemp1;
	var frame = document.getElementsByName("FormDataFrame")[0];
	frame.src = "about:blank";
	frame.style.display = "none";
	oAlias = oImg.previousSibling.previousSibling;
	var condition = objattr(oImg, "condition");
	if (condition.substr(0, 1) == "$")
	{
		str = showModalDialog(psubdir + "SeleQuoteTabEx.jsp?TableName=" + TableName + 
			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
			escape(condition) + "&AliasValue=" + oAlias.value, window, 
			"dialogWidth:680px;dialogHeight:600px;scroll:0;help:0;status:0;resizable:1");
	}
	else
	{
	  if (condition.substr(0, 1) == "#")
	  {	  sTemp = condition.substr(1);
		  nDot = sTemp.indexOf(",");
		  if (nDot!=-1){
				sEvalStr=eval(sTemp.substr(nDot+1));
				sTemp1=sTemp.substr(0,nDot);
		  }
		  else{
			  sEvalStr=idobj(sTemp).value;
			  sTemp1=sTemp;
		  }
		  if (sEvalStr!="")
		  {
		  sTemp=sTemp1+"="+sEvalStr;
		  }
		  else{sTemp=""}
		  //alert(sTemp);
			str = showModalDialog(psubdir + "SeleQuoteTable.jsp?TableName=" + TableName + 
			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
			sTemp+ "&AliasValue=" + oAlias.value, "", "dialogWidth:300px;scroll:0;help:0;status:0;resizable:1");
	  }
	  else
	  {
			str = showModalDialog(psubdir + "SeleQuoteTable.jsp?TableName=" + TableName + 
			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
			escape(condition) + "&AliasValue=" + oAlias.value, "", "dialogWidth:360px;scroll:0;help:0;status:0;resizable:1");
	  }
	}
	
	// w3c lxt 2017.12.26
	if(window.g_isChrome){
		if(window.g_SelectQuoteTableLoopTime){
			window.clearTimeout(window.g_SelectQuoteTableLoopTime);
			window.g_SelectQuoteTableLoopTime=0;
		}
		var funcx=function(){
			if(window.localStorage["SeleQuoteTableReturnValue"]){
				str=window.localStorage["SeleQuoteTableReturnValue"]+"";
				window.localStorage.removeItem("SeleQuoteTableReturnValue");
				ConfirmQuoteTable(str, oAlias);
				return;
			}
			window.g_SelectQuoteTableLoopTimer=setTimeout(funcx, 1000);
		};
		setTimeout(funcx, 1000);
		return;
	}
	
	return ConfirmQuoteTable(str, oAlias);
}

function ConfirmQuoteTable(str, oAlias)
{
var oInput, s, s1, s2, obj;
	if (typeof(str) == "string")
	{
		oInput =oAlias.parentNode.getElementsByTagName("INPUT");
		s = str.split("|,|");
		if ((s.length > 1) && (oInput.length > 1))
		{
			if (oInput[0].value != s[0])
			{
				oInput[0].value = s[0];
				oInput[1].value = s[1];
				fireobjevt(oInput[0], "change");
			}
		}
		else
		{
			if (oInput[0].value != s[0])
			{
				oInput[0].value = s[0];
				fireobjevt(oInput[0], "change");
			}
		}
	}
	return str;
}

function CBSelectQuoteTable(obj, TableName, QuoteField, AliasField, value)
{
var oAlias, str,sEvalStr,nDot,sTemp,sTemp1;
	var frame = document.getElementsByName("FormDataFrame")[0];
	frame.src = "about:blank";
	frame.style.display = "none";

	oAlias = obj.lastChild;
	var condition = objattr(obj, "condition");
	if (condition.substr(0, 1) == "$")
	{
		str = showModalDialog(psubdir + "SeleQuoteTabEx.jsp?TableName=" + TableName + 
			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
			escape(condition) + "&AliasValue=" + oAlias.value, window.parent, 
			"dialogWidth:680px;dialogHeight:600px;scroll:0;help:0;status:0;resizable:1");
	}
	else
	{
	  if (condition.substr(0, 1) == "#")
	  {	  sTemp = condition.substr(1);
		  nDot=sTemp.indexOf(",");
		  if (nDot!=-1){
				sEvalStr=eval(sTemp.substr(nDot+1));
				sTemp1=sTemp.substr(0,nDot);
		  }
		  else{
			  sEvalStr=idobj(sTemp).value;
			  sTemp1=sTemp;
		  }
		  if (sEvalStr!="")
		  {
		  sTemp=sTemp1+"="+sEvalStr;
		  }
		  else{sTemp=""}
		  //alert(sTemp);
			str = showModalDialog(psubdir + "SeleQuoteTable.jsp?TableName=" + TableName + 
			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
			sTemp+ "&AliasValue=" + oAlias.value, "", "dialogWidth:300px;scroll:0;help:0;status:0;resizable:1");
	  }
	  else
	  {
	SelectCombo(obj, psubdir + "SeleQuoteTable.jsp?bIFrame=1&TableName=" + TableName + 
			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
			escape(condition) + "&AliasValue=" + oAlias.value);
return;
//			str = showModalDialog(psubdir + "SeleQuoteTable.jsp?TableName=" + TableName + 
//			"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
//			escape(oImg.condition) + "&AliasValue=" + oAlias.value, "", "dialogWidth:300px;scroll:0;help:0;status:0;resizable:1");
	  }
	}
	return ConfirmQuoteTable(str, oAlias);
}


function RunSubMenu(ModuleNo)
{
	obj = document.getElementById("submenu" + ModuleNo);
	if (obj == null)
		return;
	obj.click();
}

function ResizeFlowFrame()
{
	var oTable = idobj("flowtable");
	var len = document.body.clientHeight - oTable.clientHeight + 2 - 50;
	if (len < 1)
		len = 1;
	idobj("FlowChartDIV").style.height = len;
}

function GetFileName(url)
{
	var x = url.lastIndexOf("\\");
	if (x > 0)
		return url.substr(x + 1);
	x = url.lastIndexOf("/");
	if (x > 0)
		return url.substr(x + 1);
}

function GetFileExtName(filename)
{
	var x = filename.lastIndexOf(".");
	if (x > 0)
		return filename.substr(x);
	return "";
}


function SelectColor(oImg, param)
{
	return SelectDialog(oImg, psubdir + "SeleColor.jsp", "dialogWidth:360px;dialogHeight:290px;status:0;help:0", param);
}

function SelectColors(oImg)
{
	return SelectDialogValue(oImg, psubdir + "SeleColor.jsp", "dialogWidth:360px;dialogHeight:280px;status:0;help:0");
}

function SelectFont(oImg)
{
	return SelectDialog(oImg, psubdir + "SeleFont.htm", "dialogWidth:18.5em; dialogHeight:17.5em; status:0; help:0");
}

function SelectImg(oImg, PathName)
{
	var value = "";
	if (typeof(oImg) == "object")
	{
		var oInput =oImg.parentNode.getElementsByTagName("INPUT");
		if (oInput.length == 1)
			value= oInput[0].value;
	}
	if (value == "")
		value = "ICON";
	return SelectDialog(oImg, "SeleImg.asp?PathName=" + PathName + "&Value=" + value);
}

function SubmitAffixFile(obj,ParentID)
{
var param = "";
	if (typeof(obj) == "object")
		param = "?ParentTagName=" + obj.parentNode.id;
	if (typeof(obj) != "undefined")
	{
		if (param == "")
			param = "?ParentID=" + ParentID;
		else
			param += "&ParentID=" + ParentID;
	}
	var oNewWin = NewHref("/UpFileForm.asp" + param, "width=480,height=360,scrollbars=0,status=0");
}

function SelectAffixFile(obj, param)
{
var condition = "";
	if (typeof(param) == "string")
			condition = "?ParentName=" + param
	if (typeof(param) == "number")
			condition = "?ParentID=" + param
	
	var AffixFile = showModalDialog("/SeleAffixFile.asp" + condition, "", 
		"dialogWidth:640px;dialogHeight:480px;scroll:0;help:0;status:0");
	if (typeof(AffixFile) == "undefined")
		return;
	if (typeof(obj) == "object")
	{
		var oInput =obj.parentNode.getElementsByTagName("INPUT");
		var s = AffixFile.split(":")
		oInput[0].value = s[0];
		oInput[1].value = s[1];
	}
	return AffixFile;
}

function SelectImgAffixFile(obj)
{
	var ff = SelectTableRecord(0, 8, "0,1", ":", 0, "ViewMode=6");
	if (typeof(ff) == "undefined")
		return;
	if (typeof(obj) == "object")
	{
		var s = ff.split(":")
		var http_request = new ActiveXObject("Microsoft.XMLHTTP");
		http_request.onreadystatechange = function()
		{
			if (http_request.readyState == 4)
			{
				obj.outerHTML = http_request.responseText;
			}
		};
		http_request.open("GET", "/RunCmd.asp?Cmd=GetThumbNailPic&nType=1&Param=" + s[0], true);
		http_request.send();
		var oInput =obj.parentNode.getElementsByTagName("INPUT");
		oInput[0].value = s[0];
	}
	return ff;
}


function DownAffixFile(AffixID)
{
	if (IsNetBoxWindow())
		location.href = "/DownAffix.asp?AffixID=" + AffixID;
	else
		var oNewWin = NewHref("/DownAffix.asp?AffixID=" + AffixID, "width=300,height=200,status=0,resizable=1");
}

function FlowMon(FlowMonID)
{
	NewHref("/MonFlow.asp?FlowMonID=" + FlowMonID,
			"menubar=0,toolbar=0,location=0,status=0,width=400,height=150,scrollbars=0,resizable=0");
}

function PushButton(oImg)
{
	oImg.style.borderStyle = "inset";
}

function UnPushButton(oImg)
{
	oImg.style.borderStyle = "outset";
}

function ShowBorder(obj)
{
	obj.oldborder = obj.style.border;
	obj.style.border = "1px outset gray";
	obj.oldmargin = obj.style.margin;
	obj.style.margin = "0px";
}

function HideBorder(obj)
{
	if (typeof(obj.oldborder) != "undefined")
		obj.style.border = obj.oldborder;
	if (typeof(obj.oldmargin) != "undefined")
		obj.style.margin = obj.oldmargin;
}

function ShowTool(obj)
{
	ShowBorder(obj);
	obj.oldborder = obj.style.border;
	obj.oldmargin = "0px";
	obj.oldcolor = obj.style.backgroundColor;
	obj.style.backgroundColor = "white";
}

function HideTool(obj)
{
	obj.oldborder = "0px none";
	obj.oldmargin = "1px";
	HideBorder(obj);
	obj.style.backgroundColor = obj.oldcolor;
}

function ShowButton(obj)
{
	ShowBorder(obj);
	obj.oldcolor = obj.style.backgroundColor;
	obj.style.backgroundColor = "white";
	obj.width = parseInt(obj.width) - 2;
}

function HideButton(obj)
{
	HideBorder(obj);
	obj.style.backgroundColor = obj.oldcolor;
	obj.width = parseInt(obj.width) + 2;
}

function DrawShadow(obj, color, size)
{
var x, oShadow, opacity;
	if (obj.bDrawShadow == 1)
		return;
	obj.bDrawShadow = 1;
	obj.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=" + size + ",color=" + color + ")";
}

function SelectTableRecord(oImg, Action, SelFields, colsp, rowsp, condition, sFeature)
{
	var sp = "";
	if (typeof(colsp) == "string")
		sp = "&ColSP=" + colsp;
	if (typeof(rowsp) == "string")
		sp += "&RowSP=" + rowsp;
	if (typeof(SelFields) == "undefined")
		SelFields = 0;
	if (typeof(condition) != "string")
		condition = "";
	else
		condition = "&condition=" + escape(condition)
	if (typeof(sFeature) == "undefined")
		sFeature = "dialogWidth:800px;dialogHeight:600px;scroll:no;help:no;status:no;resizable:1";
	return SelectDialog(oImg, psubdir + "seleTableRec.jsp?Action=" + Action + "&SelFields=" + SelFields + sp + condition, 
		sFeature);
}

function SelectTextEditDlg(oImg, title)
{
var value, href = "/SeleTextEdit.htm";
	if (typeof(oImg) == "object")
	{
		var oInput =oImg.parentNode.getElementsByTagName("TEXTAREA");
		if (oInput.length == 1)
			var value = oInput[0];
		else
		{
			var oInput =oImg.parentNode.getElementsByTagName("INPUT");
			if (oInput.length == 1)
				value = oInput[0];
		}
	}
	if (typeof(title) == "string")
		href = href + "?title=" + title;
	return SelectDialog(oImg, href, "dialogWidth:640px;dialogHeight=480px;scroll:no;help:no;status:no;resizable:1", value);
	
}

function IsNetBoxWindow()
{
	if ((typeof(window.external) == "object") && (window.external != null))
	{
		if (typeof(window.external.Visible) == "boolean")
			return true;
	}	
	return false;
}

function IsNetBoxRunning()
{
	try
	{
		var NetBox = new ActiveXObject("NetBox");
		return true;
	}
	catch(e)
	{
		return false;
	}
}

function LTrim(s, w)
{
//	return str.replace(/^\s*/g,"");
	if (typeof(w) == "undefined")
		w = " \t\n\r";
	if (w.indexOf(s.charAt(0)) != -1)
	{
		var j=0, i = s.length;
		while (j < i && w.indexOf(s.charAt(j)) != -1)
			j++;
		s = s.substring(j, i);
	}
	return s;
}

function RTrim(s, w)
{
//	return str.replace(/\s*$/g,"");
	if (typeof(w) == "undefined")
		w = " \t\n\r";
	if (w.indexOf(s.charAt(s.length-1)) != -1)
	{
		var i = s.length - 1;
		while (i >= 0 && w.indexOf(s.charAt(i)) != -1)
			i--;
		s = s.substring(0, i+1);
	}
	return s;
}

function Trim(str)
{
	return str.replace(/^\s*|\s*$/g,"");
//	return RTrim(LTrim(str));
}

function AppendURLParam(url, param)
{
	if (param == "")
		return url;
	if (url.search(/[?]/) == -1)
		return url + "?" + param;
	else
		return url + "&" + param;
}

function CheckURL(url)
{
	if (!/^https?:\/\//.test(url))
		return  "http://" + url;
	else
		return url;
}

function IsImageFile(filename)
{
	return IsFileExt(filename, "gif,jpg,bmp,emf,png,wmf,xbm,jpeg");
}

function IsFileExt(filename, exf)
{
	var ef = exf.split(",");
	for (var x = 0; x < ef.length; x++)
	{
		if (filename.substr(filename.length - ef[x].length).toLowerCase() == ef[x])
			return true;
	}
	return false;
}

var dragObj, clickleft, clicktop;
var g_nResize = 0;
function BeginDragObj(obj, flag)
{
	ResizeCursorObj(obj);
	if (obj.nSize > 0)
	{
		g_nResize = obj.nSize;
		document.onmousemove = ResizingObj;
	}
	else
	{
		if (flag == false)
			return;
		document.onmousemove = DragingObj;
	}
	DragInit(obj);
}

function DragInit(obj)
{
	document.onmouseup = EndDragObj;
	document.ondragstart = DragingObj;
//	obj.style.zIndex += 1;
//	obj.setActive();
	if (typeof(dragObj) == "object")
		dragObj.style.zIndex = dragObj.oldIndex;
	obj.oldIndex = obj.style.zIndex;
	obj.style.zIndex = 50;
	dragObj = obj;
	var evt = getEvent();
	if (evt != null)
	{
		clickleft = evt.screenX - parseInt(obj.style.left);
		clicktop = evt.screenY - parseInt(obj.style.top);
	}
	try {
		obj.setCapture();
	} catch(e) {
	}
}


function DragingObj()
{
	if (typeof dragObj != "object")
		return EndDragObj();
	var evt = getEvent();
	dragObj.style.left = (evt.screenX - clickleft) + "px";
	dragObj.style.top = (evt.screenY - clicktop) + "px";
	evt.returnValue = false;
}

function EndDragObj()
{
	document.onmousemove = null;
	document.onmouseup = null;
	document.ondragstart = null;
	g_nResize = 0;
	dragObj.nSize = 0;
	dragObj = 0;
	
	try {
		document.releaseCapture();
	} catch(e) {
	}
}

function ResizeCursorObj(obj)
{
	var d = 0;
	if (g_nResize > 0)
		return;
	var evt = getEvent();
	if (evt.x < obj.offsetLeft + 4 - obj.offsetParent.scrollLeft)
		d = 1;
	if (evt.y < obj.offsetTop + 4 - obj.offsetParent.scrollTop)
		d += 2;
	if (evt.x > obj.offsetLeft + obj.offsetWidth - 4 - obj.offsetParent.scrollLeft)
		d += 4;
	if (evt.y > obj.offsetTop + obj.offsetHeight - 4 - obj.offsetParent.scrollTop)
		d += 8;
	obj.nSize = d;
	SetResizeCursor(obj, d);
}

function SetResizeCursor(obj, nSize)
{
	switch (nSize)
	{
	case 0:
		obj.style.cursor = "auto";
		break;
	case 1:
		obj.style.cursor = "W-resize";
		break;
	case 2:
		obj.style.cursor = "N-resize";
		break;
	case 3:
		obj.style.cursor = "NW-resize";
		break;
	case 4:
		obj.style.cursor = "E-resize";
		break;
	case 6:		
		obj.style.cursor = "NE-resize";
		break;
	case 8:
		obj.style.cursor = "S-resize";
		break;
	case 9:
		obj.style.cursor = "SW-resize";
		break;
	case 12:
		obj.style.cursor = "SE-resize";
		break;
	}
}

function ResizingObj()
{
	if (g_nResize > 0)
	{
		var evt = getEvent();
		switch (g_nResize)
		{
		case 12:			//右下
			dragObj.style.width = (evt.x - parseInt(dragObj.style.left) + dragObj.offsetParent.scrollLeft) + "px";
			dragObj.style.height = (evt.y - parseInt(dragObj.style.top) + dragObj.offsetParent.scrollTop) + "px";
			break;
		case 9:				//左下
			dragObj.style.width = (parseInt(dragObj.style.width) + parseInt(dragObj.style.left) - evt.x - dragObj.offsetParent.scrollLeft) + "px";
			dragObj.style.left = (evt.x + dragObj.offsetParent.scrollLeft) + "px";
			dragObj.style.height = (evt.y - parseInt(dragObj.style.top) + dragObj.offsetParent.scrollTop) + "px";
			break;
		case 8:				//下
			dragObj.style.height = (evt.y - parseInt(dragObj.style.top) + dragObj.offsetParent.scrollTop) + "px";
			break;
		case 4:				//右
			dragObj.style.width = (evt.x - parseInt(dragObj.style.left) + dragObj.offsetParent.scrollLeft) + "px";
			break;
		case 6:				//右上
			dragObj.style.height = (parseInt(dragObj.style.height) + parseInt(dragObj.style.top) - evt.y - dragObj.offsetParent.scrollTop) + "px";
			dragObj.style.top = evt.y + dragObj.offsetParent.scrollTop + "px";
			dragObj.style.width = (evt.x - parseInt(dragObj.style.left) + dragObj.offsetParent.scrollLeft) + "px";
			break;
		case 1:				//左
			dragObj.style.width = (parseInt(dragObj.style.width) + parseInt(dragObj.style.left) - evt.x - dragObj.offsetParent.scrollLeft) + "px";
			dragObj.style.left = (evt.x + dragObj.offsetParent.scrollLeft) + "px";
			break;
		case 2:				//上
			dragObj.style.height = (parseInt(dragObj.style.height) + parseInt(dragObj.style.top) - evt.y - dragObj.offsetParent.scrollTop) + "px";
			dragObj.style.top = (evt.y + dragObj.offsetParent.scrollTop) + "px";
			break;
		case 3:				//左上
			dragObj.style.width = (parseInt(dragObj.style.width) + parseInt(dragObj.style.left) - evt.x - dragObj.offsetParent.scrollLeft) + "px";
			dragObj.style.left = (evt.x + dragObj.offsetParent.scrollLeft) + "px";
			dragObj.style.height = (parseInt(dragObj.style.height) + parseInt(dragObj.style.top) - evt.y - dragObj.offsetParent.scrollTop) + "px";
			dragObj.style.top = (evt.y + dragObj.offsetParent.scrollTop) + "px";
			break;
		}
		if (parseInt(dragObj.style.height) < 10)
			dragObj.style.height = "10px";
		if (parseInt(dragObj.style.width) < 10)
			dragObj.style.width = "10px";
	}
}

function AjaxRequestPage(page, mode, postdata, fun)
{
	var http_request = null;
	try {
		http_request = new ActiveXObject("Microsoft.XMLHTTP");
	} catch (e) {
		http_request = new XMLHttpRequest();
	}
	if (typeof(mode) == "undefined")
		mode = true;
	if (mode)
	{
		http_request.onreadystatechange = function()
		{
			if (http_request.readyState == 4)
			{
				if (typeof(fun) == "function")
					fun(http_request.responseText);
				if (typeof(fun) == "string")
					eval(fun);
				http_request = null;
			}
		};
	}
	if ((typeof(postdata) != "string") || (postdata == ""))
	{
		http_request.open("GET", page, mode);
		http_request.setRequestHeader("If-Modified-Since","0");
		var result = http_request.send();
	}
	else
	{
		http_request.open("POST", page, mode);
		http_request.setRequestHeader("content-length",postdata.length); 
		http_request.setRequestHeader("content-type","application/x-www-form-urlencoded;charset=utf-8"); 
		var result = http_request.send(postdata);
	}
	if (mode)
		return result;
	return http_request.responseText;
}

function ShowHTMLCode(str)
{
	var w=window.open('','');
	var d=w.document;
	d.open();
	str=str.replace(/=(?!")(.*?)(?!")( |>)/g,"=\"$1\"$2");
	str=str.replace(/(<)(.*?)(>)/g,"<span style='color:red;'>&lt;$2&gt;</span><br />");
	str=str.replace(/\r/g,"<br />\n");
	d.write(str);
}

function ShowServerImg(filename)
{
	var oNewWin = NewHref("about:blank", "width=640,height=480,resizable=1,status=0");
	oNewWin.document.write("<HTML><HEAD><title><j:Lang key="psub.Image_select"/></title></HEAD><BODY topmargin=0 leftmargin=0>h_psub<img src=/Download.asp?FileURL=" +
		escape(filename) + "></BODY></HTML>");
	oNewWin.document.close();	
}

function FocusInput(obj)
{
	if (obj.bempty == 1)
	{
		obj.title = obj.value;
		obj.value = "";
		obj.style.color = "black";
	}
	obj.oldborder = obj.style.border;
	if (obj.style.borderStyle == "none")
		obj.style.border = "1px solid gray";
}

function PopupMenu(oMenu, oPop, x, y, filter)
{
	var evt = getEvent();
	if (typeof(oMenu) == "object")
	{
		oPop.document.body.innerHTML = oMenu.outerHTML;
		oPop.document.body.firstChild.style.display = "block";
		var oTable = oPop.document.getElementsByTagName("TABLE")[0];
		oTable.style.fontSize = "9pt";
		if (typeof filter == "object")
		{
			var ss = filter.str.split(",");
			var flag = 1, delfalg;
			for (var xx = oTable.rows.length - 1; xx >= 0; xx--)
			{
				if (Trim(oTable.rows[xx].innerText) == "")
				{
					if (flag == 1)
					{
							oTable.rows[xx].removeNode(true);
							oTable.rows[xx - 1].removeNode(true);
					}
					flag = 1;
					xx --;
				}
				else
				{
					if (filter.disable == 1)
					{
						delflag = 0;
						for (var yy = 0; yy < ss.length; yy++)
						{
							if (Trim(oTable.rows[xx].innerText) == ss[yy])
							{
								oTable.rows[xx].removeNode(true);
								delflag = 1;
								break;
							}
						}
					}
					else
					{
						delflag = 1;
						for (var yy = 0; yy < ss.length; yy++)
						{
							if (Trim(oTable.rows[xx].innerText) == ss[yy])
							{
								delflag = 0;
								break;
							}
						}
						if (delflag == 1)
							oTable.rows[xx].removeNode(true);
					}
					if (delflag == 0)
						flag = 0;
				}
			}
			if (oTable.rows.length == 0)
				return;
		}
		if (typeof(x) == "undefined")
		{
			x = evt.screenX;
			y = evt.screenY;
		}

		oPop.show(x, y, 1, 1);
		var width = oPop.document.body.firstChild.offsetWidth;
		var height = oPop.document.body.firstChild.offsetHeight;

		if (x + width + 2 > screen.width)
			x = screen.width - width - 2;
		if (y + height + 2 > screen.height)
			y = screen.height - height - 2;

		oPop.show(x, y, width + 2, height + 2);
		return true;
	}
}

function SetMenuRadioStatus(oItem, oMenu)
{
var obj;
	oItem.cells[0].innerHTML = "<img src=" + psubdir + "pic/bacocheck.gif>";
	obj = oItem;
	while (true)
	{
		obj = obj.nextSibling;
		if ((obj.tagName != "TR") || (obj.height == 3))
			break;
		obj.cells[0].innerHTML = "";
	}
	obj = oItem;
	while (true)
	{
		obj = obj.previousSibling;
		if ((obj.tagName != "TR") || (obj.height == 3))
			break;
		obj.cells[0].innerHTML = "";
	}
	if (typeof(oMenu) != "object")
		return;
	HighlightTR(oItem);
	oItem.ownerDocument.body.firstChild.style.display = "none";
	oMenu.outerHTML = oItem.ownerDocument.body.innerHTML;
}

function SetMenuCheckStatus(oItem, oMenu, status)
{
	if (status == 1)
		oItem.cells[0].innerHTML = "<img src=" + psubdir + "pic/bacocheck.gif>";
	else
		oItem.cells[0].innerHTML = "&nbsp;";
	if (typeof(oMenu) != "object")
		return;
	HighlightTR(oItem);
	oItem.ownerDocument.body.firstChild.style.display = "none";
	oMenu.outerHTML = oItem.ownerDocument.body.innerHTML;
}

function GetMenuCheckStatus(oItem)
{
	if (oItem.cells[0].innerHTML == "&nbsp;")
		return 0;
	return	1;
}


function StrAddItem(str, s, t)
{
	if (str == "")
		return s;
	else
		return str + t + s;
}

function EditToCombo(oEdit, items, value)
{
	if ((typeof(items) != "string") || (items == ""))
		return;
	oEdit.insertAdjacentHTML("beforeBegin", "<select name=InlineSelect style='position:absolute;' " +
		"onchange='this.nextSibling.value=this.value;this.value=\"\";'></select>");
	var oSel = oEdit.previousSibling;
	var w = oEdit.clientWidth;
	var h = oEdit.clientHeight;
	oSel.style.top = (oSel.offsetTop + 1) + "px";
	oSel.style.left = (oSel.offsetLeft + 4) + "px";
	oSel.style.width = w + "px";
	oSel.style.height = h + "px";
	oSel.style.clip = "rect(0," + w + "," + (h + 4) + "," + (w - 18) + ")";
	var ss = items.split(",");
	for (var x = 0; x < ss.length; x++)
	{
		var oOption = document.createElement("OPTION");
		oOption.text = ss[x];
		oOption.value = ss[x];
		oSel.options.add(oOption);
	}
	if (typeof(value) == "string")
		oEdit.value = value;
	else
		oEdit.value = ss[0];
	oSel.value = "";
}

function GetScrollInput(title, defaultvalue, minvalue, maxvalue, action)
{
	return "<div style='border:1px solid gray;width=100%;height:100%;font-size:9pt;'>" +
		"<span style='vertical-align:top;height:100%;' maxvalue=" + maxvalue + " minvalue=" + minvalue + ">" +
		"<img src=" + psubdir + "pic/prev.gif onmousedown=parent.BeginSpinScroll(this,-1) onmouseup=parent.EndSpinScroll(this)>" +
		"<img src=" + psubdir + "pic/next.gif onmousedown=parent.BeginSpinScroll(this,1) onmouseup=parent.EndSpinScroll(this)><BR>&nbsp;" +
		title +"&nbsp;</span><span onmousedown=\"this.firstChild.style.left=(event.offsetX-5)+'px';" +
		"this.parentNode.lastChild.innerHTML=parseInt(" + minvalue + "+ parseInt(this.firstChild.style.left)*" +
		(maxvalue - minvalue) + "/100);\" style='" +
		"margin-top:10px;width:111px;height:20px;background:url(" + psubdir + "pic/boardbk5a.gif) no-repeat center left;'>" +
		"<img src=" + psubdir + "pic/point.gif style=cursor:hand;position:relative;left:" + 
		parseInt((defaultvalue - minvalue)* 100 / (maxvalue - minvalue)) + "px; offsetX=-1 onmousemove=\"" +
		"if (this.offsetX>=0){this.style.left=Math.min(100,Math.max(0,parseInt(this.style.left)+event.screenX-this.offsetX)) + 'px';" +
		"this.offsetX=event.screenX;this.parentNode.parentNode.lastChild.innerHTML=parseInt(" + minvalue + 
		"+ parseInt(this.style.left)*" + (maxvalue - minvalue) + "/100);}'" +
		" onmousedown='this.setCapture();this.offsetX=event.screenX;event.cancelBubble=true;' onmouseup='this.offsetX=-1;this.releaseCapture();" + 
		action + "(this,this.parentNode.parentNode.lastChild.innerText);')></span>" + "&nbsp<span>" +
		defaultvalue + "</span></div>"
}

function BeginSpinScroll(obj, pos)
{
	obj.parentNode.keypress = 1;
	obj.setCapture();
	SpinScroll(obj, pos);
}

function SpinScroll(obj, pos)
{
	if (obj.parentNode.keypress == 0)
		return;
	var value = parseInt(obj.parentNode.parentNode.lastChild.innerText) + pos;
	if ((value > obj.parentNode.maxvalue) || (value < obj.parentNode.minvalue))
		return;
	obj.parentNode.parentNode.lastChild.innerHTML = value;
	obj.parentNode.nextSibling.firstChild.style.left = parseInt((value - obj.parentNode.minvalue)* 100 /
		(obj.parentNode.maxvalue - obj.parentNode.minvalue)) + "px";
	setTimeout(function(){SpinScroll(obj, pos);}, 200);
}

function EndSpinScroll(obj)
{
	obj.parentNode.keypress = 0;
	obj.releaseCapture();
	fireobjevt(obj.parentNode.nextSibling.firstChild, "mouseup");
}

function CheckDocUpdate()
{
	if (IsNetBoxRunning())
	{
		var NetBox = new ActiveXObject("NetBox");
		if (typeof this.id == "undefined")
		{
			NetBox.Contents.Remove("HWND_Refresh");
			this.id = window.setInterval("CheckDocUpdate();", 1000);
			return;
		}
		if (typeof(NetBox("HWND_Refresh")) == "undefined")
			return;
		var hwnd = NetBox("HWND_Refresh");
		NetBox.Contents.Remove("HWND_Refresh");
		if (hwnd == 0)
			return window.clearInterval(this.id);
		if (hwnd == window.external.HWND)
			window.location.reload(true);
	}
}

function ConfirmDlg(msg)
{
	if (IsNetBoxRunning())
	{
		var Shell = new ActiveXObject("Shell");
		var result = Shell.MsgBox(msg, "<j:Lang key="psub.Wenjian_tishi"/>", 1 + 32);
		if (result == 1)
			return true;
		else
			return false;
	}
	else
		return window.confirm(msg);
}

function TableRowShift(rowobj, offset)
{
	if (typeof(rowobj) != "object")
		return -1; 
	if ((rowobj.rowIndex + offset < 0) || (rowobj.rowIndex + offset >= rowobj.parentNode.parentNode.rows.length))
	{
		rowobj.parentNode.insertBefore(rowobj, null);
		return 0;
	}

	rowobj.parentNode.insertBefore(rowobj, rowobj.parentNode.rows[rowobj.rowIndex + offset]);
	return 0;
}

function GetValidDate(value, smin, smax, sdft)
{
var s, d, t, tdft, tmin, tmax;
	s = value.split(" ");
	d = s[0].split("-");
	tdft = GetDate(sdft);
	tmin = GetDate(smin);
	tmax = GetDate(smax);
	if (s.length == 2)
	{
		t = s[1].split(":");
		return new Date(GetValue(d[0], tdft.getFullYear(), tmin.getFullYear(), tmax.getFullYear()), 
			GetValue(d[1] - 1, tdft.getMonth(), tmin.getMonth(), tmax.getMonth()),
			GetValue(d[2], tdft.getDate(), tmin.getDate(), tmax.getDate()),
			GetValue(t[0], tdft.getHours(), tmin.getHours(), tmax.getHours()), 
			GetValue(t[1], tdft.getMinutes(), tmin.getMinutes(), tmax.getMinutes()),
			GetValue(t[2], tdft.getSeconds(), tmin.getSeconds(), tmax.getSeconds()));
	}
	else
		return new Date(GetValue(d[0], tdft.getFullYear(), tmin.getFullYear(), tmax.getFullYear()), 
			GetValue(d[1] - 1, tdft.getMonth(), tmin.getMonth(), tmax.getMonth()));
}

function GetValidDateStr(value, smin, smax, sdft)
{
	if (typeof(sdft) == "undefined")
		sdft = GetDateTimeString(new Date(), 7);
	if (typeof(smax) == "undefined")
		smax = "2999-12-31 23:59:59";
	if (typeof(smin) == "undefined")
		smin = "1752-01-01 00:00:00";
	value = GetValidDate(value, smin, smax, sdft);
	if (smin.length == 16)
		return GetDateTimeString(value, 8);
	return GetDateTimeString(value, 7);
}

function GetValue(v, d, min, max)
{
	var result = parseInt(v, 10);
	if (isNaN(result))
		return d;
	if (result < min)
		return min;
	if (result > max)
		return max;
	return result;
}



function BeginDragRow(obj)
{
var pos, tableObj, dragObj, dropObj, hitObj, x, y;
	tableObj = obj.parentNode.parentNode.parentNode;
	pos = GetObjPos(obj);	
	document.body.insertAdjacentHTML("beforeEnd", "<div id=DragRowTD style='position:absolute;left:" + pos.left +
		"px;top:" + (pos.top - tableObj.parentNode.scrollTop) + "px;width:" + (pos.right - pos.left) + 
		"px;height:" + (pos.bottom - pos.top) + "px;border:solid 1px red;padding-left:3px;background-color:white'>" +
		obj.innerHTML + "</div>");
	dragObj = idobj("DragRowTD");
	dropObj = obj;
	var evt = getEvent();
	y = evt.screenY - parseInt(dragObj.style.top);
	dragObj.setCapture();
	document.ondragstart = function ()
	{
		dragObj.style.top = (evt.screenY - y) + "px";
		hitObj = document.elementFromPoint(pos.right + 1, evt.clientY);
		if ((hitObj != null) && (hitObj.tagName == "TD") && (hitObj.parentNode.parentNode.parentNode == tableObj))
		{
			dragObj.style.borderColor = "green";
			for (x = 0; x < dropObj.parentNode.cells.length; x++)
				dropObj.parentNode.cells[x].style.borderBottom = "none";
			dropObj = hitObj;
			for (x = 0; x < dropObj.parentNode.cells.length; x++)
				dropObj.parentNode.cells[x].style.borderBottom = "1px solid green";
		}
		else
		{
			dragObj.style.borderColor = "red";
			for (x = 0; x < dropObj.parentNode.cells.length; x++)
				dropObj.parentNode.cells[x].style.borderBottom = "none";
			dropObj = obj;
		}
		evt.returnValue = false;
	}
	document.onmousemove = document.ondragstart;
	document.onmouseup = function ()
	{
		for (x = 0; x < dropObj.parentNode.cells.length; x++)
			dropObj.parentNode.cells[x].style.borderBottom = "none";
		if (dropObj != obj)
		{
			if (obj.parentNode.rowIndex <= dropObj.parentNode.rowIndex)
				tableObj.moveRow(obj.parentNode.rowIndex, dropObj.parentNode.rowIndex);
			else
				tableObj.moveRow(obj.parentNode.rowIndex, dropObj.parentNode.rowIndex + 1);
		}
		dragObj.parentNode.removeChild(dragObj);
		document.ondragstart = null;
		document.onmousemove = null;
		document.onmouseup = null;
		document.releaseCapture();
	}
	evt.returnValue = false;
}

function RightButtonMenu()
{
	if (document.selection.type == "Text")
		return true;
//	var t1 = document.selection.createRange();
//alert(t1.boundingTop + "." + t1.boundingHeight + "." + t1.boundingLeft + "." + t1.boundingWidth);
//	if (t1.boundingHeight > 0)
//		return true;
	var evt = getEvent();
	if ((evt.srcElement.tagName == "INPUT") || (evt.srcElement.tagName == "TEXTAREA"))
		return true;
	return false;
//	var rng = document.body.createTextRange();
	if (evt.srcElement.tagName == "IMG")
	{
//		rng.moveToElementText(event.srcElement);
//		rng.select();
		return true;
	}
	return false;
}

function TRACE(info)
{
	if ((typeof TRACE.win == "undefined") || (TRACE.win.closed == true))
	{
		TRACE.win = window.open("about:blank", "TRACE_DEBUG", "location=0,toolbar=0,resizable=1,width=640,height=480");
		TRACE.win.document.charset = "GBK";
		TRACE.win.document.write("<html><body><textarea style=width:100%;height:100%>" + info + "</textarea></body></html>");
		TRACE.win.document.close();
		return;
	}
	TRACE.win.document.body.firstChild.innerHTML += "\n\n" + info;
	TRACE.win.focus();
}

//==operate png image
function correctPNG()
{
   var docImages=document.images;
   for(var i=0; i<docImages.length; i++)
      {
     var img = docImages[i]
     var imgName = img.src.toUpperCase()
     if (imgName.substring(imgName.length-3, imgName.length) == "PNG")
        {
        	img.style.width=img.width;
        	img.style.height=img.height;
     	 img.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'" + img.src + "\', sizingMethod='scale')";
      	 img.src=gRootPath + "images/point.gif";
      	 //window.alert(img.src);
       //i = i-1
        }
      }
}
   
function alphaBackgrounds(){
   var rslt = navigator.appVersion.match(/MSIE (d+.d+)/, '');
   var itsAllGood = (rslt != null && Number(rslt[1]) >= 5.5);
   var all = objall();
   for (i=0; i < all.length; i++){
      var bg = all[i].currentStyle.backgroundImage;
      if (bg){
         if (bg.match(/.png/i) != null){
            var mypng = bg.substring(5,bg.length-2);
   //alert(mypng);
            all[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+mypng+"', sizingMethod='crop')";
            all[i].style.backgroundImage = "url('')";
   //alert(all[i].style.filter);
         }                                              
      }
   }
}

//if (navigator.platform == "Win32" && navigator.appName == "Microsoft Internet Explorer" && window.attachEvent) {
//window.attachEvent("onload", correctPNG);
//window.attachEvent("onload", alphaBackgrounds);
//}
/*=============处理IE6下PNG的问题============*/
//==预加载内部弹出窗边框用到的PNG图像，以解决图像未加载就滤镜处理问题
try {
new Image().src=psubdir+"../images/405.png";
new Image().src=psubdir+"../images/406.png";
new Image().src=psubdir+"../images/407.png";
new Image().src=psubdir+"../images/408.png";
new Image().src=psubdir+"../images/409.png";
new Image().src=psubdir+"../images/410.png";
new Image().src=psubdir+"../images/411.png";
new Image().src=psubdir+"../images/412.png";
new Image().src=psubdir+"../images/413.png";
} catch(e) {

}
function changePNGSrc(imgF, src)
{
	if(document.all&&!window.XMLHttpRequest){
	imgF.style.width=imgF.width;
	imgF.style.height=imgF.height;
     imgF.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'" + src + "\', sizingMethod='scale')";
      imgF.src=psubdir + "../images/point.gif";
      }else{
      	imgF.src=src;
      }
}
function changePNGbg(imgF, src)
{
	if(document.all&&!window.XMLHttpRequest){
     	imgF.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+src+"', sizingMethod='crop')";
      }else{
      	imgF.style.backgroundImage="url('"+src+"')";
      }
}
function correctPNG2(parentF)
{
	if(!(document.all&&!window.XMLHttpRequest)) return;
   var docImages=parentF.getElementsByTagName("img");
   for(var i=0; i<docImages.length; i++)
      {
     var img = docImages[i]
     if (img.width == 0) continue;
     var imgName = img.src.toUpperCase()
     if (imgName.substring(imgName.length-3, imgName.length) == "PNG")
        {
      	 img.style.width=img.width+"px";
       	 img.style.height=img.height+"px";
     	 img.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'" + img.src + "\', sizingMethod='scale')";
      	 img.src=psubdir + "../images/point.gif";
        }
      }
}
function alphaBackgrounds2(parentF){
	if(!(document.all&&!window.XMLHttpRequest)) return;
   var rslt = navigator.appVersion.match(/MSIE (d+.d+)/, '');
   var itsAllGood = (rslt != null && Number(rslt[1]) >= 5.5);
   for (i=0; i< parentF.all.length; i++){
      var bg = parentF.all[i].currentStyle.backgroundImage;
      if (bg){
         if (bg.match(/.png/i) != null){
            var mypng = bg.substring(5,bg.length-2);
            parentF.all[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+mypng+"', sizingMethod='crop')";
            parentF.all[i].style.backgroundImage = "url('')";
         }                                              
      }
   }
}
/*========================*/
//==设置CS滚动条颜色

try {
window.attachEvent("onload", function(){
	if(!external.browser) return;
	var doc=document;
	//if(doc.body.innerHTML=="") return;
	var link=doc.createElement("link");
	link.type='text/css';
	link.rel='stylesheet';
	link.href='<%=request.getContextPath() %>/css/scrollbarForCS.css';

	//var tag="<link rel='stylesheet' type='text/css' href='/eut/css/scrollbarForCS.css'>";
	//调用insertAdjacentHTML("afterBegin", tag);没用，要append才行

	doc.getElementsByTagName("head")[0].appendChild(link);
});
} catch(e) {}

//流程自动流转和关闭窗口
function PlatAction() {
	this.isSubmitedForm = false;
	this.isSubmitedFlow = false;
	this.dialogObj = null;
	this.checkSubmitFormHandle = "";
	this.checkSubmitFlowHandle = "";
	this.checkFlowSuccessHandle = "";
	this.submitFlowIFrame = null;
	
	
	this.checkSubmitForm = function() {
		var inDlgBox = null;
		try {
			inDlgBox = document.getElementById("InDlgBox");
		} catch(e) {
			return;
		}
		if (inDlgBox == null) {
			this.checkSubmitFormHandle = setTimeout("PlatAction.thisObj.checkSubmitForm()", 1000);
			return;
		} else {
			clearTimeout(this.checkSubmitFormHandle);
			this.checkSubmitFormHandle = "";
		}
		var divArr = inDlgBox.getElementsByTagName("div");
	    for(var x = 0; x < divArr.length; x++) {
	        if(divArr[x].id == "MDiv"){
		        this.submitFlowIFrame = divArr[x].childNodes[0].contentWindow;
		        break;
	        }
	    }
		//alert(3338888999 + "\n\n" + this.submitFlowIFrame.document.getElementsByName("SubmitButton").length)
		var isRepeat = false;
	    if (this.submitFlowIFrame.document.getElementsByName("SubmitButton").length == 0) {
	    	isRepeat = true;
	    }
	    if (isRepeat) {
	    	var submitFlowResultObj = this.submitFlowIFrame.document.getElementById("ActionSave"); 
			if (submitFlowResultObj != null && submitFlowResultObj.tagName.toLowerCase() == "div") {
				isRepeat = false;
			}
	    }
	    if (isRepeat)  {
	    	this.checkSubmitFormHandle = setTimeout("PlatAction.thisObj.checkSubmitForm()", 1000);
			return;
	    }
	    this.checkSubmitFlow();
	};
	
	
	this.checkSubmitFlow = function() {
		var submitFlowResultObj = null;
		try {
			submitFlowResultObj = this.submitFlowIFrame.document.getElementById("ActionSave");
		} catch(e) {
			return;
		} 
		if (submitFlowResultObj == null || submitFlowResultObj.tagName.toLowerCase() != "div") {
			this.checkSubmitFlowHandle = setTimeout("PlatAction.thisObj.checkSubmitFlow()", 1000);
			return;
		} else {
			clearTimeout(this.checkSubmitFlowHandle);
			this.checkSubmitFlowHandle = "";
		}
		PlatAction.setCookie("flow_send", "success");
		var flowSendValue = PlatAction.getCookie("flow_send");
		//alert("form  flowSendValue=" + flowSendValue);
		if (!IsNetBoxRunning()) {
			setTimeout("top.close()", 2000);
		}
	};
	
	
	this.checkFlowSuccess = function() {
		var flowType = PlatAction.getCookie("flow_type");
		//alert("flowType=" + flowType);
		if (flowType != null && flowType != "") {
			var divArr = document.getElementsByTagName("div");
			var re = new RegExp("[\\s\\S]*ondblclick=ExpFlow\\(this\\)\\s+"
				+ "onclick=ViewFlowList\\(this," + flowType + "[\\s\\S]*", "i");
			re = new RegExp("[\\s\\S]*"
				+ "onclick=ViewFlowList\\(this," + flowType + "[\\s\\S]*", "i");
		    for(var x = 0; x < divArr.length; x++) {
		        if (divArr[x].innerHTML.toLowerCase().indexOf("<div") < 0 && re.test(divArr[x].outerHTML)) {
		        	PlatAction.setCookie("flow_type", "");
		        	divArr[x].click();
		        	break;
		        }
		    }
		}
		
		
		var flowSendValue = PlatAction.getCookie("flow_send");
		//alert("list  flowSendValue=" + flowSendValue);
		if (flowSendValue == "success" && oFocus != null) {
			var itemHtml = oFocus.outerHTML;
			var nType = PlatAction.getValueByRegExp(itemHtml
				, /[\s\S]*onclick=ViewFlowList\(this,(\d+)[\s\S]*/i);
			PlatAction.setCookie("flow_type", nType);
			//alert("setCookie-flow_type=" + nType + "=\n\n" + itemHtml)
			PlatAction.setCookie("flow_send", "");
			location.reload();
			//this.checkFlowSuccessHandle = setTimeout("PlatAction.thisObj.checkFlowSuccess()", 3000);
		} else {
			this.checkFlowSuccessHandle = setTimeout("PlatAction.thisObj.checkFlowSuccess()", 1000);
		}
	};
}

PlatAction.setCookie = function ( sName, sValue, nDays ) {
	var expires = "";
	if ( nDays ) {
		var d = new Date();
		d.setTime( d.getTime() + nDays * 24 * 60 * 60 * 1000 );
		expires = "; expires=" + d.toGMTString();
	}

	document.cookie = sName + "=" + sValue + expires + "; path=/";
};

PlatAction.getCookie = function (sName) {
	var re = new RegExp( "(\;|^)[^;]*(" + sName + ")\=([^;]*)(;|$)" );
	var res = re.exec( document.cookie );
	return res != null ? res[3] : null;
};

PlatAction.getValueByRegExp = function ( str, propRegExp )
{
	var result = "";
	var arr = propRegExp.exec(str);
	if ( arr != null ) {
		result = arr[1];
	} else {
		result = "";
	}
	return result;
}

function checkFlow() {
	PlatAction.thisObj = new PlatAction();
	var checkPageUrl = location.toString();
	if (checkPageUrl.indexOf("myflow.jsp") >= 0) {
		PlatAction.thisObj.checkFlowSuccess();
	} else {
		var flowNameForm = document.getElementsByName("I_FlowName");
		if (flowNameForm.length > 0) {
			PlatAction.thisObj.checkSubmitForm();
		}
	}
}

function addMetaIe() {
	var flowNameForm = document.getElementsByName("I_FlowName");
	if (flowNameForm.length == 0) {
		return;
	}
	var metas = document.getElementsByTagName("meta");
	metas[metas.length].setAttribute("X-UA-Compatible","IE=EmulateIE7");
}

try {
	window.attachEvent("onload", checkFlow);
	//window.attachEvent("onload", addMetaIe);
} catch(e) {
}
//</script>