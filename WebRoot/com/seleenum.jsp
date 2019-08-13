<%@ page language="java" import="java.util.*,com.jaguar.*,java.sql.*" pageEncoding="GBK"%>
 <%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
 <%@ include file="init.jsp" %>
<%
	WebEnum webenum = new WebEnum(jdb);
//	jdbapp = new JDBApp(jdb, user, webenum);
//	if (!user.GetDataRight(12,1,"",0,""))
//	{
//		out.println("您没有权限执行此操作，请与管理员联系");
//		out.close();
//	}

		String[][] aDB = null;
		String Quote, s[], s1[];
		String EnumType = "";
			
		EnumType = WebChar.requestStr(request, "EnumType");
		if (EnumType.substring(0, 1).equals("@"))
			EnumType = EnumType.substring(1);
		else
		{
			
		}
		aDB = webenum.GetEnumResult(EnumType);

		if (WebChar.RequestInt(request, "AjaxMode") == 1)
		{
			String result = "", fenge = "";
			if (aDB != null)
			{
				for (int x = 0; x < aDB.length; x++)
				{
					result += fenge + aDB[x][0] + ":" + aDB[x][1];
					fenge = ",";
				}
			}
			else
				result = "[]";
			out.print(result);
			jdb.closeDBCon();
			return;
		}

		out.println(WebFace.GetHeadBody("选择枚举量", WebFace.MainBodyColor));
			

%>
<DIV style=height:420;overflow:auto>
<table cellpadding=3 cellspacing=1 border=0 width=100% bgcolor=<%=WebFace.MainTableLnColor%>>
<%
	if (aDB != null)
	{
			for (int x = 0; x < aDB.length; x++)
			{
%>
				<tr bgcolor=white onclick=SelObject(this) ondblclick=ConfirmDlg()><TD>
				<%=aDB[x][0]%></TD><TD><%=aDB[x][1]%></TD></TR>
<%
			}
			jdb.closeDBCon();
	}
%>
</table></DIV><BR><CENTER>
<input type=Button value=确定 onclick=ConfirmDlg()>&nbsp;
<input type=button value=取消 onclick=window.close()>&nbsp;
</CENTER>
<script language=javascript src=psub.jsp></script>
<SCRIPT LANGUAGE="JavaScript">

function ConfirmDlg()
{
	if (typeof(oFocus) == "object")
		returnValue = oFocus.cells[0].innerText + ":" + oFocus.cells[1].innerText;
	else
	{
		alert("未选择");
		return;
	}
	// Chrome lxt 2017.12.27
	if(navigator.userAgent.indexOf("Chrome")>-1)
		window.localStorage["crmSelenumReturnValue"]=returnValue;
	window.close();
}

</SCRIPT>
<% out.println("</BODY></HTML>"); %>