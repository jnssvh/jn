<%@ page language="java" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
<%@ include file="../init_comm.jsp" %>
<%
	out.println(WebFace.GetHTMLHead("上传文件", "<link rel='stylesheet' type='text/css' href='../forum.css'><script language=javascript src=psub.jsp></script>"));

%>
<p id=StatusBar>正在打开选择文件对话框...</p>
<div id=FileListDiv style=display:none;padding-left:40px;width:100%;height:90%;overflow:auto;></div>
<iframe id=FormDataFrame width=0></iframe>
<SCRIPT LANGUAGE="JavaScript">
function window.onload()
{
	document.all.FormDataFrame.src = "uploadform.jsp";
	window.setTimeout("SubmitLocalFile()", 500);
}



function SubmitLocalFileOK(FileType, AffixID, FileCName)
{
	return CloseWin();
}

function RefreshMsg(msg, bRefresh)
{
	document.all.StatusBar.innerHTML = msg;
}

function SubmitLocalFile()
{
	try
	{
		document.all.FormDataFrame.contentWindow.document.all.LocalName.click();
	}
	catch (e)
	{
		window.setTimeout("SubmitLocalFile()", 500);
		return;
	}
	if (document.all.FormDataFrame.contentWindow.document.all.LocalName.value == "")
		return CloseWin();
	RefreshMsg("正在发送文件...,请等待");
	document.all.FormDataFrame.contentWindow.document.all.form1.action = "../flow/inflow.jsp";
	document.all.FormDataFrame.contentWindow.document.all.form1.target = "_parent";
	document.all.FormDataFrame.contentWindow.SubmitForm();
}
</SCRIPT>
</BODY></HTML>
