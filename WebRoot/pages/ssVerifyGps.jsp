<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
<%@ include file="/init_comm.jsp" %>
<%
int courseId = WebChar.RequestInt(request, "CourseId");
int classId = WebChar.RequestInt(request, "ClassId");
String sql;

sql = "SELECT GPSInfo,(SELECT StdName FROM SS_Student WHERE SS_Student.RegID=StudentID) StdName,StartTime,IP"
	+ " FROM SS_Attendance_Detail WHERE SyllabusesId=" + courseId
	+ " AND GPSInfo<>'' ORDER BY STDID";

String gpsData = jdb.getValueBySql(0, sql, ",");
if (gpsData.isEmpty()) {
	gpsData = "[]";
} else {
	gpsData = gpsData.replace(";", "';'");
	gpsData = gpsData.replace(",", "','");
	gpsData = "'" + gpsData + "'";
	gpsData = gpsData.replace(";", "],[");
	gpsData = "[[" + gpsData + "]]";
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <style type="text/css">
        body, html,#allmap {width: 100%;height: 100%;overflow: hidden;margin:0;font-family:"微软雅黑";}
    </style>
    <script type="text/javascript" src="http://api.map.baidu.com/getscript?v=2.0&ak=BCGrysMslrTxq3G0urVGlyt4Xd9W38yL"></script>
    <script type="text/javascript">
    
	    //坐标转换完之后的回调函数
	    translateCallback = function (data){
			if(data.status === 0) {
				for (var i = 0; i < data.points.length; i++) {
    				var markergg = new BMap.Marker(data.points[i]);
					bm.addOverlay(markergg);
					pos[i][3] = pos[i][3].replace(/\.0/, "");
				    var labelgg = new BMap.Label(pos[i][2] + "<br>" + pos[i][3] + "<br>" + pos[i][4]
				    	, {offset:new BMap.Size(20,-10)});
				    markergg.setLabel(labelgg); //添加GPS label
					bm.setCenter(data.points[i]);
				}
			}
		}
    	
    	function viewPos() {
	        var pointArr = [];
    		for (var x = 0; x < pos.length; x++) {
    			var ggPoint = new BMap.Point(pos[x][0], pos[x][1]);
	        	pointArr.push(ggPoint);
    		}
	        var convertor = new BMap.Convertor();
	        convertor.translate(pointArr, 1, 5, translateCallback);
    	}
    	
    	function posData(str) {
    		pos = [
    			  [116.3786889372559,39.90762965106183, '张三']
    			, [116.38632786853032,39.90795884517671, '李四']
    			, [116.39534009082035,39.907432133833574, '王五']
    		];
    		viewPos();
    	}
    	
    	function getPos() {
    		//posData();
    		pos = <%=gpsData %>;
    		if (pos.length == 0) {
    			return;
    		}
    		
    		viewPos();
    	}
    	
    	function initMap() {
		    //地图初始化
		    bm = new BMap.Map("allmap");
		    //设置地图中心点和缩放级别
			bm.centerAndZoom(new BMap.Point(116.47496938705444, 39.873154043017784), 19);
    		bm.addControl(new BMap.NavigationControl());
    		
    	}
    	
    	var bm;
    	var pos = null;
    	window.onload = function() {
    		//initMap();
    		//获取考勤学员地理位置
    		//getPos();
    	};
    </script>
    <title>GPS转百度</title>
</head>
<body>
    <div id="allmap"></div>
</body>
</html>
<script type="text/javascript">




    initMap();
	getPos();
</script>

<%
	jdb.closeDBCon();
%>