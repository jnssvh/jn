<%@ page language="java" contentType="text/html; charset=GBK" import="com.jaguar.*" pageEncoding="GBK"%>
<%!
public static String scriptName(String url)
    {
        String scrname = url.substring(url.lastIndexOf("/") + 1);
        return scrname;
    }
 %>
<%
int FormType = 1;
 String  DataID = WebChar.requestStr(request , "DataID");
 %>
<%@ include file="../init_comm.jsp" %>
    <%
    	request.setCharacterEncoding("GBK"); 
    	String direct = request.getParameter("direct");
    	String loadtype = WebChar.requestStr(request, "loadtype");
    	String formname = WebChar.requestStr(request, "formname");
    	String rtnValue = WebChar.requestStr(request, "rtnValue");
    	String script = WebChar.requestStr(request, "script");
    	String rename = WebChar.requestStr(request, "rename");
    	String referrer = scriptName(WebChar.isString(request.getHeader("Referer")));
    	String saveto = WebChar.requestStr(request, "saveto");
    	String filepath = WebChar.requestStr(request, "filepath");
    	String instanceName = WebChar.requestStr(request, "instanceName");
    	String isMore = WebChar.requestStr(request, "isMore");
    	
    	if(saveto.length() == 0)
    	{
    		saveto = WebChar.requestStr(request, "ParentName");
    	}
    	if (saveto.length() == 0 && filepath.equals(""))
    	{
    		filepath = "upload";
    	}
    	String log_desc = WebChar.requestStr(request, "log_desc");
    	String plusStr = WebChar.requestStr(request, "plusStr");
    	String forward = WebChar.requestStr(request, "forward");
    	
    	// 解决跨脚本攻击XSS问题 lxt 2017.7.7
    	loadtype=loadtype.replaceAll("\\<[^\\<\\>]+\\>","").replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		formname=formname.replaceAll("\\<[^\\<\\>]+\\>","").replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		saveto=saveto.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		if(direct!=null)
		direct=direct.replaceAll("\"", "").replaceAll(">","").replaceAll("<","");
		rtnValue=rtnValue.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		script=script.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		rename=rename.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		referrer=referrer.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		filepath=filepath.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		instanceName=instanceName.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		isMore=isMore.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		plusStr=plusStr.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		forward=forward.replaceAll("\"","").replaceAll(">","").replaceAll("<","");
		

    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=GBK">
<!-- 选择要上传的文件 -->
<title>选择要上传的文件</title>
<script language="javascript">
function xianshi()
{
	var form = "<%=formname%>";
	var filetype = "", filetype0 = "<%=loadtype%>";
	var filename = document.getElementsByName("LocalName")[0].value;
	if (filename == "")
	{
		alert("请选择文件。");
		return false;
	}
	var r = /.*\\(.*)/;
	var f = r.exec(filename);
	if(f) fname = f[1];
	else fname=r; // firefox没能读取到路路径，只filename \\xx\\xx.xx lxt 2014.09.17
	var re = null;
	
	filetype = filename.substr(filename.lastIndexOf(".") + 1);
	var filetype1 = filetype0.replace(/,/g, "|");
	//alert(filetype1);
	var re = new RegExp("^(" + filetype1 + ")$", "ig");
	if (filetype1 != undefined && filetype1 != "" && !re.test(filetype))
	{
		alert("选择的文件【" + filetype + "】不符合条件，请重新选择后缀是【" + filetype0 + "】的文件。");
		return false;
	}
	document.getElementsByName("form1")[0].submit();
<%--
	/*=====显示等处理遮罩 lxt 2013.04.15========*/
	var divPanel=top.document.createElement("div");
	divPanel.id="divForUploadFileWaitingPanel";
	var wx=top.document.body.scrollWidth,hx=top.document.body.scrollHeight;
	with(divPanel.style){
		position="absolute";
		left="0px";
		top="0px";
		width="100%";//wx+"px";
		height="100%";//hx+"px";
		backgroundColor="black";
		filter="Alpha(Opacity=30)";
		opacity=0.3;
		textAlign="center";
	}
	divPanel.innerHTML="<div style='background-color:white;padding:10px;"+
	"width:300px;font-size:32px;margin:0 auto;margin-top:25%;'><span style='vertical-align:middle;'>"+
	"<img src='<%=request.getContextPath()%>/images/upload_wait.gif'/></span>正在上传..."+
	"<span id='spanForUploadFileWaitingPanel'></span></div>";
	top.document.body.appendChild(divPanel);
	/*==================*/
--%>
	
	return true;
}

function init()
{
	//alert(unescape("<%=script%>"));
	//alert(document.body.innerHTML);
}

function SubmitForm()
{
	xianshi();
}
</script>
</head>
<body onload="init();">
<form action="upload.jsp" enctype="multipart/form-data" method="post" name="form1">
<input type="hidden" name="saveto" value="<%=saveto %>">
<input type="hidden" name="formname" value="<%=formname%>">
<input type="hidden" name="direct" value="<%=direct %>">
<input type="hidden" name="loadtype" value="<%=loadtype %>">
<input type="hidden" name="rtnValue" value="<%=rtnValue %>">
<input type="hidden" name="script" value="<%=script %>">
<input type="hidden" name="log_desc" value="<%=log_desc %>">
<input type="hidden" name="rename" value="<%=rename %>">
<input type="hidden" name="referrer" value="<%=referrer %>">
<input type="hidden" name="filepath" value="<%=filepath %>">
<input type="hidden" name="plusStr" value="<%=plusStr %>">
<input type="hidden" name="instanceName" value="<%=instanceName %>">
<input type="hidden" name="isMore" value="<%=isMore %>">
<input type="hidden" name="forward" value="<%=forward %>">
<table>
<tr>
<td>本地上传：</td>
<td>
<input type="file" name="LocalName">
</td>
</tr>
<tr>
<td>
<input type="button" value="提交" onclick="xianshi();">
</td>
<td>
<input type="reset" value="重置">
</td>
</tr>
</table>
</form>
</body>
</html>
<% jdb.closeDBCon();%>