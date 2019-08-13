<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.io.*,java.util.*,java.awt.image.BufferedImage,javax.imageio.ImageIO,org.apache.commons.fileupload.*,com.jaguar.*,project.*,jxl.*, jxl.write.*"%>
<%@ include file="init.jsp" %>
<%!
//通用数据导出程序(Excel...)
private WritableCellFormat SetCellAttrib(String value, String prop, String style, String tdstyle) throws WriteException
{
	jxl.write.Border wBorder = null;
	String [] ss = style.split(";");
	WritableCellFormat cf;
	if (value.length() < 20)
		cf = new WritableCellFormat(NumberFormats.TEXT);
	else
		cf = new WritableCellFormat();
	for (int x = 0; x < ss.length; x++)
	{
		String [] sss = ss[x].split(":");
		if (sss[0].equals("font"))
		{
			jxl.write.WritableFont wfont = null;
			String [] ssss = sss[1].split(" ");
			int pt = WebChar.ToInt(ssss[3].substring(0, ssss[3].length() - 2));
   			wfont = new jxl.write.WritableFont(WritableFont.createFont(ssss[4]), pt);   			
			wfont.setItalic(ssss[0].equals("italic"));
			if (WebChar.ToInt(ssss[2]) >= 600)
				wfont.setBoldStyle(WritableFont.BOLD);
			cf.setFont(wfont);
		}
//		else if (sss[0].equals("background-color"))
//			cf.setBackground();
			
	}
	
	ss = prop.split(" ");
	for (int x = 0; x < ss.length; x++)
	{
		String [] sss = ss[x].split("=");
		if (sss[0].equals("align"))
		{
			if (sss[1].equals("left"))
				cf.setAlignment(Alignment.LEFT);
			else if (sss[1].equals("right"))
				cf.setAlignment(Alignment.RIGHT);
			else if (sss[1].equals("center"))
				cf.setAlignment(Alignment.CENTRE);
			else if (sss[1].equals("justify"))
				cf.setAlignment(Alignment.JUSTIFY);
		}
		
	}
	ss = tdstyle.split(";");
	for (int x = 0; x < ss.length; x++)
	{
		String [] sss = ss[x].split(":");
		if (sss[0].equals("border"))
		{
			if (!sss[1].equals("none"))
				cf.setBorder(Border.ALL, BorderLineStyle.THIN);
		}
		else
			cf.setBorder(Border.ALL, BorderLineStyle.THIN);
	}
	cf.setVerticalAlignment(VerticalAlignment.CENTRE);
	return cf;
}

private void addPictureToExcel(WritableSheet sheet, File file, int nRow, int nCol, int colspan, int rowspan) throws Exception
{
	BufferedImage pic = ImageIO.read(file);
	ByteArrayOutputStream png = new ByteArrayOutputStream();
	ImageIO.write(pic, "png", png);

	WritableImage image = new WritableImage(nCol, nRow, colspan, rowspan, png.toByteArray());
	sheet.addImage(image);
}


