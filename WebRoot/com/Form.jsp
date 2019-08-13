<%@page import="com.jaguar.Config"%>
<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
//<script type="text/javascript">
function SubmitForm(obj, option)
{
var x, sels;
	var evt = getEvent();
	if (evt != null)
		SetHTMLEditorData(evt.ctrlKey);
//	sels = document.getElementsByName("TextReadOnlyViewDiv");
//	sels = objall("DIV", "TextReadOnlyViewDiv");
	sels = objsbyname("TextReadOnlyViewDiv", "DIV");
	for (x = 0; x < sels.length; x++)
	{
		var o = sels[x].previousSibling;
		if ((o != null) && (o.tagName == "INPUT") && (o.type == "hidden"))
		{
			if (o.ReqText == 1)
				o.value = objtext(sels[x]);
			else
				o.value = sels[x].innerHTML;
		}
	}

	sels = document.getElementsByTagName("INPUT");
	for (x = 0; x < sels.length; x++)
	{
		if (sels[x].value == sels[x].title)
			sels[x].value = "";
	}

	for (x = 0; x < OfficeInputObj.length; x++)
	{
		if (OfficeInputObj[x].SaveDoc(arguments.callee) == false)
			return false;
	}
	
	if (option != "nocheck")
	{
		if (CheckForm() == false)
			return false;
	}
	sels = document.getElementsByTagName("SELECT");
	for (x = 0; x < sels.length; x++)
		sels[x].disabled = false;
	sels = document.getElementsByTagName("INPUT");
	for (x = 0; x < sels.length; x++)
		sels[x].disabled = false;
	if (typeof(obj) == "object")
		obj.disabled = true;
	if (option == 1)
		idobj("PrintFlag").value = 1;
	var sm = 0;
	if (typeof(SubmitMode) != "undefined")
		sm = SubmitMode;
	if ((typeof(window.dialogHeight) != "undefined") && (sm == 0))
		sm = 1;
	Submitting(sm);
}

function Submitting(sm)
{
	document.body.onbeforeunload = null;
	var form = document.getElementsByName("ActionSave")[0];
	switch (sm)
	{
	case 0:			//直接提交到本页面
		return form.submit();
	case 1:			//提交到隐藏IFRAME
		form.target = "FormDataFrame";			
		return form.submit();
	case 2:			//弹出内部对话框，并提交
		NewFrameWin("about:blank", "width=640,height=200");
		form.target = "IFrameDlg";
		var evt = getEvent();
		try {
			var src = typeof evt.srcElement == "undefined" ? evt.target : evt.srcElement;
			src.disabled = true;
		} catch (e) {
		}
		return form.submit();
	}
}

function AppendLine()
{
	var value = new Number(idobj("Count").value);
	value ++;
	var oTR = idobj("SampleTR");
	if (document.getElementById("LineCountTR") == null)
		var oNewTR = oTR.parentNode.insertRow();
	else
		var oNewTR = oTR.parentNode.insertRow(oTR.parentNode.rows.length - 1);
	oNewTR.bgColor = oTR.bgColor;
	oNewTR.onclick = oTR.onclick;
	oNewTR.ondblclick = oTR.ondblclick;
	var re = new RegExp("_0", "g"); 
	for (var x = 0; x < oTR.cells.length; x++)
	{
		var oTD = oNewTR.insertCell();
		oTD.id = oTR.cells[x].id;
		oTD.noWrap = oTR.cells[x].noWrap;
		oTD.innerHTML = oTR.cells[x].innerHTML.replace(re, "");
	}
	idobj("Count").value = value;
	SelectObj(oNewTR);
	AutoNumber(oTR.parentNode);
	idobj("MultiDIV").style.width = "80%";	//解决不能对齐的问题。
	idobj("MultiDIV").style.width = "100%";
	return oNewTR;
}

function DeleteLine()
{
	if (typeof(oFocus) != "object")
	{
		alert("<j:Lang key="Form.No_delete"/>");
		return;
	}
	if (confirm("<j:Lang key="Form.Xuanze_delete"/>"))
	{
		var value = new Number(idobj("Count").value);
		if (value == 1)
		{
			alert("<j:Lang key="Form.Nodelete"/>");
			return;
		}
		value --;
		idobj("Count").value = value;
		oFocus.removeNode(true);
		AutoNumber(idobj("MultiLineTable"));
		oFocus = 0;
	}
}

function AutoNumber(oTable)
{
	for (var x = 2; x < 2 + Number(idobj("Count").value); x++)
	{
		objall(oTable.rows[x].cells[0], "SerialSpan").innerHTML = x - 1;		
	}
}

function ExecWeb(nCommand)
{
	idobj("MenuBarTable").style.display = "none";
	idobj("WBobj").ExecWB(nCommand, 1);
	idobj("MenuBarTable").style.display = "inline";
}


function ArrangePage()
{
	ArrangeTable(idobj("FormTableObj"));
	ArrangeTable(idobj("FormTableObj1"));
	ArrangeTable(idobj("MultiLineTable"));
	
}

function CheckFormValue(oForm)
{
	var oInputs = oForm.getElementsByTagName("INPUT");
	if (CheckInputs(oInputs) == false)
		return false;
	oInputs = oForm.getElementsByTagName("TEXTAREA");
	if (CheckInputs(oInputs) == false)
		return false;
	oInputs = oForm.getElementsByTagName("SELECT");
	for (var x = 0; x < oInputs.length; x++)
	{
		if ((objattr(oInputs[x], "bRequired") ==1) && (oInputs[x].name.substr(oInputs[x].name.length - 2) != "_0"))
		{
			if (oInputs[x].value == "")
			{
				var obj = document.getElementById("T1_" + oInputs[x].name);
				alert("[" + objtext(obj) + "] <j:Lang key="Form.Bitian"/> ");
				oInputs[x].focus();
				return false;
			}
		}
	}
	return true;
}

function ArrangeTable(oTable)
{
var x, y, objs;
	if (typeof(oTable) != "object")
		return;
	for (x = 0; x < oTable.cells.length;x++)
	{
		objs = oTable.cells[x].getElementsByTagName("INPUT");
		if (objs.length > 0)
		{	
			for (y = 0; y < objs.length; y++)
			{
				if (objs[y].type == "text")
				{
					oTable.cells[x].innerHTML = objs[y].value;
					oTable.cells[x].noWrap  = true;
				}
			}
		}
	}
}


function PressKey(obj)
{
	var evt = getEvent();
	if (typeof(obj) != "object")
		obj = evt.srcElement;
	obj = evt.srcElement;
	if (parseInt(objattr(obj, "FieldType")) == 4)
		return PressDateTime(obj);
	if (PressDefaultKey(obj))
		return false;

	switch (parseInt(objattr(obj, "nFormat")))
	{
	case 1:		//
		break;
	case 2:		//只允许英文
		if ((evt.keyCode < 65) || (evt.keyCode > 90))
		{
			evt.returnValue = false;
			return false;
		}
		break;
	case 3:		//只允许数字
		if (evt.keyCode == 229)	//微软拼音等输入法不能检测到数字，只好不过滤
			return;
		if ((evt.keyCode >= 48) && (evt.keyCode <= 57) && (evt.shiftKey == false))
			return;
		if ((evt.keyCode >= 96) && (evt.keyCode <= 105))
			return;
		evt.returnValue = false;
		return false;
	case 4:		//
		break;
	case 9:		//IP地址
		break;
	case 12:	//只允许数值
		if (objattr(obj, "FieldType") != 6)
			objattr(obj, "FieldType", 6);
		break;
	case 13:	//只允许日期
	case 14:	//只允许日期和时间
	case 15:	//只允许时间
		if (objattr(obj, "FieldType") != 4)
			objattr(obj, "FieldType", 4);
		break;
	default:
		break;
	}

	switch (parseInt(objattr(obj, "FieldType")))
	{
		case 6:			//单精度浮点
		case 7:			//双精度浮点
			if (((evt.keyCode == 190) && (evt.shiftKey == false)) || (evt.keyCode == 110))
			{
				if (obj.value.indexOf(".") == -1)
					return;
				else
				{
					t1 = document.selection.createRange();
					if (t1.text.indexOf(".") >= 0)
						return;
				}
			}
		case 5:			//自动编号
		case 3:			//数字
			if (evt.keyCode == 229)	//微软拼音等输入法不能检测到数字，不过滤
				return;
			if ((evt.keyCode >= 48) && (evt.keyCode <= 57) && (evt.shiftKey == false))
				return;
			if ((evt.keyCode >= 96) && (evt.keyCode <= 105))
				return;
			if (  (evt.keyCode == 109) ||((evt.keyCode == 189) && (evt.shiftKey == false)))
			{
				t1 = document.selection.createRange();
				t2 = obj.createTextRange();
				if (t1.boundingLeft == t2.boundingLeft)
					return;
			}
			evt.returnValue = false;
			return false;
//		case 4:
//			return PressDateTime(obj);
	}
}

