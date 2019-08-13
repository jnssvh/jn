<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
<html><head>
<title><j:Lang key="seledatetime.Select_data"/></title><link rel=stylesheet type=text/css href=forum.css></head>
<body bgcolor=#ffffff alink=#333333 vlink=#333333 link=#333333 topmargin=0>
<nobr><img src=pic\prev.gif title=<j:Lang key="seledatetime.Houtui_year"/> style=cursor:hand; onclick=SelectYear(-1)>
	<B id=YearSel onclick=EditYear(this) onblur=EditYearEnd(this) onkeypress=PressYear(this)>&nbsp;</B>
	<img src=pic\next.gif title=<j:Lang key="seledatetime.Qiangjin_year"/> style=cursor:hand; onclick=SelectYear(1)>

	<SELECT name=MonthSel onchange=SelectMonth()>
 		<option value=1><j:Lang key="seledatetime.moth1"/></option><option value=2><j:Lang key="seledatetime.moth2"/></option><option value=3><j:Lang key="seledatetime.moth3"/></option>
 		<option value=4><j:Lang key="seledatetime.moth4"/></option><option value=5><j:Lang key="seledatetime.moth5"/></option><option value=6><j:Lang key="seledatetime.moth6"/></option>
 		<option value=7><j:Lang key="seledatetime.moth7"/></option><option value=8><j:Lang key="seledatetime.moth8"/></option><option value=9><j:Lang key="seledatetime.moth9"/></option>
 		<option value=10><j:Lang key="seledatetime.moth10"/></option><option value=11><j:Lang key="seledatetime.moth11"/></option><option value=12><j:Lang key="seledatetime.moth12"/></option>
	</SELECT>
</nobr>
	<table cellpadding=0 cellspacing=0 border=0 width=100% bgcolor=gray align=center>
	<tr><td>
        	<table id=DateTable cellpadding=3 cellspacing=1 border=0 width=100%>
		<TBODY id=DateBody><TR ID=WeekTitle bgcolor=white>
			<TD bgColor=mintcream><j:Lang key="seledatetime.Day"/></TD>
			<TD><j:Lang key="seledatetime.day1"/></TD>
			<TD><j:Lang key="seledatetime.day2"/></TD>
			<TD><j:Lang key="seledatetime.day3"/></TD>
			<TD><j:Lang key="seledatetime.day4"/></TD>
			<TD><j:Lang key="seledatetime.day5"/></TD>
			<TD bgColor=whitesmoke><j:Lang key="seledatetime.day6"/></TD></TR>

         	</TBODY></table></td></tr></table>
<CENTER><span id=TimeSel></span><input type=button value=OK style=display:none;></CENTER>
<CENTER id=ButtonObj><input type=Button value="<j:Lang key="psub.Queding"/>" onclick=ConfirmDateSelect()> &nbsp;
		<input type=button value="<j:Lang key="psub.cancel"/>" onclick=CloseWin()> &nbsp;</CENTER>
<script language=javascript src=psub.jsp></script>
<SCRIPT LANGUAGE="JavaScript">
var tday = new Date();
var g_isOnLoad = false;
window.onload = function()
{
var s, ss;
var isTime = false, timeStr = "";
	g_isOnLoad = true;
	if ((typeof(window.dialogArguments) == "string") && (window.dialogArguments != ""))
	{
		s = window.dialogArguments.split(" ");
		if ((s.length == 1) || (s.length == 2))
		{
			ss = s[0].split("-");
			if (ss.length == 3)
				tday = new Date(Number(ss[0]), Number(ss[1]) - 1, Number(ss[2]));
			if (s.length == 2) {
				timeStr = s[1];
				isTime = true;
			}
		}
	}
	if (!isTime) {
		var type = "<%=com.jaguar.WebChar.requestStr(request, "type")%>";
		if (type == "datetime") {
			isTime = true;
			timeStr = new Date().getHours() + ":" + new Date().getMinutes() + ":00";
		}
	}
	if (isTime) {
		InitTime(timeStr);
	}
	DateCard(tday);
}

function InitTime(st)
{
var x, ss = "", sss = "";
	for (x = 0; x < 24; x++)
		ss += "<option value='" + LStrFill(x, 2, "0") + "'>" + LStrFill(x, 2, "0");
	for (x = 0; x < 60; x++)
		sss += "<option value='" + LStrFill(x, 2, "0") + "'>" + LStrFill(x, 2, "0");
	document.all.TimeSel.innerHTML = "<SELECT onchange=SetComboValue() name=HourSel>" + ss + 
		"</SELECT>:<SELECT onchange=SetComboValue() name=MinuteSel>" + sss +
		"</SELECT>:<SELECT onchange=SetComboValue() name=SecondSel>" + sss + "</SELECT>";
	ss = st.split(":");
	if (ss.length > 1)
	{
		document.all.HourSel.value = LStrFill("00" + parseInt(ss[0]), 2, "0");;
		document.all.MinuteSel.value = LStrFill("00" + parseInt(ss[1]), 2, "0");;
		if (ss.length > 2)
			document.all.SecondSel.value = LStrFill("00" + parseInt(ss[2]), 2, "0");
	}
}

