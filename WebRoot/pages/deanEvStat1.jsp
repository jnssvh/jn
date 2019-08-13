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
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
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
//@@##627:��������������(�鵵��ע��,����ɾ��)
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
	column[0] = "['�γ�'";
	column[1] = "['������'";
	column[2] = "['��������'";
	column[3] = "['ƽ����'";
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
				+ "<row><name>�γ�</name><data>CourseOrder.BeginTime TaskName</data></row>"
				+ "<row><name>���а�</name><data>UsedAverage</data></row>"
				+ "<row><name>ƽ����</name><data>CourseOrder</data></row>"
				+ "</map>";
	template = "�γ�,CourseOrder.BeginTime TaskName;���а�,UsedAverage;ƽ����,CourseOrder";
	template = "�γ�,TaskName;�Ͽ�ʱ��,BeginTime;�ڿ���,Teachers;���а�,CourseOrder;ƽ����,UsedAverage";
	template = "�γ�,TaskName;���а�,CourseOrder";
	template = "�γ�,TaskName;ƽ����,UsedAverage;���а�,CourseOrder";
	String data = set.getDataSetBySql(template, sql);
	//System.out.println(data);

	out.clear();
	out.println(data);
	out.flush();
	jdb.closeDBCon();
	return;
}
//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>�γ���������</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
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
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
//@@##624:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
	var o = book.setDocTop("������...", "Filter", "");
 	book.Filter = new TermClassFilter(o, {Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.Filter.onclickClass = ClickEVTask;
	book.setPageObj(book.Filter);
	
	
	
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##628:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function ClickEVTask(obj, item) {
	
	if (book.Page == undefined)
	{
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_EvaluateTask_deanEvStat1.jsp"
			, {formitemstyle:"font:normal normal normal 16px ΢���ź�", 
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
	        text: '�༶�γ����а�',
	        subtext: '�༶����',
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
	        //data: ['ֱ�ӷ���','�ʼ�Ӫ��','���˹��','��Ƶ���','��������']
	    },
	    dataset: {
	        // �ṩһ�����ݡ�
	        source: data
	    },
	    series : [
	        {
	            name: '���а�',
	            type: 'pie',
				seriesLayoutBy: 'row',
	            radius : '55%',
	            center: ['50%', '60%'],
	            /*data:[
	                {value:335, name:'ֱ�ӷ���'},
	                {value:310, name:'�ʼ�Ӫ��'},
	                {value:234, name:'���˹��'},
	                {value:135, name:'��Ƶ���'},
	                {value:1548, name:'��������'}
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
            //data: ['��һ', '�ܶ�', '����', '����', '����', '����', '����'],
            z: 10
            , axisLabel: { //�̶ȱ�ǩ����
		��������margin: 0, //�̶���������֮��ľ���
		��������textStyle: {
		������������color: '#333'
		��������}
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
		����}
        },
	    dataset: {
	        // �ṩһ�����ݡ�
	        source: data
	    },
           polar: {
           },
           tooltip: {
           	  formatter:function(params) {
	                	var color = params.color;//ͼ����ɫ
			            var htmlStr ='<div>';
			            htmlStr += params.name + '<br/>';//x�������
			            
			            //Ϊ�˱�֤��ԭ����Ч��һ���������Լ�ʵ����һ�����Ч��
			            htmlStr += '<span style="margin-right:5px;display:inline-block;width:10px;height:10px;border-radius:5px;background-color:'+color+';"></span>';
			            
			            //���һ�����֣���������Ը�ʽ������ֻ����Զ����ı�����
			            var t;
			            t = params.value[0];
			            t = t.replace(/(.{15})/g, "$1<br>\n");
			            htmlStr += params.seriesName + '��'+t;
			            
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
		    // ����̨��ӡ���ݵ�����
		    console.log(params.name);
		});
}
function viewChart2(data) {
	data = eval(data);
	option = {
		backgroundColor: '#eeeeee',
		title: {
            text: '�༶�γ��������а�'
        },
	    legend: {		//ͼ�����
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
	        , saveAsImage : {show: true,title :'����ΪͼƬ'}
	    },
	    tooltip: {trigger: 'axis'},
	    dataset: {
	        // �ṩһ�����ݡ�
	        source: data
	    },
	    itemStyle: {
		    // ��Ӱ�Ĵ�С
		    shadowBlur: 200,
		    // ��Ӱˮƽ�����ϵ�ƫ��
		    shadowOffsetX: 0,
		    // ��Ӱ��ֱ�����ϵ�ƫ��
		    shadowOffsetY: 0,
		    // ��Ӱ��ɫ
		    shadowColor: 'rgba(0, 0, 0, 0.5)'
		},
		grid:{//ֱ������ϵ�ڻ�ͼ����
            show:true,//�Ƿ���ʾֱ������ϵ����[ default: false ]
            left:"300px",//grid ������������ľ��롣
            right:"50px",
            borderColor:"#c45455",//����ı߿���ɫ
            bottom:"50px",
            top:"80px"
        },
        dataZoom: [
	        {   // ���dataZoom�����Ĭ�Ͽ���x�ᡣ
	            type: 'slider', // ��� dataZoom ����� slider �� dataZoom ���
	            start: 0,      // ����� 10% ��λ�á�
	            end: 100         // �ұ��� 60% ��λ�á�
	            , orient: 'vertical'
	        }
	    ],
	    // ����һ�� X �ᣬ��ֵ�ᡣ
	    xAxis: {
		      type: 'value'
		    , axisLabel : {//������̶ȱ�ǩ��������á�
                interval:0
                //, rotate:"60"
            }
	    },
	    // ����һ�� Y �ᣬ��Ŀ�ᣨcategory����Ĭ������£���Ŀ���Ӧ�� dataset ��һ�С�
	    yAxis: [
	    	{name:'�γ�', type:"category"
	    	  	, inverse:true
			    , axisLabel : {//������̶ȱ�ǩ��������á�
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
	    // ������� bar ϵ�У�Ĭ������£�ÿ��ϵ�л��Զ���Ӧ�� dataset ��ÿһ�С�
	    series: [
	          {
	        	  type: 'bar'
	        	, seriesLayoutBy: 'row'		//���ݼ��а���ȡ����
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
	                x: '���а�',
	                y: 'ƽ����'
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
//(�鵵��ע��,����ɾ��)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
