<%@ page language="java" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="init_comm.jsp"%>
<%int ModuleNo = WebChar.RequestInt(request, "ModuleNo");
 %>
<!DOCTYPE html PUBLIC
          "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<meta http-equiv="Content-Type" content="text/html; charset=GBK" />
<title>Dynarch Calendar -- Special date information</title>
    <script src="application/jscal/js/jscal2_cn.js"></script>
    <script src="application/jscal/js/lang/cn_cn.js"></script>
    <link rel="stylesheet" type="text/css" href="application/jscal/css/jscal2.css" />
    <link rel="stylesheet" type="text/css" href="application/jscal/css/border-radius.css" />
    <link rel="stylesheet" type="text/css" href="application/jscal/css/steel/steel.css" />
    <style type="text/css">
      .highlight { color: #f00 !important; }
      .highlight2 { color: #0000ff !important; font-weight: bold;background-color:#aaaaaa; }
    </style>
    <script language=javascript src=com/psub.jsp></script>
    <link rel='stylesheet' type='text/css' href='com/forum.css' />
    <script type="text/javascript">
window.onload = function(){
	var cal = document.getElementById("calendar-container");
	var divs = document.getElementsByTagName("div");
	for (var i = 0; i < divs.length; i++)
	{
		if (/^(?:DynarchCalendar-day DynarchCalendar-weekend|DynarchCalendar-day)$/i.test(divs[i].className))
		{
			divs[i].style.backgroundColor = "#aaaaaa";
		}
	}

};
    </script>
  </head>
  <body topmargin="0" leftmargin="0">
  <%=sysApp.getModuleInlineMenu(ModuleNo, "点击这里选择更多工作日程功能...<img src=pic/downtools.gif>", "#FFFFE1") %>
    <table style="width:100%" cellspacing="0" cellpadding="0">
      <tr>
        <td align="center"><div id="calendar-container"></div></td>
      </tr>
      <tr>
        <td>
        <iframe name="calendar-info" frameborder=0 width=100% scrolling=auto height=100% src='DateHint.jsp?CalDate=<%=VB.Date()%>'></iframe>
        </td>
      </tr>
    </table>
    <script type="text/javascript">//<![CDATA[

      var DATE_INFO = {
              20091107: { klass: "highlight" },
              20091108: { klass: "highlight" }
      };

      function getDateInfo(date, wantsClassName) {
              var as_number = Calendar.dateToInt(date);
              if (as_number >= 20091118 && as_number <= 20091124)
			  {
                      return {
                              klass   : "highlight2"
                      };
			  }
              return DATE_INFO[as_number];
      };
/*
      var cal = Calendar.setup({
              cont     : "cont",
              fdow     : 1,
              date     : 20091101,
              dateInfo : getDateInfo
      });
*/

function $(id) {
	var rtn = document.getElementById(id);
	if (rtn == null) {
		rtn = document.getElementsByName(id);
	}
	return rtn;
}
var cal = Calendar.setup({
    cont          : "calendar-container",
    weekNumbers   : true,
    selectionType : Calendar.SEL_SINGLE,	/*SEL_SINGLE,SEL_MULTIPLE*/
    selection     : Calendar.dateToInt(new Date()),
    showTime      : false,
    onSelect      : function() {
        var count = this.selection.countDays();
        if (count == 1) {
		//throw 4;
            var date = this.selection.get();
			//alert(date.constructor);
            date = Calendar.intToDate(date);
            date = Calendar.printDate(date, "%Y-%m-%d");
            $("calendar-info").src = "DateHint.jsp?CalDate=" + date;
        } else {
            $("calendar-info").innerHTML = "2  |  " + Calendar.formatString(
                "$ {count:no date|one date|two dates|# dates} selected",
                { count: count }
            );
        }
    },
    onTimeChange  : function(cal) {
        var h = cal.getHours(), m = cal.getMinutes();
        // zero-pad them
        if (h < 10) h = "0" + h;
        if (m < 10) m = "0" + m;
        $("calendar-info").innerHTML = Calendar.formatString("Time changed to ${hh}:${mm}", {
            hh: h,
            mm: m
        });
    }
});

    //]]></script>

  </body>
</html>
<%
jdb.closeDBCon();
%>