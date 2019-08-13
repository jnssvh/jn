<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,com.jaguar.*,project.*,jxl.*,jxl.write.*"%>
<%@ include file="init.jsp" %>
<%!
//Excel通用数据导入程序(用作表单、导入数据，和导出数据)
private String GetColName(int x)
{
	String name = String.format("%c", 'a' + (x % 26));
	int y = x / 26;
	if (y > 0)
		name = String.format("%c", 'a' + (y - 1)) + name;
	return name;
}
private String GetMergerCell(Range[] ranges, Cell cell, String field, String sp)
{
	String value = cell.getContents().replaceAll("\\n", "<br>").replaceAll("\r", "");
//	String value = WebChar.toJson(cell.getContents());
	int col = cell.getColumn();
	int row = cell.getRow();
	for (Range range : ranges)
	{
		Cell tl = range.getTopLeft();
		Cell br = range.getBottomRight();
		int startRow = tl.getRow();
		int startCol = tl.getColumn();
		int endRow = br.getRow();
		int endCol = br.getColumn();
		if (tl.equals(cell))
		{
			String result = sp + field + ":{";
			if (endCol - startCol > 0)
				result += "colspan:" + (endCol - startCol + 1) + ",";
			if (endRow - startRow > 0)
				result += "rowspan:" + (endRow - startRow + 1) + ",";
			String attrib = GetCellAttrib(cell);
			if (!attrib.equals(""))
				result += attrib;
			return result + "value:\"" + value + "\"}";
		}
		else if ((col >= startCol) && (col <= endCol) && (row >= startRow) && (row <= endRow))
				return "";
	}
	String attrib = GetCellAttrib(cell);
	if (attrib.equals(""))
		return sp + field + ":" + "\"" + value + "\"";
	return sp + field + ":{" + attrib + "value:\"" + value + "\"}";	  
}

private String GetCellAttrib(Cell cell)
{
	jxl.format.CellFormat cf = cell.getCellFormat();
	if (cf == null)
		return "";
	String align = cf.getAlignment().getDescription();
	if (align.equals("centre") || align.equals("general") || align.equals("fill"))
		align = "center";
	String value = "prop:\"align=" + align + " \",tdstyle:\"";
	String border = "border:none;";
	if (cf.hasBorders())
	{
		border = "border:" + "1px solid black;";
	}
	value += border;
	align = cf.getVerticalAlignment().getDescription();//??
	if (align.equals("centre"))
		value += "vertical-align:middle";
	value += "\",";

	jxl.format.Font font = cf.getFont();
	value += "style:\"font:" + (font.isItalic()? "italic" : "normal") + " normal " + font.getBoldWeight() + " " + font.getPointSize() + "pt " +font.getName() + ";";
	String color = cf.getBackgroundColour().getDescription();
	if (!color.equals("default background"))
		value += "background-color:" + color + ";";
	return value + "\",";
}

private String GetImage(JDatabase jdb, WebUser user, String srcName, Sheet sheet) throws Exception
{
	int num = sheet.getNumberOfImages();
	String result = "", sp = "";
	for(int x = 0; x < num; x++)
	{
		Image img = sheet.getDrawing(x);
		String oldname = img.getImageFile().getName();
		oldname = oldname.substring(0, oldname.length()- 1);
   		String fname = AffixManager.getRootDir(jdb) + System.currentTimeMillis()  + "XLSIMG.jpg";
		File f = new File(fname);
		f.createNewFile();
		FileOutputStream o = new FileOutputStream(f);
		o.write(img.getImageData());
		o.flush();
		o.close();
		String time = VB.Now();
		String url = f.getPath().replaceAll("\\\\", "\\\\\\\\");
		String sql = "INSERT INTO AffixFile(FileCName,LocalName,ParentID,FileURL,FileSize,SubmitMan,SubmitTime) VALUES('" + 
			oldname + ".jpg','" + srcName + "',0,'" + url + "'," + f.length() + ",'" + user.CMemberName + "','" + time +"')";
		WebChar.logger.info("EXCEL文件信息写库： " + sql);
		jdb.ExecuteSQL(0, sql);
		String Affix = jdb.getSQLValue(0, "SELECT id FROM AffixFile WHERE FileURL='" + url + "' AND SubmitTime='" + time + "'");

		result += sp + "{row:" + img.getRow() + ",col: " + img.getColumn() + ",affixID:" + Affix + "}";
		sp = ",";
	}
	return "[" + result + "]";
}