function PressDefaultKey(obj)
{
	var oTab, oTR, oTD, x, y, t1, t2;
	oTD = obj.parentNode;
	oTR = oTD.parentNode;
	oTab = oTR.parentNode.parentNode;

	var evt = getEvent();
	switch (evt.keyCode)
	{
	case 37:		//LEFT KEY
		if ((obj.type == "text") || (obj.tagName == "TEXTAREA"))
		{
			t1 = document.selection.createRange();
			t2 = obj.createTextRange();
			if (t1.boundingLeft != t2.boundingLeft)
				return true;
		}
		if (document.selection.type == "Text")
			return true;		
		for (x = oTD.cellIndex - 1; x >= 0; x--)
		{
			if (SelectTDInputObj(oTR.cells[x]))
				return true;
		}
	case 38:		//UP KEY
		if ((obj.tagName == "SELECT") && evt.ctrlKey)
			return true;
		if (obj.tagName == "TEXTAREA")
		{
			t1 = document.selection.createRange();
			t2 = obj.createTextRange();
			if (t1.boundingTop > t2.boundingTop)
				break;
		}
		y = oTR.rowIndex - 1;
		if (y >= 0)
		{
			x = oTD.cellIndex;
			if (x >= oTab.rows[y].cells.length)
				x = oTab.rows[y].cells.length - 1;
			SelectTDInputObj(oTab.rows[y].cells[x]);
		}
		return true;
	case 39:		//RIGHT KEY
		if ((obj.type == "text") || (obj.tagName == "TEXTAREA"))
		{
			t1 = document.selection.createRange();
			t2 = obj.createTextRange();
			if (t1.boundingLeft != t2.boundingLeft + t2.boundingWidth)
				return true;
		}
		for (x = oTD.cellIndex + 1; x < oTR.cells.length; x++)
		{
			if (SelectTDInputObj(oTR.cells[x]))
				return true;
		}
	case 40:		//DOWN KEY
		if ((obj.tagName == "SELECT") && evt.ctrlKey)
			return true;
		if (obj.tagName == "TEXTAREA")
		{
			t1 = document.selection.createRange();
			t2 = obj.createTextRange();
			if (t1.boundingTop + t1.boundingHeight < t2.boundingTop + t2.boundingHeight)
				break;
		}
		y = oTR.rowIndex + 1;
		if ( y < oTab.rows.length)
		{
			x = oTD.cellIndex;
			if (x >= oTab.rows[y].cells.length)
				x = oTab.rows[y].cells.length - 1;
			SelectTDInputObj(oTab.rows[y].cells[x]);
		}
		return true;
	case 13:		//Enter
		if (obj.tagName != "TEXTAREA")
			evt.keyCode = 9;
		return true;
	case 8:			//BackSpace
	case 9:			//Tab
	case 45:		//Insert
	case 46:		//Delete
	case 36:		//Home
	case 35:		//End
	case 16:		//Shift
	case 17:		//Ctrl
	case 18:		//Alt
	case 20:		//CapsLock
	case 144:		//Num Lock
	case 33:		//PgUp
	case 34:		//PgDn
		return true;
	default:
		if (evt.ctrlKey)
			return true;
		if (evt.altKey)
			return true;
		return false;
	}
}


function PressDateTime(obj)
{
var c, x, y, p, t1, t2, fmt, fmt1;
	t1 = document.selection.createRange();
	var evt = getEvent();
	x = GetCaretPos(obj);
	fmt = "1752-01-01 00:00";
	fmt1 = "2999-12-31 23:59";
	if (obj.onblur == null)
		obj.onblur = function () {if (obj.changeflag==1) {obj.fireEvent("onchange");obj.changeflag=0;}};
	if (x < fmt.length)
	{
		c = "";
		if ((evt.keyCode >= 48) && (evt.keyCode <= 57) && (evt.shiftKey == false))
			c = String.fromCharCode(evt.keyCode);
		if ((evt.keyCode >= 96) && (evt.keyCode <= 105))
			c = String.fromCharCode(evt.keyCode - 48);
		if (c != "")
		{
//			if (t1.text != "")
//				t1.text = c;
//			else
			{
				p = obj.value.substr(x, 1);
				if ((p == "-") || (p == ":") || (p == " "))
					x ++;
				if (x > 0)
				{
					obj.value = obj.value.substr(0, x) + c + obj.value.substr(x + 1);
				}
				else
					obj.value = c + obj.value.substr(1);
				p = fmt.substr(x + 1, 1);
				if ((p == "-") || (p == ":") || (p == " ") || (p == ""))
				{
					obj.value = GetValidDateStr(obj.value, fmt, fmt1);
					x ++;
				}
				t1.moveStart("character", x + 1);
				t1.collapse(true); 
			}
			t1.select();
			obj.changeflag = 1;
		}
		switch (evt.keyCode)
		{
		case 39:
		case 13:
			obj.value = GetValidDateStr(obj.value, fmt, fmt1);
			y = (parseInt((x - 4) / 3) + 1) * 3 + 5;
			if ( y < 5)
				y = 5;
			t1.move("character", -20);
			t1.move("character", y);
			t1.moveEnd("character", 2);
			t1.select();
			break;
		case 37:
			obj.value = GetValidDateStr(obj.value, fmt, fmt1);
			y = (parseInt((x - 4) / 3) - 1) * 3 + 5;
			if ( y < 5)
			{
				t1.move("character", -20);
				t1.moveEnd("character", 4);
			}
			else
			{
				t1.move("character", -20);
				t1.move("character", y);
				t1.moveEnd("character", 2);
			}
			t1.select();
			break;
		case 8:			//BackSpace
		case 46:		//Delete
			break;
		default:
			if (PressDefaultKey(obj))
				return false;
		}
		evt.returnValue = false;
		return false;
	}
	else
	{
		if (PressDefaultKey(obj))
			return false;
	}

	evt.returnValue = false;
	return false;
}

function GetCaretPos(obj)
{
	var t = document.selection.createRange();
	t.collapse(); 
	t.moveStart("character", -obj.value.length);
	return t.text.length;
}


function CountField(obj, nField)
{
var oTable, oTR, nTD, x, value;
	oTable = obj.parentNode.parentNode.parentNode.parentNode;
	oTR = obj.parentNode.parentNode;
	for (nTD = 0; nTD < oTR.cells.length; nTD++)
	{
		if (oTR.cells[nTD] == obj.parentNode)
			break;
	}
	if (nTD == oTR.cells.length)
		return;
	value = "";
	for (x = 2; x < oTable.rows.length - 1; x++)
	{
		if (value == "")
			value = oTable.rows[x].cells[nTD].firstChild.value;
		else
			value += " + " + oTable.rows[x].cells[nTD].firstChild.value;
	}
	try
	{
		oTable.rows[oTable.rows.length -1].cells[nTD].innerHTML = eval(value);
	}
	catch(e)
	{
		alert("<j:Lang key="Form.error"/>" + e.description);
	}
	if (nField > 0)
		eval("ChangeObj" + nField + "(obj)");
	idobj("MultiDIV").style.width = "80%";	//解决不能对齐的问题。
	idobj("MultiDIV").style.width = "100%";
}

function StartSubmitLocalFile(obj, filter)
{
	if (typeof obj == "object")
		var parentName = objattr(obj, "node");
	else
		var parentName = obj;
	idobj("FormDataFrame").src = psubdir + "uploadform.jsp?ParentName=" + encodeURIComponent(parentName);
	window.setTimeout(function(){SubmitLocalFile(obj, filter)}, 500);
}

