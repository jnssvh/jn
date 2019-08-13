<%@ page language="java" import="java.sql.*,java.util.*,com.jaguar.*, project.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();
	int result = user.initWebUser(jdb, cookie);
	if (result != 1)
	{
		jdb.closeDBCon();
		response.sendRedirect("login.jsp");
		return;
	}
	SysApp app = new SysApp(jdb);
	int ModuleNo = WebChar.RequestInt(request, "ModuleNo");
	out.print(WebFace.GetHTMLHead("即网通", "<link rel='stylesheet' type='text/css' href='com/forum.css'>"));
	String sql = "select * from ServiceSeat where CName='" + user.CMemberName + "'";
	ResultSet rs = jdb.rsSQL(0, sql);
	int bService = 0;
	if ( (rs!= null) && rs.next())
		bService = 1;
%>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript>
var NetBox = new ActiveXObject("NetBox");
var g_nUsers = 0;
var g_nGuests = 0;
var w_ready = 1;
var w_Buffer = "";
function TransData()
{
var x, obj, oTable;
	oTable = document.all.frmGuestOnline.contentWindow.document.all.OnlineListTable;
	for (x = 0; x < oTable.rows.length; x++)
	{
		obj = GetGuestSpan("G_" + oTable.rows[x].cells[0].innerText);
		if (typeof(obj) == "object")
			obj.innerText = oTable.rows[x].cells[1].innerText + "(" + oTable.rows[x].cells[9].innerText + " " +
				oTable.rows[x].cells[10].innerText + ":" + oTable.rows[x].cells[8].innerText + ")";
	}
	if (w_Buffer != "")
	{
		document.all.frmGuestOnline.src = "OnlineGuestList.asp?gids=" + w_Buffer;
		w_Buffer = "";
	}
	else
		w_ready = 1;

}

function GetGuestSpan(UserName, flag)
{
var x, oDivs;
	oDivs = document.all.GuestsDiv.getElementsByTagName("DIV");
	for (x = 0; x < oDivs.length; x++)
	{
		if (oDivs[x].node == UserName)
		{ 
			if ((flag == 1) && (oDivs[x].all.UserInfoSpan.innerText != ""))
				return oDivs[x].all.UserInfoSpan;
			if ((flag != 1) && (oDivs[x].all.UserInfoSpan.innerText == ""))
				return oDivs[x].all.UserInfoSpan;
		}
	}
	return 0;
}


function UserChange(UserName, nChange, nStatus)
{
var oDiv, ss, x, objs;
	if ( UserName.indexOf("G_") == 0)
		oDiv = document.all.GuestsDiv;
	else
		oDiv = document.all.UsersDiv;
	if (typeof(nStatus) == "undefined")
		nStatus = 1;
	if (nStatus == 4)
		nChange = 2;
	if (UserName == "<%=user.CMemberName%>")
		return;
	switch (nChange)
	{
	case 1:
		ss = "<span id=UserInfoSpan></span>";
		objs = oDiv.getElementsByTagName("DIV");
		for (x = 0; x < objs.length; x++)
		{
			if (objs[x].node == UserName)
			{
				objs[x].firstChild.firstChild.src = "/pic/users" + nStatus + ".gif";
				return;
			}
		}
		oDiv.insertAdjacentHTML("beforeEnd", "<DIV style='cursor:hand;padding-left:16px;height:20px;' ondblclick=RealMsg(this.node) node='" + 
			UserName + "'><NOBR><IMG align=absbottom src=/pic/users" + nStatus + ".gif>&nbsp;<SPAN id=UserSpan onclick=\"SelectObj(this,'#F2F5FB','black','solid 1px #8396C3')\">" + 
			UserName + "&nbsp;" + ss + "</SPAN></NOBR></DIV>");
		if ( UserName.indexOf("G_") == 0)
		{
			g_nGuests ++;
			var tid = UserName.substring(2);
			if (tid == parseInt(tid, 10))	// 如果用户名为 10 进制数
			{
				var obj = GetGuestSpan(UserName, 1);
				if (typeof(obj) == "object")
					ss = "<span id=UserInfoSpan>" + obj.innerText + "</span>";
				else
				{
					if (w_ready == 1)
					{	
						w_ready = 0;
						document.all.frmGuestOnline.src = "OnlineGuestList.asp?gids=" + tid;
					}
					else
					{
						if (w_Buffer == "")
							w_Buffer = tid;
						else
							w_Buffer += "," + tid;
					}
				}
			}
		}
		else
			g_nUsers ++;
		UpdateOnlineNum();
		
		break;
	case 2:
		for (x = 0; x < oDiv.childNodes.length; x++)
		{
			if (oDiv.childNodes[x].node == UserName)
			{
				oDiv.removeChild(oDiv.childNodes[x]);
				if ( UserName.indexOf("G_") == 0)
					g_nGuests --;
				else
					g_nUsers --;
				UpdateOnlineNum();
				break;
			}
		}
		break;
	case 3:
		document.all.UsersDiv.innerHTML = "";
		document.all.GuestsDiv.innerHTML = "";
		g_nUsers = 0;
		g_nGuests = 0;
		UpdateOnlineNum();
		break;	
	default:
		break;
	}
}