private String GetExcel(InputStream stream, JDatabase jdb, String filename, WebUser user)
{		
	StringBuffer data = new StringBuffer();
	String head, imgs = "[]";
	try
	{
		Workbook rBook = jxl.Workbook.getWorkbook(stream);
		Sheet sheet = rBook.getSheet(0);
		imgs = GetImage(jdb, user, filename, sheet);
		int rows = sheet.getRows();
		int cells = sheet.getColumns();
		if (cells > 100)
			cells = 100;
		Range[] ranges = sheet.getMergedCells();
		for (int x = 0; x < rows; x++)
		{
			if (x > 0)
				data.append(",\n");
			int eh = sheet.getRowHeight(x);
			data.append("{_lineControl:{height:" + ( 4 * eh / 60 - 2) + "}");
//			String sp = "";
			for (int y = 0; y < cells; y++)
			{
				Cell cell = sheet.getCell(y, x);
				String line = GetMergerCell(ranges, cell, GetColName(y), ",");
				data.append(line);
//				if (!line.equals("") && sp.equals(""))
//					sp = ",";
			}
			data.append("}");
		}
		head = "[{FieldName:\"Num\", TitleName:\"&nbsp;\", nShowMode:6, nWidth:36}";
		for (int y = 0; y < cells; y++)
		{
			int w = (sheet.getColumnView(y).getSize() - 256 - 16) / 32;
			head += ",\n		{FieldName:\"" + GetColName(y) + "\", TitleName:\"" + GetColName(y).toUpperCase() +
				"\", nShowMode:1, nWidth:" + w + "}";
		}
		head += "]";
		rBook.close();
	}
	catch (Exception e)
	{
		WebChar.logger.error("EXCEL Import Error:\n" + e.getMessage());
		return "[]";
	}
	return "{head:" + head + ", data:[" + data.toString() + "], images:" + imgs + "}";	
}
%>
<%
	user = new SysUser();
	user.initWebUser(jdb, request.getCookies());
	String JsonData = "", TitleName = "", FormName = "", FormCName = ""; 
	int DataID = WebChar.RequestInt(request, "DataID");
	if (WebChar.RequestInt(request, "SavetoTmplFile") == 1)
	{
		int AffixID = WebChar.ToInt(jdb.getSQLValue(0, "select AffixID from UserDatas where ID=" + DataID));
		if (AffixID == 0)
		{
			out.print("Error");
			jdb.closeDBCon();
			return;
		}
		String filePath = jdb.getSQLValue(0, "SELECT FileURL FROM AffixFile WHERE id=" + AffixID);
		java.io.File f = new java.io.File(filePath);
		if (!f.exists()) 
		{
			out.print("Error");
			jdb.closeDBCon();
			return;
		}
		Workbook rBook = jxl.Workbook.getWorkbook(f);
		WorkbookSettings settings = new WorkbookSettings();  
//		settings.setWriteAccess(null); 
		WritableWorkbook wwb = jxl.Workbook.createWorkbook(f, rBook, settings);
		WritableSheet sheet = wwb.getSheet(0);
		
		int cnt = WebChar.RequestInt(request, "count");
		for (int x = 0; x < cnt; x++)
		{
			int col = WebChar.ToInt(WebChar.RequestForms(request, "col", x));
			int row = WebChar.ToInt(WebChar.RequestForms(request, "row", x));
			String value = WebChar.RequestForms(request, "value", x);
			WritableCell cell = sheet.getWritableCell(col, row);
			jxl.format.CellFormat cf = cell.getCellFormat();
			sheet.addCell(new Label(col, row, value, cf));
			
		}
		wwb.write();
		wwb.close();
		rBook.close();
		out.print("OK");
		jdb.closeDBCon();
		return;		
	}
	if (WebChar.RequestInt(request, "SaveFlag") == 1)
	{
		FormName = WebChar.requestStr(request, "EName");
		FormCName = WebChar.requestStr(request, "CName");
		String Content = WebChar.requestStr(request, "Content");
		String sm = user.CMemberName;
		String st = VB.Now();
		String sql;
		if (DataID > 0)
			sql = "update UserDatas set EName='" +FormName + "', CName='" + FormCName + "', Content='" + Content + "',Status=1 where ID=" + DataID;
		else
			sql = "insert into UserDatas (EName, CName, DataType, Content, SubmitMan, SubmitTime, Status) values ('" + FormName + "','" + FormCName +
				"',1,'" + Content + "','" + sm + "','" + st + "',1)";
		jdb.ExecuteSQL(0, sql);
		if (DataID == 0)
			DataID = WebChar.ToInt(jdb.getValueBySql(0, 
				"select ID from UserDatas where EName='" + FormName + "' and SubmitMan='" + sm + "' and SubmitTime='" + st + "'"));
		out.print(DataID);
		jdb.closeDBCon();
		response.sendRedirect("inform.jsp?DataID=" + DataID);
		return;
	}
	if (DataID > 0)
	{
		ResultSet rs = jdb.rsSQL(0, "select * from UserDatas where ID=" + DataID);
		if (rs.next())
		{
			FormName = rs.getString("EName");
			FormCName = rs.getString("CName");
			TitleName = FormCName + "-" + FormName;
			JsonData = rs.getString("Content");
			int AffixID = WebChar.ToInt(rs.getString("AffixID"));
			if (WebChar.RequestInt(request, "GetAffixFile") == 1)
				JsonData = "";
			rs.close();
			if ((AffixID > 0) && ((JsonData == null) || (JsonData.equals(""))))
			{
				String filePath = jdb.getSQLValue(0, "SELECT FileURL FROM AffixFile WHERE id=" + AffixID);
				java.io.File f = new java.io.File(filePath);
				if (f.exists()) 
				{
					JsonData = GetExcel(new FileInputStream(f), jdb, f.getName(), user);
				}
			}
			if (WebChar.RequestInt(request, "Ajax") == 1)
			{
				out.print(JsonData);
				jdb.closeDBCon();	
				return;
			}
		}
		else
		{
			rs.close();
			jdb.closeDBCon();
			out.println("error,not found data.");
			return;
		}
	}	
	if (WebChar.RequestInt(request, "ImportExcelFlag") == 1)
	{
		FormName = WebChar.requestStr(request, "FormName");
	 	DiskFileUpload fu = new DiskFileUpload(); 
		List fileItems = fu.parseRequest(request);
		Iterator iter = fileItems.iterator();
		while (iter.hasNext()) 
		{
			FileItem item = (FileItem) iter.next();
			if(item.isFormField())
				continue;
			JsonData = GetExcel(item.getInputStream(), jdb, item.getName(), user);
			TitleName = item.getName();
		}
		if (WebChar.RequestInt(request, "Ajax") == 1)
		{
			out.print(JsonData);
			jdb.closeDBCon();	
			return;
		}
	}
	jdb.closeDBCon();
	String sDoc = "";
	if ((JsonData == null) || (JsonData.equals("")))
		JsonData = "{}";
	else if (!(JsonData.substring(0, 1).equals("{")))
	{
			sDoc = JsonData;
			JsonData = "{}";
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head><title>自定义表单报表(<%=TitleName%>)</title>   
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<link rel="stylesheet" type="text/css" href="../forum.css">
</head>
<body topmargin="0" leftmargin="0" scroll=no>
<div style="width:100%;height:100%;overflow:hidden;" id=DIV0></div>
</body>
<script language=javascript src=../com/jquery.js></script>
<script language=javascript src=../com/jcom.js></script>
<script language=javascript>
var oLayer, menudef, menubar, view, head, cellEditor, fieldmenu, docEditor; 
var dataObj, cellshadow,  formwin, formview;
var EditMode = 1;
var cellwin, cellview;
var FormName = "<%=FormName%>", FormCName = "<%=FormCName%>", DataID = <%=DataID%>;

window.onload = function()
{
	var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"WorkDiv"}};
	oLayer = new $.jcom.Layer(document.all.DIV0, aFace, {});
	menudef = [{item:"文件",child:[{item:"导入EXCEL表格",action:ImportTPL}, {item:"导入WORD表格", action: ImportWord},
		{item:"重新加载", action:"location.reload(true)"},{item:"重新从模板文件加载", action:ReloadFromAffix},{},{item:"表格编辑模式", action:GridEditMode},{item:"文档编辑模式", action:DocEditMode},{},{item:"关联表单", action:FormSet},{},{item:"另存为模板文件", action:SaveAsExcel}]},
		{item:"编辑",child:[{item:"单元格设置", action :CellSet},{item:"删除单元格内容", action:DelCell},{item:"单元格合并与拆分", action:MergeCell}, {}, {item:"插入行", action:InsertRow},
		{item:"删除选择行",action:DeleteRow},{item:"删除空行",action:DeleteBlankRow},{},
		{item:"插入列", action:InsertCol}, {item:"删除选择列", action:DeleteCol}, {item:"删除空列",action:DeleteBlankCol}, {},{item:"显示行列标题",action:ShowTitle,img:""}]},
		{item:"保存", child:[{item:"保存到数据库", action:SaveForm},{item:"保存到模板文件", action:SaveFile}]}]
	menubar = new $.jcom.CommonMenubar(menudef, document.all.SeekMenubar,"");
	if (FormName != "")
		FormSet();

	var json = <%=JsonData%>;
	if ((json == null) || (json.data == undefined))
	{
		DocEditMode("<%=WebChar.toJson(sDoc)%>");
		return;
	}
	dataObj = json.data;
	head = json.head;
	head[0].nShowMode = 1;
	head[0].nWidth = 1;
	
