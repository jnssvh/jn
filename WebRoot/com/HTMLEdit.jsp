<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

//<script language=javascript type="text/javascript">
/////////////////////////////////////HTML Editor function
function InitHTMLData(obj)
{
	if (obj.ownerDocument.readyState != "complete")
		return window.setTimeout(function(){InitHTMLData(obj);}, 300);

var oText = obj.nextSibling;
var oTR = obj.parentNode.parentNode.previousSibling;
	obj.contentWindow.onerror = function(){	return false;};
	for (var x = 0; x < oTR.cells.length; x++)
		oTR.cells[x].UNSELECTABLE = "on";
	if (oText.value != "")
	{

		if (oText.value.toUpperCase().indexOf("<HTML>") >= 0)
			obj.contentWindow.document.write(oText.value);
		else
			obj.contentWindow.document.write("<HTML><head><link rel=stylesheet type=text/css href=../com/forum.css>" +
				"</head><BODY>" + oText.value + "</BODY><HTML>");
//		obj.contentWindow.document.close();
	}
	SetHTMLEditorMode(oTR, obj);
}

function SetHTMLEditorMode(obj, oFrame)
{
	var win = oFrame.contentWindow;
	if (obj.style.display == "none")
	{
		win.document.body.contentEditable = "false";
		win.document.oncontextmenu = null;
		win.document.onclick = null;
	}
	else
	{
		win.document.body.contentEditable = "true";
		win.document.oncontextmenu = function () {return HTMLEditorMenu(obj);};
		win.document.onmouseup = function () { return SetHTMLEditorStatus(obj);};
		win.document.onkeydown = function () { return HTMLEditorKeyFilter(obj);};
		win.document.onkeyup = function () { return SetHTMLEditorStatus(obj);};
	}
}

function HTMLEditorKeyFilter(obj)
{
var e = obj.nextSibling.all.HTMLEditFrame.contentWindow.event;
	if ((e.keyCode == 37) && (e.altKey))
		return alert("<j:Lang key="HTMLEdit.Houtijian"/>");
	if (obj.ownerDocument.body.onbeforeunload == null)
		obj.ownerDocument.body.onbeforeunload = function () {event.returnValue='';};
}

function HTMLEditorMenu(obj)
{
	var win = document.getElementById("HTMLEditFrame").contentWindow;
//	return false;
}

function SetHTMLEditorStatus(obj)
{
	var win = document.getElementById("HTMLEditFrame").contentWindow;
	if (document.getElementById("ForeColorImg") != null)
	{
		var value = win.document.queryCommandValue('ForeColor');
		if (value != null)
			document.getElementById("ForeColorImg").style.backgroundColor = RGBColor(value);
	}
	if (document.getElementById("BackColorImg") != null)
	{
		value = win.document.queryCommandValue('BackColor');
		if (value != null)
			document.getElementById("BackColorImg").style.backgroundColor = RGBColor(value);
	}
	if (document.getElementById("StatusToolSpan") != null)
	{
		var tools = document.getElementById("StatusToolSpan").getElementsByTagName("IMG");
		for (var x = 0; x < tools.length; x++)
		{
			if (typeof(tools[x].cmd) == "undefined")
				continue;
			value = win.document.queryCommandValue(tools[x].cmd);
			SetHTMLButtonStauts(tools[x], value ? 0 : 1);
		}
	}
}

function RGBColor(color)
{
	var rgb = "00000" + color.toString(16);
	rgb = rgb.substr(rgb.length - 6);
	return "#" + rgb.substr(4, 2) + rgb.substr(2, 2) + rgb.substr(0, 2);
}

function HTMLTextFormat(oImg, bface)
{
	var oTable = FindParentObject(oImg, null, "TABLE");
	if (oTable.all.HTMLEditFrame.style.display == "none")
		return;
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
	if (typeof(bface) == "undefined")
		oTable.all.HTMLEditFrame.contentWindow.document.execCommand(oImg.cmd);
	else
		oTable.all.HTMLEditFrame.contentWindow.document.execCommand(oImg.cmd, bface);
	SetHTMLButtonStauts(oImg);
}

function SetHTMLButtonStauts(oImg, node)
{
	var oTable = FindParentObject(oImg, null, "TABLE");
	eval("var objs = oTable.all." + oImg.name + ";");
	if ((typeof(node) != "undefined") || (typeof(objs.length) == "undefined"))
	{
		if (typeof(node) == "undefined")
			node = oImg.node;
		if (node == 0)
		{
			oImg.node = 1;
			oImg.style.border = "1px inset gray";
			oImg.oldborder = oImg.style.border;
			oImg.style.margin = "0px";
			oImg.oldmargin = oImg.style.margin;
		}
		else
		{
			if (node == 1)
			{
				oImg.node = 0;
				oImg.style.border = "0px none";
				oImg.oldborder = oImg.style.border;
				oImg.style.margin = "1px";
				oImg.oldmargin = oImg.style.margin;
			}
		}
		return;
	}
	oImg.node = 1;
	oImg.style.border = "1px inset gray";
	oImg.oldborder = oImg.style.border;
	oImg.style.margin = "0px";
	oImg.oldmargin = oImg.style.margin;
	for (var x = 0; x < objs.length; x++)
	{
		if (objs[x] != oImg)
		{
			objs[x].node = 0;
			objs[x].style.border = "0px none";
			objs[x].oldborder = oImg.style.border;
			objs[x].style.margin = "1px";
			objs[x].oldmargin = oImg.style.margin;
		}
	}
}