function SubmitLocalFile(obj, filter)
{
	var frame = idobj("FormDataFrame");
	var LocalName = idobj("LocalName", frame.contentWindow.document);
	try
	{
		LocalName.click();
	}
	catch (e)
	{
		window.setTimeout(function(){SubmitLocalFile(obj)}, 500);
		return;
	}
	
	/** w3c不阻塞LoclaName.click选择文件事件问题 lxt 2017.5.26 **/
	if(window.g_timerSaittingSelectFileOK)
		window.clearTimeout(window.g_timerSaittingSelectFileOK);
	window.g_waittingSelectFileOKTimes=1;
	var func=function(){
		if(!LocalName.value&&window.g_waittingSelectFileOKTimes++ < 200)
			window.g_timerSaittingSelectFileOK=setTimeout(func, 500);
		else{
			SubmitLocalFileOK.obj = obj;
			frame.contentWindow.SubmitForm();
		}
	};
	if(window.addEventListener){
		window.g_timerSaittingSelectFileOK=setTimeout(func, 3000);
		return;
	}
	/****/
	
	if (LocalName.value == "")
		return SubmitLocalFileOK();
	if (typeof filter == "string")
	{
		var e = LocalName.value.toLowerCase();
		var f =filter.split(",");
		for (var x = 0; x < f.length; x++)
		{
			if (f[x].toLowerCase() == e.substr(e.length - f[x].length))
				break;
		}
		if (x == f.length)
		{
			alert("不支持的文件格式，不能上传");
			return SubmitLocalFileOK();
		}
	}
	//document.all.FormDataFrame.contentWindow.document.all.SecretType.value = 6;
	//document.all.FormDataFrame.contentWindow.document.all.FileLife.value = 31;
//	obj.previousSibling.innerText = "<j:Lang key="Form.Fasong_file"/>";
	SubmitLocalFileOK.obj = obj;
	frame.contentWindow.SubmitForm();
}

function SubmitLocalFileOK(FileType, AffixID, FileCName)
{
	if (FileType == undefined)
		return;
	var obj = SubmitLocalFileOK.obj;
	SubmitLocalFileOK.obj = undefined;
	if (typeof(obj) != "object")
		return alert("上传文件" + FileCName + "成功");
	if ((obj.tagName != "IMG") && (obj.tagName != "INPUT"))
	{
		obj.firstChild.value = AffixID;
		obj.lastChild.src = "/down.jsp?Thumb=1&AffixID=" + AffixID;
		return;
	}
	var oInput = obj.parentNode.getElementsByTagName("INPUT");
//	if ((objattr(oInput[1], "FieldType") == 1) || (objattr(oInput[1], "FieldType") == 2))
	{
//		if (oInput[0].nextSibling.tagName == "INPUT")
//		{
//			oInput[0].nextSibling.style.display = "none";
//			oInput[0].insertAdjacentHTML("afterEnd", "<span class=spantext style='margin-right:45px'></span>");
//		}
		if (oInput[0].value == "")
			oInput[0].value += AffixID;
		else
			oInput[0].value += "," + AffixID;
		var inHtml = oInput[0].nextSibling.innerHTML;
		inHtml += "<a href=" + psubdir + "down.jsp?AffixID=" + AffixID + ">" + 
			"<img style='border:none;vertical-align:middle;' src=" + psubdir + "../pic/Affix.gif>" + FileCName +
			"&nbsp;</a><img onclick=DeleAffixOne(this) align=middle title=删除此附件 style=cursor:hand; src=" + psubdir +
			"pic/closewin.gif>";
		var openOfficePath = "<%=Config.getItem("OpenOfficePath") %>";
		if (typeof openOfficePath != "undefined" && openOfficePath != "") {
			var previous = "<img onclick=PreviousAffixOne(this) align=middle  style=cursor:hand;margin-left:5px;";
			if (!/.*\.(docx?|xlsx?|pptx?|pdf|jpg|jpeg|gif|png|bmp|txt|htm|html)$/i.test(FileCName)) {
				previous += "filter:gray;-moz-opacity:.1;opacity:0.1; title=系统不能识别该文件格式，无法预览";
			} else {
				previous += " title=预览此附件";
			}
			previous += " src=" + gRootPath +
				"com/pic/previous.png>";
			inHtml += previous;
		}
		inHtml += "<span>&nbsp;&nbsp;;</span><br>";
		oInput[0].nextSibling.innerHTML = inHtml;
		ResizeActionWin();
	}
//	else
//	{
//		oInput[0].value = AffixID;
//		oInput[1].value = FileCName;
//	}
	if (typeof uploadEndEvent == "function") {
		uploadEndEvent(FileType, AffixID, FileCName);
	}
}

function DeleAffixOne(obj)
{
	if (window.confirm("删除已上传的附件？") == false)
		return;
	var oSpan = obj.parentNode;
	var oInput = oSpan.previousSibling;
	var objs = oSpan.getElementsByTagName("A");
	var values = oInput.value.split(",");
	var value = "";
	for (var x = 0; x < objs.length; x++)
	{
		if (objs[x] != obj.previousSibling)
		{
			if (value == "")
				value += values[x];
			else
				value += "," + values[x];
		}
		else
			AjaxRequestPage(psubdir + "upload.jsp?option=DeleteFile&fileName0=" + values[x]);
	}
	oInput.value = value;
	//obj.nextSibling.nextSibling.removeNode(true);
	//obj.nextSibling.removeNode(true);
	//obj.previousSibling.removeNode(true);
	//obj.removeNode(true);
	// 换成兼容w3c lxt 2017.6.1
	obj.nextSibling.nextSibling.parentNode.removeChild(obj.nextSibling.nextSibling);
	obj.nextSibling.parentNode.removeChild(obj.nextSibling);
	obj.previousSibling.parentNode.removeChild(obj.previousSibling);
	obj.parentNode.removeChild(obj);
	
	ResizeActionWin();
}


function PreviousAffixOne(obj)
{
	var fileName = "", url = "";
	if (obj.previousSibling.previousSibling != null && obj.previousSibling.previousSibling.tagName.toLowerCase() == "a") {
		fileName = obj.previousSibling.previousSibling.innerText;
		url = obj.previousSibling.previousSibling.href;
	} else {
		fileName = obj.previousSibling.innerText;
		url = obj.previousSibling.href;
	}
	if (!/\.((doc|xls|ppt)x?)|pdf|jpg|jpeg|gif|png|bmp|txt|htm|html$/i.test(fileName)) {
		alert("系统不能识别该文件，无法预览");
		return;
	}
	var _affixId = url.replace(/^.*AffixID=(\d+)$/, "$1");
	previewFile(fileName, _affixId);
}

function previewFile(fileName, id) {
	  //var fileExtName = fileName.match(/^.*?\.(.+)$/)[1];
	  //alert(fileExtName)
	  fileName = fileName.replace(/\s+$/g, "");
	  
	  if (/.*\.(?:jpg|jpeg|png|gif|bmp)\s*$/i.test(fileName)) {
	    HTMLDlgBox("预览文件 - " + fileName, "<img src='../com/down.jsp?inpage=true&AffixID="
	    + id + "' ondblclick='window.open(this.src)' onload='setSize(this)'"
	    + " title='双击图片在新窗口中打开'"
	    + " onerror=\"this.outerHTML='<div style=text-align:center;margin-top:100px;>文件已不存在。</div>'\">"
	                                                               
	      , "width=550,height=300,resizable=yes,titlebar=no,scrollbars=yes");
	  } else if (/.*\.(?:txt|htm|html)$/i.test(fileName)) {
	    NewHref(gRootPath + "com/down.jsp?inpage=true&AffixID=" + id,
	       "width=550,height=300,resizable=yes,titlebar=no,scrollbars=yes", "预览文件", 5);
	  } else if (/.*\.(?:docx?|xlsx?|pptx?|pdf)$/i.test(fileName)) {
	    var h = top.document.body.offsetHeight;
	    if (h > 600) {
	      h = 600;
	    } else if (h < 200) {
	      h = 200;
	    }
	    NewHref(gRootPath + "flash/flexpaper.jsp?AffixID=" + id,
	       "width=900,height=" + h + ",resizable=yes,titlebar=no,scrollbars=yes", "_blank", 5);
	  }  else {
	    alert("预览文件只支持图片、网页、office文档，pdf文件。");
	    return;
	  }
}

function setSize(obj, type) {
	  var w = 530;
	  var h = 260;
	  var r0 = 530 / 260;
	  if (obj.height == 0) {
		  return;
	  }
	  var r = obj.width / obj.height;
	  if (r > r0) {	//宽比较大
		  if (obj.width > w) {
		    obj.style.width = w + "px";
		  }
	  } else {
		  if (obj.height > h) {
	      obj.style.height = h + "px";
	    }
	  }
	  
	}

