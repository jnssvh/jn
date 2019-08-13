<%@ page language="java" import="java.sql.*,java.util.*,com.jaguar.*, project.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%!
String GetJNetPages(JDatabase jdb, WebUser user)
{
	String sql = "select * from RightObject where parent_node=0 and auth_show=1 and auth_status=9 order by auth_order, auth_no";
	ResultSet rs = jdb.rsSQL(0, sql);
	String result = "";
	try
	{
		while (rs.next())
		{
   			if (user.isModuleEnable(rs.getInt("auth_no")))
				result += "<div style=\"width:100%;height:40px;border-right:1px solid #79828b;\">" +
					"<span id=JNETPageSpan node='" + rs.getString("auth_no") +
					"' onmouseover=ShowPageFocus(this) onmouseout=HidePageFocus(this) onclick=SelectFocusPage(this)" +
					" style='cursor:hand;width:100%;height:100%;border-right:1px solid #a9b7c4;padding-top:5px;'>" +
					"<img width=30 height=30 onclick=\"" + WebChar.apostrophe(rs.getString("auth_url")) +
					"\" src='" + rs.getString("auth_img") + "' title='" + rs.getString("auth_name") + "'></span></div>";
		}
		jdb.rsClose(0, rs);
	}
	catch (SQLException e)
	{
		e.printStackTrace();
	}
	return result;
}

String GetJNetToolModuleSpan(JDatabase jdb, String ModuleInfo)
{
	String result = "<span style=height:20px;>&nbsp;</span>";
	String sql = "select * from ModuleCfg where Status=1 and ModuleInfo='" + ModuleInfo + "'";
	ResultSet rs = jdb.rsSQL(0, sql);
	try
	{
		if (!rs.next())
			return result;
//		if (GetGroupsRight(MemberGroupIDs, rs.getString("ModuleNo")))
			result = "<span style=height:20px;padding-top:4px;cursor:hand;>&nbsp;" +
				"<img onclick=\"" + rs.getString("URL") + "\" id=ToolImg src='" + rs.getString("Img") +
				"' title=" + rs.getString("ModuleName") + "></span>";
		jdb.rsClose(0, rs);
		jdb.rsClose(0, rs);
	}
	catch (SQLException e)
	{
		e.printStackTrace();
	}
	return result;
}
%>
<%
	
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();
	int result = user.initWebUser(jdb, cookie);
	if (result != 1)
	{
		jdb.closeDBCon();
		response.sendRedirect("com/error.jsp");
		return;
	}
	SysApp app = new SysApp(jdb);
	if (WebChar.RequestInt(request, "UpdatePhoto") == 1)
	{
	
		int PhotoID = WebChar.RequestInt(request, "PhotoID");
		String sql = "update Member set Photo=" + PhotoID + " where CName = '" + user.CMemberName + "'";
		result = jdb.ExecuteSQL(0, sql);
		out.print(app.GetThumbNail(PhotoID, 64, 64));
		jdb.closeDBCon();
		return; 
	}

	out.print(WebFace.GetHTMLHead("即网通", "<link rel='stylesheet' type='text/css' href='com/forum.css'>"));
	String boss = app.getSysParam("Leader");
	if (boss.equals(user.CMemberName))
		user.bMemberAdmin = 1;
	String phototag = "<img src=netbox:/pic/photo.gif width=60 height=60>";
	int AffixID = WebChar.ToInt(jdb.GetTableValue(0, "Member", "Photo", "CName", "'" + user.CMemberName + "'"));
	if (AffixID > 0)
		phototag = "<img width=60 src=" + app.GetThumbNail(AffixID) + ">";
	String PageSpan = GetJNetPages(jdb, user);
	int JNet = WebChar.RequestInt(request, "JNet");
	String RealServicePort = app.getSysParam("RealServicePort");
	RealServicePort = "2300";
	String ProductUnitNo = app.getSysParam("ProductUnitNo");		
	String str = WebFace.GetRollMenuItem("images/status1.gif", "在线", "SetMyNetStatus(1)", "") +
		WebFace.GetRollMenuItem("images/status2.gif", "忙碌", "SetMyNetStatus(2)", "") +
		WebFace.GetRollMenuItem("images/status3.gif", "离开", "SetMyNetStatus(3)", "") +
		WebFace.GetRollMenuItem("images/status4.gif", "隐身", "SetMyNetStatus(4)", "");
	str = WebFace.GetRollMenuBox("StatusMenu", str);
	String statusmenu = user.CMemberName + "(" + user.EMemberName +
		")（<span id=NetStatus>断线</span>）&nbsp;<img src=pic/downtools.gif>";
	statusmenu = WebFace.GetMenuBarItem(statusmenu, "", "", "", str, 2);
	String group = "www";
%>
<body alink=#333333 vlink=#333333 link=#333333 bgcolor=#70716C onload=InitBody() 
 style="margin:0px;border-right:1px solid #3F403B;border-bottom:1px solid #3F403B;">
<div style="width:100%;margin-left:4px;margin-right:4px;">
<%=WebFace.GetMenuBarTableEx(app.getModuleMenu(0, 0, 8, user)
	, "<span style=height:22px;padding-top:5px><object classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" " 
	+ "codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0\"" 
	+ " width=\"10\" height=\"10\" id=\"JNetServer\" align=\"middle\">" 
	+ "<param name=\"allowScriptAccess\" value=\"sameDomain\" />" 
	+ "<param name=\"allowFullScreen\" value=\"false\" />" 
	+ "<param name=\"movie\" value=\"flash/conn.swf\" /><param name=\"quality\" value=\"high\" />" 
	+ "<param name=\"bgcolor\" value=\"#ffffff\" />	<embed src=\"flash/conn.swf\" quality=\"high\"" 
	+ " bgcolor=\"#ffffff\" width=\"10\" height=\"10\" name=\"conn\" align=\"middle\"" 
	+ " allowScriptAccess=\"sameDomain\" allowFullScreen=\"false\" type=\"application/x-shockwave-flash\"" 
	+ " pluginspage=\"http://www.adobe.com/go/getflashplayer\" />" 
	+ "</object></span>", "#C1C2BD", 2)%>