function ShowMessage(msg)
{
	if (MemberMessage(msg))
		return;

	var ss = msg.split("|");
	switch (parseInt(ss[4]))
	{
	case 2:		//消息框
		document.all.oMsgBox.src = "/MsgBox.htm";
		document.all.oMsgBox.msg = msg;
		document.all.oMsgBox.style.left = (document.body.clientWidth - 240) / 2;
		document.all.oMsgBox.style.top = (document.body.clientHeight - 180) / 2;
		document.all.oMsgBox.style.width = 240;
		document.all.oMsgBox.style.height = 180;
		document.all.oMsgBox.style.display = "inline";
		break;
	case 3:		//推送页面
		PushWebSite(ss[5]);
		break;
	case 4:		//清除页面
		PushWebSite("");
		break;
	case 5:		//推送居中图片
		document.all.oShowImg.src = ss[5];
		document.all.oShowMaxImg.style.display = "none";
		break;
	case 6:		//推送全屏图片
		document.all.oShowMaxImg.src = ss[5];
		document.all.oShowImg.style.display = "none";
		document.all.oShowMaxImg.style.display = "inline";
		break;
	case 7:		//清除推送图片
		ClearImg();
		break;
	case 8:		//推送FLASH
		document.FlashObj.movie = ss[5];
		document.FlashObj.style.display = "inline";
		document.all.oShowMaxImg.style.display = "none";
		document.all.oShowImg.style.display = "none";
		break;
	case 9:		//
		break;
	case 10:	//打开对话
		document.all.OnlineImg.click();
		break;
	case 11:	//邀请对话
		break;
	case 24:	//闪屏振动
		BeginWinkWindow();
		break;
	default:
		break;
	}
}

function InitBody()
{
	SetIMStatus();
	ResizeWin();
	window.onresize = ResizeWin;
	window.setInterval("ReadMessage()", 400);
	if (typeof(NetBox("JNet_MainMsg")) != "undefined")
		NetBox("JNet_MainMsg").RemoveAll();
}

function SetIMStatus()
{
	if (NetBox("JNet_ConnState") == 1)
	{
		if (typeof(document.all.NetStatus) == "object")
			document.all.NetStatus.innerText = "联机";
		if (NetBox("JNet_OnlineUser") == "")
			return;
		var users = NetBox("JNet_OnlineUser").split(",");
		var ss;
		for (x = 0; x < users.length; x++)
		{
			ss = users[x].split(":");
			UserChange(ss[0], 1, ss[1]);
		}
	}
	else
	{
		if (typeof(document.all.NetStatus) == "object")
			document.all.NetStatus.innerText = "脱机";
	}
}


function ReadMessage()
{
	if (typeof(NetBox("JNet_MainMsg")) != "object")
		return;
	var msg = NetBox("JNet_MainMsg").RemoveHead();
	if (typeof(msg) == "string")
	{
		var ss = msg.split(":");
		switch (ss[0])
		{
		case "UserChange":
			if (ss.length == 3)
				UserChange(ss[1], parseInt(ss[2]));
			else
				UserChange(ss[1], parseInt(ss[3]), parseInt(ss[2]));
			break;
		case "Connect":
 			SetIMStatus();
 			break;
		case "DisConnect":
 			SetIMStatus();
			UserChange("", 3);
			break;
		}
	}
}

function RealMsg(Receiver, nNotice)
{
var pp = "";
	if (typeof(nNotice) != "undefined")
		pp = "&nNotice=" + nNotice;
	NewHref("/RealMsg.asp?Receiver=" + escape(Receiver) + pp, "width=520,height=520,left=50,top=50,resizable=1", "JNet_" + Receiver);
}

function ExitSystem(bConfirm)
{
	if (window.confirm(""是否登出系统?""))
	{
		var NetBox = new ActiveXObject("NetBox");
		NetBox("DesktopServer") = "JNetEnd";
	}
}

