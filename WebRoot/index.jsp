<%@ page language="java" import="java.sql.*,java.util.*,com.jaguar.*, project.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%!
String GetJNetPages(JDatabase jdb, WebUser user)
{
	String sql = "SELECT auth_id FROM RightObject WHERE auth_name='����ͨ(�ͻ���)'";
	int parent_node = jdb.getIntBySql(0, sql);
	sql = "select * from RightObject where parent_node=" + parent_node + " and auth_show=1 and auth_status=1";
	if (user.isAdmin() == false)
		sql += " AND auth_id IN (SELECT auth_id FROM rightlist WHERE usergroup_id in (" + 
			(VB.isEmpty(user.MemberGroupIDs)?"null":user.MemberGroupIDs) + "))";
	sql += " order by auth_order, auth_no";
	ResultSet rs = jdb.rsSQL(0, sql);
	String result = "";
	try
	{
		boolean isGxdxStdUser=false;
 		if("student".equals(Global.projectCode)){
 			//==�жϵ�ǰ�û���ѧԱ�������� lxt 2011.08.27
 			String sqlx="select count(RegID) from SS_Student where StdNo='"+user.EMemberName+"'";
 			if(WebChar.ToInt(jdb.getSQLValue(0, sqlx))>0)
 			isGxdxStdUser=true;
 		}
 		String auth_name="";
		while (rs.next())
		{
//   			if (user.isModuleEnable(rs.getInt("auth_no")))
				auth_name=rs.getString("auth_name");
				if(isGxdxStdUser&&auth_name!=null&&auth_name.indexOf("����ƽ̨")>-1) auth_name="ѧԱ����ϵͳ";
				result += "<div style=\"width:30px;height:30px;text-align:center;margin-bottom:8px;\">" +
					"<span id=JNETPageSpan node='" + rs.getString("auth_no") +
					"' title='" + auth_name + "' onclick=SelectFocusPage(this)" +
					" onmouseover=overFocusPage(this) onmouseout=outFocusPage(this) style='cursor:default;width:30px;height:28px;'>" +
					"<img style='width:24px;height:24px;margin-top:2px;' onclick=\"" + WebChar.apostrophe(rs.getString("auth_url")) +
					"\" src='" + rs.getString("auth_img") + "'></span></div>";
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
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
		String EName = WebChar.requestStr(request, "UserName");
		Cookie [] ck = new Cookie[2];
		ck[0] = new Cookie("loginname", EName);
		ck[1] = new Cookie("loginpassword", WebChar.requestStr(request, "Password"));
		result = user.initWebUser(jdb, ck);
		if (result != 1)
		{
			jdb.closeDBCon();
			response.sendRedirect("com/error.jsp");
			return;
		}			
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}

	String group = "www";
	if (WebChar.RequestInt(request, "GetUnReadMsg") == 1)
	{
		ChatOption chatdb = new ChatOption(jdb, 0);
		int nType = WebChar.RequestInt(request, "nType");
		int maxLen = WebChar.RequestInt(request, "maxLen");
		String lastTime = WebChar.requestStr(request, "lastTime");
		out.print(chatdb.GetJSONOfflineMsg(group, user.CMemberName, nType, lastTime, maxLen));
		
//		String sql = "select Msg from RealMsgCache where Receiver='" + user.CMemberName + "' order by SendTime";
//		out.print(jdb.getJsonBySql(0, sql));
//		sql = "delete from RealMsgCache where Receiver='" + user.CMemberName + "'";
//		jdb.ExecuteSQL(0, sql);
		jdb.closeDBCon();
		return;
	}
	SysApp app = new SysApp(jdb);
	if (WebChar.RequestInt(request, "UpdatePhoto") == 1)
	{
	
		int PhotoID = WebChar.RequestInt(request, "PhotoID");
		int width = WebChar.RequestInt(request, "width");
		int espace_id = WebChar.RequestInt(request, "espace_id");
		if (width == 0) width = 50;
		String sql = "";
		if (espace_id == 0) {
			sql = "update Member set Photo=" + PhotoID + " where CName = '" + user.CMemberName + "'";
		} else {
			sql = "update Member set Photo=" + PhotoID + " where id=(SELECT user_id FROM espace_user WHERE espace_id=" + espace_id + ")";
		}
		result = jdb.ExecuteSQL(0, sql);
		//out.print(app.GetThumbNail(PhotoID, width, width));
		out.print("ok");
		jdb.closeDBCon();
		return; 
	}

	out.print(WebFace.GetHTMLHead("����ͨ-EUT", "<link rel='stylesheet' type='text/css' href='forum.css'>"));
	String boss = app.getSysParam("Leader");
	if (boss.equals(user.CMemberName))
		user.bMemberAdmin = 1;
	int AffixID = WebChar.ToInt(jdb.GetTableValue(0, "Member", "Photo", "CName", "'" + user.CMemberName + "'"));
	String phototag = "<img src='com/down.jsp?AffixID="+AffixID+"' onerror=\"this.src='pic/306.jpg'\" style='width:50px;height:50px;margin-top:7px;margin-left:7px;' />";
	//if (AffixID > 0)
		//phototag = "<img onerror=\"this.src='pic/306.jpg'\" style='width:50px;height:50px;margin-top:7px;margin-left:7px;' src=" + app.GetThumbNail(AffixID, 50, 50) + ">";
	String PageSpan = GetJNetPages(jdb, user);
	int JNet = WebChar.RequestInt(request, "JNet");
	String RealServicePort = app.getSysParam("RealServicePort");
	RealServicePort = WebChar.getValueByNodeName(new WebChar().getNode("WEB-INF/system_config.xml"
		, "application{type=ChatServer}"), "port");
	String ProductUnitNo = app.getSysParam("ProductUnitNo");
	String sql = "SELECT auth_id FROM RightObject WHERE auth_name='���˵�' AND parent_node=(SELECT auth_id FROM RightObject WHERE auth_name='����ͨ(�ͻ���)')";
	int parent_node = jdb.getIntBySql(0, sql);
	String sysmenu = app.getModuleMenuArray(parent_node, -1, user);
	String statusmenu = "[{item:\"<span><font id=NetStatus>" +
		"<img src=images/status4.gif>&nbsp;����</font>&nbsp;<span style='vertical-align:1px;'>"+
		"<img src=pic/downtools.gif></span></span>\", className:\"statusMenu\", child:" +
		"[{item:\"����\",img:\"images/status1.gif\",action:\"SetMyNetStatus(1)\"}," +
		"{item:\"æµ\",img:\"images/status2.gif\",action:\"SetMyNetStatus(2)\"}," +
		"{item:\"�뿪\",img:\"images/status3.gif\",action:\"SetMyNetStatus(3)\"}," +
		"{item:\"����\",img:\"images/status4.gif\",action:\"SetMyNetStatus(4)\"}]}]";
	
%>
<style>
.statusMenu0{
	width:65px;height:20px;border:none;background-color:transparent;
}
.statusMenu1{
	width:65px;height:20px;border:1px outset #dddddd;background-color:transparent;
}
.statusMenu2{
	width:65px;height:20px;border:1px inset #dddddd;background-color:transparent;
}
</style>
<body alink=#333333 vlink=#333333 link=#333333 onselectstart="return false"
 style="margin:0px;padding:0px;background-color:#82B6D7;text-align:center;color:#303030;">
<!-- ==�˵�������== -->
<div style="width:100%;margin:0px;padding:0px;">
	<!-- ==�˵���������Ƭ== -->
	<div style="width:100%;height:75px;margin:0px;padding:0px;cursor:default;
	background-image:url('images/client/back/back_08.gif');background-position:left middle;background-repeat:repeat-x;">
	<table style="width:100%;border-collapse:collapse;
	background-image:url('images/client/back/back_07.gif');background-position:left middle;background-repeat:no-repeat;">
		<tr>
			<td rowspan="2" style="width:70px;vertical-align:middle;padding-left:5px;">
				<div onclick="addSelf();//ChangePhoto()" id=PhotoSpan style="width:70px;height:74px;text-align:left;
				background-image:url('images/client/menu/photoBorder.png');background-position:left top;
				background-repeat:no-repeat;cursor:pointer;"  title="��������ҵ��׿ռ�">
				<%=phototag%>
				</div>
			</td>
			<td>
				<DIV id=LableDiv nowrap>
					<table><tr><td onclick=ShowError() style="width:50px;vertical-align:middle;text-align:center;">
					<%if(user.CMemberName!=null&&user.CMemberName.length()>6)out.println(user.CMemberName.substring(0,6));
					else out.println(user.CMemberName);%></td>
					<td style="vertical-align:top;padding-top:2px;">
					<span id=StatusMenu style='width:80px;overflow:hidden;'></span></td>
					<td style="vertical-align:top;padding-top:6px;"><div style="position:absolute;right:-30px;" title="ͨ��״̬">
					<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"  
					 codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" 
					 width="10" height="10" id="JNetServer" align="middle">
					<param name="allowScriptAccess" value="sameDomain" /> 
					<param name="allowFullScreen" value="false" /><param name="movie" value="flash/conn.swf" />
					<param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />
					<embed src="flash/conn.swf" quality="high" bgcolor="#ffffff" width="10" height="10" name="conn" align="middle" 
					allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" 
					pluginspage="http://www.adobe.com/go/getflashplayer" /> 
					</object></div>
					</td></tr></table>
				</div>
				<!-- ==Сͼ�갴ť��== -->
				<div id=toolbarDiv style='text-align:right;'>
					<table><tr>
					<td><span style='vertical-align:-1px;'><img src='images/429.gif' 
					onclick='openMsgBox(this)' title='��Ϣ��' 
					style='margin-right:2px;cursor:pointer;'/></span><span id="spanMsgBoxCount" style='font-size:10px;'></span>
					</td>
					<td><div style='position:absolute;top:4px;right:90px;'><img 
					onclick='QABox(this)' src='images/430.gif' title="���ⷴ��" 
					style='cursor:pointer;'/></div>
					</td>
					</tr></table>
				</div>
			</td>
			<td rowspan="2" style="
			background-image:url('images/client/back/back_09.gif');
			background-position:right middle;background-repeat:no-repeat;">&nbsp;</td>
		</tr>
		<tr>
			<td>
			</td>
		</tr>
		</table>
	</div>
	
	
	<!-- ==Iframe��== -->
	<div id=MainDiv style="width:100%;height:429px;margin:0px;margin-top:-1px;padding:0px;">
		<TABLE id=MainTable style="width:100%;height:100%;border-collapse:collapse;
		background-image:url('images/client/back/back_12.gif');background-position:left bottom;background-repeat:repeat-y;">
		<tr>
		<td id=MenuTD valign=top style="width:35px;
		background-image:url('images/client/back/back_10.gif');background-position:left top;background-repeat:no-repeat;">
			<div ID=PageDiv style="margin-left:3px;cursor:default;">
				<%=PageSpan%>
			</div>
		</td>
		<td rowspan="2" style="padding:0px;padding-right:1px;border-right:1px solid #1170b2;">
		<IFRAME name=OtherPageFrame SCROLLING=no FRAMEBORDER=0 marginheight="0" marginwidth="0" 
			style="margin:0px;padding:0px;width:100%;height:100%;"></IFRAME>
		</td>
		</tr>
		<tr>
			<td style="padding:0px;text-align:left;"><img src="images/client/back/back_13.gif" style="display:none;width:35px;"/></td>
		</tr>
		</table>
	</div>

	
	<!-- ==β��== -->
	 <div style="width:100%;margin:0px;padding:0px;text-align:center;">
 		<table style=";margin:0px;padding:0px;width:100%;height:69px;border-collapse:collapse;">
 		<tr>
			<td style="width:195px;background-image:url('images/client/back/back_14.gif');
			background-position:left bottom;background-repeat:no-repeat;vertical-align:bottom;padding:0px;margin:0px;">
				<span title="���˵�" id="span_N" onclick=ShowSysMenu(this) 
				onmouseover="changePNGSrc(this.firstChild,'images/client/foot/N2.png');"
				 onmouseout="changePNGSrc(this.firstChild,'images/client/foot/N.png');">
				<img src="images/client/foot/N.png"/>
				</span>
			</td>
			<td style="padding:0px;">
			<img src="images/client/back/back_15.gif" alt="" style="height:100%;width:100%;margin:0px;"></img>
			</td>
			<td style="width:23px;background-image:url('images/client/back/back_16.gif');
			background-position:right bottom;background-repeat:no-repeat;padding:0px;">&nbsp;
				<span style="position:absolute;bottom:20px;left:40%;">
				<!--  <img src="images/client/foot/nsoft.png"/> -->
				</span>
			</td>
		</tr>
		</table>
	</div>
	<IFRAME name=oMsgBox SCROLLING=no FRAMEBORDER=0 style=display:none;position:absolute;z-index:2></IFRAME>
	<IMG id=oShowImg onmousedown=BeginDragObj(this) onload=CenterImg(this) style=display:none;cursor:hand;position:absolute;z-index:3;>
	<IMG id=oShowMaxImg width=100% height=100% style=display:none;position:absolute;top:0;left:0;z-index:3;>
</div>
</body>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript src=com/common.js></script>
<script language=javascript src=com/nbwin.js></script>
<script language=javascript src=csindex.js></script>
<script language=javascript src=im/online.js></script>
<script language=javascript>
var g_CMemberName = "<%=user.CMemberName%>";
var g_EMemberName = "<%=user.EMemberName%>";
var g_RealServicePort = "<%=RealServicePort%>";
var g_group = "<%=group%>";
var g_WinStyle = 1;	//�������ڷ��
var g_selObj, oFocusPage;
function SelectPage(oImg, url)
{
	g_selObj = oImg.parentNode;
	if (g_selObj == null) {
		return;
	}
	if (oFocusPage == g_selObj)
		return;
		
	if (typeof(oFocusPage) == "object")
	{
		oFocusPage.style.filter="";
	}
	oFocusPage = g_selObj;
	//===IE6�����⴦��PNG
	oFocusPage.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='images/client/menu/glass.png', sizingMethod='crop')";
	var fra=document.all.OtherPageFrame;
	if (!fra.src) {
		fra.src = AppendURLParam(url, "ModuleNo=" + g_selObj.getAttribute("node"));
	} else {//==ͨ������iframeģʽ����û������ֹ����ҳ���� lxt 2012.1.17
		var td=fra.parentNode;
		td.insertAdjacentHTML("beforeEnd", fra.outerHTML.replace(/src=\S+/i, ""));
		var newFra=td.childNodes[1];
		newFra.style.display="none";
		var func = function(){//==����ֱ����newFra.onload=...��������
			if(!newFra.src) return;//==��ֹ�ռ����¼�Ӱ��
			td.removeChild(fra);
			newFra.style.display="block";
			fra=null;
			newFra.detachEvent("onload", func);
		};
		newFra.attachEvent("onload", func);
		newFra.src= AppendURLParam(url, "ModuleNo=" + g_selObj.getAttribute("node"));
	}
	if (typeof(event) == "object")
		event.cancelBubble = true;
}
function overFocusPage(spanF)
{
	spanF.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='images/client/menu/glass.png', sizingMethod='crop')";
}
function outFocusPage(spanF)
{
	if(spanF.getAttribute("node") == g_selObj.getAttribute("node")) return;
	spanF.style.filter = "";
}

