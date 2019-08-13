<%@page import="project.*"%>
<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger,java.io.*,java.util.*,org.apache.commons.fileupload.*,com.jaguar.*,org.apache.commons.fileupload.disk.*,org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.fileupload.util.Streams" %>
<%!
static int uploadCount = 0;

%>
<%
	request.setCharacterEncoding("GBK");
%>
<%@ include file="/init_comm.jsp" %>
<%
	String rootDir = AffixManager.getRootDir(jdb);
	{
		String item = jdb.GetTableValue("SysConfig", "ParamValue", "ename", "'" + "FormUploadPath'");
		if ((item == null) || item.equals(""))
			rootDir += "Form" + File.separator;
		else
			rootDir = item;
		File folder = new File(rootDir);
		if (!folder.exists())
			folder.mkdirs();
		//if (!folder.exists())
		//	rootDir = AffixManager.getConfigRootDir();
		if ( !rootDir.matches(".*(?:\\|/)$") )
				rootDir += File.separator;
	}
WebChar.logger.info("Upload Begin：" + request.getRemoteAddr() + ":" + request.getRemotePort());

String option = WebChar.requestStr(request , "option");
if (option.equals("DeleteFile"))
{
	File delFile = null;
	String sql = "";
	String fileName0 = WebChar.requestStr(request , "fileName0");
	if (fileName0.matches("\\d+"))
	{
		sql = "SELECT FileURL FROM AffixFile WHERE ID=" + fileName0;
		String url = jdb.getValueBySql(0, sql);
		sql = "DELETE FROM AffixFile WHERE ID=" + fileName0;
		jdb.ExecuteSQL(0, sql);
		fileName0 = url;
	}
	else
		fileName0 = getServletContext().getRealPath(fileName0);
	delFile = new File(fileName0);
	if (delFile.exists() && delFile.delete())
		out.print("ok");
	SystemLog.setLog(jdb, user, request, "0", "删除文件[" + fileName0 + "]", "AffixFile", "" + fileName0);
	jdb.closeDBCon();
	return;
}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=GBK">
<link rel='stylesheet' type='text/css' href='forum.css'>
<title>上传文件</title></head>
<body>
<%
boolean bool = false;
String name = ""; 
long size = 0;
String path = getServletConfig().getServletContext().getRealPath("/");

//服务器端生成的变量
String filename0 = "";		//原文件名
String filename = "";		//上传后的文件名
String fpath = "";			//上传后的路径
String fname = "";			//上传后的路径


//表单域传入的参数
/*
上传路径，为相对于WebRoot的站内路径
上传至网站内目录为必填,否则上传至项目根目录
*/
String filepath = "";
/*
附件表中的文件夹名称
上传至网站外upload目录为必填
*/
String saveto = "";

/*
可选参数
*/
String loadtype = "";		//上传文件类型，为空则不过滤
String formname = "";		//表单名称，上传完毕后，把文件名填入
String direct = "";			//上传后 redirect到 url，url附加参数：filepath，tempname，saveto
String rtnValue = "";		//弹出窗口的返回值 returnValue，已不使用
String script = "";			//上传后执行的脚本
String log_desc = "";		//写入日志的描述，可能已不使用
String rename = "";			//上传后改变文件名，目前支持 ms  以系统的毫秒值为文件名;或者不为空时做指定文件名;为空保存使用原名称
String referrer = "";		//上传文件调用来源，swfupload 表示只返回附件编号
String plusStr = "";		//写数据库时的附加数据。格式：    字段=值，会把字段附加到field,值附加到value
String instanceName = "";	//AutoSelectFile 类的实例名称，为空使用默认名称
String isMore = "";			//是否是多附件上传，如果是单附件(值为空)，更改后会把原附件删除;如果是多附件，需要设置为  true
String forward = "";		//上传后跳转页面
String Filename = "";   //swfupload提交时的字段,防止中英文混合文件名出现乱码
String clientType = "";			//客户端类型，为空表示电脑客户端，android,iphone