//	cellshadow = new $.jcom.CommonShadow(0, "#eeeeee");
	RenumberLine(false);
	
	if (dataObj.length == 0)
		alert("载入错误或载入数据为空。");
	view = new $.jcom.GridView($("#WorkDiv")[0], head, dataObj, {}, {footstyle:4,headstyle:3,nowrap:0});
	view.clickRow = SelectCell;
	view.bodymenu = FieldMenu;
//	cellEditor = new $.jcom.DynaEditor.ContentEditor();
//	view.attachEditor("a", cellEditor);
//	document.body.onbeforeprint = PreviewForm;
//	document.body.onafterprint = PrintEnd;
}

function PreviewForm()
{
	document.body.scroll = "yes";
	if (typeof formwin == "object")
		formwin.hide();
	if (typeof cellwin == "object")
		cellwin.hide();
	  
	$("#SeekMenubar").css("display", "none");

	$("#DIV0").css("overflow", "visible");
	$("#WorkDiv").css("overflow", "visible");
	$("#BodyDiv").css("overflow", "visible");
//	$(document).on("mousedown", PrintEnd);
//	alert("提示：目前显示的是打印效果，通过选用浏览器的打印或打印预览功能。可看到更直观的交往果。\n提示：完成后，点击文档任意处则恢复原界面。")
}