<div onclick=ChangePhoto() id=PhotoSpan style="width:64px;height:64px;overflow:hidden;position:absolute;
left:84px;top:45px;padding-left:2px;padding-top:2px;background:url(netbox:/pic/imgbox.gif);"><%=phototag%></div>
<DIV nowrap id=LableDiv style="width:100%;height:52px;background-color:#FDA304;">
<span style="width:80px;height:50px;padding:10px 0px 0 10;"><%=GetJNetToolModuleSpan(jdb, "内部邮件")%>&nbsp;
<%=GetJNetToolModuleSpan(jdb, "知识文档")%></span>
<span style="height:50px;padding-top:5px;padding-left:60px;"><%=statusmenu%></span>
</DIV>
<DIV id=MainDiv style="width:100%;height:500px;">
<TABLE id=MainTable width=100% height=100% align=center cellspacing=0 cellpadding=0>
<TR><TD id=MenuTD valign=top style="background-color:#A0A19D;padding:0 0 0 4px;">
<div style="width:100%;height:18px;border-right:1px solid #79828b;">
<div style="width:100%;height:100%;border-right:1px solid #a9b7c4;"></div></div>
<div ID=PageDiv style="width:35px;overflow:hidden"><%=PageSpan%>
<div style="width:100%;height:100%;border-right:1px solid #79828b;"><span style="width:100%;height:100%;border-right:1px solid #a9b7c4;padding-top:5px;">
</span></div></div></TD>
<TD id=WorkAreaTD valign=top width=100% style="padding:4px;background-color:#C1C2BD;">
<IFRAME name=OtherPageFrame SCROLLING=no FRAMEBORDER=0 style="width:100%;height:100%;"></IFRAME></TD>
</TR></table>
</div>

<IFRAME name=oMsgBox SCROLLING=no FRAMEBORDER=0 style=display:none;position:absolute;z-index:2></IFRAME>
<IMG id=oShowImg onmousedown=BeginDragObj(this) onload=CenterImg(this) style=display:none;cursor:hand;position:absolute;z-index:3;>
<IMG id=oShowMaxImg width=100% height=100% style=display:none;position:absolute;top:0;left:0;z-index:3;>
</div></body>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript src=com/common.js></script>
<script language=javascript src=com/nbwin.js></script>
<script language=javascript src=csindex.js></script>
<script language=javascript>
var g_CMemberName = "<%=user.CMemberName%>";
var g_RealServicePort = "<%=RealServicePort%>";
var g_group = "<%=group%>";
var g_WinStyle = 0;	//弹出窗口风格
function window.onload()
{
	window.nbwin = new NBWindow("即网通 - JNET", {minWidth:215,minHeight:500,dockEnable:1,resizable:true});
	var pages = document.getElementsByName("JNetPageSpan");
	if (pages.length > 0)
		pages[0].firstChild.click();
	window.onresize = ResizeWin;
	ResizeWin();
	SetMyNetStatus();
	if (NetBox("JNetWinTop") == 0)
		external.TopMost = false;
	else
		external.TopMost = true;
}

function SelectPage(oImg, url)
{

	obj = oImg.parentNode;
	if (oFocusPage == obj)
		return;
	if (typeof(oFocusPage) == "object")
	{
		oFocusPage.style.borderBottom = "0px solid #b4ccd6";
		oFocusPage.style.borderTop = "0px solid #515151";
		oFocusPage.style.borderLeft = "0px solid #a9a9a9";
		oFocusPage.parentNode.style.borderBottom = "0px solid #ebebeb";
		oFocusPage.parentNode.style.borderTop = "0px solid #919191";
		oFocusPage.parentNode.style.borderLeft = "0px solid #797979";

		oFocusPage.style.backgroundColor = "#A0A19D";

		oFocusPage.style.borderRight = "1px solid #a9b7c4";
		oFocusPage.parentNode.style.borderRight = "1px solid #79828b";
	}
	oFocusPage = obj;
	oFocusPage.style.borderBottom = "1px solid #808080";
	oFocusPage.style.borderTop = "1px solid #515151";
	oFocusPage.style.borderLeft = "1px solid #515151";
	oFocusPage.parentNode.style.borderBottom = "1px solid #C0C0C0";
	oFocusPage.parentNode.style.borderTop = "1px solid #919191";
	oFocusPage.parentNode.style.borderLeft = "1px solid #797979";

	oFocusPage.style.backgroundColor = "#808080";

	oFocusPage.style.borderRightWidth = "0px";
	oFocusPage.parentNode.style.borderRightWidth = "0px";

	document.all.OtherPageFrame.src = AppendURLParam(url, "ModuleNo=" + obj.node);
	if (typeof(event) == "object")
		event.cancelBubble = true;
}




function ResizeWin()
{
	if (document.body.clientHeight > 129)
	{
		document.all.PageDiv.style.pixelHeight = document.body.clientHeight - 129;
		document.all.MainDiv.style.height = document.body.clientHeight - 110;
	}
}

</script>
</html>