String queryString = request.getQueryString();
if (!VB.isEmpty(queryString))
{
	direct = WebChar.getValueByRegExp(".*direct=([^&]*).*", queryString);
	formname = WebChar.getValueByRegExp(".*formname=([^&]*).*", queryString);
	loadtype = WebChar.getValueByRegExp(".*loadtype=([^&]*).*", queryString);
	rtnValue = WebChar.getValueByRegExp(".*rtnValue=([^&]*).*", queryString);
	script = WebChar.getValueByRegExp(".*script=([^&]*).*", queryString);
	log_desc = WebChar.getValueByRegExp(".*log_desc=([^&]*).*", queryString);
	rename = WebChar.getValueByRegExp(".*rename=([^&]*).*", queryString);
	referrer = WebChar.getValueByRegExp(".*referrer=([^&]*).*", queryString);
	saveto = WebChar.getValueByRegExp(".*saveto=([^&]*).*", queryString);
	saveto = WebChar.unescape(WebChar.unescape(saveto));
	instanceName = WebChar.getValueByRegExp(".*instanceName=([^&]*).*", queryString);
	filepath = WebChar.getValueByRegExp(".*filepath=([^&]*).*", queryString);
	plusStr = WebChar.getValueByRegExp(".*plusStr=([^&]*).*", queryString);
	forward = WebChar.getValueByRegExp(".*forward=([^&]*).*", queryString);
	forward = WebChar.unescape(WebChar.unescape(forward));
	Filename = WebChar.getValueByRegExp(".*Filename=([^&]*).*", queryString);
	if (Filename.indexOf("%") >= 0) {
		Filename = WebChar.unescape(WebChar.unescape(Filename));
	}
	clientType = WebChar.getValueByRegExp(".*clientType=([^&]*).*", queryString);
}
	String tempFilePath = System.getProperty("java.io.tmpdir");
	// 创建一个基于硬盘的FileItem工厂
	DiskFileItemFactory factory = new DiskFileItemFactory();
	// 设置向硬盘写数据时所用的缓冲区的大小，此处为4K
	factory.setSizeThreshold(4 * 1024);
	// 设置临时目录
	factory.setRepository(new File(tempFilePath));
	ServletFileUpload fu = new ServletFileUpload(factory);
	final long mk = 1024 *1024;
	ProgressListener progressListener = new ProgressListener() {
		private long uploadSize = 0, sizeM = 0, sizeK = 0, sizeM0 = 0, sizeK0 = 0, uploadSize0 = 0;
		private double rate = 0.0;
		private long time0 = System.currentTimeMillis();
		public void update(long pBytesRead, long pContentLength, int pItems) {
			if (pContentLength == 0) {
				return;
			}
			sizeM = pBytesRead / mk;
			if (pContentLength > 200 * mk) {
				sizeM = sizeM / 50;
			} else if (pContentLength > 100 * mk) {
				sizeM = sizeM / 10;
			} else if (pContentLength > 50 * mk) {
				sizeM = sizeM / 5;
			} else if (pContentLength > 30 * mk) {
				sizeM = sizeM / 3;
			} else if (pContentLength > 20 * mk) {
				sizeM = sizeM / 2;
			}
			long time2 = System.currentTimeMillis();
			if (sizeM != sizeM0) {
				if (time2 - time0 > 0) {
					rate = ((pBytesRead - uploadSize0) / 1024.0) / ((time2 - time0) / 1000.0);
				}
				WebChar.logger.info(VB.Now() + " 上传" + pBytesRead + " 字节，总大小为 "
					+ pContentLength + "，网速：" + rate + "KB");
				time0 = time2;
				uploadSize0 = pBytesRead;
				sizeM0 = sizeM;
			}
		}
	};
	fu.setProgressListener(progressListener);
	int requestSize = request.getContentLength();
    if (requestSize == -1)
    {
        WebChar.logger.info(VB.Now() + "上传大小未知。");
    }
    
	//WebChar.logger.info(VB.Now() + "while循环之前,getItemIterator之前");
	FileItemIterator iter = fu.getItemIterator(request);
	WebChar.logger.info(VB.Now() + "while循环之前");