function SelectTDInputObj(oTD)
{
var x;
	if (typeof oTD != "object")
		return false;
	var evt = getEvent();
	var all = objall(oTD);
	for (x = 0; x < all.length; x++)
	{
		if ((all[x].tagName == "INPUT") || (all[x].tagName == "SELECT") || (all[x].tagName == "TEXTAREA"))
		{
			try
			{
				all[x].focus();
			}
			catch(e)
			{
				continue;
			}
			if ((all[x].type == "text") && (!evt.ctrlKey))
				all[x].select();
			evt.returnValue = false;
			return true;
		}
	}
	return false;
}

function CheckInputs(oInputs)
{
	for (var x = 0; x < oInputs.length; x++)
	{
		var obj = document.getElementById("T1_" + oInputs[x].name);
		if ((objattr(oInputs[x], "bRequired") == 1) && (oInputs[x].name.substr(oInputs[x].name.length - 2) != "_0"))
		{
			if (oInputs[x].parentNode.parentNode.id == "DetailTempleteTR")
				continue;
			if (oInputs[x].value == "")
			{
				if (obj == null)
					alert("<j:Lang key="Form.Tianxie_neirong"/>");				
				else
					alert("[" + objtext(obj) + "] <j:Lang key="Form.Bitian"/> ");
				if ((oInputs[x].type == "hidden") || (oInputs[x].style.display == "none"))
				{
					var oImg = oInputs[x].nextSibling;
					if ((oImg != null) && (oImg.tagName == "IMG"))
						oImg.click();
//					var oImg = oInputs[x].parentNode.getElementsByTagName("IMG");
//					if (oImg.length > 0)
//						oImg[0].click();
				}
				else
					oInputs[x].focus();
				return false;
			}
		}
		if (obj == null) {
			obj = FindParentObject(oInputs[x], document.body, "td");
			if (obj == null) {
				obj = FindParentObject(oInputs[x], document.body, "TD");
			}
			if (obj != null) {
				obj = obj.previousSibling;
			}
			if (obj == null) {
				obj = {innerText:"填写的项目"};
			}
		}
		switch (Number(objattr(oInputs[x], "FieldType")))
		{
		case 1:			//文本
			if (Number(oInputs[x].value.length)> Number(oInputs[x].FieldLen))
			{
			 var test_obj="<j:Lang key="Form.Length_many"/>";
			var xuanze_wenben= test_obj.replace("[0]",oInputs[x].value.length);
				alert("[" + objtext(obj) + "](" + xuanze_wenben  +
					") " + oInputs[x].FieldLen);
				oInputs[x].focus();
				return false;
			}
			break;
		case 2:			//备注
			break;
		case 5:			//自动编号
		case 3:			//数字
		case 6:			//单精度浮点
		case 7:			//双精度浮点
			if (isNaN(Number(oInputs[x].value)))
			{
				if (oInputs[x].value.indexOf(",") == -1)
				{
				var reshu_shuzi="<j:Lang key="Form.shuru_shuzi"/>";
					alert(reshu_shuzi.replace("[0]", objtext(obj) ) );
					oInputs[x].focus();
					return false;
				}
			}
			break;
		case 4:			//日期
			if (oInputs[x].value == "")
				break;
			var ss = oInputs[x].value.split(" ")
			var sss = ss[0].split("-")
			if (isNaN(Number(sss[0])) || isNaN(sss[1]) || isNaN(sss[2]))
			{
				alert("[" + objtext(obj) + "] <j:Lang key="Form.Date_feifa"/>");
				oInputs[x].focus();
				return false;
			}
			var dd = new Date(Number(sss[0]), Number(sss[1]) - 1, Number(sss[2]));
			if ((dd.getFullYear() != Number(sss[0])) || (dd.getMonth() != Number(sss[1]) - 1) || (dd.getDate() != Number(sss[2])))
			{
				alert("[" + objtext(obj) + "] <j:Lang key="Form.Date_error"/>");
				oInputs[x].focus();
				return false;
			}
			if (ss.length < 2)
				break;
			sss = ss[1].split(":");
			for (var xx = 0; xx < sss.length; xx++)
			{
				if (sss.length > 3 || isNaN(Number(sss[xx])) || (Number(sss[xx]) > 59) || (Number(sss[xx]) < 0) || (Number(sss[0]) >= 24))
				{
					alert("[" + objtext(obj) + "] <j:Lang key="Form.Time_error"/>");
					oInputs[x].focus();
					return false;
				}
			}
			break;
		case 8:			//二进制
			break;
		case 9:			//是/否
			break;
		case 10:		//货币
			break;
		}
		
		if ((oInputs[x].name == "JU_PasswordAgain") && (oInputs[x].type == "password") 
			&& (oInputs[x - 1].type == "password") && (oInputs[x].value != oInputs[x - 1].value))
		{
			alert("<j:Lang key="Form.Pass_same"/>");
			oInputs[x].focus();
			return false;
		}
		
	}
	return true;
}

