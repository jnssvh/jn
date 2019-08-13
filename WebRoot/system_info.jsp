<%@ page language="java" import="java.sql.* ,com.jaguar.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<system name="EUT">
	<update type="javascript">
	var v = 0;
	if (NetBox.FileSystem.FileExists("ver.dat")) {
		var vStr = getFileContentFromServer("ver.dat");
		vStr = vStr.replace(/htex_ver=/, '');
		vStr = vStr.replace(/\\s[\\s\\S]*$/, '');
		v = parseFloat(vStr);
	} else {
		var file = new ActiveXObject("NetBox.File");
		file.Open("ver.dat", 16 + 2);
		file.WriteLine("htex_ver=" + eutVers[1].ver);
		file.setEOS();
		file.Close();
		v = eutVers[1].ver;
	}
	window.vers = [
	{fileName:"EUT.exe",ver:2.6}
	, {fileName:"htex.ocx", ver:2.0, server_ver:2.1}
	];
	if (v < vers[1].server_ver) {
		downloadFile("/htex.ocx", "htex.ocx");
		var file = new ActiveXObject("NetBox.File");
		file.Open("ver.dat", 16 + 2);
		file.WriteLine("htex_ver=" + vers[1].server_ver);
		file.setEOS();
		file.Close();
	}
	window.vers;
	</update>
</system>