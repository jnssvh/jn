<%@ page language="java" import="java.sql.* ,com.jaguar.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ include file="init_public.jsp" %>
<%
String url = WebChar.requestStr(request, "url");
String[] urls = url.split(";");
String xml = WebChar.requestStr(request, "xml");
String ratio = WebChar.requestStr(request, "ratio");
String size = WebChar.requestStr(request, "size");

 %>
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Ò³ÃæÈÝÆ÷</TITLE>
<META NAME="Generator" CONTENT="EditPlus">
<META NAME="Author" CONTENT="">
<META NAME="Keywords" CONTENT="">
<META NAME="Description" CONTENT="">
<style type="text/css">
*{margin:0; padding:0;}
html,body{width:100%;height:100%;}
</style>
<link rel='stylesheet' type='text/css' href='forum.css'>
<script language=javascript src=com/psub.jsp></script>
<script type="text/javascript" src="js/jaguar.js"></script>
<SCRIPT LANGUAGE="JavaScript">
function setTitle(obj)
{
	obj.previousSibling.innerHTML = obj.contentWindow.document.title;
	var size = "<%=size%>";
	if (size == "absolute") {
		//setTimeout("timeoutResizeForSize('" + obj.id + "')", 100);
	}
}

function timeoutResizeForSize(ifrid) {
	if (!isEnd) {
		setTimeout("timeoutResizeForSize('" + ifrid + "')", 100);
		return;
	}
	var obj = document.getElementById(ifrid);
	obj.style.height = obj.contentWindow.document.body.scrollHeight;
	alert("h="+obj.style.height);
}

function timeoutResize()
{
	var ifrcount = <%=urls.length%>;
	var xml = "<%=xml%>";
	var ratio = "<%=ratio%>";
	var rs = ratio.split(/:/);
	var size = "<%=size%>";
	if (rs.length > 1) {
		var sumH = 0;
		for (var i = 0; i < rs.length; i++) {
			rs[i] = WebFunc.CDbl(rs[i]);
			sumH += rs[i];
		}
		if (sumH > 0 && sumH != 1) {
			for (var i = 0; i < rs.length; i++) {
				rs[i] = rs[i] / sumH;
			}
		}
	}
	if (ifrcount > 1)
	{
		var h = document.body.offsetHeight - document.getElementById("div1").offsetHeight * ifrcount;
		var avgH = 0;
		if (size == "absolute") {
			avgH = h;
		} else {
			avgH = h / ifrcount;
		}
		var ifrs = document.getElementsByTagName("iframe");
		for (var i = 0; i < ifrs.length; i++)
		{
			if (rs.length == 1 || ifrcount != rs.length) {
				if (size == "absolute") {
					var hh = ifrs[i].contentWindow.document.body.scrollHeight + 20;
					ifrs[i].style.height = hh + "px";
				} else {
					ifrs[i].style.height = avgH;
				}
			} else {
				ifrs[i].style.height = h * rs[i] + "px";
			}
		}
		ifrs = null;
	}
	handle = "";
	isEnd = true;
}

var resizeHandle = "";
function rsz() {
	if (handle != "") {
		clearTimeout(handle);
		handle = "";
	}
	var ifrcount = <%=urls.length%>;
	if (ifrcount > 1)
	{
		var ifrs = document.getElementsByTagName("iframe");
		for (var i = 0; i < ifrs.length; i++)
		{
			if (ifrs[i].contentWindow.document.readyState != "complete") {
				handle = setTimeout("rsz()", 100);
				return;
			}
		}
	}
	timeoutResize();
	//handle = setTimeout("timeoutResize()", 0);
}

var handle = "";
var isEnd = false;
window.onresize = rsz;
window.onload = function (){
//document.body.innerHTML = "";
	
};
</script>
</HEAD>

<BODY topmargin="0" leftmargin="0" scroll="<%=size.equals("absolute")?"yes":"no" %>">
<%
String qs = request.getQueryString();
if (urls.length == 1) {%>
<iframe id="list" name="list" style="width:100%;height:100%;border:none;" 
frameborder="0" src="<%
url = sysApp.setProp(url, "xml", xml);
out.print(url);
%>"></iframe>
<%
}
else
{
	for (int x = 0; x < urls.length; x++)
	{
		
		if (VB.isEmpty(urls[x])) continue;
		String[] iframeUrl = urls[x].split(":");
		urls[x] = iframeUrl[0];
		if (xml.length() > 0)
		{
			urls[x] = sysApp.setProp(urls[x], "xml", xml);
		}
		if (urls[x].indexOf("?") < 0) {
			urls[x] += "?";
		} else {
			urls[x] += "&";
		}
		urls[x] += qs;
 %>
<div id="div<%=x %>" style="padding-left:15px;">&nbsp;</div><iframe id="list<%=x %>" name="list<%=x %>" style="width:100%;height:200px;border:none;" 
			frameborder="0" src="<%=urls[x] %>" <%=(iframeUrl.length==2&&iframeUrl[1].equals("noonload"))?"":"onload=\"setTitle(this)\"" %>></iframe>
<%
	}
}
%>
<script type="text/javascript">
rsz();
</script>
</body>
</html>
<% jdb.closeDBCon();%>