function ValidField(obj, nFormat)
{
var x;
	if (typeof(nFormat) == "undefined")
		nFormat = Number(objattr(obj, "nFormat"));

	var obj1 = document.getElementById("T1_" + obj.name);
	switch(nFormat)
	{
	case 1:
		break;
	case 2:
		for (x = 0; x < obj.value.length; x++)
		{
			if (((obj.value.charAt(x) < "a") || (obj.value.charAt(x) > "z")) &&
			    ((obj.value.charAt(x) < "A") || (obj.value.charAt(x) > "Z")))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_english"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 3:
		for (x = 0; x < obj.value.length; x++)
		{
			if ((obj.value.charAt(x) < "0") || (obj.value.charAt(x) > "9"))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_shuzi"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 4:
		for (x = 0; x < obj.value.length; x++)
		{
			if (obj.value.charCodeAt(x) < 256)
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_hanzi"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 5:
		for (x = 0; x < obj.value.length; x++)
		{
			if (((obj.value.charAt(x) >= "a") && (obj.value.charAt(x) <= "z")) ||
			    ((obj.value.charAt(x) >= "A") && (obj.value.charAt(x) <= "Z")))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_noenglish"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 6:
		for (x = 0; x < obj.value.length; x++)
		{
			if ((obj.value.charAt(x) >= "0") && (obj.value.charAt(x) <= "9"))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_noshuzi"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 7:
		for (x = 0; x < obj.value.length; x++)
		{
			if (obj.value.charCodeAt(x) > 256)
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_nohanzi"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 8:
		if (obj.value.length > 0)
		{
			if ((obj.value.charAt(0) >= "0") && (obj.value.charAt(0) <= "9"))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_noshuzi_kaitou"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 9:
		if (obj.value == "")
			break;
		var ss = obj.value.split(":");
		if (ss.length > 2)
		{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_ipaddress"/>");
				obj.focus();
				return;
		}
		if (ss.length == 2)
		{
			if (isNaN(Number(ss[1])) || (Number(ss[1]) > 65535) || (Number(ss[x]) < 0))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_ipaddress_port"/>");
				obj.focus();
				return;
			}
			var sss = ss[0].split(".");
		}
		else
			var sss = obj.value.split(".");
		for (x = 0; x < sss.length; x++)
		{
			if (sss.length != 4 || isNaN(Number(sss[x])) || (Number(sss[x]) > 255) || (Number(sss[x]) < 0))
			{
				alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_addr"/>");
				obj.focus();
				return;
			}
		}
		break;
	case 10:
		break;
	case 11:
		if (obj.value == "")
			break;
		var re = /^[a-zA-Z0-9][A-Za-z0-9_\.-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/g;
		if (re.test(obj.value) == false)
		{
			alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_email"/>");
			obj.focus();
			return;
		}
		break;
	case 12:
		if (obj.value == "")
			break;
		//var re = /[a-zA-Z][A-Za-z0-9_.-]+@[a-zA-Z0-9_.-]+/g;
		var re = /^[\+\-]?\d*?\.?\d?$/;
		if (re.test(obj.value) == false)
		{
			alert("[" + objtext(obj1) + "] <j:Lang key="Form.Check_shuzhi"/>");
			//alert("输入类型格式不对,请输入带小数点的数值类型.");
			obj.focus();
			return;
		}
		break;
		break;
	}	
}

function OmitInput()
{
var objs, x, oo;
	objs = document.getElementsByTagName("INPUT");
	for (x = 0; x < objs.length; x++)
	{
		if (objs[x].type == "password")
		{
			oo = document.getElementsByName(objs[x].name);
			if (oo.length == 2) 
				oo[1].removeNode();
		}
		if (objs[x].type == "checkbox")
		{
			if ((objs[x].checked == false) && (objs[x].value == 1))
			{
				objs[x].checked = true;
				objs[x].value = 0;
				objs[x].style.display = "none";
			}
		}
	}
}

function CheckInputValue()
{
var objs, x, oo;
	if (CheckFormValue(idobj("MyInfoForm")) == false)
		return false;
	objs = document.getElementsByTagName("INPUT");
	for (x = 0; x < objs.length; x++)
	{
		if (objs[x].type == "password")
		{
			oo = document.getElementsByName(objs[x].name);
			if ((oo.length == 2) && (oo[0].value != oo[1].value))
			{
				alert("<j:Lang key="Form.Pass_samez"/>");
				oo[0].focus();
				return false;
			}
		}
	}
	return true;
}

function SelectQuoteValue(oAlias, TableDefID, TableName, QuoteField, AliasField, value)
{
return;
var to, oImg, str, oInput, s, s1, s2;
	var frame = idobj("FormDataFrame");
	frame.oAlias = oAlias;
	oImg = oAlias.nextSibling.nextSibling;
	to = GetObjPos(oAlias);
	frame.style.top = to.bottom + "px";
	frame.style.left = to.left + "px";
	frame.style.display = "block";
	frame.style.width = oAlias.parentNode.offsetWidth + "px";
	frame.src = psubdir + "SeleQuoteTable.jsp?TableDefID=" + TableDefID + "&TableName=" + TableName + 
		"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + value + "&Condition=" + 
		escape(oImg.condition) + "&AliasValue=" + oAlias.value + "&bIFrame=1";
}

function SetHTMLEditorData(bHTMLAddressChange)
{
var oFrames, x, oText;
var host = location.host.replace(/\./g, "\\.");
var re = new RegExp("\"http://" + host, "g"); 
	oFrames = document.getElementsByName("HTMLEditFrame");
	if (oFrames.length == 0)
		return;
	for (x = 0; x < oFrames.length; x++)
	{
		CopyHTMLData(oFrames[x]);

		oText = oFrames[x].nextSibling;
		var val = oText.value;
		var val = val.replace(/<script[^>]*>[\s\S]*?<\/script>/ig, "");
		val = val.replace(/<style[^>]*>[\s\S]*?<\/style>/ig, "");
		val = val.replace(/<iframe[^>]*>[\s\S]*?<\/iframe>/ig, "");
		val = val.replace(/src="data:image/ig, "src2=\"data:image");
		val = val.replace(/(onclick|ondblclick|onerror|onmousemove|onmousedown|onmouseup|onkeydown|onkeyup|onkeypress)/ig, "event_script_$1");
		oText.value = val;
		if  (bHTMLAddressChange)
		{
			oText.value = oText.value.replace(re, "\"");
		}
	}
}

function CloseActionWindow(bReload, href)
{
	// Electron lxt 2017.12.15
	if(navigator.userAgent.indexOf("Electron")>-1){
		if(top.require)
			top.require('electron').remote.getCurrentWindow().close();
		else top.close();
		return;
	}
	
	if (parent != window)
	{
		if (typeof parent.nbwin == "object")
			return parent.external.Close();
		if (typeof parent.EditorWin == "object")
			return parent.EditorWin.close();
		if (idobj("InDlgDiv", parent.document) != null)
			return parent.CloseInlineDlg();
		if (history.length > 0)
			history.back();
		else
			parent.location.assign(parent.location.href);
		return;		
	}	

	if (typeof(window.opener) == "object")
	{
		if (bReload == 1)
		{
			try
			{
				window.opener.location.assign(window.opener.location.href);
//				window.opener.location.reload(true);
			}
			catch(e)
			{
			}
		}
		window.close();
	}
	else
	{
		if (typeof(window.dialogHeight) == "undefined")
		{
			if (IsNetBoxWindow())
				return window.external.EndDialog(bReload);
			if ((typeof(href) == "undefined") || (href == ""))
				window.history.back();
			else
				window.location.href = href;
		}
		else
			window.close();	
	}
}

function ChangePassword(obj, nType)
{
	var password = window.showModalDialog("/Chpass.htm", obj.previousSibling, 
		"dialogWidth:400px;dialogHeight:160px;scroll:0;help:0;status:0");
	if (typeof password == "string")
		obj.previousSibling.value = password;
}

function UpdateCheckValue(obj)
{
	var oChecks = obj.parentNode.parentNode.parentNode.getElementsByTagName("INPUT");
	var value = "";
	for (var x = 0; x < oChecks.length; x++)
	{
		if (oChecks[x].checked)
			value = StrAddItem(value, oChecks[x].value, ",");
	}
	obj.parentNode.parentNode.parentNode.parentNode.parentNode.firstChild.value = value;
}

function PageReturn(href)
{

	if (typeof(parent.dialogHeight) != "undefined")
	{
		parent.returnValue = "OK";
		parent.close();
		return;
	}

	if (parent != window)
	{
		if (typeof parent.nbwin == "object")
			return parent.external.Close();
		var url = parent.location.toString();
		parent.location = url;
		return;
		//return parent.location.reload(true);
		if (idobj("ActionSave", parent.document) != null)
			return parent.location.reload(true);
		return CloseActionWindow(1, href);
	}
	if (IsNetBoxWindow())
	{
		var w = external.Browser.GetProperty("HTMLWinParent");
		if (typeof(w) == "object")
			w.location.reload(true);
		window.external.EndDialog(1);
	}
	else
	{
		if(window.opener != undefined) {
			try {
				window.opener.location.reload(true);
			} catch (e) {					
			}
		}
		window.close();
	}
	//window.setTimeout("CloseActionWindow(1, href)", 6000);
}

function InitTools()
{

	if (typeof(window.tools) == "undefined")
	{
		window.tools = [{pic:"/pic/PlayStart.gif",text:"首张",action:"FirstRecord()",status:0},
			{pic:"/pic/PlayLast.gif",text:"上张",action:"PreviousRecord()",status:0},
			{pic:"/pic/PlayNext.gif",text:"下张",action:"NextRecord()",status:0},
			{pic:"/pic/PlayEnd.gif",text:"末张",action:"LastRecord()",status:0},
			{pic:"/pic/add.gif",text:"新增",action:"NewRecord()",status:0},
			{pic:"/pic/delete.gif",text:"删除",action:"DeleteRecord()",status:0},
			{pic:"/pic/save.gif",text:"保存",action:"SaveRecord()",status:0},
			{pic:"/pic/undo.gif",text:"取消",action:"CancelEditRecord()",status:0},
			{pic:"/pic/refur.gif",text:"刷新",action:"location.reload(true)",status:1},
			{pic:"/pic/Print.gif",text:"打印",action:"PrintRecord()",status:0},
			{pic:"/pic/query.gif",text:"查询",action:"SearchItem()",status:1},
			{pic:"/pic/list.gif",text:"浏览",action:"SearchItem()",status:0}];
		if (idobj("I_DataRange").value != "")
		{
			tools[0].status = 1;
			tools[1].status = 1;
			tools[2].status = 1;
			tools[3].status = 1;
		}
		var dataid = idobj("I_DataID");
		if ((dataid.value != 0) && (dataid != ""))
		{
			tools[4].status = 1;
			tools[5].status = 1;
		}
		SetValueChange(FormValueChange);
	}
	
	if (typeof(parent.SetToolbarCallback) == "function")
		parent.SetToolbarCallback(window);

}


function ResizeFormWin(width, height)
{
	if (typeof parent.nbwin == "object")
		return parent.external.resizeTo(width, height);
	if (parent != window)
		return;
//	if (ResizeActionWin() == true)
//		return;

	if (IsNetBoxWindow())
		window.external.resizeTo(width, height);
	else
		window.resizeTo(width, height);
}

function ResizeFlowForm()
{
	ResizeActionWin();
	var ActionSave = idobj("ActionSave");
	if (typeof parent.nbwin == "object")
		return parent.nbwin.Resize(ActionSave.scrollWidth + 40, ActionSave.scrollHeight + 40);
	if (parent != window)
	{
		if (document.body.clientHeight < document.body.scrollHeight)
			document.body.scroll = "yes";
		return;
	}
	var offsetHeight = 0;
	var offsetWidth = 0;
	
	offsetWidth = 0;
	offsetHeight = ActionSave.scrollHeight - document.body.clientHeight;
	if (1== 1 || window.isEffect != undefined && window.isEffect == true) {
		var screenHeight = 0;
		var currentHeight = document.body.clientHeight;
		screenHeight = window.screen.availHeight;
		var screenWidth = window.screen.availWidth;
		if (currentHeight + offsetHeight > screenHeight * 0.8) {
			offsetWidth = document.body.scrollWidth - document.body.clientWidth;
			offsetHeight = screenHeight * 0.8 - document.body.clientHeight;
			var currentWidth = document.body.clientWidth;
			window.moveBy((screenWidth - currentWidth) / 2  - window.screenLeft
				, screenHeight * 0.1 - window.screenTop + 20);
		}
	}
	if (IsNetBoxWindow())
		window.external.resizeTo(ActionSave.scrollWidth, ActionSave.scrollHeight + 40);
	else
		window.resizeBy(offsetWidth, offsetHeight);
}

function ResizeActionWin()
{
	var h, hh = 0, x;
	var o = idobj("FormTableObj");
	if (o != null)
		hh += o.clientHeight;
	var o = idobj("FormTableObj1");
	if (o != null)
		hh += o.clientHeight;
	var o = idobj("FormButtonDiv");
	if (o != null)
		hh += o.clientHeight;
	var o = idobj("UserFormHeadDiv");
	if (o != null)
		hh += o.clientHeight;
	var o = idobj("FlowAttach");
	if (o != null)
		hh += o.clientHeight;
		
	var obj = document.getElementsByName("HTMLEditFrame");
	if (obj.length == 1)
	{
		var oText = obj[0].nextSibling;
		if (oText.rows == 100)
		{
			h = document.body.clientHeight - hh + oText.parentNode.clientHeight;
			if (h < 80)
				h = 80;
			obj[0].style.height = h;
			oText.style.height = h;
		}
		return;
	}
	obj = document.getElementsByName("TextReadOnlyViewDiv");
	if (obj.length == 0)
		obj = document.getElementsByName("OfficeEditor");
	for (x = 0; x < obj.length; x++)
	{
		if (obj[x].rows == 100)
		{
			h = document.body.clientHeight - hh + obj[x].clientHeight;
			if (h > 0)
				obj[x].style.height = h;
			return;
		}
	}
	if (document.all)
		return;
	obj = document.getElementsByTagName("INPUT")
	for (x = 0; x < obj.length; x++)
	{
		if ((obj[x].style.width == "100%") || (obj[x].className == "text"))
		{
			obj[x].style.width = (obj[x].parentNode.offsetWidth - 80) + "px";
		}
	}

	obj = document.getElementsByTagName("TEXTAREA")
	for (x = 0; x < obj.length; x++)
	{
		if ((obj[x].style.width == "100%") || (obj[x].className == "text"))
		{
			obj[x].style.width = (obj[x].parentNode.offsetWidth - 80) + "px";
		}
	}

	
}

function FormValueChange()
{
	if (document.body.onbeforeunload != null)
		return;
	var evt = getEvent();
	if ((evt.propertyName != "value") && (evt.propertyName != "checked"))
		return;
	document.body.onbeforeunload = function(){getEvent().returnValue="表单内容已改变";};
	tools[0].status = 0;
	tools[1].status = 0;
	tools[2].status = 0;
	tools[3].status = 0;
	tools[4].status = 0;
	tools[5].status = 0;
	tools[6].status = 1;
	tools[7].status = 1;

	if (typeof(parent.SetToolbarCallback) == "function")
		parent.SetToolbarCallback(window);
}

function  SetValueChange(fun)
{
	var ActionSave = idobj("ActionSave");
	var objs = ActionSave.getElementsByTagName("INPUT")
	for (var x = 0; x < objs.length; x++)
		objevent(objs[x], "propertychange", fun);
	objs = ActionSave.getElementsByTagName("SELECT")
	for (x = 0; x < objs.length; x++)
		objevent(objs[x], "propertychange", fun);
	objs = ActionSave.getElementsByTagName("TEXTAREA")
	for (var x = 0; x < objs.length; x++)
		objevent(objs[x], "propertychange", fun);
}


function InitOffice(obj, value)
{
//	var win = obj.contentWindow.(value);
}

function FlowEnd()
{
	var objs = document.getElementsByName("SubmitButton");
	for (var x = 0; x < objs.length; x++)
		objs[x].disabled = true;
	CloseInlineDlg();
	idobj("exitform").onclick = ReloadMyFlow;
}

function ReloadMyFlow()
{
	if (typeof parent.Reload == "function")
		return parent.Reload();
	if (typeof window.opener == "object")
	{
		CloseActionWindow(2);
		if (typeof window.opener.parent.Reload == "function")
			window.opener.parent.Reload();
		return;
	}
	if (IsNetBoxWindow())
	{
//		var w = external.Browser.GetProperty("HTMLWinParent");
		var NetBox = new ActiveXObject("NetBox");
		var w = NetBox("HTMLWin_Dict")("hDesktop").Browser.Document.parentWindow;
		if (typeof(w) == "object")
		{
			if (typeof w.Reload == "function")
				w.Reload();
			else if (typeof w.parent.Reload == "function")
				w.parent.Reload();
		}
		return CloseActionWindow(2);
	}	
}

function SubmitFlowForm(obj, nAction)
{
	if (nAction == 4) {
		if (!confirm("警告：\n  终止流程将强行关闭当前的流程实例。所有已发起的流转都将结束。\n\n提示：流程的正常流转（包括最后一步）请点击“发送”.\n\n您确定要终止流程吗？")) {
			return;
		}
	}
	if (typeof nAction != "undefined")
		idobj("I_nAction").value = nAction;
	SubmitMode = 2;
	if ((nAction != 1) && (nAction != 2))
	{
		idobj("ActionSave").action = idobj("I_FlowName").value + ".jsp";		
		return Submitting(SubmitMode);
	}
	if (nAction == 1)
		return SubmitForm(obj, "nocheck");
	SubmitForm(obj);
}

function FlowView(obj)
{
	if (typeof window.FlowViewMenu == "undefined")
		window.FlowViewMenu = new FlowViewObj(obj);
	window.FlowViewMenu.run();
}

function FlowViewObj(obj)
{
var menu;
var status = 1;
	if (idobj("I_StepID").value == 0)
		menu = new CommonMenu([{item:"流程表单", img:"<span style='font:normal small-caps normal 16pt wingdings'>3</span>", action:FlowForm},
			{item:"流程图",  img:"<span style='font:normal small-caps normal 16pt wingdings'>O</span>", action:FlowChart}]);
	else
		menu = new CommonMenu([{item:"流程表单", img:"<span style='font:normal small-caps normal 16pt wingdings'>3</span>", action:FlowForm},
			{item:"流程实例图", img:"<span style='font:normal small-caps normal 16pt wingdings'>P</span>", action:FlowChart},
			{item:"流转历史",  img:"<span style='font:normal small-caps normal 16pt wingdings'>&#185;</span>", action:FlowHis}]);

	this.run = function ()
	{
		var evt = getEvent();
		if (objtext(evt.srcElement) == "6")
		{
			var pos = GetObjPos(obj);
			return menu.show(pos.left, pos.bottom, pos.left, pos.bottom);
		}
		switch (status)
		{
		case 1:
			FlowChart();
			break;
		case 2:
		if (idobj("I_StepID").value == 0)
			FlowForm();
		else
			FlowHis();
			break;
		case 3:
			FlowForm();
			break;
		}
	}
	
	function FlowForm()
	{
		status = 1;
		var frame = idobj("FlowChartFrame");
		if (frame != null)
		{
			frame.parentNode.removeChild(frame);
			document.body.scroll = document.body.scrollsave;
			obj.firstChild.title = "流程表单";
			obj.firstChild.innerHTML = "3";
		}
	}

	function FlowChart()
	{
		status = 2;
		var href = "../flow/graph.jsp?FlashStatus=FlowView&StepID=" + idobj("I_StepID").value;
		var name = "流程实例图";
		var pic = "P";
		if (idobj("I_StepID").value == 0)
		{
			href = "../flow/graph.jsp?FlashStatus=FlowView&FlowID=" + idobj("I_FlowID").value;
			name = "流程图";
			pic = "O";
		}
		FlowShowURL(href, name, pic);
	}
	
	function FlowHis()
	{
		status = 3;
		FlowShowURL("FlowInstData.jsp?StepID=" + idobj("I_StepID").value, "流转历史", "&#185;");
	}
	
	function FlowShowURL(href, name, pic)
	{
		var frame = idobj("FlowChartFrame");
		if (frame != null)
			frame.src = href;
		else
		{
			document.body.insertAdjacentHTML("beforeEnd", "<iframe id=FlowChartFrame frameborder=0 src=" +
				href + " style=position:absolute;top:0px;width:100%;height:100%;margin-top:40px;padding-bottom:40px;background:white;></iframe>");
			document.body.scrollsave = document.body.scroll;
			document.body.scrollLeft = 0;
			document.body.scrollTop = 0;
			document.body.scroll = "no";
		}
		obj.firstChild.innerHTML = pic;
		obj.firstChild.title = name;
	}
}

function NoteFlowForm()
{
	InlineHTMLDlg("<div id=SubmitBar>填写协办意见</div>", "<iframe name=FormResult frameborder=0 scrolling=no width=100% height=175px></iframe>", 400, 200);
	var form = idobj("FormResult");
	form.contentWindow.document.write("<HTML><HEAD><BODY><FORM method=post action=../flow/flowrun.jsp>" +
		"<input type=hidden name=I_MonDataID value=0><input type=hidden name=I_nAction value=10>" +
		"<input type=hidden name=I_FlowID value=" + idobj("I_FlowID").value + 
		"><input type=hidden name=I_StepID value=" + idobj("I_StepID").value +
		"><input type=hidden name=I_ActionID value=" + idobj("I_ActionID").value +
		"><input type=hidden name=I_FlowInstID value=" + idobj("I_FlowInstID").value +
		"><input type=hidden name=FlowSaveFlag value=1><textarea name=MonNote style=width:100%;height:120px></textarea>" + 
		"<div style=overflow:hidden;width:100%;height:10px></div><center><input type=submit value=提交>&nbsp;&nbsp;" +
		"<input type=button value=取消 onclick=parent.CloseInlineDlg()></center></FORM></BODY></HTML>"); 
	form.contentWindow.document.close();
	form.contentWindow.document.charset = "GBK";
}

function FlowMonView(obj)
{
	InlineHTMLDlg("<div id=SubmitBar>填写" + obj.value + "</div>", "<iframe name=FormResult frameborder=0 scrolling=no width=100% height=175px></iframe>", 400, 200);
	var form = idobj("FormResult");
	form.contentWindow.document.write("<HTML></HEAD><BODY></BODY></HTML>");
	form.contentWindow.document.close();
	form.contentWindow.document.charset = "GBK";
	NextFlowMonView(0, obj);
	var objs = obj.nextSibling.children;
	idobj("SubmitBar").innerHTML = objs[0].rs_SubmitMan + "填写的" + obj.value + "(时间:" + objs[0].rs_SubmitTime + ")";
}

function ExpandFlowMonView(obj)
{
	var o = obj.nextSibling;
	if (o.style.display == "none")
	{
		o.style.display = "block";
		obj.firstChild.src = "../pic/btnDocCollapse.gif";
	}
	else
	{
		o.style.display = "none";
		obj.firstChild.src = "../pic/btnDocExpand.gif";
	}
	ResizeActionWin();
}

function NextFlowMonView(index, obj)
{
	if (typeof obj == "object")
		var objs = obj.nextSibling.children;
	else
		var objs = idobj("FlowMonViewDiv").children;
	idobj("SubmitBar").innerHTML = objs[index].rs_SubmitMan + "填写的协办意见(时间:" + objs[index].rs_SubmitTime + ")";
	var tag = "<FORM method=post action=../flow/flowrun.jsp><input type=hidden name=I_nAction value=10>" +
		"<input type=hidden name=I_MonDataID value=" + objattr(objs[index], "node") +
		"><input type=hidden name=I_FlowID value=" + idobj("I_FlowID").value +
		"><input type=hidden name=I_StepID value=" + idobj("I_StepID").value +
		"><input type=hidden name=I_ActionID value=" + idobj("I_ActionID").value +
		"><input type=hidden name=I_FlowInstID value=" + idobj("I_FlowInstID").value +
		"><input type=hidden name=FlowSaveFlag value=1>" +
		"<textarea name=MonNote style=width:100%;height:120px>" + objs[index].innerHTML + "</textarea>" + 
		"<div style=overflow:hidden;width:100%;height:10px></div><center>";
	if (index > 0)
		tag += "<input type=button onclick=parent.NextFlowMonView(" + (index - 1) + ") value=上一条>&nbsp;&nbsp;";
	if (index < objs.length - 1)
		tag += "<input type=button onclick=parent.NextFlowMonView(" + (index + 1) + ") value=下一条>&nbsp;&nbsp;";
	if (objs[index].rs_EditFlag == "1")
		tag += "<input type=submit value=修改>&nbsp;&nbsp;<input type=submit value=删除 onclick=\"if (confirm('是否确定删除?')) idobj(\"MonNote\").value='';else return false;\">&nbsp;&nbsp;"
	tag += "<input type=button value=返回 onclick=parent.CloseInlineDlg()></center></FORM></BODY></HTML>"; 
	
	idobj("FormResult").contentWindow.document.body.innerHTML = tag;
}



function SelectQuoteResult(oImg, TableName, QuoteField, AliasField, value)
{
	var obj = oImg.previousSibling.previousSibling;
	var str = showModalDialog(psubdir + "SeleQuoteTable.jsp?Multi=1&TableName=" + TableName + 
		"&QuoteField=" + QuoteField + "&AliasField=" + AliasField + "&Value=" + obj.value + "&Condition=" + 
		escape(oImg.getAttribute("condition")), "", "dialogWidth:640px;scroll:0;help:0;status:0;resizable:1");
		// Electron lxt 2017.11.8
		if(navigator.userAgent.indexOf("Electron")>-1){
			window.g_SelectQuoteResultElectronTimes=0;
			var funcx=function(){
				if(window.localStorage["SeleQuoteTableReturnValue"]){
					var s=window.localStorage["SeleQuoteTableReturnValue"];
					ConfirmQuoteTable(s, obj);
					window.localStorage.removeItem("SeleQuoteTableReturnValue");
				}
				if(window.g_SelectQuoteResultElectronTimes++>2000) return;
				setTimeout(funcx, 200);
			};
			setTimeout(funcx, 200);
		}
	return ConfirmQuoteTable(str, obj);
}

var OfficeInputObj = [], QuoteInputObjs = [];
function InitForm()
{
	if (IsNetBoxWindow())
	{
		window.external.ContextMenu = true;
		document.body.oncontextmenu = RightButtonMenu;
	}
	
	var objs = document.getElementsByName("OfficeInput");
	if(objs.length == 0){
		if(document.getElementById("OfficeInput") != null){
			objs = [];
			var idArr = document.getElementsByTagName("div");
			for(var x = 0; x < idArr.length; x++)
				if(idArr[x].id == "OfficeInput")
				objs.push(idArr[k]);
		}
	}
	for (var x = 0; x < objs.length; x++)
		OfficeInputObj[x] = new OfficeInput(objs[x]);
		
	objs = document.getElementsByName("ConSignEditor");
	if(objs.length == 0){
		if(document.getElementById("ConSignEditor") != null){
			objs = [];
			var idArr = document.getElementsByTagName("div");
			for(var x = 0; x < idArr.length; x++)
				if(idArr[x].id == "ConSignEditor")
				objs.push(idArr[k]);
		}
	}
	for (var x = 0; x < objs.length; x++)
		new ConSignEditor(objs[x]);
	
	objs = document.getElementsByTagName("INPUT");
	for (x = 0; x < objs.length; x++)
	{
		if ((objs[x].title != "") && (objs[x].value == ""))
		{
			objs[x].value = objs[x].title;
			objs[x].style.color = "#cccccc";
			objevent(objs[x], "focus", HideInputTitle);
			objevent(objs[x], "blur", ShowInputTitle);
		}
	}
	objs = document.getElementsByName("QuoteInput");
	if (objs.length > 0)
	{
		for (x = 0; x < objs.length; x++)
			QuoteInputObjs[x] = new QuoteSearch(objs[x]);
	}
	initFlowRemark();
	
	if(window.attachEvent) {
		window.attachEvent('onload', initButtonAction);
	} else {
		window.addEventListener("load", initButtonAction, false);
	}
}

function initFlowRemark() {
	var url = location.toString();
	var re = new RegExp("FlowName=(.*?)(?=&|&amp;|$)", "");
	var arr = re.exec(url);
	var flowName = "";
	if ( arr != null ) {
		flowName = arr[1];
	}
	var StepID = "";
	re = new RegExp("StepID=(.*?)(?=&|&amp;|$)", "");
	arr = re.exec(url);
	if ( arr != null ) {
		StepID = arr[1];
	}
	if (flowName == "" && StepID == "") {
		return;
	}
	url = gRootPath + "AjaxFunction?type=GetFlowRemark"
		+ "&FlowName=" + flowName + "&StepID=" + StepID;
	AjaxRequestPage(url, true, ""
		, function(str) {
			if (str == "") {
				return;
			}
			str = unescape(str);
			if (str.indexOf("error:") == 0) {
				return;
			}
			str = "<div style='border:1px solid #dddddd;padding:10px 30px;"
				+ "margin:0 5px; 15px 5px;'>" + str + "</div>";
			document.forms[0].insertAdjacentHTML("afterEnd", str);
		}
	);
}

function savePageHtml() {
	var page = gRootPath + "system/error.jsp?error_type=save_form";
	var mode = true;
	var time1 = new Date().getTime();
	var source = document.documentElement.innerHTML;
    var formElement = formToXml();
    var url = location.toString();
	var postdata = "<page>"
		+ "<url>" + url + "</url>"
		+ "<source>" + source + "</source>"
		+ "<form>" + formElement + "</form>"
		+ "</page>";
	postdata = "Param=" + escape(escape(postdata));
	var frm = document.getElementsByName("ActionSave")[0];
	var formName = frm.action;
	formName = formName.replace(/\..*/, "");
	postdata += "&form_name=" + formName;
	var fun = function(str){
		
	};
	var time2 = new Date().getTime();
	var time3 = time2 - time1;
	AjaxRequestPage(page, mode, postdata, fun);
}

function initButtonAction() {
	var btn = document.getElementsByName("SubmitButton");
	for (var x = 0; x < btn.length; x++) {
		if (/保存|发送|完成/.test(btn[x].value)) {
			if(window.attachEvent) {
				btn[x].attachEvent('onclick', savePageHtml);
			} else {
				btn[x].addEventListener("click", savePageHtml, false);
			}
		}
	}
}


function getEnumPropertyNames (obj) {
    var props = [];
    for (prop in obj) {
    	var val = obj[prop];
    	if (typeof obj[prop] == "object") {
    		val = getEnumPropertyNames(obj[prop]);
    	}
    	var remark = prop + "=" + val + ";\n";
        props.push(remark);
    }
    return props.join("");
}

function formToXml()
{
	var x;
	var value;
	var aXml = ["<?xml version=\"1.0\" encoding=\"GBK\"?><datas>"];
	var frm = document.getElementsByName("ActionSave")[0];
	var elements = frm.elements;
	for (var x = 0; x < elements.length; x++) {
		var name = elements[x].name;
		var type = elements[x].type;
		var value;
		if (type == "button") {
			continue
		} else if (type == "radio" || type == "checkbox") {
			value = elements[x].checked;
		} else {
			value = elements[x].value;
		}
		aXml.push("<");
		aXml.push(name);
		aXml.push(">");
		aXml.push(value);
		aXml.push("</");
		aXml.push(name);
		aXml.push(">");
		
	}
	aXml.push("</datas>");
	var xmlText = aXml.join("");
	return xmlText;
}

function QuoteSearch(obj)
{
	var QuoteList, QuoteObj;

	function init()
	{
		var hisfun = QuoteSearch;
		var quote = obj.getAttribute("quote");
		if (quote == undefined)
			return;
		switch (quote.substr(0, 1))
		{
		case "(":
			QuotoList = quote.substr(1, quote.length - 2).split(",");
			hisfun = EnumSearch;
			break;
		case "@":
			AjaxRequestPage(psubdir + "seleenum.jsp?EnumType=" + quote.substr(1) + "&AjaxMode=1", true, "", EnumDataOK);
			hisfun = EnumSearch;
			break;
		case "$":
			AjaxRequestPage(psubdir + "seleenum.jsp?EnumType=" + quote.substr(1) + "&AjaxMode=1", true, "", EnumDataOK);
			hisfun = EnumSearch;
			break;
		default:
			break;
		}
		QuoteObj = new DynaEditor.Search(hisfun);
		QuoteObj.valueChange = QuoteChange;
		QuoteObj.attach(obj);
	}
	
	function EnumSearch(value)
	{
		var list = "", sp = "";
		for (var x = 0; x < QuoteList.length; x++)
		{
			var ss = QuoteList[x].split(":");
			if (ss.length > 1)
				list += sp + ss[1];
			else
				list += sp + ss[0];
			sp = ",";
		}
		return list;
	}
	
	function QuoteSearch(value)
	{
		var ss = obj.quote.split(",")
		if (ss.length == 1)
			return "";
		var s1 = ss[0].split(".");
		AjaxRequestPage(psubdir + "SeleQuoteTable.jsp?AjaxMode=1&nDB=&TableName=" + s1[0] + "&QuoteField=" + s1[1] + 
			"&AliasField=" + ss[1] + "&SeekKey=" + value, true, "", QuoteSearchOK);
		return "";
	}

	function EnumDataOK(data)
	{
		QuoteList = Trim(data).split(",");
	}

	function QuoteSearchOK(data)
	{
		EnumDataOK(data);
		var list = EnumSearch("");
		QuoteObj.setData(list);
		QuoteObj.popDown();
	}

	function QuoteChange(obj)
	{
//		QuoteObj.value = "";
		if (typeof QuoteList == "object")
		{
			for (var x = 0; x < QuoteList.length; x++)
			{
				var ss = QuoteList[x].split(":");
				if (((ss.length > 1) && (obj.value == ss[1])) || ((ss.length <= 1) && (obj.value == ss[0])))
				{
					obj.previousSibling.value = ss[0];
					return;
				}
			}
		}
		obj.value = "";
		obj.previousSibling.value = 0;
	}
	init();
}

function HideInputTitle()
{
	var evt = getEvent();
	if (evt.srcElement.title == evt.srcElement.value)
	{
		evt.srcElement.value = "";
		evt.srcElement.style.color = "";
	}
}

function ShowInputTitle()
{
	var evt = getEvent();
	if (evt.srcElement.value == "")
	{
		evt.srcElement.value = evt.srcElement.title;
		evt.srcElement.style.color = "#cccccc";	
	}
}

function InsertDetail(obj)
{
	var oTab = obj.parentNode.parentNode.parentNode.parentNode;
	var oNewTR = oTab.insertRow();
	var oTR = oTab.rows[1];
	for (var x = 0; x < oTR.cells.length; x++)
	{ 
		var oTD = oNewTR.insertCell();
		oTD.innerHTML = oTR.cells[x].innerHTML;
		oTD.style.display = oTR.cells[x].style.display; 
	}
}

function DeleteDetail(obj)
{
	var oTR = obj.parentNode.parentNode;
	if (oTR.parentNode.rows.length <= 3)
		return alert("不能删除最后一行");
	if (window.confirm("是否删除当前行?"))
		oTR.removeNode(true);
}

function MakeRedFile(AffixID, FileNo)
{
		NewFrameWin("UserDatas_viewRedFile.jsp?FileNo=" + FileNo + "&AffixID=" + AffixID, "Width=650px,Height=500px,scroll=0;");	
}

// chrome lxt 2017.11.14
if(navigator.userAgent.indexOf("Chrome")>-1){
	window.addEventListener("load", function(){
		//var div=document.getElementById("FormBodyDiv");
		//if(div) div.style.paddingLeft="0px";
		var l=document.createElement("link");
		l.rel="stylesheet";
		l.type="text/css";
		l.href="../forum_w3c.css";
		document.getElementsByTagName("head")[0].appendChild(l);
	}, false);
}
//</script>