function SetColorCmd(oImg)
{
	var color = SelectColor(0, oImg.style.backgroundColor);
	var oTable = oImg.parentNode.parentNode.parentNode.parentNode;
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
	if (typeof(color) != "string")
		return;
	oTable.all.HTMLEditFrame.contentWindow.document.execCommand(oImg.cmd, false, color);
	oImg.style.backgroundColor = color;
}

function ChangeFontSize(obj)
{
	var oFonts = obj.getElementsByTagName("FONT");
	MenuEditHTMLCommand(obj, "FontSize", oFonts[0].size);
}

function ChangeFont(obj)
{
	MenuEditHTMLCommand(obj, "FontName", obj.innerText);
}

function SelectFormatBlock(obj, tag)
{
	MenuEditHTMLCommand(obj, "FormatBlock", "<" + tag + ">");
}

function MenuEditHTMLCommand(obj, command, param)
{
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
	document.execCommand(command, false, param);
	HideSubMenu(oSpan);
}

function SetHTMLMode(oImg)
{
	var oTable = oImg.parentNode.parentNode.parentNode.parentNode;
	if (CopyHTMLData(oTable.all.HTMLEditFrame) == false)
	return alert("<j:Lang key="HTMLEdit.Moshi_fail"/>");
	var oText = oTable.getElementsByTagName("TEXTAREA");
	if (oImg.node == 0)
	{
		oTable.all.DesignToolsSpan.style.display = "none";
		oTable.all.HTMLEditFrame.style.display = "none";
		oText[0].style.display = "inline";
		oImg.node = 1;
	}
	else
	{
		oTable.all.DesignToolsSpan.style.display = "inline";
		oTable.all.HTMLEditFrame.style.display = "inline";
		oText[0].style.display = "none";
		oImg.node = 0;
	}
}

function PreviewMode(oImg)
{
	var oTable = oImg.parentNode.parentNode.parentNode.parentNode;
	CopyHTMLData(oTable.all.HTMLEditFrame);
	var oText = oTable.getElementsByTagName("TEXTAREA");
	window.showModalDialog(psubdir + "blank.htm", oText[0], 
		"dialogWidth:640px;dialogHeight:480px;scroll:1;help:0;status:1;resizable:1");
}

function InsertTable(obj)
{
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	var tag = showModalDialog(psubdir + "HTMLtable.htm", window, "dialogWidth:22em; dialogHeight:20em; status:0;scroll:no;");
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
	if (typeof(tag) == "string")
	{
	 	var oRange = document.selection.createRange();
		oRange.pasteHTML(tag);
	}
}

function InsertRow(obj)
{
var newRow, newCell, x;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	oTable = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TABLE");
	if (oTable != null)
	{
		newRow = oTable.insertRow();
		for (x = 0; x < oTable.rows[0].cells.length; x++)
		{
			newCell = newRow.insertCell();
			newCell.bgColor = oTable.rows[0].cells[x].bgColor;
		}
	}
}

function DeleteRow(obj)
{
var oTR;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	var oTR = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TR");
	if (oTR != null)
		oTR.removeNode(true);
}

function InsertCol(obj)
{
var oTable, newCell, x;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	oTable = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TABLE");
	if (oTable != null)
	{
		for (x = 0; x < oTable.rows.length; x++)
		{
			newCell = oTable.rows[x].insertCell();
			newCell.bgColor = oTable.rows[x].cells[0].bgColor;
		}
	}
}

function DeleteCol(obj)
{
var oTD, oTable, x, pos;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	var oTD = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TD");
	if (oTD != null)
	{
		oTable = oTD.parentNode.parentNode.parentNode;
		pos = oTD.cellIndex;
		for(var x = 0; x < oTable.rows.length; x++)
			oTable.rows[x].cells[pos].removeNode(true);
	}
}

function InsertCell(obj)
{
var oTD, newCell;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	var oTD = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TD");
	if (oTD != null)
	{
		newCell = oTD.parentNode.insertCell();
		newCell.bgColor = oTD.bgColor;
	}
}

function DeleteCell(obj)
{
var oTD;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	var oTD = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TD");
	if (oTD != null)
		oTD.removeNode(true);
}

