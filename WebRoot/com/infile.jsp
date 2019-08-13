<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,com.jaguar.*,project.*,jxl.*"%>
<%@ include file="init.jsp" %>
<%!
//通用数据导入程序(Excel...)
public String GetExcelJson(InputStream is)
{
//	String data = "";
	StringBuffer data = new StringBuffer();
	try
	{
		Workbook rBook = jxl.Workbook.getWorkbook(is);
		Sheet sheet = rBook.getSheet(0);
		int rows = sheet.getRows();
		int cells = sheet.getColumns();
		for (int x = 0; x < rows; x++)
		{
			if (x > 0)
				data.append(",\n");	
			data.append("{");
			for (int y = 0; y < cells; y++)
			{
				if (y > 0)
					data.append(",");
				data.append(String.format("%c:", 'a' + y) + "\"" + sheet.getCell(y, x).getContents().replaceAll("\\n", "").replaceAll("\r", "") + "\"");
				if (y > 24)
					break;
			}
			data.append("}");
		}
		rBook.close();
	}
	catch (Exception e)
	{
		return "[]";
	}
	return "[" + data.toString() + "]";
}
%>
<%
	if (WebChar.RequestInt(request, "ExportFlag") == 1)
	{
		response.setContentType("application/octet-stream;charset=gbk ");
		String TableName = WebChar.RequestForms(request, "TableName", 0);
		response.setHeader("Content-Disposition", "attachment; filename=\"" + TableName + "_templete.csv\"");
		String data = WebChar.RequestForms(request, "data", 0);
		response.setContentLength(data.length()); //  设置下载内容大小 
		out.print(data);		 
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "RunFlag") == 1)
	{
		String result = "";
		String TableName = WebChar.RequestForms(request, "TableName", 0);
		String [] o = request.getParameterValues("ExField");
		String sqlex1 = "", sqlex2 = "", sqlex3 = "";
		if (o != null)
		{
			int excnt = request.getParameterValues("ExField").length;
			for (int x = 0; x < excnt; x++)
			{
					String ExName = WebChar.RequestForms(request, "ExField", x);
					int ExType = WebChar.ToInt(WebChar.RequestForms(request, "ExType", x));
					String exValue = WebChar.RequestForms(request, ExName, x);
					sqlex1 += "," + jdb.SQLField(0, ExName);
					sqlex2 += "," + jdb.GetFieldTypeValueEx(exValue, ExType, 0);
					sqlex3 += "," + jdb.SQLField(0, ExName) + "=" + jdb.GetFieldTypeValueEx(exValue, ExType, 0);
			}
		}
		int fieldcnt = request.getParameterValues("FieldName").length;
		int datacnt = request.getParameterValues(WebChar.RequestForms(request, "FieldName", 0)).length;
		for (int y = 0; y < datacnt; y++)
		{
			String sql = "", sql1 = "", sql2 = "", sql3 = "", sql4 = "";
			for (int x = 0; x < fieldcnt; x++)
			{
				String FieldName = WebChar.RequestForms(request, "FieldName", x);
				String fname = jdb.SQLField(0, FieldName);
				int FieldType = WebChar.ToInt(WebChar.RequestForms(request, "FieldType", x));
				int bUnique =  WebChar.ToInt(WebChar.RequestForms(request, "bUnique", x));
				int bPrimaryKey =  WebChar.ToInt(WebChar.RequestForms(request, "bPrimaryKey", x));
				String value = WebChar.GetAjaxPostData(request, FieldName, y);
				if ((bUnique == 1) || (bPrimaryKey == 1))
				{
					if (!sql4.equals(""))
						sql4 += " and ";
					sql4 += fname + "=" + jdb.GetFieldTypeValueEx(value, FieldType, 0);
				}
				else
				{
					if (!sql3.equals(""))
						sql3 += ",";
					sql3 += fname + "=" + jdb.GetFieldTypeValueEx(value, FieldType, 0);
				}
				if (!sql1.equals(""))
					sql1 += ",";
				sql1 += fname;
				if 	(!sql2.equals(""))
					sql2 += ",";
				sql2 += jdb.GetFieldTypeValueEx(value, FieldType, 0);
			}
			int cnt = 0;
			if (!sql4.equals(""))
			{
				sql = "update " + TableName + " set " + sql3 + sqlex3 + " where " + sql4;
				cnt = jdb.ExecuteSQL(0, sql);
			}
			if (cnt < 1)
			{
				sql = "insert into " + TableName + "(" + sql1 + sqlex1 + ") values (" + sql2 + sqlex2 + ")";
				cnt = jdb.ExecuteSQL(0, sql);
			}
			if (!result.equals(""))
			result += ",";
			WebChar.logger.info("sql = " + sql);
			result += cnt;
		}
		out.print("[" + result + "]");
		jdb.closeDBCon();
		return;		
	}

	String JsonData = "[]", FileName = "", FieldInfo = "[]", ImportInfo = "[]", sinc = "", incfile = "";
	if (WebChar.RequestInt(request, "SaveFlag") == 1)
	{
	 	DiskFileUpload fu = new DiskFileUpload(); 
		List fileItems = fu.parseRequest(request);
		Iterator iter = fileItems.iterator();
		while (iter.hasNext()) 
		{
			FileItem item = (FileItem) iter.next();
			if(item.isFormField())
			{
				if (item.getFieldName().equals("ImportInfo"))
				{
					ImportInfo = new String(item.get(), WebChar.charSet);
					if (ImportInfo.equals(""))
						ImportInfo = "[]";
				}
				else if (item.getFieldName().equals("FieldInfo"))
				{
					FieldInfo = new String(item.get(), WebChar.charSet);
					if (FieldInfo.equals(""))
						FieldInfo = "[]";
				}
				else if (item.getFieldName().equals("sinc"))
					sinc = new String(item.get(), WebChar.charSet);
				else if (item.getFieldName().equals("cinc"))
				{
					String cinc = new String(item.get(), WebChar.charSet);
					if (!cinc.equals(""))
						incfile = "<script language=javascript src=" + cinc + "></script>";
				}
//				WebChar.logger.info(item.getString());
				continue;
			}
			else
			{
				JsonData = GetExcelJson(item.getInputStream());
				FileName = item.getName();
			}
		}
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head><title>数据导入(<%=FileName%>)</title>   
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<link rel="stylesheet" type="text/css" href="../forum.css">
</head>
<body topmargin="0" leftmargin="0" scroll=no>
<div id=SeekMenubar style='with:100%;height:24px;padding:2px;background:'>载入中...</div>
<div id=ImportGridDiv style=width:100%;height:100%;overflow:hidden;padding-bottom:30px>
</div>
</body>
<script language=javascript src=../com/jquery.js></script>
<script language=javascript src=../com/jcom.js></script>
<%=incfile%>
<script language=javascript>
var menubar, view, fieldEditor, cellEditor; 
var TableName, TableCName, InFields;
var dataObj, fieldObj, ImportInfo, cellshadow, titleIndex;

window.onload = function()
{
	dataObj = <%=JsonData%>;
	fieldObj = <%=FieldInfo%>;
//	InportInfo = [{col:"a", field:"", exp:"", index:0}];
	ImportInfo = <%=ImportInfo%>;
	cellshadow = new $.jcom.CommonShadow(0, "#eeeeee");
	TableName = fieldObj[0].TableName;
	TableCName = fieldObj[0].TableCName;
	if (typeof UserInFields == "string")
		InFields = UserInFields;
	else
	{
		if (typeof fieldObj[0].Fields == "undefined")
			InFields = "";
		else
			InFields = fieldObj[0].Fields.split(",");
	}
	var head = GetHead(dataObj);
	
	for (var x = 0; x < dataObj.length; x++)
		dataObj[x].Num = {value:x, tdstyle:"background-color:#78BCED",divstyle:"color:white;"};
	if (dataObj.length > 0)
		dataObj[0].Num.value = "标题";
	titleIndex = 0;
	menubar = new $.jcom.CommonMenubar([{item:"文件",child:[{item:"导入新文件",action:ImportNew},
		{item:"导入本地文件",action:ImportLocal}, 	{item:"导出SQL",action:OutSQL},
		{item:"重新加载", action:"location.reload(true)"},{item:"字段定义描述", action:OutImportInfo},{},{item:"另存为模板文件", action:SaveAsExcel}]},
		{item:"编辑",child:[{item:"新增行", action:AddLine},{item:"新增列", action:AddCol},{},
			{item:"删除选择行",action:DeleteRow},{item:"删除空行",action:DeleteBlankRow}]},
		{item:"处理", child:[{item:"设置标题行",action:SetTitleLine},
			{item:"删除选择数据中的空格",action:DelBlankData},
			{item:"用当前单元格的数据填充选择列", action:FillData},
			{item:"为选择列使用数据转换公式", action:SetExp},
			{item:"将选择列内容转换成日期格式", action:"SetDateFmt()"},
			{item:"设置唯一性字段", action:SetUnique},
			{item:"检查数据的有效合法性", action:CheckGrid}]}], $("#SeekMenubar")[0],
			"<span id=FileNameSpan>源文件：(<%=WebChar.toJson(FileName)%>)</span>&nbsp;<input id=RunButton type=button value=\"导入到" + TableCName +"(" + TableName + ")\" onclick=RunImport()>");
	view = new $.jcom.GridView(document.all.ImportGridDiv, head, dataObj, {}, {footstyle:0,headstyle:4});
	if (dataObj.length == 0)
		view.waiting("未加载导入数据或导入数据为空。请使用文件菜单下的导入功能导入数据。");
	
	var gridhead = view.getChildren("gridhead");
	gridhead.clickHead = SelectCol;
//	view.bodyonload = BodyOnload;
//	BodyOnload();
	$("#ImportGridDiv").on("onmousedown", SelectCell);
	
	var list = "未设置";
	for (var x = 1; x < fieldObj.length; x++)
	{
		if (isFieldEnable(fieldObj[x]))
			list += "," + fieldObj[x].FieldName + "(" + fieldObj[x].ShowName + ")";
	}
	fieldEditor = new $.jcom.DynaEditor.List(list, 300, 300);
	fieldEditor.valueChange = fieldChange;
	SetHeadEditor();
	FormatImportInfo(ImportInfo);
	AutoSetupCol();
}

function GetHead(dataObj)
{
	var head = [{FieldName:"Num", TitleName:"字段<br>序号", nShowMode:1, nWidth:36}];
	for (var key in dataObj[0])
	{
		var x = head.length;
		head[x] = {};
		head[x].FieldName = key;
		head[x].TitleName = "<div id=" + key + "_Field style='width:100%;overflow:hidden;'>未设置</div>" + key.toUpperCase();
		head[x].nShowMode = 1; 
		head[x].nWidth = 80;
	}
	return head;
}

function isFieldEnable(field)
{
	if (InFields.length == 0)
		return true;
	for (var x = 0; x < InFields.length; x++)
	{
		if (field.FieldName == InFields[x])
			return true;
	}
	return false;
}

function BodyOnload()
{
	for (var y = 0; y < ImportInfo.length; y++)
	{
		for (var x = 0; x < dataObj.length; x++)
		{
			var cell = view.getCell(x, ImportInfo[y].col);
			cell.firstChild.attachEvent("onmousedown", SelectCell);
		}
	}
}

function AutoSetupCol()
{
	var item = dataObj[titleIndex];
	for (var x = 0; x < ImportInfo.length; x++)
	{
		var col = ImportInfo[x].col;
		for (var y = 1; y < fieldObj.length; y++)
		{
			if (($.trim(item[col]) == fieldObj[y].FieldName) || ($.trim(item[col]) == fieldObj[y].ShowName))
			{
				ImportInfo[x].index = y;
				ImportInfo[x].field = fieldObj[y].FieldName;
				var obj = document.getElementById(col + "_Field");
				obj.innerText = fieldObj[y].FieldName + "(" + fieldObj[y].ShowName + ")";
				SetColEditor(fieldObj[y], ImportInfo[x].col);
				break;
			}	
		}
	}
}

function SetTitleLine()
{
	var sel = view.getSelRow();
	if (sel == undefined)
		return alert("未选择行");
	var item = view.getItemData(sel);
	dataObj[titleIndex].Num.value = titleIndex;
	titleIndex = parseInt(sel.node);
	item.Num.value = "标题";
	view.reload();
}

function SelectCell(e)
{
	var o = e.target;
	if (o.tagName !="DIV")
		return;
	if (o.parentNode.tagName != "TD")
		return;
	if (o.parentNode.cellIndex == 0)
		return;
	if (o.parentNode.parentNode.rowIndex == 0)
		return;
	cellshadow.show(o);
}

function SetHeadEditor()
{
	for (var key in dataObj[0])
	{
		var o = document.getElementById(key + "_Field");
		if (o != null)
		{
			fieldEditor.attach(o);
//			view.attachEditor(key, cellEditor);
		}
	}
}

var reloadFlag = true;
function FormatImportInfo(ImportInfo)
{
var x = 0;
	reloadFlag = false;
	for (var key in dataObj[0])
	{
		if (key == "Num")
			continue;
		if (typeof ImportInfo[x] != "object")
			ImportInfo[x] = {};
		ImportInfo[x].col = key;
		ImportInfo[x].exp = "";
		if (typeof ImportInfo[x].field == "string")
		{
			var o = document.getElementById(key + "_Field");
			o.innerText = ImportInfo[x].field;
			fieldChange(o);
		}
		x++;
	}
	reloadFlag = true;
	view.reload();
	
}

function fieldChange(obj)
{
	for (var x = 0; x < ImportInfo.length; x++)
	{
		if (ImportInfo[x].col == obj.id.substr(0, obj.id.length - 6))
		{
			CopyColVal(ImportInfo[x].col, "restore");
			if (obj.innerText == "未设置")
			{
					view.detachEditor(ImportInfo[x].col);
					delete ImportInfo[x].field;
					ImportInfo[x].index = 0;
					break;
			}
			ImportInfo[x].field = obj.innerText.split("(")[0];
			for (var y = 1; y < fieldObj.length; y++)
			{
				if (fieldObj[y].FieldName == ImportInfo[x].field)
				{
					ImportInfo[x].index = y;
					obj.innerHTML = fieldObj[y].FieldName + "(" + fieldObj[y].ShowName + ")";
					if (fieldObj[y].bUnique == 1)
						obj.innerHTML = "<b>" + obj.innerHTML + "</b>";
					SetColEditor(fieldObj[y], ImportInfo[x].col);
					dataObj[titleIndex][ImportInfo[x].col] = fieldObj[y].ShowName;
					if (reloadFlag)
						view.reload();
					break;
				}	
			}
			if (y == fieldObj.length)
				obj.innerText = "未设置";
			break;
		}	
	}
}

function CopyColVal(col, action)
{
	if (reloadFlag == false)
		return;
	for (var y = 0; y < dataObj.length; y++)
	{
		if (y == titleIndex)
			continue;
		if (action == "backup")
			dataObj[y][col + "_old"] = dataObj[y][col];
		if (action == "restore")
		{
			if (typeof dataObj[y][col + "_old"] != "undefined")
				dataObj[y][col] = dataObj[y][col + "_old"];
		}
	}		
	view.reload();
}

function SetColEditor(field, col)
{
	if (typeof field.editor == "object")
		return view.attachEditor(col, field.editor);
	var q = field.QuoteTable;
	var fun = function (data)
	{
		field.editor = new $.jcom.DynaEditor.List(data, 300, 300);
		view.attachEditor(col, field.editor);
		TranslateCol(col, field);
	};
	switch (q.substr(0, 1))
	{
	case "(":
		fun(q.substr(1, q.length - 2));
		return true;
	case "@":
//		AjaxRequestPage(psubdir + "seleenum.jsp?EnumType=" + q.substr(1) + "&AjaxMode=1", true, "", fun);
		$.get("seleenum.jsp?EnumType=" + q.substr(1) + "&AjaxMode=1", {}, fun);
		return true;
	case "$":
		return true;
	default:
		var ss = q.split(",")
		if (ss.length == 1)
			break;;
		var s1 = ss[0].split(".");
		if (s1[1] == ss[1])
			break;
//		AjaxRequestPage(psubdir + "SeleQuoteTable.jsp?AjaxMode=1&TableName=" + s1[0] + "&QuoteField=" + s1[1] + "&AliasField=" + ss[1],
//			true, "", fun);
		$.get("SeleQuoteTable.jsp?AjaxMode=1&TableName=" + s1[0] + "&QuoteField=" + s1[1] + "&AliasField=" + ss[1], {}, fun);
		return true;	
	}
	if (field.FieldType == 4)
	{
		SetDateFmt(col);
		field.editor = new $.jcom.DynaEditor.Date(200, 250);
	}
	else
		field.editor = new $.jcom.DynaEditor.Input();
	view.attachEditor(col, field.editor);
}

function TranslateCol(col, field)
{
	if (typeof UserTranslateCol == "function")
		UserTranslateCol(col, field);
	var data = $.trim(field.editor.getData());
	var ss = data.split(",");
	for (var y = 0; y < dataObj.length; y++)
	{
		if (y == titleIndex)
			continue;
		for (var x = 0; x < ss.length; x++)
		{
			var sss = ss[x].split(":");
			if (sss.length > 1)
			{
				if ((sss[1] == dataObj[y][col]) || (ss[x] == dataObj[y][col]) || (sss[0] == dataObj[y][col]))
					dataObj[y][col] = ss[x];
			}
		}
	}
	if (reloadFlag)
		view.reload(dataObj);
}

function SetUnique()
{
	var objs = view.getsel().getShadow();
	if ((objs.length <= 0) || (objs[0].obj.tagName == "TR"))
		return alert("请先选择列");
	var FieldName = objs[0].obj.id.split("_")[0];
	var FieldName = objs[0].obj.id.split("_")[0];
	for (var x = 0; x < ImportInfo.length; x++)
	{
		if ((typeof ImportInfo[x].field != "undefined") && (ImportInfo[x].col == FieldName))
		{
			var field = fieldObj[ImportInfo[x].index];
			var o = document.getElementById(FieldName + "_Field");
			if (field.bUnique == 0)
			{
				if (window.confirm("设置唯一性字段的目的是为了再次导入时能替换原先导入的结果，但如果字段本身不唯一，有可能会影响其它记录，是否继续？") == false)
					return;
				field.bUnique = 1;
				o.innerHTML = "<b>" + o.innerText + "</b>";
			}
			else
			{
				if (window.confirm("将取消唯一性字段设置，是否继续？") == false)
					return;
				field.bUnique = 0;
				o.innerHTML = o.innerText;
			}
			break;
		}
	}
	if (x == ImportInfo.length)
		return alert("请先设置选择列");
}

function SetExp()
{
	var objs = view.getsel().getShadow();
	if ((objs.length <= 0) || (objs[0].obj.tagName == "TR"))
		return alert("请先选择列");
	var FieldName = objs[0].obj.id.split("_")[0];
	for (var x = 0; x < ImportInfo.length; x++)
	{
		if ((typeof ImportInfo[x].field != "undefined") && (ImportInfo[x].col == FieldName))
		{
			var dlg = new $.jcom.PopupWin("<textarea id=ColExpText style=width:100%;height:240>" + ImportInfo[x].exp + 
				"</textarea><input type=button value=运行 onclick=RunExp('" + FieldName +
				"')><input type=button value=保存 onclick=SaveExp('" +FieldName + "')>", 
				{title:"设置公式(列名：" + FieldName.toUpperCase() + ")", mask:50, width:500, height:300});

//			HTMLDlgBox("设置公式(列名：" + FieldName.toUpperCase() + ")", "<textarea id=ColExpText style=width:100%;height:240>" + ImportInfo[x].exp + 
//				"</textarea><input type=button value=运行 onclick=RunExp('" + FieldName +
//				"')><input type=button value=保存 onclick=SaveExp('" +FieldName + "')>", "width=500,height=300");
			break;
		}
	}
	if (x == ImportInfo.length)
		return alert("请先设置选择列");
}

function SaveExp(FieldName)
{
	for (var x = 0; x < ImportInfo.length; x++)
	{
		if (ImportInfo[x].col == FieldName)
		{
			ImportInfo[x].exp = document.all.ColExpText.innerText;
			alert("OK");
			break;
		}
	}
}

function RunExp(FieldName)
{
	var objs = view.getsel().getShadow();
	if ((objs.length <= 0) || (objs[0].obj.tagName == "TR"))
		return alert("未先选择列");
	var exp = document.all.ColExpText.innerText;
	var index, value, returnValue;
	for (var x = 0; x < objs.length; x++)
	{
		index = objs[x].obj.parentNode.rowIndex;
		value = dataObj[index][FieldName];
		returnValue = "";
		switch (exp.substr(0, 1))
		{
		case "=":
			value = eval(exp.substr(1));
			break;
		case "!":
			eval(exp.substr(1));
			value = returnValue;
			break;
		default:
			value = exp;
			break;
		}
		view.setCell(index, FieldName, value);
	}
}

function DelBlankData()
{
	var objs = view.getsel().getShadow();
	for (var x = 0; x < objs.length; x++)
	{
		if (objs[x].obj.tagName == "TD")
		{
			var index = objs[x].obj.parentNode.rowIndex;
			var FieldName = objs[x].obj.id.split("_")[0];
			value = dataObj[index][FieldName].replace(/\s/g, "");
			view.setCell(index, FieldName, value);
		}
		if (objs[x].obj.tagName == "TR")
		{
			for (var y = 0; y < objs[x].obj.cells.length; y++)
			{
				var index = objs[x].obj.rowIndex;
				var FieldName = objs[x].obj.cells[y].id.split("_")[0];
				value = dataObj[index][FieldName].replace(/\s/g, "");
				view.setCell(index, FieldName, value);
			}
		}
	}
}


function FillData()
{
	var objs = view.getsel().getShadow();
	if ((objs.length <= 0) || (objs[0].obj.tagName == "TR"))
		return alert("未先选择列");
	var obj = cellshadow.getObj();
	if (typeof obj == "undefined")
		return alert("未选择单元格");
	var FieldName = objs[0].obj.id.split("_")[0];
	var value = obj.innerText;
	for (var x = 0; x < objs.length; x++)
	{
		index = objs[x].obj.parentNode.rowIndex;
		view.setCell(index, FieldName, value);
	}
}

function SetDateFmt(FieldName)
{
	if (FieldName == undefined)
	{
		var objs = view.getsel().getShadow();
		if ((objs.length <= 0) || (objs[0].obj.tagName == "TR"))
			return alert("未先选择列");
		FieldName = objs[0].obj.id.split("_")[0];
	}
	for (var x = 0; x < dataObj.length; x++)
	{
		if (x == titleIndex)
			continue;
		var value = $.jcom.makeDateObj(dataObj[x][FieldName]);
		if ((value == null) || (isNaN(value)))
			value = "";
		else
		{
			value =  $.jcom.GetDateTimeString(value, 1);
		}
		dataObj[x][FieldName + "_old"] = dataObj[x][FieldName];
		dataObj[x][FieldName] = value;
	}
	if (reloadFlag)
		view.reload();
	
}

function AddLine()
{
	var o = $.jcom.initObjVal(dataObj[0], {});
	for (var key in o)
		o[key] = "";
	o.Num = {value:"?", tdstyle:"background-color:#78BCED",divstyle:"color:white;"};
	var sel = view.getSelRow();
	if (parseInt(sel.node) == titleIndex)
	{
		dataObj[titleIndex].Num.value = titleIndex;
		view.insertRow(o, 0);
	}
	else
		view.insertRow(o);
	view.reload(view.getData());
}

function AddCol()
{
	var head = view.getHead();
	var o = {};
	var key = String.fromCharCode(head[head.length - 1].FieldName.charCodeAt(0) + 1);
	o.FieldName = key;
	o.TitleName = "<div id=" + key + "_Field style='width:100%;overflow:hidden;'>未设置</div>" + key.toUpperCase();
	o.nShowMode = 1; 
	o.nWidth = 80;
	for (var x = 0; x < dataObj.length; x++)
		dataObj[x][key] = "";
	view.insertCol(o);
	view.reload(view.getData(), head);
	SetHeadEditor();
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

function SelectCol(e)
{
	var td = $.jcom.findParentObj(e.target, document.body, "TD");
	if (td == undefined)
		return;
	view.selCol(td.cellIndex);
}

function DeleteRow()
{
	view.deleteRow();
	view.reload();

}

function CheckGrid()
{
	var bdef = false;
	for (var x = 0; x < ImportInfo.length; x++)
	{
		if (typeof ImportInfo[x].field != "undefined")
		{
			bdef = true;
			for (var y = titleIndex + 1; y < dataObj.length; y++)
			{
				var cell = view.getCell(y, ImportInfo[x].col);
				var result = CheckValue(dataObj[y][ImportInfo[x].col], fieldObj[ImportInfo[x].index]);
				if ( result != "OK")
				{
					cell.firstChild.style.color = "red";
					cell.firstChild.title = result;
				}
				else
				{
					cell.firstChild.style.color = "black";
					cell.firstChild.title = "";
				}
			}
		}
	}
	if (bdef == false)
		alert("字段未定义");
}

function CheckValue(value, field)
{
	if (value == "")
		return "OK";
	value = ConvertValue(value, field);
	switch (field.FieldType)
	{
	case 1:		//文本
		if (value.length > field.FieldLen)
			return "数据超长:" + value.length + ">" + field.FieldLen;
		break;
	case 2:		//备注
		break;
	case 3:		//数字
	case 5:		//自动编号
	case 6:		//单精度浮点
	case 7:		//双精度浮点
		if (isNaN(Number(value)))
			return "数字类型格式不对";	
		break;
	case 4:		//日期
		var r = /\d{4}-\d{2}-\d{2}/;
		if (r.test(value) == false)
			return "日期格式不对";
		break;
	case 8:		//二进制
		break;
	case 9:		//是/否
		break;
	case 10:	//货币
		break;
	case 11:	//GUID
		break;
	}
	return "OK";
}

function ConvertValue(value, field)
{
	if (typeof field.editor != "object")
		return value;
	if (typeof field.editor.getData != "function")
		return value;
	var data = $.trim(field.editor.getData());
	var ss = data.split(",");
	for (var x = 0; x < ss.length; x++)
	{
		var sss = ss[x].split(":");
		if (sss.length > 1)
		{
			if ((sss[1] == value) || (ss[x] == value) || (sss[0] == value))
				return sss[0];
		}
	}
	return value;
}

function ImportNew()
{
	if (typeof document.all.ImportFrame == "object")
		document.all.ImportFrame.removeNode(true);
	document.body.insertAdjacentHTML("beforeEnd", "<iframe id=ImportFrame style=display:none></iframe>");
	var doc = document.all.ImportFrame.contentWindow.document;
	doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
		"</head><body><form id=ImportForm method=post action=infile.jsp?SaveFlag=1" +
		" enctype=multipart/form-data target=IFrameDlg><input name=FieldInfo><input name=ImportInfo>" +
		"<input type=file name=LocalName onchange=parent.StartInNewFile()></form></body></html>");
	doc.charset = "gbk";
	doc.all.FieldInfo.value = JSonString(fieldObj);
	doc.all.ImportInfo.value = JSonString(ImportInfo);
	doc.all.LocalName.click();
}

function ImportLocal()
{
	var o = document.createElement("<input type=file>");
	document.body.insertAdjacentElement("beforeEnd", o);
	o.style.display = "none";
	o.onchange = function ()
	{
		if (o.value != "")
			ImportLocalFile(o.value);
		o.onchange = null;
		$(o).remove();
	}
	o.click();
}

function ImportLocalFile(file)
{
	if (file.substr(file.length - 3).toLowerCase() == "xls")
		ImportExcel(file);
	else
		ImportWord(file);
}

var excel, oUpload;
function ImportExcel(file)
{
	if (typeof excel != "object")
	{
		try
		{
			excel = new ActiveXObject("Excel.Application");
//			excel.Visible = true;
			window.onbeforeunload = QuitOffice;
		}
		catch (e)
		{
			alert("未能打开本地的OFFICE程序。" + e.description);
			return false;
		}
		oUpload =  new $.jcom.FileUpload();
		oUpload.progress = UploadEvent;		
	}
	var book = excel.Workbooks.Open(file);  
	var sheet = book.Sheets(1);
	var rows = sheet.UsedRange.Rows.Count;
	var cols = sheet.UsedRange.Columns.Count;
	if (cols > 100)
		cols = 100;
	var cnt = 0;
	var datalist = [];
	for (var y = 0; y < rows; y++)
	{
		datalist[y] = {};
		for (var x = 0; x < cols; x++)
		{
		
			try
			{
				var cell = sheet.UsedRange.Cells(y + 1, x + 1);
			}
			catch (e)
			{
				window.status = (y + "-" + x + e.description);
//				continue;
			}
			var text = cell.Text.replace(/[\s\7]+/g, "");
			datalist[y][GetColName(x)] = text;
		}
	}
	if (window.confirm("是否要导入EXCEL文件中的图片？"))
		GetExcelImage(sheet, datalist);
	var head = GetHead(datalist);
	for (var x = 0; x < datalist.length; x++)
		datalist[x].Num = {value:x, tdstyle:"background-color:#78BCED",divstyle:"color:white;"};
	datalist[titleIndex].Num.value = "标题";
	
	view.reload(datalist, head);
	book.Close(false);
	excel.Workbooks.Close();
	dataObj = datalist;
	SetHeadEditor();

	if (typeof UserOnload == "function")
		UserOnload();
	FormatImportInfo(ImportInfo);
	$("#FileNameSpan").html("源文件:(" + file + ")");
}

var ImageList;
function GetExcelImage(sheet, datalist)
{
//	var path = "C:\\TMP\\TMP\\";
	var fso = new ActiveXObject("Scripting.FileSystemObject");
	var path = fso.GetSpecialFolder(2).Path + "\\";
	ImageList = [];
	for (var x = 1; x <= sheet.Shapes.Count; x++)
	{
		ImageList[x - 1] = {};
		var shape = sheet.Shapes.Item(x);
		var row = shape.TopLeftCell.Row - 1;
		var col = shape.TopLeftCell.Column - 1;
		var colname = GetColName(col);
		if (datalist[row][colname] != "")
		{
			col++;
			colname = GetColName(col);
		}
		var Name = row + "_" + col + ".jpg";
		ImageList[x - 1].path = path + Name;
		ImageList[x - 1].filename = Name;
		ImageList[x - 1].FileSize = "";
		ImageList[x - 1].upsize = 0;
		ImageList[x - 1].rate = 0;
		ImageList[x - 1].Info = ""; 
		ImageList[x - 1].row = row;
		ImageList[x - 1].colname = colname;
		datalist[row][colname] = path + Name;
		datalist[row][colname + "_ex"] = "<img src='" + path + Name + "'>";
		shape.CopyPicture(1, 2);
		var ocx = oUpload.getocx();
		var result = ocx.GetClipboardImg(path + Name);
//		var chart = sheet.ChartObjects.Add(0, 0, shape.Width + 5, shape.Height + 5).Chart;
//		chart.Paste();
//		chart.Export(path + shape.Name, "JPG");
//		chart.Parent.Delete();
	}
}

function ImportWord()
{
}

function GetColName(x)
{
	var name = String.fromCharCode(97 + (x % 26));
	var y = parseInt(x / 26);
	if (y > 0)
		name = String.fromCharCode(96 + y) + name;
	return name;
}

function QuitOffice()
{
	if (typeof word == "object")
		word.Quit();
	if (typeof excel == "object")
		excel.Quit();
}

function SaveAsExcel()
{
	if (typeof document.all.ImportFrame == "object")
		document.all.ImportFrame.removeNode(true);
	document.body.insertAdjacentHTML("beforeEnd", "<iframe id=ImportFrame style=display:none></iframe>");
	var doc = document.all.ImportFrame.contentWindow.document;
	doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
		"</head><body><form id=ImportForm method=post action=infile.jsp?ExportFlag=1><input type=text name=TableName value=" + TableName + ">" +
		"<textarea name=data></textarea></form></body></html>");
	doc.charset = "gbk";
	var data = "";
	for (x = titleIndex; x < dataObj.length; x++)
	{
		var sp = "";
		for (var key in dataObj[x])
		{
			if (key == "Num")
				continue;
			if (dataObj[x][key].indexOf(",") >= 0)
				data += sp + "\"" + dataObj[x][key] +"\"";
			else
				data += sp + dataObj[x][key];
			sp = ",";
		}
		data += "\n";
	}
	doc.all.data.value = data;
	document.all.ImportFrame.contentWindow.document.all.ImportForm.submit();
}

