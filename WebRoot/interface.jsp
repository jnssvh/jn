<%@page import="com.jaguar.app.HttpAccess"%>
<%@page import="project.ICaseAction"%>
<%@page import="project.InitAction"%>
<%@ page language="java" import="java.sql.* ,com.jaguar.*" pageEncoding="gbk"%>
<%!
	

 %>
<%@ include file="init_public.jsp" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

String type = WebChar.requestStr(request, "type");
//response.setCharacterEncoding("utf8");
String result = "", sql = "";
boolean isAuth = false;


String auth_user = WebChar.requestStr(request, "auth_user");
String auth_passwd = WebChar.requestStr(request, "auth_passwd");
if (auth_user.isEmpty() || auth_passwd.isEmpty()) {
	result += "<login><result>0</result>"
		+ "<description>user name or password not found</description></login>";
} else {
	String url = basePath + "chklogin.jsp?UserName=" + auth_user + "&Password=" + auth_passwd;
	String r = HttpAccess.getGetResponseWithHttpClient(url, "gbk");
	if (r.indexOf("成功") >= 0) {
		sql = "SELECT CName FROM Member WHERE EName='" + auth_user + "'";
		String cname = jdb.getValueBySql(0, sql);
		sql = "SELECT * FROM WorkGroup WHERE GroupName='外部系统查询组' AND (Members LIKE '"
			+ cname + "' OR Members LIKE '" + cname + ",%' OR Members LIKE '%,"
			+ cname + ",%' OR Members LIKE '%," + cname + "')";
		int count = jdb.count(0, sql);
		if (count > 0) {
			isAuth = true;
		}
	} else {
	}
}
if (!isAuth) {
	result += "<login><result>0</result>"
		+ "<description>login failt</description></login>";
	result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
		+ "<datas><data_type>login_auth</data_type><data>" + result + "</data></datas>";
	out.clear();
	out.print(result);
	jdb.closeDBCon();
	return;
}
if (type.equals("auth")) {
	String UserName = WebChar.requestStr(request, "UserName");
	String Password = WebChar.requestStr(request, "Password");
	if (UserName.isEmpty() || Password.isEmpty()) {
		result += "<result>0</result>"
			+ "<description>user name or password not</description>";
	} else {
		String url = basePath + "chklogin.jsp?UserName=" + UserName + "&Password=" + Password;
		String r = HttpAccess.getGetResponseWithHttpClient(url, "gbk");
		if (r.indexOf("成功") >= 0) {
			result += "<result>1</result>"
				+ "<description>login success</description>";
		} else {
			result += "<result>0</result>"
				+ "<description>login failt</description>";
		}
	}
	//result = "<auth>" + result + "</auth>";
} else if (type.equals("isUserExists")) {
	String UserName = WebChar.requestStr(request, "UserName");
	sql = "SELECT ID FROM Member WHERE EName='" + UserName + "'";
	int id = jdb.getIntBySql(0, sql);
	if (id > 0) {
		result += "<result>1</result>"
			+ "<description>user exists</description>";
	} else {
		result += "<result>0</result>"
			+ "<description>user not exists</description>";
	}
	//result = "<isUserExists>" + result + "</isUserExists>";
} else if (type.equals("getMemberInfo")) {
	String UserName = WebChar.requestStr(request, "UserName");
	UserName = WebChar.unescape(UserName);
	if (UserName.isEmpty()) {
		result += "<result>0</result>"
			+ "<description>user name not</description>";
		result = "<getMemberInfo>" + result + "</getMemberInfo>";
	} else {
		sql = "SELECT ID,SerialNo,EName,CName,Leader,Man,Dept,Duty"
			+ ",MemberRight,MemberLevel,Status,Info,IPAddress,Phone,Mobile"
			+ ",HomePhone,EMail,Birthday,EnterTime,LeaveTime,Culture,Specialty"
			+ ",Native,College,Photo,SelfResume,Remark,NickName,IDCard,pym"
			+ ",oaid,ICCardNo,AccNum,UserNation,UserJobTitle,UserName"
			+ ",article_count,WorkTime,Party,PartyTime FROM Member"
			+ " WHERE EName='" + UserName + "' OR CName='" + UserName + "'";
		result = sysApp.sql2xml( sql, "escape", "", true, "" );
		result = WebChar.getValueFromXml("data", result);
	//result = "<getMemberInfo>" + result + "</getMemberInfo>";
		//result = WebChar.escape(result);
		//result = "<result>1</result>"
		//	+ "<value>" + result + "></value>";
	}
} else {
	if (type.length() == 0) {
		result += "<description>null param error</description>";
	}
}
if (result.startsWith("<?xml")) {
	
} else {
	result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
		+ "<datas><data_type>" + type + "</data_type><data>" + result + "</data></datas>";
}
out.clear();
out.print(result);
jdb.closeDBCon();%>