function ExCell(obj, value)
{
var oTD;
	var oSpan = FindParentObject(obj, document.body, "SPAN");
	HideSubMenu(oSpan);
	var oTable = FindParentObject(oSpan, document.body, "TABLE");
	var oTD = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "TD");
	if (oTD != null)
	{
		if (value == 1)
			oTD.colSpan = oTD.colSpan + 1;
		if (value == 2)
			oTD.rowSpan += 1;
	}
}

function GetRangeObj(obj, tag)
{
	obj.focus();
	var target = null, item;
	var ttype = obj.ownerDocument.selection.type;
	var selrange = obj.ownerDocument.selection.createRange();
	
	switch(ttype)
	{
	case 'Control' :
		if (selrange.length > 0 ) 
			target = selrange.item(0);
	break;
	case 'None' :
		target = selrange.parentElement();
		break;
	case 'Text' :
		target = selrange.parentElement();
		break;
	}

	if (tag == "")
		return target;
	for (item = target; (item != null) && (item != obj); item = item.parentElement)
	{
		if (item.tagName == tag)
			return item;
	}
	return null;
}


function CopyHTMLData(obj)
{
var oFrames, oText, x;
	if (typeof(obj) != "object")
		return false;
	oText = obj.nextSibling;
	if (oText.ReqHTML == 1)
	{
		if (oText.style.display == "none")
		{
			var oHTMLs = obj.contentWindow.document.getElementsByTagName("HTML");
			oText.value = oHTMLs[0].outerHTML;
		}
		else
		{
			obj.contentWindow.document.write(oText.value);
			obj.contentWindow.document.close();
			obj.contentWindow.document.designMode = "On";
		}
		return true;
	}
	if (oText.style.display == "none")
	{
		if (obj.contentWindow.document.body != null)
			oText.value = obj.contentWindow.document.body.innerHTML;
		else
		{
			var oHTMLs = obj.contentWindow.document.getElementsByTagName("HTML");
			oText.value = oHTMLs[0].innerHTML;
		}
	}
	else
	{
		if (obj.contentWindow.document.body != null)
		{
			obj.contentWindow.document.body.innerHTML = oText.value;
			obj.contentWindow.document.body.contentEditable = true;
		}
		else
			return false;
	}
	return true;
}

var oFocusTD;
function SelHTMLDocObj(oDiv)
{
	return;
	if (typeof(oFocusTD) == "object")
		oFocusTD.style.border = "";
	var oTD = GetRangeObj(oDiv, "TD");
	if (oTD != null)
	{
		if (oTD.parentNode.parentNode.parentNode.border != 0)
			return;
		oFocusTD = oTD;
		oTD.style.border = "1px solid red";
	}	
}

function HTMLDocObjProp(oImg)
{
	var oTable = oImg.parentNode.parentNode.parentNode.parentNode;
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
	var obj = GetRangeObj(oTable.all.HTMLEditFrame.contentWindow.document.body, "");
	window.showModelessDialog(psubdir + "HTMLProp.htm", obj,
		"dialogWidth:320px;dialogHeight:400px;status:0;scroll:0;help:0");
	SetHTMLButtonStauts(oImg);
//	if (typeof(oImg) == "object")
//		oImg.style.borderStyle = "outset";
}

function InsertImage(obj)
{
	var oTable = FindParentObject(obj, null, "TABLE");
	if (oTable.all.HTMLEditFrame.style.display == "none")
		return;
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
//	HTMLTextFormat(obj, true);
	var tag = showModalDialog(psubdir + "SelectImg.htm", obj, "dialogWidth:480px; dialogHeight:240px; status:0;scroll:no;");
	oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
	if (typeof(tag) == "string")
	{
	 	var oRange = document.selection.createRange();
		oRange.pasteHTML(tag);
	}
}
//--------------------------------------------------HTML Editor End

function HTMLStartUploadFile(obj)
{
	document.all.FormDataFrame.src = psubdir + "uploadform.jsp?ParentName=¡Ÿ ±π≤œÌÕº∆¨";
	var fun = function()
	{
		try
		{
			document.all.FormDataFrame.contentWindow.document.all.LocalName.click();
		}
		catch (e)
		{
			window.setTimeout(fun, 500);
			return;
		}
		if (document.all.FormDataFrame.contentWindow.document.all.LocalName.value == "")
			return;
		document.all.FormDataFrame.contentWindow.SubmitForm();
	}
	window.setTimeout(fun, 500);
	var oldcallback = window.SubmitLocalFileOK;
	window.SubmitLocalFileOK = function(FileType, AffixID, FileCName)
	{
		window.SubmitLocalFileOK = oldcallback;
		var oTable = FindParentObject(obj, null, "TABLE");
		if (oTable.all.HTMLEditFrame.style.display == "none")
			return;
		oTable.all.HTMLEditFrame.contentWindow.document.body.focus();
		var oRange = document.selection.createRange();
		oRange.pasteHTML("<a href='" + psubdir + "down.jsp?AffixID=" + 
			AffixID + "'>&nbsp;" + FileCName + "&nbsp;</a>");
	}
}

//<script>