function Broadcast(nType)
{
	if (NetBox("JNet_ConnState") != 1)
		return alert("不能发送，未连接服务器。");
	if (nType == 1)
		RealMsg("在线用户");
	else
		RealMsg("在线访客");
}

function UpdateOnlineNum()
{
	document.all.UsersNum.innerText = g_nUsers;
	if (typeof document.all.GuestsNum != "object")
		return;
	if (g_nGuests == 0)
		document.all.GuestsNum.innerText = "";
	else
		document.all.GuestsNum.innerText = g_nGuests;
}

function RTOnline(obj)
{
	if (NetBox("JNet_ConnState") == 0)
	{
		SetIMStatus();
	}
}

function ExpandUserList(obj)
{
	var oList = obj.parentNode.parentNode.nextSibling.cells[0].lastChild;
	if (oList.style.display == "none")
	{
		obj.src = "/pic/minus1.gif";
		oList.style.display = "inline";
	}
	else
	{
		obj.src = "/pic/plus1.gif";
		oList.style.display = "none";
	}
}

function SelectMenu(obj, url)
{
	arg = ""
	if (typeof(obj.ModuleNo) != "undefined")
		arg = "ModuleNo=" + obj.ModuleNo;
	NewNBWin(AppendURLParam(url, arg), "resizable=1,width=800,height=600,left=50,top=50",
		"JNETWin_" + obj.ModuleNo );
}

function ResizeWin()
{
	document.all.MainDiv.style.height = document.body.clientHeight - 25;
}

var oPop = window.createPopup();
function document.oncontextmenu()
{
	PopUpWinMenu();
}

</script>
<body alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0 onload=InitBody()>
<%
		out.print(app.getModuleInlineMenu(ModuleNo, "点击这里选择更多功能...<img src=pic/downtools.gif>", "#FFFEA4"));
%>
<DIV id=MainDiv style="width:100%;height:100%;border:solid 1px white;overflow:auto;">
<TABLE width=100% cellspacing=0 cellpadding=0>
<TR height=20><TD width=100% onclick="SelectObj(this,'#F2F5FB','darkblue','solid 1px #8396C3')" ondblclick=Broadcast(1)
NOWRAP style="border:solid 1px gray;cursor:hand;color:darkblue;">
<img src=com/pic/minus1.gif style=cursor:hand onclick=ExpandUserList(this)>
&nbsp;内部在线用户:<FONT ID=UsersNum>0</FONT></TD></TR>
<TR><TD id=UsersTD valign=top style="width:100%;padding:4px;">
<DIV ID=UsersDiv style=overflow:auto;width:100%;>
</DIV></TD></TR>
<%
	if (bService == 1)
	{
%>
<TR height=20><TD width=100% onclick="SelectObj(this,'#F2F5FB','darkblue','solid 1px #8396C3')" ondblclick=Broadcast(2)
NOWRAP style="border:solid 1px gray;cursor:hand;color:darkblue;">
<img src=com/pic/minus1.gif style=cursor:hand onclick=ExpandUserList(this)>
&nbsp;"外部在线访客:<FONT ID=GuestsNum>0</FONT></TD></TR>
<TR><TD id=GuestTD valign=top style="width:100%;padding:4px;">
<DIV ID=GuestsDiv style=overflow:auto;width:100%;></DIV></TD></TR>
<%
	}
else
	{
%>
<DIV ID=GuestsDiv style=display:none;></DIV></TD></TR>
<%
	}
%>
</TABLE></div>
<IFRAME name=oMsgBox SCROLLING=no FRAMEBORDER=0 style=display:none;position:absolute;z-index:2></IFRAME>
<IMG id=oShowImg onmousedown=BeginDragObj(this) onload=CenterImg(this) style=display:none;cursor:hand;position:absolute;z-index:3;>
<IMG id=oShowMaxImg width=100% height=100% style=display:none;position:absolute;top:0;left:0;z-index:3;>
<object classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' 
		codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0' 
		width=100% height=100% id=FlashObj align=middle style=position:absolute;display:none;z-index:3;>
<param name='allowScriptAccess' value='sameDomain' />
<param name='movie' value='/skin/blank.swf' />
<param name='quality' value='high' />
<param name='wmode' value='transparent' />
<param name='bgcolor' value='#ffffff' />
<embed src='/skin/blank.swf' quality='high' wmode='transparent' bgcolor='#ffffff' 
width=100% height=100% name='testswf' align='middle' allowScriptAccess='sameDomain' 
type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer' />
</object>
<iframe id="frmGuestOnline" frameborder="1" width="0"></iframe>
</body>
</html>