function CurrentActive() {
	
}

CurrentActive.actives = null;	//ȫ���
CurrentActive.newActives = null;  //�»

CurrentActive.viewCurrentActive = function () {
	var date1 = null;
	var diff = 0;
	var dateStr = "";
	var txt = "";

	if (CurrentActive.newActives != null) {
		CurrentActive.actives = CurrentActive.concatActive(CurrentActive.actives, CurrentActive.newActives);
		CurrentActive.newActives = null;
	}
	for (var i = 0; i < CurrentActive.actives.length; i++) {
		dateStr = CurrentActive.actives[i].SpecDate.replace(/-/g, '/');
		dateStr = dateStr.replace(/.0$/, "");
		dateStr = dateStr.replace(/\d+-\d+-\d+/, "<%=VB.Date()%>");
		date1 = new Date(Date.parse(dateStr));
		diff = date1.getTime() - new Date().getTime();
		if (diff < 0) {
			CurrentActive.actives.splice(i, 1);
			i--;
		} else if (diff < 60 * 1000) {
			txt = CurrentActive.actives[i].CalNote;
			txt = txt.replace(/<(style|script)[^>]*>[\s\S]*<\/\1>/ig, "");
			txt = txt.replace(/<[^>]+>/g, "");
			txt = txt.substr(0, 100);
			txt = txt.replace(/[\r\n]+/g, "<br>");
			var url = gRootPath + "fvs/ViewDeptCalendar.jsp?DataID=" + CurrentActive.actives[i].ID;
			var t = "0|0:0|�ճ�����||" + url + "|" +
				"<img src=../images/402.png style=float:left><div style='color:blue;font:normal"
				+ " normal bolder 14px ΢���ź�;padding-left:10px;'>" +
				CurrentActive.actives[i].CalTitle + "<br>" + txt + "</div>";
			PopJNetMsg("LocalMsg", t, 1);
			CurrentActive.actives.splice(i, 1);
			i--;
		}
	}
};

