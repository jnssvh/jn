<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,com.jaguar.*,project.*"%>
<%@ include file="init.jsp" %>
<%!
//通用表格数据导出程序(HTML...)
%>
<%
//通用表格数据导出程序(HTML...)
	user = new SysUser();
	user.initWebUser(jdb, request.getCookies());
	
	StringBuffer buffer = new StringBuffer();
	String FileName = WebChar.requestStr(request, "FileName");
	String head = WebChar.RequestForms(request, "head", 0);
	if ((head != null) && !head.equals(""))
	{
		buffer.append(head);		
	}
	else
	{
		buffer.append("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n>" +
			"<html><head><meta http-equiv='Content-Type' content='text/html; charset=gb2312'>\n" +
			"<meta http-equiv='MSThemeCompatible' content='Yes'>\n<title>" + FileName + "</title>\n");
		String css = WebChar.RequestForms(request, "css", 0);
		if ((css != null) && !css.equals(""))
			buffer.append("<style type=\"text/css\">\n" + css + "\n</style>\n");
		buffer.append("</head>\n");
	}
	buffer.append("<body>\n");
	String body = WebChar.RequestForms(request, "body", 0);
	if ((body != null) && !body.equals(""))
		buffer.append(body.replace("&#39;", "'"));
	else
	{
		int hCount = WebChar.RequestInt(request, "hCount");
		int nHead = (WebChar.RequestInt(request, "headstyle") == 3) ? 0 : 1;
		int [] width = new int [hCount];
		buffer.append("<table cellpadding=0 cellspacing=0 border=1 style=border-collapse:collapse;border:none;table-layout:fixed;>\n");
		String tr = "<tr>";
		for (int x = 0; x < hCount; x++)
		{
			String hv = WebChar.RequestForms(request, "hv", x);
			String hp = WebChar.RequestForms(request, "hp", x);
			width[x] = WebChar.ToInt(hp);
			tr += "<td width=" + width[x] + ">" + hv + "</td>";
		}
		if (nHead == 1)
			buffer.append(tr + "</tr>\n");
		
		int vCount = WebChar.RequestInt(request, "vCount");
		int [] height = new int [vCount];
	
		for (int x = 0; x < vCount; x++)
		{
			String vp = WebChar.RequestForms(request, "vp", x);
			height[x] = WebChar.ToInt(vp);
		}
		int Count = WebChar.RequestInt(request, "Count");
		int br = 1;
		for (int z = 0; z < Count; z++)
		{
			String v = WebChar.RequestForms(request, "v" + z, 0);
			String p = WebChar.RequestForms(request, "p" + z, 0);
			String [] ss = p.split(",");
			if (ss.length < 4)
				continue;

			int x = WebChar.ToInt(ss[0]);
			int y = WebChar.ToInt(ss[1]) + nHead;
			int colspan = WebChar.ToInt(ss[2]);
			int rowspan = WebChar.ToInt(ss[3]);
			String span = "";
			int w = width[x];
			if (colspan > 1)
			{
				span = " colspan=" + colspan;
				for (int zz = x + 1; zz < x + colspan; zz++)
				{	if (zz < width.length)
						w += width[zz];
				}
			}
			if (rowspan > 1)
				span = " rowspan=" + rowspan;
			String prop = "", style = "";
			if (ss.length >= 5)
			{
				prop = " " + ss[4];
				style = " style=\"" + ss[5] + "\"";
			}
			if (br == 1)
				buffer.append("<tr>");
			br = 0;
			buffer.append("<td width=" + w + " height=" + height[y] + span + prop + style + ">" + v + "</td>");
			if (x + colspan >= hCount)
			{
				buffer.append("</tr>\n");
				br = 1;
			}
		}
		buffer.append("</table>\n");
	}
	buffer.append("</body>\n</html>\n");

	int OutToServer = WebChar.RequestInt(request, "OutToServer");
	if (OutToServer == 1)
	{
   		String fname = AffixManager.getRootDir(jdb) + System.currentTimeMillis()  + "OUT.htm";
		FileWriter f = new FileWriter(fname);
		f.write("" + buffer);
		f.close();
		String time = VB.Now();
		String url = fname.replaceAll("\\\\", "\\\\\\\\");
		String sql = "INSERT INTO AffixFile(FileCName,LocalName,ParentID,FileURL,FileSize,SubmitMan,SubmitTime) VALUES('" + 
			FileName + "','" + FileName + "',0,'" + url + "'," + buffer.length() + ",'" + user.CMemberName + "','" + time +"')";
		WebChar.logger.info("HTML文件信息写库： " + sql);
		jdb.ExecuteSQL(0, sql);
		String Affix = jdb.getSQLValue(0, "SELECT id FROM AffixFile WHERE FileURL='" + url + "' AND SubmitTime='" + time + "'");
		
		out.println("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">");
		out.println("<html><head>");
		out.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">");
		out.println("<title>导出HTML文件到服务器</title></head>");
		out.println("<body>");
		out.println("<script language=\"javascript\">");
		out.println("window.onload = function ()");
		out.println("{");
		out.println("	if (typeof parent.OutHtmltoServerOK == \"function\")");
		out.println("		return parent.OutHtmltoServerOK(" + Affix + ")");
		out.println("	alert(导出HTML文件到服务器成功。ID=" + Affix + ")");
		out.println("}");
		out.println("</script>");
		out.println("</body>");
		out.println("</html>");

	}
	else
	{
		response.setContentType("application/octet-stream");
		String filename = new String(FileName.getBytes(), "ISO8859-1");
		response.setHeader("content-disposition", "attachment; filename=\"" + filename + "\"");
		out.print(buffer);
	}
	response.flushBuffer();
	jdb.closeDBCon();
%>
