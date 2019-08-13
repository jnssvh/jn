<%@ page language="java" import="java.sql.* ,com.jaguar.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="org.apache.log4j.Logger"%>
<%@ include file="com/init.jsp" %>
<%!
static Logger logger = Logger.getLogger("jnetface_jsp");
 %>
<%
String sql = "", ms = "";
	out.print(WebFace.GetHTMLHead("界面管理器", "<link rel='stylesheet' type='text/css' href='forum.css'>"));
	out.print("<body topmargin=0 leftmargin=0 bgcolor='#ffffff'>");
	int flag = WebChar.RequestInt(request, "UploadFlag");
	int DefaultFlag = WebChar.RequestInt(request, "DefaultFlag");
	if (flag == 1)
	{
		if (DefaultFlag != 1)
		{
			out.print("<script language=javascript>var win=window.external.Browser.GetProperty(\"HTMLWinParent\");win.location.reload(true);</script>");
	
			String[] ModuleIDs = WebChar.requestStr(request, "FaceData").split(","), ss = null;
			for (int x = 0; x < ModuleIDs.length; x++)
			{
				ss = ModuleIDs[x].split(":");
				ms = WebChar.requestStr(request, "img_url_" + ss[0]);
				if ( ms.length() > 0 )
				{
					ms = ",auth_img='" + ms + "'";
				}
				sql = "UPDATE RightObject SET auth_order=" + x + ", auth_show=" + ss[1] + ms + " WHERE auth_id=" + ss[0];
				logger.info(sql);
				jdb.ExecuteSQL( 0, sql);
			}
			if (WebChar.RequestInt(request, "ApplyFlag") == 0)
			{
				out.print("<script language=javascript>window.external.close();</script></body></html>");
				return;
			}
		}
		else
		{
			sql = "UPDATE RightObject SET auth_order=(SELECT auth_order FROM RightObjectOLD"
				+ " WHERE RightObjectOLD.auth_id=RightObject.auth_id)"
				+ ", auth_show=(SELECT auth_show FROM RightObjectOLD"
				+ " WHERE RightObjectOLD.auth_id=RightObject.auth_id)"
				+ ",auth_img=(SELECT auth_img FROM RightObjectOLD"
				+ " WHERE RightObjectOLD.auth_id=RightObject.auth_id)"
				+ " WHERE auth_id IN (SELECT auth_id FROM RightObjectOLD)";
			logger.info("恢复默认值数量：" + jdb.ExecuteSQL( 0, sql));
		}
	}


	String sql = "SELECT auth_id FROM RightObject WHERE auth_name='易用通(客户端)'";
	int parent_node = jdb.getIntBySql(0, sql);
	sql = "SELECT * FROM RightObject WHERE parent_node=" + parent_node + " AND auth_status=1 ORDER BY auth_order, auth_no";
	ResultSet rs = jdb.rsSQL(0, sql);
	out.print("<form action=jnetface.jsp method=POST name=FaceSave>");
	out.print("<div class='MenuBarTable1' style='background:repeat-x url(pic/jnetface_bg.png);height:30;padding-top:5px;padding-left:30px;border-bottom:1 solid #A1CCEB;'>面板设置</div>");
	//out.print("<fieldset id=ShoutCut><legend style=FONT-SIZE:9pt>面板设置</legend>");
	out.print("<table border=0 width=100% align=center><tr><td style='border:1px solid #EEEEEE'>");
	out.print("<table width=100% cellpadding=1 cellspacing=1 border=0>" +
		"<tr align='center'><td width=30>显示</td><td width=40>图标</td><td width=100>名称</td><td width=200>替换文件(30x30 gif)</td></tr></table>");
	out.print("<table width=100% id=PageTable cellpadding=2 cellspacing=0 bgcolor=gray border=0 align=center>");
	while ( rs.next() )
	{
		out.print("<tr onclick=SelectObj(this) bgcolor=white node=" + rs.getString("auth_id") +
			"><td width=30><input type=checkbox " + VB.isString("checked", rs.getInt("auth_show") == 1) + "></td>" +
			"<td width=40><img width=30 height=30 src=" + rs.getString("auth_img") + "></td>" +
			"<td width=100>" + rs.getString("auth_name") + "</td>" +
			"<td width=200><input type=hidden name=img_url_" + rs.getString("auth_id") 
			+ "><input type=text name=Img_" + rs.getString("auth_id") 
			+ "><input type=button name=ingupload value='上传' onclick='upload(this);'></td>" +
			"</tr>");
	}
	jdb.rsClose(0, rs);
	out.print("</table></td>");
	out.print("<td valign=top width=50px><input type=button value='更换图标' style=display:none>" +
		"<button onclick=TableRowShift(oFocus,-1)><img src='pic/jnetface_arrow_up.png' style='vertical-align:middle;'>上移</button><br>" +
		"<button onclick=TableRowShift(oFocus,2)><img src='pic/jnetface_arrow_down.png' style='vertical-align:middle;'>下移</button></td></tr></table>");		//</fieldset>
	out.print("<div align=center style=\"border-top:1 solid #A1CCEB;padding-top:8px;background:repeat-x url(pic/jnetface_bg.png);\"><input type=button value=恢复默认值 onclick=SaveDefault()>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
		"<input type=button value=确定 onclick=Confirm()>&nbsp;&nbsp;" +
		"<input type=button value=取消 onclick=window.external.close()>&nbsp;&nbsp;" +
		"<input type=button value=应用 onclick=Apply()>&nbsp;&nbsp;</div>");