CurrentActive.viewActive = function(id) {
	NewHref(gRootPath + 'fvs/calendar_dept_form.jsp?DataID=' + id,'scrollbars=0,resizable=1,width=800,height=600,title=�����'
	, 'DeptAction');
};

CurrentActive.addActive = function (str) {
	str = unescape(str);
	var act = null;
	try {
		act = eval(str);
	} catch (e){alert("����:" + e)}
	if (act == null) {
		return;
	}
	if (CurrentActive.newActives != null) {
		CurrentActive.newActives = CurrentActive.concatActive(CurrentActive.newActives, act);
	} else {
		CurrentActive.newActives = act;
	}
	CurrentActive.viewCurrentActive();
}

/**
arr1  ԭ���飬Ŀ������
arr2   ������
*/
CurrentActive.concatActive = function (arr1, arr2) {
	for (var i = 0; i < arr2.length; i++) {
		for (var j = 0; j < arr1.length; j++) {
			if (arr1[j].ID == arr2[i].ID) {
				arr1.splice(j, 1);
				break;
			}
		}
	}
	arr1 = arr1.concat(arr2);
	return arr1;
}


var SysMenu, StatusMenu;
var serviceIcon;// = "netbox:/pic/nsoft16.gif";
 window.onload = function()
{
	//external.ContextMenu = true;
	initNetBox();
	if (NetBox("LoginMode") != 1)
	{
		serviceIcon = "netbox:/pic/nsoft16.gif";
		ResizeWin(true);//==����true��ʾ��һ������
		window.onresize = ResizeWin;
		window.nbwin = new NBWindow("", {minWidth:260,minHeight:600,dockEnable:1,resizable:true}, 0, 2);
		document.all.NBWinTopedge.attachEvent("onmousedown", function(){//==����λ�õ��ļ�
			NetBox.Config("", "deskWinPositionx")=external.left+":"+external.top;
		});
		document.all.NBWinMinbox.onclick = function ()
		{
			window.external.Visible = false;
		};
		document.all.NBWinClosebox.onclick = function ()
		{
			if (window.confirm("������˹رմ��ڣ�����Ҫ�˳�ϵͳ��\n����Ҫ��С����ϵͳ���̣�\n�����ȷ�����˳�ϵͳ��\n�����ȡ������С����ϵͳ���̡�") == true)
				Shell.Halt(0);
			else
				window.external.Visible = false;
		}
		var pages = document.getElementsByName("JNETPageSpan");
		if (pages.length > 0)
			pages[0].firstChild.click();
		
		SysMenu = new CommonMenu(<%=sysmenu%>);
		StatusMenu = new CommonMenubar(<%=statusmenu%>, document.all.StatusMenu);
		SetMyNetStatus();
		if (NetBox("JNetWinTop") == 0)
			external.TopMost = false;
		else
			external.TopMost = true;
		setTimeout("checkActive()", 15000);
		AjaxRequestPage("flow/myflow.jsp?AjaxType=99", true, "", FlowNotice);
	}
	else
	{
		serviceIcon = "netbox:/pic/box.gif";
		PopJNetMsg("LocalMsg", "0|0:0|||3000|" +
			"<img src=images/402.png style=float:left><div style='color:blue;font:normal normal bolder 14px ΢���ź�;padding-left:10px;'>" +
				"����ͨ-��Ϣ��������.<br>������Ϣ����ʱ������</div>", 1);
	}
	//==��ǰ������֪ͨ��׼���� lxt 2011.12.31
	setTimeout(function(){PopJNetMsgPrepare(1)}, 3000);//==����ֱ���л��빤������֪ͨ��ͻ
	window.setInterval(checkMsg, 500);
	ocxinstall();
	setTimeout("checkOldClient()", 0);
}