try {
	while (iter.hasNext()) 
	{
		FileItemStream item = (FileItemStream) iter.next();        //忽略其他不是文件域的所有表单信息
		InputStream stream = item.openStream();
		if(item.isFormField())
		{
			String formName = item.getFieldName();
			String formValue = VB.CStr(Streams.asString(stream,request.getCharacterEncoding()), "");
			if (formName.equals("direct"))
				direct = formValue;
			else if (formName.equals("formname"))
				formname = formValue;
			else if (formName.equals("loadtype"))
				loadtype = formValue;
			else if (formName.equals("rtnValue"))
				rtnValue = formValue;
			else if (formName.equals("script"))
				script = formValue;
			else if (formName.equals("log_desc"))
				log_desc = formValue;
			else if (formName.equals("rename"))
				rename = formValue;
			else if (formName.equals("referrer"))
				referrer = formValue;
			else if (formName.equals("saveto"))
				saveto = formValue;
			else if (formName.equals("instanceName"))
				instanceName = formValue;
			else if (formName.equals("isMore"))
				isMore = formValue;
			else if (formName.equals("filepath"))
				fpath = formValue;
			else if (formName.equals("plusStr"))
				plusStr = formValue;
			else if (formName.equals("forward"))
				forward = formValue;
			else if (formName.equals("Filename")) {
				Filename = WebChar.isString(new String(formValue.getBytes(), "utf-8"));
			}
			else if (formName.equals("clientType"))
				clientType = formValue;
		}
		if(!item.isFormField())
		{
			if (saveto.length() > 0 || fpath.matches("file:.*"))
			{
				filepath = rootDir + fpath.replaceAll("file:", "");
			}
			else
			{
				if (fpath.equals(""))
					fpath = "upload";
				if (!fpath.equals("root")) {
					fpath += File.separator;
				}
				if (fpath.substring(0, 1).equals("/")) {
					filepath = fpath;
				} else {
					if (!fpath.equals("root"))
						filepath = path + fpath;
					else
						filepath = path;
					File pathFile = new File(filepath);
					if (!pathFile.exists()) {
						pathFile.mkdirs();
					}
				}
			}
	    	name = item.getName();
	    	if (referrer.equals("swfupload") || clientType.equals("android")) {
	    		name = Filename;
	    	}
	    	//size = item.getSize();
	   		//if(VB.isEmpty(name) && size == 0)
	         //   continue;
	    	// 注意item.getName()    会返回上载文件在客户端的完整路径名称，这似乎是一个BUG。
	    	// 为解决这个问题，这里使用了writeFile.getName()。
	    	if(stream.available() == 0){//如果文件域没有选择文件，则忽略处理
	    		continue;
	    	}
	    	name = name.replace('\\','/');
	    	if (name.matches(".*\\.(jsp|jspx|class|jar)$")) {
	    		SystemLog.setLog(jdb, user, request, "0", "上传非法文件[" + name + "]被禁止", "AffixFile", "");
	    		jdb.closeDBCon();
	    		return;
	    	}
	    	File writeFile = new File(name);
	    	filename = writeFile.getName();
	    	String fileType = "";//filename.replaceAll(".*\\.(\\w+)", "$1");
	    	fileType = WebChar.getValueByRegExp(".*\\.(\\w+)", filename);
    	
			if (loadtype.length() > 0 && !filename.matches("(?i).*\\.(?:" + loadtype.replaceAll(",", "|") + ")"))
	   			bool = true;
	    	else
	    	{
   				bool = false;
   				filename0 = writeFile.getName();
   				if (saveto.length() > 0 && VB.isString(rename).length() == 0)		//存储到网站外面
   				{
	   				rename = "ms";
	   			}
	   			if (VB.isEmpty(rename))
	   			{
	   				fname = writeFile.getName();
	   			}
	   			else
	   			{
   					if (rename.equals("ms"))
   					{
	   					fname = System.currentTimeMillis() + WebChar.LStrFill( ++uploadCount, 4, "0" ) + "." + fileType;
	   				}
	   				else if (VB.isString(rename).length() > 0)
	   				{
	   					fname = rename;
	   				}
	   				filename = fname;
	   			}
	   			File savedFile = new File(filepath, fname);
	   			//item.write(savedFile);
	   			Streams.copy(stream, new FileOutputStream(savedFile), true);
	   			if (saveto.length() > 0)
	   			{
	   				String sql = "";
	   				if (saveto.matches("(?i)id:.*")) {
	   					saveto = saveto.replaceAll("(?i)id:", "");
	   				} else {
	   					saveto = WebChar.unescape(WebChar.unescape(saveto));
		   				sql = "SELECT ID FROM AffixFile WHERE FileCName='" + saveto + "'";
		   				saveto = jdb.getSQLValue(0, sql);
	   				}
	   				if (saveto == null || saveto.equals(""))
	   				{
						saveto = "0";
	   				}
	   				String time = VB.Now();
	   				String fields = "FileCName,LocalName,ParentID,FileURL,FileSize,SubmitMan,SubmitTime";
	   				String values = WebChar.getStr(filename0) + "," + WebChar.getStr(writeFile.getPath()) 
	   					+ "," + saveto + "," + WebChar.getStr(savedFile.getPath()) 
	   					+ "," + savedFile.length() + "," + WebChar.getStr(jdb.getSQLValue(0
	   					, "SELECT CName FROM Member WHERE EName='" + WebChar.getCookie(request, "loginname") + "'"))
	   					+ "," + WebChar.getStr(time);
	   				if (plusStr.length() > 0 && plusStr.indexOf("<") < 0)
	   				{
	   					String[] plus = plusStr.split("=");
	   					fields += "," + plus[0];
	   					values += "," + plus[1];
	   				}
	   				sql = "INSERT INTO AffixFile(" + fields + ") VALUES(" + values + ")";
	   				sql = sql.replaceAll("\\\\", "\\\\\\\\");
	   				WebChar.logger.info("文件信息写库： " + sql);
	   				saveto = jdb.getGeneratedKey(0, sql);
	   				//jdb.ExecuteSQL(0, sql);
	   				//saveto = jdb.getSQLValue(0, "SELECT id FROM AffixFile WHERE FileURL LIKE '%" + fname + "' AND SubmitTime='" + time + "'");
	   				WebChar.logger.info("上传文件编号： " + saveto);
	   			}
	   			if(!VB.isEmpty(direct) && !direct.equals("null"))
	   			{
	   				if (direct.indexOf("%") >= 0) {
	   					direct = WebChar.unescape(WebChar.unescape(direct));
	   				}
	   				direct += direct.matches(".*\\?.+")?"&":"?";
	   				filename = java.net.URLEncoder.encode(filename, "gbk");
	   				response.sendRedirect(direct + (direct.indexOf("?")>=0?"&":"?") + "filepath=" 
	   					+ filepath.replaceAll("\\\\", "\\\\\\\\") + "&tempname=" + filename 
	   					+ "&saveto=" + saveto);
	   				jdb.closeDBCon();
	   				return;
	   			}
	   			else
	   				break;
   			}
    	}
  	}
} catch (Exception e) {
	WebChar.printError(e, WebChar.logger, request.getRemoteAddr() + ":" + request.getRemotePort());
}
	WebChar.logger.info(VB.Now() + "while循环结束");
  	if (referrer.equalsIgnoreCase("swfupload")) {
  		out.clear();
  		out.print(saveto);
  		out.flush();
  		return;
  	}
  	if (!VB.isEmpty(forward))
  	{
		jdb.closeDBCon();
  		forward = WebChar.setProp(forward, "plusStr", plusStr);
  		forward = WebChar.setProp(forward, "filepath", filepath);
  		forward = WebChar.setProp(forward, "filename", filename);
  		forward = WebChar.setProp(forward, "filename0", filename0);
  		forward = WebChar.setProp(forward, "saveto", saveto);
  		forward = WebChar.setProp(forward, "fullname", fpath + (fpath.matches(".*[\\/\\\\]")?"":"/") + filename);
		//String scr = "<script type=\"text/javascript\">top.alert(\"" + forward + "\");window.location=\"" + forward + "\";</script>";
		//HttpAccess.getGetResponseWithHttpClient(forward, "GBK");
		//System.out.println(forward);
		ServletContext sc = getServletContext();
		//request.setAttribute("pagename", WebChar.scriptName(request));
		RequestDispatcher rd = sc.getRequestDispatcher(forward);
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		return;
  	}
	if(bool)
	{
		out.println("<script>window.alert('导入的文件格式不正确！');</script>");
	}
	else
	{
		fpath = fpath.replace('\\', '/');
%>
<script language="javascript">
function xianshi()
{
	var saveto = "<%=saveto%>";
	var fname = "<%=fname%>";
	var form = "<%=formname%>";
	var rtnValue = "<%=rtnValue%>";
	var filename0 ="<%=filename0%>";
	var filename1 ="<%=filename0.replaceAll("(.+?)\\..+", "$1")%>";
		
	var filesize = "<%=size%>";
	var parentObj;
	if (rtnValue != "")
	{
		returnValue = "<%=fpath%>" + filename;
		window.close();
		return;
	}

	var filename = "<%=filename%>";
	var fullname = "<%=fpath + (fpath.matches(".*[\\/]")?"":"/") + filename%>";
	if (typeof window.parent.SubmitOK == "function")
	{
		return window.parent.SubmitOK("<%=fpath%>" + filename);
	}
	if (typeof(window.opener) != "undefined"&&window.opener)
	{
		parentObj = window.opener;
	}
	else
	{
		parentObj = parent.window;
	}
	<%if (!VB.isEmpty(instanceName)){%>
		if(parentObj.<%=instanceName%>)parentObj.<%=instanceName%>.fileName0 = (saveto==""?fullname:saveto);
		<%}%>
		if ("<%=script%>" != "")
		{
			<%=WebChar.unescape(script)%>;
		}
		if (saveto == "" && form != "")
		{
			parentObj.document.getElementsByName(form)[0].value = "<%=(fpath 
				+ (fpath.matches("")?"":(!fpath.matches(".+(?:\\|/)$")?"/":""))).replaceAll("\\/\\/", "/")%>" + filename;
		}
		else if (saveto != "" && typeof parentObj.SubmitLocalFileOK == "function")
		{
			parentObj.SubmitLocalFileOK("1", saveto, filename0);
		}
		//window.close();
}

/*=====删除等待指示面板 lxt 2013.4.15====*/
try{
top.document.body.removeChild(top.document.getElementById("divForUploadFileWaitingPanel"));
}catch(ex){}
/*========*/

xianshi();
</script>

<%
	//out.println("window.alert('文件已上传。');");
	}
 %>
</body>
</html>
 <%
jdb.closeDBCon();
%>