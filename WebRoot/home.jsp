<%@ page language="java" import="java.util.*" pageEncoding="gbk"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<HEAD>
<TITLE> E用通首页 </TITLE>
<META NAME="Generator" CONTENT="EditPlus">
<META NAME="Author" CONTENT="">
<META NAME="Keywords" CONTENT="">
<META NAME="Description" CONTENT="">
<style type="text/css">
body{background-color:white;
font-size:14px;marign:0px;padding:0px;color:black;}
div{
margin:0px;padding:0px;
}
img{border:0px;}
ul,li{margin:0px;padding:0px;list-style:none;list-style-type:none;}
table{border-collapse:collapse;}
td{border:0px solid gray;}
.span1{margin-left:-120px;background-color:#FF8080;}
.span1 span{padding-left:4px;padding-right:4px;padding-top:1px;padding-bottom:1px;
border:1px solid #EE2255;background-color:#FF8080;cursor:pointer;
color:#FDFDFD;
}
a{color:#004499;text-decoration:none;}
a:hover{color:#B6320A;text-decoration:underline;}
.ul2{width:100%;padding-top:8px;}
.ul2 li{float:left;width:100px;}
.ul2 a{color:white;}
.div3{width:358px;height:20px;overflow:hidden;
position:relative;top:-26px;background-color:#000000;opacity:0.5;
filter:alpha(opacity=50);color:white;padding-top:5px;}
.ul3{width:110px;height:20px;position:relative;top:-46px;left:260px;font-size:12px;}
.ul3 li{float:left;width:16px;height:13px;border-right:1px solid #FAFAFA;
color:white;text-align:center;background-color:#5784E7;filter:alpha(opacity=80);
cursor:pointer;}
</style>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript src=com/seek.jsp></script>
<script type="text/javascript" src="js/lxt_box.js"></script>
<script type="text/javascript">
window.onload=function(){
//==设置好起点，开始执行自动切换图片
g_imgNum=1;
g_liField=document.getElementById("coolLi_1");
autoToggleCoolImg();
CheckEUT();
}

function CheckEUT()
{
	var img = new Image(1, 1);
	img.src = "C:\\EUT\\nsoft16.ico";
	if (img.readyState != "complete")
	{
		BodyAlert("<b>信息处友情提醒:</b><BR><p>为了保证教职工能及时看到校园网站和学校的最新消息，<br>现向大家推荐一款能即时弹出学校最新消息的客户端软件：<br><b>易用通-消息盒</b><br>" +
			"<br>您只需点击下面的链接运行即可完成安装。</p><a href=EUT.exe>安装客户端软件易用通-消息盒(EUT.exe 1.12MB)</a>");
	}
}
//==手动切换图片
function showCoolImg(imgNum,liField)
{
	var img=document.getElementById("coolImg_"+imgNum);
	if(img==null||img=="undefined")return;
	var imgArr=img.parentNode.parentNode.getElementsByTagName("img");
	for(var i=0; i<imgArr.length; i++){
		imgArr[i]!=img ? imgArr[i].style.display="none" : img.style.display="block";
	}
	var liArr=liField.parentNode.getElementsByTagName("li");
	for(i=0; i<liArr.length; i++){
		liArr[i]!=liField ? liArr[i].style.backgroundColor="#5784E7" : liField.style.backgroundColor="#FA524C";
	}
	//==显示标题
	var titleDiv=liField.parentNode.parentNode.getElementsByTagName("div")[1];
	titleDiv.innerHTML="&nbsp"+img.attributes["title"].value;
	//==设置自动切换的起点
	g_imgNum=imgNum;
	g_liField=liField;
}
//==自动切换图片,此处js代码比html要快，所以getElementById("coolLi_1")不到元素
var g_imgNum=1;
var g_liField=null;
function autoToggleCoolImg()
{
	var liArr=g_liField.parentNode.getElementsByTagName("li");
	if(g_imgNum==5) {
		showCoolImg(g_imgNum, g_liField);
		g_imgNum=1;
		g_liField=liArr[0];
		window.setTimeout(autoToggleCoolImg, 3500);
	}else{
		showCoolImg(g_imgNum, g_liField);
		g_liField=liArr[g_imgNum];
		g_imgNum+=1;
		window.setTimeout(autoToggleCoolImg, 3500);
	}
	
	
}
function SubmitForm()
{
	var userName = document.getElementsByName("UserName")[0].value;
	var password = document.getElementsByName("Password")[0].value;
	if (userName == "")
	{
		alert("请填写用户名。");
		return;
	}
	/*if (password == "")
	{
		alert("请填写密码。");
		return;
	}*/
	document.forms[0].submit();
}
function PressKey(event)
{
	if ((event.keyCode == 13) || (event.keyCode == 10))
	{
			SubmitForm();
	}
}
</script>
</HEAD>
<body>
<%  
JDatabase jdb = null; 
jdb = new JDatabase(); 
jdb.InitJDatabase(); 
 
%>
<div id="content" style="width:100%;height:900px;margin:0px auto;">
	<div style="margin:0px auto;width:800px;height:auto;">
		<div style="width:100%;font-size:12px;color:#303030;">
			<table style="width:100%;">
				<tr><td><img src="images/104.jpg"/></td>
				<td style="text-align:right;vertical-align:bottom;"><div style="height:18px;overflow:hidden;">
					<form id="formLogin" action="chklogin.jsp" method="post">
					<input type=hidden name=RetryTime>
					<input type=hidden name=ClientInfo>
					<input type=hidden name=JustUserID>
					<input type=hidden name=clientType value="web">
					<input type=hidden name=LoginPage value='home.jsp'>
					E用通用户名：<input type="text" name="UserName" style="width:80px;height:12px;border:1px solid #B4B4B4;"/>&nbsp;
					密码：<input type="password" name="Password" style="width:80px;height:12px;border:1px solid #B4B4B4;"/>&nbsp;
					<input type="image" src="images/105.gif" style="vertical-align:-5px;"/>&nbsp;
					<a href="#" onclick="showLxtBox('open','registerUser.jsp',660,572, '员工注册');">注册新用户</a>&nbsp;
					</form></div>
				</td></tr>
			</table>
		</div>
		<div style="width:100%;height:30px;background-image:url('images/103.gif');background-repeat:repeat-x;background-color:white;">
		<ul class="ul2">
			<li style="width:100px;">&nbsp;&nbsp;<span style="vertical-align:middle;"><img src="images/108.png"/></span>&nbsp;<a style="color:#C306CA;" href="home.jsp">首页</a></li>
			<%
				String sql0="SELECT EnumString,EnumValue FROM UEnumData WHERE EnumTypeCode='news_columns' ORDER BY id";
				ResultSet rs0=jdb.rsSQL(0, sql0);
				for(int i=1; rs0.next(); i++){
					out.println("<li><span style='vertical-align:middle;'><img src='images/news1.png'/></span>"
					+"&nbsp;<a target='_blank' href='news_more_bs.jsp?enumValue="+rs0.getString("EnumValue")+"'>"+rs0.getString("EnumString")+"</a>&nbsp;</li>");
				}rs0.close();
				
			 %>
		</ul>
		</div>
<%
String sql = "", colorStr = "", rs_color = "", rs_image_url = "", rs_title = "", DataID = "";
String span1 = "", span2 = "", rs_content = "", title = "";
ResultSet rs = null, rs1 = null;
int view_type = 0;
//显示图片新闻和新闻头条
sql =jdb.SQLSelect(0, 1, "ID,title,news_columns", "news", "flow_node=2","submit_time desc"); 
//"SELECT * FROM news WHERE flow_node=2 AND view_type>0 ORDER BY view_type DESC";
rs = jdb.rsSQL(0, sql);
out.println("<div style='width:800px;margin:0px auto;margin-top:20px;text-align:center;border-bottom:1px dotted gray;padding-bottom:5px;'>");

if (rs.next())
{
	rs_title = rs.getString("title");
	DataID = rs.getString("id");
	out.println("<a target='_blank' style='font-size:16px;font-weight:bold;' href='news_view_bs.jsp?DataID="+DataID+"&enumValue="+rs.getString("news_columns")+"'>"+rs_title+"</a>");
}
out.println("</div>");
jdb.rsClose(0, rs);


out.println("<div style='width:100%;float:left;margin-top:20px;margin-bottom:5px;text-align:center;'>");
out.println("<table style='width:100%;height:230px;'>");
out.println("<tr><td style='width:390px;vertical-align:top;'>");
sql=jdb.SQLSelect(0,10,"ID,title,content,view_type,submit_time,news_columns","news","flow_node=2","submit_time desc");
rs=jdb.rsSQL(0, sql);
String temImgUrl="";
StringBuilder imageSB=new StringBuilder();
int imgNum=0;
while(rs.next()){
	rs_title = rs.getString("title");
	title="title='"+rs_title+"'";
	if ( rs_title.length() > 18 )
	{
			rs_title = rs_title.replaceAll("(.{18}).*", "$1…");
	}
	DataID = rs.getString("id");
	rs_content = rs.getString("content");
	view_type=rs.getInt("view_type");
	
		
	if(rs_content.matches("(?i)[\\s\\S]*?<img[^>]+src=\"[^\"]*\"[\\s\\S]*")){
		++imgNum;
		temImgUrl=rs_content.replaceAll("(?i)[\\s\\S]*?<img[^>]+src=\"([^\"]*)\"[\\s\\S]*", "$1");
		temImgUrl = temImgUrl.replaceAll("(?i)http:\\/\\/.+?\\/", "\\/");
		temImgUrl = temImgUrl.replaceAll("\\.\\.\\/", "");
		imageSB.append("<a target='_blank' href='news_view_bs.jsp?DataID=" + DataID+"&enumValue="+rs.getString("news_columns")+"'>");
		imageSB.append("<img id='coolImg_"+imgNum+"' title='"+rs_title+"' src=\"" +temImgUrl+"\" style=\"width:360px;height:240px;\" /></a>");
	}else temImgUrl="";
	
	out.println("<div style='width:100%;'>");
	out.println("<ul style='width:100%;height:25px;'><li style='width:75%;float:left;text-align:left;margin-left:0px;'>");
	out.println("<span><img src='images/li.gif'></span>");
	out.println("<a target='_blank' "+title+" href=\"news_view_bs.jsp?DataID=" + DataID+"&enumValue="+rs.getString("news_columns")+"\">" +  rs_title + "</a></li>");
	out.println("<li style='text-align:right;'>"+rs.getDate("submit_time")+"</li></ul>");
	out.println("</div>");
}jdb.rsClose(0, rs);
out.println("</td>");
out.println("<td style='width:atuo;text-align:left;vertical-align:top;padding:0px;'>");
out.println("<div style='width:360px;height:240px;overflow:hidden;margin-left:20px;'>");
out.println("<div style='width:360px;height:240px;overflow:hidden;'>"+imageSB.toString()+"</div>");
out.println("<div class='div3'>&nbsp;这里显示新闻标题</div>");
out.println("<ul class='ul3'>");
out.println("<li id='coolLi_1' style='background-color:#FA524C;' onclick='showCoolImg(1,this);'>1</li>");
out.println("<li onclick='showCoolImg(2,this);'>2</li><li onclick='showCoolImg(3,this);'>3</li>");
out.println("<li onclick='showCoolImg(4,this);'>4</li><li style='border:0px;' onclick='showCoolImg(5,this);'>5</li></ul>");
out.println("</div>");
out.println("</td></tr></table>");
out.println("</div>");


//按栏目显示新闻
int count = 0,times=0;
sql = "SELECT EnumString,EnumValue FROM UEnumData WHERE EnumTypeCode='news_columns' ORDER BY id";
rs = jdb.rsSQL(0, sql);
while (rs.next())
{
	rs_title = rs.getString("EnumString");
	if(times%2==0) out.println("<div style='width:390px;height:250px;overflow:hidden;float:left;margin-top:10px;'>");
	else if(times%2!=0) out.println("<div style='width:380px;height:250px;overflow:hidden;float:left;margin-top:10px;margin-left:20px;'>");
	out.println("<table style='width:100%;'><tr>");
	out.println("<td style='border-bottom:1px solid gray;font-weight:bold;'>"+rs_title+"</td>");
	out.println("<td style='text-align:right;border-bottom:1px solid gray;'><a href='news_more_bs.jsp?enumValue="+rs.getString("EnumValue")+"'>更多..</a></td>");
	out.println("</tr><tr><td colspan='2'>");
	count = 0;
	++times;
	sql = jdb.SQLSelect(0, 10, "ID,view_type,title,submit_time,news_columns", "news", "flow_node=2 AND news_columns=" + rs.getString("EnumValue"), "is_top DESC,view_date");
	rs1 = jdb.rsSQL(0, sql);
	while (rs1.next())
	{
		view_type = rs1.getInt("view_type");
		rs_title = rs1.getString("title");
		DataID = rs1.getString("id");
		if (count == 0)colorStr = "font-size:11pt;";
		else colorStr = "font-size:10pt;";
		title = " title=\"" + rs_title + "\"";
		if ( rs_title.length() > 18 )
		{
			rs_title = rs_title.replaceAll("(.{18}).*", "$1…");
		}
		else
		{
			title = "";
		}
		out.println("<div style='width:100%;'>");
		out.println("<ul style='width:100%;margin-top:5px;'><li style='width:75%;float:left;text-align:left;margin-left:0px;'><span><img src='images/li.gif'></span>");
		out.println("<a target='_blank' "+title+" href=\"news_view_bs.jsp?DataID=" + DataID+"&enumValue="+rs1.getString("news_columns")+"\">"+rs_title + "</a></li>");
		out.println("<li style='text-align:right;'>"+rs1.getDate("submit_time")+"</li></ul>");
		out.println("</div>");
		count++;
	}
	out.println("</td></tr></table></div>");
	
	jdb.rsClose(0, rs1);
}

jdb.rsClose(0, rs);

jdb.closeDBCon();
 %>
 	</div>
 </div>




</body>
</html>