function checkActive() {
	
		AjaxRequestPage("AjaxFunction?datas=<%=VB.Date()%>&type=GetActive&caltype=day"
			+ "&return_type=json_index&userid=<%=user.UserID%>", true, "", function(str){

			var xmlText = unescape(str);
			//alert(xmlText);
			CurrentActive.actives = eval(xmlText);
			CurrentActive.viewCurrentActive();
			setInterval("CurrentActive.viewCurrentActive()", 30000);
		});
}


function checkOldClient() {
	if (NetBox("eut_ver") != undefined && NetBox("eut_ver")+"" != "") {
		return false;
	}
	return;
	//var updateTip = "��Ҫϵͳ��ʾ��\n���ֿͻ����°汾���뵽��У��ҳ�������¿ͻ��������������"
	//if (updateTip != undefined)
	//	alert(updateTip);
	//return;
	var Shell = new ActiveXObject("Shell");
	/*
	*/
	
	Shell.Service.TrayIcon = false;
	if (!confirm("��Ҫϵͳ��ʾ��\n���ֿͻ����°汾�����ȷ�����Զ��رձ��ͻ���"
		+ "��\nͬʱ������������\n\n��ʾ���ֶ��������¿ͻ���Ҳ�������������")) {
		Shell.Service.TrayIcon = true;
		return false;
	}
	var fso, tempfile;fso = new ActiveXObject("Scripting.FileSystemObject");

	var tfolder, tfile, tname, fname, TemporaryFolder = 2, path;
	tfolder = fso.GetSpecialFolder(TemporaryFolder);
	path = tfolder.Path;
	tfolder = null;
	fso = null;
	downloadFile("/EUT.exe", "EUT.exe", path);	
	Shell.Execute(path + "\\EUT.exe", 1);
	Shell.Halt(0);
	return true;
}