function PrintEnd()
{
	document.body.scroll = "no";
	$("#SeekMenubar").css("display", "");
	$("#DIV0").css("overflow", "hidden");
	$("#WorkDiv").css("overflow", "auto");
	$("#BodyDiv").css("overflow", "auto");
	$(document).off("mousedown", PrintEnd);
}

function GridEditMode()
{
	if (typeof view != "object")
	{
		alert("提示：需要载入表格文件");
		ImportTPL();
		return;
	}

	view.setDomObj($("#WorkDiv")[0]);
	if (typeof docEditor == "object")
		docEditor.setDomObj();
	EditMode = 1;
	var item = menubar.getItem("表格编辑模式");
	item.img = "../pic/flow_end.png";
	var item = menubar.getItem("文档编辑模式");
	item.img = "";
	if (menudef.length == 2)
	{
		menudef.splice(1, 0, editdef[0]);
		menubar.reload(menudef);
	}
}

function DocEditMode(sDoc)
{
	if (typeof view == "object")
		view.setDomObj();
	if (typeof sDoc == "string")
		$("#WorkDiv").html(sDoc);
	else
		$("#WorkDiv").html("");
	if (docEditor == undefined)
		docEditor = new $.jcom.HTMLEditor($("#WorkDiv")[0]);
	else
		docEditor.setDomObj($("#WorkDiv")[0]);
	EditMode = 2;
	var item = menubar.getItem("文档编辑模式");
	item.img = "../pic/flow_end.png";
	var item = menubar.getItem("表格编辑模式");
	item.img = "";
	if (menudef.length == 3)
	{
		editdef = menudef.splice(1, 1);
		menubar.reload(menudef);
	}
}

function MergeCell()
{
}

function InsertCol()
{
}

