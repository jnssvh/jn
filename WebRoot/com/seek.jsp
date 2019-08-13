<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
//<script type="text/javascript">
var oPop;
var oMenu;
//var seekdir = psubdir;
var oPop = null;

function ExSeekFunction(obj)
{
	if ((typeof submenudef != "object") || (RightButtonMenu() == true))
		return true;
	if (obj.tagName == "TABLE")
	{
		obj = GetTableEventTR(obj);
		if (obj == null)
		return true;
	}
//	if (typeof(obj.TableDefID) == "undefined")
//		oMenu = document.all.SeekUserDefineMenu;
//	else
//		oMenu = document.all.SeekUserDefineMenuEx;
	if (obj.selflag != 1)
		obj.click();
	var evt = getEvent();
	obj.ClickTD = evt.srcElement;
    var e = document.createEventObject();
    e.button = 2;
    e.srcElement = evt.srcElement;
	obj.ClickTD.fireEvent("onclick", e);
	window.sysmenu = new CommonMenu(submenudef);
	var hit = TestCurrentObj();
	if (typeof(RMenuFilter) == "function")
	{
		var filter = RMenuFilter(hit);
		sysmenu.setMenuFilter(filter);
	}
	sysmenu.show();
	return false;
}

function TestCurrentObj(obj)
{
	if (typeof obj == "undefined")
		obj = oFocus;
	if (typeof obj != "object")
		return 0;
	if (obj.tagName == "TR")
		return 1;
	if (objall(obj, "BtExTree") != null)
		return 2;
	return 3;
}


function TableKeySeek(key, param)
{
	location.href = AppendURLParam(href, "ViewMode=" + ViewMode + "&SeekKey=" + key +"&SeekParam=" + param +
		"&OrderField=" + OrderField + "&bDesc=" + bDesc);
}

function SetOrder(oTD)
{
var desc;
	if (objattr(oTD, "bDesc") == 0)
		desc = "&bDesc=1";
	else
		desc = "";
			
	location.href = AppendURLParam(href, "ViewMode=" + ViewMode + "&OrderField=" + escape(objattr(oTD, "node")) + desc +
		"&SeekKey=" + SeekKey + "&SeekParam=" + SeekParam);
	
}

function GetFocusObj(obj)
{
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
		{
			if (typeof(frame.contentWindow.oFocus) == "object")
				return frame.contentWindow.oFocus;
		}
		return oFocus;
	}
	return obj;
}

function NewRecord(sFeatures, nWinMode, param)
{
	if (FormAction == "")
		return alert("<j:Lang key="seek.No_form"/>");
	if (typeof param == "string")
	{
		if (FormAction.indexOf("?") == -1)
			param = "?" + param;
		else
			param = "&" + param;
	}
	else
		param = "";
	nWinMode = GetWinMode(nWinMode);
	sFeatures = GetWinFeatures(sFeatures);
	oNewWin = NewHref(FormAction + param, sFeatures, "_blank", nWinMode);
	CheckDocUpdate();
}

function EditRecord(obj, sFeatures, nWinMode)
{
	if (FormAction == "")
		return alert("<j:Lang key="seek.No_form"/>");
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
		{
			if (typeof(frame.contentWindow.oFocus) == "object")
				return frame.contentWindow.EditRecord(0, sFeatures, nWinMode);
		}
		obj = GetSelectRow()
//		obj = oFocus;
	}
	if (typeof(obj) != "object")
		return alert("<j:Lang key="seek.Slect_biaolist"/>");
	obj.click();
	if (objattr(obj, "TableDefID") != null)
	{
		if (objattr(obj, "TableDefID") == 0)
			return alert("<j:Lang key="seek.Check_select"/>");
		TableDefID = objattr(obj, "TableDefID");
	}
	nWinMode = GetWinMode(nWinMode);
	sFeatures = GetWinFeatures(sFeatures);
	var Action = FormAction;
	if (FormAction.indexOf("?") == -1)
		Action += "?DataID=" + objattr(obj, "node");
	else
		Action += "&DataID=" + objattr(obj, "node");
	oNewWin = NewHref(Action, sFeatures, "_blank", nWinMode);
//	CheckDocUpdate();
	return true;
}

function GetWinFeatures(f)
{
	if ((typeof(f) != "string") || (f == ""))
	{
		if ((typeof(FormFeatures) == "string") && (FormFeatures != ""))
			return FormFeatures;
		else
			return "titlebar=0,toolbar=0,scrollbars=0,resizable=1,scrollbars=1,width=640,height=200,left=50,top=50";
	}
	return f;
}

function GetWinMode(nMode)
{
	if (typeof(nWinMode) != "undefined")
		return nMode;
	if (typeof(nDefaultWinMode) != "undefined")
		return nDefaultWinMode;
	return 2;
}

function PrintTable()
{
	oNewWin = NewHref(AppendURLParam(href, "ActionType=3&SeekKey=" + SeekKey + "&SeekParam=" + SeekParam + "&OrderField=" +
		OrderField + "&bDesc=" + bDesc + "&ViewMode=" + ViewMode),
		"menubar=0,toolbar=0,location=0,status=0,resizable=1,width=800,height=600,left=50,top=50,scrollbars=1");
}

function ExecWeb(nCommand)
{
	idobj("MenuBarTable").style.display = "none";
	idobj("WBobj").ExecWB(nCommand, 1);
	idobj("MenuBarTable").style.display = "inline";
}

function ViewRecord()
{
var Action
	if (FormViewAction == "")
		return alert("没有定义与查询对应的查看表单");
	
	var Action = FormViewAction;
	if (Action.indexOf("?") == -1)
		Action += "?DataID=";
	else
		Action += "&DataID=";
	RunTableRecord(Action);
}

function RunTableRecord(href, hint, sFeatures, nWinMode)
{
	nWinMode = GetWinMode(nWinMode);
	sFeatures = GetWinFeatures(sFeatures);
	var obj = GetSelectRow()
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
			frame.contentWindow.RunTableRecord(href, hint, sFeatures, nWinMode);
		else
		{
			if (hint == "force")
			{
				oNewWin = NewHref(href + "0", sFeatures, "_blank", bNBWin);
				return true;
			}	
			alert("<j:Lang key="seek.Slect_biaolist"/>");
			return false;
		}
	}
	if ((typeof(hint) != "undefined") && (hint != ""))
	{
			if (window.confirm(hint) == false)
				return;
	}
	obj.click();
	oNewWin = NewHref(href + objattr(obj, "node"), sFeatures, "_blank", nWinMode);
	return true;
}

function DoTableRecord(href)
{
	var obj = GetSelectRow()
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
			return frame.contentWindow.DoTableRecord(href);
		else
			return alert("<j:Lang key="seek.Slect_biaolist"/>");
	}
	obj.click();
	location.href = href + objattr(obj, "node");
}

function ExecTableRecord(href)
{
	var obj = GetSelectRow()
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
			return frame.contentWindow.ExecTableRecord(href);
		else
			return alert("<j:Lang key="seek.Slect_biaolist"/>");
	}
	eval(href);
}

function TableExec(href, sFeatures)
{
	if (typeof(sFeatures) != "undefined")
		oNewWin = NewHref(href, sFeatures);
	else
		oNewWin = NewHref(href, "resizable=1,width=640,height=480,left=50,top=50");
}

function DeleteRecord(obj)
{
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
		{
			if (typeof frame.contentWindow.oFocus == "object") {
				return frame.contentWindow.DeleteTableRecord();
			}
		}
		var nodes = GetSelectNode().split(",");
		if (nodes.length > 0) {
			return TableBatchAction(1);
		}
		obj = GetSelectRow()
	}
	if (typeof(obj) != "object")
		return alert("<j:Lang key="seek.Slect_biaolist"/>");
	oFocus = obj;
	return TableBatchAction(1);
}

function DeleteTableRecord(obj, bAjaxMode, QuoteField)
{
var TableID = TableDefID, quote;
	if (typeof(obj) != "object")
	{
		var frame = idobj("SubSeekFrame");
		if (frame != null)
		{
			if (typeof frame.contentWindow.oFocus == "object")
				return frame.contentWindow.DeleteTableRecord();
		}
		var nodes = GetSelectNode().split(",");
		if (nodes.length > 0)
			return TableBatchAction(1);
		obj = GetSelectRow()
//		obj = oFocus;
	}

	if (typeof(obj) != "object")
		return alert("<j:Lang key="seek.Slect_biaolist"/>");
	if (objattr(obj, "TableDefID") != null)
	{
		if (objattr(obj, "TableDefID") == 0)
		{
			alert("<j:Lang key="seek.Check_onedelete"/>");
			return;
		}
		TableID = objattr(oFocus, "TableDefID");
	}

	if (confirm("<j:Lang key="seek.Check_delete"/>") == false)
		return;
	if (typeof(QuoteField) == "string")
		quote = "&QuoteField=" + QuoteField;
	else
		quote = ""
	if (typeof(bAjaxMode) == "undefined")
		oNewWin = NewHref("DeleTableRecord.asp?TableDefID=" + TableID + "&ID=" + objattr(obj, "node") + quote,
			"menubar=0,toolbar=0,location=0,status=0,width=320,height=80,left=50,top=50,scrollbars=0");
	else
			AjaxRequestPage("DeleTableRecord.asp?TableDefID=" + TableID + "&ID=" + objattr(obj, "node") + quote, bAjaxMode);
	obj.removeNode(true);
	return true;
}

function TableMenuComplexSeek(param)
{
	if (typeof(param) == "string")
			location.href = AppendURLParam(href, "ViewMode=" + ViewMode + param);
	else
	{
		PopMenuItem();
		var Action = AppendURLParam(href, "ComplexSeek=1");
		NewFrameWin(Action, "Width=480px,Height=315px,scroll=0;");
	}

}

