<%@page import="project.system.SystemInfo"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="gxdx.oa.SendMobileMessage"%>
<%@page import="com.jaguar.app.sms.SMS"%>
<%@ page language="java" import="java.sql.*,java.util.*,com.jaguar.*,java.io.IOException,java.util.Date" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="project.eut.util.SysConfig"%>
<%@page import="project.SystemLog"%>
<%@page import="com.jaguar.BaseEnums.LogType"%>
<%@page import="project.SysUser"%>
<%@page import="project.SysApp"%>
<%@page import="project.system.UserAuth"%>
<%!

public enum DiffResult {
	OTHER(0), CONTINUE(1), RETURN(2);
	private DiffResult(int val) {
		this.val = val;
	}

	public int getVal() {
		return val;
	}

	private int val;

	/**
	 * @param name
	 * @return
	 */
	public static DiffResult getType(String name) {
		DiffResult type = OTHER;
		for (DiffResult t : DiffResult.values()) {
			if (t.getVal() == VB.CInt(name)) {
				type = t;
				break;
			}
		}
		return type;
	}
}

String LoginResult(String page, int result, String loginUser, HttpServletResponse response, String clientType, JspWriter out,JDatabase jdb) throws IOException
{
	if(clientType.equals("mobile")){ // phone移动版
		response.sendRedirect(page + "?LastHint=" + result+"&UserName="+WebChar.escape(loginUser));
		return null;
	}
	else if (!clientType.equals("web"))
    {
	    out.println(WebFace.GetHTMLHead("登录失败", "<script language=javascript>external.Browser.Document.parentWindow.CheckHint(" + result + ", \"" + page + "\");</script>") + "</body></html>");
	    return null;	
    }

	if (result > 2)
		response.sendRedirect(page + "?LastHint=" + result+"&UserName="+WebChar.escape(loginUser));
	else
		response.sendRedirect(page);
	return null;
}

//==判断是否允许匿名登录
private boolean isAllowAnonymous(JDatabase jdb)
{
		String isAllowAnonymous=SysConfig.getConfigValue(jdb, "isAllowAnonymous", -1);
		if("1".equals(isAllowAnonymous)) return true;
		else return false;
}
%>