function DeleteCol()
{
}

function SaveForm()
{
	if (FormName == "")
	{
		alert("请先绑定表单后，才能保存");
		FormSet();
		return;
	}
	if (EditMode == 1)
	{
		if (event.ctrlKey)		//去除早期的未被清除的垃圾
		 	AdjustData(dataObj);
		CellValueSave();
		var o = {head:head, data:dataObj};
 		var Content = ValToJSONStr(o);
	}
	else
	{
		var doc = docEditor.getdoc();
		var Content = $(doc.body).html();
	}
	if (typeof $("#SaveFormFrame")[0] == "object")
	    $("#SaveFormFrame").remove();
	document.body.insertAdjacentHTML("beforeEnd", "<iframe id=SaveFormFrame style=display:none></iframe>");
	var doc = $("#SaveFormFrame")[0].contentWindow.document;
	doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
		"</head><body><form id=SaveForm method=post action=inform.jsp?SaveFlag=1 target=_parent>" +
		"<input id=Content name=Content><input name=DataID value=" + DataID +"><input name=EName value=\"" + FormName +
		"\"><input name=CName value=\"" + FormCName + "\">></form></body></html>");
	doc.charset = "gbk"; 
	doc.getElementById("Content").value = Content;
	 doc.getElementById("SaveForm").submit();
}


function SaveFile()
{
	var tag = "", cnt = 0;
	for (var x = 0; x < dataObj.length; x++)
	{
		for (var y = 0; y < head.length; y++)
		{
			var value = dataObj[x][head[y].FieldName];
			if (value == undefined)
				continue;
			if (typeof value == "object")
				value = value.value;
			value = "" + value;
			if ((value.substr(0, 1) == "(") && (value.substr(value.length - 1, 1) == ")"))
			{
				tag += "&row=" + x + "&col=" + (y - 1) + "&value=" + value;
				cnt ++;
			}
		}
	}
	$.jcom.Ajax(location.pathname + "?SavetoTmplFile=1", true, "DataID=" + DataID + "&count=" + cnt + tag, SaveFileOK);
}

function SaveFileOK(result)
{
	alert(result);
}

function ShowTitle(obj, item)
{
	if (item.img == "")
	{
		item.img = "../pic/flow_end.png";
		head[0].nShowMode = 1;
		head[0].nWidth = 20;
		RenumberLine(true);
		view.reload(dataObj, head, {headstyle:2});
	}
	else
	{
		item.img = "";
		head[0].nShowMode = 1;
		head[0].nWidth = 1;
		RenumberLine(false);
		view.reload(dataObj, head, {headstyle:3});
	}
}

function RenumberLine(bNum)
{
	if (bNum == undefined)
	{
		var item = menubar.getItem("显示行列标题");
		if (item.img == "")
			bNum = false;
		else
			bNum = true;
	}
	for (var x = 0; x < dataObj.length; x++)
	{
		if (bNum)
			dataObj[x].Num = {value:x + 1, tdstyle:"background-color:#78BCED",divstyle:"color:white;"};
		else
			dataObj[x].Num = {value:"", tdstyle:"",divstyle:"color:white;"};
	}
}

function SelectCell(td, event)
{
	var sel = view.getsel();
	var old = sel.getObj();
	if (old == td)
		return;
	CellValueSave();
	sel.show(td);
	var o = td.firstChild;
	if ((o == null) || (o.nodeType == 3))
	{
//		alert(td.style.font);
		td.innerHTML = "<div style='font:" + td.style.font + ";color:" + td.style.color + ";' CONTENTEDITABLE>" + td.innerHTML + "</div>";
	}
	else if (o.contentEditable != true)
	{
		o.contentEditable = true;
//		o.onpropertychange = test;
//		window.status = "!";
	}
	if (typeof cellwin == "object")
	{
		if (cellwin.isShow())
			CellProp();
	}
	
}

function test()
{
	window.status += ".";
}

function FieldMenu()
{
	if (fieldmenu == undefined)
	{
	
	}
return false;
}

function CellValueSave()
{
	var sel = view.getsel();
	var td = sel.getObj();
	if (typeof td != "object")
		return;
	var node = $(td.parentNode).attr("node");
	var ss = td.id.split("_");
	var o = td.firstChild;
	if ((o == null) || (o.nodeType == 3))
		o = td;
	view.setCell(node, ss[0], o.innerHTML);
}

