/**
 * 统计图数组
 */
var charts = [];

function drawChart(chartIndex, option, title) {
	var indexChart = checkChart(chartIndex, title);
	indexChart.clear();
	indexChart.setOption(option);
}

function checkChart(chartIndex, title) {
	var height = 300;
//	if (chartIndex > 0) {
		height = 500;
//	}
	var id = "indexChart" + chartIndex;
	var oChart = document.getElementById(id);
	if (oChart == null) {
		var caseHtml = "";
		caseHtml += "<div id='" + id + "' style='width:100%;height:" + height + "px;"
			+ "border:1px solid gray;border-bottom:none;background-color:#ffffff;"	
			+ "'></div>";
		caseHtml += "<div id='" + id + "_bottom' style='width:100%;height:30px;"
			+ "border:1px solid gray;border-top:none;"
			+ "background-color:#eeeeee;text-align:center;font-size:12pt;margin-bottom:20px;'>"
			+ title + "</div>";
		var _statMap = document.getElementById("StatMap");
		_statMap.insertAdjacentHTML("beforeEnd", caseHtml);
		var indexChart = echarts.init(document.getElementById(id));
		charts.push(indexChart);
	}
	return charts[chartIndex];
}

function viewChart11(chartIndex, indexName, data) {
//	data = eval(data);
	option = {
		title: {
            text: indexName + ''
            , textStyle:{
            	fontSize:"14"
            }
        },
        backgroundColor:"#ffffff",
	    legend: {
	    	selected:{
	    		 
	    	}
	    	, top: '30px'
	    },
	    toolbox: {},
	    tooltip: {trigger: 'axis'},
	    dataset: {
	        // 提供一份数据。
	        source: data
	    },
	    itemStyle: {},
		grid:{//直角坐标系内绘图网格
            show:true,//是否显示直角坐标系网格。[ default: false ]
            left:"10%",//grid 组件离容器左侧的距离。
            right:"30px",
            borderColor:"#c45455",//网格的边框颜色
            bottom:"30px",
            top:"80px"
        },
	    // 声明一个 X 轴，类目轴（category）。默认情况下，类目轴对应到 dataset 第一列。
	    xAxis: {
		      type: 'category'
		    , axisLabel : {//坐标轴刻度标签的相关设置。
                interval:0
            }
	    },
	    // 声明一个 Y 轴，数值轴。
	    yAxis: [
	    	  {name:'', type:"value"}
	    ],
	    // 声明多个 bar 系列，默认情况下，每个系列会自动对应到 dataset 的每一列。
	    series: [
	          {type: 'bar'},{type:'bar'}, {type:'bar'}, {type:'bar'},{type:'bar'},{type:'bar'},{type:'bar'}
	    ]
	}
	drawChart(chartIndex, option, indexName);
}

function viewChart12(chartIndex, indexName, data) {
//	data = eval(data);
	option = {
		backgroundColor: '#ffffff',
		title: {
            text: indexName
            , textStyle:{
            	fontSize:"14"
            }
        },
	    tooltip: {trigger: 'axis'},
	    dataset: {
	        // 提供一份数据。
	        source: data
	    },
		grid:{//直角坐标系内绘图网格
            show:true,//是否显示直角坐标系网格。[ default: false ]
            left:"250px",//grid 组件离容器左侧的距离。
            right:"50px",
            borderColor:"#c45455",//网格的边框颜色
            bottom:"50px",
            top:"80px"
        },
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
	    	{name:'', type:"category"
	    	  	, inverse:true
			    , axisLabel : {//坐标轴刻度标签的相关设置。
	                textStyle:{
                        fontSize:'13'
                    }
                }
            }
	    ],
	    // 声明多个 bar 系列，默认情况下，每个系列会自动对应到 dataset 的每一列。
	    series: [
	          {
	        	  type: 'bar'
	        	, seriesLayoutBy: 'row'
	        	, yAxisIndex: 0
	        	, itemStyle:{
                    normal: {
                        label: {
                            show: true,
                            position: 'insideRight',
                        }
                        , color:'#717afe'
                    }
                    
                }
	        }


	    ]
	}

	drawChart(chartIndex, option, indexName);
}

