/**
 * ͳ��ͼ����
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
	        // �ṩһ�����ݡ�
	        source: data
	    },
	    itemStyle: {},
		grid:{//ֱ������ϵ�ڻ�ͼ����
            show:true,//�Ƿ���ʾֱ������ϵ����[ default: false ]
            left:"10%",//grid ������������ľ��롣
            right:"30px",
            borderColor:"#c45455",//����ı߿���ɫ
            bottom:"30px",
            top:"80px"
        },
	    // ����һ�� X �ᣬ��Ŀ�ᣨcategory����Ĭ������£���Ŀ���Ӧ�� dataset ��һ�С�
	    xAxis: {
		      type: 'category'
		    , axisLabel : {//������̶ȱ�ǩ��������á�
                interval:0
            }
	    },
	    // ����һ�� Y �ᣬ��ֵ�ᡣ
	    yAxis: [
	    	  {name:'', type:"value"}
	    ],
	    // ������� bar ϵ�У�Ĭ������£�ÿ��ϵ�л��Զ���Ӧ�� dataset ��ÿһ�С�
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
	        // �ṩһ�����ݡ�
	        source: data
	    },
		grid:{//ֱ������ϵ�ڻ�ͼ����
            show:true,//�Ƿ���ʾֱ������ϵ����[ default: false ]
            left:"250px",//grid ������������ľ��롣
            right:"50px",
            borderColor:"#c45455",//����ı߿���ɫ
            bottom:"50px",
            top:"80px"
        },
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
	    	{name:'', type:"category"
	    	  	, inverse:true
			    , axisLabel : {//������̶ȱ�ǩ��������á�
	                textStyle:{
                        fontSize:'13'
                    }
                }
            }
	    ],
	    // ������� bar ϵ�У�Ĭ������£�ÿ��ϵ�л��Զ���Ӧ�� dataset ��ÿһ�С�
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
	        //data: ['ֱ�ӷ���','�ʼ�Ӫ��','���˹��','��Ƶ���','��������']
	    },
	    dataset: {
	        // �ṩһ�����ݡ�
	        source: data
	    },
	    series : [
	        {
	            name: 'ָ��',
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
            left:"10%",//grid ������������ľ��롣
            right:"30px",
            borderColor:"#c45455",//����ı߿���ɫ
            bottom:"30px",
            top:"80px"
        },
	    // ����һ�� X �ᣬ��Ŀ�ᣨcategory����Ĭ������£���Ŀ���Ӧ�� dataset ��һ�С�
	    xAxis: {
		      type: 'category'
		    , axisLabel : {//������̶ȱ�ǩ��������á�
                interval:0
            }
	    },
	    // ����һ�� Y �ᣬ��ֵ�ᡣ
	    yAxis: [
	    	  {name:'ָ��', type:"value"}
	    ],
	    // ������� bar ϵ�У�Ĭ������£�ÿ��ϵ�л��Զ���Ӧ�� dataset ��ÿһ�С�
	    series: [
	          {
               name:'',
               type:'line',
	        	 seriesLayoutBy: 'row',
               itemStyle : {  /*����������ɫ*/
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
	        	var len = 6;
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
	drawChart(chartIndex, option, indexName);
}
/*��ͼ
 * 
 */
var geoCoordMap = {
    '�Ͼ�������˼��Ϣ�Ƽ����޹�˾':[119.215466, 32.235117],
    '�Ͼ���ͨ��Ϣ�������޹�˾':[118.781363, 32.219651],
    '�Ͼ��컪�а�ͨ�ż������޹�˾':[118.807971, 32.103824],
    '�Ͼ���ʯ������Ϣ�Ƽ����޹�˾':[118.920596, 32.051383]
};

var comData = [
   {name: '�Ͼ�������˼��Ϣ�Ƽ����޹�˾', value: 100},
   {name: '�Ͼ���ͨ��Ϣ�������޹�˾', value: 200},
   {name: '�Ͼ��컪�а�ͨ�ż������޹�˾', value: 80},
   {name: '�Ͼ���ʯ������Ϣ�Ƽ����޹�˾', value: 150}
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

/**��ȡ��ҵָ�����ݣ���ȡ��ҵ��ͼ����
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
				   name: 'ָ��',
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