function TableWholeDocSeek(param, seekkey)
{
	if (typeof(param) == "undefined")
	{

		InlineHTMLDlg("查询", "<br>&nbsp;请输入全文检索关键字：<br><br><center><div><input id=InlineInputObj type=text></div>" + 
			"<BR><BR><input type=button id=TableWholeDocSeekButton value=确定>&nbsp;&nbsp;" +
			"<input type=button onclick=CloseInlineDlg() value=取消>&nbsp;&nbsp;" +
			"<input type=button onclick=CloseInlineDlg();TableMenuComplexSeek() value=更多></center>", 300, 200);
		var input = idobj("InlineInputObj");
		window.oSearch.insert(input);
		window.oSearch.oEdit.lastChild.style.display = "none";
		window.oSearch.oEdit.style.width = "200px";
		input.parentNode.removeChild(input);
		idobj("TableWholeDocSeekButton").onclick = function ()
		{
			window.oSearch.oEdit.lastChild.click();
		}
		return;
	}
	if (param == "")
		return TableKeySeek("", "");
	if (typeof seekkey != "string")
		seekkey = "$WholeDoc$";
	if (typeof(param) == "string")
	{
		if (param.length > 50)
			param = param.substr(0, 50);
		if (typeof SeekParamEx == "string" && SeekParamEx != "")
			param = param + "||" + SeekParamEx.replace(/\?/g, param);
		location.href = AppendURLParam(href, "ViewMode=" + ViewMode + "&SeekKey=" + seekkey + "&SeekParam=" + param);
	}
}

function SearchTable(obj)
{
	
}

function UserImportData(cinc)
{
	var fun = function(FieldInfo)
	{
		var frame = idobj("ImportFrame");
		if (frame != null)
			frame.parentNode.removeChild(frame);
		document.body.insertAdjacentHTML("beforeEnd", "<iframe id=ImportFrame style=display:none></iframe>");
		frame = idobj("ImportFrame");
		var doc = frame.contentWindow.document;
		doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
			"</head><body><form id=ImportForm method=post action=../com/infile.jsp?SaveFlag=1" +
			" enctype=multipart/form-data target=ImportWin><input name=FieldInfo><input name=ImportInfo>" +
			"<input name=cinc value='" + cinc + "'></form></body></html>");
		doc.charset = "gbk";
		idobj("FieldInfo", doc).value = FieldInfo;
		if (typeof ImportInfo == "string")
			idobj("ImportInfo", doc).value = ImportInfo;
		idobj("ImportForm", doc).submit();
	};
	AjaxRequestPage(location.pathname + "?GetFieldInfo=1", true, "", fun);
	window.open("../com/blank.htm", "ImportWin");
}

function ImportData(FieldInfo)
{
	if (typeof FieldInfo != "string")
		return AjaxRequestPage(location.pathname + "?GetFieldInfo=1", true, "", ImportData);
	var frame = idobj("ImportFrame");
	if (frame != null)
		frame.parentNode.removeChild(frame);
	document.body.insertAdjacentHTML("beforeEnd", "<iframe id=ImportFrame style=display:none></iframe>");
	frame = idobj("ImportFrame");
	var doc = frame.contentWindow.document;
	doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
		"</head><body><form id=ImportForm method=post action=../com/infile.jsp?SaveFlag=1" +
		" enctype=multipart/form-data target=IFrameDlg><input name=FieldInfo><input name=ImportInfo>" +
		"<input type=file name=LocalName onchange=parent.StartImportFile()></form></body></html>");
	doc.charset = "gbk";
	idobj("FieldInfo", doc).value = FieldInfo;
	if (typeof ImportInfo == "string")
		idobj("ImportInfo", doc).value = ImportInfo;
	idobj("LocalName", doc).click();
}

function StartImportFile()
{
	var doc = idobj("ImportFrame").contentWindow.document;
	if (idobj("LocalName", doc).value != "")
	{
		NewFrameWin("about:blank", "width=640,height=480,resizable=1", "");
		idobj("ImportForm", doc).submit();
	}
}

function TableMenuSeek(obj, param)
{
var value;
	var evt = getEvent();
	evt.cancelBubble = true;
	if (typeof(obj) == "object")
		value = objattr(obj.parentNode.parentNode, "node");
	else
		value = obj;

	if (param == "@@SeleDate@@")
	{
		param = SelectDate();	
		if (typeof(param) != "string")
			return;
	}
	if (param == "@@DateRange@@")
	{
		param = window.showModalDialog("SeleDateRange.htm", "", 
			"dialogWidth:420px;dialogHeight:180px;status:0;help:0");
		if (typeof(param) != "string")
			return;
	}
	if (param == "@@more@@")
	{
		param = prompt("<j:Lang key="psub.Chaxun_guanjizi"/>", "");
		if (typeof(param) != "string")
			return;
	}
	TableKeySeek(value, param)
}

function SeekItem(TableName, FieldName, FieldCName, QuoteTable)
{
	var	param = window.showModalDialog(psubdir + "SeekKey.jsp?TableName=" + TableName + "&FieldName=" +FieldName +
			"&FieldCName=" + FieldCName + "&QuoteTable=" + QuoteTable, "", 
			"status:0;dialogWidth:520px;dialogHeight:300px;help:0;scroll:0");
		if (typeof(param) != "string")
			return;
	TableKeySeek(FieldName, param)
}

function SeleTableView(ViewMode)
{
	location.href = AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam + "&OrderField=" + OrderField +
		"&bDesc=" + bDesc + "&ViewMode=" + ViewMode);
}

function getXmlHttpObject() {
	var xmlHttp = null;
	try {
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
	} catch (e) {
		try {
			xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				xmlHttp = new XMLHttpRequest();;
			} catch (e) {
				alert("无法获取ajax对象，请与管理员联系");
			}
		}
	}
	return xmlHttp;
}

var bTotal = 0;
function TotalSeek()
{
var oTR, oTD, x, y, t;
	if (bTotal == 1)
		return;
	bTotal = 1;
	var table = idobj("SeekTable");
	if (table == null)
		return;
	oTR = table.insertRow();
	oTR.bgColor = table.rows[0].bgColor;
	for (x = 0; x < table.rows[0].cells.length; x++)
	{
		oTD = oTR.insertCell();
		if (table.rows[0].cells[x].bTotal == 1)
		{
			for (y = 1, t = 0; y < table.rows.length; y++)
			{
				if (table.rows[y].cells.length == table.rows[0].cells.length)
				{
					if (!isNaN(parseFloat(objtext(table.rows[y].cells[x]))))
						t += parseFloat(objtext(table.rows[y].cells[x]));
				}
			}
			oTD.innerHTML = t;
		}		
	}
	AjaxRequestPage(AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam + "&bTotal=1"), true, "", AJAXComplete)
}

function AJAXComplete(data)
{
var oTR, oTD, x, y, t;
	t = data.split(",");
	var table = idobj("SeekTable");
	oTR = table.insertRow();
	oTR.bgColor = table.rows[0].bgColor;
	for (x = 0, y = 0; x < table.rows[0].cells.length; x++)
	{
		oTD = oTR.insertCell();
		if (table.rows[0].cells[x].bTotal == 1)
		{
			oTD.innerHTML = t[y];
			y = y + 1;
		}		
	}
}

function SelectAllItem(obj)
{
var x, oChecks;
	oChecks = document.getElementsByName("SelectLineTD")
	for (x = 0; x < oChecks.length; x++)
		oChecks[x].checked = obj.checked;
}

function TableBatchAction(nType, BatchKey, BatchParam, msg)
{
var x, oChecks, values;
	var values = GetSelectNode();
	if (values == "")
	{
		if (typeof(oFocus) != "object")
		{
			alert("<j:Lang key="seek.Select_caozuo"/>"); 
			return -1;
		}
		values = objattr(oFocus, "node");
	}

	if (typeof(msg) == "string")
	{
		if (!window.confirm(msg))
			return;
	}	

	switch (nType)
	{
	case 1:			//批量删除
		if (typeof(msg) == "undefined")
		{
			if (!window.confirm("<j:Lang key="seek.Check_delete"/>"))
				return;
		}
		break;
	case 2:			//批量修改

		break;
	case 3:			//批量修改并复制
		break;
	case 5:			//自定义删除
		break;
	case 4:			//批量操作，如电子邮件群发
		NewHref(BatchKey + values, "location=0,resizable=1,scrollbars=1,width=640,height=480,left=50,top=50");
		return true;
	}
	location.href = AppendURLParam(href, "SeekKey=" +SeekKey + "&SeekParam=" +SeekParam + "&OrderField=" + OrderField + 
		"&bDesc=" + bDesc + "&ViewMode=" + ViewMode + "&BatchAction=" + nType + "&BatchValue=" + values +
		"&BatchKey=" + BatchKey + "&BatchParam=" + BatchParam);
}

function FlowView()
{
	if (typeof flow == "undefined")
	{
		if (typeof(FlowName) != "string")
			return alert("未定义与本视图对应的流程");
		flow = FlowName;
	}
	if (typeof(oFocus) != "object")
	{
		alert("<j:Lang key="seek.Slect_biaolist"/>");
		return;
	}
	oNewWin = NewHref(flow + ".jsp?RunMode=2&DataID=" + objattr(oFocus, "node"),
		"menubar=0,toolbar=0,location=0,resizable=1,scrollbars=1,width=840,height=480,left=50,top=50");
}

function ExpandTableTree(oImg, nType)
{
	if (oImg.getAttribute("ready") == 2)
		return;
	if (oImg.getAttribute("ready") == 0)
		return AjaxGetTreeData(oImg);

	if (ViewMode == 9)
		return ExpandTreeList(oImg);

	var oDiv = oImg.parentNode.parentNode.nextSibling;
	if (oDiv == null)
	{
		alert("<j:Lang key="seek.No_zhangkai"/>");
		return;
	}
	if (oDiv.style.display == "none")
	{
		oDiv.style.display="block";
		switch (nType)
		{
		case 1:			//vista
			oImg.innerHTML = "y";
			break;
		case 2:
			oImg.innerHTML = "6";
			break;
		default:
			if (typeof(oImg.getAttribute("s2")) == "string")
				oImg.src = oImg.getAttribute("s2");
			else
				oImg.src = psubdir + "pic/minus.gif";

			break;
		}
		oImg.value = 1;
	}
	else
	{
		oDiv.style.display="none";
		switch (nType)
		{
		case 1:			//vista
			oImg.innerHTML = "w";
			break;
		case 2:
			oImg.innerHTML = "4";
			break;
		default:
			if (typeof(oImg.getAttribute("s1")) == "string")
				oImg.src = oImg.getAttribute("s1");
			else
				oImg.src = psubdir + "pic/plus.gif";
			break;
		}
		oImg.value = 0;
	}

}

