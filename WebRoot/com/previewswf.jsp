<%@ page language="java" import="java.sql.* ,com.jaguar.*,java.io.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%!
private int nDB = 0;
public String viewSwfFile(JDatabase jdb, int AffixID) {
		if (AffixID == 0) {
			return "body:�鿴�ļ�����ȷ��";
		}
		String sql = "SELECT FileURL FROM AffixFile WHERE ID=" + AffixID;
		String url = jdb.getStringBySql(nDB, sql);
		String name = WebChar.getValueByRegExp(".*\\\\(.*)", url);
		String swfFile = "tmp/"+name+".swf";
		String tomcatUrl = Config.getItem(Config.ItemType.DiskPath);
		System.out.println("tomcat=" + tomcatUrl);
		//�����ļ�ת��
		if(!isExits(tomcatUrl+swfFile)){
			
	        System.out.println(swfFile + "  �ļ������ڣ���ʼת����");
			toSwf(url,tomcatUrl+swfFile);
			
			//���߳�˯��15��ȴ��ļ�����
			try {
				Thread.sleep(15000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}else{
			System.out.println("�ļ��Ѵ��ڲ���ת��");
		}
		String swfName = swfFile.split("/")[1];
		//System.out.println(swfFile.split("/")[2]);
		String swfUrl = "";
		swfUrl = "tmp/"+swfName;
		String str = "<center>"
				+ "<div style='background-color: #999999;height: 300px;width: 100%;' >"
				+ "<object type='application/x-shockwave-flash' data='11.swf' style='width: 100%;height: 100%'/>"
				+ "<param name='movie' value='../" + swfUrl + "'/>"
				+ "<param name='wmode' value='transparent' />"
				+ "</object>"
				+ "</div>"
				+ "<br />�����ʱ���޷���ҳ�棬��ˢ�µ�ǰҳ�棡"
				+ "</center>";
		return "../" + swfUrl;
	}
	
public boolean toSwf(String file,String swfFile){
		
		
		boolean flag =false;
		  try {             
	        	//String dos = "C:\\Program Files\\Macromedia\\FlashPaper 2\\FlashPrinter.exe c:\\123.doc -o d:\\1.swf";              
	        	String command = "FlashPrinter "+file+" -o "+swfFile;
	        	System.out.println(command);
	        	Process process = Runtime.getRuntime().exec(command);              
	        	System.out.println("ִ�гɹ�"); 
	        	flag = true;
		  } 
	        catch (IOException e) {
	        	e.printStackTrace();         
	        	}  
	        
	        return flag;
	        }
	
	
	

	/***
	 * �ж��ļ��Ƿ�ת����
	 * @param swfFile Ҫת���ɵ�swf�ļ�
	 * @return���ڷ���true���򷵻�false
	 */
	public boolean isExits(String swfFile){
		
		
		File file = new File(swfFile);
		
		return file.exists();
	}

 %>
<%

JDatabase jdb = new JDatabase();
jdb.InitJDatabase();
Cookie cookie[] = request.getCookies();


String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE>�ĵ�Ԥ��</TITLE>
<META NAME="Generator" CONTENT="EditPlus">
<META NAME="Author" CONTENT="">
<META NAME="Keywords" CONTENT="">
<META NAME="Description" CONTENT="">
<link rel='stylesheet' type='text/css' href='forum.css'>
<script type="text/javascript" src="<%=basePath%>com/psub.jsp"></script>
<script type="text/javascript" src="<%=basePath%>js/jaguar.js"></script>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
window.onload = function() {
	var h = document.body.offsetHeight;
	h -= 30;
	if (h < 200) {
		h = 200;
	}
	document.getElementById("div_flash").style.height = h + "px";
};
</script>
</HEAD>
<BODY topmargin="0">
     <center>
    <div id="div_flash" style="background-color: #999999;height: 300px;width: 100%;" >
    	<object type="application/x-shockwave-flash" data="11.swf" style="width: 100%;height: 100%"/>
			<param name="movie" value="<%
int AffixID = WebChar.RequestInt(request, "AffixID");
String flash = viewSwfFile(jdb, AffixID);
out.print(flash);
 %>"/>
			<param name="wmode" value="transparent" />
			
		</object>

	</div>
	<br />�����ʱ���޷���ҳ�棬��ˢ�µ�ǰҳ�棡
	</center>

</body>
</html>
<% jdb.closeDBCon();%>