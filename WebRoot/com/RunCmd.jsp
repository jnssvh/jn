<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ include file="init.jsp"%>
<%
	String cmd = WebChar.requestStr(request, "Cmd");
	String Param = WebChar.requestStr(request, "Param");
	Param= WebChar.unescape(WebChar.unescape(Param));
	int nType = WebChar.RequestInt(request, "nType");	// 0:page function; 1:ajax function; 2:page sub; 3:ajax sub
	int r = 0;
	String result = "";
	if (nType == 2 || nType == 3)
	{
		if ( cmd.equals("DBExecuteSQL") )
		{
			r = jdb.ExecuteSQL( 0, Param );
		}
		result = "OK";
	}
	//else
	//	result = Eval(cmd & "(" & Param & ")")

	if ( r == -1 )
		result = "Error : 执行内部命令[" + cmd + "(" + Param + ")]  错误。<BR>错误内容为：" + jdb.getErrorStr(0);


	//call RecordHis(72, 0, 0, 0, Now(), request.ServerVariables("REMOTE_ADDR"))
	if (nType == 1 || nType == 3)		//for ajax function
	{
		out.print(result);
	}
	else
	{
		out.print(WebFace.GetHTMLHead("执行内部命令", "<link rel='stylesheet' type='text/css' href='com/forum.css'>"));
		out.print(WebFace.SubmitResult(result, 1));
	}
jdb.closeDBCon();
%>