function AjaxGetTreeData(oImg)
{
var hintobj, obj, Depth;
	obj = oImg.parentNode.parentNode;
	oImg.ready = 2;
	// w3c lxt 2017.12.28
	oImg.setAttribute("ready", 2);
	var resultfun = function (data)
	{
		if (typeof(hintobj) == "object")
			hintobj.parentNode.removeChild(hintobj); // w3c 2017.9.23

		switch (ViewMode)
		{
		case 2:
		case 5:
			if (typeof(oImg.s2) == "string")
				oImg.src = oImg.s2;
			else
				oImg.src = psubdir + "pic/minus.gif";
			oImg.value = 1;
			oImg.title="展开子功能";
			obj.insertAdjacentHTML("afterEnd", "<div style=display:inline;>" +
				data + "</div>");
			if (typeof(window.SubTreeLoadEvent) == "function")
				SubTreeLoadEvent(oImg);
			oImg.ready = 1;
			// w3c lxt 2017.12.28
			oImg.setAttribute("ready", 1);
			break;
		case 3:
			if (typeof(oImg.s2) == "string")
				oImg.src = oImg.s2;
			else
				oImg.src = psubdir + "pic/minus.gif";
			oImg.value = 1;
			oImg.title="展开子功能";
			var oTD = obj.parentNode.parentNode.parentNode.insertCell(obj.parentNode.parentNode.cellIndex + 1);
			oTD.innerHTML = data;
			oTD.noWrap = true;
			oImg.ready = 1;
			// w3c lxt 2017.12.28
			oImg.setAttribute("ready", 1);
			break;
		case 4:
			break;
		case 9:
			SelObject();
			obj = document.getElementById("TEMP_TR_" + obj);
			var id = obj.previousSibling.id;
			if (data == "")
				obj.removeNode(true);
			else
			{
				var s = obj.parentNode.parentNode.outerHTML;
				var re = new RegExp("<TR id\\=TEMP_TR_" + obj.id.substr(8) + ">[\\S\\s]+?正在加载[\\S\\s]+?</TR>", "ig");
				s = s.replace(re, data);
				obj.parentNode.parentNode.outerHTML = s;
			}
			obj = document.getElementById(id);
			oImg = obj.cells[0].firstChild;
			if (typeof(oImg.s2) == "string")
				oImg.src = oImg.s2;
			else
				oImg.src = psubdir + "pic/minus.gif";
			oImg.value = 1;
			oImg.title="展开子功能";
			SelObject(obj);
			oImg.ready = 1;
			// w3c lxt 2017.12.28
			oImg.setAttribute("ready", 1);
			break;
		default:
			alert(ViewMode);
			break;
		}
	};
	if (typeof nTreeIndent == "undefined")
		nTreeIndent = 16;
	Depth = parseInt(parseInt(oImg.parentNode.style.paddingLeft) / nTreeIndent) + 1;
	
	var url = AppendURLParam(location.href, "ParentNode=" + oImg.parentNode.parentNode.id.substr(2) +
		"&nDepth=" + Depth + "&SubTree=1&t=" + (new Date()).getTime());
	switch (ViewMode)
	{
	case 2:
	case 5:
		obj.insertAdjacentHTML("afterEnd", "<span style='display:inline;background-color:#FFFEA4;border:solid 1px gray;'>正在加载..</span>");
		hintobj = obj.nextSibling;
		break;
	case 3:
		break;
	case 4:
		break;
	case 9:
		var oTR = obj.parentNode.insertRow(obj.rowIndex + 1);
		oTR.id = "TEMP_TR_" + objattr(obj, "node");
		var oTD = oTR.insertCell();
		oTD.colSpan = obj.cells.length;
		oTD.bgColor = "#FFFEA4";
		oTD.innerHTML = "正在加载...";
		obj = objattr(obj, "node");
		break;
		
	}
	AjaxRequestPage(url, true, "", resultfun)
}


function ArrangeSubTree(ParentNode, ViewMode)
{
	switch (ViewMode)
	{
	case 2:
	case 5:
		obj = document.getElementById("P_" + ParentNode);
		oImg = obj.firstChild.firstChild;
		oImg.ready = 1;
		if (typeof(oImg.s2) == "string")
			oImg.src = oImg.s2;
		else
			oImg.src = psubdir + "pic/minus.gif";
		oImg.value = 1;
		oImg.title="<j:Lang key="seek.Zhangkai_zigongneng"/>";
		obj.insertAdjacentHTML("afterEnd", "<div style=display:inline;>" +
			idobj("TableTreeSubDataFrame").contentWindow.document.body.innerHTML + "</div>");
		break;
	case 3:
		obj = document.getElementById("P_" + ParentNode);
		oImg = obj.firstChild.firstChild;
		oImg.ready = 1;
		if (typeof(oImg.s2) == "string")
			oImg.src = oImg.s2;
		else
			oImg.src = psubdir + "pic/minus.gif";
		oImg.value = 1;
		oImg.title="<j:Lang key="seek.Zhangkai_zigongneng"/>";
		var oTD = obj.parentNode.parentNode.parentNode.insertCell(obj.parentNode.parentNode.cellIndex + 1);
		oTD.innerHTML = idobj("TableTreeSubDataFrame").contentWindow.document.body.innerHTML;
		oTD.noWrap = true;
		break;
		break;
	case 4:
		break;
	}
}

var CurrentSubView = 101;
function SelectSubView(obj)
{
	if (event != null)
		SelObject(obj);
	var frame = idobj("SubSeekFrame");
	frame.src = "TableSeek.asp?TableDefID=" + TableDefID + "&ActionID=" + ActionID + 
		"&ParentNode=" + objattr(obj, "node") + "&ViewMode=" + CurrentSubView;
	frame.style.display = "inline";
}

function SelectParentSubView(obj)
{
	SelObject(obj);
	parent.SelectSubView(obj);
}

function ExpandFrame(obj)
{
var oTR = obj.parentNode.parentNode;
	var frame = idobj("FieldDataFrame");
	var evt = getEvent();
	if (frame.floatStatus != 0)
	{
		frame.style.posLeft = oTR.style.posLeft + 32;
		frame.style.posTop = evt.clientY + document.body.scrollTop + 20;
	}
	frame.style.display = "inline";
	frame.src = "TableMoreView.asp?TableDefID=" +TableDefID + "&ActionID=" + ActionID +
		"&DataID=" + objattr(oTR, "node") + "&ClassName=" + ClassName;
	evt.cancelBubble = true;
}

function SelectRootObj(obj, TableDefID)
{
	SelObject(obj);
	objattr(obj, "TableDefID", TableDefID);
}

function DefaultDbClick(oTR)
{
var x;
	return;
//	if (typeof(parent.ConfirmDlg) == "function")
//		return parent.ConfirmDlg();
	if (typeof(oTR.cells) == "undefined")
		return;
	var evt = getEvent();
	for (x = 0; x < oTR.cells.length; x++)
	{
		if ((oTR.cells[x] == evt.srcElement) || (oTR.cells[x] == evt.srcElement.parentNode))
			break;
	}
	var oTable = oTR.parentNode.parentNode;
	var param = objtext(oTR.cells[x]);
	if (objattr(oTR.cells[x], "node") != null)
		param = objattr(oTR.cells[x], "node");
	if (evt.shiftKey)
	{
		alert("<j:Lang key="psub.update"/>");
	}
	else
		TableKeySeek(objattr(oTable.rows[0].cells[x], "node"), param);
}

function ViewPage(obj)
{
	if (typeof(obj) != "object")
		obj = idobj("PageFootSel");
	GoHref(AppendURLParam(obj.action, "Page=" + obj.value));
}

function MakeFootPage(obj)
{
	for (x = 1; x <= obj.pagecount; x++)
	{
		oOption = document.createElement("OPTION");
		oOption.text = x;
		oOption.value = x;
		obj.add(oOption);
	}
	obj.value = objattr(obj, "node");
}

function SelectPrepSeek(PrepID)
{
	location.href = AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam + "&OrderField=" +
		OrderField + "&bDesc=" + bDesc + "&ViewMode=" + ViewMode + "&PrepID=" + PrepID);
}

function ExportSeek()
{
	var x = parseInt(objtext(idobj("RecordNums")));
	if (x <= 500)
		return window.open(AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam +
		"&OrderField=" + OrderField + "&bDesc=" + bDesc + "&nExport=1"));
	x = Math.ceil(x / 500);
	
	
	//var nExport = window.prompt("数据记录长度超长，系统将按500条一段分为" + x +"段, \n请选择需要导出的段号: [1 - " + x + " ]", 1);
	var test_fenduan="<j:Lang key="seek.fenduan"/>";
	var seek_biaohao="<j:Lang key="seek.daochubiaohao"/>";
	var fenduan_string=test_fenduan.replace("[0]",x)+ "," + seek_biaohao.replace("[0]",[1 - " + x + " ]);
	
	var nExport = window.prompt(fenduan_string, 1);
	if (nExport == null)
		return;
	if ((nExport < 0) || (nExport > x) || isNaN(parseInt(nExport)))
		return alert("<j:Lang key="seek.Check_port"/>");
	window.open(AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam +
		"&OrderField=" + OrderField + "&bDesc=" + bDesc + "&nExport=" + nExport));
}

function TitleMenu(obj)
{
	if (typeof oPop != "object")
		oPop = window.createPopup();
	PopupMenu(idobj("TitleMenu"), oPop);
}

function NewAffixFile(attrib, SecretType)
{
	if (typeof(oFocus) == "object")
		var oNewWin = NewHref("UpFileForm.asp?KMMode=1&FileAttrib=" + attrib + "&ParentID=" + objattr(oFocus, "node"), 
			"width=640,height=480,scroll=0,status=0");
	else
		var oNewWin = NewHref("UpFileForm.asp?KMMode=1&FileAttrib=" + attrib + "&SecretType=" + SecretType,
			"width=640,height=480,status=0");
}

function DeleteAffixFile()
{
var DeleFlag = false;
	if (typeof(oFocus) == "object")
	{
		if (window.confirm("<j:Lang key="seek.Check_deleteselect"/>"))
		{
			if (oFocus.firstChild.firstChild.id == "BtExTree")
				DeleFlag = window.confirm("<j:Lang key="seek.Delete_allfile"/>");
			var oNewWin = NewHref("DeleAffix.asp?ID=" + objattr(oFocus, "node") + "&DeleFlag=" + DeleFlag,
				"width=320,height=200,scroll=0,status=0");
		}
	}
	else
		alert("<j:Lang key="seek.No_select"/>");
}