function getValueByRegExp( str, propRegExp )
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

function getFileContentFromServer(filePah) {
	var file1 = null;
	var content = "";
	try {
		file1 = new ActiveXObject("NetBox.File");
		file1.Open(filePah);
		while (!file1.eos) {
			content += file1.ReadLine() + "\n";
		}
		file1.Close();
		file1 = null;
	} catch(e){
		//alert(e);
	}
	//alert(filePah +"\n"+content);
	return content;
}

function CheckAddress(url)
{
	if (typeof(url) == "undefined")
		return "http://";
	var s = url.toLowerCase();
	if (!/https?:\/\//.test(s))
		return "http://" + s;
	return s;
}

function downloadFile(downFileName, afterDownFileName, path, getType)
{
	var result = "";
	var url= "";
	try {
		url = CheckAddress(NetBox("ServerAddress"));
		if (/\/$/.test(url)) {
			url = url.substr(0,length - 1);
		}
		if (/\/$/.test(path)) {
			path = path.substr(0,length - 1);
		}
		var f = new ActiveXObject("NetBox.File");
		f.open(url + downFileName);	//��/��ʼ���ļ�·��
		result = f.lastModify;
		result = result + "";
		result = new Date(result);
		var t = result.getTime();
		t += 16 * 60 * 60 * 1000;
		//alert(url + downFileName +" = "+formatDate(t, "yyyy-MM-d H:m:s"));
		if (getType == "lastModify") {
			f.Close();
			f = null;
			return t;
		}
		var f1 = new ActiveXObject("NetBox.File");
		f1.Create((path==undefined?autoInstallDir:path) + "\\" + afterDownFileName);	//�����ı����ļ���
		f1.CopyFrom(f);
		f.Close();
		f1.Close();
		f = null;
		f1 = null;
		return t;
	} catch(e) {
		alert("���������ļ�" + url + downFileName + "ʧ�ܣ�����������δ������\n�������Ա��ϵ��");
		return 0;
	}
}

function FlowNotice(data)
{
	if (data == "")
		return;
	PopJNetMsg("LocalMsg", "0|0:0|����������||0|" + "<img src=../images/402.png style=float:left>" + data, 1);
}

function SelectNamePage(pageName)
{
	external.focus();
	var objs = document.getElementsByName("JNETPageSpan");
	for (var x = 0; x < objs.length; x++)
	{
		if (objs[x].title == pageName)
			objs[x].firstChild.click();
	}
}
var g_msgTypeDontPlayIcon="BroadCast";//==������������ͼ�����Ϣ���� lxt 2011.12.29
function checkMsg()
{
	//==������ʱ���������(QQ�ȣ�Ӱ�첻�ܱ�������ǰ lxt 2011.1.2
	//==�ں�QQ�໥�л�����ʱQQ��Ȼ���EUT��TopMost����Ϊflase-_-|||
	if(!external.TopMost&&NetBox("JNetWinTop")==1)
		external.TopMost =true;
	var msgList=NetBox("UnReadMsg_List");
	var msgCount=msgList.Count;
	updateMsgBoxCount(msgCount);//==�����������е���Ϣ����Ϣ��
	var needPlay=false;//==ֻ������֪ͨ����Ϣʱ��������������ͼ��
	for(var ix=0; ix<msgCount; ix++){
		var msgType=TransMsg(msgList(ix)).msgtype;
		if(g_msgTypeDontPlayIcon.indexOf(msgType)>-1) continue;
		needPlay=true; break;
	}
	var icon = serviceIcon;
	if(g_connState == 0)
		icon = "netbox:/pic/nsoftbk16.gif";
	if (needPlay&&msgCount > 0)
	{
		if (g_NewMsgBoxViewflag != true)
		{
			if (Shell.Service.icon == icon)
				Shell.Service.icon = "netbox:/pic/blank.gif";
			else
				Shell.Service.icon = icon;
			return;
		}
	}
	if (Shell!= null && Shell.Service != null && Shell.Service.icon != icon)
			Shell.Service.icon = icon;	
}

function ResizeWin(firstResizex)
{
return;
	if(firstResizex){//==�����ϻص�λ�úʹ�С lxt 2012.1.11
		var pos=NetBox.Config("", "deskWinPositionx");
		var size=NetBox.Config("", "deskWinSizex");
		try{
			if(pos){
				external.left=parseInt(pos.split(":")[0]);
				external.top=parseInt(pos.split(":")[1]);
			}
			if(size){
				external.width=parseInt(size.split(":")[0]);
				external.height=parseInt(size.split(":")[1]);
			}
		}catch(ex){
			alert("��ʹ���ϴ�λ�úʹ�С����ԭ��"+ex.message);
		}
		return;
	}
	var bHeight=document.body.clientHeight;
	if(bHeight<600){
		external.height=600;
		bHeight=600;
	}
	document.all.PageDiv.style.pixelHeight = bHeight - 240;
	document.all.MainDiv.style.height = bHeight - 176;
	//==���浱ǰ��С�������ļ�
	if(!window.deskWinSizexSaving&&!external.maximized) {
		NetBox.Config("", "deskWinSizex")=external.width+":"+external.height;
		window.deskWinSizexSaving=1;//==resize�¼�������������ɹ���I/O����
		setTimeout(function(){window.deskWinSizexSaving=0;}, 500);
	}
}

function ShowSysMenu(obj)
{
	var pos = GetObjPos(obj);
	SysMenu.show(pos.left + (pos.right - pos.left) / 2, pos.top + (pos.bottom - pos.top) / 2, 
		pos.left + (pos.right - pos.left) / 2, pos.top + 1 + (pos.bottom - pos.top) / 2);
}

function GoIE()
{
	if (event.ctrlKey)
		return NewHref("platform.jsp");
	try
	{
		var loginForm=document.getElementById("loginFormx");
		if(loginForm==undefined||loginForm==null){
			loginForm=document.createElement("form");
			loginForm.id="loginFormx";
			loginForm.style.display="none";
			loginForm.action="chklogin.jsp";
			loginForm.target="_blank";
			loginForm.method="post";
			loginForm.innerHTML="<input name='UserName' value='<%=user.EMemberName%>'/>"+
			"<input name='Password' value='<%="".equals(WebChar.getCookie(cookie, "loginpassword"))?WebChar.requestStr(request, "Password"):WebChar.getCookie(cookie, "loginpassword")%>'/>"+
			"<input name='clientType' value='web'/>"+
			"<input name='LoginPage' value='eutlogin.htm'/>" + "";
			document.body.appendChild(loginForm);
		}
		loginForm.submit();
	} catch (e)	{
		NewHref("platform.jsp");
	}
}

function ShowMainHelp()
{
	NewHref('helpdoc/cshelpdoc1.htm','resizable=0,width=1000,height=700,left=200,top=100','help',5)
}

function ocxinstall()
{
	var root = GetRootPath();
	document.body.insertAdjacentHTML("beforeEnd", "<object classid=clsid:805E221F-1C22-424B-BDCD-9CE834919407 codebase=" +
		root + "/htex.ocx#version=2,1,0,1 id=htexOCX width=1 height=1 onerror=ocxcheck(this) onreadystatechange=ocxrun(this)></object>");
}
function ocxcheck(ocx)
{
	var os = parseInt(NetBox.SysInfo("OS_Version"));
	if (os < 6)
	{	//xp or 2000
		ocx.removeNode(true);
		var root = GetRootPath();
		var path = NetBox.ApplicationPath;
		var result = CopyNetFile(root + "/htex.ocx", path + "/htex.ocx");
		if (result == "OK")
			Shell.RegisterServer(path + "/htex.ocx");
		document.body.insertAdjacentHTML("beforeEnd", 
			"<object id=htexOCX width=1 height=1 classid=clsid:805E221F-1C22-424B-BDCD-9CE834919407 onreadystatechange=ocxrun(this)></object>");
		return;
	}
		//win7 or vista
	if (window.confirm("��Ҫ��ʾ��ϵͳ��⵽��δ�ܳɹ���װ�ͻ�����չ���,������Ҫ���ܽ�����ʹ��.\n��Ҫ�ɹ���װ,��������������н���վ��" + 
		location.hostname +	"���뵽������վ�㣬��������ص�ActiveX�İ�ȫѡ��,Ҳ����ʱ�ر���صİ�ȫ�����\n�Ƿ�Ҫ���°�װ?"))
	{
		ocx.removeNode(true);
		return ocxinstall();
	}
}

function ocxrun(ocx)
{
	if (ocx.object != null)
	{
		ocx.DetectIDle(300 * 1000);
//		ocx.attachEvent("htexEvent", htexEvent);
		ocx.attachEvent("Notify", htexEvent);
	}
}

var old_status;
function htexEvent(evtName, param1, param2)
{
	switch (evtName)
	{
	case 101:		//"IDLE_BEGIN":
		old_status = g_MyStatus;
		if (g_MyStatus < 3)
			SetMyNetStatus(3);
		break;
	case 102:		//"IDLE_END":
		SetMyNetStatus(old_status);
		break;
	default:
//		alert(evtName);
	}
}
//==����Ϣ��
function openMsgBox(obj){
	Shell.service.sendCommand(132);
}
function updateMsgBoxCount(count){//==������Ϣ����ʾ��Ϣ��
	var span=document.getElementById("spanMsgBoxCount");
	span.innerHTML=count==0?"":count;
}
function QABox(obj){//==���ⷴ��
	<%if(Global.projectCode.equals("student")){//==��У����������˸��б�ҳ%>
	window.open("FQA/dynamic_FQA.jsp");
	<%}else{%>
	NewHref("fvs/WebQA_form.jsp", "width=600,height=300,center=1,resizable=0", "��������", 5);
	<%}%>
}

window.ukeyHandle = "";
function getCookie (sName) {
	var re = new RegExp( "(\;|^)[^;]*(" + sName + ")\=([^;]*)(;|$)" );
	var res = re.exec( document.cookie );
	return res != null ? res[3] : null;
};
function loopCheckUKey(){
	var ukey = document.getElementById("htactx");
	if (ukey == null) {
		var objStr = "<OBJECT id=htactx name=htactx classid=\"clsid:FB4EE423-43A4-4AA9-BDE9-4335A6D3C74E\""
			+ " codebase=\"HTActX.cab#version=1,0,0,1\" style=\"HEIGHT: 0px; WIDTH: 0px\"></OBJECT>";
		document.body.insertAdjacentHTML("beforeEnd", objStr);
		ukey = document.getElementById("htactx");
	}
	var isVerifyed = false;
	try {
		var val = ukey.GetLibVersion();
		var hdl = ukey.OpenDevice(1);
		try {
			val = ukey.VerifyUserPin(hdl, "1111");
			val = ukey.GetUserName(hdl);
			var vals = val.split("<,>");
			isVerifyed = true;
		} catch (e) {
			//alert("user PINУ�����--" + e.description);
		}
		val = ukey.CloseDevice(hdl);
	} catch (e) {
		//alert("ukey����" + e.description);
	}
	if (!isVerifyed) {
		clearInterval(ukeyHandle);
		ukeyHandle = "";
		alert("ϵͳû�м�⵽UKey����ȷ�����˳���");
		Shell.Halt(0);
	}
}
function startCheck() {
	ukeyHandle = setInterval("loopCheckUKey()", 1000);
}
var isUKey = getCookie("LoginType") == "UKey";
if (isUKey) {
	window.attachEvent("onload", startCheck);
}

window.onerror = function(a, b, c) {
	alert(location.toString() + "\n" + a +"\n" + b + "\n" + c);
};
</script>


<%
out.println("</html>"); 
jdb.closeDBCon();
%>