var g_cbinputObj;
function InitComboValue(obj)
{
	var t = "";
	g_cbinputObj = obj;
	var d = new Date();
	if (obj.value == "")
		obj.value = d.getYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
	t = GetDate(obj.value);
	if (!isNaN(t))
		tday = t;
	var s = obj.value.split(" ");
	var type = "<%=com.jaguar.WebChar.requestStr(request, "type")%>";
	if (s.length == 2 || type == "datetime")
		InitTime(s[1]);
	document.all.ButtonObj.style.display = "none";
	ResetCard();
	DateCard(tday);
	window.onload = null;
}

function SetComboValue()
{
	if (g_cbinputObj != null && typeof(g_cbinputObj) == "object")
	{
		g_cbinputObj.value = GetDateValue();
		if (!g_isOnLoad) {
			// 兼容chrome lxt 2017.11.10
			if(g_cbinputObj.fireEvent)
			g_cbinputObj.fireEvent("onchange");
		}
		g_isOnLoad = false;
		return true;
	}
	return false;
}

function GetDateValue()
{
	var value = tday.getFullYear() + "-" + (tday.getMonth() + 1) + "-" + tday.getDate();
	if (typeof(document.all.HourSel) == "object")
		value += " " + document.all.HourSel.value + ":" + document.all.MinuteSel.value + ":" + document.all.SecondSel.value;
	return value;
}

function ConfirmDateSelect()
{
	if (typeof(oFocus) == "object")
	{
		returnValue = GetDateValue();
		// Chrome lxt 2017.11.17
		if(navigator.userAgent.indexOf("Chrome")>-1){
			window.localStorage["crmSelectDialogRValue"]=returnValue;
		}
		if (typeof(g_cbinputObj) == "object")
			parent.document.body.fireEvent("onmousedown");
		else
		{
			if (IsNetBoxWindow())
				external.EndDialog(returnValue);
			else
				window.close();
		}
	}
	else
	//未选择日期
		alert("<j:Lang key="seledatetime.Check_slectdata"/>");
}

function DateCard(tday)
{
	var today = new Date();
	var mday = new Date(tday.getTime());
	mday.setDate(1);
	var ww = mday.getDay();
	var x;
	var month = mday.getMonth();
	var oTR, oTD;
	var func = new Function("SelectDate(this);");
	var func1 = new Function("ConfirmDateSelect();");
	
	document.all.MonthSel.selectedIndex = month;
	//年
	document.all.YearSel.innerText = tday.getFullYear() + "<j:Lang key="seledatetime.Year"/>";
	while (month == mday.getMonth())
	{
		oTR = document.all.DateTable.insertRow(-1);
		oTR.bgColor = "white";
		for (x = 0; x < ww; x++)
		{
			oTD = oTR.insertCell(-1);
			oTD.bgColor = GetWeekColor(x);
		}
		
		for (x = ww; x < 7; x++)
		{
			oTD = oTR.insertCell(-1);
			oTD.bgColor = GetWeekColor(x);
			oTD.innerText = mday.getDate();
			oTD.onclick = func;
			oTD.ondblclick = func1;
			if (mday.getDate() == tday.getDate())
				SelectDate(oTD);
			if (  (mday.getDate() == today.getDate())
			    &&(mday.getYear() == today.getYear())
			    &&(mday.getMonth() == today.getMonth()))	
				oTD.innerHTML = "<B>" + oTD.innerText + "</B>"
			mday.setDate(mday.getDate() + 1);
			if (month != mday.getMonth())
			{
				ww = mday.getDay();
				if (ww == 0)
					break;
				for (x = ww; x < 7; x++)
				{
					oTD = oTR.insertCell(-1)
					oTD.bgColor = GetWeekColor(x);
				}
				break;
			}
		}
		ww = 0;
	}
}

var oFocus;
function SelectDate(oTD)
{
	SelObject(oTD);
	tday.setDate(oTD.innerText);
	var ret = SetComboValue();
	if (event == null)
		return;
	if (ret && (event.srcElement == oTD))
		ConfirmDateSelect();
}

function SelectMonth()
{
	tday.setMonth(document.all.MonthSel.selectedIndex);
	tday.setMonth(document.all.MonthSel.selectedIndex);
	ResetCard();
	DateCard(tday);
}

function SelectYear(offset)
{
	if (typeof(offset) == "undefined")
	{
		var d = new Date();
		//请输入年份:
		offset = window.prompt("<j:Lang key="seledatetime.Check_year"/>", d.getFullYear()) -  tday.getFullYear();
	}

	var m = tday.getMonth();
	tday.setFullYear(tday.getFullYear() + offset);
	ResetCard();
	DateCard(tday);
}

function EditYear(obj)
{
	obj.contentEditable = true;
	document.execCommand("OverWrite");
	obj.focus();
}

function EditYearEnd(obj)
{
	obj.contentEditable = false;
	var value = parseInt(obj.innerText);
	if (value < 1900)
		value = 1900;
	if (value > 2099)
		value = 2099;
	SelectYear(value - tday.getFullYear());
}

function PressYear(obj)
{
	window.status = (event.keyCode);
	if (event.keyCode == 13)
		EditYearEnd(obj);
}

function ResetCard()
{
	var tbodys = document.all.DateBody.rows;
	for (x = tbodys.length - 1; x > 0; x--)
		document.all.DateBody.deleteRow(x);
}

function GetWeekColor(wk)
{
var clr;
	switch (wk)
	{
	case 0:
		clr = "mintcream"
		break;
	case 6:
		clr = "whitesmoke"
		break;
	default:
		clr = "white"
		break;
	}
	return clr;
}
</SCRIPT>
</BODY></HTML>