function ResizeFrame()
{
var th = 0, tm = 0, tt = 0, tf = 0;
//throw "debug";
	var o = idobj("PageTitleTable");
	if (o != null)
		th = o.offsetHeight;
	o = idobj("SeekMenubar");
	if (o != null)
		tm = o.offsetHeight;
	o = idobj("ToolbarTable");
	if (o != null)
		tt = o.offsetHeight;
	var o = idobj("PageFootTable");
	if (o != null)
		tf = o.offsetHeight;

	var table = idobj("TableDoc");
	var frame = idobj("FrameDoc");
	var h = window.innerHeight;
	if (typeof h == "undefined")
		h = document.body.clientHeight;
	h = h - th - tm - tt - tf;
//	var h = document.documentElement.offsetHeight - th - tm - tt - tf;
//	var h = document.body.clientHeight - th - tm - tt - tf;
//	var h = window.innerHeight - th - tm - tt - tf;
	if ((table != null) && (h > 4))
	{
		if (frame != null)
		{
			frame.style.height = h + "px";
			table.style.height = h + "px";
		}
		else
			table.style.height = h + "px";
		var o = idobj("SubSeekFrame");
		if ((table.style.display == "none") && (o != null))
			o.style.height = table.style.height;
		var o = idobj("SubSeekFrame");
		if ((table.style.display == "none") && (o != null))
			o.style.height = table.style.height;
		o = idobj("LeftViewDiv");
		if (o != null)
			o.style.height = h + "px";
		o = idobj("RightViewDiv");
		if (o != null)
			o.style.height = h + "px";
		
	}
	if (typeof split == "object")
	{
		split.refresh();
//		if ((typeof document.all.LeftViewDiv == "object") && (typeof document.all.RightViewDiv == "object"))
//			document.all.RightViewDiv.style.pixelWidth = document.all.TableDoc.offsetWidth - document.all.LeftViewDiv.offsetWidth - 4;
	}
}

function InitSubView()
{
var oDivs = document.getElementsByTagName("DIV");
	for (var x = 0; x < oDivs.length; x++)
	{
		if ((oDivs[x].onclick != null) && (oDivs[x].onclick.toString().indexOf("SelectSubView") > 0))
		{
			oDivs[x].click();
			break;
		}
	}
}

function InitTitleOrder()
{
	var tr = idobj("SeekTitleTR");
	if (tr == null)
		return
	for (var x = 0; x < tr.cells.length; x++)
	{
		if (objattr(tr.cells[x], "node") == OrderField)
		{
			if (bDesc == 0)
			{
				tr.cells[x].innerHTML += "&uarr;";
				objattr(tr.cells[x], "bDesc", 0);
			}
			else
				tr.cells[x].innerHTML += "&darr;";
		}
	}
	var table =idobj("SeekTable");
	for (var x = 0; x < table.rows.length; x++)
	{
		for (var y = 0; y < table.rows[x].cells.length; y++)
		{
			if (table.rows[x].cells[y].innerHTML == "")
				table.rows[x].cells[y].innerHTML = "&nbsp";
		}
	}
}

function CheckAllChild(obj, value)
{
	oChecks = obj.getElementsByTagName("INPUT");
	for (var x = 0; x < oChecks.length; x++)
		oChecks[x].checked = value;
}

function SelectRow(oTR)
{
	if ((ViewMode == 3) || (ViewMode == 4))
		return SelObject(oTR);
	var evt = getEvent();
	if (evt.ctrlKey)
		return CtrlSelectRow(oTR);
	if (evt.shiftKey)
		return ShiftSelectRow(oTR);
	return SimpleSelectRow(oTR);
}

function CtrlSelectRow(oTR)
{
	if (oTR.selflag != 1)
	{
		oFocus = 0;
		SelObject(oTR);
		oTR.selflag = 1;
	}
	else
	{
		oFocus = oTR;
		SelObject();
		oTR.selflag = 0;
	}
	document.selection.empty();
	return false;
}

function SimpleSelectRow(oTR)
{
	ClearSelectRow(oTR.parentNode.parentNode);
	oFocus = 0;
	SelObject(oTR);
	oTR.selflag = 1;
	return false;
}

function ClearSelectRow(oTable)
{
	if ((oTable.tagName != "TABLE") && (oTable.tagName != "TBODY"))
	{
		var divs = oTable.ownerDocument.getElementsByTagName("DIV");
		for (var x = 0; x < divs.length; x++)
		{
			if (divs[x].selflag == 1)
			{
				oFocus = divs[x];
				oFocus.selflag = 0;
				SelObject();
			}
		}
		return;
	}
	for (var x = 1; x < oTable.rows.length; x++)
	{
		if (oTable.rows[x].selflag == 1)
		{
			oFocus = oTable.rows[x];
			oFocus.selflag = 0;
			SelObject();
		}
	}
}

function ShiftSelectRow(oTR)
{
var x, min = -1, max = -1, index, delta = 1;
	if (oTR.tagName != "TR")
		delta = 0
	for (x = delta; x < oTR.parentNode.childNodes.length; x++)
	{
		if ((oTR.parentNode.childNodes[x].selflag == 1) && (min == -1))
			min = x;
		if ((oTR.parentNode.childNodes[x].selflag == 1) && (x > max))
			max = x;
		if (oTR.parentNode.childNodes[x] == oTR)
			index = x;
	}
	if ((min == -1) && (max == -1))
		return SimpleSelectRow(oTR);

	if (index < min)
		min = index;
	else
	{
		if (index > max)
			max = index;
		else
			min = index
	}
	for (x = delta; x < min; x++)
	{
		if (oTR.parentNode.childNodes[x].selflag == 1)
		{
			oFocus = oTR.parentNode.childNodes[x];
			oFocus.selflag = 0;
			SelObject();
		}
	}
	for (x = min; x <= max; x++)
	{
		if (oTR.parentNode.childNodes[x].selflag == 1)
			continue;
		oFocus = 0;
		SelObject(oTR.parentNode.childNodes[x]);
		oTR.parentNode.childNodes[x].selflag = 1;
	}
	for (x = max + 1; x < oTR.parentNode.childNodes.length; x++)
	{
		if (oTR.parentNode.childNodes[x].selflag == 1)
		{
			oFocus = oTR.parentNode.childNodes[x];
			oFocus.selflag = 0;
			SelObject();
		}
	}
	document.selection.empty();
	return true;
}

function TableSelectBegin(obj)
{
	obj.onmousemove = function (){TableSelect(obj);};
	return false;
}

function TableSelect(obj)
{
	var sel = idobj("SelDiv");
	var evt = getEvent();
	if (sel == null)
	{
		if ((evt.button & 1) == 0)
			return;
		if ((evt.ctrlKey == false) && (evt.shiftKey == false))
		{
			for (var x = 1; x < obj.rows.length; x++)
			{
				if (obj.rows[x].selflag == 1)
				{
					oFocus = obj.rows[x];
					oFocus.selflag = 0;
					SelObject();
				}
			}
		}
		document.body.insertAdjacentHTML("afterBegin", "<div id=SelDiv style=" +
			"'position:absolute;border:solid 1px blue;width:2px;height:2px;overflow:hidden;'></div>");
		sel = idobj("SelDiv");
		sel.style.left = evt.x + "px";
		sel.style.top = evt.y + "px";
		sel.posx = evt.x;
		sel.posy = evt.y;
		obj.onmouseup = function ()
		{
			obj.onmousemove = null;
			obj.onmouseup = null;
			obj.releaseCapture();
			if (sel == null)
				return false;
			var e = document.createEventObject(evt);
			e.ctrlKey = true;
			for (var x = 1; x < obj.rows.length; x++)
			{
				if ((obj.rows[x].offsetTop + obj.rows[x].offsetHeight + obj.parentNode.offsetTop > parseInt(sel.style.top) + obj.parentNode.scrollTop)
					&& (obj.rows[x].offsetTop + obj.parentNode.offsetTop < parseInt(sel.style.top) + obj.parentNode.scrollTop + parseInt(sel.style.height))
					&& (obj.rows[x].selflag != 1))
					obj.rows[x].fireEvent("onclick", e);
			}
			sel.parentNode.removeChild(sel);
			document.selection.empty();
			return false;
		}
		obj.setCapture(true);
	}
	if ((evt.button & 1) == 0)
		return obj.fireEvent("onmouseup");
	MouseDrawRect(evt, sel);
}

function TreeSelectBegin(obj)
{
	obj.onmousemove = function (){TreeSelect(obj);};
	return false;
}

function TreeSelect(obj)
{
	var	sel = idobj("SelDiv");
	evt = getEvent();
	if (sel == null)
	{
		if ((evt.button & 1) == 0)
			return;
		if ((evt.ctrlKey == false) && (evt.shiftKey == false))
		{
			var divs = obj.getElementsByTagName("DIV");
			for (var x = 1; x < divs.length; x++)
			{
				if (divs[x].selflag == 1)
				{
					oFocus = divs[x];
					oFocus.selflag = 0;
					SelObject();
				}
			}
		}
		document.body.insertAdjacentHTML("afterBegin", "<div id=SelDiv style=" +
			"'position:absolute;border:solid 1px blue;width:2px;height:2px;overflow:hidden;'></div>");
		sel = idobj("SelDiv");
		sel.style.left = evt.x + "px";
		sel.style.top = evt.y + "px";
		sel.posx = evt.x;
		sel.posy = evt.y;
		obj.setCapture(true);
		obj.onmouseup = function ()
		{
			obj.onmousemove = null;
			obj.onmouseup = null;
			obj.releaseCapture();
			if (sel == null)
				return false;
			var divs = obj.getElementsByTagName("DIV");
			var e = document.createEventObject(evt);
			e.ctrlKey = true;
			for (var x = 1; x < divs.length; x++)
			{
				if ((divs[x].offsetTop + divs[x].offsetHeight + obj.offsetTop > parseInt(sel.style.top) + obj.scrollTop)
					&& (divs[x].offsetTop + obj.offsetTop < parseInt(sel.style.top) + obj.scrollTop + parseInt(sel.style.height))
					&& (divs[x].selflag != 1))
					divs[x].fireEvent("onclick", e);
			}
			sel.removeNode();
			document.selection.empty();
			return false;
		}
	}
	if ((evt.button & 1) == 0)
		return obj.fireEvent("onmouseup");
	MouseDrawRect(evt, sel);
}