function StartInNewFile()
{
	document.all.ImportFrame.contentWindow.document.all.ImportForm.submit();
}

function JSonString(o)
{
	var s = "";
	for (var x = 0; x < o.length; x++)
	{
		var ss = "";
		for (var key in o[x])
		{
			if (typeof o[x][key] != "undefined")
			{
				if (ss != "")
					ss += ",";
				switch (typeof o[x][key])
				{
				case "number":
					ss += key + ":" + o[x][key];
					break;
				default:
					ss += key + ":\"" + o[x][key] + "\"";
					break;
				}
			}
		}
		if (s != "")
			s += ",";
		s += "{" + ss + "}";
	}
	return "[" + s + "]";
}

function OutSQL()
{
	var x, y, value, sql1, sql2, sql = "";
	for (y = titleIndex + 1; y < dataObj.length; y++)
	{
		sql1 = "";
		sql2 = "";
		for (x = 0; x < ImportInfo.length; x++)
		{
			if (typeof ImportInfo[x].field != "undefined")
			{
				value = ConvertValue(dataObj[y][ImportInfo[x].col], fieldObj[ImportInfo[x].index]);
				if (sql1 != "")
					sql1 += ",";
				sql1 += fieldObj[ImportInfo[x].index].FieldName;
				if (sql2 != "")
					sql2 += ",";
				sql2 += GetSQLValue(value, fieldObj[ImportInfo[x].index].FieldType);
			}
		}
		if (sql1 == "")
			return alert("请先设置字段");
		sql += "insert into " + fieldObj[0].TableName + "(" + sql1 + ") values (" + sql2 + ")\n";
	}
//	HTMLDlgBox("outerSQL", "<textarea id=SQLOutText style=width:100%;height:240>" + sql + 
//		"</textarea><input type=button onclick=seltxt(this) value=全选><input type=button value=复制 onclick=copytext(this)>", "width=500,height=300");
	new $.jcom.PopupWin("<textarea id=SQLOutText style=width:100%;height:240>" + sql + 
		"</textarea><input type=button onclick=seltxt(this) value=全选><input type=button value=复制 onclick=copytext(this)>", 
			{title:"outerSQL", mask:50, width:500, height:300});
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

function GetSQLValue(value, FieldType)
{
	switch (FieldType)
	{
	case 1:		//文本
	case 2:		//备注
		return "'" + value + "'";
	case 3:		//数字
	case 5:		//自动编号
	case 6:		//单精度浮点
	case 7:		//双精度浮点
	case 10:	//货币
		if (value == "")
			return "null";
		return value;
	case 4:		//日期
		if (value == "")
			return "null";
	case 8:		//二进制
		break;
	case 9:		//是/否
		break;
	case 11:	//GUID	return value;
		if (value == "")
			return "null";
	}
	return "'" + value + "'";
}

function RunImport()
{
	if (typeof UserRunImport == "function")
	{
		if (UserRunImport() == false)
			return;
	}
	RunUploadImage()
}

function RunUploadImage()
{
	var obj = $("#RunButton")[0];
	if (obj.value != "再次导入")
	{
		if (UploadPhoto() == false)
			return false;
	}
	RunImportForm();
}

function RunImportForm()
{
	var obj = $("#RunButton")[0];
	var x, y, index, value, data1 = "", data2 = "", data3 = "";
	var flag = 0;
	if (obj.value == "再次导入")
	{
		if (window.confirm("再次导入是否仅导入未成功的记录？") == true)
			flag = 1;
	}
	for (x = 0; x < ImportInfo.length; x++)
	{
		if (typeof ImportInfo[x].field != "undefined")
		{
			index = ImportInfo[x].index;
			data1 += "&FieldName=" + fieldObj[index].FieldName + "&FieldType=" + fieldObj[index].FieldType +
				"&bUnique=" + fieldObj[index].bUnique;
			for (y = titleIndex + 1; y < dataObj.length; y++)
			{
				value = ConvertValue(dataObj[y][ImportInfo[x].col], fieldObj[index]);
				data2 += "&" + fieldObj[index].FieldName + "=" + escape(escape(value));
			}
		}
	}
	if (data1 == "")
		return alert("请先设置字段");
	if (typeof ExFields != "undefined")
	{
		for (x = 0; x < ExFields.length; x++)
			data3 += "&ExField=" + ExFields[x].field + "&ExType=" + ExFields[x].extype + "&" + ExFields[x].field + "=" + ExFields[x].value; 
	}
	obj.disabled = true;
	obj.value = "正在导入...";
	$.jcom.Ajax(location.pathname + "?RunFlag=1", true, "TableName=" + fieldObj[0].TableName + data1 + data2 + data3, RunResult);
}

function RunResult(data)
{
	document.all.RunButton.value = "再次导入";
	document.all.RunButton.disabled = false;
	var result = eval(data);
	var fails = 0, oks = 0;
	for (var x = 0; x < result.length; x++)
	{
		dataObj[x].Num.result = result[x];
		var cell = view.getCell(titleIndex + 1 + x, "Num");
		if (result[x] >=0)
		{
			cell.style.backgroundColor = "green";
			oks ++;
		}
		else
		{
			cell.style.backgroundColor = "red";
			fails ++;
		}
	}
	alert("导入完成，共导入记录" + result.length + "条，其中成功:" + oks + "条，失败:" + fails + "条");
}

function OutImportInfo()
{
//	HTMLDlgBox("字段定义描述", "<textarea id=ImportText style=width:100%;height:240>" + JSonString(ImportInfo) + 
//		"</textarea><input type=button onclick=seltext(this) value=全选><input type=button value=复制 onclick=copytext(this)>" +
//		"<input type=button value=粘贴 onclick=pasteinfo(this)><input type=button value=加载 onclick=LoadImportInfo(this)>"+
//		"提示:将上述描述保存,可方便以后导入类似的文档。", "width=500,height=300");
	new $.jcom.PopupWin("<textarea id=ImportText style=width:100%;height:240>" + JSonString(ImportInfo) + 
		"</textarea><input type=button onclick=seltext(this) value=全选><input type=button value=复制 onclick=copytext(this)>" +
		"<input type=button value=粘贴 onclick=pasteinfo(this)><input type=button value=加载 onclick=LoadImportInfo(this)>"+
		"提示:将上述描述保存,可方便以后导入类似的文档。", 
			{title:"字段定义描述", mask:50, width:500, height:300});

}

function pasteinfo(obj)
{
	var o = document.all.ImportText;
	o.focus();
	o.select();
	var oRange = o.createTextRange();
	oRange.execCommand("Paste");
}

function LoadImportInfo(obj)
{
	var txt = document.all.ImportText.innerText;
	try {
			ImportInfo = eval(txt);
			FormatImportInfo(ImportInfo);
			alert("加载成功");
		} catch (e) 
		{
			alert("加载失败");
		}
}

var upwin, upview, upokcnt = 0;
function UploadPhoto()
{
	if ((ImageList == undefined) || (ImageList.length == 0))
		return true;
	if (oUpload == undefined)
	{
		oUpload =  new $.jcom.FileUpload();
		oUpload.progress = UploadEvent;
	}

	if (upwin == undefined)
	{
		upwin = new $.jcom.PopupWin("<div id=UploadGrid style=width:100%;height:100%></div>", 
			{title:"上传文件", mask:50, width:740, height:400});
		upwin.CloseWin = upwin.close;
		upwin.close = upwin.hide;
		upview = new $.jcom.GridView($("#UploadGrid")[0], [{FieldName:"filename", TitleName:"名称", nWidth:320, nShowMode:9},
			{FieldName:"FileSize", TitleName:"长度", nWidth:60, nShowMode:1},
			{FieldName:"upsize", TitleName:"已上传", nWidth:60, nShowMode:1},
			{FieldName:"rate", TitleName:"进度", nWidth:40, nShowMode:1},
			{FieldName:"info", TitleName:"信息", nWidth:200, nShowMode:1}], ImageList,{},{footstyle:4, initDepth:100});
	}
	else
		upwin.show();
	UploadNext();
	upokcnt = 0;
	return false;
}

function UploadEvent(evt, param1, param2)
{
	var uploadid = parseInt(param1);
	var uploadid = parseInt(param1);
	var node = upview.findNode("uploadid", uploadid);
	var item = upview.getItemData(node);
	switch (evt)
	{
	case "SendFileBegin":
		break;
	case "SendFileProgress":
		break;
	case "SendFileOK":
		var ss = param2.split(":");
		if (ss[0] != "OK")
			return alert(param2);
		var index = getGridRowNo(ImageList[node].row);
		dataObj[index][ImageList[node].colname] = "../com/down.jsp?AffixID=" + ss[1];		
//		upview.setCell(node, "upsize", item.FileSize);
//		upview.setCell(node, "rate", "100%");
		upview.setCell(node, "info", "上传完成");
		item.uploadid = -1;
		upokcnt ++;
		UploadNext();		
		
		break;
	case "SendFileFail":
		oUpload.stop(param1);
		upview.setCell(node, "info", "上传失败。(" + param2 + ")");
		break;
	case "SendFileCancel":
		upview.setCell(node, "info", "上传被服务器拒绝");
		break;
	}
}
function getGridRowNo(num)
{
	for (var x = 0; x < dataObj.length; x++)
	{
		if (dataObj[x].Num.value == num)
			return x;
	}
}
function UploadNext()
{
	for (var x = 0; x < ImageList.length; x++)
	{
		if (ImageList[x].uploadid == undefined)
		{
			ImageList[x].uploadid = oUpload.upfile(ImageList[x].path, {DestDir:"Form", saveto: "表单Office文档"});
			if (ImageList[x].uploadid < 0)
				upview.setCell(x, "info", "上传文件失败:" + ImageList[x].uploadid);
			else
			{
				upview.setCell(x, "info", "正在上传..." + ImageList[x].uploadid);
				return false;
			}
		}
	}
	upwin.CloseWin();
	RunImportForm();
	return true;
}
</script>
<%
	out.println("</body>");
	out.println("</html>");
	jdb.closeDBCon();
%>