function viewChart21(chartIndex, indexName, data) {
	data = eval(data);
	var option = {
		backgroundColor: '#ffffff',
		color:['#717afe','#fb964e','#c7c6c2','#fff200'],
	    aria: {
	        show: true
	    },
	    title : {
	        text: indexName,
	        subtext: '',
	        x:'center'
	            , textStyle:{
	            	fontSize:"14"
	            }
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
	            name: '指数',
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
	drawChart(chartIndex, option, indexName);
}

function viewChart22(chartIndex, indexName, data) {
	data = eval(data);
	option = {
		title: {
            text: indexName + ''
            , textStyle:{
            	fontSize:"14"
            }
        },
        backgroundColor:"#ffffff",
	    legend: {
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
            left:"10%",//grid 组件离容器左侧的距离。
            right:"30px",
            borderColor:"#c45455",//网格的边框颜色
            bottom:"30px",
            top:"80px"
        },
	    // 声明一个 X 轴，类目轴（category）。默认情况下，类目轴对应到 dataset 第一列。
	    xAxis: {
		      type: 'category'
		    , axisLabel : {//坐标轴刻度标签的相关设置。
                interval:0
            }
	    },
	    // 声明一个 Y 轴，数值轴。
	    yAxis: [
	    	  {name:'指数', type:"value"}
	    ],
	    // 声明多个 bar 系列，默认情况下，每个系列会自动对应到 dataset 的每一列。
	    series: [
	          {
               name:'',
               type:'line',
	        	 seriesLayoutBy: 'row',
               itemStyle : {  /*设置折线颜色*/
                   normal : {
                       color:'#fb964e'
                   }
               }
             }
	    ]
	}
	drawChart(chartIndex, option, indexName);
}

function viewChart3(chartIndex, indexName, data) {
	data = eval(data);
	var option = {
		backgroundColor: '#ffffff',
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
	        	var len = 6;
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
	drawChart(chartIndex, option, indexName);
}
/*地图
 * 
 */
var geoCoordMap = {
    '南京德塔博思信息科技有限公司':[119.215466, 32.235117],
    '南京御通信息技术有限公司':[118.781363, 32.219651],
    '南京天华中安通信技术有限公司':[118.807971, 32.103824],
    '南京安石格心信息科技有限公司':[118.920596, 32.051383]
};

var comData = [
   {name: '南京德塔博思信息科技有限公司', value: 100},
   {name: '南京御通信息技术有限公司', value: 200},
   {name: '南京天华中安通信技术有限公司', value: 80},
   {name: '南京安石格心信息科技有限公司', value: 150}
];
var convertData = function (data) {
   var res = [];
   for (var i = 0; i < data.length; i++) {
       var geoCoord = geoCoordMap[data[i].name];
       if (geoCoord) {
           res.push({
               name: data[i].name,
               value: geoCoord.concat(data[i].value)
           });
       }
   }
   return res;
};

/**获取企业指数数据，获取企业地图数据
 * 
 */
function viewChart4(chartIndex, indexName, data2) {
	//$.get('StatResult.jsp', {}, function(dataStr) {
		
	//});
	mapChart(chartIndex, indexName, data);
}
function mapChart(chartIndex, indexName, data) {
	//data = eval(data);
	$.get('./nanjing.json',function(geoJson){
		echarts.registerMap('qixiaqu',geoJson,{});
		var option = {
		    tooltip: {
		        trigger: 'item',
            	formatter: function(param) {
					var t = param.name + "<br />" + param.value[2] + "%";
					return t;
				}
		    },
		    visualMap: {
	            min: 50,
	            max: 200,
	            text:['High','Low'],
	            left: 'right',
	            realtime: false,
	            calculable: true,
	            inRange: {
	                color: ['#313695','#4575b4', '#74add1','#abd9e9','#e0f3f8']
	            }
	        },
			geo: {
			   show: true,
			   map: 'qixiaqu',
			   label: {
				 normal: {
				   show: true
				 },
				 emphasis: {
				   show: true
				 }
			   },
			   roam: true,
			   itemStyle: {
				 normal: {
				   areaColor: '#dddddd',
				   borderColor: '#3B5077'
				 },
				 emphasis: {
				   areaColor: '#dddddd'
				 }
			   },
			   zoom: 1.2
			 },
		    series: [
				{
				   name: '指数',
				   type: 'scatter',
				   coordinateSystem: 'geo',
				   data: convertData(comData),
				   symbolSize: function (val) {
					   return val[2] / 10;
				   },
				   label: {
					   normal: {
						   formatter: '{b}',
						   position: 'right',
						   show: false
					   },
					   emphasis: {
						   show: true
					   }
				   },
				   itemStyle: {
					   normal: {
						   color: '#ddb926'
					   }
				   }
				}
		    ]
		};
		drawChart(chartIndex, option, indexName);
	});
	
}