function MouseDrawRect(evt, obj)
{
	if (evt.x > obj.posx)
	{
		obj.style.left = obj.posx + "px";
		obj.style.width = (evt.x - obj.posx) + "px";
	}
	else
	{
		if (evt.x < obj.posx)
		{
			obj.style.left = evt.x + "px";
			obj.style.width = (obj.posx - evt.x) + "px";
		}
	}

	if (evt.y > obj.posy)
	{
		obj.style.top = obj.posy + "px";
		obj.style.height = (evt.y - obj.posy) + "px";
	}
	else
	{
		if (evt.y < obj.posy)
		{
			obj.style.top = evt.y + "px";
			obj.style.height = (obj.posy - evt.y) + "px";
		}
	}
}

function KeySelectRow()
{
	var tab = idobj("SeekTable");
	if (tab == null)
		return KeySelectTreeItem();
	var doc = idobj("TableDoc");
	var evt = getEvent();
	switch (evt.keyCode)
	{
	case 38:  //up
		if (tab.rows.length < 2)
			return;
		oRow = GetSelectRow();
		if (typeof(oRow) != "object")
		{
			tab.rows[1].click();
			tab.rows[0].scrollIntoView(true);
		}

  		else
  		{
			ClearSelectRow(tab);
    			if (oRow.rowIndex > 1)
			{
				tab.rows[oRow.rowIndex - 1].click();
				if (oFocus.offsetTop < doc.scrollTop + oFocus.offsetHeight)
					tab.rows[oFocus.rowIndex - 1].scrollIntoView(true);
			}
	  	}
 		break;
	case 40:  //down
		if (tab.rows.length < 2)
			return;
		oRow = GetSelectRow(tab);
		if (typeof(oRow) != "object")
		{
			tab.rows[tab.rows.length - 1].click();
			oFocus.scrollIntoView(false);
		}
 		else
  		{
			ClearSelectRow(tab);
    			if (oRow.rowIndex < tab.rows.length - 1)
			{
				tab.rows[oRow.rowIndex + 1].click();
				if (oFocus.offsetTop + oFocus.offsetHeight > doc.scrollTop + parseInt(doc.style.height))
					oFocus.scrollIntoView(false);
			}
		}
	case 39:    //right
		break;
	case 37:    //left
		break;
	default: 
		return true;
	}
	return false;
}

function GetSelectRow()
{
	if (typeof(oFocus) == "object")
		return oFocus;
	var tab = idobj("SeekTable");
	if (tab == null)
		return;
	for (var x = 1; x < tab.rows.length; x++)
	{
		if (tab.rows[x].selflag == 1)
			return tab.rows[x];
	}
}

function GetSelectNode()
{
var values = ""
	var oChecks = document.getElementsByName("SelectLineTD")
	var tab = idobj("SeekTable");
	if (oChecks.length == 0)
	{
		if (tab == null)
		{
			var divs = document.getElementsByTagName("DIV");
			for (var x = 1; x < divs.length; x++)
			{
				if (divs[x].selflag == 1)
				{
					if (values == "")
						values = objattr(divs[x], "node");
					else
						values += "," + objattr(divs[x], "node");
				}
			}
			if (values != "")
				return values;
			if (typeof(oFocus) == "object")
				return objattr(oFocus, "node");
			return values;
		}
		for (var x = 1; x < tab.rows.length; x++)
		{
			if (tab.rows[x].selflag == 1)
			{
				if (values == "")
					values = objattr(tab.rows[x], "node");
				else
					values += "," + objattr(tab.rows[x], "node");
			}
		}
		if ((typeof(oFocus) == "object") && (values == ""))
			return objattr(oFocus, "node");
		return values;
	}
	for (x = 0; x < oChecks.length; x++)
	{
		if (oChecks[x].checked)
		{
			if (values == "")
				values = objattr(oChecks[x].parentNode.parentNode, "node");
			else
				values += "," + objattr(oChecks[x].parentNode.parentNode, "node");
		}
	}
	return values;

}

function KeySelectTreeItem()
{
	var evt = getEvent();
	switch (et.keyCode)
	{
	case 38:  //up
 		break;
	case 40:  //down
	case 39:    //right
		break;
	case 37:    //left
		break;
	default: 
		return true;
	}
	return false;
}

function CopyTableRow(oRow, nIndex)
{
	var oNewTR = oRow.parentNode.insertRow(nIndex);
	oNewTR.bgColor = oRow.bgColor;
	oNewTR.onclick = oRow.onclick;
	oNewTR.ondblclick = oRow.ondblclick;
	for (var x = 0; x < oRow.cells.length; x++)
	{
		var oTD = oNewTR.insertCell();
		oTD.innerHTML = oRow.cells[x].innerHTML;
	}
	return oNewTR;
}

function EditLine(oTR)
{
}

function EditAllSeek(obj, ActionID)
{
	if (objtext(obj) != "<j:Lang key="psub.Commit"/>")
	{
		obj.innerHTML = "<j:Lang key="psub.Commit"/>";
		AjaxRequestPage("/TableAction.asp?InlineForm=1&ActionID=" + ActionID, true, "", InitEditSeek);
	}
}

function InitEditSeek(result)
{
var oTR, oTable;
	document.body.insertAdjacentHTML("afterEnd", "<DIV style=display:hidden>" + result + "</div>");

	if (typeof(oFocus) == "undefined")
		oTR = idobj("SeekTable").rows[1];
	else
		oTR = oFocus;
	SelObject();
	oTable = oTR.parentNode.parentNode;
	obj = document.createElement("SCRIPT");
	obj.src = psubdir + "form.jsp";
	obj.id = "FormScript";
	document.body.insertBefore(obj, null);
	oTable.parentNode.style.overflow = "visible";
	oTable.onselectstart = null;
	oTable.onmousedown = null;
	for (var x = 1; x < oTable.rows.length; x++)
	{
		oTable.rows[x].onclick = null;
		oTable.rows[x].ondblclick = null;
		for (var y = 0; y < oTable.rows[x].cells.length; y++)
		{
			if (objattr(oTable.rows[0].cells[y], "node") == null)
				continue;
			var oInput = document.getElementsByName(objattr(oTable.rows[0].cells[y], "node"));
			var value = objattr(oTable.rows[x].cells[y], "node");
			if (typeof(value) == "undefined")
				value = objtext(oTable.rows[x].cells[y]);
			switch (oInput[0].tagName)
			{
			case "INPUT":
				if (oInput[0].type == "hidden")
					break;
			case "SELECT":
				oTable.rows[x].cells[y].innerHTML = oInput[0].outerHTML;
				oTable.rows[x].cells[y].firstChild.style.border = "none";
				oTable.rows[x].cells[y].firstChild.style.backgroundColor = oTable.rows[x].bgColor;
				oTable.rows[x].cells[y].firstChild.value = value;
				break;
			}
		}
	}
	oTable.onkeydown = function (){PressKey(this);};
	document.onkeydown = null;
	oTable.parentNode.style.overflow = "auto";
}

function ConfirmFilter()
{
var param, x, oInputs, andor
	param = "";
	if (idobj("AndOr").checked)
		andor = " and ";
	else
		andor = " or ";
	var tab = idobj("FilterTable");
	for (x = 1; x < tab.rows.length; x++)
	{
		oInputs = tab.rows[x].getElementsByTagName("input")
		if (oInputs[0].value != "")
		{
			if (param == "")
				param = GetSeekCondition(oInputs[0].name, oInputs[0].value, objattr(oInputs[0], "node"));
			else
				param = param + andor + GetSeekCondition(oInputs[0].name, oInputs[0].value, objattr(oInputs[0], "node"));
		}
	}
	returnValue = param;
	window.close()
}

function GetSeekCondition(SeekKey, SeekParam, KeyType)
{
	if ((SeekParam.substr(0, 1) == "*") || (SeekParam.substr(SeekParam.length - 1, 1) == "*"))
		return SeekKey + " like '" + SeekParam + "'"
	
	if ((SeekParam.substr(0, 1) == "<") && (SeekParam.substr(SeekParam.length - 1, 1) == ">"))
	{
		var ss = SeekParam.substr(1, SeekParam.length - 2).split(",");
		if (ss.length == 2)
			return SeekKey + " >=" + GetFieldTypeValue(ss[0], KeyType) + " and " +
				SeekKey + " <=" + GetFieldTypeValue(ss[1], KeyType);
	}

	if ((SeekParam.substr(0, 1) == "(") && (SeekParam.substr(SeekParam.length - 1, 1) == ")"))
	{
		var result = SeekKey + " in (";
		var ss = SeekParam.substr(1, SeekParam.length - 2).split(",");
		for (var x = 0; x < ss.length; x++)
			result += GetFieldTypeValue(ss[x], KeyType) + ",";
		return result.substr(0, result.length - 1) + ")";
	}
	if ((SeekParam.substr(0, 2) == "<=") || (SeekParam.substr(0, 2) == ">="))
		return SeekKey + SeekParam.substr(0, 2) + GetFieldTypeValue(SeekParam.substr(2), KeyType);
	if ((SeekParam.substr(0, 1) == "<") || (SeekParam.substr(0, 1) == ">"))
		return SeekKey + SeekParam.substr(0, 1) + GetFieldTypeValue(SeekParam.substr(1), KeyType);

	if ((KeyType == 4) && (SeekParam.substr(0, 1) == "@"))
	{
		switch (SeekParam.substr(1, 1))
		{
		case "1":					//按年份查询
			return "DateDiff('yyyy'," + SeekKey + ",'" + SeekParam.substr(3) + "-01-01')=0";
		case "2":					//按月份查询
			return "Month(" + SeekKey + ")=" + SeekParam.substr(3);
		case "3":					//按日期查询
			return "Day(" + SeekKey + ")=" + SeekParam.substr(3);
		case "4":					//按年月查询
			return "DateDiff('m'," + SeekKey + ",'" + SeekParam.substr(3) + "-1')=0";
		case "5":					//按月日查询
			var ss = SeekParam.substr(3).split("-");
			if (ss.length == 2)
				return "Month(" + SeekKey + ")=" + ss[0] + " and Day(" + SeekKey + ")=" + ss[1];
			return ""
		case "6":					//按季度查询(1-4)
			var x = parseInt(SeekParam.substr(3)) * 3;
			return "Month(" + SeekKey + ")>=" + (x - 2) + " and Month(" + SeekKey + ")<=" + x;
		case "7":					//按时间段查询
			var ss = SeekParam.substr(3).split(",");
			if (ss.length == 2)
				return "DateDiff('d'," + SeekKey + ",'" + ss[0] + "')<=0 and " +
					"DateDiff('d'," + SeekKey + ",'" + ss[1] + "')>=0"
			return ""
		case "0":
			return SeekKey + ">=" + GetFieldTypeValue(SeekParam.substr(3), KeyType);
		}
	}
	return 	SeekKey + "=" + GetFieldTypeValue(SeekParam, KeyType)
}