function DelCell()
{
	var sel = view.getsel();
	var td = sel.getObj();
	if (td == undefined)
		return alert("未选择单元格");
	var node = $(td.parentNode).attr("node");
	var ss = td.id.split("_");
	view.setCell(node, ss[0], "");
}

function DeleteBlankRow()
{
	for (var x = dataObj.length - 1; x>=0; x--)
	{
		var row = view.getRow(x);
		var bk = true;
		for (var y = 1; y < row.cells.length; y++)
		{
			if (row.cells[y].innerText != "")
			{
				bk = false;
				break;
			}
		}
		if (bk)
			view.deleteRow(x);
	}
	view.reload();	
}

function DeleteBlankCol()
{
	for (var y = head.length - 1; y >= 0; y--)
	{
		for (var x = dataObj.length - 1; x >= 0; x--)
		{
			if (((typeof dataObj[x][head[y].FieldName] == "string") && (dataObj[x][head[y].FieldName] != "")) ||
				((typeof dataObj[x][head[y].FieldName] == "object") && (dataObj[x][head[y].FieldName].value != "")))
				break;
		}
		if (x == -1)
		{
			for (var x = dataObj.length - 1; x >= 0; x--)
			{
				delete dataObj[x][head[y].FieldName];
			}	
			head.splice(y, 1);
		}
	}
	
	view.reload(dataObj, head);
}

function AdjustData()
{
	for (var x = dataObj.length - 1; x >= 0; x--)
	{
		for (key in dataObj[x])
		{
			if (key == "_lineControl")
				break;
			for (var y = 0; y < head.length; y++)
			{
				if (head[y].FieldName == key)
					break;
			}
			if (y == head.length)
				delete dataObj[x][key];
		}
	}
}


function InsertRow()
{
	var sel = view.getsel();
	var td = sel.getObj();
	var items = view.getData();
	var node = items.length - 1;
	if (typeof td == "object")
		node = parseInt($(td.parentNode).attr("node"));
	var span = 0;
	var item = {};
	for (var x = 0; x < head.length; x++)
	{
		if (items[node][head[x].FieldName] == undefined) 
		{
			if (span == 0)
				continue;
		}
		else if (typeof items[node][head[x].FieldName] == "object")
		{
			if (items[node][head[x].FieldName].rowspan > 1)
				continue;
			if (items[node][head[x].FieldName].colspan > 1)
				span += items[node][head[x].FieldName].colspan - 1;
		}
		item[head[x].FieldName] = "";
			
	}
	var d = 0;
	for (var y = node; y >= 0; y--)
	{
		d ++;
		for (var x = head.length - 1; x >= 0; x--)
		{
			if (typeof items[y][head[x].FieldName] == "object")
			{
				if (items[y][head[x].FieldName].rowspan > d)
				{
					items[y][head[x].FieldName].rowspan ++;
				}
			}
		}
	}	
	RenumberLine();
	view.insertRow(item, node + 1);
	view.reload();
}

function DeleteRow()
{
	var sel = view.getsel();
	var td = sel.getObj();
	if (td == undefined)
		return alert("未选择单元格");
	if (window.confirm("将删除当前单元格所在的行，是否确定？") == false)
		return;
	view.deleteRow($(td.parentNode).attr("node"));
	view.reload();

}

function SaveAsExcel()
{
	view.OutExcel(FormName + ".xls");

}

function ValToJSONStr(val)
{
	switch (typeof val)
	{
	case "string":
		return "\"" + val.replace(/[\r\n]+/g, "").replace(/"/g, "\\\"") + "\"";
	case "number":
		return val;
	case "object":
		if (Object.prototype.toString.apply(val) == "[object Array]")
		{
			var s = "[", p1 = "";
			for (var x = 0; x < val.length; x++)
			{
				s += p1 + ValToJSONStr(val[x]);
				p1 = ",";
			}
			return s + "]";
		}
		var s = "{", p1 = "";
		for (var key in val)
		{
			s += p1 + key + ":" + ValToJSONStr(val[key]);
			p1 = ",";
		}
		return s + "}";
	}
}