private boolean WriteExcelFromTmpl(WritableSheet sheet,  HttpServletRequest request) throws WriteException
{
	Enumeration enu = request.getParameterNames();  

	while(enu.hasMoreElements())
	{  
		String name = (String) enu.nextElement();
		String value = WebChar.RequestForms(request, name, 0);
		Cell cell = sheet.findCell("(" + name + ")");
		if (cell != null)
		{
			sheet.addCell(new Label(cell.getColumn(), cell.getRow(), value, cell.getCellFormat()));
		}
	}	
	
	return true;
}
%>
<%
//通用数据导出程序(Excel...)
	user = new SysUser();
	user.initWebUser(jdb, request.getCookies());
	int OutToServer = WebChar.RequestInt(request, "OutToServer");
	int TMP = WebChar.RequestInt(request, "TMP");
	String FileName = WebChar.requestStr(request, "FileName");
	WritableWorkbook wb;
	Workbook wbTmpl = null;
	File savedFile = null;
	int ExcelFormID = WebChar.RequestInt(request, "ExcelFormID");
	if (ExcelFormID > 0)
	{
		String filePath = jdb.getSQLValue(0, "SELECT FileURL FROM AffixFile WHERE id in (select AffixID from UserDatas where ID=" + ExcelFormID + ")");
		java.io.File f = new java.io.File(filePath);
		if (!f.exists()) 
		{
			out.print("Error");
			jdb.closeDBCon();
			return;
		}
		wbTmpl = Workbook.getWorkbook(f);
	}
	
	if (OutToServer == 1)
	{
		String fname;
		if (TMP == 1)
			fname = application.getRealPath("/") + "tmp/" + FileName;
		else
			fname = AffixManager.getRootDir(jdb) + System.currentTimeMillis()  + "OUT.xls";
		savedFile = new File(fname);
		if (wbTmpl != null)
			wb = Workbook.createWorkbook(savedFile, wbTmpl);
		else
			wb = Workbook.createWorkbook(savedFile);
	}
	else
	{
		response.setContentType("application/octet-stream");
		String filename = new String(FileName.getBytes(), "ISO8859-1");
		response.setHeader("content-disposition", "attachment; filename=\"" + filename + "\"");
		OutputStream ws =response.getOutputStream();
		if (wbTmpl != null)
			wb = Workbook.createWorkbook(ws, wbTmpl);
		else
			wb = Workbook.createWorkbook(ws);
	}
	if (ExcelFormID > 0)
	{
		WritableSheet sheet = wb.getSheet(0);
		WriteExcelFromTmpl(sheet, request);
	}
	else
	{
		WritableSheet sheet = wb.createSheet("sheet1", 0);
		String serverurl =request.getRequestURL().toString();
		serverurl = serverurl.replace("OutExcel","down") + "?AffixID=";
		int hCount = WebChar.RequestInt(request, "hCount");
		int nHead = (WebChar.RequestInt(request, "headstyle") == 3) ? 0 : 1;
		for (int x = 0; x < hCount; x++)
		{
			if (nHead == 1)
			{
				String hv = WebChar.RequestForms(request, "hv", x);
				sheet.addCell(new Label(x, 0, hv));
			}
			String hp = WebChar.RequestForms(request, "hp", x);
			sheet.setColumnView(x, (WebChar.ToInt(hp) + 16) / 8);
		}
		int vCount = WebChar.RequestInt(request, "vCount");
		for (int x = 0; x < vCount; x++)
		{
			String vp = WebChar.RequestForms(request, "vp", x);
			if (WebChar.ToInt(vp) > 24)
				sheet.setRowView(x + nHead,  (WebChar.ToInt(vp) + 2) * 60 / 4);
		}
		SheetSettings st = new SheetSettings(sheet);
		st.setHorizontalFreeze(1);
		int x = 0, y = 0;
		int Count = WebChar.RequestInt(request, "Count");
		for (int z = 0; z < Count; z++)
		{
			String v = WebChar.RequestForms(request, "v" + z, 0);
			String p = WebChar.RequestForms(request, "p" + z, 0);
			String [] ss = p.split(",");
			if (ss.length < 4)
				continue;
			x = WebChar.ToInt(ss[0]);
			y = WebChar.ToInt(ss[1]) + nHead;
			int colspan = WebChar.ToInt(ss[2]);
			int rowspan = WebChar.ToInt(ss[3]);
			jxl.write.WritableCellFormat f;
			if (ss.length > 6)
				f = SetCellAttrib(v, ss[4], ss[5], ss[6]);
			else if (ss.length == 6)
				f = SetCellAttrib(v, ss[4], ss[5], "");
			else if (ss.length == 5)
				f = SetCellAttrib(v, ss[4], "", "");
			else if (ss.length == 4)
				f = SetCellAttrib(v, "", "", "");
			else
				f = new WritableCellFormat();
			f.setWrap(true);
			sheet.addCell(new Label(x, y, v, f));
			if ((colspan > 1) || (rowspan > 1))
				sheet.mergeCells(x, y, x + colspan - 1, y + rowspan - 1);
			if ((v.length() > serverurl.length()) && (serverurl.equals(v.substring(0, serverurl.length()))))
			{
				try
				{
					int AffixID = WebChar.ToInt(v.substring(serverurl.length()));
					String filePath = jdb.getSQLValue(0, "SELECT FileURL FROM AffixFile WHERE id=" + AffixID);
					java.io.File file = new java.io.File(filePath);
					addPictureToExcel(sheet, file, y, x, colspan, rowspan);
				}
				catch(Exception e)
				{
			       WebChar.logger.error("OutExcel:" + x + "," + y + "\n" + e.getMessage());
				}
			}
		}
	}
	wb.write();
	wb.close();
//	response.setContentLength((sheet.); //  设置下载内容大小 
	if (OutToServer == 1)
	{
		String Affix = "tmp/" + FileName;
		if (TMP == 0)
		{
			String time = VB.Now();
			String url = savedFile.getPath().replaceAll("\\\\", "\\\\\\\\");
			String sql = "INSERT INTO AffixFile(FileCName,LocalName,ParentID,FileURL,FileSize,SubmitMan,SubmitTime) VALUES('" + 
				FileName + "','" + FileName + "',0,'" + url + "'," + savedFile.length() + ",'" + user.CMemberName + "','" + time +"')";
			WebChar.logger.info("EXCEL文件信息写库： " + sql);
			jdb.ExecuteSQL(0, sql);
			Affix = jdb.getSQLValue(0, "SELECT id FROM AffixFile WHERE FileURL='" + url + "' AND SubmitTime='" + time + "'");
		}
		out.println("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">");
		out.println("<html><head>");
		out.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">");
		out.println("<title>导出EXCEL文件到服务器</title></head>");
		out.println("<body>");
		out.println("<script language=\"javascript\">");
		out.println("window.onload = function ()");
		out.println("{");
		out.println("	if (typeof parent.OutExceltoServerOK == \"function\")");
		out.println("		return parent.OutExceltoServerOK(\"" + Affix + "\")");
		out.println("	alert(\"导出Excel文件到服务器成功。文件编号或文件名=" + Affix + "\")");
		out.println("}");
		out.println("</script>");
		out.println("</body>");
		out.println("</html>");
	}
	response.flushBuffer();
	jdb.closeDBCon();
%>