function GetFieldTypeValue(value, KeyType)
{
	switch (parseInt(KeyType))
	{
	case 3:					//Integer
	case 5:					//Counter
	case 6:					//Double
	case 7:
		return value;
	case 9:					//Yes/No
		if (value != 0)
			return "true";
		return "false";
	case 4:					//DateTime
		if (value == "")
			return "null";
		return "'" + value + "'";
	default:
		return "'" + value + "'";
	}
}

function ResizeSeekCol(obj)
{
	window.document.onmousemove = SeekColSplitting;
	window.document.onmouseup = EndSeekColSplit;
//	window.document.ondragstart = SeekColSplitting;
//	window.document.onselectstart = SeekColSplitting; 
	obj.style.filter = "alpha(opacity=50)";
	obj.style.opacity = "0.5";
	dragObj = obj;
	var evt = getEvent();
	evt.cancelBubble = true;
	obj.setCapture();
	return false;
}

function SeekColSplitting()
{
	var evt = getEvent();
	if (evt.clientX  > 50)
		dragObj.style.left = evt.clientX + "px";
	return false;
}

function EndSeekColSplit(nWidth)
{
	var div = idobj("LeftViewDiv");
	if (typeof nWidth == "number")
	{
		div.style.width = nWidth + "px";
		div.nextSibling.style.left = (nWidth - 4) + "px";
		return;
	}
	div.style.width = (parseInt(dragObj.style.left) + 4) + "px";
	window.document.onmousemove = null;
	window.document.onmouseup = null;
	window.document.ondragstart = null;
	dragObj.style.filter = "alpha(opacity=0)";
	dragObj.style.opacity = "0.0";
	dragObj = 0;
	document.releaseCapture();
}

function SetDivHeight()
{
	idobj("ftdiv").style.height = (document.body.clientHeight - 75) + "px";
}


function SelectFuncObj(oTR, clr)
{
	if (typeof(clr) == "undefined")
		clr = "moccasin";
	if (typeof(oFocus) == "object")
		oFocus.style.backgroundColor = oFocus.oldColor;
	oFocus = oTR
	oFocus.oldColor = oFocus.style.backgroundColor;
	oFocus.style.backgroundColor = clr;
	var evt = getEvent();
	evt.cancelBubble = true;
}

function ExpandFuncTree(oImg)
{
	var oDiv = oImg.parentNode.parentNode;
	if (oDiv.children[oDiv.children.length - 1].style.display == "none")
	{
		oDiv.children[oDiv.children.length - 1].style.display="inline";
		oImg.src = psubdir + "pic/minus.gif";
		oImg.value = 1;
	}
	else
	{
		oDiv.children[oDiv.children.length - 1].style.display="none";
		oImg.src = psubdir + "pic/plus.gif";
		oImg.value = 0;
	}

}

function ExpandAllFuncTree(oImg)
{
	var x, oImgs;
	oImgs = document.getElementsByName("BtExTree");
	if (oImg.value == 1)
	{
		oImg.value = 0;
		oImg.src = psubdir + "pic/plus.gif";
	}
	else
	{
		oImg.value = 1;
		oImg.src = psubdir + "pic/minus.gif";
	}
	
	for (x = 0; x < oImgs.length; x++)
	{
		if (oImg.value != oImgs[x].value)
			oImgs[x].click();
	}
	
}

function ExpandArbor(oImg)
{
	if (oImg.ready == 0)
	{
		var Depth = parseInt(parseInt(oImg.parentNode.style.paddingLeft) / 32) + 1;
		idobj("TableTreeSubDataFrame").src = "SubTreeSeek.asp" + location.search + "&ParentNode=" +
			oImg.parentNode.parentNode.id.substr(2) + "&ViewMode=3&nDepth=" + Depth;
		return;
	}

	if (typeof(oFocus) == "object")
		oFocus.style.backgroundColor = oFocus.oldColor;
	var oTable = oImg.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.cells[1];
	var oTD = oImg.parentNode.parentNode.parentNode.parentNode;
	if (oImg.value == 1)
	{
		oImg.src = psubdir + "pic/plus.gif";
		oImg.value = 0;
		oTable.style.display="none";
	}
	else
	{
		oImg.src=psubdir + "pic/minus.gif";
		oImg.value = 1;
		oTable.style.display="inline";
	}
	ExpandTreeLine(oTD);

	for (var oParent = oTD; oParent != document.body; oParent = oParent.parentNode)
	{
		if ((oParent.tagName == "TABLE") && (objall(oParent.cells[0], "TRItem") != null))
			ExpandTreeLine(oParent.cells[0]);
	}
	SelObject(oTD);

//	window.event.cancelBubble = true;
}

function ExpandHArbor(oImg)
{
	var oTable = oImg.parentNode.parentNode.parentNode.parentNode.lastChild;
	var oTD = oImg.parentNode.parentNode.parentNode.parentNode;
	if (oImg.value == 1)
	{
		oImg.src = psubdir + "pic/plus.gif";
		oImg.value = 0;
		if (oTable.tagName == "TABLE")
			oTable.style.display="none";
	}
	else
	{
		oImg.src = psubdir + "pic/minus.gif";
		oImg.value = 1;
		if (oTable.tagName == "TABLE")
			oTable.style.display="inline";
	}
	ExpandHTreeLine(oTD);
	for (var oParent = oTD; oParent != document.body; oParent = oParent.parentNode)
	{
		if ((oParent.tagName == "TD") && (oParent.firstChild.id == "HTRItem"))
			ExpandHTreeLine(oParent);
	}

//	window.event.cancelBubble = true;
}

function InitTreeLine()
{
	var oSpans = document.getElementsByName("TRItem")
	for (var x = 0; x < oSpans.length; x++)
		ExpandTreeLine(oSpans[x].parentNode);
	
}

function InitHTreeLine()
{
	var oSpans = document.getElementsByName("TRText")
	for (var x = 0; x < oSpans.length; x++)
	{
		if (oSpans[x].parentNode.parentNode.parentNode.parentNode.clientWidth < objtext(oSpans[x]).length * 20)
			oSpans[x].style.width = "5px";
	}
	oSpans = document.getElementsByName("HTRItem")
	for (x = 0; x < oSpans.length; x++)
		ExpandHTreeLine(oSpans[x].parentNode);
}

function ExpandTreeLine(oTD)
{
var nEx, x, t1, t2, tabchar, oParent;
	tabchar = objtext(objall(oTD, "TRLine")).substr(0, 1);
	switch (tabchar)
	{
	case "─":
		break;
	case "┌":
		oTD.innerHTML = objall(oTD, "TRItem").outerHTML;
		nEx = Math.floor((oTD.clientHeight / 20 - 1) * 3 / 4 );
		t1 = "";
		t2 = "";
		for (x = 0; x < nEx; x++)
		{
			t1 += "<BR>";
			t2 += "<BR>│"
		}
		oTD.innerHTML = t1 + oTD.innerHTML + t2;
		break;
	case "└":
		oTD.innerHTML = objall(oTD, "TRItem").outerHTML;
		nEx = Math.floor((oTD.clientHeight / 20 - 1) * 3 / 4 );
		t1 = "";
		t2 = "";
		for (x = 0; x < nEx; x++)
		{
			t1 += "│<BR>";
			t2 += "<BR>"
		}
		oTD.innerHTML = t1 + oTD.innerHTML + t2;
		break;
	case "├":
		oTD.innerHTML = objall(oTD, "TRItem").outerHTML;
		nEx = Math.floor((oTD.clientHeight / 20 - 1) * 3 / 4 );
		t1 = "";
		t2 = "";
		for (x = 0; x < nEx; x++)
		{
			t1 += "│<BR>";
			t2 += "<BR>│"
		}
		oTD.innerHTML = t1 + oTD.innerHTML + t2;
		break;
	}
}

function ExpandHTreeLine(oTD)
{
var nEx, x, t1, t2, oSpan;
	oSpan = objall(oTD, "HTRLine");
	switch (oSpan.value)
	{
	case "0":
		break;
	case "1":
		oSpan.innerHTML = "┌";
		nEx = Math.round(oTD.clientWidth / 24);
		t1 = "&nbsp;";
		t2 = "";
		for (x = 0; x < nEx - 1; x++)
		{
			t1 += "&nbsp;";
			t2 += "─"
		}
		oSpan.innerHTML = t1 + "┌" + t2;
		break;
	case "2":
		oSpan.innerHTML = "┐";
		nEx = Math.round(oTD.clientWidth / 24);
		t1 = "";
		t2 = "&nbsp;";
		for (x = 0; x < nEx - 1; x++)
		{
			t1 += "─"
			t2 += "&nbsp;";
		}
		oSpan.innerHTML = t1 + "┐" + t2;
		break;
	case "3":
		oSpan.innerHTML = "┬";
		nEx = Math.round(oTD.clientWidth / 24);
		t1 = "";
		for (x = 0; x < nEx - 1; x++)
			t1 += "─"
		oSpan.innerHTML = t1 + "┬" + t1;
		break;
	}
}