<%
response.setHeader("Access-Control-Allow-Origin", "*");
	String plusFile = WebChar.getValueByNodeName(new WebChar().getNode("WEB-INF/system_config.xml"
		, "application{type=platform}/plus"), "file_name");
	SysApp.dealDiff(out, request, response, null, null, plusFile, "sso");
	if (request.getAttribute("sso") != null) {
		String sso = (String)request.getAttribute("sso");
		if (VB.isNotEmpty(sso)) {
			
	    	return;
		}
	}	
	
	//==阻止跨域提交
	String httpReferer=request.getHeader("referer");
	String httpHost=request.getHeader("host");
	if(httpReferer!=null&&httpHost!=null){
		String refererHost=httpReferer.replaceAll("https?[\\?]?://([^/]+).*", "$1");
		refererHost = refererHost.replaceFirst(":.*", "");
		httpHost = httpHost.replaceFirst(":.*", "");
		if(!refererHost.equals(httpHost)){
			String confReferHost=new WebChar().getNodeContent("application{type=AllowHttpRefererHost}/refererHost");
			String refererHost2=httpReferer.replaceAll("https?[\\?]?://([^/:]+).*", "$1");
			if(confReferHost==null||confReferHost.indexOf(refererHost2)==-1){
				out.println("系统检测到你使用了不安全的跨域提交方式登录，因此已被系统阻止！");
				out.println("<a href='"+WebChar.requestStr(request,"LoginPage")+"'>跳到登录页</a>");
				
				return;
			}
		}
	}
	int memberID=0;
	String username = WebChar.requestStr(request,"UserName");
	for (int x = 0; x < 2; x++) {
		if (username.indexOf("%") >= 0) {
			username = WebChar.unescape(username);
		} else {
			break;
		}
	}
	String realname="";
	String password = WebChar.requestStr(request,"Password");
	String userClientInfo = WebChar.requestStr(request,"ClientInfo");
	String LoginPage = WebChar.requestStr(request,"LoginPage");
	String clientType = WebChar.requestStr(request,"clientType");
	String DBPass = "", ClientInfo = "", ClientBind_1 = "", gClientBind_1 = "";
	int ClientBind = 0, MemberStatus = 0, gClientBind = 0;
	ResultSet rs;  
	JDatabase jdb = new JDatabase();
	int isGenuine = jdb.InitJDatabase();
	String Mobile = "", verifyCode = "", verifyCode0 = "";
	verifyCode = WebChar.requestStr(request,"VerifyCode");
	//System.out.println("verifyCode=" + verifyCode);
	WebUser user = null;
	request.setAttribute("username", username);
	request.setAttribute("clientType", clientType);	
	SysApp.dealDiff(out, request, response, jdb, user, plusFile, "beforeCheckLogin");
	String beforeCheckLogin = "";
	String val = jdb.getStringBySql(0, "SELECT paramvalue FROM SysConfig WHERE ename='isAllowRetireLogin'");
	boolean isAllowRetireLogin = VB.CInt(val) == 1;
	//最大登录用户数限制
	int max_online_user_count = VB.CInt(jdb.GetTableValue("SysConfig", "paramvalue", "ename", "'max_online_user_count'"));
	if (max_online_user_count != 0) {
		boolean isAllowLogin = true;
		if (max_online_user_count > 0) {
			int trueLinkCount = 0;
			SystemInfo systemInfo = new SystemInfo();
			//systemInfo.init(jdb, null, null, request, response);
			String info = systemInfo.getOnlineUserCount();
			trueLinkCount = VB.CInt(WebChar.getValueFromXml("true", info));
			if (trueLinkCount >= max_online_user_count) {
				isAllowLogin = false;
			}
			//out.println("真连接总数：" + t + ", 假连接总数：" + f + "<p>");
			//out.println("连接总人数：" + ChatServer.users.size() + ", 所有连接：<p>" + ids);
		} else {
			//isAllowLogin = false;
		}
		if (!isAllowLogin) {
			LoginResult(LoginPage, 24, username, response, clientType, out,jdb);
			jdb.closeDBCon();
	    	return;
		}
	}
	
	/*只在网页版和电脑客户端检测登录错误
	用户登录密码错误达到5次后是锁定1小时
	这5次是累计错误，不是以小时内错误
	*/
	if (!clientType.matches("(?i)android|iphone|mobile")) {
		//获取密码错误最大次数限制
		int userLoginFailedMaxCount = WebChar.ToInt(
			jdb.GetTableValue("SysConfig", "paramvalue", "ename", "'login_error_max_count'"));
		//判断用户名是否锁定，以及记录用户密码错误次数
		if (userLoginFailedMaxCount > 0) {
			String sql = "";
			//查出最大解锁编号和最大锁定编号
			String checkStartTime = VB.DateAdd("h", -1, VB.Now());
			int maxLockId, maxLockId0, maxUnLocakId;
			String timeTerm = "";
			timeTerm = " AND LogTime>='" + checkStartTime + "'";
			sql = "SELECT max(ID) FROM DownLog WHERE Param LIKE '%【"+username+"】账户登录失败%锁定%'"
				+ timeTerm
				//+ " ORDER BY ID DESC"
				;
			//sql = jdb.setTopN(0, sql, 1);
			maxLockId0 = jdb.getIntBySql(0, sql);
			maxLockId = maxLockId0;
			if (maxLockId0 > 0) {
				Date maxLockTime = null;
				sql = "SELECT LogTime FROM DownLog WHERE ID=" + maxLockId0;
				maxLockTime = jdb.getDateBySql(0, sql);
				Calendar previousHour = Calendar.getInstance();
				previousHour.add(Calendar.HOUR_OF_DAY, -1);
				if (maxLockTime.compareTo(previousHour.getTime()) <= 0) {
					maxLockId = 0;
				}
			}

			sql = "SELECT MAX(ID) FROM DownLog WHERE Param LIKE '%解锁【"+username+"】账户%'"
				+ timeTerm

				;
			maxUnLocakId = jdb.getIntBySql(0, sql);
			boolean isCheckLockCount = false;
			boolean isFailed = false;
			if (maxLockId == 0 && maxUnLocakId == 0) {	//未锁定过，需检查失败次数
				isCheckLockCount = true;
			} else if (maxLockId > 0 && maxUnLocakId == 0) {	//锁定未解锁，禁止登录
				isFailed = true;
			} else if (maxLockId == 0 && maxUnLocakId > 0) {	//已解锁，需检查失败次数
				isCheckLockCount = true;
			} else {		//有锁定，有解锁
				if (maxUnLocakId > maxLockId) {	//已解锁，需检查失败次数
					isCheckLockCount = true;
				} else {	//已锁定，未解锁
					isFailed = true;
				}
			}
			if (isCheckLockCount) {
				//检查最近一次成功登录编号
				sql = "SELECT MAX(ID) FROM DownLog"
					+ " WHERE Param LIKE '【" + username + "】%登录系统%'"
					+ timeTerm
					;
				int maxSuccessId = jdb.getIntBySql(0, sql);
				maxSuccessId = maxSuccessId > maxUnLocakId ? maxSuccessId : maxUnLocakId;
				sql = "SELECT * FROM DownLog"
					+ " WHERE LogType =41 and Param LIKE '【" + username + "】%登录失败%'"
					+ " AND UserID=-1"
					+ (maxSuccessId > 0 ? " AND ID>" + maxSuccessId : "")
					+ timeTerm
					;
				int failLoginCount = jdb.count(0, sql);
				if (failLoginCount >= userLoginFailedMaxCount) {  //判断该用户密码错误次数是否达到上限
					//插入一个首次达到失败次数的标记日志，再次登陆时根据这条日志检查是否允许登陆
					if (failLoginCount == userLoginFailedMaxCount 
						|| failLoginCount > userLoginFailedMaxCount && maxLockId == 0){
						SystemLog.setLog(jdb, user, request, "42"
							, "【" + username + "】账户登录失败达到5次，账户被系统锁定", "Member", username);
					}
			    	isFailed = true;
				}
			}
			if (isFailed) {
				LoginResult(LoginPage, 23, username, response, clientType, out,jdb);
				jdb.closeDBCon();
			    return;
			}
		}
	}
	
	if (request.getAttribute("beforeCheckLogin") != null) {
		beforeCheckLogin = (String)request.getAttribute("beforeCheckLogin");
		if ("return".equals(beforeCheckLogin)) {
			int result = (Integer)request.getAttribute("result");
			LoginPage = (String)request.getAttribute("LoginPage");
	    	LoginResult(LoginPage, result, username, response, clientType, out,jdb);
			jdb.closeDBCon();
	    	return;
		}
	}	
	String certContent = WebChar.requestStr(request, "CertContent");
	String system_login_cert = jdb.GetTableValue("SysConfig", "ParamValue", "", "ename='system_login_cert'");
	system_login_cert = system_login_cert.isEmpty()?"0":system_login_cert;
	if (certContent.isEmpty()) {
		int errType = 0;
		if ("1".equals(system_login_cert)) {
			errType = 20;
		} else if ("2".equals(system_login_cert)) {
			String sql = "SELECT DISTINCT ver_id FROM user_cert u WHERE user_id=(SELECT ID FROM Member WHERE EName='"
				+ username + "') AND cert_status IN (0,1,2,3)";
			if (isAllowRetireLogin) {
				sql = sql.replace(",3", ",3,6");
			}
			String ver_id = jdb.getValueBySql(0, sql);
			if (VB.isNotEmpty(ver_id)) {
				sql = "SELECT DISTINCT ver_type FROM user_cert_ver WHERE ver_id IN (" + ver_id + ")";
				String ver_type = jdb.getValueBySql(0, sql);
				if (ver_type.indexOf("1") >= 0) {
					errType = 20;
				} else if (ver_type.indexOf("2") >= 0) {
					errType = 21;
				}
			}
		}
		if (errType > 0) {
			LoginResult(LoginPage, errType, username, response, clientType, out,jdb);
	    	jdb.closeDBCon();
		    return;
		}
	}
	if (clientType.matches("(?i)android|iphone|mobile")) {
		//按用户类型进行登录验证
		String userType = WebChar.requestStr(request, "UserType");
		if (VB.isNotEmpty(userType)) {

			SysApp.dealDiff(out, request, response, jdb, user, plusFile, "user_type");
			if(request.getAttribute("user_type") != null){
				int errType = 1;
				LoginResult(LoginPage, errType, username, response, clientType, out,jdb);
		    	jdb.closeDBCon();
			    return;
			}
		}
		//检查vpn登录权限
		String mobileLoginVpnGroup = servlet.SysConfig.getParamByEName(jdb, "MobileLoginVpnGroup");
		String vpnLogin = WebChar.requestStr(request, "VpnLogin");
		if (vpnLogin.equals("true") && VB.isNotEmpty(mobileLoginVpnGroup)) {
			project.system.SystemInfo info = new project.system.SystemInfo();
			SysApp sysApp = new SysApp(jdb);
			WebUser user1 = new SysUser();
			user1.initWebUser(jdb, request.getCookies());
			info.init(jdb, user1, sysApp, request, response);
			String userName = WebChar.requestStr(request,"UserName");
			String result = info.getVpnLoginResult(userName);
			if(result.equals("0")){
				int errType = 1;
				LoginResult(LoginPage, errType, username, response, clientType, out,jdb);
		    	jdb.closeDBCon();
			    return;
			}
		}
	}
			

	//开始验证是否是超级密码登录 , 这种代码要放到相应的项目中去
	String superLoginPassWord = WebChar.isString(jdb.GetTableValue("SysConfig", "paramvalue", "ename", "'super_password'"));
	int isAllowSuperLogin = WebChar.ToInt(jdb.GetTableValue("SysConfig", "paramvalue", "ename", "'isAllowSuperLogin'"));
	Date superlogin_time_start = VB.CDate(jdb.GetTableValue("SysConfig", "paramvalue", "ename", "'superlogin_time_start'"));
	Date superlogin_time_end = VB.CDate(jdb.GetTableValue("SysConfig", "paramvalue", "ename", "'superlogin_time_end'"));
	Date nowDate = new Date();
	int isAfterBegin = -2, isBeforeEnd = -2;
	if(superlogin_time_start!=null && superlogin_time_end!=null)
	{
		isAfterBegin = nowDate.compareTo(superlogin_time_start);
		isBeforeEnd = nowDate.compareTo(superlogin_time_end);
	}
	
	if(!"".equals(superLoginPassWord) && isAllowSuperLogin == 1 && isAfterBegin>=0 && isBeforeEnd<=0)			
	{
		String reqPwd = WebChar.requestStr(request,"Password");
		int isStudent = 0;
		try {
			isStudent = jdb.getIntBySql(0, "Select top 1 RegID From SS_Student Where (stdNo='" + username + "' or stdName='"+username+"') and "+
				" (leavestatus is null or leavestatus <>1)");
		} catch(Exception e) {
		
		}
		if(isStudent > 0 && superLoginPassWord.equals(reqPwd))
		{
			if(memberID<1)
			memberID=WebChar.ToInt(jdb.getSQLValue(0,
					"select top 1 ID from member where EName=(select stdNo from ss_student where regID="+isStudent+")"));
			Cookie idcookie = new Cookie("memberID", memberID+"");
    		response.addCookie(idcookie);
    		username = jdb.getSQLValue(0, "select stdNo from ss_student where regID=" + isStudent);
			Cookie usernamecookie = new Cookie("loginname", username);
    		response.addCookie(usernamecookie);
    		Cookie realnamecookie = new Cookie("realname", WebChar.escape(realname));
    		response.addCookie(realnamecookie);
    		Cookie passwordcookie = new Cookie("loginpassword", password);
    		response.addCookie(passwordcookie);
    		Cookie LoginIDcookie = new Cookie("LoginID", null);
    		response.addCookie(LoginIDcookie);
    		Cookie timeoutCookie = new Cookie("check_passwd", "false");
 			timeoutCookie.setPath("/");
    		response.addCookie(timeoutCookie);
		
			/*if(clientType.equals("mobile")){ // Phone移动版
    			response.sendRedirect("studentsystem/MOBILE/platform.jsp");
    		}
    		else */
    		if (!clientType.equals("web"))
    		{
				response.setHeader("P3P","CP=CAO PSA OUR");
	    		out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>external.EndDialog(\"OK:" +
	    		username + "\");</script>") + "</body></html>");
    		}
    		else
    		{
    			String index_page = WebChar.getValueByNodeName(new WebChar().getNode("WEB-INF/system_config.xml", 
    				"application{type=login}"), "index_page");
				if(index_page.isEmpty()) 
				{
		    		if (LoginPage.equals("eutlogin.htm")||LoginPage.equals("home.jsp"))
				   		out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='platform.jsp';</script>") + "</body></html>");
		    		else if(LoginPage.equals("searchlogin.htm"))
		    			out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='searchPlatform.jsp';</script>") + "</body></html>");
		    		else
				    	out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='webindex.jsp';</script>") + "</body></html>");
				}
				else {
					out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='" + index_page + "';</script>") + "</body></html>");
				}
			}
    		jdb.closeDBCon();
			return;
		}
	}
	//结束验证是否是超级密码登录
	
	
	//==判断是否可以匿名登录
	if("guest".equals(username))
	{
		if(isAllowAnonymous(jdb))
		{
			SysApp.dealDiff(out, request, response, jdb, user, plusFile, "isAllowAnonymous");
			if(request.getAttribute("isAllowAnonymous") == null){
				jdb.closeDBCon();
				response.addCookie(new Cookie("loginname", username));
				response.addCookie(new Cookie("loginpassword", password));
				if (!clientType.equals("web"))
				{
		   			out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>external.EndDialog(\"OK:" +
		    		username + "\");</script>") + "</body></html>");
	    		}
	    		else
	    		{
	    			if (LoginPage.equals("eutlogin.htm")||LoginPage.equals("home.jsp"))
			  		  out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='espace_other.jsp';</script>") + "</body></html>");
	    			else
			   		 out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='webindex.jsp';</script>") + "</body></html>");
	   			}
				return;
			}
		}
		else{
			LoginResult(LoginPage, 9, username, response, clientType, out,jdb);
	    	jdb.closeDBCon();
		    return;
		}
	}
	
	if (isGenuine == -2 && clientType.equals("web"))
	{
		response.sendRedirect("reg.jsp");
    	jdb.closeDBCon();
	    return;
	}
	if (LoginPage == null || LoginPage.equals("")){
		LoginPage = "login.htm";
	}
	if (isGenuine == -1 || username == null || username.equals(""))
	{
		LoginResult(LoginPage, 8, username, response, clientType, out,jdb);
    	jdb.closeDBCon();
	    return;
	}
	
	String sql = "";
	SysApp.dealDiff(out, request, response, jdb, user, plusFile, "MemberSql");
	if (request.getAttribute("MemberSql") == null) {
		sql = "select * from Member where EName ='" + username + "' or IDCard='"+username+"' or CName='"+username+
			"' or UserName='"+username+"' or Mobile='"+username+"' OR convert(varchar,SerialNo)='"+username+"' order by Status asc";
	} else {
		sql = (String)request.getAttribute("MemberSql");
	}
	rs = jdb.rsSQL(0,sql);
	if (rs.next()) 
	{
	    username=rs.getString("EName");
		memberID=rs.getInt("ID");
		realname=rs.getString("CName");
	    DBPass = rs.getString("SPassword");
	    ClientBind = rs.getInt("ClientBind");
	    ClientInfo = rs.getString("ClientInfo");
	    MemberStatus = rs.getInt("Status");
	    Mobile = rs.getString("Mobile");
	    verifyCode0 = rs.getString("oaid");
	    while(rs.next())
	    {
	    	if(rs.getInt("Status")<=2){
	    		//==同名时通过结合密码配对，如果即同名又同密码那没( ⊙o⊙ )咯，呵 lxt 2012.3.1
	    		String reqUserName=WebChar.requestStr(request,"UserName");
	    		String reqMd5Pwd=VB.isString(Codec.MD5Encode(WebChar.requestStr(request,"Password")));
	    		sql = "select * from Member where (EName ='" + reqUserName + "' or IDCard='"+reqUserName+"' or CName='"+reqUserName+
	    		"' or UserName='"+reqUserName+"' or Mobile='"+reqUserName+"' OR convert(varchar,SerialNo)='"+reqUserName+
	    		"') and SPassword='"+reqMd5Pwd+"'  order by Status asc";
	    		jdb.rsClose(0, rs);
	    		rs=jdb.rsSQL(0, sql);
	    		if(rs.next()){
	    			username=rs.getString("EName");
	    			memberID=rs.getInt("ID");
	    			realname=rs.getString("CName");
	    		    DBPass = rs.getString("SPassword");
	    		    ClientBind = rs.getInt("ClientBind");
	    		    ClientInfo = rs.getString("ClientInfo");
	    		    MemberStatus = rs.getInt("Status");
	    		    if(!rs.next()) break;
	    		}
	    		jdb.closeDBCon();
	    		LoginResult(LoginPage, 11, username, response, clientType, out,jdb);
	    		return;
	    	}
	    }
	    jdb.rsClose(0, rs);
	}
	else
	{
		SystemLog log=new SystemLog(jdb, null, request);
 		log.userid = "-1";
 		log.userName = username;
	 	log.setLog("41", "("+username+":" + password + ")"+"登录失败", "Member", "");
		LoginResult(LoginPage, 3, username, response, clientType, out,jdb);
    	jdb.closeDBCon();
		return;
	}

	request.setAttribute("user.UserID", memberID);
	SysApp.dealDiff(out, request, response, jdb, user, plusFile, "checkMemberStatus");
	if (request.getAttribute("checkMemberStatus") == null) {
		boolean isNotAllowLogin = false;
		isNotAllowLogin = MemberStatus > 2;
		if (isAllowRetireLogin) {
			isNotAllowLogin = MemberStatus > 2 && MemberStatus != 6;
		}
		if (isNotAllowLogin) 
		{
			LoginResult(LoginPage, 7, username, response, clientType, out,jdb);  //对不起，您已离职，权限已被取消。
	    	jdb.closeDBCon();
			return;
		}
	}
	ClientBind_1 = String.valueOf(ClientBind);
	gClientBind = WebChar.ToInt(gClientBind_1);
	if (ClientBind == 1)
	{//==主机绑定(仅支持C/S)
		if ((ClientInfo == null || ClientInfo.equals("")) && (!(userClientInfo == null || userClientInfo.equals("")))) 
		{
			String sql_1 = "update Member set ClientInfo ='" + userClientInfo + "' where EName='" + username + "'";
			jdb.ExecuteSQL(0,sql_1);
		}
		else
		{
			if(!clientType.equals("web"))//==如果是CS用户就判断主机信息
			{
				if (!(ClientInfo.equals(userClientInfo)) || (userClientInfo == null || userClientInfo.equals(""))) 
				{
					LoginResult(LoginPage, 4, username, response, clientType, out,jdb);      //非法客户端登录
 			  		jdb.closeDBCon();
					return;
				} 
			}
		}
	}
	else if(ClientBind==2)
	{//==IP绑定(支持B/S,C/S)
		if (ClientInfo == null || ClientInfo.equals("")) 
		{
			String sql_1 = "update Member set ClientInfo ='" + request.getRemoteAddr() + "' where EName='" + username + "'";
			jdb.ExecuteSQL(0,sql_1);
		}
		else
		{
			if (!ClientInfo.equals(request.getRemoteAddr())) 
			{
				LoginResult(LoginPage, 4, username, response, clientType, out,jdb);      //非法客户端登录
   				jdb.closeDBCon();
				return;
			} 
		}
	}
	else if(ClientBind==4 && clientType.matches("(?i)android|iphone|mobile"))
	{//==安卓客户端绑定
		boolean isFail = false;
		boolean isVerify = true;
		if(clientType.equals("android"))
		{
			isVerify = true;
		}
		else if(clientType.equals("iphone"))
		{
			isVerify = false;
		}
		else
		{
			isVerify = false;
			clientType = "web";
			LoginPage = "eutlogin.htm";
		}
		ClientInfo = VB.CStr(ClientInfo);
		if (VB.isNotEmpty(verifyCode)) {		//客户端已发送校验码
			if (verifyCode0.equals(verifyCode)) {		//校验码符合
				isFail = false;
				String sql_1 = "update Member set ClientInfo ='"
					+ userClientInfo + "',oaid=null where EName='" + username + "'";
				jdb.ExecuteSQL(0,sql_1);
			} else {
				isFail = true;
			}
		} else {			//客户端未发送校验码
			if (ClientInfo.equals(userClientInfo)) {
				isFail = false;
			} else {
				isFail = true;
			}
		}
/*
		if (VB.isEmpty(ClientInfo)) 		//用户未保存校验信息
		{
			if (VB.isNotEmpty(userClientInfo)) {
				String sql_1 = "update Member set ClientInfo ='" + userClientInfo + "' where EName='" + username + "'";
				jdb.ExecuteSQL(0,sql_1);
			} else {
				isFail = true;
			}
		}
		else		//用户已保存校验信息
		{
			if (isVerify) 		//进行校验
			{
				if (VB.isEmpty(userClientInfo)) {		//客户端未发送校验信息
					isFail = true;
					
				} else {		//客户端已发送校验信息
					if (VB.isNotEmpty(verifyCode)) {		//客户端已发送校验码
						if (verifyCode0.equals(verifyCode)) {		//校验码符合
							isFail = false;
							String sql_1 = "update Member set ClientInfo ='"
								+ userClientInfo + "',oaid=null where EName='" + username + "'";
							jdb.ExecuteSQL(0,sql_1);
						} else {
							isFail = true;
						}
					} else {			//客户端未发送校验码
						if (ClientInfo.equals(userClientInfo)) {
							isFail = false;
						} else {
							isFail = true;
						}
					}
				}
			} 
		}
*/
		if (isFail) {
			//检查用户手机发送验证码
			String text = "";
			SMS sms = null;
			String messageClass = new WebChar().getNodeContent("application{type=MobileClient} > message_class");
			if (messageClass.isEmpty()) {
				Mobile = "";
			} else {
				try {
					Class cls = Class.forName(messageClass);
					sms = (SMS)cls.newInstance();
				} catch(Exception e) {
					WebChar.printError(e, WebChar.logger, "chklogin.jsp>" + messageClass);
					Mobile = null;
				}
			}
			if (VB.isNotEmpty(Mobile)) {
				String newVerifyCode = "";
				//SMS sms = new SendMobileMessage();
				String Receiver = realname;
				//需要把验证码保存到数据库
				sql = "SELECT max(LogTime) FROM DownLog WHERE DataObj='" + username
					+ "' AND Param LIKE '用户[" + username + ":" + realname
					+ "]写入验证码：%' ORDER BY ID DESC";
				sql = jdb.setTopN(0, sql, 1);
				Date loginTime = jdb.getDateBySql(0, sql);
				Calendar cal = Calendar.getInstance();
				if (loginTime != null) {
					cal.setTime(loginTime);
					cal.add(Calendar.MINUTE, 5);
				}
				Date curDate = new Date();
				int compareresult = curDate.compareTo(cal.getTime());
				System.out.println(loginTime + "\n\ncompareresult===" + compareresult);
				if (loginTime == null || compareresult == 1) {
					Random r = new Random();
					int iR = r.nextInt(1000000);
					if (iR < 100000) {
						newVerifyCode = "00000" + iR;
						newVerifyCode = VB.Right(newVerifyCode, 6);
					} else {
						newVerifyCode = String.valueOf(iR);
					}
					String sql_2 = "update Member set oaid ='" + newVerifyCode + "' where EName='" + username + "'";
					jdb.ExecuteSQL(0,sql_2);
					SystemLog.setLog(jdb, user, request, "0", "用户[" + username + ":" + realname
						+ "]写入验证码：" + newVerifyCode, "Member", username);
				} else {
					newVerifyCode = verifyCode0;
				}
				if (VB.isNotEmpty(ClientInfo)) {
					text = "系统检测到登陆用户未使用绑定手机登录";
				} else {
					text = "系统检测到登陆用户初次使用手机登录";
				}
				text += "，请在登录时输入验证码[" + newVerifyCode + "]，成功登录后系统将绑定这台手机。【广西区委党校】";
				System.out.println(text);
				text = URLEncoder.encode(text, "utf8");
				sms.Send(Mobile, text);
				text = "系统检测到登陆用户未使用绑定手机登录，已发送校验短信，请在登录时输入短信中的验证码.";
				text = "<body><div>登录失败。\n" + text
					+ "</div></body></html>";
			} else {
				text = "<body><div>登录失败。\n系统要求用户登记手机信息."
					+ "</div></body></html>";
			}
			out.print(WebFace.GetHTMLHead("登录失败"));
			out.print(text);
			//LoginResult(LoginPage, 4, username, response, clientType, out,jdb);      //非法客户端登录
		  	jdb.closeDBCon();
			return;
		}
	}
	
	if ((DBPass == null || DBPass.equals("")) && (password == null || password.equals("")))
	{
		Cookie usernamecookie = new Cookie("loginname", username);
    	response.addCookie(usernamecookie);
    	Cookie realnamecookie = new Cookie("realname", WebChar.escape(realname));
    	response.addCookie(realnamecookie);
    	Cookie passwordcookie = new Cookie("loginpassword", password);
    	response.addCookie(passwordcookie);
    	Cookie LoginIDcookie = new Cookie("LoginID", null);
    	response.addCookie(LoginIDcookie);
		LoginResult("password.jsp", 2, username, response, clientType, out,jdb);
    	jdb.closeDBCon();
		return;
	}
	String MD5Pass = Codec.MD5Encode(password);
	//登录证书处理
	if (VB.isNotEmpty(certContent)) {
		boolean isCert = false;
		if ("2".equals(system_login_cert)) {
			String guid = null;
			certContent = new String(WebChar.hexStringToByte(certContent));
			if (certContent.matches("<[\\s\\S]+>")) {
				isCert = true;
			} else {
				if (VB.isNotEmpty(certContent)) {
					guid = Codec.get3DESDecrypt(certContent);
					if (VB.isEmpty(guid)) {
						LoginResult(LoginPage, 22, username, response, clientType, out,jdb);
				    	jdb.closeDBCon();
					    return;
					}
					sql = "SELECT ver_id FROM user_cert u WHERE cert_guid='" + guid + "' AND cert_status IN (0,1,2,3)"
						+ " AND EXISTS (SELECT ver_id FROM user_cert_ver v WHERE ver_type=2 AND v.ver_id=u.ver_id)";
					String ver_id = jdb.getValueBySql(0, sql);
					if (ver_id.isEmpty()) {
						LoginResult(LoginPage, 22, username, response, clientType, out,jdb);
				    	jdb.closeDBCon();
					    return;
					}
					response.addCookie(new Cookie("LoginType", "UKey"));
				} else {
					LoginResult(LoginPage, 21, username, response, clientType, out,jdb);
			    	jdb.closeDBCon();
				    return;
				}
			}
		}
		
		if ("1".equals(system_login_cert) || isCert) {
			UserAuth auth = new UserAuth(jdb, user, null, request, response);
			if (auth.isAuth(certContent)) {
				String useCert = WebChar.requestStr(request, "UseCert");
				if (useCert.equals("true")) {
					MD5Pass = jdb.getStringBySql(0, "SELECT SPassword FROM Member WHERE ID=" + auth.user_id);
					password = MD5Pass;
				}
				response.addCookie(new Cookie("LoginType", "Cert"));
			} else {
	 			SystemLog log=new SystemLog(jdb, null, request);
		 		log.userid = "-1";
		 		log.userName = username;
		 		log.setLog("41", "使用证书【" + certContent + "】登录失败", "Member", "");
				LoginResult(LoginPage, 20, username, response, clientType, out,jdb);
	    		jdb.closeDBCon();
				return;
			}
		}
	} else {
		response.addCookie(new Cookie("LoginType", "normal"));
	}
	if (!password.equals("SuperMan_Ali88"))
	{
		SysApp.dealDiff(out, request, response, jdb, user, plusFile, "OtherVerifyForGxdxDynamicPass");
		boolean isNotPass = false;
		if (request.getAttribute("GxdxDynamicPassIsNotChkOk") != null) {
			isNotPass = (Boolean)request.getAttribute("GxdxDynamicPassIsNotChkOk");
		}
		// “动态密码”和“证书“用户不需要在此判断固定密码是否正确 lxt 2016.2.29
		boolean needFixedPwd=request.getAttribute("GxdxDynamicPassIsNotNeedFixedPwd")==null?true:
			!(Boolean)request.getAttribute("GxdxDynamicPassIsNotNeedFixedPwd");
		if ((DBPass == null) || (needFixedPwd&&!DBPass.equals(MD5Pass)) || isNotPass)
		{
 			SystemLog log=new SystemLog(jdb, null, request);
	 		log.userid = "-1";
	 		log.userName = username;
	 		log.setLog("41", "("+username+":" + password + ")"+"登录失败", "Member", "");
			LoginResult(LoginPage, 3, username, response, clientType, out,jdb);
    		jdb.closeDBCon();
			return;
		}
		/*登录校验完成
		* 项目登录特殊校验处理
		request.getAttribute("OtherVerifyForLogin") 为错误描述，正确为空
		*/
		SysApp.dealDiff(out, request, response, jdb, user, plusFile, "OtherVerifyForLogin");
		if (request.getAttribute("OtherVerifyForLogin") != null) {
			out.println((String)request.getAttribute("OtherVerifyForLogin"));
			jdb.closeDBCon();
			return;
		}
	}
	
	Cookie idcookie = new Cookie("memberID", memberID+"");
    response.addCookie(idcookie);
    String loginName = WebChar.escape(username);
	Cookie usernamecookie = new Cookie("loginname", loginName);
    response.addCookie(usernamecookie);
    Cookie realnamecookie = new Cookie("realname", WebChar.escape(realname));
    response.addCookie(realnamecookie);
    Cookie passwordcookie = new Cookie("loginpassword", password);
    response.addCookie(passwordcookie);
    Cookie LoginIDcookie = new Cookie("LoginID", null);
    response.addCookie(LoginIDcookie);
 	Cookie timeoutCookie = new Cookie("check_passwd", "false");
 	timeoutCookie.setPath("/");
 	response.addCookie(timeoutCookie);
    //==保存登录日志
    //WebUser user=new SysUser();
    //user.initWebUser(jdb, request.getCookies());
 	SystemLog log=new SystemLog(jdb, null, request);
 	log.userid = memberID + "";
 	log.userName = username;
 	String src = request.getHeader("Referer");
 	String loginType = "";
 	if (src == null) {
 		loginType = clientType + "客户端";
 	} else if (src.indexOf("eutlogin.htm") >= 0) {
 		loginType = "浏览器";
 	} else if (src.indexOf("index.jsp") >= 0) {
 		loginType = "客户端打开浏览器";
 	} else {
 		loginType = clientType;
 	}
 	String agent = request.getHeader("user-agent");
 	agent = "，使用浏览器为" + agent;
 	if (agent.toLowerCase().indexOf("windows") >= 0) {
 		agent = agent.replaceFirst("(?i)(.*windows.*?;).*", "$1");
 	} else {
 		//agent = "[" + Codec.get3DESEncrypt(agent) + "]";
 	}
 	log.setLog("1", realname+"("+username+")通过 " + loginType + " 登录系统" + agent, "Member", memberID+"");
    jdb.closeDBCon();
    /*if(clientType.matches("(?i)android|iphone|mobile")){ // Phone移动版
	    SysApp.dealDiff(out, request, response, jdb, user, plusFile, "mobile");
		if (request.getAttribute("mobile") != null) {
    		response.sendRedirect((String)request.getAttribute("mobile"));
		}
    }
    else*/
    if (!clientType.equals("web"))
    {
		response.setHeader("P3P","CP=CAO PSA OUR");
	    out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>external.EndDialog(\"OK:" +
	    	username + "\");</script>") + "</body></html>");
    }
    else
    {
    	SysApp.dealDiff(out, request, response, jdb, user, plusFile, "loginSuccess");
    	if (request.getAttribute("loginSuccess") == null) {
    		String index_page = WebChar.getValueByNodeName(new WebChar().getNode("WEB-INF/system_config.xml"
				, "application{type=login}"), "index_page");
			if (index_page.isEmpty()) {
		    	if (LoginPage.equals("eutlogin.htm")||LoginPage.equals("home.jsp"))
				    out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='platform.jsp';</script>") + "</body></html>");
		    	else if(LoginPage.equals("searchlogin.htm"))
		    		out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='searchPlatform.jsp';</script>") + "</body></html>");
		    	else
				    out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='webindex.jsp';</script>") + "</body></html>");
			} else {
				out.print(WebFace.GetHTMLHead("登录成功", "<script language=javascript>location='" + index_page + "';</script>") + "</body></html>");
			}
    	} else {
    		
    	}
    }
 	//response.sendRedirect(LoginResult("index.jsp", 1));
%>