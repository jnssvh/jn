<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanEvStat1";
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	switch (loginType)
	{
	case 2:
		user = new studentUser();
		break;
	default:
		user = new SysUser();
		break;
	}
	int result = user.initWebUser(jdb, cookie);
	if (result != 1)
	{//如果cookie丢失，就从命令行取出账户，重设cookie
		String EName = WebChar.requestStr(request, "UserName");
		Cookie [] ck = new Cookie[2];
		ck[0] = new Cookie("loginname", EName);
		ck[1] = new Cookie("loginpassword", WebChar.requestStr(request, "Password"));
		result = user.initWebUser(jdb, ck);
		if (result != 1)
		{
			jdb.closeDBCon();
			response.sendRedirect("../cps/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanEvStat1' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##627:服务器启动代码(归档用注释,切勿删改)
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

String type = WebChar.requestStr(request, "type");
if (type.equals("getCourseData")) {
	int DataClass_id = WebChar.RequestInt(request, "DataClass_id");
	String sql = "SELECT Syllabuses_subject_name,evaluate_rate,evaluate_count,effective_average"
		+ ",Syllabuses_date,Syllabuses_AP"
		+ " FROM CPB_Syllabuses WHERE class_id=" + DataClass_id
		+ " AND evaluate_id>0"
		+ " ORDER BY Syllabuses_date,Syllabuses_AP";
	ResultSet rs = jdb.rsSQL(0, sql);
	String[] column = new String[4];
	column[0] = "['课程'";
	column[1] = "['参评率'";
	column[2] = "['评估人数'";
	column[3] = "['平均分'";
	while (rs.next()) {
		String Syllabuses_subject_name = rs.getString("Syllabuses_subject_name");
		float evaluate_rate = rs.getFloat("evaluate_rate");
		int evaluate_count = rs.getInt("evaluate_count");
		float effective_average = rs.getFloat("effective_average");
		String Syllabuses_date = rs.getString("Syllabuses_date").replaceFirst(" .*", "");
		String Syllabuses_AP = rs.getString("Syllabuses_AP");
		String courseName = Syllabuses_date + Syllabuses_AP + " " + Syllabuses_subject_name;
		column[0] += ",'" + courseName + "'";
		column[1] += "," + evaluate_rate;
		column[2] += "," + evaluate_count;
		column[3] += "," + effective_average;
	}
	jdb.rsClose(0, rs);
	column[0] += "]";
	column[1] += "]";
	column[2] += "]";
	column[3] += "]";
	
	out.clear();
	out.println("[");
	out.println(column[0]);
	out.println(", ");
	out.println(column[1]);
	out.println(", ");
	out.println(column[2]);
	out.println(", ");
	out.println(column[3]);
	out.println("]");
	out.flush();
	jdb.closeDBCon();
	return;
} else if (type.equals("getCourseOrderData")) {
	int DataClass_id = WebChar.RequestInt(request, "DataClass_id");
	String sql = "SELECT TaskName,UsedAverage,RealPapes,CourseOrder"
		+ ",EvaluateRate,BeginTime"
		+ " FROM CPB_EvaluateTask WHERE ClassIDs='" + DataClass_id + "'"
		+ " AND EvaluateID>0 AND TermID>0"
		+ " ORDER BY CourseOrder";
	app.echarts.EchartsDataSet set = new app.echarts.EchartsDataSet(jdb);
	
	String template = "<map>"
				+ "<row><name>课程</name><data>CourseOrder.BeginTime TaskName</data></row>"
				+ "<row><name>排行榜</name><data>UsedAverage</data></row>"
				+ "<row><name>平均分</name><data>CourseOrder</data></row>"
				+ "</map>";
	template = "课程,CourseOrder.BeginTime TaskName;排行榜,UsedAverage;平均分,CourseOrder";
	template = "课程,TaskName;上课时间,BeginTime;授课人,Teachers;排行榜,CourseOrder;平均分,UsedAverage";
	template = "课程,TaskName;排行榜,CourseOrder";
	template = "课程,TaskName;平均分,UsedAverage;排行榜,CourseOrder";
	String data = set.getDataSetBySql(template, sql);
	//System.out.println(data);

	out.clear();
	out.println(data);
	out.flush();
	jdb.closeDBCon();
	return;
}
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>课程评分排名</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript" src="<j:Prop key="ContextPath"/>js/ECharts/dist/echarts.min.js" charset='UTF-8'></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanEvStat1", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
//@@##624:客户端加载时(归档用注释,切勿删改)
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.Filter = new TermClassFilter(o, {Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.Filter.onclickClass = ClickEVTask;
	book.setPageObj(book.Filter);
	
	
	
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##628:客户端自定义代码(归档用注释,切勿删改)
function ClickEVTask(obj, item) {
	
	if (book.Page == undefined)
	{
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_EvaluateTask_deanEvStat1.jsp"
			, {formitemstyle:"font:normal normal normal 16px 微软雅黑", 
			formvalstyle:"width:400px", URLParam:"?ClassIDs=" + item.Class_id}, {}
			, {gridstyle:4, resizeflag:0});
	}
	else
	{
		book.Page.config({URLParam:"?ClassIDs=" + item.Class_id});
		book.Page.ReloadGrid();
	}
	getCourseOrderDataByClass(item.Class_id);
}


function getCourseOrderDataByClass(Class_id) {
	orderNo = 0;
	if (document.getElementById('courseChartCase') == null) {
		var caseHtml = "<div id='courseChartCase' style='border:1px solid red;width:100%;height:" + 600 + "px;'></div>";
		$("#Page").append(caseHtml);
	}
	$.get("deanEvStat1.jsp", {"DataClass_id":Class_id, "type" : "getCourseOrderData"}, viewChart2);
}

var orderNo = 0;



function viewChart25(data) {
	data = eval(data);
	var option = {
		backgroundColor: '#eeeeee',
		color:['red', 'green','yellow','blueviolet'],
	    aria: {
	        show: true
	    },
	    title : {
	        text: '班级课程排行榜',
	        subtext: '班级名称',
	        x:'center'
	    },
	    /*
	    tooltip : {
	        trigger: 'item',
	        formatter: "{a} <br/>{b} : {c} ({d}%)"
	    },
	    */
	    legend: {
	        orient: 'vertical',
	        left: 'left',
	        //data: ['直接访问','邮件营销','联盟广告','视频广告','搜索引擎']
	    },
	    dataset: {
	        // 提供一份数据。
	        source: data
	    },
	    series : [
	        {
	            name: '排行榜',
	            type: 'pie',
				seriesLayoutBy: 'row',
	            radius : '55%',
	            center: ['50%', '60%'],
	            /*data:[
	                {value:335, name:'直接访问'},
	                {value:310, name:'邮件营销'},
	                {value:234, name:'联盟广告'},
	                {value:135, name:'视频广告'},
	                {value:1548, name:'搜索引擎'}
	            ],*/
	            itemStyle: {
	                emphasis: {
	                    shadowBlur: 10,
	                    shadowOffsetX: 0,
	                    shadowColor: 'rgba(0, 0, 0, 0.5)'
	                }
	            }
	            /*
	            */
	        }
	    ]
	}
	drawChart(data, option);
}

function viewChart22(data) {
	data = eval(data);
	var option = {
		backgroundColor: '#eeeeee',
		angleAxis: {},
        radiusAxis: {
            type: 'category',
            //data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
            z: 10
            , axisLabel: { //刻度标签设置
		　　　　margin: 0, //刻度与坐标轴之间的距离
		　　　　textStyle: {
		　　　　　　color: '#333'
		　　　　}
			,formatter:function(param) {
	                	var param0 = param;
	                	param = param.replace(/^.*? (.*)/, "$1");
	                	var len = 10;
						if (param.length > len) {
							param = param.substr(0, len - 1);
							param += "...";
						}
						param = param0.replace(/^(\d+\.).*/, "$1" + param);
						
	                	return param;
	                } 
		　　}
        },
	    dataset: {
	        // 提供一份数据。
	        source: data
	    },
           polar: {
           },
           tooltip: {
           	  formatter:function(params) {
	                	var color = params.color;//图例颜色
			            var htmlStr ='<div>';
			            htmlStr += params.name + '<br/>';//x轴的名称
			            
			            //为了保证和原来的效果一样，这里自己实现了一个点的效果
			            htmlStr += '<span style="margin-right:5px;display:inline-block;width:10px;height:10px;border-radius:5px;background-color:'+color+';"></span>';
			            
			            //添加一个汉字，这里你可以格式你的数字或者自定义文本内容
			            var t;
			            t = params.value[0];
			            t = t.replace(/(.{15})/g, "$1<br>\n");
			            htmlStr += params.seriesName + '：'+t;
			            
			            htmlStr += '</div>';
			            
			            return htmlStr;
	                } 
           },
           series: [{
               type: 'bar',
               //data: [1, 2, 4, 3, 6, 5, 7],
				seriesLayoutBy: 'row',
               coordinateSystem: 'polar',
               itemStyle: {
                   normal: {
                       color: '#00f'
                   }
               },
               barWidth: '50%'
           }]
       };
       drawChart(data, option, function (params) {
		    // 控制台打印数据的名称
		    console.log(params.name);
		});
}
function viewChart2(data) {
	data = eval(data);
	option = {
		backgroundColor: '#eeeeee',
		title: {
            text: '班级课程评分排行榜'
        },
	    legend: {		//图例组件
	    	show: false,
	    	selected:{
	    		 
	    	}
	    	, top: '30px'
	    },
	    toolbox: {
	        show: true,
	        feature: {
	            dataZoom: {
	                yAxisIndex: 'none'
	            },
	            dataView: {readOnly: false},
	            //magicType: {type: ['bar']},
	            restore: {},
	            saveAsImage: {}
	        }
	        , saveAsImage : {show: true,title :'保存为图片'}
	    },
	    tooltip: {trigger: 'axis'},
	    dataset: {
	        // 提供一份数据。
	        source: data
	    },
	    itemStyle: {
		    // 阴影的大小
		    shadowBlur: 200,
		    // 阴影水平方向上的偏移
		    shadowOffsetX: 0,
		    // 阴影垂直方向上的偏移
		    shadowOffsetY: 0,
		    // 阴影颜色
		    shadowColor: 'rgba(0, 0, 0, 0.5)'
		},
		grid:{//直角坐标系内绘图网格
            show:true,//是否显示直角坐标系网格。[ default: false ]
            left:"300px",//grid 组件离容器左侧的距离。
            right:"50px",
            borderColor:"#c45455",//网格的边框颜色
            bottom:"50px",
            top:"80px"
        },
        dataZoom: [
	        {   // 这个dataZoom组件，默认控制x轴。
	            type: 'slider', // 这个 dataZoom 组件是 slider 型 dataZoom 组件
	            start: 0,      // 左边在 10% 的位置。
	            end: 100         // 右边在 60% 的位置。
	            , orient: 'vertical'
	        }
	    ],
	    // 声明一个 X 轴，数值轴。
	    xAxis: {
		      type: 'value'
		    , axisLabel : {//坐标轴刻度标签的相关设置。
                interval:0
                //, rotate:"60"
            }
	    },
	    // 声明一个 Y 轴，类目轴（category）。默认情况下，类目轴对应到 dataset 第一列。
	    yAxis: [
	    	{name:'课程', type:"category"
	    	  	, inverse:true
			    , axisLabel : {//坐标轴刻度标签的相关设置。
	                formatter:function(param) {
	                	var index = -1;
	                	for (var x = 0; x < data[0].length; x++) {
	                		if (data[0][x] == param) {
	                			index = x;
	                			break;
	                		}
	                	}
	                	var param0 = param;
	                	param = param.replace(/^.*? (.*)/, "$1");
	                	var len = 20;
						if (param.length > len) {
							param = param.substr(0, len - 1);
							param += "...";
						}
						param = param0.replace(/^(\d+\.).*/, "$1" + param);
						param = data[2][index] + "." + param;
	                	return param;
	                }
                }
            }
	    ],
	    // 声明多个 bar 系列，默认情况下，每个系列会自动对应到 dataset 的每一列。
	    series: [
	          {
	        	  type: 'bar'
	        	, seriesLayoutBy: 'row'		//数据集中按行取数据
	        	//, encode: {x: 0, y: 1}
	        	, yAxisIndex: 0
	        	, itemStyle:{
                    normal: {
                        label: {
                            show: true,
                            position: 'insideRight',
                            textStyle:{
                            	color: "#000000"
                            }
                        }
                        , color:'#717afe'
                    }
                    
                }
                /*, encode: {
	                x: '排行榜',
	                y: '平均分'
	            }*/
	        }
	    ]
	}
	drawChart(data, option);
}
window.courseChart = null;
window.data = null;
function drawChart(data, option, ent) {
	window.data = data;
	var isInit = false;
	var h = 500;
	//if (data[0].length > 20)
	{
		h = 200 + data[0].length * 20;
	}
	var caseObj = document.getElementById('courseChartCase');
	if (courseChart == null) {
		if (caseObj == null) {
			var caseHtml = "<div id='courseChartCase' style='border:1px solid red;width:100%;height:" + h + "px;'></div>";
			$("#Page").append(caseHtml);
			caseObj = document.getElementById('courseChartCase');
			isInit = true;
		} else {
			//caseObj.style.height = h + "px";
		}
		courseChart = echarts.init(caseObj);
	}
	courseChart.clear();
	if (!isInit) {
		caseObj.style.height = h + "px";
		courseChart.resize();
	}
	if (typeof ent == "function") {
		courseChart.on("click", ent);
	}
	courseChart.setOption(option);
}
//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