function ExpandTree(oImg)
{
	if (oImg.ready == 0)
	{
		idobj("TableTreeSubDataFrame").src = "SubTreeSeek.asp?ParentNode=" +
			oImg.parentNode.parentNode.id.substr(2);
		return;
	}
	var oDiv = oImg.parentNode.parentNode.nextSibling;
	if (oDiv == null)
	{
		alert("<j:Lang key="FTreeSub.Zhangkai_no"/>");
		return;
	}
	if (oDiv.style.display == "none")
	{
		oDiv.style.display="inline";
		oImg.src = psubdir + "pic/minus.gif";
		oImg.value = 1;
	}
	else
	{
		oDiv.style.display="none";
		oImg.src = psubdir + "pic/plus.gif";
		oImg.value = 0;
	}

}

function GetTableEventTR(oTable)
{
	var evt = getEvent();
	obj = FindParentObject(evt.srcElement, oTable, "TR");
	if (typeof(obj) == "undefined")
	{
		for (var obj = evt.srcElement; obj != oTable; obj = obj.parentNode)
		{
			if (obj == null)
				return evt.srcElement;
			if (objattr(obj, "node") != null)
				return obj;
		}
		return evt.srcElement;
	}
	if (obj.rowIndex == 0)
		return null;
	if (obj.parentNode.parentNode == oTable)
		return obj;
	return null;
}

function InsertCondition()
{
	var obj = document.getElementsByName("Content")[0];
	if (obj.value == "")
	{
		BodyAlert("内容不能为空");
		obj.focus();
		return;
	}
	var t = objattr(obj, "FieldType");
	if ((t == 3) || ( t == 5) || (t == 6) || (t == 7))
	{
		if (isNaN(parseFloat(obj.value)))
		{
			BodyAlert("内容不合法，请输入数值");
			obj.focus();
			return;
		}
	}
	var FieldsSel = idobj("FieldsSel");
	var sel = FieldsSel.options[FieldsSel.selectedIndex];
	if ((idobj("ComboImg").style.display != "none") && (objattr(sel, "node") != 4))
		SelectFilterNode(obj.value);
	else
		RunInsertCondition()
}		

function RunInsertCondition(sql)
{
	var oNewTR = idobj("SelectedList").insertRow();
	var sel = idobj("FieldsSel");
	oNewTR.setAttribute("type", sel.options[sel.selectedIndex].getAttribute("type"));
	oNewTR.onclick = function ()
	{
		SelObject(this);
		document.getElementsByName("DeleteButton")[0].disabled = false;
	}
	
	oNewTR.insertCell();
	oNewTR.insertCell();
	oNewTR.insertCell();
	oNewTR.insertCell();
	oNewTR.cells[0].width = 120;
	oNewTR.cells[0].innerHTML = objtext(sel.options[sel.selectedIndex]);
	oNewTR.cells[0].value = sel.options[sel.selectedIndex].value;
	objattr(oNewTR.cells[0], "node", objattr(sel.options[sel.selectedIndex], "node"));
//var oTD = oNewTR.insertCell();
	oNewTR.cells[1].width = 40;
	var ChoiceSel = idobj("ChoiceSel");
	oNewTR.cells[1].innerHTML = objtext(ChoiceSel.options[ChoiceSel.selectedIndex]);
	oNewTR.cells[1].value = ChoiceSel.options[ChoiceSel.selectedIndex].value;
//var oTD = oNewTR.insertCell();
	oNewTR.cells[2].width = 100;
	var Content = document.getElementsByName("Content")[0];
	oNewTR.cells[2].innerHTML = Content.value;
	objattr(oNewTR.cells[2], "node", objattr(Content, "node"));
	objattr(oNewTR.cells[2], "sql", sql);
//var oTD = oNewTR.insertCell();
	oNewTR.cells[3].width = 40;
	var ConnectSel = idobj("ConnectSel");
	oNewTR.cells[3].innerHTML = objtext(ConnectSel.options[ConnectSel.selectedIndex]);
	oNewTR.cells[3].value = ConnectSel.options[ConnectSel.selectedIndex].value;
	Content.value = "";
	objattr(Content, "node", null);
	var button = idobj("SaveButton");
	if (button != null)
		button.disabled = false;
}


function SelectFilterNode(value)
{
var sel, ss, x, item;
	var FieldsSel = idobj("FieldsSel");
	sel = FieldsSel.options[FieldsSel.selectedIndex];
	var Content = document.getElementsByName("Content")[0];
	var quote = objattr(sel, "quote");
	switch (quote.substr(0, 1))
	{
	case "(":
		objattr(Content, "data", quote.substr(1, quote.length - 2));
	case "@":
	case "$":
		ss = objattr(Content, "data").split(",");
		for (x = 0; x < ss.length; x++)
		{
			item = ss[x].split(":");
			if (item[1] == value)
			{
				objattr(Content, "node", item[0]);
				return RunInsertCondition();
			}
		}
		BodyAlert("枚举量不存在");
		Content.focus();
		return true;
	case "&":
		RunInsertCondition();//暂未实现拼音码
		return true;		
	default:
		var ss = quote.split(",")
		if (ss.length == 1)
			return false;
		var s1 = ss[0].split(".");
		if (s1[1] == ss[1])
			return false;
		var ChoiceSel = idobj("ChoiceSel");
		var sql = " in (select " + s1[1] + " from " + s1[0] + " where " +
			GetSeekItem(ss[1], value, parseInt(ChoiceSel.options[ChoiceSel.selectedIndex].value), 1) + ")";
		return RunInsertCondition(sql);
	}
}

function DeleteCondition()
{
	if (typeof(oFocus) == "object")
		oFocus.parentNode.removeChild(oFocus);
	
	document.getElementsByName("DeleteButton")[0].disabled = true;
	var SaveButton = idobj("SaveButton");
	if ((idobj("SelectedList").rows.length == 0) && (SaveButton != null))
		SaveButton.disabled = true;
}

function SaveCondition()
{
	idobj("LoadButton").style.visibility = "hidden";
	document.getElementsByName("DeleteButton")[0].style.visibility = "hidden";
	idobj("SeekButton").style.visibility = "hidden";
	
	idobj("FilterTable").style.display = "none";
	idobj("ContentDiv").insertAdjacentHTML("afterBegin", "<div id=SaveInputDiv>请输入要保存的检索方案名称:<br>" +
		"<input id=SaveNameObj style=width:100%;><br></div>");
	idobj("SaveNameObj").focus();
	idobj("CancelButton").onclick = function ()
	{
		idobj("LoadButton").style.visibility = "visible";
		document.getElementsByName("DeleteButton")[0].style.visibility = "visible";
		idobj("SeekButton").style.visibility = "visible";
		idobj("FilterTable").style.display = "block";
		idobj("SaveInputDiv").removeNode(true);
		idobj("CancelButton").onclick = CalcelSel;
		idobj("SaveButton").onclick = SaveCondition;
	}
	idobj("SaveButton").onclick = function ()
	{
		param = GetCondition();
		AjaxRequestPage(location.pathname + "?ComplexSeek=1&Title=" + idobj("SaveNameObj").value +
			"&Content=" + param, true, "", "idobj('CancelButton').click()");
	}
	
}

function LoadCondition()
{
	idobj("FilterTable").style.visibility = "hidden";
	idobj("LoadCatalogDiv").style.display = "block";
	idobj("SelectedDiv").style.display = "none";
	idobj("LoadButton").style.visibility = "hidden";
	idobj("SaveButton").style.visibility = "hidden";
	idobj("ContentTitleTD").innerHTML = "选择已保存的检索方案:";
	idobj("SeekButton").onclick = LoadSeek;
	if ((typeof(oFocus) != "object") || (objattr(oFocus, "node") == null))
	{
		idobj("SeekButton").disabled = true;
		document.getElementsByName("DeleteButton")[0].disabled = true;
	}
	else
	{
		idobj("SeekButton").disabled = false;
		document.getElementsByName("DeleteButton")[0].disabled = false;
	}
	document.getElementsByName("DeleteButton")[0].onclick = function ()
	{
		if (window.confirm("是否删除已选择的查询方案?") == false)
			return;
		AjaxRequestPage(location.pathname + "?ComplexSeek=1DeleteID=" + objattr(oFocus, "node"), true, "",
			"oFocus.removeNode(true);oFocus=0;idobj('SeekButton').disabled=true;document.getElementsByName('DeleteButton')[0].disabled=true;");
	}
	idobj("CancelButton").onclick = function ()
	{
		idobj("ContentTitleTD").innerHTML = "已添加的查询条件:";
		idobj("SelectedDiv").style.display = "block";
		idobj("LoadButton").style.visibility = "visible";
		idobj("SaveButton").style.visibility = "visible";
		idobj("LoadCatalogDiv").style.display = "none";
		idobj("FilterTable").style.visibility = "visible";
		idobj("CancelButton").onclick = CalcelSel;
		idobj("SeekButton").onclick = ConfirmCondition;
		document.getElementsByName("DeleteButton")[0].onclick = DeleteCondition;
		idobj("SeekButton").disabled = false;
	}

}

function LoadSeek()
{
	if ((typeof(oFocus) != "object") || (objattr(oFocus, "node") == null))
		return alert("请选择一项查询方案");
	if (typeof(parent.TableMenuComplexSeek) == "function")
		parent.TableComplexSeek("&SeekKey=$LoadSeek$&SeekParam=" + objattr(oFocus, "node"));
	if (typeof(parent.FormComlexSeek) == "function")
		parent.FormComlexSeek(objattr(oFocus, "node"));
	CalcelSel();
}

function CalcelSel()
{
	var o = idobj("InDlgDiv", parent.document);
	o.parentNode.removeChild(o);
}

function GetCondition()
{
var param = "", param1 = "", x, item, item1, andor, value;
	var tab = idobj("SelectedList");
	for (x = 0; x < tab.rows.length; x++)
	{
		if (objattr(tab.rows[x].cells[2], "sql") != null)
			item = tab.rows[x].cells[0].value + objattr(tab.rows[x].cells[2], "sql");
		else
		{
			if (objattr(tab.rows[x].cells[2], "node") == null)
				value = objtext(tab.rows[x].cells[2]);
			else
				value = objattr(tab.rows[x].cells[2], "node");
			item = GetSeekItem(tab.rows[x].cells[0].value, value, parseInt(tab.rows[x].cells[1].value), objattr(tab.rows[x].cells[0], "node"));
			if (tab.rows[x].getAttribute("type") == "custom") 
			{		//如果是自定义的条件字段
				if (typeof parent.getCustomCondition == "function")
					item = parent.getCustomCondition(tab.rows[x], item);
				else
				{
					param1 += "||" + tab.rows[x].cells[0].value + "=" + tab.rows[x].cells[1].value +
						"," + tab.rows[x].cells[3].value + "," + objtext(tab.rows[x].cells[2]);
					item = "";
				}
			}
		}
		if (item != "")
		{
			if (param == "")
				param = item
			else
				param = param + andor + item
		}
		andor = " " + tab.rows[x].cells[3].value + " ";
	}
	return param + param1;
}