%>
<input type=hidden name=UploadFlag value=1>
<input type=hidden name=FaceData>
<input type=hidden name=ApplyFlag value=0>
<input type=hidden name=DefaultFlag value=0>
<%="</form>" %>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript src=com/common.js></script>
<script language=javascript>
function window.onload()
{
	document.all.PageTable.rows[0].click();
}

function Confirm()
{
	var value = "";
	for (var x = 0; x < document.all.PageTable.rows.length; x++)
	{
		if (document.all.PageTable.rows[x].cells[0].firstChild.checked)
			value += "," + document.all.PageTable.rows[x].node + ":1";
		else
			value += "," + document.all.PageTable.rows[x].node + ":0";
	}
	document.all.FaceData.value = value.substr(1);
//	if (document.all.FaceImgFile.value != "")
//	{
//		if ((document.all.FaceImage.width != 212) || (document.all.FaceImage.height != 53))
//		{
//			if (window.confirm("选择的图片尺寸为:" + document.all.FaceImage.width + "x" + document.all.FaceImage.height +",不是212x53, 是否确定?") == false)
//			{
//				return false;
//			}
//		}
//	}
	document.all.FaceSave.submit();
}

function SaveDefault()
{
	document.all.DefaultFlag.value = 1;
	document.all.FaceSave.submit();
}

function Apply()
{
	document.all.ApplyFlag.value = 1;
	Confirm();
}

function UploadFile()
{
	document.all.FaceImage.src = document.all.FaceImgFile.value;
}

function ChangeIcon(obj)
{
	var oTR = obj.parentNode.parentNode;
	oTR.cells[1].firstChild.src = obj.value;
}

function upload(obj)
{
	AutoSelectFile.start("FormDataFrame",{rename:"ms", loadtype:"jpg,gif,png,bmp"
		,filepath:"images/face", script:"parentObj.uploaded('" + obj.previousSibling.name + "',filename0,fullname);"
		}
	)
}

function uploaded(obj, filename0,fullname)
{
	//alert(obj + "==" + filename0+","+fullname);
	var o = document.getElementsByName(obj)[0];
	o.value = filename0;
	o.previousSibling.value = fullname;
	var oTR = o.parentNode.parentNode;
	oTR.cells[1].firstChild.src = fullname;
}
</script>
<iframe name="FormDataFrame" style="display:none;"></iframe>
<%out.print("</body></html>");
jdb.closeDBCon();%>