function ImportTPL()
{
	if (typeof $("#ImportExcelFrame")[0] == "object")
		$("#ImportExcelFrame").remove();
	document.body.insertAdjacentHTML("beforeEnd", "<iframe id=ImportExcelFrame style=display:none></iframe>");
	var doc = $("#ImportExcelFrame")[0].contentWindow.document;
	doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
		"</head><body><form id=ImportForm method=post action=../com/inform.jsp?ImportExcelFlag=1&DataID=" + DataID +
		" enctype=multipart/form-data target=_parent><input type=file name=LocalName onchange=parent.StartImportFile()></form></body></html>");
	doc.charset = "gbk";
	doc.getElementById("LocalName").click();
}

function StartImportFile()
{
  var doc = $("#ImportExcelFrame")[0].contentWindow.document;
  if (doc.getElementById("LocalName").value != "")
    doc.getElementById("ImportForm").submit();
}

function ReloadFromAffix()
{
	$.get(location.href, {Ajax:1, GetAffixFile:1}, ReloadOK);

}

function ReloadOK(data)
{
	var json = $.jcom.eval(data);
	if (json.data == undefined)
		return alert("加载的内容是空");
	dataObj = json.data;
	head = json.head;
	RenumberLine();
	view.reload(dataObj, head);
}
function ImportWord()
{
	return alert("暂未支持");
	if (typeof App != "object")
	{
		try
		{
			App = new ActiveXObject("Word.Application");
			App.visible=true;
//			var doc = App.Documents.Add();
//			App.Activate();
		} catch (e)
		{
			alert("未能打开本地的OFFICE程序。" + e.description);
			return false;
		}
	}
	var doc = App.Documents.Open("C:\\TMP\\test.doc");
	doc.ActiveWindow.Activate();
	var rows = doc.Tables(1).Rows.Count;
	var cols = doc.Tables(1).Columns.Count;
	alert(rows + "-" + cols);
	for (var y = 0; y < rows; y++)
	{
		for (var x = 0; x < cols; x++)
		{
			try
			{
				var cell = doc.Tables(1).Cell(y + 1, x + 1);
				alert(cell.Range.Text + "-" + y + "-" + x + "-" + cell.ColumnIndex);
			}
			catch (e)
			{
				alert(y + "-" + x + e.description);
			}
		}
	}
}

function seltext(obj)
{
	obj.previousSibling.focus();
	obj.previousSibling.select();
}

function copytext(obj)
{
	var oRange = obj.previousSibling.previousSibling.createTextRange();
	oRange.execCommand("Copy");
}

function CellSet()
{
	if (typeof cellwin == "object")
	{
		CellProp();
		return cellwin.show();
	}
	
	cellwin = new $.jcom.PopupWin("<div id=CellInfoView style=width:100%;height:100%></div>", 
			{title:"单元格信息", width:400, height:520});
	cellwin.close = cellwin.hide;
	var aFace = {x:0,y:30,node:1,a:{id:"InfoTop"},b:{id:"InfoBottom"}};
	var def = [{item:"应用", action:ApplyGrid}];
	var oLayer = new $.jcom.Layer($("#CellInfoView")[0], aFace, {border:"1px dotted gray"});
	var menu = new $.jcom.CommonMenubar(def, $("#InfoTop")[0]);
	cellview = new $.jcom.GridView($("#InfoBottom")[0], [{FieldName:"Prop", TitleName:"名称", nWidth:200, bTag:1, nShowMode:9},
		{FieldName:"Value", TitleName:"内容", nWidth:170, nShowMode:1}], [],{},{footstyle:4, initDepth:100});
	var celleditor = new $.jcom.DynaEditor.Edit();
//	celleditor.valueChange = PropChange();
	cellview.EditorChange = PropChange;
	cellview.attachEditor("Value", celleditor);
	CellProp();
}

function ApplyGrid()
{
	view.reload();
}

function PropChange(value, FieldName, node, obj)
{
	var propdata = cellview.getData();
	var griddata = view.getData();
	var ss = node.split(",");
	switch (parseInt(ss[0]))
	{
	case 0:		//cell value
//		alert(propdata[0].child[ss[1]].Prop);
//		alert(griddata[propdata[0].row][propdata[0].col][propdata[0].child[ss[1]].Prop]);
		griddata[propdata[0].row][propdata[0].col][propdata[0].child[ss[1]].Prop] = value;
		break;
	case 1:		//row
		griddata[propdata[0].row]._lineControl[propdata[1].child[ss[1]].Prop] = value;
		break;
	case 2:		//col
		var head = view.getHead();
		var index = $.jcom.inObjArray(head, "FieldName", propdata[0].col);
		head[index][propdata[2].child[ss[1]].Prop] = value;
		break;
	}
}