function ConfirmCondition()
{
	var param = GetCondition();
	if (param == "")
	{
		if (document.getElementsByName("Content")[0].value != "")
		{
			InsertCondition();
			param =  GetCondition();
		}
	}
	
	if (typeof(parent.TableMenuComplexSeek) == "function")
		parent.TableMenuComplexSeek("&SeekParam=" + param);
	if (typeof(parent.FormComlexSeek) == "function")
		parent.FormComlexSeek(param);

	CalcelSel();
}

function GetSeekItem(SeekKey, SeekParam, SeekChoice, KeyType)
{
var ch;
	if (SeekParam.length > 50)
		SeekParam = SeekParam.substr(0, 50);
	switch (parseInt(SeekChoice))
	{
	case 1:
		return SeekKey + "=" + GetFieldTypeValue(SeekParam, KeyType)
	case 2:
		return SeekKey + "<>" + GetFieldTypeValue(SeekParam, KeyType)
	case 3:
		return SeekKey + ">" + GetFieldTypeValue(SeekParam, KeyType)
	case 4:
		return SeekKey + "<" + GetFieldTypeValue(SeekParam, KeyType)
	case 5:
		return SeekKey + ">=" + GetFieldTypeValue(SeekParam, KeyType)
	case 6:
		return SeekKey + "<=" + GetFieldTypeValue(SeekParam, KeyType)
	case 7:
		return SeekKey + " like '" + SeekParam + "*'"
	case 8:
		return SeekKey + " like '*" + SeekParam + "'"
	case 9:
		return SeekKey + " like '*" + SeekParam + "*'"
	default:
		return "true";
	}
}

function SelectFilterField(obj)
{
	var sel = obj.options[obj.selectedIndex];
	var Content = document.getElementsByName("Content")[0];
	objattr(Content, "FieldType", objattr(sel, "node"));
	Content.value = "";
	objattr(Content, "node", null);
	var ComboImg = idobj("ComboImg");
	var quote = objattr(sel, "quote");
	if ((quote == "") && (objattr(sel, "node") != 4))
	{
		ComboImg.style.display = "none";
		return;
	}
	if (SelectFilterCombo(ComboImg))
	{
		ComboImg.style.display = "inline";
 		if  (objattr(sel, "node") != 4)
 			objattr(Content, "FieldType", 1);
	}
}

function SelectFilterCombo(obj)
{
	var FieldsSel = idobj("FieldsSel");
	var sel = FieldsSel.options[FieldsSel.selectedIndex];
	document.getElementsByName("Content")[0].focus();
	if (objattr(sel, "node") == 4)
	{
		CBSelectDate(idobj("ComboImg"));
		return true;
	}
	var fun = function(result)
	{
		objattr(obj.previousSibling, "data", result);
		UserCombo(obj.previousSibling, result);
	}
	var quote = objattr(sel, "quote");
	switch (quote.substr(0, 1))
	{
	case "(":
		UserCombo(obj.previousSibling, quote.substr(1, quote.length - 2));
		return true;
	case "@":
		if (objattr(obj.previousSibling, "data") == null)
			AjaxRequestPage(psubdir + "seleenum.jsp?EnumType=" + quote.substr(1) + "&AjaxMode=1", true, "", fun);
		else
			UserCombo(obj.previousSibling, objattr(obj.previousSibling, "data"));	
		return true;
	case "$":
		if (objattr(obj.previousSibling, "data") == null)
			AjaxRequestPage(psubdir + "seleenum.jsp?EnumType=" + quote + "&AjaxMode=1", true, "", fun);
		else
			UserCombo(obj.previousSibling, objattr(obj.previousSibling, "data"));	
		return true;
	default:
		var ss = quote.split(",")
		if (ss.length == 1)
			return false;
		var s1 = ss[0].split(".");
		if (s1[1] == ss[1])
			return false;
		AjaxRequestPage(psubdir + "SeleQuoteTable.jsp?AjaxMode=1&nDB=&TableName=" + s1[0] + "&QuoteField=" + s1[1] + "&AliasField=" + ss[1],
			true, "", fun);
		return true;
	}
}

function SelectCatalog(obj)
{
	SelObject(obj);
	idobj("SeekButton").disabled = false;
	document.getElementsByName("DeleteButton")[0].disabled = false;
}


function UserCombo(obj, items, value, width, height)
{
var oDiv, pos, ss, tag, item, x
	oDiv = document.getElementById("ComboTempDiv");
	if (oDiv != null)
		oDiv.removeNode(true);

	pos = GetObjPos(obj.parentNode, document.body);
	if (typeof(width) == "undefined")
		width = pos.right - pos.left;
	if (typeof(height) == "undefined")
		height = 200;
	document.body.insertAdjacentHTML("beforeEnd", "<div ID=ComboTempDiv width=0 " +
		"style='position:absolute;border:1px solid black;left:" + pos.left + ";top:" + pos.bottom +
		";width:" + width +";height:" + height + ";background-color:highlighttext;overflow-y:auto;line-height:18px;'></div>");
	oDiv = idobj("ComboTempDiv");
	objevent(document.body, "mousedown", function()
	{
		var evt = getEvent();
		if (evt.srcElement == oDiv)
			return;
		if (evt.srcElement == oFocus)
		{
			obj.value = objtext(oFocus);
			objattr(obj, "node", objattr(oFocus, "node"));
		}
		oDiv.parentNode.removeChild(oDiv);
		objevent(document.body, "mousedown", arguments.callee, 1);
	});
	

	ss = items.split(",");
	tag = "";
	for (x = 0; x < ss.length; x++)
	{
		item = ss[x].split(":");
		if (item.length == 2)
			tag += "<div onmouseover=SelObject(this) style=width:100%; node=" + item[0] + ">" + item[1] + "</div>";
	}


	oDiv.innerHTML = tag;
}

function InitSeekItemEvent()
{
	if (IsNetBoxWindow())
	{
		document.body.oncontextmenu = RightButtonMenu;
	}

	var fun = function(data)
	{
		if (data != "")
		{
			window.oSearch.setData(data);
			window.oSearch.popDown();
		}
	};
	window.oSearch = new DynaEditor.Search(function (value)
	{
		if ((value != "") || (value.length < 50))
			AjaxRequestPage(AppendURLParam(href, "SeekKey=$AjaxGetKeyword$&SeekParam=" + value), true, "", fun);
		return "";
	}, TableWholeDocSeek);
//	window.oSearch = new DynaEditor.List("1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z");
	var SearchInput = idobj("SearchInput");
	if (SearchInput != null)
	{
		if ((SeekKey == "$ClipSearch$") || (SeekKey == "$WholeDoc$"))
		{
			SearchInput.value = unescape(SeekParam);
		}
//		window.oSearch.insert(SearchInput, 200, 20, SearchInput.value);
		window.oSearch.attach(SearchInput);
//		SearchInput.style.display = "none";
		window.oSearchOption = new CommonMenu([{item:"清除搜索结果",action:"TableWholeDocSeek('')"},
		{item:"启用跟踪剪贴板搜索",action:ClipSearch},{item:"高级搜索",action:TableMenuComplexSeek}]);
		SearchInput.previousSibling.style.cursor = "hand";
		SearchInput.previousSibling.onclick = function ()
		{
			window.oSearchOption.show();
		};
		
		if (SeekKey == "$ClipSearch$")
		{
			ClipSearch.value = SearchInput.value;
			ClipSearch();
		}				
	}
	
	if (typeof(RollBkColor) == "undefined")
		return;
	var tab = idobj("SeekTable");
	if (tab != null)
	{
		for (var x = 1; x < tab.rows.length - 1; x++)
		{
			tab.rows[x].onmouseover = function (){RollSeekTable(this);};
			tab.rows[x].onmouseout = RollSeekTable;
		}
	}
}

function ClipSearch()
{
	var menu = window.oSearchOption.getmenu();
	if (typeof ClipSearch.timer  != "undefined")
	{
		window.clearInterval(ClipSearch.timer);
		ClipSearch.timer = undefined;
		window.oSearch.oEdit.lastChild.src="../pic/search.png";
		menu[1].img = "";
		return;
	}
	window.oSearch.oEdit.lastChild.src="../pic/360.png";
	menu[1].img = "../pic/flow_end.png";
	ClipSearch.timer = window.setInterval(function()
	{
		var text = window.clipboardData.getData("Text");
		if (text == null)
			return;
		var value = text.replace(/[ 　]+/g, "");
		if ((text.length > 0) && (text.length < 100) && (value != ClipSearch.value))
		{
			ClipSearch.value = value;
			window.oSearch.setValue(value);
			ClipSearch();
			TableWholeDocSeek(value, "$ClipSearch$");
		}
	},500);
}

var oRollObj;
function RollSeekTable(obj)
{
	if ((obj == oRollObj) || (obj == oFocus))
		return;
		
	if (RollBkColor.substr(0, 1) == ".")
	{
		if (typeof(oRollObj) == "object")
			oRollObj.className = "";
		oRollObj = 0;
		if (obj == null)
			return;
		if ((obj.tagName) != "TR")
			return;
		if (obj == oFocus)
			return;
		oRollObj = obj;
		if (typeof(oRollObj) != "object")
			return;
		oRollObj.className = "RollOverObj";
		return;
	}
		
	if (typeof(oRollObj) == "object")
	{
		oRollObj.runtimeStyle.backgroundColor = "";
		oRollObj.runtimeStyle.color = "";
	}
	oRollObj = 0;
	if (obj == null)
		return;
	if ((obj.tagName) != "TR")
		return;
	oRollObj = obj;
	if (typeof(oRollObj) != "object")
		return;
	oRollObj.runtimeStyle.backgroundColor = RollBkColor
	oRollObj.runtimeStyle.color = RollFgColor;
}
//</script>