function CellProp()
{
	var propdata = [{Prop:{colspan:2, value:"单元格信息"}, child:[]}, {Prop:{colspan:2, value:"行信息"}, child:[]}, {Prop:{colspan:2, value:"列信息"}, child:[]}];
	var item = {Prop:"", Value:""};
	var sel = view.getsel();
	var td = sel.getObj();
	if (typeof td == "object")
	{
		var value = view.getCellData(td);
		if (typeof value == "object")
			SetObjProp(value, propdata[0].child);
		else
			propdata[0].child[0] = {Prop:"value", Value: value};
		var item = view.getItemData($(td.parentNode).attr("node"));
		SetObjProp(item._lineControl, propdata[1].child);
		var head = view.getHead();
		var ss = td.id.split("_");
		var index = $.jcom.inObjArray(head, "FieldName", ss[0]);
		if  (index >= 0)
			SetObjProp(head[index], propdata[2].child);
		
		propdata[0].row = $(td.parentNode).attr("node");
		propdata[0].col = ss[0];
	}
	cellview.reload(propdata);
}

function SetObjProp(obj, a)
{
	if (typeof obj != "object")
		return;
	for (var key in obj)
		a[a.length] = {Prop:key, Value:obj[key]};
}

function FormSet()
{
	if (typeof formwin == "object")
		return formwin.show();
	formwin = new $.jcom.PopupWin("<div id=FormFieldView style=width:100%;height:100%></div>", 
		{title:"关联表单信息", width:360, height:480,unselect:1});
	formwin.close = formwin.hide;
	var aFace = {x:0,y:30,node:1,a:{id:"FormTop"},b:{id:"FormBottom"}};
	var oLayer = new $.jcom.Layer($("#FormFieldView")[0], aFace, {border:"1px dotted gray"});
	var def = [{item:"应用", action:ApplyField}];
	var menu = new $.jcom.CommonMenubar(def, $("#FormTop")[0],
		{title:"表单:&nbsp;<input type=text id=FormName value=" + FormName + ">&nbsp;<input type=button onclick=LoadForm() value=加载>&nbsp;"});

	formview = new $.jcom.GridView($("#FormBottom")[0], [{FieldName:"CName", TitleName:"名称", nWidth:160, nShowMode:9},
			{FieldName:"EName", TitleName:"字段", nWidth:120, nShowMode:1}], [],{},{footstyle:4, initDepth:100});
	if (FormName != "")
		LoadForm();
	formview.dblclickRow = ApplyField;
}

function ApplyField()
{
	var item = formview.getItemData();
	if (item == undefined)
		return alert("请先选择字段");
	var FieldName = "(" + item.EName + ")";
	if (EditMode == 2)
	{
		docEditor.insertHTML(FieldName);
		return;
	}
	CellValueSave();
	var sel = view.getsel();
	var td = sel.getObj();
	if (td == undefined)
		return alert("未选择单元格");
	var node = $(td.parentNode).attr("node");
	var ss = td.id.split("_");
	var value = view.getCellData(td);
	if (typeof value == "object")
		FieldName = value.value + FieldName;
	else
		FieldName = value + FieldName;
	view.setCell(node, ss[0], FieldName);
}

function LoadForm()
{
	FormName = $("#FormName")[0].value;
	if (FormName == "")
		return alert("表单名不可为空");
	$.get("../fvs/" + FormName + ".jsp", {getdesign: 1}, LoadFormOK);
}

function LoadFormOK(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return json;
	FormCName = json.title;
	for (var x = 0; x < json.fields.length; x++)
	{
		if ((json.fields[x].nWidth == 0) || (json.fields[x].InputType == 21))
				json.fields[x]._lineControl = {height:0};
	}
	formview.reload(json.fields);
	var box = formwin.getbox();
	box.unselect();	
}

function pasteinfo(obj)
{
	var o = document.all.ImportText;
	o.focus();
	o.select();
	var oRange = o.createTextRange();
	oRange.execCommand("Paste");
}
</script></html>