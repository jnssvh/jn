$.extend({jcom: {}});

$.jcom.getBrowser = function (u)		//����:��õ�ǰ�������Ϣ����
{//
 //u:������������Ϣ�ı�����Ϊ�գ���ȡֵnavigator.userAgent
 //����ֵ:���ض���
 //˵��:�μ�Դ����
	
	if (u == undefined)
		u = navigator.userAgent;
	return {     //�ƶ��ն�������汾��Ϣ
		trident: u.indexOf('Trident') > -1, //IE�ں�
		presto: u.indexOf('Presto') > -1, //opera�ں�
		webKit: u.indexOf('AppleWebKit') > -1, //ƻ�����ȸ��ں�
		gecko: u.indexOf('Gecko') > -1 && u.indexOf('KHTML') == -1, //����ں�
		mobile: !!u.match(/AppleWebKit.*Mobile.*/), //�Ƿ�Ϊ�ƶ��ն�
		ios: !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/), //ios�ն�
		android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1, //android�ն˻�uc�����
		iPhone: u.indexOf('iPhone') > -1, //�Ƿ�ΪiPhone����QQHD�����
		iPad: u.indexOf('iPad') > -1, //�Ƿ�iPad
		webApp: u.indexOf('Safari') == -1 //�Ƿ�webӦ�ó���û��ͷ����ײ�
	};
};

$.jcom.initObjVal = function(objf, obj)	//����:��ʼ������ //ȡ�� FormatObjvalue in psub.jsp
{//
	 //objf:��ʽ���ľ���Ĭ��ֵ�Ķ���
	 //obj:����Ķ���
	 //����ֵ:���ض���
	 //˵��:�μ�Դ����

	if (typeof obj != "object")
		return objf;
	for (var key in objf)
	{
		if (typeof obj[key] == "undefined")
			obj[key] = objf[key];
	}
	return obj;
};

$.jcom.findParentObj = function(oStart, oEnd, tagName)	//����:Ѱ��DOM������	//��DOM������Ѱ�����������ĸ�����
{//
	//oStart:��ʼ����
	//oEnd:��������
	//tagName:��Ҫ���ҵĶ����tagName
	//����ֵ:�鵽�Ķ��󣬻�undefined
	//˵��:�μ�Դ����
	for (var obj = oStart; obj != oEnd; obj = obj.parentNode)
	{
		if (obj == null)
			return;
		if (obj.tagName == tagName)
			return obj;
	}
};

$.jcom.toJSONStr = function(val)	//����:���������л�ΪJSON�ı�
{//
	//val:����
	//����ֵ:���л�����ı�
	//˵��:�μ�Դ����

	switch (typeof val)
	{
	case "string":
		return "\"" + val.replace(/[\r\n]+/g, "").replace(/"/g, "\\\"") + "\"";
	case "object":
		if (Object.prototype.toString.apply(val) == "[object Array]")
		{
			var s = "[", p1 = "";
			for (var x = 0; x < val.length; x++)
			{
				s += p1 + $.jcom.toJSONStr(val[x]);
				p1 = ",";
			}
			return s + "]";
		}
		var s = "{", p1 = "";
		for (var key in val)
		{
			if ((typeof val[key] != "string") || (val[key] != ""))
			{
				s += p1 + key + ":" + $.jcom.toJSONStr(val[key]);
				p1 = ",";
			}
		}
		return s + "}";
	case "number":
	case "boolean":
	default:
		return val;
	}
};

$.jcom.getStyleObjFromString = function(style)	//����: ���ı�styleת���ɶ���
{
	var o = {};
	var items = style.split(";");
	for (var x = 0; x < items.length; x++)
	{
		var ss = items[x].split(":");
		var s = ss[0].split("-");
		if (s.length == 2)
			key = s[0].toLowerCase() + s[1].substr(0, 1).toUpperCase() + s[1].substr(1).toLowerCase();
		else
			key = s[0].toLowerCase();
		o[key] = ss[1];
	}
	return o;
};

$.jcom.getObjPos = function(obj, p)		//����: �õ�DOM�����λ��
{
	var to = {left:0, top:0, right:0, bottom:0, width:obj.offsetWidth, height:obj.offsetHeight};
	if (typeof(p) == "undefined")
		p = obj.ownerDocument.body;
	while (obj != p)
	{
		to.left += obj.offsetLeft - obj.scrollLeft;
		to.top += obj.offsetTop - obj.scrollTop;
		to.p = obj.style.position;
		obj = obj.offsetParent;
		if (obj == null)
			break;
		if ((typeof(p) == "string") && (obj.tagName.toUpperCase() == p.toUpperCase()))
			break;
	}
	to.right = to.left + to.width;
	to.bottom = to.top + to.height;
	return to;
};

$.jcom.makeDateObj = function(value)	//����:����ת��	//ȡ��GetDate in psub.jsp
{
	var s = $.trim(value).split(" ");
	var d = s[0].split("-");
	switch (s.length)
	{
	case 1:
		if (d.length == 1)
		{
			d = s[0].split(".");	//�����������Ƿ�����.���ָ�
			if (d.length == 1)
			{
				d = s[0].split("/");
				if (d.length == 1)
				{
					d = s[0].split("��");
					if (isNaN(d[0]))
						return null;
					if (d.length == 2)
					{
						var dd = d[1].split("��");
						return new Date(d[0], parseInt(dd[0]) - 1, parseInt(dd[1]));
					}
					return new Date(d[0], 0, 1);
				}
			}
		}
		if (d[0].length == 2)
			d[0] = "20" + d[0];
		if (d.length == 2)
			return new Date(d[0], d[1] - 1, 1);
		return new Date(d[0], d[1] - 1, d[2]);
	case 2:
		var t = s[1].split(":");
		if (t.length < 2)
			t = s[1].split("��");
		switch (t.length)
		{
		case 1:
			return new Date(d[0], d[1] - 1, d[2]);
		case 2:			
			return new Date(d[0], d[1] - 1, d[2], t[0], t[1]);
		case 3:
			return new Date(d[0], d[1] - 1, d[2], t[0], t[1], t[2]);
		}
	default:
		return null;
	}
};

$.jcom.GetDateTimeString = function(t, fmt) //����:���ڸ�ʽ����� //fmt ��ƽ̨˳���Ӧ������ԭpsub.js����Ӧ�ˡ�
{
	if (typeof t == "string")
	{
		if ($.trim(t) == "")
			return "";
		t = $.jcom.makeDateObj(t);
		if (t == null)
			return "";
	}
	if ((isNaN(t)) ||(t == null))
		return "";
	switch (fmt)
	{
	case 1:		//2008-3-15
		return t.getFullYear() + "-" + (t.getMonth() + 1) + "-" + t.getDate();
	case 2:		//2008-03-15 09:18:05
		return t.getFullYear() + "-" + $.jcom.LStrFill((t.getMonth() + 1), 2, "0") + "-" + $.jcom.LStrFill(t.getDate(), 2, "0") + " " +
			$.jcom.LStrFill(t.getHours(), 2, "0") + ":" + $.jcom.LStrFill(t.getMinutes(), 2, "0") + ":" + $.jcom.LStrFill(t.getSeconds(), 2, "0");
	case 3:		//2008-03-15 09:18
		return t.getFullYear() + "-" + $.jcom.LStrFill((t.getMonth() + 1), 2, "0") + "-" + $.jcom.LStrFill(t.getDate(), 2, "0") + " " +
			$.jcom.LStrFill(t.getHours(), 2, "0") + ":" + $.jcom.LStrFill(t.getMinutes(), 2, "0");
	case 4:		//9:18
		return t.getHours() + ":" + $.jcom.LStrFill(t.getMinutes(), 2, "0");
	case 5:		//2015-11
		return t.getFullYear() + "-" + (t.getMonth() + 1);
	case 6:		//9:18:5
		return t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
	case 7:		//2008-03-15
		return t.getFullYear() + "-" + $.jcom.LStrFill((t.getMonth() + 1), 2, "0") + "-" + $.jcom.LStrFill(t.getDate(), 2, "0");
	case 8:		//09:18:05
		return $.jcom.LStrFill(t.getHours(), 2, "0") + ":" + $.jcom.LStrFill(t.getMinutes(), 2, "0") + ":" + $.jcom.LStrFill(t.getSeconds(), 2, "0");
	case 9:		//3-15 9:18:5
		return (t.getMonth() + 1)+ "-" + t.getDate() + " " + t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
	case 10:		//3-15
		return (t.getMonth() + 1) + "-" + t.getDate();
	case 11:	//2011
		return t.getFullYear();
	case 12:	//2008��3��15��
		return t.getFullYear() + "��" + (t.getMonth() + 1) + "��" + t.getDate() + "��";
	case 13:	//3��15��
		return (t.getMonth() + 1) + "��" + t.getDate() + "��";
	case 14:	//09:18
		return $.jcom.LStrFill(t.getHours(), 2, "0") + ":" + $.jcom.LStrFill(t.getMinutes(), 2, "0");
	case 16:	//2018.1.30
		return t.getFullYear() + "." + (t.getMonth() + 1) + "." + t.getDate();
	case 17:	//1.30
		return (t.getMonth() + 1) + "." + t.getDate();		
	case 15:
	default:	//2008-3-15 9:18:5
		return t.getFullYear() + "-" + (t.getMonth() + 1) + "-" + t.getDate() + " " +
			t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
	}
};

$.jcom.getCWeekDay = function (d)		//����:��ȡ��������
{
	var weekdays = "��һ����������";
	return weekdays.substr(d.getDay(), 1);
};

$.jcom.LStrFill = function(n, length, ch)	//����:������ֿ�λ//�ø����ַ����������ߵĿ�λ���õ�ָ�����ȵ��ַ���
{
	
	var value = n;
	for (var x = 0; x < length; x++)
	{
		value = ch + value;
	}
	return value.substr(value.length - length);
}


$.jcom.GetRootPath = function()		//����:��ø�·��//�õ���ǰվ��ĸ�·��
{
	var s = document.getElementsByTagName("SCRIPT");
	var path = ""
	for (var x = 0; x < s.length; x++)
	{
		if (new RegExp("jcom.js$", "i").test(s[x].src))
		{
			path = s[x].src.substr(0, s[x].src.length - 7);
			if (path.substr(0, 7) == "http://")
				return path.substr(0, path.length - 5);
			break;
		}
	}
	var href = location.protocol + "//" + location.hostname + "/";
	if (location.port != "")
		href = location.protocol + "//" + location.hostname + ":" + location.port + "/";
	var ss = location.pathname.split("/");
	if (path.substr(0, 3) == "../")
		href += ss[ss.length - 3];
	else 
		href += ss[ss.length - 2];
	return href;
}

$.jcom.eval = function(data)	//����:���ı�ת��ΪJSON����//������JSON����
{
	try
	{
		data = data.replace("\r\n", "");
		var list = eval("(" + data + ")");
	}
	catch (e)
	{
		return e.description + "\n" + data;
	}
	return list;	
}

$.jcom.getDataCount = function (item)	//����:��������ĺ�//�������е��������������
{
	if (typeof item.length != "number")
	{
		if (typeof item.child == "object")
			return $.jcom.getDataCount(item.child) + 1;
		return 1;
	}
	var cnt = 0;
	for (var x = 0; x < item.length; x++)
	{
		if (typeof item[x].child == "object")
			cnt += $.jcom.getDataCount(item[x].child);
	}
	return cnt + item.length;
};

$.jcom.DataClearEmptyChild = function (items)	//����:���Ϊ�յ�child�ڵ�
{
	for (var x = 0; x < items.length; x++)
	{
		if (typeof items[x].child == "object")
		{
			if (items[x].child.length == 0)
				delete items[x].child;
			else
				$.jcom.DataClearEmptyChild(items[x].child);
		}
	}
};

$.jcom.Ajax = function(page, mode, postdata, fun)	//����:�Զ����Ajax
{
	var http_request = null;
	try {
		http_request = new ActiveXObject("Microsoft.XMLHTTP");
	} catch (e) {
		http_request = new XMLHttpRequest();
	}
	if (typeof(mode) == "undefined")
		mode = true;
	if (mode)
	{
		http_request.onreadystatechange = function()
		{
			if (http_request.readyState == 4)
			{
				if (typeof(fun) == "function")
					fun(http_request.responseText);
				if (typeof(fun) == "string")
					eval(fun);
				http_request = null;
			}
		};
	}

	if (typeof postdata == "object")
	{
		var pd = "", b = "";
		for (var key in postdata)
		{
			pd += b + key + "=" + encodeURIComponent(postdata[key]);
			b = "&";
		}
		postdata = pd;
	}
	
	if ((typeof(postdata) != "string") || (postdata == ""))
	{
		http_request.open("GET", page, mode);
		http_request.setRequestHeader("If-Modified-Since","0");
		var result = http_request.send();
	}
	else
	{
		http_request.open("POST", page, mode);
//		http_request.setRequestHeader("content-length",postdata.length); 
		http_request.setRequestHeader("content-type","application/x-www-form-urlencoded;charset=utf-8"); 
		var result = http_request.send(postdata);
	}
	if (mode)
		return result;
	return http_request.responseText;
};

$.jcom.submit = function (action, obj, cfg)		//����:�������صı������ύ
{
	cfg = $.jcom.initObjVal({target:"SaveFormFrame", fnReady:0, File:"",fValid:undefined, method:"post", wincfg:undefined}, cfg);
	if (typeof $("#SaveFormFrame")[0] == "object")
		$("#SaveFormFrame").remove();
	var text = "", win;
	if (typeof obj == "object")
	{
		if ($.isArray(obj))
		{
			for (var x = 0; x < obj.length; x++)
			{
				for (var key in obj[x])
					text += "<textarea name=" + key + ">" + obj[x][key] + "</textarea>";
			}
		}
		else
		{
			for (var key in obj)
				text += "<textarea name=" + key + ">" + obj[key] + "</textarea>";
		}
		if (action == "#getObjTag")
			return text;
	}
	else
		text = obj;
	var enctype = "";
	if (cfg.File != "")
	{
		text += "<input name=" + cfg.File + " type=file>";
		enctype = "enctype=multipart/form-data ";
	}
	
	if (cfg.target == "SaveFormFrame")
	{
		if (typeof cfg.fnReady == "function")
		{
			$("iframe[name='SaveFormFrame']").remove();
			document.body.insertAdjacentHTML("beforeEnd", "<iframe id=SaveFormFrame name=SaveFormFrame style=display:none></iframe>");
			$("#SaveFormFrame")[0].onload = function ()	//onreadystatechange�ڷǼ���ģʽ��ʧЧ������onload
			{
				var win = $("#SaveFormFrame")[0].contentWindow;
				if (win.location.href == "about:blank")
					return;
				if (win.document.readyState != "complete")
					return;
				cfg.fnReady(win.document.body.innerHTML);
			}
		}
		else
		{
			cfg.wincfg = $.jcom.initObjVal({title:"�����ϴ�", width:320, height:200, position:"fixed",mask:50}, cfg.wincfg);
			win = $.jcom.PopupWin("<iframe id=SaveFormFrame name=SaveFormFrame frameBorder=0 style=width:100%;height:100%;></iframe>", cfg.wincfg);
		}
	}
	$("#SaveFormDiv").remove();
	document.body.insertAdjacentHTML("beforeEnd", "<div id=SaveFormDiv style=display:none></div>");
	$("#SaveFormDiv").html("<form id=SaveForm " + enctype + "method=" + cfg.method + " action=" + action + " target=" + cfg.target + ">" + text + "</form>");
	if (cfg.File != "")
	{
		var o = $("input[name='" + cfg.File + "']")[0];
		o.onchange = function ()
		{
			if (o.value != "")
			{
				var b = true;
				if (typeof cfg.fValid == "function")
					b = cfg.fValid(o.value);
				if (b)
					document.getElementById("SaveForm").submit();
			}
			o.onchange = null;
		}
		o.click();		
	}
	else
		document.getElementById("SaveForm").submit();
	return win;
};

$.jcom.getChineseNumber = function(x)		//����:�����ַ��������
{
	var c = "��һ�����������߰˾�ʮ";
	if (x <= 10)
		return c.substr(x, 1);
	if ((x > 10) && (x < 20))
		return "ʮ" + c.substr(x % 10, 1);
	if ((x >= 20) && (x < 100))
	{
		if ((x % 10) == 0)
			return c.substr(parseInt(x / 10), 1) + "ʮ";
		return c.substr(parseInt(x / 10), 1) + "ʮ" + c.substr(x % 10, 1);
	}
	return x;//99���ϲ�����
};

$.jcom.inObjArray = function(fields, key, value, flag)		//����:��ȡ�ֶζ������ݵ�����//, flag=1,ͬʱ���ӽڵ����ң������ؽڵ����
{
	for (var x = 0; x < fields.length; x++)
	{
		if (fields[x][key] == value)
		{
			if (flag == 1)
				return fields[x];
			return x;
		}
		if ((flag == 1) && (typeof fields[x].child == "object"))
		{
			var v = $.jcom.inObjArray(fields[x].child, key, value, flag);
			if (v != -1)
				return v;
		}
	}
	return -1;
};

$.jcom.OptionWin = function (info, title, options, cfg)			//����:����ѡ���ѡ��Ի���
{
	if ((title == undefined) && (options == undefined) && (cfg == undefined))
	{
		var box = new $.jcom.PopupBox(info);
		box.show();
		return box;
	}
	if (title == undefined)
		title = "ϵͳ��ʾ";
	cfg = $.jcom.initObjVal({title:title, resize:0, mask:30,height:0}, cfg);

	if (options == undefined)
		options = [{item:"ȷ��", action:null}];
	var tag = "<div id=OptionWinInfoDiv style=padding:8px;>" + info + "</div><table width=100%><tr>";
	for (var x = 0; x < options.length; x++)
	{
		tag += "<td align=center><input type=button value=" + options[x].item + "></td>";
	}
	var win = new $.jcom.PopupWin(tag + "</tr></table>", cfg);
	if ((cfg.width == 0) || (cfg.height == 0))
	{
		var pos = $.jcom.getObjPos($("#OptionWinInfoDiv")[0]);
		win.show(-1, -1, pos.right - pos.left + 10, pos.bottom - pos.top + 60);
	}
	var fun = function (e)
	{
		var x = $.jcom.inObjArray(options, "item", e.target.value);
		if (x >= 0)
		{
			if (options[x].action == null)
				win.close();
			else if (typeof options[x].action == "function")
				options[x].action(e.target, win);
			else
				eval(options[x].action);
		};
	};
	var o = win.getbox().getdomobj();
	$(":button", o).on("click", fun);
	return win;
};

$.jcom.getItemImg = function(img, style, tag, prop, lrstr)			//����:�õ�ͼʾ���ַ���ͼʾ
{
	if ((img == "") || (img== undefined))
		return "";
	if ((typeof style != "string") || (style == ""))
		style = "font-size:20px;color:gray;";
	if ((typeof tag != "string") || (tag == ""))
		tag = "span";
	if ((typeof prop != "string") || (prop == ""))
		prop = "";
	else
		prop += " ";
	if (lrstr == undefined)
		lrstr = "";
	switch (img.substr(0, 1))
	{
	case "<":
		return img;
	case "#":
		var s = "";
		var v = parseInt(img.substr(1) / 256);
		if (v == 224)
			s = "font-family:sfont;";
		else if ((v > 229) && (v < 236))
			s = "font-family:iconfont;";
		return lrstr + "<" + tag + " " + prop + "style='" + s + style + "'>&" + img + "</" + tag + ">" + lrstr;
	default:
		return img = lrstr + "<img " + prop + "src='" + img + "' style='" + style + "'>" + lrstr;
	}
}

$.jcom.Base = function (domobj, data, cfg)			//��:����
{//�⽫������Ϊ������Ļ���,����δʵ��
	var self = this;

	this.config = function (cfg)	//����:����
	{
	}
	
	this.reload = function (data)	//����:���¼���
	{
	};
	
	this.setdomobj = function(obj)	//����:��������dom����
	{
	};
}

$.jcom.MDIWindows = function(oContainer, cfg)	//��:���ĵ�����// 
{//����ʵ�ִ���ǩ�Ķ��ĵ�
//oContainer:���������DOM����
//cfg:��ѡ��������Ϣ,�����У�css-���ĵ�������ʽ����-MDI, fnClose-�ر��¼�-this.onClose closeButton-���ĵ���ǩ�Ƿ���رհ�ť-0��
//˵��:
	var mdibar, divbar, divdoc, morebutton;
	var self = this;
	
	this.Create = function(url, title, nNewDoc, windef) //����:�����ĵ�
	{//
	 //url:��Ҫ�����ĵ���URL�����Ѿ�������DOM����
	 //title:�ĵ����⣬��Ϊ�գ���ʹ���ĵ�����
	 //nNewDoc:�Ƿ�ǿ�ƴ����ĵ�����1ʱ�����ĵ���ͬ�����л���
	//windef:����
	//����ֵ:�������ĵ��Ķ���
	//˵��:
		if ((typeof(nNewDoc) == "undefined") || (nNewDoc != 1))
		{
			var bar = mdibar.getmenu();
			for (var x = 0; x < bar.length; x++)
			{
				var o = document.getElementById(bar[x].data);
				if ((o != null) && ((o == url) || (o.src == url)))
					return mdibar.run(x);
			}
		}

		if ((typeof(title) == "undefined") || (title == ""))
			title = "��������...";

		windef = $.jcom.initObjVal({dblclick:ClosePage}, windef);
		var bar = mdibar.getmenu();
		var item = {item:title, className:cfg.css + "_Page", type:2, action:ClickPage, dblclick:windef.dblclick,zorder:bar.length + 1};

		var oPage;
		if (typeof url == "object")
			oPage = $(url);
		else
		{
			if (url.substr(0, 1) == "<")
				oPage = $(url);
			else
			{
				oPage = $("<iframe noresize scrolling=no frameborder=0 src=" + url + "></iframe");
				var index = bar.length;
				var iframeok = function ()
				{
					if (title == "��������...")
					{
						try {
							mdibar.setmenutext(index, event.srcElement.contentWindow.document.title);
						} catch (e) {
						mdibar.setmenutext(index, "�Ѽ���");
						}
					}
					self.pageready(bar[x]);
				}
				oPage.on("load", iframeok);
			}
		}
		mdibar.append(item);
		item.data = oPage[0];//oPage[0].uniqueID;
		mdibar.run(item);
		$(divdoc).prepend(oPage);
		oPage.width("100%");
		oPage.height("100%");
//		oPage.width($(divdoc).width());
//		oPage.height($(divdoc).height());
		SetPropPageScroll();
		return item;
	}

	
	this.pageready = function(item)	//�¼�:��ҳ���iframe�������ʱ����
	{//item:��ǰ�ĵ�
	};
	
	this.ShowBar = function(nShow)	//����:��ʾ�ĵ���ǩ
	{//nShow:1��ʾ��0����
		if (nShow == 1)
		{
			divbar.style.display = "block";
			divdoc.style.margin = "";
			divdoc.style.padding = "";
		}
		else
		{
			divbar.style.display = "none";
			divdoc.style.margin = "0px";
			divdoc.style.padding = "0px";
		}
		
	};
	
	function ActPage(obj, item)
	{
		self.ActivePage(item.data);
	}

	this.ActivePage = function(item)	//����:����ָ���ĵ�
	{
		mdibar.run(item);
		SetPropPageScroll();
	};
	
	this.onactive = function(item)	//�¼�:�л�ҳ��ʱ����
	{
	};
	
	this.GetActivePage = function(nType)	//����:��ȡ��ǰ��ĵ�
	{
		var bardef = mdibar.getmenu();
		for (var x = 0; x < bardef.length; x++)
		{
			if (bardef[x].status == 1)
			{
				switch (nType)
				{
				case 1:			//����
					return bardef[x].item;
				case 2:			//iframe object
					return bardef[x].data;
				case 3:
					return bardef[x];
				default:
					return x;
				}
			}
		}
	};

	this.setPage = function (page, src)	//����:����ҳ���ĵ���URL
	{
	//page:
	//src:
		var bardef = mdibar.getmenu();
		for (var x = 0; x < bardef.length; x++)
		{
			if ((bardef[x].item == page) || (x == page) || (bardef[x] == page))
			{
				bardef[x].data.src = src;
				break;
			}	
		}
		
	};

	function ClickPage(obj, item)
	{
		var bar = mdibar.getmenu();
		var active;
		for (var x = 0; x < bar.length; x++)
		{
			var page = bar[x].data;
			if (bar[x] == item)
			{
				page.style.display = "block";
				self.onactive(item);
				active = x;
			}
			else
			{
				page.style.display = "none";
			}
		}
		for (var x = 0; x < bar.length; x++)
		{
			if (bar[x].zorder > bar[active].zorder)
				bar[x].zorder --;
		}
		bar[active].zorder = bar.length;
	};

	function SetPropPageScroll()
	{
	var x, cnt = 0;
		$(divdoc).height($(oContainer).innerHeight() - $(divbar).outerHeight());
		var bar = mdibar.getmenu();
		if (bar.length == 0)
		{
			oContainer.firstChild.style.display = "none";
			return;
		}
		oContainer.firstChild.style.display = "block";

		if (oContainer.clientWidth == 0)
			return;
		if (bar.length * 71 < oContainer.clientWidth - 60)
		{
			if (morebutton != undefined)
			{
				$(morebutton).remove();
				for (var x = 0; x < bar.length; x++)
					mdibar.showItem(x, true);
				morebutton = undefined;
			}
			return;
		}
		if (morebutton == undefined)
		{
			$(mdibar).prepend("<span id=MoreButton style=font-family:webdings;padding-left:4px;>4</span>");
			morebutton = $(mdibar).find("#MoreButton")[0];
			$(morebutton).mousedown(ShowMorePage);
		}

		var nPos = self.GetActivePage(4);
		var pages = parseInt((oContainer.clientWidth - 60) / 71);
		for (x = nPos; x >= 0; x--)
		{
			if (cnt < pages)
			{
				cnt ++;
				mdibar.showItem(x, true);
			}
			else
				mdibar.showItem(x, false);
		}
		for (x = nPos + 1; x < bar.length; x++)
		{
			if (cnt < pages)
			{
				cnt ++;
				mdibar.showItem(x, true);
			}
			else
				mdibar.showItem(x, false);
		}
	};
	
	function ShowMorePage()
	{
		var bar = mdibar.getmenu();
		var nPos = self.GetActivePage(4);
		var menudef = [];
		for (var x = 0; x < bar.length; x++)
		{
			menudef[x] = {};
			if (mdibar.showItem(x) == true)
				menudef[x].style = "color:gray";
			if (x == nPos)
				menudef[x].img = "<span style='color:red;font:18px webdings'>a</span>";
			menudef[x].item = bar[x].item;
			menudef[x].data = x;
			menudef[x].action = ActPage;
		}
		menudef[bar.length] = {};
		menudef[bar.length + 1] = {item:"�ر�ȫ������(����:" + (bar.length - 1) + ")", 
			img: "<span style=color:red;font-family:webdings;>r</span>", action:self.closeAll};
		var menu = new $.jcom.CommonMenu(menudef);
		menu.show();
		return false;
	};
	
	this.closeAll = function()	//����:�ر������ĵ�
	{
		if (window.confirm("�Ƿ�ر�ȫ�����ڣ�") == false)
			return;
		var bar = mdibar.getmenu();
		for (var x = bar.length - 1; x >= 0; x--)
			self.Close(bar[x]);
	};


	this.Close = function(item)	//����:�ر��ĵ�
	{//item:
	//
		var menuitem = mdibar.getmenu(item);
		if (typeof menuitem != "object")
			return;
		var frm = document.getElementById(menuitem.data);
		try
		{
			if (frm.contentWindow.document.body.onbeforeunload != null)
			{
				if (window.confirm("���ĵ��������Ѿ��ı䣬��δ���棬�Ƿ���Ҫ�����˳���") == false)
					return;
			}
		}
		catch (e)
		{
		}
		$(frm).remove(true);
		var o = mdibar.remove(item);
		SetPropPageScroll();
		cfg.fnClose(mdibar, o[0]);
		var bar = mdibar.getmenu();
		for (var x = 0; x < bar.length; x++)
		{
			if (bar[x].zorder == bar.length)
				return mdibar.run(x);
		}
		mdibar.run(0);
	};	

	this.onClose = function(mdibar, obj)	//�¼�:�ĵ��ر�ʱ����
	{
	};

	function ClosePage(obj, item)
	{
		if (typeof obj == "undefined")
			self.Close(self.GetActivePage(4));
		else
			self.Close(parseInt($(obj).attr("node")));
	}

	function InitMDIWin()
	{
		cfg = $.jcom.initObjVal({css:"MDI", fnClose:self.onClose, closeButton:0, barpos:1}, cfg);
		switch (cfg.barpos)
		{
		case 1:		//��ǩ��ҳ���ϲ�
			$(oContainer).prepend("<div style='width:100%;height:100%;overflow:hidden;display:none'>" +
				"<div id=MDIBar class=" + cfg.css + "_Bar></div><div id=MDIPage style='width:100%;overflow:auto;'></div></div>");
			break;
		case 3:		//��ǩ��ҳ���²�
			$(oContainer).prepend("<div style='width:100%;height:100%;overflow:hidden;display:none'>" +
				"<div id=MDIPage style='width:100%;overflow:auto;'></div><div id=MDIBar class=" + cfg.css + "_Bar></div></div>");
			break;
		}
		var button = "";
		if (cfg.closeButton == 1)
			button = "<span id=CloseWinButton style=font-family:webdings;>r</span>";
		divbar = $(oContainer).find("#MDIBar")[0];
		mdibar = new $.jcom.CommonMenubar([], divbar, {className:cfg.css + "_Container", title:button});
		divdoc = $(oContainer).find("#MDIPage")[0];
		$(oContainer).on("resize", SetPropPageScroll);
		$(window).on("resize", SetPropPageScroll);

		if (cfg.closeButton == 1)
			divbar.all.CloseWinButton.onclick = ClosePage;
	}
	if (typeof oContainer == "object")
		InitMDIWin();	
};



$.jcom.Split = function(obj1, obj2, cfg)	//��:�ָ���
{//������DOM����֮����Ϸָ���,��ʵ�ֺ��������ı������ߴ�.���ڶ�������obj2ʡ��,��obj2Ϊ��һ����������һ������.
//obj1:
//obj2:
//cfg:
	var obj, button, hv = 0, delta = 0;
	var self = this;
	
	function onsize()
	{
		if (document.onmouseup == null)
		{
			var pos = $.jcom.getObjPos(obj1);
			if (hv == 1)
				obj.style.left = pos.right + 3;
			else
				obj.style.top = pos.bottom + 3;
		}
		obj.style.display = obj2.style.display;
	}

	this.refresh = function ()	//����:ˢ��
	{
		if (obj.style.display == "none")
			return;
		var pos = $.jcom.getObjPos(obj1, obj.offsetParent);
		if (hv == 1)
		{
			obj.style.left = pos.right;
//			obj.style.height = obj1.style.height;
			obj.style.pixelHeight = obj1.offsetHeight;
			obj.style.top = pos.top;
		}
		else
		{
			obj.style.left = pos.left;
//			obj.style.width = obj1.style.width;
			obj.style.width = obj1.offsetWidth;
			obj.style.top = pos.bottom;
		}
	};

	this.show = function (nShow)	//����:��ʾ
	{
		switch (nShow)
		{
		case 0:
			obj.style.display = "none";
			break;
		case 1:
			obj.style.display = "block";
			break;
		}
	};
	this.setPos = function (pos)	//����:����λ��
	{
		if (pos <= 0)
			return ClickButton();
		if (hv == 1)
			$(obj).css("left", pos + "px");
		else
			$(obj).css("top", pos + "px");
		EndSplit();
	};
	
	this.onsplit = function (left, top, split)	//�¼�:�ָ���ɺ����
	{};
		
	function Create()
	{
		var p1 = $.jcom.getObjPos(obj1);
		var p2 = $.jcom.getObjPos(obj2);
		if (p1.top == p2.top)
		{
			hv = 1;
			$(obj1).after("<div style='height:24px;width:16px;font-family:webdings;font-size:16px;filter:alpha(opacity=70);'>3</div>");
			$(obj1).after("<div style='width:8px;height:" + (p1.bottom - p1.top) + "px;cursor:col-resize;margin-left:-3px;'></div>");
		}
		else if (p1.left == p2.left)
		{
			hv = 0;
			$(obj1).after("<div style='height:16px;width:16px;font-family:webdings;font-size:16px;filter:alpha(opacity=70);'>5</div>");
			$(obj1).after("<div style='height:8px;overflow:hidden;cursor:row-resize;margin-top:-3px;'></div>");
		}
		obj = obj1.nextSibling;
		button = obj.nextSibling;
		$(button).css({position:"absolute", overflow:"hidden",cursor:"hand", display:"none"});
		$(obj).css({position:"absolute", overflow:"hidden", backgroundColor:"gray", opacity:0.00, filter:"alpha(opacity=0)"});
		$(obj).mouseover(overSplit);
		$(button).mouseout(OutButton);
		$(obj).mouseout(OutSplit);
		$(button).click(ClickButton);
		$(obj).mousedown(BeginSplit);
//		if (obj1.parentNode.tagName == "BODY")
//			obj1.attachEvent("onresize", onsize);
	}

	function overSplit()
	{
		if (obj.onmousemove != null)
			return;
		var pos = $.jcom.getObjPos(obj2, obj.offsetParent);
		if (hv == 1)
		{
			button.style.top = pos.top + parseInt((pos.bottom - pos.top) / 2) - 12;
			if (obj1.style.display != "none")
				button.style.left = pos.left - 9;
		}
		else
		{
			button.style.left = pos.left + parseInt((pos.right - pos.left) / 2) - 12;
			if (obj1.style.display != "none")
				button.style.top = pos.top - 15;
			else
				button.style.top = pos.top - 10;
		}
		if (cfg.nStyle == 1)
			button.style.display = "block";
	};

	function OutButton()
	{
//		if (event.toElement != obj)
//			button.style.display = "none";
	}
	
	function OutSplit(event)
	{
		if (event.toElement != button)
			button.style.display = "none";
	}
	
	function ClickButton()
	{
		if (hv == 1)
		{
			button.style.top = obj1.offsetTop + parseInt((obj2.offsetHeight - obj1.offsetTop) / 2) - 12;
			button.style.left = -4;
			if (obj1.style.display == "none")
			{
				obj1.style.display = "block";
				obj.style.pixelLeft = obj1.offsetWidth;
				button.innerText = 3;
				obj.style.cursor = "col-resize";
			}
			else
			{
				button.innerText = 4;
				obj1.style.display = "none";
				obj.style.cursor = "default";
				obj.style.pixelLeft = 0;
			}
		}
		else
		{
			if (obj1.style.display == "none")
			{
				obj1.style.display = "block";
				var pos = $.jcom.getObjPos(obj2, obj.offsetParent);
				obj.style.pixelTop = pos.top;
				button.innerText = 5;
				obj.style.cursor = "row-resize";
			}
			else
			{
				button.innerText = 6;
				obj1.style.display = "none";
				obj.style.cursor = "default";
				var pos = $.jcom.getObjPos(obj2, obj.offsetParent);
				obj.style.pixelTop = pos.top;
			}
			obj.onmouseover();
		}
		self.onsplit(obj.style.pixelLeft, obj.style.pixelTop, self)
	}
	
	function BeginSplit(event)
	{
		if (obj2.style.display == "none")
			return;
		button.style.display = "none";
		if (obj1.style.display == "none")
			return button.onclick();
		$(document).on("mousemove", Splitting);
		$(document).on("mouseup", EndSplit);
		obj.style.filter = "alpha(opacity=60)";
//		obj.setCapture();
		var pos = $.jcom.getObjPos(obj);
		if (hv == 1)
			delta = pos.left - event.clientX;
		else
			delta = pos.top - event.clientY;
		Splitting(event);
	};
	
	function Splitting(event)
	{
		var pos = $.jcom.getObjPos(obj);
		var p1 = $.jcom.getObjPos(obj1.parentNode);
//		var p2 = $(obj).position();
		if (hv == 1)
		{
			if (event.clientX - p1.left < cfg.minedge)
				$(obj).css("left", (p1.left + cfg.minedge - pos.left + parseInt(obj.style.left)) + "px");
			else if (p1.right - event.clientX < cfg.maxedge)
				$(obj).css("left", (p1.right - cfg.maxedge - pos.left + parseInt(obj.style.left)) + "px");
			else
				$(obj).css("left", (event.clientX - pos.left + delta + parseInt(obj.style.left)) + "px");
		}
		else
		{
			if (event.clientY - p1.top < cfg.minedge)
				$(obj).css("top", (p1.top + cfg.minedge - pos.top + parseInt(obj.style.top)) + "px");
			else if (p1.bottom - event.clientY < cfg.maxedge)
				$(obj).css("top", (p1.bottom - cfg.maxedge - pos.top + parseInt(obj.style.top)) + "px");
			else
				$(obj).css("top", (event.clientY - pos.top + delta + parseInt(obj.style.top)) + "px");
		}
	}

	function EndSplit()
	{
		obj.style.filter = "alpha(opacity=0)";
		var pos = $.jcom.getObjPos(obj1);//, obj.offsetParent);
		var left = parseInt(obj.style.left);
		var top = parseInt(obj.style.top);
		if (hv == 1)
		{
			$(obj1).css("width", (left - pos.left) + "px");
//			obj2.style.pixelWidth -= obj.style.pixelLeft  - pos.right;
		}
		else
		{
			$(obj1).css("height", (top - pos.top) + "px");
//			obj2.style.pixelHeight -= obj.style.pixelTop  - pos.top;
		}
//		self.onsplit(obj.style.pixelLeft, obj.style.pixelTop, self);
		$(document).off("mousemove", Splitting);
		$(document).off("mouseup", EndSplit);
//		document.releaseCapture();
		self.refresh();
		self.onsplit(left, top, self);
	}

	function Init()
	{
		if (typeof obj1 != "object")
			return;
		if (typeof(obj2) != "object")
			obj2 = obj1.nextSibling;
		cfg = $.jcom.initObjVal({minedge:0, maxedge:0, nStyle:0}, cfg);
		Create();
		self.refresh();
	}
	Init();
};

$.jcom.PopupBox = function(tag, x1, y1, x2, y2, cfg) //��:������
{// �Զ��ھ���x1, y1, x2, y2��λ����Χ����, ֻҪ��������������ĵ�,�����������ĵ��߽�.�����ڵ����˵��ȡ�
//tag:
//x1:
//y1:
//x2:
//y2:
//cfg:
var self = this, oDiv;
	this.show = function()		//����:��ʾ������
	{
		x1 = arguments[0];
		y1 = arguments[1];
		x2 = arguments[2];
		y2 = arguments[3];
		if (typeof x1 == "undefined")
		{
			x1 = cfg.body.scrollLeft;
			y1 = cfg.body.scrollTop;
			if (event != null)
			{
				x1 = event.clientX;
				y1 = event.clientY;
			}
		}
		if (typeof x2 == "undefined")
		{
			x2 = x1;
			y2 = y1;
		}

		oDiv.style.display = "block";
		var left = x2, top = y1;
		if (x1 == x2)
			top = y2;
		if ((y1 != y2) && (top + oDiv.clientHeight + 2 >= cfg.body.clientHeight + cfg.body.scrollTop))
		{
			top = y2 - oDiv.clientHeight;		//x1,x2,y1,y2��Ϊ����,����Ϊ�˵�����ʽ�����ݿռ�λ�ã���ʾ�ڲ˵�����Χ
			if (x1 == x2)
				top = y1 - oDiv.clientHeight - 2;//x1,x2,y1,y2��Ϊ��ֱ���ߣ�����Ϊ��������ʽ�����ݿռ�λ�ã���ʾ�����������
		}
		if ((x1 != x2) && (x2 + oDiv.clientWidth >= cfg.body.clientWidth + cfg.body.scrollLeft))
			left = x1 - oDiv.clientWidth;	//��Ӧ�ڲ˵���ʾ�����ұ߿ռ䲻�����ͷŵ����
		if (top + oDiv.clientHeight > cfg.body.clientHeight + cfg.body.scrollTop)
			top = cfg.body.clientHeight - oDiv.clientHeight + cfg.body.scrollTop;
		if (left + oDiv.clientWidth > cfg.body.clientWidth + cfg.body.scrollLeft)
			left = cfg.body.clientWidth - oDiv.clientWidth + cfg.body.scrollLeft;
		
		if (top < 0)
			top = 0;	//���ϻ���Ҳ�������ʹ��ϻ���ԭ�㿪ʼ
		if (left < 0)
			left = 0;
		oDiv.style.left = left + "px";
		oDiv.style.top = top + "px";
//		oDiv.focus();		//��ȥ����Ӱ�������򣬵���ʧȥ���뽹��
	};

	this.isShow = function()	//����:��ⵯ�����Ƿ���ʾ
	{
		if ((oDiv == undefined) || (oDiv.style.display == "none"))
			return false;
		return true;
	};
	
	this.hide = function()		//����:���ص�����
	{
		oDiv.style.display = "none";
	};
	
	this.remove = function()	//����:�Ƴ�������
	{
		$(oDiv).remove();
		oDiv = undefined;
		if (cfg.autoHide == 1)
			$(document).off("mousedown", CheckHide);
		if (typeof (cfg.hideButton == "string") && (cfg.hideButton != ""))
			$("#hideButton", oDiv).off("click", this.onClose)
	};

	this.getdomobj = function()	//����:�õ��������DOM����
	{
		return oDiv;
	};
	
	this.unselect = function()	//����:���õ������е�Ԫ������Ϊ����ѡ
	{
		$(oDiv).attr("UNSELECTABLE", "on");		//ie,�˴��ƺ�Ҳ�ܶ�̬����
		$("*:not(input)", oDiv).attr("UNSELECTABLE", "on");		//ie
		$("*:not(input)", oDiv).css("MozUserSelect", "none");		//firebox
		$("*:not(input)", oDiv).css("WebkitUserSelect", "none");	//chrome
	};
	
	this.setSize = function(width, height)	//����:���õ�����ĳߴ�
	{
		$(oDiv).width(width);
		$(oDiv).height(height);
	};

	this.setPopObj = function (obj)		//����:���õ����������
	{
		tag = obj;
		$(oDiv).append(tag);
		if (typeof x1 == "number")
			this.show(x1, y1, x2, y2);
		if ((cfg.unselect == 1) || (cfg.unselect == true))
			this.unselect();
	};
	
	this.top = function ()		//����:���������ö�
	{
		var iframes  = $("iframe", oDiv);
		if (iframes.length > 0)		//��div�����iframeʱ���ᵼ��iframe�е�����ʧЧ��
			return;
		$(cfg.body).append(oDiv);
	};
	
	this.onClose = function ()	//�¼�������˹رհ�ť��Ĭ��Ϊ����
	{
		self.hide();
	};
	
	function CheckHide(e)
	{
		if (e.target == oDiv)
			return;
		if (!($(event.target).parents().is($(oDiv))))
			self.hide(true);
	}
	
	cfg = $.jcom.initObjVal({body:document.body, unselect:1, position:"fixed", title:"", autoHide:0, border:"none", hideButton:""}, cfg);
	oDiv = cfg.body.ownerDocument.createElement("DIV");
	if (typeof (cfg.hideButton == "string") && (cfg.hideButton != ""))
	{
		var s = $.jcom.getItemImg(cfg.hideButton, "float:right;font-size:20px;", "div", "id=hideButton align=right");
		$(oDiv).html(s);
		$("#hideButton", oDiv).on("click", this.onClose)
	}
	if (typeof (cfg.title == "string") && (cfg.title != ""))
		$(oDiv).append("<h3 align=center>" + cfg.title + "</h3>");
		
	$(cfg.body).append(oDiv);
	$(oDiv).css({display: "none", position: cfg.position, backgroundColor: "white", zIndex: 99, border:cfg.border, overflow: "visible"});
	this.setPopObj(tag);
	if (cfg.autoHide == 1)
		$(document).on("mousedown", CheckHide);

};

$.jcom.PopupWin = function(href, cfg)	//��:��������
{//
//href:
//cfg:
	var self = this;
	var box, mask, sizebox;
	var bodyscroll;
	function init()
	{
		if (href == undefined)
			return;
		var htmlText = "";
		if (typeof href == "string")
		{
			if (href.substr(0, 1) != "<")
				htmlText = "<iframe id=IFrameDlg name=" + cfg.framename + " frameborder=0 style='width:100%;height:100%' src=" + href + "></iframe>";
			else
				htmlText = href;
		}
		var body = document.body;
		var doc = document;
		if (typeof cfg.parent == "object")
		{
			if (cfg.parent.nodetype == 1)
				body = cfg.parent;
			else
				body = cfg.parent.getbox().getdomobj();
			doc = body.ownerDocument;
		}
		var top = body.scrollTop;
		var left = body.scrollLeft;
		if (cfg.mask >= 0)
		{
			mask = doc.createElement("DIV");
			$(mask).css({position: "fixed", zIndex: 99, left: left + "px", top: top + "px", width: "100%", height: "100%", opacity: cfg.mask / 100, backgroundColor:"white", filter: "alpha(opacity=" + cfg.mask + ")"});
			$(body).append(mask);
			bodyscroll = body.scroll;
			body.scroll = "no";
		}
		if (cfg.top < 0)
			cfg.top = top + parseInt(($(window).height() - cfg.height) / 2);
		if (cfg.left < 0)
			cfg.left = left + parseInt(($(window).width() - cfg.width) / 2);
		if (cfg.top < 0)
			cfg.top = 0;
		if (cfg.left < 0)
			cfg.left = 0;
		var tag = "<div id=InDlgBox style='width:" + cfg.width + "px;height:100%;' class=" + cfg.css + 
			"><div nowrap id=RTDiv><div id=LTDiv><div id=TDiv>" +
			"<div id=CloseButton onmouseover=this.className='ClsBox_Roll'; onmouseout=this.className='ClsBox'; class=ClsBox></div>" +
			"<b id=titlebar style=width:100%;overflow:hidden;>" + cfg.title + "</b></div></div></div><div id=RDiv style=height:" +
			(cfg.height - 32) + "px;><div id=LDiv><div id=MDiv>" + htmlText +
			"</div></div></div><div id=RBDiv><div id=LBDiv><div id=BDiv></div></div></div></div>";

		box = new $.jcom.PopupBox(tag, cfg.left, cfg.top, cfg.left, cfg.top, {body:body,unselect:cfg.unselect, position:cfg.position});
		if ((cfg.unselect == 0) || (cfg.unselect == false))
			box.unselect = function (){};

		box.show(cfg.left, cfg.top, cfg.left, cfg.top);

		var div = box.getdomobj();

		if ((cfg.title == "") && ($(div).find("#IFrameDlg").length > 0))
			$(div).find("#IFrameDlg").on("load", frameOK);
		if ((cfg.bClose == 0) || (cfg.bClose == false))
			$(div).find("#CloseButton").css("display", "none");
		box.setSize(cfg.width, cfg.height);
		sizebox = new $.jcom.SizeBox(cfg.resize, "transparent");
		sizebox.attach(div);
		$(div).find("#TDiv").on("mousedown", sizebox.start);
		$(div).find("#TDiv").on("dblclick", sizebox.runMax);
		$(div).find("#TDiv").on("click", clickbar);
//		$(div).on("resize", ResizeWin);
		$(div).attr("userfun", {resize: ResizeWin});

	}
	
	function clickbar(event)
	{
		box.top();
		if (event.target.id == "CloseButton")
			self.close();
	}
	
	function ResizeWin()
	{
		var div = box.getdomobj();
		div.style.overflow = "hidden";
		$(div).find("#RDiv").css("height", $(div).height() - 32 + "px");
		$(div).find("#InDlgBox").css("width", div.style.width);
		div.style.overflow = "visible";
	}

	function frameOK()
	{
		var div = box.getdomobj();
		$(div).find("#titlebar").html($(div).find("#IFrameDlg")[0].contentWindow.document.title);
	}

	this.show = function (left, top, width, height)		//����:��ʾ
	{
		var div = box.getdomobj();
		if (typeof mask == "object")
		{
			if (mask.style.display == "none")
			{
				mask.style.display = "block";
				bodyscroll = document.body.scroll;
				document.body.scroll = "no";				
			}
		}
		if ((left > 0) || (top > 0))
			box.show(left, top, left, top);
		else
			box.show(cfg.left, cfg.top, cfg.left, cfg.top);
		if ((width > 0) && (height > 0))
		{
			box.setSize(width, height);
			ResizeWin();
		}
//		else
//		{
//			var pos = $.jcom.getObjPos($("#MDiv")[0], div);
//			box.setSize(pos.right - pos.left + 30, pos.bottom - pos.top + 10);
//			ResizeWin();
//		}
		sizebox.attach(div);
		box.top();
	}

	this.hide = function ()		//����:����
	{
		if (typeof mask == "object")
		{
			mask.style.display = "none";
			document.body.scroll = bodyscroll;
		}
		var div = box.getdomobj();
		$("#CloseButton", div).prop("className", "ClsBox");
		box.hide();
		sizebox.detach();
	};

	this.runMax = function (nType)		//����:���
	{
		sizebox.runMax(nType);
	};

	this.getbox = function ()		//����:�õ���Ӧ�ĵ�����
	{
		return box;
	};
	
	this.close = function ()		//����:�ر�
	{
		self.onclose();
		if (typeof mask == "object")
		{
			$(mask).remove();
			document.body.scroll = bodyscroll;
		}
		box.remove();
		sizebox.remove();
	};
	
	this.setTitle = function (title)			//����:���ô��ڱ���
	{
		cfg.title = title;
		var div = box.getdomobj();
		$(div).find("#titlebar").html(title);
		sizebox.attach(div);
	}
	
	this.isShow = function()			//����:����Ƿ���ʾ
	{
		return box.isShow();
	}

	this.load = function (href)		//����:���¼���
	{
		var div = box.getdomobj();
		var frame = $(div).find("#IFrameDlg");
		if (frame.length > 0)
			frame[0].src = href;
		else
			$("#MDiv",div).html(href);
	};
	
	this.onclose = function ()		//�¼�:�ر�ʱ����
	{};
	cfg = $.jcom.initObjVal({left:-1, top:-1, width:300, height:350, css:"InlineDlg", position:"absolute",
		framename:"IFrameDlg", title:"", resize:1, mask:-1, bClose:1, parent:0, unselect:0}, cfg);
	init();
};

$.jcom.CommonMenu = function(menudef, cfg) //��:�����˵�
{//
//menudef:
//cfg:
//˵��:	var sysmenu = new CommonMenu([{item:"�˵���", img:"pic.gif", action:"alert()"},{item:""},{item:"�Ӳ˵�,child:[...]}]);
//	sysmenu.show();

	cfg = $.jcom.initObjVal({oParentMenu:undefined, domobj:undefined, itemstyle:"", unselect:0, position:"absolute"}, cfg);
	var oMenuBox, oRoll;
	var oSubMenu;
	var oTimeout = null;
	var self = this;
	function InitMenu(x1, y1, x2, y2)
	{
		if (typeof(menudef) != "object")
			return;
		var tag = "", bLine = false;
		for (var x = 0; x < menudef.length; x++)
		{
			if (menudef[x].status == 1)
				continue;
				
			if ((menudef[x].item == "") || (typeof menudef[x].item == "undefined"))
			{
				if (bLine == true)
					tag += "<tr height=8px><td bgcolor=#e8edf0 colspan=3></td><td colspan=3 style='padding:4px 4px 0px 2px;'>" +
						"<div style='overflow:hidden;width:100%;height:3px;border-top:1px solid #e8edf0'></div></td><td></td></tr>";
				bLine = false;
			}				
			else
			{
				if (menudef[x].disabled)
					tag += "<tr class=RMenuItemDis";
				else
					tag += "<tr class=RMenuItem";
				tag += " height=24px node=" + x + "><td bgcolor=#e8edf0></td><td class=leftTD></td>";
				tag += "<td class=leftTD align=center>" + $.jcom.getItemImg(menudef[x].img) + "</td>";
				var style = "";
				if (typeof menudef[x].style == "string")
					style = menudef[x].style;
				tag += "<td nowrap style='font-size:9pt;padding-left:10px;" + style + ";" + cfg.itemstyle + "'>" + menudef[x].item + "</td>";
				if (typeof menudef[x].child == "object")
					tag += "<td align=right style='font:normal normal normal 16px'>&#9654</td>";
				else
					tag += "<td></td>";
				tag += "<td></td><td bgcolor=white></td></tr>";
				bLine = true;
			}
		}
		tag = "<table cellpadding=0 cellspacing=0 border=0 style='filter:progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray);background-color:white;border:1px solid gray;cursor:default;'>" +
			"<tr height=3px><td bgcolor=#e8edf0><div style=width:2px;height:3px;overflow:hidden;></div></td>" +
			"<td bgcolor=#e8edf0><div style=width:3px;height:3px;overflow:hidden;></div></td>" + 
			"<td bgcolor=#e8edf0><div style=width:30px;height:3px;overflow:hidden;></div></td><td></td>" +
			"<td><div style=width:32px;height:3px;overflow:hidden;></div></td>" +
			"<td><div style=width:3px;height:3px;overflow:hidden;></div></td>" +
			"<td><div style=width:2px;height:3px;overflow:hidden;></div></td></tr>" + tag +
			"<tr height=3px><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td>" +
			"<td></td><td></td></tr></table>";
		var oMenuDiv = cfg.domobj;
		if (oMenuDiv == undefined)
		{
			oMenuBox = new $.jcom.PopupBox(tag, x1, y1, x2, y2, {position:cfg.position});
//			oMenuBox.show(x1, y1, x2, y2);
//			oMenuBox.unselect();
			oMenuDiv = oMenuBox.getdomobj();
			if ($(oMenuDiv).height() > $(document.body).height())
			{
				$(oMenuDiv).height($(document.body).height());
				oMenuDiv.style.overflowX = "hidden";
				oMenuDiv.style.overflowY = "auto";
			}
//		  	oMenuDiv.firstChild.onfocusout = CheckFocus;
			$(oMenuDiv).children(":first").on("focusout", CheckFocus);
			$(document).on("mousedown", CheckHide);
			oMenuDiv.firstChild.focus();
		}
		else
			$(oMenuDiv).html(tag);
		$(oMenuDiv).on("mousemove", RollMenu);
//		$(oMenuDiv).on("mouseout", RollMenu);
		$(oMenuDiv).on("mouseleave", RollMenu);
		$(oMenuDiv).on("click", ActionMenu);
	}

	function RollMenu(event)
	{
		var oMenuDiv = cfg.domobj;
		if (oMenuDiv == undefined)
			oMenuDiv = oMenuBox.getdomobj();
		var oTR = $.jcom.findParentObj(event.target, oMenuDiv, "TR");
		if (oTR == oRoll)
			return;
		if (typeof oRoll == "object")
		{
//			oRoll.cells[1].className = "RMenuItem1";
//			oRoll.cells[2].className = "RMenuItem1";
//			oRoll.cells[3].className = "RMenuItem2";
//			oRoll.cells[4].className = "RMenuItem2";
//			oRoll.cells[5].className = "RMenuItem2";
			if (oTimeout != null)
			{
				window.clearTimeout(oTimeout);
				oTimeout = null;
			}
			if (typeof oSubMenu == "object")
				oSubMenu.hide();
			oSubMenu = 0;
//			oMenuDiv.firstChild.focus();
		}
		oRoll = 0;	
		if ((typeof(oTR) == "object") && (oTR.offsetHeight > 10))
		{
//			oTR.cells[1].className = "RMenuSelItem1";
//			oTR.cells[2].className = "RMenuSelItem2";
//			oTR.cells[3].className = "RMenuSelItem2";
//			oTR.cells[4].className = "RMenuSelItem2";
//			oTR.cells[5].className = "RMenuSelItem3";
			if (oTR.cells[4].firstChild != null)
				oTimeout = window.setTimeout(ShowSubMenu, 500);
			oRoll = oTR;
		}	
	}

	function ShowSubMenu()
	{
		var index = $(oRoll).attr("node");
		if (typeof menudef[index].child == "object")
		{
			var pos = $.jcom.getObjPos(oRoll);
			if ((typeof oMenuBox == "object") || (typeof cfg.domobj == "object"))
			{
				oSubMenu = new $.jcom.CommonMenu(menudef[index].child, {oParentMenu:self, position:cfg.position});
				oSubMenu.show(pos.left, pos.top, pos.right, pos.bottom);
			}
		}
	}

	function ActionMenu()
	{
		if (typeof oSubMenu != "object")
		{
			var index = $(oRoll).attr("node");
			if (index == undefined)
				return;
			if (typeof menudef[index].child == "object")
			{
				if (oTimeout != null)
				{
					window.clearTimeout(oTimeout);
					oTimeout = null;
				}
				return ShowSubMenu();
			}
			self.hide(true);
			if	(menudef[index].disabled)
				return;
			if (typeof menudef[index].action == "string")
				return eval(menudef[index].action);
			if (typeof menudef[index].action == "function")
				return menudef[index].action(oRoll, menudef[index]);
			self.runmenu(oRoll, menudef[index]);
		}
	}

	function CheckFocus()
	{
		if ((typeof oSubMenu == "object") && (oSubMenu.isShow() == true))
			return;
		self.hide(true);
	}

	function CheckHide(event)
	{
		if ((typeof oSubMenu == "object") && (oSubMenu.isShow() == true))
			return;
		var oMenuDiv = oMenuBox.getdomobj();
		if (event.target == oMenuDiv)
			return;
		if (!($(event.target).parents().is($(oMenuDiv))))
			self.hide(true);
	}
	
	this.show = function (x1, y1, x2, y2, def)		//����:��ʾ�˵�
	{
		if (typeof def == "object")
			menudef = def;
		oRoll = 0;
		if (typeof oMenuBox == "object")
			return oMenuBox.show(x1, y1, x2, y2);
		InitMenu(x1, y1, x2, y2);
	};
	
	this.hide = function (flag)		//����:���ز˵�
	{
		if (typeof oMenuBox == "object")
		{
			$(document).off("mousedown", CheckHide);
			if (typeof oSubMenu == "object")
				oSubMenu.hide();
			oSubMenu = 0;
			oMenuBox.remove();
			oMenuBox = 0;
		}
		if ((flag == true) && (typeof cfg.oParentMenu == "object"))
			cfg.oParentMenu.hide(true);
	};
	
	this.isShow = function ()		//����:���˵��Ƿ���ʾ
	{
		if (typeof oMenuBox == "object")
			return true;
		return false;
	};
	
	this.setDisabled = function (item, disabled)		//����:���ý�ֹ
	{
		var x = $.jcom.inObjArray(menudef, "item", item);
		if (x < 0)
			return;
		menudef[x].disabled = disabled;
		if (typeof cfg.domobj != "object")
			return;
		var tr = $("tr[node='" + x + "']", cfg.domobj);
		tr.removeClass();
		if (disabled)
			tr.addClass("RMenuItemDis");
		else
			tr.addClass("RMenuItem");
	};

	//���˲˵�����ʾ
	this.setMenuFilter = function(filter)			//����:���˲˵���
	{//
		//˵��: filter = {	disable:1, str:"���ͼ�ʱ��Ϣ,�����ڲ��ʼ�,���ĸ�������,���ĶԻ���¼,���������ڲ��ʼ�,���Ϊ�ҵĺ���"};
		//��: filter = {	disable:1, str:""};
		if (typeof filter != "object")
			return;
		var ss = filter.str.split(",");
//		var flag = 1, delflag;
		var status = 0 ,inistatus = 0;
		if (filter.disable == 1)
			status = 1;
		else
			inistatus = 1;
		for (var x = 0; x < menudef.length ; x++)
		{
			menudef[x].status = inistatus;
			for (var y = 0; y < ss.length; y++)
			{
				if (menudef[x].item == ss[y])
				{
					menudef[x].status = status;
					break;
				}
			}
		}
	};

	this.getmenu = function(item)		//����:�õ��˵���
	{
		if (typeof item == "undefined")
			return menudef;
		return $.jcom.inObjArray(menudef, "item", item, 1);		//����:��ȡ�ֶζ������ݵ�����, flag=1,ͬʱ���ӽڵ����ң������ؽڵ����

//		var obj = this.getDomItem(item);
//		if (typeof obj == "object")
//			return menudef[$(obj).attr("node")];
	};
	
	this.reload = function (def)	//����:���¼��ز˵�
	{
		if (typeof def == "object")
			menudef = def;
		oRoll = 0;
		if (typeof cfg.domobj == "object")
		{
			$(cfg.domobj).off("mousemove", RollMenu);
			$(cfg.domobj).off("mouseout", RollMenu);
//			$(cfg.domobj).off("mouseleave", RollMenu);
			$(cfg.domobj).off("click", ActionMenu);
			InitMenu();
		}
	};
	
	this.runmenu = function (oRoll, menuitem)	//�¼�:����˲˵����menudefû�ж���actionʱ������
	{
	};
	
	self.reload();
};

$.jcom.CommonMenubar = function(menudef, domObj, cfg)//��:�˵���//�˵�����������������ҳ������,�˵��������ڸ�����������.������ԭ�е����ݱ�����.
{//
	//˵��:	var menubar = new $.jcom.CommonMenubar([{item:"�˵���", img:"pic.gif", action:"alert()"},{item:""},{item:"�Ӳ˵�,child:[...]}], domobj);
	//
	var oRoll;
	var nStatus = 0;
	var self = this;
	var childMenu;
	
	function InitMenu()
	{
		if (typeof domObj != "object")
			return;
		if (typeof cfg == "string")
			cfg = {title:cfg};
		cfg = $.jcom.initObjVal({title:"", nMode:1, className:"CommonMenubar", tagName:"BUTTON"}, cfg);

		var tag = "";
		for (var x = 0; x < menudef.length; x++)
			tag += getMenuItemHTML(menudef[x], x);
		$(domObj).html("<table cellpadding=0 cellspacing=0 border=0 class=" + cfg.className +
			"><tr><td nowrap>" + tag + "</td><td nowrap id=titletd align=right>" + cfg.title +
			"</td></tr></table>");
 		var objs = $(domObj).find("BUTTON");
		objs.on("mouseover", RollMenu);
		objs.on("mouseout", OutMenu);
	}
	
	function getMenuItemHTML(item, node)
	{
		if (typeof item == "string")
			return item;
		if ( (item.item == undefined) && (item.img == undefined) && (item.action == undefined))
			return "&nbsp;";
		var tag = "<" + cfg.tagName + " UNSELECTABLE=on node=" + node;
		if ((item.disabled == true) || ((typeof item.action == "undefined") && (typeof item.child == "undefined")))
			tag += " disabled";
		if (typeof item.className == "string")
			tag += " class=" + item.className + "0";
		else
			tag += " class=CommonMenubarItem0";
		if (typeof item.style == "string")
			tag += " style=\"" + item.style + "\"";
		if ((typeof item.title == "string") && (item.title != ""))
			tag += " title=\"" + item.title + "\"";
		if ((typeof item.img == "string") && (item.img != ""))
			tag += "><img UNSELECTABLE=on align=texttop src='" + item.img + "'";
		if ((typeof item.item == "string") && (item.item != ""))
				tag += ">" +  item.item + "</button>";
		else
			tag += "></" + cfg.tagName + ">";
		return tag;
	}
	
	function OutMenu(obj)
	{
		if ((nStatus == 1) && (typeof childMenu == "object"))
			return;
		self.hide();
	}
	
	function RollMenu(event)
	{
		var oSrc = $.jcom.findParentObj(event.target, domObj, cfg.tagName);
		if (oRoll == oSrc)
			return;
		if (typeof oSrc != "object")
			return;
		var node = $(oSrc).attr("node");
		if ((oSrc.tagName == cfg.tagName) && (typeof node != "undefined"))
		{
			if (oSrc.disabled)
				return;
			if (typeof oRoll == "object")
				self.hide();
			oRoll = oSrc;
			if (node >= menudef.length)
				return;
			if ((menudef[node].type == 2) && (menudef[node].status == 1))
				return;
			if ((nStatus == 1) && (typeof menudef[node].child == "object"))
				PushMenu();
			else
			{
				nStatus = 0;
				oRoll.className = oRoll.className.substr(0, oRoll.className.length - 1) + "1";
				if (typeof childMenu == "object")
				{
					childMenu.hide();
					childMenu = 0;
				}
			}
		}
	}
		
	function PushMenu()
	{
		if (typeof oRoll != "object")
			return;
		if ((oRoll.type == 2) && (oRoll.status == 1))
			return;
		nStatus = 1;
		oRoll.className = oRoll.className.substr(0, oRoll.className.length - 1) + "2";
		if (typeof childMenu == "object")
		{
			childMenu.hide();
			childMenu = 0;
			if (event.type == "mousedown")
				return;
		}
		var node = $(oRoll).attr("node");
		if (node >= menudef.length)
			return;
		if (typeof menudef[node].child == "object")
		{
			var pos = $.jcom.getObjPos(oRoll);
			childMenu = new $.jcom.CommonMenu(menudef[node].child, {oParentMenu:self});
//			childMenu.show(pos.left, pos.bottom, pos.left, pos.bottom);
			window.setTimeout(function(){childMenu.show(pos.left, pos.bottom, pos.left, pos.bottom);}, 10);
		}
	}
		
	function ActionMenu(event)
	{
		if ((typeof oRoll == "object") && (typeof childMenu != "object")) 
		{
			var node = $(oRoll).attr("node");
			oRoll.blur();
			if (node >= menudef.length)
				return;
			switch (menudef[node].type)
			{
			case 1:
				if (menudef[node].status == 1)
					menudef[node].status = 0;
				else
					menudef[node].status = 1;
				break;
			case 2:
				for (var x = 0; x < menudef.length; x++)
				{
					if (node != x)
					{
						menudef[x].status = 0;
						SetDomItem(self.getDomItem(x));
					}
				}
				menudef[node].status = 1;
				break;
			}
			if (typeof menudef[node].action == "string")
				eval(menudef[node].action);
			if (typeof menudef[node].action == "function")
				menudef[node].action(oRoll, menudef[node]);
			self.hide(true);
			nStatus = 0;
		}
	}
	
	function DblClickMenu()
	{
		if ((typeof oRoll == "object") && (typeof childMenu != "object")) 
		{
			var node = $(oRoll).attr("node");
			if (node >= menudef.length)
				return;
			if (typeof menudef[node].dblclick == "string")
				eval(menudef[node].dblclick);
			if (typeof menudef[node].dblclick == "function")
				menudef[node].dblclick(oRoll, menudef[node]);
		
		}
	}
	
	function SetDomItem(obj)
	{
		var node = $(obj).attr("node");
		if (node >= menudef.length)
			return;
		if (((menudef[node].type == 1) || (menudef[node].type == 2))
			&& (menudef[node].status == 1))
			obj.className = oRoll.className.substr(0, obj.className.length - 1) + "2";
		else
			obj.className = obj.className.substr(0, obj.className.length - 1) + "0";	
	}
		
	this.run = function(item)		//����:ִ�в˵���Ķ���
	{
		oRoll = this.getDomItem(item);
		if (typeof oRoll == "object")
			oRoll.click();
	};
	
	this.setStatus = function(item, status)		//����:���ò˵���״̬
	{
		var obj = this.getDomItem(item);
		menudef[$(obj).attr("node")].status = status;
		SetDomItem(obj);
	}
	
	this.setAttrib = function(name, key, value)	//����:���ò˵�������
	{
		var item = this.getItem(name);
		if (typeof item == "object")
			item[key] = value;		
	};
	
	this.setDisabled = function (item, disabled)		//����:���ý�ֹ
	{
		var obj = this.getDomItem(item);
		obj.disabled = disabled;
	};
	
	this.getDomItem = function(item)		//����:�õ��˵����DOM����
	{
		var oo = domObj.getElementsByTagName(cfg.tagName);
		for (var x = 0; x < oo.length; x++)
		{
			switch (typeof item)
			{
			case "number":
				if ($(oo[x]).attr("node") == item)
					return oo[x];
				break;
			case "string":
				if ((oo[x].innerText == item) || (oo[x].title == item))
					return oo[x];
				break;
			case "object":
				if (menudef[$(oo[x]).attr("node")] == item)
					return oo[x];
			}
		}
	};

	this.hide = function (flag)		//����:���ز˵�
	{
		if (flag == 1)
			nStatus = 0;
		if (typeof oRoll != "object")
			return;
		SetDomItem(oRoll);
		oRoll = 0;
		if ((typeof childMenu == "object") && (childMenu.isShow()))
			childMenu.hide();
	};
	
	this.show = function (x1, y1, x2, y2, def)		//����:��ʾ�������˵�
	{
		if (childMenu == undefined)
			childMenu = new $.jcom.CommonMenu(menudef);
		childMenu.show(x1, y1, x2, y2, def);
	};
	
	this.append = function(obj)		//����:��Ӳ˵���
	{
		
		var node = menudef.length;
		menudef[node] = obj;
		var tag = getMenuItemHTML(obj, node);
		var o = self.getDomItem(node - 1);
		if (o == null)
		{
			$(domObj.firstChild.rows[0].cells[0]).append(tag);
//			domObj.firstChild.rows[0].cells[0].insertAdjacentHTML("afterBegin", tag);
			$(domObj).children().first().children().last().on("mouseover", RollMenu);
 			$(domObj).children().first().children().last().on("mouseout", OutMenu);
		}
		else
		{
			$(o).after(tag);
//			o.insertAdjacentHTML("afterEnd", tag);
			$(o).siblings().on("mouseover", RollMenu);
 			$(o).siblings().on("mouseout", OutMenu);
		}
		return node;
	};

	this.remove = function(item)		//����:�Ƴ��˵���
	{
		var obj = this.getDomItem(item);
		for (var x = parseInt($(obj).attr("node")) + 1; x < menudef.length; x ++)
		{
			var o = this.getDomItem(x);
			$(o).attr("node", parseInt($(o).attr("node")) - 1);
		}
		var o = menudef.splice($(obj).attr("node"), 1);
		$(obj).remove();
		return o;
	};
	
	this.showItem = function(item, bshow)		//����:���û��ȡ�˵����Ƿ���ʾ
	{
		var obj = this.getDomItem(item);
		if (typeof bshow == "undefined")
			return (obj.style.display == "none") ? false : true;
		if ((bshow == 0) || (bshow == false))
			obj.style.display = "none";
		else
			obj.style.display = "inline";
	};

	this.insertHTML = function(tag, sWhere)		//����:�ڲ˵�������HTML����
	{
		$(domObj).find("td")[0].insertAdjacentHTML(sWhere, tag);
	};

	this.getmenu = function(item)		//����:��ȡ�˵���
	{
		if (typeof item == "undefined")
			return menudef;
		var obj = this.getDomItem(item);
		if (typeof obj == "object")
			return menudef[$(obj).attr("node")];
	};

	this.setmenutext = function(item, text)		//����:�޸Ĳ˵��������
	{
		var obj = this.getDomItem(item);
		menudef[$(obj).attr("node")].item = text;
		obj.innerHTML = text;
	};

	this.reload = function (def, ncfg)		//����:���¼��ز˵���
	{
 		var objs = $(domObj).find(cfg.tagName);
		objs.off("mouseover", RollMenu);
		objs.off("mouseout", OutMenu);
		if (typeof def == "object")
			menudef = def;
		if (typeof ncfg == "object")
			cfg = ncfg;
		else if (typeof ncfg == "string")
			cfg.title = ncfg;
		InitMenu();
	};

	this.setDOMObj = function (o)		//����:���˵����󶨵�DOM����
	{
		if (typeof domobj == "object")
		{
	 		var objs = $(domObj).find(cfg.tagName);
			objs.off("mouseover", RollMenu);
			objs.off("mouseout", OutMenu);
		 	$(domObj).off("mousemove", RollMenu);
		 	$(domObj).off("click", ActionMenu);
		 	$(domObj).off("mousedown", PushMenu);
		 	$(domObj).off("dblclick", DblClickMenu);
		}
		if ((o == null) || (typeof o != "object"))
			return;
		domObj = o;
		InitMenu();
	 	$(domObj).on("mousemove", RollMenu);
	 	$(domObj).on("click", ActionMenu);
	 	$(domObj).on("mousedown", PushMenu);
	 	$(domObj).on("dblclick", DblClickMenu);
	 };
	 
	 this.getItem = function(name, def)		//����:��ȡ�˵�����
	 {
	 	if (def == undefined)
	 		def = menudef;
	 	for (var x = 0; x < def.length; x++)
	 	{
		 	if (def[x].item == name)
		 		return def[x];
		 	if (typeof def[x].child == "object")
		 	{
		 		var result = this.getItem(name, def[x].child);
		 		if (typeof result == "object")
		 			return result;
		 	}
		}
	 };
	 this.setDOMObj(domObj);
};

//
$.jcom.CommonShadow = function(mode, param1, param2, oDoc)//��:��Ӱ
{//�������ѡ�е�״̬
var old = [], div;
	if (typeof oDoc == "undefined")
		oDoc = document.body;
	this.show = function(obj, bMulti)		//����:��ʾ��֧�ֶ�ѡ
	{
		if ((typeof obj != "object") || (obj == null))
			return this.hide();
		if ((old.length == 1) && (old[0].obj == obj))
			return;
		var len  = 0;
		switch (mode)
		{
		case 0:				//����Ԫ�صı���ɫ
			if ((bMulti != 1) && (bMulti != true))
				this.hide();
			old[old.length] = {value:obj.style.backgroundColor, obj:obj};
			obj.style.backgroundColor = param1;
			break;
		case 1:				//����Ԫ�ص�CSS����
			if ((bMulti != 1) && (bMulti != true))
				this.hide();
			old[old.length] = {value:obj.className, obj: obj};
			obj.className = param1;
			break;
		case 2:				//����һ����Ԫ���ڵ�����Ԫ��,��ʵ�ֹ�Ӱ
			if (typeof div != "object")
			{
				div = document.createElement("DIV");
				div.style.position = "absolute";
				div.style.backgroundColor = param1;
				if (param2 == undefined)
					param2 = 2;
				div.style.filter = "progid:DXImageTransform.Microsoft.alpha(opacity=50) progid:DXImageTransform.Microsoft.Blur(pixelradius=" + 
					param2 + ")";
				$(oDoc).append(div);
			}
			old[len] = {obj:obj};
//			div.style.zIndex = obj.style.zIndex - 1; ʧЧ��������Ϊ������
			var pos = $.jcom.getObjPos(obj, oDoc);
			div.style.width = pos.right - pos.left + "px";
			div.style.height = pos.bottom - pos.top + "px";
			div.style.top = (pos.top - param2) + "px";
			div.style.left = (pos.left - param2) + "px";
			div.style.display = "block";
			break;
		case 3:				//����һ����Ԫ���ڵ���ָ����Ԫ��
			if (typeof div != "object")
			{
				div = document.createElement("DIV");
				div.style.position = "absolute";
				div.innerHTML = param1;
				$(oDoc).append(div);
			}
			old[len] = {obj:obj};
//			div.style.zIndex = obj.style.zIndex - 1;
			var pos = $.jcom.getObjPos(obj, oDoc);
			div.style.width = (pos.right - pos.left) + "px";
			div.style.height = (pos.bottom - pos.top) + "px";
			div.style.top = pos.top + "px";
			div.style.left = pos.left + "px";
			div.style.display = "block";
			break;
		case 4:
			if (typeof div != "object")
			{
				div = document.createElement("SPAN");
				div.innerHTML = param1;
				if (typeof param2 == "string")
					div.style.cssText = param2;
			}
			old[len] = {obj:obj};
			$(obj).append(div);
			break;
		}
	};
		
	this.hide = function()		//����:����
	{
		for (var x = 0; x < old.length; x++)
		{
			switch (mode)
			{
			case 0:
				old[x].obj.style.backgroundColor = old[x].value;
				break;
			case 1:
				old[x].obj.className = old[x].value;
				break;
			case 2:
			case 3:
				div.style.display = "none";
				break;
			}
		}
		old = [];
	};
	
	this.getObj = function()		//����:�õ���ǰ��ʾ�Ķ���
	{
		if (old.length == 0)
			return;
		return old[0].obj;
	};
	
	this.getShadow = function ()		//����:�õ���ǰ��ʾ�Ķ�������
	{
		return old;
	}
	
	this.isShadow = function (obj)		//����:�������Ƿ���ʾ
	{
		for (var x = 0; x < old.length; x++)
		{
			if (obj == old[x].obj)
				return true;
		}
		return false;
	}
};

$.jcom.Desktop = function(nMode, domObj)	//��:�Զ�������
{//������������
var drag;
var self = this;
var root = document.body;
var css = "Widget";
	function getWidget(x, y)
	{
		switch (typeof x)
		{
		case "object":
			return x;
		case "undefined":
			return event.srcElement.parentNode.parentNode.parentNode.parentNode;
		case "string":
			return domObj.all[x];
		default:
			return domObj.childNodes[col].childNodes[row];
		}
	}

	function OverBtn()
	{
		event.srcElement.className = event.srcElement.className.substr(0, event.srcElement.className.length - 1) + "1";
	}

	function OutBtn()
	{
		event.srcElement.className = event.srcElement.className.substr(0, event.srcElement.className.length - 1) + "0";
	}

	function Option()
	{
		var oMenuItems = [];
//		if (typeof self.setupWidgetDlg == "function")
//			oMenuItems[0] = {item:"����", action:self.setupWidgetDlg};
//		oMenuItems[oMenuItems.length] = {};
		oMenuItems[oMenuItems.length] = {item:"���İ�ʽ", action:LayerDlg};
		if (typeof self.appendWidgetDlg == "function")
			oMenuItems[oMenuItems.length] = {item:"�������", action:self.appendWidgetDlg};
				
		var oMenu = new $.jcom.CommonMenu(oMenuItems);
		oMenu.show();
	}
	
	function LayerDlg()
	{
		var text = "<div align=left style='padding:20px;'>" +
			"<span style=width:200px;><input name=layer type=radio value=3 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td bgcolor=white></td><td bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"<span style=width:120px><input name=layer type=radio value=2 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"<br><br><span style=width:200px><input name=layer type=radio value=22 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td width=33% bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"<span style=width:120px><input name=layer type=radio value=12 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td width=67% bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"</div><hr size=1><div align=right style='margin-right:30px;'><input name=OKButton type=button value=ȷ�� onclick=''>&nbsp;&nbsp;<input type=button value=ȡ�� onclick=CloseInlineDlg()></div>"
		InlineHTMLDlg("�����Զ��������ʽ", text, 380, 310);
		var oo = document.all.InDlgDiv.all.layer;
		for (var x = 0; x < oo.length; x++)
		{
			if (oo[x].value == nMode)
				oo[x].checked = true;
		}
		document.all.InDlgDiv.all.OKButton.onclick = setLayer;
	} 
	
	function setLayer(nLayer)
	{
		if (typeof nLayer == "undefined")
		{
			var oo = document.all.InDlgDiv.all.layer;
			for (var x = 0; x < oo.length; x++)
			{
				if (oo[x].checked)
					nLayer = parseInt(oo[x].value);
			}
		}
		changeLayer(nLayer);
		CloseInlineDlg();
		if (typeof self.desktopChange == "function")
			self.desktopChange("layerChange", null, nLayer);
	}
	
	this.minimize = function (x, y)		//����:��С������Ԫ��
	{
	var widget, btn, body, evttype;
		widget = getWidget(x, y);
		btn = widget.firstChild.firstChild.lastChild.firstChild.nextSibling;
		body = widget.firstChild.lastChild;
		if (body.style.display == "none")
		{
			body.style.display = "block";
			btn.className = btn.className.replace("_Restore_", "_Minimize_");
			evttype = "restore";
		}
		else
		{
			body.style.display = "none";
			btn.className = btn.className.replace("_Minimize_", "_Restore_");
			evttype = "minimize";
		}
		if (typeof self.desktopChange == "function")
			self.desktopChange(evttype, widget);
	}
		
	this.close = function(x, y)		//����:�ر�����Ԫ��
	{
		var o = getWidget(x, y);
		if (typeof self.desktopChange == "function")
			self.desktopChange("beforeClose", o);
		$(o).remove();
	}

	function Drag()
	{
		switch (event.srcElement.tagName)
		{
		case "DIV":
			drag = event.srcElement.parentNode.parentNode;
			break;
		case "H5":
			drag = event.srcElement.parentNode.parentNode.parentNode;
			break;
		default:
			return;
		}
		var pos = $.jcom.getObjPos(drag);
		drag.style.border = "2px dashed gray";
		var status = self.getStatus(drag);
		var oDiv = document.createElement("div");
		oDiv.style.display = "block";
		oDiv.style.position = "absolute";
		oDiv.style.filter = "alpha(opacity=70)";
		oDiv.style.zIndex = 100;
		domObj.appendChild(oDiv);
		drag.style.height = pos.bottom - pos.top;
		oDiv.insertAdjacentElement("beforeEnd", drag.firstChild);
		oDiv.style.pixelLeft = pos.left;
		oDiv.style.pixelTop = pos.top;
		oDiv.style.width = pos.right - pos.left;
		var clickleft = event.screenX - pos.left;
		var clicktop = event.screenY - pos.top;
		var oTimer = null;
		var scrollHeight = root.scrollHeight + oDiv.clientHeight;
		function draging()
		{
			oDiv.style.pixelLeft = event.screenX - clickleft;
			oDiv.style.pixelTop = event.screenY - clicktop;
			if ((event.y + 10 > root.clientHeight) || (event.y < 10))
			{
				if ((oTimer == null) && ((root.scrollTop + root.clientHeight < scrollHeight) || (root.scrollTop > 0)))
				{
					var delta = 4;
					if (event.y < 10)
						delta = -4;
					oTimer = window.setInterval(function()
					{
						root.scrollTop += delta;
						oDiv.style.pixelTop += delta;
						clicktop -= delta;
						if ((root.scrollTop + root.clientHeight >= scrollHeight) || (root.scrollTop == 0))
						{
							window.clearInterval(oTimer);
							oTimer = null;
						}
					}, 40);
				}
			}
			else
			{
				if (oTimer != null)
				{
					window.clearInterval(oTimer);
					oTimer = null;
				}
			}
			event.returnValue = false;
			for (var y = 0; y < domObj.childNodes.length; y++)
			{
				pos = $.jcom.getObjPos(domObj.childNodes[y]);
				if ((event.x >= pos.left) && (event.x < pos.right))
				{
					for (var x = 0; x < domObj.childNodes[y].childNodes.length; x++)
					{
						pos = $.jcom.getObjPos(domObj.childNodes[y].childNodes[x]);
						if (event.y + root.scrollTop < pos.bottom - (pos.bottom - pos.top) / 2)
							return domObj.childNodes[y].childNodes[x].insertAdjacentElement("beforeBegin", drag);
					}
					return domObj.childNodes[y].insertAdjacentElement("beforeEnd", drag);
				}
			}
		}

		function dragend()
		{
			document.detachEvent("onmousemove", draging);
			document.detachEvent("onmouseup", dragend);
			if (oTimer != null)
			{
				window.clearInterval(oTimer);
				oTimer = null;
			}
			document.releaseCapture();
			drag.insertAdjacentElement("beforeEnd", oDiv.firstChild);
			drag.style.border = "none";
			drag.style.height = "auto";
			$(oDiv).remove();
			if (self.getStatus(drag) != status)
			{
				if (typeof self.desktopChange == "function")
					self.desktopChange("posChange", drag, status);
			}
			drag = 0;
			oDiv = 0;
		}
		document.attachEvent("onmousemove", draging);
		document.attachEvent("onmouseup", dragend);
		root.setCapture(true);	
	}

	this.createWidget = function(id, title, col, tag)		//����:��������Ԫ��
	{
		if (col >= domObj.childNodes.length)
			col = 0;
		var o = domObj.childNodes[col];
		
		o.insertAdjacentHTML("beforeEnd", "<div id=" + id + " style='width:100%;padding:2px 4px;'>" +
			"<div class=" + css + "_Box><div class=" + css + "_Titlebar><h5 style=float:left;>" + title +
			"</h5><div class=" + css + "_Toolbar><span class=" + css +
			"_Option_Button_0></span><span class=" + css + "_Minimize_Button_0></span>" +
			"<span class=" + css + "_Close_Button_0></span></div></div><div></div></div></div>");
		switch (typeof tag)
		{
		case "string":
			o.lastChild.firstChild.lastChild.insertAdjacentHTML("beforeEnd", tag);
			break;
		case "object":
			o.lastChild.firstChild.lastChild.insertAdjacentElement("beforeEnd", tag);
			break;
		}
		o = o.lastChild.firstChild.firstChild.lastChild;
		o.parentNode.onmousedown = Drag;
		o.firstChild.onmouseover = OverBtn;
		o.firstChild.onmouseout = OutBtn;
		o.firstChild.onclick = Option;

		o.firstChild.nextSibling.onmouseover = OverBtn;
		o.firstChild.nextSibling.onmouseout = OutBtn;
		o.firstChild.nextSibling.onclick = this.minimize;

		o.lastChild.onmouseover = OverBtn;
		o.lastChild.onmouseout = OutBtn;
		o.lastChild.onclick = this.close;

		return o.parentNode.parentNode.parentNode;
	};

	this.setContext = function(widget, tag)		//����:��������Ԫ��������
	{
		if (typeof widget == "object")
			widget.firstChild.lastChild.insertAdjacentHTML("beforeEnd", tag);
	};

	this.getStatus = function(widget)		//����:��ȡ����Ԫ��״̬
	{
		widget = getWidget(widget);
		if (typeof widget != "object")
			return 2;	//0002;
		for (var y = 0; y < domObj.childNodes.length; y++)
		{
			for (var x = 0; x < domObj.childNodes[y].childNodes.length; x++)
			{
				if (domObj.childNodes[y].childNodes[x] == widget)
				{
					if (widget.firstChild.lastChild.style.display == "none")
						return y * 1000 + x * 10 + 1;
					return y * 1000 + x * 10;
				}
			}
		}
		return -1;
	};

	function changeLayer(newMode)
	{
		var colold = nMode % 10;
		var colnew = newMode % 10;
		for (var x = 0; x < colnew - colold; x++)
			domObj.insertAdjacentHTML("beforeEnd", "<div style='float:right;width:33%;overflow-x:hidden;'></div>");
			
		for (var x = 0; x < colold - colnew; x++)
		{
			for (var y = domObj.childNodes[colnew + x].childNodes.length - 1; y >= 0; y--)
				domObj.childNodes[0].insertAdjacentElement("beforeEnd", domObj.childNodes[colnew + x].childNodes[y]);
			$(domObj.childNodes[colnew + x]).remove();		//domObj.childNodes[colnew + x].removeNode(true);	
		}
		switch (newMode)
		{
		case 1:
			domObj.childNodes[0].style.width = "100%";
			break;
		case 2:
			domObj.childNodes[0].style.width = "50%";
			domObj.childNodes[1].style.width = "50%";
			break;
		case 3:
			domObj.childNodes[0].style.width = "33%";
			domObj.childNodes[1].style.width = "34%";
			domObj.childNodes[2].style.width = "33%";
			break;
		case 12:
			domObj.childNodes[0].style.width = "66%";
			domObj.childNodes[1].style.width = "34%";
			break;
		case 22:
			domObj.childNodes[0].style.width = "34%";
			domObj.childNodes[1].style.width = "66%";
			break;
		}
		nMode = newMode;
	}

	if (typeof domObj != "object")
		domObj = root;
	switch (nMode)
	{
	case 1:
		domObj.insertAdjacentHTML("beforeEnd", "<div style='float:left;width:100%;overflow-x:hidden;'></div>");
		break;
	case 2:
		domObj.innerHTML = "<div style='float:left;width:50%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:50%;overflow-x:hidden;'></div>";
		break;
	case 3:
		domObj.innerHTML = "<div style='float:left;width:33%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:34%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:33%;overflow-x:hidden;'></div>";
		break;
	case 12:
		domObj.innerHTML = "<div style='float:left;width:66%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:34%;overflow-x:hidden;'></div>";
		break;
	case 13:
		domObj.innerHTML = "<div style='float:left;width:40%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:40%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:20%;overflow-x:hidden;'></div>";
		break;
	case 22:
		domObj.innerHTML = "<div style='float:left;width:34%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:64%;overflow-x:hidden;'></div>";
		break;
	case 23:
		domObj.innerHTML = "<div style='float:left;width:20%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:40%;overflow-x:hidden;'></div>" +
			"<div style='float:left;width:40%;overflow-x:hidden;'></div>";
		break;
	}
};


$.jcom.CalendarBase = function(tday, domobj, cfg)	//��:������
{
	var self = this;
	var oDiv, year, month, day, hour, minute, second, oSel, mode = 0;
	this.show = function (d)//����:��������ģʽ����ʾ�����ƻ�������ʽ
	{
		InitDate(d);
		switch (cfg.dateType)
		{
		case 1:		//������
			ShowTitle(year, month);
			ShowAll(0);
			break;
		case 2:		//������ ʱ����
			ShowTitle(year, month, day, hour, minute, second);
			ShowAll(0);
			break;
		case 3:		//������ʱ��
			ShowTitle(year, month, day, hour, minute);
			ShowAll(0);
			break;
		case 4:		//ʱ����
			ShowTitle(-1, -1, -1, hour, minute, second);
			ShowAll(3);
			break;
		case 5:		//ʱ��
			ShowTitle(-1, -1, -1, hour, minute);
			ShowAll(3);
			break;
		case 6:		//����
			ShowAll(2);
		case 7:		//�򻯵�ʱ��
			ShowTitle(-1, -1, -1, hour, minute);
			ShowAll(7);
			break;
		}
	};
	
	function showDate()	//��ʾ������
	{
		var daytext = "";
		var today = new Date();
		var mday = new Date(tday.getTime());
		mday.setDate(1);
		var ww = mday.getDay();
		var lunar;
		var tag = "<tr>";
		for (var x = 0; x < ww; x++)
			tag += "<td id=weekday" + x + "></td>";
		if (cfg.lunarDis != true)
			lunar = new $.jcom.LunarDate(mday);
		while (month == mday.getMonth() + 1)
		{
			if (ww == 0)
				tag += "</tr><tr>";
			if (typeof lunar == "object")
			    daytext = "<div class=\"day\" style=\"display:block;font:9px ΢���ź�;color:gray;\">" + 
					 lunar.toString(3) + "</div>";
			tag += "<td align=center id=weekday" + x + " node=" + mday.getDate() + ">";
			if ((mday.getDate() == today.getDate()) && (mday.getFullYear() == today.getFullYear())
				&&(mday.getMonth() == today.getMonth()))	
				tag += "<b>" +  mday.getDate() + daytext + "</b></td>";
			else
				tag += mday.getDate() + daytext + "</td>";
					
			mday.setDate(mday.getDate() + 1);
			if (typeof lunar == "object")
				lunar.setLunar(mday);
			ww = mday.getDay();
		}
		if (ww > 0)
		{
			for (x = ww; x < 7; x++)
				tag += "<td id=weekday" + x + "></td>";
		}
		oDiv.innerHTML = "<table border=0 cellpadding=0 cellspacing=0 style=width:100%;height:100%;><tr><th id=week0>��</th><th id=week1>һ</th>" +
			"<th id=week2>��</th><th id=week3>��</th><th id=week4>��</th><th id=week5>��</th><th id=week6>��</th></th>" + tag + "</tr></table>";
		self.onReady();
	}

	function InitDate(d)
	{
		if (typeof d != "undefined")
			tday = d;
		if ((typeof tday == "string") && (tday != ""))
		{
			if ((cfg.dateType == 4) || (cfg.dateType == 5) || (cfg.dateType == 7))	//��ʱ�䣬�����ڵ�
				tday = "2017-8-16 " + d;
			tday = $.jcom.makeDateObj(tday);
		}
		if ((typeof tday != "object") || isNaN(tday) || (tday == null))
			tday = new Date();
		year = tday.getFullYear();
		month = tday.getMonth() + 1;
		day = tday.getDate();
		hour = tday.getHours();
		minute = tday.getMinutes();
		second = tday.getSeconds();
	}
	
	function setDateValue(value, nType, obj)
	{
		switch (nType)
		{
		case 1:		//��ݱ仯
			year = value;
			tday.setFullYear(year);
			break;
		case 2:		//�·ݱ仯
			month = value;
			tday.setMonth(month - 1);
			break;
		case 3:		//���ڱ仯
			day = value;
			tday.setDate(day);
			break;
		case 4:		//Сʱ�仯
			hour = value;
			tday.setHours(hour);
			break;
		case 5:		//���ӱ仯
			minute = value;
			tday.setMinutes(minute);
			break;
		case 6:		//��仯
			second = value;
			tday.setSeconds(second);
			break;
		}
		self.dateChange(tday, nType, obj);			
	}
	
	function ShowTitle(y, m, d, h, mm, s)
	{
		showTitleTag("#YearSpan", y, "��");
		showTitleTag("#MonthSpan", m, "��");
		showTitleTag("#DaySpan", d, "��");
		showTitleTag("#HourSpan", h, "ʱ");
		showTitleTag("#MinuteSpan", mm, "��");
		showTitleTag("#SecondSpan", s, "��");
	}
	
	function showTitleTag(tag, value, ex)
	{
		if ((value < 0) || (value == undefined))
			$(tag, domobj).css("display", "none");
		else
		{
			$(tag, domobj).css("display", "inline");
			$(tag, domobj).html(value + ex);
		}
	}
	
	function ClickTitle(event)
	{
		switch (event.target.id)
		{
		case "DecMonth":
			switch (mode)
			{
			case 0:
				setDateValue(month - 1, 2, event.target);
				break;
			case 1:
				setDateValue(year - 1, 1, event.target);
				break;
			case 2:
				setDateValue(year - 20, 1, event.target);
				break;
			default:
				mode = 0;
			}
//			oDiv.filters[0].Motion = "forward";
//			oDiv.filters[0].apply();
			self.show();
//			oDiv.filters[0].play();
			break;
		case "AddMonth":
			switch (mode)
			{
			case 0:
				setDateValue(month + 1, 2, event.target);
				break;
			case 1:
				setDateValue(year + 1, 1, event.target);
				break;
			case 2:
				setDateValue(year + 20, 1, event.target);
				break;
			default:
				mode = 0;
			}
//			oDiv.filters[0].Motion = "reverse";
//			oDiv.filters[0].apply();
			self.show();
//			ShowAll(mode);
//			oDiv.filters[0].play();
			break;
		case "MonthSpan":
			ShowAll(1);
			break;
		case "YearSpan":
			if (mode == 2)
				ShowAll(6);
			else
				ShowAll(2);
			break;
		case "DaySpan":
			ShowAll(0);
			break;
		case "HourSpan":
			ShowAll(3);
			break;
		case "MinuteSpan":
			ShowAll(4);
			break;
		case "SecondSpan":
			ShowAll(5);
			break;
		default:
			break;
		}
	}
	
	function ShowAll(m)
	{
		var tag, y;
		mode = m;
		switch (mode)
		{
		case 0:	//������
			showDate();
			return;
		case 1:	//�·�
			ShowTitle(year);
			tag = "<tr align=center><td>һ��</td><td>����</td><td>����</td><td>����</td></tr>" +
				"<tr align=center><td>����</td><td>����</td><td>����</td><td>����</td></tr>" +
				"<tr align=center><td>����</td><td>ʮ��</td><td>ʮһ��</td><td>ʮ����</td></tr>";
			break;
		case 2:	//���
			var y0 = year - year % 20;
			ShowTitle(y0 + "-" + (y0 + 19));
			for (tag = "", y = y0; y < y0 + 20; y += 4)
				tag += "<tr align=center><td>" + y + "</td><td>" + (y + 1) + "</td><td>" + (y + 2) + "</td><td>" + (y + 3) + "</td></tr>";
			break;
		case 3:		//Сʱ
			for (tag = "", y = 0; y < 24; y += 6)
				tag += "<tr align=center><td>" + y + "ʱ</td><td>" + (y + 1) + "ʱ</td><td>" + (y + 2) + "ʱ</td><td>" + (y + 3) + "ʱ</td><td>" + (y + 4) + "ʱ</td><td>" + (y + 5) + "ʱ</td></tr>";
			break;
		case 4:		//����
			for (tag = "", y = 0; y < 60; y += 10)
				tag += "<tr align=center><td>" + y + "��</td><td>" + (y + 1) + "��</td><td>" + (y + 2) + "��</td><td>" + (y + 3) + "��</td><td>" + (y + 4) + "��</td><td>" +
					(y + 5) + "��</td><td>" + (y + 6) + "��</td><td>" + (y + 7) + "��</td><td>" + (y + 8) + "��</td><td>" + (y + 9) + "��</td></tr>";
			break;
		case 5:		//��
			for (tag = "", y = 0; y < 60; y += 10)
				tag += "<tr align=center><td>" + y + "��</td><td>" + (y + 1) + "��</td><td>" + (y + 2) + "��</td><td>" + (y + 3) + "��</td><td>" + (y + 4) + "��</td><td>" +
					(y + 5) + "��</td><td>" + (y + 6) + "��</td><td>" + (y + 7) + "��</td><td>" + (y + 8) + "��</td><td>" + (y + 9) + "��</td></tr>";
			break;
		case 6:		//300��
			var y0 = 1840;
			ShowTitle(y0 + "-" + (y0 + 299));
			for (tag = "", y = y0; y < y0 + 300; y += 100)
				tag += "<tr align=center><td>" + y + "-<br> " + (y + 19) + "</td><td>" + (y + 20) + "-<br>" + (y + 39) + "</td><td>" + 
					(y + 40) + "-<br>" + (y + 59) + "</td><td>" + (y + 60) + "-<br>" + (y + 79) + "</td><td>" + (y + 80) + "-<br>" + (y + 99) + "</td></tr>";
			break;
		case 7:		//�򻯵�ʱ��
			var tag = "<tr align=center colspan=6><td>ѡ��Сʱ</td></tr>";
			for (y = 0; y < 24; y += 6)
				tag += "<tr align=center><td>" + y + "ʱ</td><td>" + (y + 1) + "ʱ</td><td>" + (y + 2) + "ʱ</td><td>" + (y + 3) + "ʱ</td><td>" + (y + 4) + "ʱ</td><td>" + (y + 5) + "ʱ</td></tr>";
			tag += "<tr align=center colspan=6><td>ѡ�����</td></tr>";
			tag += "<tr align=center><td>0��</td><td>5��</td><td>10��</td><td>15��</td><td>20��</td><td>25��</td></tr>";
			tag += "<tr align=center><td>30��</td><td>35��</td><td>40��</td><td>45��</td><td>50��</td><td>55��</td></tr>";
			break;			
		}
		oDiv.innerHTML = "<table border=0 cellpadding=0 cellspacing=0 style=width:100%;height:100%;>" + tag + "</table>";
//		for (var x = 0; x < oDiv.all.length; x++)
//			oDiv.all[x].UNSELECTABLE = "on";
	}
	
	function ClickTable(event)
	{
		var obj;
		if (event.target.tagName == "TD")
			 obj = event.target;
		if (event.target.parentNode.tagName == "TD") 
			obj = event.target.parentNode;
		if (typeof obj != "object")
			return;
		if ($(obj).attr("node") == "")
			return;
		switch (mode)
		{
		case 0:		//������
			setDateValue(parseInt($(obj).attr("node")), 3, obj);
			$("#DaySpan", domobj).html(day + "��");
			if ((cfg.dateType == 2) || (cfg.dateType == 3))
				ShowAll(3);
			if (cfg.dateType == 1)
				self.onDateComplete(tday);
			break;
		case 1:		//�·�
			setDateValue(obj.parentNode.rowIndex * 4 + obj.cellIndex + 1, 2, obj);
			if (cfg.dateType == 6)
				self.onDateComplete(tday);
			else
				self.show();
			break;
		case 2:		//���
			year = parseInt(obj.innerText);
			setDateValue(parseInt(obj.innerText), 1, obj);
			ShowAll(1);
			break;
		case 3:		//Сʱ
			setDateValue(parseInt($(obj).text()), 4, obj);
			$("#HourSpan", domobj).html(hour + "ʱ");
			if (cfg.dataType != 7)
				ShowAll(4);
			break;
		case 4:		//����
			setDateValue(parseInt($(obj).text()), 5, obj);
			$("#MinuteSpan", domobj).html(minute + "��");
			if ((cfg.dateType == 3) || (cfg.dateType == 5) || (cfg.dateType == 7))
				self.onDateComplete(tday);
			else
				ShowAll(5);
			break;
		case 5:		//��
			setDateValue(parseInt($(obj).text()), 6, obj);
			$("#SecondSpan", domobj).html(second + "��");
//			ShowAll(0);
			self.onDateComplete(tday);
			break;
		case 6:		//300��
			setDateValue(parseInt(obj.innerText), 1, obj);
			ShowAll(2);
			break;
		case 7:		//Сʱ�ͷ��ӵĺϲ�
			if (obj.innerText.indexOf("ʱ") > 0)
			{
				setDateValue(parseInt($(obj).text()), 4, obj);
				$("#HourSpan", domobj).html(hour + "ʱ");
			}
			else
			{
				setDateValue(parseInt($(obj).text()), 5, obj);
				$("#MinuteSpan", domobj).html(minute + "��");
			}
			var o = oSel.getObj();
			if (o != undefined)
				self.onDateComplete(tday);
			break;
		}
		oSel.show(obj);
	}
	
	function DblClickTable()
	{
		var obj = oSel.getObj();
		self.dblclickDate(tday, mode, obj);
	}
	
	this.dblclickDate = function (t, mode, obj)	//�¼�:˫������
	{};
	
	
	this.dateChange = function (t, nType, obj)	//�¼�:���������ڷ����仯 nType-> 1:��ݱ仯��2:�·ݱ仯, 3:���ڱ仯, 4:Сʱ�仯, 5:���ӱ仯, 6:��仯
	{};
	
	this.onReady = function ()		//�¼�:�����Ƽ�����ɺ���
	{};
	
	this.onDateComplete = function (t)	//�¼�:���ڸı���ɺ���
	{
	};
	
	this.setDateCellProp = function(d, item, value)		//����:�������ڵ�Ԫ�������
	{
		var o = this.getCellObject(d);
		if (o != null)
		{
			if (item.substr(0, 1) == ".")
				o.style.setAttribute(item.substr(1), value);
			else
				o.setAttribute(item, value);
		}
	};
	
	this.getDateCellProp = function(d, item)		//����:������ڵ�Ԫ�������
	{
		var o = this.getCellObject(d);
		if (o != null)
		{
			if (item.substr(0, 1) == ".")
				return o.style.getAttribute(item.substr(1));
			else
				return o.getAttribute(item);
		}
	};
	
	this.getCellObject = function(d)		//����:�������ڣ��õ���Ԫ��
	{
		if (typeof d == "string")
			d = $.jcom.makeDateObj(d);
		if ((typeof d != "object") || (d == null))
			return null;
		var oCells = $(oDiv).find("td");
		for (var x = 0; x < oCells.length; x++)
		{
			if (d.getDate() == $(oCells[x]).attr("node"))
				return oCells[x];
		}
		return null;
	};
		
	this.getDate = function()		//����:��ȡ��ǰ����
	{
		var obj = oSel.getObj();
		if (obj == undefined)
			return "";
		return tday;
	};
	
	this.getDateString = function()	//����:��ȡ��ǰ�����ַ���
	{
		switch (cfg.dateType)
		{
		case 1:		//������
			return $.jcom.GetDateTimeString(tday, 1);
		case 2:		//������ ʱ����
			return $.jcom.GetDateTimeString(tday, 15);
		case 3:		//������ʱ��
			return $.jcom.GetDateTimeString(tday, 3);
		case 4:		//ʱ����
			return $.jcom.GetDateTimeString(tday, 6);
		case 5:		//ʱ��
		case 7:		//�򻯵�ʱ��
			return $.jcom.GetDateTimeString(tday, 4);
		case 6:		//����
			return $.jcom.GetDateTimeString(tday, 5);
		}
	};
	
	this.selDateCell = function(d)		//����:ѡ��ǰ����
	{
		var o = this.getCellObject(d);
		if (o != null)
			oSel.show(o);
		else
			oSel.show();
	};

	function Init()
	{
		if (typeof domobj != "object")
			return;
		var pos = $.jcom.getObjPos(domobj);
		domobj.innerHTML = "<div align=center id=TitleDiv><span title=���� id=DecMonth>&#9668</span>&nbsp;" +
			"<span id=YearSpan style='color:#000;'></span><span id=MonthSpan style='color:#000;'></span>" +
			"<span id=DaySpan style='color:#000;'></span><span id=HourSpan style='color:#000;'></span>" +
			"<span id=MinuteSpan style='color:#000;'></span><span id=SecondSpan style='color:#000;'></span>" +
			"&nbsp;<span id=AddMonth title=ǰ��>&#9658</span></div><div style='margin-top:-20px;padding-top:20px;" +
			"overflow:hidden;height:" + (pos.height - 20) + "px;filter:progid:DXImageTransform.Microsoft.GradientWipe(GradientSize=0.00,wipestyle=0,motion=c)'></div>";
		oDiv = domobj.lastChild;
		$(oDiv).on("click", ClickTable);
		$(oDiv).on("dblclick", DblClickTable);
		$(domobj).children().first().on("click", ClickTitle);
		oSel = new $.jcom.CommonShadow(0, "#f4b77e");
	}
	cfg = $.jcom.initObjVal({lunarDis:false, dateType:1}, cfg);//dateType:=1 ������,=2 ������ ʱ����, =3 ������ʱ��, =4 ʱ���� , =5 ʱ��, =6����, =7�򻯵�ʱ��
	Init();
};

$.jcom.LunarDate = function(dateobj)//��:ũ��
{//������ת����ũ��
	if (typeof $.jcom.LunarDate.TermData == "undefined")
	{
		$.jcom.LunarDate.TermData = [0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989,
		    308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758];

		$.jcom.LunarDate.lunarInfo = [0x4bd8, 0x4ae0, 0xa570, 0x54d5, 0xd260, 0xd950, 0x5554, 0x56af,
			0x9ad0, 0x55d2, 0x4ae0, 0xa5b6, 0xa4d0, 0xd250, 0xd255, 0xb54f, 0xd6a0, 0xada2,
			0x95b0, 0x4977, 0x497f, 0xa4b0, 0xb4b5, 0x6a50, 0x6d40, 0xab54, 0x2b6f, 0x9570,
			0x52f2, 0x4970, 0x6566, 0xd4a0, 0xea50, 0x6a95, 0x5adf, 0x2b60, 0x86e3, 0x92ef,
			0xc8d7, 0xc95f, 0xd4a0, 0xd8a6, 0xb55f, 0x56a0, 0xa5b4, 0x25df, 0x92d0, 0xd2b2,
			0xa950, 0xb557, 0x6ca0, 0xb550, 0x5355, 0x4daf, 0xa5b0, 0x4573, 0x52bf, 0xa9a8,
			0xe950, 0x6aa0, 0xaea6, 0xab50, 0x4b60, 0xaae4, 0xa570, 0x5260, 0xf263, 0xd950,
			0x5b57, 0x56a0, 0x96d0, 0x4dd5, 0x4ad0, 0xa4d0, 0xd4d4, 0xd250, 0xd558, 0xb540,
			0xb6a0, 0x95a6, 0x95bf, 0x49b0, 0xa974, 0xa4b0, 0xb27a, 0x6a50, 0x6d40, 0xaf46,
			0xab60, 0x9570, 0x4af5, 0x4970, 0x64b0, 0x74a3, 0xea50, 0x6b58, 0x5ac0, 0xab60,
			0x96d5, 0x92e0, 0xc960, 0xd954, 0xd4a0, 0xda50, 0x7552, 0x56a0, 0xabb7, 0x25d0,
			0x92d0, 0xcab5, 0xa950, 0xb4a0, 0xbaa4, 0xad50, 0x55d9, 0x4ba0, 0xa5b0, 0x5176,
			0x52bf, 0xa930, 0x7954, 0x6aa0, 0xad50, 0x5b52, 0x4b60, 0xa6e6, 0xa4e0, 0xd260, 
			0xea65, 0xd530, 0x5aa0, 0x76a3, 0x96d0, 0x4afb, 0x4ad0, 0xa4d0, 0xd0b6, 0xd25f,
			0xd520, 0xdd45, 0xb5a0, 0x56d0, 0x55b2, 0x49b0, 0xa577, 0xa4b0, 0xaa50, 0xb255,
			0x6d2f, 0xada0, 0x4b63, 0x937f, 0x49f8, 0x4970, 0x64b0, 0x68a6, 0xea5f, 0x6b20,
			0xa6c4, 0xaaef, 0x92e0, 0xd2e3, 0xc960, 0xd557, 0xd4a0, 0xda50, 0x5d55, 0x56a0,
			0xa6d0, 0x55d4, 0x52d0, 0xa9b8, 0xa950, 0xb4a0, 0xb6a6, 0xad50, 0x55a0, 0xaba4,
			0xa5b0, 0x52b0, 0xb273, 0x6930, 0x7337, 0x6aa0, 0xad50, 0x4b55, 0x4b6f, 0xa570,
			0x54e4, 0xd260, 0xe968, 0xd520, 0xdaa0, 0x6aa6, 0x56df, 0x4ae0, 0xa9d4, 0xa4d0, 
			0xd150, 0xf252, 0xd520];

		$.jcom.LunarDate.chMonth = "�������������߰˾�ʮ����";
		$.jcom.LunarDate.chDate = "��һ�����������ĳ���������߳��˳��ų�ʮʮһʮ��ʮ��ʮ��ʮ��ʮ��ʮ��ʮ��ʮ�Ŷ�ʮإһإ��إ��إ��إ��إ��إ��إ��إ����ʮ";
		$.jcom.LunarDate.TianGan = "���ұ����켺�����ɹ�";
		$.jcom.LunarDate.DiZhi = "�ӳ���î������δ�����纥";
		$.jcom.LunarDate.Animals = "��ţ������������Ｆ����";
		$.jcom.LunarDate.TermName = "С����������ˮ���ݴ���������������С��â������С��������ﴦ���¶��ֺ�¶˪������Сѩ��ѩ����";
	}
	var year, month, isLeap, day, term, sterm;

	function lYearDays(y)	//����ũ�� y���������
	{  
		var sum = 348;
		for (var x = 0x8000; x > 0x8; x >>= 1) 
			sum += ($.jcom.LunarDate.lunarInfo[y - 1900] & x) ? 1: 0;
 		return sum + leapDays(y);
	}

	function leapDays(y)	//����ũ�� y�����µ�����
	{
		if (leapMonth(y) == 0)
			return 0;
		return (($.jcom.LunarDate.lunarInfo[y - 1899] & 0xf) == 0xf) ? 30 : 29;
	}



	function leapMonth(y)	//����ũ�� y�����ĸ��� 1-12 , û�򴫻� 0
	{
		var rtn = $.jcom.LunarDate.lunarInfo[y - 1900] & 15;
		if (rtn == 15)
			return 0;
		return rtn;
	}

	function monthDays(y, m)	//����ũ�� y��m�µ�������
	{
		return ($.jcom.LunarDate.lunarInfo[y - 1900] & (0x10000 >> m)) ? 30: 29;
	}

	function toDate(dt)
	{
		if (typeof dt == "object")
			return dt;
		if (typeof dt == "string")
		{
			var ss = dt.split("-");
			if (ss.length > 2)
				return new Date(ss[0], parseInt(ss[1]) - 1, ss[2]);
		}
		return new Date();
	}

	this.setLunar = function(dt)		//����:��������
	{
		var leap = 0, temp, x;
		dt = toDate(dt);
//	   	if ((dt.getFullYear() < 1900) || (dt.getFullYear() > 2100))
//			return;
		var baseDate = new Date(1900,0,31);
		var offset = parseInt((dt - baseDate) / 86400000);	//24*3600*1000 = 86400000

//		this.dayCyl = offset + 40;
		var monCyl = 14;
		dateobj = dt;

		for (var x = 1900; x < 2100 && offset > 0; x ++)
		{
			temp = lYearDays(x);
			offset -= temp;
			monCyl += 12;
		}
		if (offset < 0)
		{
		 	offset += temp;
			x --;
			monCyl -= 12;
		}
		year = x;
//		this.yearCyl = x - 1864;

	   leap = leapMonth(x); //���ĸ���
	   isLeap = false;

		for (x = 1; x < 13 && offset > 0; x ++)
		{	//����
			if (leap > 0 && x == (leap + 1) && isLeap == false)
			{
				x --;
				isLeap = true;
				temp = leapDays(year);
			}
			else
				temp = monthDays(year, x);

			//�������
			if (isLeap == true && x == (leap + 1))
				isLeap = false;

			offset -= temp;
		}

 		if (offset == 0 && leap > 0 && x == leap + 1)
 		{
      		if(isLeap)
				isLeap = false;
			else
			{
				isLeap = true;
				x --;
			}
		}
		if (offset < 0)
		{
			offset += temp;
			x --;
		}

		month = x;
		day = offset + 1;
		term = 0;
		sterm = "";
		offset = dateobj.getMonth() * 2;
		for (x = offset; x < offset + 2; x++)
		{
			temp = (31556925974.7 * (dateobj.getFullYear() - 1900) + $.jcom.LunarDate.TermData[x] * 60000);
			baseDate = new Date(1900, 0, 6, 2, 5);
			baseDate.setTime(baseDate.getTime() + temp);
			if (baseDate.getDate() == dateobj.getDate())
			{
				term = x + 1;
				sterm = $.jcom.LunarDate.TermName.substring(x * 2, term * 2);
				break;
			}
		}
	};

	this.toString = function (nType)		//����:�õ���ͬ��ʽ��ũ��
	{
		if ((dateobj.getFullYear() < 1900) || (dateobj.getFullYear() > 2100))
			return "";
		switch (nType)
		{
		case 1:			//������
			return $.jcom.LunarDate.TianGan.substring((year - 1864) % 10, (year - 1864) % 10 + 1) + 
				$.jcom.LunarDate.DiZhi.substring((year - 1864) % 12, (year - 1864) % 12 + 1) +
				"�� " + $.jcom.LunarDate.chMonth.substring(month - 1, month) + "�� " +
				$.jcom.LunarDate.chDate.substring(day * 2 - 2, day * 2);
		case 2:			//����
			return $.jcom.LunarDate.chMonth.substring(month - 1, month) + "�� " +
				$.jcom.LunarDate.chDate.substring(day * 2 - 2, day * 2);
		case 3:			//(����/��/��)
			if (sterm != "")
				return sterm;
			if (day == 1)
				return $.jcom.LunarDate.chMonth.substring(month - 1, month) + "��";
			return $.jcom.LunarDate.chDate.substring(day * 2 - 2, day * 2);
		default:		//�� ���� �� �� ����
			return $.jcom.LunarDate.TianGan.substring((year - 1864) % 10, (year - 1864) % 10 + 1) + 
				$.jcom.LunarDate.DiZhi.substring((year - 1864) % 12, (year - 1864) % 12 + 1) +
				"�� ����:" + $.jcom.LunarDate.Animals.substring((year - 1864) % 12, (year - 1864) % 12 + 1) +
				" " + $.jcom.LunarDate.chMonth.substring(month - 1, month) + "�� " +
				$.jcom.LunarDate.chDate.substring(day * 2 - 2, day * 2) + sterm;
		}
	};
	this.setLunar(dateobj);
};


$.jcom.PageFoot = function(domobj, info, cfg)		//��:��ҳ����
{
	var self = this;
	function getfoot()
	{
		if (cfg.footstyle > 3)
			return "";
		var nPages = parseInt((info.Records + info.PageSize - 1)/ info.PageSize);
		info.PageCount = nPages;
		if ((nPages <= 1) && (cfg.footstyle != 1))
			return "<div style=clear:both;>&nbsp;��" + info.Records + "��</div>";
		var d1 = "", d2 = "";		
		switch (cfg.footstyle)
		{
		case 0:			//������ҳ��,ҳ����Ϣ�ͷ�ҳ
			d1 = getPagesInfo(nPages);
			d2 = getPagesSpan(nPages);
			break;
		case 1:			//û��ҳ����Ϣ���з�ҳ
			d2 = getPagesSpan(nPages);
			break;
		case 2:			//��ҳ����Ϣ��û�з�ҳ
			d1 = getPagesInfo(nPages);
			break;
		}
		return "<div style=float:left;clear:both;>" + d1 + "</div><div style=float:right>" + d2 + "</div>";
	}

	function getPagesInfo(nPages)
	{
		var tag = "<span style=width:40px;overflow:hidden><select id=PageFootSel style=width:60px;border:0px none;margin:-2px;'>";
		for (var x = 1; x <= nPages; x++)
		{
			if (x == info.nPage)
				tag += "<option value=" + x + " selected>" + x + "</option>";
			else
				tag += "<option value=" + x + ">" + x + "</option>";
		}
		tag += "</select></span>";
		return "&nbsp;ҳ�Σ�" + tag + "&nbsp;ÿҳ" + info.PageSize + "������" + nPages + "ҳ��" + info.Records + "��";
	}
	
	function getPagesSpan(nPages)
	{
		var nStart = info.nPage - 5;
		if (nStart < 1)
			nStart = 1;
		var nEnd = nStart + 9;
		if (nEnd > nPages)
		{
			nEnd = nPages;
			nStart = nEnd - 9;
			if (nStart < 1)
				nStart = 1;
		}
		
		var tag = "";
		for (x = nStart; x <= nEnd; x++)
		{
			if (x == info.nPage)
				tag += "<span class=PageSpan style='cursor:default;color:gray;border:1px solid transparent;'>" + x + "</span>";
			else
				tag += "<span class=PageSpan style='cursor:hand;' node=" + x + ">" + x + "</span>";
		}
		if (info.nPage > 1)
			tag = "<span class=PageSpan node=" + (info.nPage - 1) + ">&#9668</span>" + tag;
		if (info.nPage < nPages)
			tag += "<span class=PageSpan node=" + (info.nPage + 1) + ">&#9658</span>";
		if (nStart > 1)
			tag = "<span class=PageSpan node=1>&#9194</span>" + tag;
		if (nEnd < nPages)
			tag += "<span class=PageSpan node=" + nPages + ">&#9193</span>";
		return "<span id=PageSkip>" + tag + "</span>";		
	}
	
	function clickFoot(e)
	{
		if ((e.target.tagName == "SELECT") && (e.type == "change"))
			return self.skip(e.target.value);
		if ((typeof $(e.target).attr("node") != "undefined") && (e.type == "click"))
			self.skip($(e.target).attr("node"));
	}
	
	this.reload = function (i, c)		//����:���¼���
	{
		if ((typeof i == "string") && (c == undefined))
		{
			$(domobj).html(i);
			return;
		}
		
		$("#PageFootSel", domobj).off("change", clickFoot);
		if (typeof i == "object")
			info = i;
		if (typeof c == "object")
			cfg = $.jcom.initObjVal(cfg, c);
		$(domobj).html(getfoot());
		$("#PageFootSel", domobj).on("change", clickFoot);
	};
	
	this.skip = function (page)		//�¼�:��ҳ
	{};
	
	this.setDomObj = function(obj)		//����:����������������
	{
		if (typeof domobj == "object")
			$(domobj).off("click", clickFoot);
		domobj = obj;
		if (obj == undefined)
			return;
		this.reload();
		$(domobj).on("click", clickFoot);	//�п��ܶ���Ϊ�գ�û�з�ҳ
		
	};
	
	this.footinfo = function (i)		//����:��ȡ������ҳ�����ݶ���
	{
		info = $.jcom.initObjVal(info, i);
		return info;
	};
	
	cfg = $.jcom.initObjVal({footstyle:0}, cfg);
	info = $.jcom.initObjVal({nPage:1, PageSize:100, PageCount:1, Records:0, Order:"", bdesc:0}, info);
	if (info.PageSize <= 0)
		info.PageSize = 100;
	this.setDomObj(domobj);
};

$.jcom.GridHead = function(domobj, head, cfg)		//��:�б�ͷ//,�������Ʊ�ͷ����ͷ�����������ݱ�ͷ����Ա����������ת��
{
	var self = this;
	var headmenu, headtdtmp;
	var dragobj, dragindex, dragdelta, evtobj, dragparam;
	var quirks = 0;
	var thumbPattern;
	function showheadmenu(event)
	{
		if ((cfg.headstyle != 1) || (event.shiftKey))
			return;
		if (typeof headmenu != "object")
		{
			var menudef = [{item:"��С��������", img:"<span>��</span>", action:selorder, node:0},{item:"�Ӵ�С����", img:"<span>��</span>", action:selorder, node:1}, {}];
			for (var x = 0; x < head.length; x++)
			{
				menudef[x + 3] = {};
				menudef[x + 3].item = head[x].TitleName;
				menudef[x + 3].img = "<input type=checkbox";
				if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7) || (head[x].nShowMode == 9))
					menudef[x + 3].img += " checked";
				menudef[x + 3].img += ">";
				menudef[x + 3].action = hidecol;
				menudef[x + 3].FieldName = head[x].FieldName;
			}
			headmenu = new $.jcom.CommonMenu(menudef);
		}
		headtdtmp = $.jcom.findParentObj(window.event.srcElement, domobj, "TD");
		headmenu.show();
		return false;
	}

	function rollHead(e)
	{
		var o = e.target;
		if (o.tagName == "TD")
		{
			var pos = $.jcom.getObjPos(o);
			if (e.clientX >= pos.right - 2)
				o.style.cursor = "col-resize";
			else
				o.style.cursor = "default";
			if ((o.firstChild != null) && (o.firstChild.nodeType == 1))
			{
				if (o.firstChild.scrollWidth > o.firstChild.offsetWidth)
					o.title = o.firstChild.innerText;
				else
					o.removeAttribute("title");
			}
		}
		else
			o.style.cursor = "default";
	}
	
	function downHead(e)
	{
		evtobj = e.target;
		if (e.shiftKey && e.ctrlKey)
			return SetupHead();
		if (e.target.style.cursor != "col-resize")
		{
			if (e.target.parentNode.parentNode.id == "HeadTR")
			{
				if ((e.shiftKey == false) && (self.headItem(e.target.parentNode.id) >= 0))
				{
					dragdelta = 0;
					$(document.body).on("mousedown", disevent);
					$(document).on("mousemove", draghead);
					$(document).on("mouseup", dragheadend);
				}
			}
			return;
		}
		dragindex = evtobj.cellIndex;
//		if ((quirks == 1) && (evtobj.parentNode.id != "HeadTR"))
//			dragindex = gridhead.headItem(evtobj.id.substr(0, evtobj.id.length - 3));
		var pos = $.jcom.getObjPos(domobj);
		var h = pos.bottom - pos.top;
		if (cfg.footstyle > 0)
			h -= 25;
//		dragobj = document.createElement("<div style=position:absolute;width:1px;background-color:gray;overflow:hidden;left:" +
//			event.clientX + ";top:" + pos.top + ";height:" + h + ";cursor:col-resize></div>");
		dragobj = document.createElement("div");
		$(dragobj).css({position: "absolute", backgroundColor:"gray", overflow: "hidden", left: event.clientX + "px", top: pos.top + "px", width: "1px", height: h + "px", cursor: "col-resize"});
//		dragobj.setCapture();
		$(document.body).append(dragobj);
		$(document.body).on("mousedown", disevent);
		$(document).on("mousemove", splitting);
		$(document).on("mouseup", splitend);
	}
	
	function click(e)
	{
		self.clickHead(e);
	}
	
	function SetupHead()
	{	
		$.jcom.OptionWin("<textarea id=SetupHeadInput style='width:640px;height:300px'></textarea>", "������(FieldProp)-�ɸ��Ƶ�[��ͼ.����.�ֶη��������]����",
			[{item:"��ȡ", action:RunSetupHead},{item:"Ӧ��", action:RunSetupHead}], {width:680, height:400});
		getFieldProp(1);
		return false;
	}
	
	function getFieldProp(mode)
	{
		var tag = "";
		for (var x = 0; x < head.length; x++)
		{
			if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7) || (head[x].nShowMode == 9))
			{
				if (tag != "")
					tag += ",\n";
				tag += head[x].FieldName + ":{width:";
				if (mode == 1)
					tag += head[x].FieldProp.width;
				else
					tag += ($("#" + head[x].FieldName).width() - 4);
				tag += ", style:\"" + head[x].FieldProp.style + "\", tagName:\"" + head[x].FieldProp.tagName +
					"\", LineNo:" + head[x].FieldProp.LineNo + "}";
			}
		}
		$("#SetupHeadInput").val("{\n" + tag + "\n}");
	}
	
	function RunSetupHead()
	{
		var text = $("#SetupHeadInput").val();
		var o = $.jcom.eval(text);
		if (typeof o != "object")
			return alert(o);
		for (var key in o)
		{
			var index = self.headItem(key);
			if (index >= 0)
			{
				head[index].FieldProp.width = o[key].width + 4;
				head[index].FieldProp.style = o[key].style;
				head[index].FieldProp.tagName = o[key].tagName;
				head[index].FieldProp.LineNo = o[key].LineNo;
			}
		}
		self.reload(head);
		self.HeadChange(head);		
	}
	
	function disevent(e)
	{
		return false;
	}
	
	function draghead(e)
	{
		if ((dragdelta < 5) && (typeof dragobj != "object"))
		{
			dragdelta ++;
			return false;
		}
		if (typeof dragobj != "object")
		{
			var pos = $.jcom.getObjPos(evtobj.parentNode);
//			dragobj = document.createElement("<div align=center style='position:absolute;background-color:#78BCED;color:white;padding:0px;margin:0px;width:" +
//				(pos.right - pos.left) + "px;height:" + (pos.bottom - pos.top + 8) + "px;top:" +
//				pos.top + "px;left:" + pos.left + "px;overflow:hidden;border:1px solid gray;'></div>");
			dragobj = document.createElement("div");
			document.body.insertBefore(dragobj);
			$(dragobj).css({position:"absolute", backgroundColor:"#78BCED", color:"white", padding:"0px", margin:"0px",
				width: (pos.right - pos.left) + "px", height: (pos.bottom - pos.top) + "px", 
				top: pos.top + "px", left:pos.left + "px", overflow:"hidden", border: "1px solid gray"});
			dragobj.align = "center";
			dragobj.innerText = evtobj.innerText;
			dragdelta = e.clientX - pos.left;
			dragindex = evtobj.parentNode.cellIndex;
			dragobj.setCapture();
			evtobj = undefined;
		}
		dragobj.style.left = (e.clientX - dragdelta) + "px";
		var tr = $("#HeadTR", domobj)[0];
		var h = $("#FieldsHead", domobj)[0];
		for (var x = 0; x < tr.cells.length; x++)
		{
			if ((x < tr.cells.length - 1) && (self.headItem(h.rows[0].cells[x].id) < 0))
				continue;
			var pos = $.jcom.getObjPos(tr.cells[x]);
			if ((e.clientX - dragdelta > pos.left) && (e.clientX - dragdelta < pos.right))
			{
				if (typeof evtobj != "object")
				{
					var p = $.jcom.getObjPos(domobj);
//					evtobj = document.createElement("<div style='position:absolute;width:1px;background-color:green;top:" +
//						p.top + "px;height:" + (p.bottom - p.top - 25) + "px;overflow:hidden;'></div>");
					evtobj = document.createElement("div");
					$(evtobj).css({position:"absolute", width:"3px", backgroundColor:"green", top: p.top + "px",
						height:(p.bottom - p.top) + "px", overflow:"hidden"});
					document.body.insertBefore(evtobj);
				}
				evtobj.style.left = pos.left + "px";
				dragparam = x;
				break;
			}
		}
	}
	
	function dragheadend()
	{
		$(document.body).off("mousedown", disevent);
		$(document).off("mousemove", draghead);
		$(document).off("mouseup", dragheadend);
//		document.releaseCapture();
		if (typeof dragobj != "object")
			return;
		$(dragobj).remove();
		dragobj = undefined;
		$(evtobj).remove();
		evtobj = undefined;

		if (dragparam == dragindex)
			return;
		var h = $("#FieldsHead", domobj)[0];
		var dndx = self.headItem(h.rows[0].cells[dragparam].id);
		var sndx = self.headItem(h.rows[0].cells[dragindex].id);
		if (dndx < 0)
		{
			var item = head.splice(sndx, 1);
			head[head.length] = item[0];
		}
		else
		{
			var item = head.splice(sndx, 1);
			if (sndx < dndx)
				dndx --;
			head.splice(dndx, 0, item[0]);
		}
		if (dragparam < dragindex)
			dragindex ++;
		h.rows[0].insertCell(dragparam);
		h.rows[0].cells[dragparam].replaceNode(h.rows[0].cells[dragindex]);
//		if (quirks == 0)
//		{
//			for (var x = 0; x < domobj.all.BodyTable.rows.length; x++)
//			{
//				domobj.all.BodyTable.rows[x].insertCell(dragparam);
//				domobj.all.BodyTable.rows[x].cells[dragparam].replaceNode(domobj.all.BodyTable.rows[x].cells[dragindex]);
//			}
//		}
//		else
//			self.reload(data);
//		onScroll();		
		self.HeadChange(head);
	}

	function splitting(event)
	{
		dragobj.style.left = event.clientX - 2 + "px";
		var pos = $.jcom.getObjPos($(domobj).find("#FieldsHead")[0].rows[0].cells[dragindex]);
		var w = event.clientX - pos.left - 3;
		if (w < 2)
			w = 2;
		$(domobj).find("#FieldsHead")[0].rows[0].cells[dragindex].firstChild.style.width = w + "px";
//		self.headItem($(domobj).find("#FieldsHead tr td:eq("+ dragindex +")")[0].id, "nWidth", w);
		var x = self.headItem($("#FieldsHead tr td:eq("+ dragindex + ")", domobj)[0].id);
		head[x].FieldProp.width = w;
		return false;
	}

	function splitend(event)
	{
		$(document.body).off("mousedown", disevent);
		$(document).off("mousemove", splitting);
		$(document).off("mouseup", splitend);
		document.releaseCapture();
		$(dragobj).remove();
		dragobj = undefined;
//		if (quirks == 0)
//		{
//			for (var x = 0; x < $(domobj).find("#BodyTable")[0].rows.length; x++)
//				$(domobj).find("#BodyTable")[0].rows[x].cells[dragindex].firstChild.style.width = w + "px";
//		}
//		else
//			self.reload(data);
//		onScroll();
		self.HeadChange(head);
	}
	
	function hidecol(obj, item)
	{
		var index = self.headItem(item.FieldName);
		if (head[index].nShowMode == 1)
		{
			item.img = "<input type=checkbox>";
			head[index].nShowMode = 3;
		}
		else
		{
			item.img = "<input type=checkbox checked>";
			head[index].nShowMode = 1;
		}
		self.HeadChange(head);
	}
	
	function selorder(obj, item)
	{
		if (typeof headtdtmp != "object")
			return;
		self.orderField(headtdtmp.id, item.node);
	}
	
	function getTreeTagValue(value, depth, item)
	{
		var index = 0;
		if (depth >= cfg.initDepth - 1)
			index = 1;
		var style = "";
		if (typeof item.child != "object")
			style= " style=visibility:hidden;";
		var img = $.jcom.getItemImg(item.img, 0,0, 0, "&nbsp;");
		var ex = "<img id=BtExTree ex=" + index + " unloadflag=" + index + " src=" + cfg.expic[index] + style + ">&nbsp;";
		if (cfg.expic[0].substr(0, 1) == ".")
			ex = "<span id=BtExTree ex=" + index + " unloadflag=" + index + " class=" + cfg.expic[index].substr(1) + style + "></span>";
		if (typeof value != "object")
			return ex + img + "<span style='height:100%;width:100%;'>" + value + "</span>";
		var v = $.jcom.initObjVal(value, {});
		v.value = ex + img + "<span style='height:100%;width:100%;'>" + v.value + "</span>";	//��width:100%,�����̬�༭������Ч������
		return v;
//				return ex + img + "<span style='height:100%;width:100%;'>" + value.value + "</span>";	//��width:100%,�����̬�༭������Ч������
	}

	this.setHeadOrder = function(orderField, bDesc)	//����:���ñ�ͷ�ֶε�����ʽ
	{
		for (var x = 0; x < head.length; x++)
		{
			if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7) || (head[x].nShowMode == 9))
			{
				if (cfg.gridstyle == 4)
					var o = $("#" + head[x].FieldName, domobj);
				else
					var o = $("#" + head[x].FieldName + " div", domobj);
				if (head[x].FieldName == orderField)
				{
					if (bDesc == 1)
						o.html(head[x].TitleName + "��");
					else
						o.html(head[x].TitleName + "��");
					head[x].bDesc = bDesc;
				}
				else
				{
					o.html(head[x].TitleName);
					delete head[x].bDesc;
				}
			}
		}
	};
	
	this.clickHead = function (e)		//�¼�:��������ʱ������Ĭ��Ϊ����������
	{
		if (e.target == $("#HeadSelBox", domobj)[0])
			return self.selAllLine(e);
		var f = e.target.id;
		var index = self.headItem(f);
		if (index == -1)
		{
			var td = $.jcom.findParentObj(e.target, domobj, "TD");
			if (td == undefined)
				return;
			f = td.id;
			index = self.headItem(f);
			if (index == -1)
				return;
		}
		if (head[index].bDesc == undefined)
			var bDesc = 0;
		else
			var bDesc = head[index].bDesc ^ 1;
		if (self.orderField(f, bDesc))
			self.setHeadOrder(f, bDesc);
	};
	
	this.orderField = function (field, desc)	//�¼�:����
	{
		return false;
	};
	
	this.dblclickHead = function (td) 		//����:˫������ʱ����
	{};
	
	this.reload = function (h)		//����:���¼���
	{
		if (typeof h == "object")
			head = h;
		if (typeof head != "object")
			return;
		for (var x = 0; x < head.length; x++)
		{
			head[x] = $.jcom.initObjVal({FieldName:"", TitleName:"", nWidth:0, nShowMode:1, bTag:0, Quote:"", FieldType:1, bPrimaryKey:0, bSeek:0,FieldProp:{}}, head[x]);
			head[x].FieldProp = $.jcom.initObjVal({width:head[x].nWidth, style:"", tagName:"span", LineNo:1}, head[x].FieldProp);
			if ((head[x].FieldProp.width == 0) && (cfg.gridstyle < 3))
				head[x].FieldProp.width = 100;
		}
		var tag = "";
		if ((cfg.ThumbNail != "") && (cfg.gridstyle > 2))
		{
			$(domobj).html(cfg.ThumbNail);
			for (var x = 0; x < head.length; x++)
				$("#" + head[x].FieldName, domobj).html(head[x].TitleName);
			$("[name='thumbdiv']", domobj).addClass("ThumbHead");
			return;
		}
		if (cfg.gridstyle == 4)
		{
			var o = self.getLine(0, 0, 4);
			if (typeof o == "string")
				tag += o;
			else
				tag += o.tds;
			tag = "<div id=FieldsHead style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;'>" + tag + "</div>";
		}
		else
		{
			for (var x = 0; x < head.length; x++)
			{
				if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7) || (head[x].nShowMode == 9))
				{
					tag += "<td style='padding:0px;' nowrap id=" + head[x].FieldName + "><div style='overflow:hidden;padding:2px;width:" + head[x].FieldProp.width + "px;'>" + head[x].TitleName + "</div></td>";
				}
			}
			var t1 = "<table id=FieldsHead cellpadding=0 cellspacing=0 border=0 class=gridhead><tr id=HeadTR>";
//			var t1 = "<table id=FieldsHead cellpadding=0 cellspacing=0 border=1 style='border-collapse:collapse;border:none;'><tr id=HeadTR>";
		
			if (cfg.bodystyle == 2)
				t1 += "<td style=padding:0px><div style=width:20px><input id=HeadSelBox type=checkbox></div></td>";
			tag = t1 + tag + "</tr></table>";
		}
		$(domobj).html(tag);
	};

	this.getHeadLineTag = function()	//����:�õ������HTML����
	{
		var tag = "<thead><tr id=SeekTitleTR>"; 
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].nShowMode == 1)
				tag += "<td id=" + head[x].FieldName + " align=center width=" + head[x].FieldProp.width + ">" + head[x].TitleName + "</td>";
		}
		return tag + "</tr></thead>";
	};

	this.selAllLine = function(e)	//�¼�:ѡ�������е���
	{
		var value = $("#HeadSelBox", domobj).prop("checked");
		var o = domobj.parentNode;
		$("input[name='LineSelBox']", o).prop("checked", value);		
	};

	this.HeadChange = function(head) //�¼�:��ͷ�����˸ı�
	{};
	
	this.getHead = function (index)		//����:���ر�ͷ��������
	{
		if (index == undefined)
			return head;
		if (typeof index == "Number")
			return head[index];
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].FieldName == index)
				return head[x];
		}
	};

	this.headItem = function(name, prop, value)	//����:���ñ�ͷ���ݶ����ֵ
	{
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].FieldName == name)
			{
				if (typeof prop != "undefined")
					head[x][prop] = value;
				return x;
			}
		}
		return -1;
	};

	this.getItemValue = function(item, field)	//����:�õ�����ת����ֵ
	{
		if (typeof field != "object")
			field = self.getHead(field);
		var v = item[field.FieldName];
		if (v === null)
			v = "";
		if (typeof v == "object")
			var value = v.value;
		else
			var value = v;
		if ((cfg.transText > 0) && (typeof item[field.FieldName + "_ex"] != "undefined"))
		{
			if (cfg.transText == 1)
				value = item[field.FieldName + "_ex"];
			else
				value = value + ":" + item[field.FieldName + "_ex"];
		}
		var exp = field.Quote;
		if (typeof exp == "function")
			value = exp(value);
		else if ((value == null) || (value == undefined))
			value = undefined;
		else if ((typeof exp == "string") && (exp != "") && (value !== ""))
		{
			switch (exp.substr(0, 1))
			{
			case "&":
				if (exp.substr(1, 1) == "d")
				{
					var d = $.jcom.makeDateObj(value);
					if (d != null)
						value = $.jcom.GetDateTimeString(d, parseInt(exp.substr(3,1)));
				}
				break;
			case "(":
				exp = exp.substr(1, exp.length - 2);
			default:
				var ss = exp.split(",");
				for (var x = 0; x < ss.length; x++)
				{
					var sss = ss[x].split(":");
					if (value == sss[0])
					{
						value = sss[1];
						break;
					}
				}
			}
		}
		return value;
	};
	
	this.getFieldValue = function(item, index)	//����:�õ���ѡ�ֶζ����ֵ
	{
		var value = self.getItemValue(item, head[index]);
		var v = item[head[index].FieldName];
		if (v === null)
			v = "";
		if (typeof v == "object")
			v.value = value;
		else
			v = value;
		return v;
	};
	
	this.getFieldCell = function (value, x, gridstyle, color, nowrap, tdcss, divstyle, delwidth)	//����:�õ��ֶεĵ�Ԫ���HTMLֵ
	{
		if ((typeof value == "undefined") || (value == null))
		{
			if (quirks == 1)
				return "";
			value = "";
		}
		var align = "";
		if (typeof head[x].align == "string")
			align = "align='" + head[x].align + "'";
		var width = head[x].FieldProp.width;
		if (typeof delwidth == "number")
			width -= delwidth;
		var sontag = "div", prop = "";//, height = "";
		if (typeof value == "object")
		{
			var o = $.jcom.initObjVal(value, {});
			o = $.jcom.initObjVal({value:"", colspan:1, rowspan:1, tdstyle:tdcss, style:"", prop:"", sontag:sontag, color:color}, o);
			var tag = "<td " + align + nowrap + " colspan=" + o.colspan + " rowspan=" + o.rowspan;
			tag += " id=" + head[x].FieldName + "_TD";
			if (o.tdstyle != "")
				tag += " style='" + o.tdstyle;
			else
				tag += " style='padding:0px;" + tdcss;
			if ((o.colspan > 1) || (o.rowspan > 1))
				quirks = 1;
			if (o.colspan > 1)
			{
				var z = 1;
				for (var y = x + 1; y < head.length; y++)
				{
					if (z >= o.colspan)
						break;
					if ((head[y].nShowMode == 1) ||(head[y].nShowMode == 7) || (head[y].nShowMode == 9))
					{
						width += head[y].FieldProp.width;
						z++;
					}
				}
			}
			divstyle += o.style;
			prop = o.prop;
			color = o.color;
			sontag = o.sontag;
			height = o.height;
			value = o.value;
		}
		else
			var tag = "<td id=" + head[x].FieldName + "_TD " + align + nowrap + " style='padding:0px;" + tdcss;
		switch (gridstyle)
		{
		case 1:		//�ʺ���Ļ����ı༭��ʽ
			if ((sontag == "") || (typeof sontag != "string"))
				return tag + ";padding:2px;width:" + (width - 4) + "px;color:" + color + ";" + divstyle +
					";" + head[x].FieldProp.style + "'" + prop + ">" + value + "</td>";

			return tag + "'><" + sontag + " style=\"padding:2px;width:" + width + "px;color:" +
				color + ";" + divstyle + ";" + head[x].FieldProp.style + "\"" + prop + ">" + value + "</" + sontag + "></td>";
		case 2:		//�ʺϴ�ӡ������Ķ���ʽ
			return tag + "' width=" + width + ">" + value + "</td>";
		case 3:
			return value;
		case 4:		//��ʹ��Table,��div��span
			if (width < 10)
				width = "";
			else
				width = "width:" + width + "px;"
			return "<" + head[x].FieldProp.tagName + " id=" + head[x].FieldName + " style='" + width +
				head[x].FieldProp.style + "'>" + value + "</" + head[x].FieldProp.tagName + ">";
		}
	};

	this.getLine = function(items, index, gridstyle, depth, fg, nowrap, tdcss, divcss)	//����:���һ�е�����
	{
		var divstyle = "", tds = "", hint = "";
		var treeflag = 0;
		var item;
		if (typeof items == "object")
			item = items[index];
		if ((cfg.ThumbNail != "") && (cfg.gridstyle > 2))
		{
			if (thumbPattern == undefined)
				thumbPattern = document.createElement("DIV");
			thumbPattern.innerHTML = cfg.ThumbNail;
			for (var x = 0; x < head.length; x++)
			{
				var o = $("#" + head[x].FieldName, thumbPattern);
				if (item == undefined)
					var value = head[x].TitleName;
				else
				{
					var value = self.getFieldValue(item, x);
					o.prop("title", head[x].TitleName);
				}
				o.html(value);
				
				if ((value == "") && (typeof head[x].Editor == "object"))
				{
					o.html(head[x].TitleName);
					var c = head[x].Editor.config({bHint:true});
					o.css("color", c.hintColor);
				}
			}
			$(thumbPattern).children().attr("node", index);
			return thumbPattern.innerHTML;	
		}		
		if (depth > 0)
			divstyle = "padding-left:" + depth * cfg.nIndent + "px;";
		for (var x = 0; x < head.length; x++)
		{
			if (item == undefined)
				var value = head[x].TitleName;
			else
				var value = self.getFieldValue(item, x);
			switch (head[x].nShowMode)
			{
			case 1:			//����
			case 7:			//ת��
			case 9:			//����
				switch (gridstyle)
				{
				case 1:
				case 2:
					if ((head[x].nShowMode != 9) || (head[x].bTag != 1) || (cfg.initDepth < 0))
					{
						tds += self.getFieldCell(value, x, gridstyle, fg, nowrap, tdcss, divcss);
						break;
					}
					treeflag = 1;
					value = getTreeTagValue(value, depth, item);
					tds += self.getFieldCell(value, x, gridstyle, fg, nowrap, tdcss, divstyle + divcss, depth * cfg.nIndent);
					break;
				case 3:		//
					if ((head[x].nShowMode == 9) || (head[x].bTag == 1))
					{
						tds += self.getFieldCell(value, x, 3);
						break;
					}
					hint += head[x].TitleName + ":" + value + "\n";
					break;
				case 4:
					tds += self.getFieldCell(value, x, gridstyle, fg, nowrap, tdcss, divcss);
					break;
				}
				break;
			case 3:			//ע��
				hint += head[x].TitleName + ":" + value + "\n";
				break;
			case 2:			//����
				break;
			case 4:			//��ֹ
				break;
			case 5:			//����
				break;
			case 6:			//����
				break;
			case 8:			//����
				break;
			}
		}
		return {tds: tds, hint: hint, treeflag: treeflag};
	};
	
	this.getColumnCount = function()	//����:�õ��е�����
	{
		var count = 0;
		for (var x = 0; x < head.length; x++)
		{
			switch (head[x].nShowMode)
			{
			case 1:			//����
			case 7:			//ת��
			case 9:			//����
				count ++;
			}
		}
		return count;
	};
		
	this.setDomObj = function(obj)		//����:������������
	{
		if (typeof domobj == "object")
		{
			$(domobj).off("click", click);
			$(domobj).off("mousedown", downHead);
			$(domobj).off("mouseover", rollHead);
			$(domobj).off("contextmenu", headmenu);
		}
		domobj = obj;
		if (obj == undefined)
			return;
		this.reload();
		$(domobj).on("click", click);
		$(domobj).on("mousedown", downHead);
		$(domobj).on("mouseover", rollHead);
		$(domobj).on("contextmenu", showheadmenu);
	};

	this.config = function (c) //����:��������
	{
		cfg = $.jcom.initObjVal(cfg, c);
		if (typeof thumbPattern == "object")
			$(thumbPattern).remove();		//thumbPattern.removeNode(true);
		thumbPattern = undefined;
		return cfg;
	};
	
	cfg = $.jcom.initObjVal({gridstyle:1, headstyle:1, bodystyle:3, transText:1, cellstyle: "border:1px solid #dddddd", 
		expic:[".TreeArrawOpen", ".TreeArrawClose"], headbordercolor:"", nowrap:1, initDepth:1, nIndent:20}, cfg);
	this.setDomObj(domobj);
}

$.jcom.GridView = function(domobj, head, data, info, cfg)	//��:�б���ͼ
{//�����б���ͼ���⣬��֧��������ͼ��������ͼ��
//domobj:����DOM����
//head:�ֶ�ͷ��Ϊ�������飬��Ա����
//	FieldName:""--�ֶ���--
//	TitleName:""--������--
//	nWidth:100--�п��--�˲�������ΪFieldProp��width��Ա��Ĭ��ֵ
//	nShowMode:1--��ʾ��ʽ--
//	bTag:0--�Ƿ����ֶ�--
//	Quote:""--���û����--
//	FieldType:1--��������--
//	bPrimaryKey:0--�Ƿ�������--
//	bSeek:0--�������--
//	FieldProp:""--�ֶη��������--��Ա{width:���, style:�ֶ�CSS���, tagName:��TABEL����ʱ��HTMLԪ����, LineNo:����}
//data:���ݼ�¼,Ϊ����head��FieldName���������Ϊ��Ա�����飬��:[{field1:val,field2:val2..._lineControl:{...}}...];
//	field1,field2...:head��FieldName��������ƣ�
//	val1, val2,...:�ֶε�ֵ�����Ϊ����ʱ���������º��壬����Ϊÿ����Ԫ�����ò�ͬ����ʽ������������α��
//	value:""--�ֶε�ֵ--
//	colspan:1--����չֵ--
//	rowspan:1--����չֵ--
//	tdstyle:tdcss--��Ԫ����--
// style:""--���--
// prop:""--html����--
// sontag:sontag--�ӱ�ǩ--
// color:color--��ɫ--
//	_lineControl:�������п�ѡ�Ķ����е���ʽ�Ķ�������Ϊ��ͬ���г��ֲ�ͬ����ʽ�����Ա�������£�
//	bgcolor:"white"--����ɫ--
//	height:24--�߶�--
//	show:1--�Ƿ���ʾ--
//	divstyle:"overflow-x:hidden;"--��Ԫ���ڲ�DIV���--
//info:ҳ����Ϣ
//	nPage:1--��ǰҳ--
//	PageSize:100--ÿҳ��¼��--
// PageCount:1--��ҳ��--
// Records:0--�ܼ�¼��--
// Order:""--�����ֶ�--
// bdesc:0--�Ƿ���--	
//cfg:����.��Ա���±�,����ʱ����ı�Ĭ��ֵ�ĳ�Ա�ɺ���
//	gridstyle:1--��ͼ���--1:�༭��ʽ,2:�Ķ���ʽ,3:������ͼ,4:�ĵ���ʽ
//	headstyle:1--��ͷ���--1:������ͷ,2:��ͷ�ͱ���ϲ�,3:û�б�ͷ,4:��̬��ͷ(����Ӧ��ͷ�����¼�,���Ҽ��˵�)
//	bodystyle:3--����ѡ������--1:��ѡ,2:��Ӽ����ѡ,3:�����ѡ
//	footstyle:0--ҳ�ŷ��--0:������ҳ��,ҳ����Ϣ�ͷ�ҳ,  1:	û��ҳ����Ϣ���з�ҳ,2:	��ҳ����Ϣ��û�з�ҳ,3:�հ�,4:��
//	transText:1--�Ƿ�ת��--��ֵΪ1������ʾת����ֵ��������ʾԭֵ��ת����ֵ
//	ThumbNail:""--����ͼ��ģ��ֵ--��gridstyle>2ʱ ��Ч��ΪHTML����Ƭ�Σ�Ҫ���ֶ�ΪԪ�ص�ID���Ա㶯̬�滻
//	bodycolor:"black"--����������ɫ--
//	bodybkcolor:"white"--���屳����ɫ--
//	rollbkcolor: "#f8f8ff"--����������ɫ--
//	selbkcolor:"#B7E3FE"--ѡ�񱳾���ɫ--
//	cellstyle: "border:1px solid #dddddd"--��Ԫ����--
//	divcss: "overflow-x:hidden;"--��Ԫ���ڲ�DIV���--
//	headbordercolor:""--��ͷ�߿���ɫ--
//	expic:[".TreeArrawOpen", ".TreeArrawClose"]--չ��ͼ��--
//	nowrap:1--�Ƿ��ֹ����--
//	rightmenu:null--�Ҽ��˵�--
//	initDepth:1--�����ʼ�����--��data������child�ڵ�ʱ����������ʽչʾ����ֵΪ0ʱ���������������б�չʾ
//	nIndent:20--�������--��λ��px
//	titlebar:undefined--����-- 
//	footContainer:undefined--ҳ��DOM����-- 
//	resizeflag:1--���ű�־--
//
//˵��:
var self = this;
var dragobj, dragindex, dragdelta, evtobj, dragparam;
var rollshadow, selshadow, gridhead, pagefoot, BodyDiv;
//var expic = [".TreeArrawOpen", ".TreeArrawClose"];
var keycode = 0, keystate = 0;
	function createGrid()
	{
		if (typeof head != "object")
			return;
		var overflow = "auto";
		if (($(domobj).css("overflow") == "visible") || ($(domobj).css("overflowY") == "visible")) 
			overflow = "visible";
		var tag = "";
		if (typeof cfg.titlebar == "string")
		{
			tag = "<div id=GridTitleBar style:padding:4px>" + cfg.titlebar +"</div>";
			$(domobj).css("overflowY", "auto");
			overflow = "visible";
		}
		if ((cfg.headstyle != 2) && (cfg.headstyle != 3) && (cfg.gridstyle != 3))	//cfg.headstyle=2:��ͷ�ͱ���ϲ���cfg.headstyle=3:û�б�ͷ, cfg.gridstyle=1:�༭��ʽ���б���ͼ, cfg.gridstyle=2:�Ķ���ʽ���б���ͼ, cfg.gridstyle=3:������ͼ, cfg.gridstyle=4: divgrid
		{
			tag +="<div id=HeadDiv style='width:100%;'></div>";
		}
		tag += "<div id=BodyDiv class=gridbodycontainer style='overflow:" + overflow + "'></div>";
//		tag += "<div id=BodyDiv class=gridbodycontainer style='width:" + $(domobj).width() + "px;overflow:" + overflow + "'></div>";
		var fc = cfg.footContainer;
		if (typeof fc != "object")
		{
			domobj.innerHTML = tag + "<div id=PageFoot style='padding-top:4px;'>123</div>";
			fc = $("#PageFoot", domobj)[0];
		}
		else
			domobj.innerHTML = tag;
		BodyDiv = $("#BodyDiv", domobj);
		pagefoot.setDomObj(fc);
		
		if ((cfg.headstyle != 2) && (cfg.headstyle != 3) && (cfg.gridstyle != 3))
		{
			gridhead.setDomObj($("#HeadDiv", domobj)[0]);
			gridhead.setHeadOrder(info.Order, info.bDesc);
		}
		self.reload(data);
		self.resize();
	}
	
	function getbody(gridstyle, items, depth, node, area, config)
	{
		if (gridstyle == 3)
			return getThumbBody();

		if (typeof items != "object")
			items = data;
		if (typeof depth != "number")
			depth = 0;
		if ((node == "") || (typeof node == "undefined"))
			node = "";
		else
			node += ",";
		area = $.jcom.initObjVal({rowbegin:0, rowend:items.length}, area);
		if (typeof config == "object")
			config = $.jcom.initObjVal(cfg, config);
		else
			config = cfg;
		var tag = "";//, divstyle = "";
		var bk = ["white"];
		if (typeof config.bodybkcolor == "string")
			bk = config.bodybkcolor.split(",");
		var fg = "black";
		if (typeof config.bodycolor == "string")
			fg = config.bodycolor;
		var value, hint, tds, nowrap = " nowrap";
		if (config.nowrap == 0)
			nowrap = "";
//		if (depth > 0)
//			divstyle = "padding-left:" + depth * cfg.nIndent + "px;";
//		var treeflag = 0;
		for (var y = area.rowbegin; y < area.rowend; y++)
		{
			hint = "";
			tds = "";

			var c = bk[y % bk.length];
			var css = "height:24px";
			var divcss = config.divcss;
			if (typeof items[y]._lineControl == "object")
			{
				items[y]._lineControl = $.jcom.initObjVal({bgcolor:"white", height:24,show:1,divstyle:"overflow-x:hidden;"}, items[y]._lineControl);
				c = items[y]._lineControl.bgcolor;
				css = "height:" + items[y]._lineControl.height + "px";
				if (items[y]._lineControl.show == 0)
					css += ";display:none";
				if (items[y]._lineControl.height <= 0)
					continue;
				divcss = items[y]._lineControl.divstyle;
			}
			var o = gridhead.getLine(items, y, gridstyle, depth, fg, nowrap, config.cellstyle, divcss);
/*
			for (var x = 0; x < head.length; x++)
			{
				value = getvalue(items[y], x);
				switch (head[x].nShowMode)
				{
				case 1:			//����
				case 7:			//ת��
				case 9:			//����
					if ((head[x].nShowMode != 9) || (head[x].bTag != 1) || (cfg.initDepth < 0))
					{
//						tds += getTDTag(value, x, gridstyle, fg, nowrap, divcss);
						tds += gridhead.getFieldCell(value, x, gridstyle, fg, nowrap, divcss);
						break;
					}
					treeflag = 1;
					value = getTreeTagValue(value, depth, items[y]);
//					tds += getTDTag(value, x, gridstyle, fg, nowrap, divstyle + divcss);
					tds += gridhead.getFieldCell(value, x, gridstyle, fg, nowrap, divstyle + divcss);
					break;
				case 3:			//ע��
					hint += head[x].TitleName + ":" + value + "\n";
					break;
				case 2:			//����
					break;
				case 4:			//��ֹ
					break;
				case 5:			//����
					break;
				case 6:			//����
					break;
				case 8:			//����
					break;
				}
			}
*/
			if (typeof o == "string")
				tag += o;
			else if (gridstyle == 4)
			{
				tag += "<div name=thumbdiv style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;background-color" + c + ";' node=" + (node + y) + 
					" title=\"" + o.hint.replace(/\"/g, "&quot;") + "\">" +	o.tds + "</div>";			
			}
			else
			{
				if (config.bodystyle == 2)
					o.tds = "<td><div style=width:20px><input name=LineSelBox type=checkbox></div></td>" + o.tds;
				tag += "<tr style='" + css + "' node=" + (node + y) + " bgcolor=" + c + " title=\"" + o.hint.replace(/\"/g, "&quot;") + "\">" + o.tds + "</tr>";
				if ((o.treeflag == 1) && (typeof items[y].child == "object") && (depth < config.initDepth - 1))
					tag += getbody(gridstyle, items[y].child, depth + 1, node + y, {}, config);
			}
		}
		return tag;
	}
	
	function reindex(items, node, trs, begin)
	{
		if (typeof items != "object")
			items = data;
		if ((node == "") || (typeof node == "undefined"))
			node = "";
		else
			node += ",";
		if (begin == undefined)
			begin = 0;
		if (trs == undefined)
			trs = $(domobj).find("#BodyTable tr");
		var cnt = 0, index = 0;
		for (var x = begin; x < trs.length; x++)
		{
			cnt ++;
			$(trs[x]).attr("node", node + index);
			var treeimg = $(trs[x]).find("#BtExTree");
			if ((typeof items[index].child == "object") && (items[index].child != null) && (items[index].child.length > 0) && (treeimg.attr("unloadflag") != 1))
			{
				var scnt = reindex(items[index].child, node + index, trs, x + 1);
				x += scnt;
				cnt += scnt;
			}
			index ++;
			if (index >= items.length)
				break;
		}
		return cnt;
	}

	function getThumbBody()
	{
		var hint, line, value, x, y, tag = "";
		for (y = 0; y < data.length; y++)
		{
			hint = "";
			line = "";
			var o = gridhead.getLine(data, y, 3, 0);
/*			
			for (x = 0; x < head.length; x++)
			{
				value = getvalue(data[y], x);
				switch (head[x].nShowMode)
				{
				case 1:			//����
				case 7:			//ת��
				case 9:			//����
					if ((head[x].nShowMode == 9) || (head[x].bTag == 1))
					{
//						line += getTDTag(value, x, 3);
						line += gridhead.getFieldCell(value, x, 3);
						break;
					}
				case 3:			//ע��
					hint += head[x].TitleName + ":" + value + "\n";
					break;
				case 2:			//����
					break;
				case 4:			//��ֹ
					break;
				case 5:			//����
					break;
				case 6:			//����
					break;
				case 8:			//����
					break;
				}
			}
*/
			if (typeof o == "string")
				tag += o;
			else
				tag += self.makeThumb(o.tds, o.hint, y, data[y]);
		}
		return tag;
	}

/*
	function getTreeTagValue(value, depth, item)
	{
		var index = 0;
		if (depth >= cfg.initDepth - 1)
			index = 1;
		var style = "";
		if (typeof item.child != "object")
			style= " style=visibility:hidden;";
		var ex = "<img id=BtExTree ex=" + index + " unloadflag=" + index + " src=" + expic[index] + style + ">&nbsp;";
		if (expic[0].substr(0, 1) == ".")
			ex = "<span id=BtExTree ex=" + index + " unloadflag=" + index + " class=" + expic[index].substr(1) + style + "></span>";
		if (typeof value == "object")
				value.value = ex + "<span style='height:100%'>" + value.value + "</span>";
			else
				value = ex + "<span style='height:100%'>" + value + "</span>";
		return value;
	}
	
	function getvalue(item, index)
	{
		var value = gridhead.getItemValue(item, head[index]);
		var v = item[head[index].FieldName];
		if (typeof v == "object")
			v.value = value;
		else
			v = value;
		return v;
	}
*/	
	this.getItemValue = function(item, field)	//����:�õ�����ת����ֵ
	{//
	//item:
	//field:
	//����ֵ:
	//˵��:�÷������ܻᱻ��������Ϊ�Ѿ��Ƶ�gridhead���ˡ�
		return gridhead.getItemValue(item, field, cfg.transText);
	};
	
	function gridmenu(event)
	{
		var td = $.jcom.findParentObj(event.target, domobj, "TD");
		return bodymenu(event);
	}
	
	function keydown(event)
	{
		keycode = event.which;
		keystate = 1;
		if  (self.keydown(event) == true)
			return;
		if (data.length == 0)
			return;
		var objs = [];
		if (typeof selshadow == "object")
			objs = selshadow.getShadow();
		var rows = $(domobj).find("#BodyTable tr");
		if (event.shiftKey)
			keycode = 16;
		switch (event.which)
		{
		case 40:		//down
			if (objs.length == 0)
			{
				self.select(rows[0].cells[0]);
				break;
			}
			for (var x = objs[objs.length - 1].obj.rowIndex + 1; x <= rows.length; x++)
			{
				if (x >= rows.length)
				{
					self.select();
					break;
				}
				if (rows[x].style.display != "none")
				{
					self.select(rows[x].cells[0]);
					break;
				}
			}
			break;
		case 39:		//right
			if ((keycode == 16) || (objs.length > 1))	//shift
				break;
			var treeimg = $(objs[0].obj).find("#BtExTree");
			if (treeimg.length == 1)
				expandTreeLine(treeimg[0], 1);
			break;
		case 38:		//up
			if (objs.length == 0)
			{
				self.select(rows[rows.length - 1].cells[0]);
				break;
			}
			for (var x = objs[0].obj.rowIndex - 1; x >= 0; x--)
			{
				if (x < 0)
				{
					self.select();
					break;
				}
				if (rows[x].style.display != "none")
				{
					self.select(rows[x].cells[0]);
					break;
				}
			}
			break;
		case 37:		//left
			if ((keycode == 16) || (objs.length > 1))	//shift
				break;
			if (objs.length == 0)
				break;
			var treeimg = $(objs[0].obj).find("#BtExTree");
			if (treeimg.length == 1)
				expandTreeLine(treeimg[0], 0);
			break;
		case 13:	//enter
			break;
		default:
			break;
		}
	}
	
	function keyup(event)
	{
		keycode = event.which;
		keystate = 0;
	}
	
	function onScroll()
	{
		$(domobj).find("#HeadDiv").css("marginLeft", "-" + BodyDiv.prop("scrollLeft") + "px");
		self.DisEditor();
	}
	
	this.DisEditor = function(flag)		//����:��ֹ�󶨵���Ԫ��Ķ�̬�༭��
	{
		if (typeof head != "object")
			return;
		for (var x = 0; x < head.length; x++)
		{
			if ((typeof head[x].Editor == "object") && (head[x].Editor != null))
			{
				head[x].Editor.hide();
				if ((flag == 1) || (flag == true))
					self.detachEditor(head[x].FieldName);
			}
		}
	}

	function findThumbDiv(o)
	{
		for (var obj = o; obj != domobj; obj = obj.parentNode)
		{
			if (typeof $(obj).attr("node") != "undefined")
				return obj;
		}
	}
	
	function rollgrid(event)
	{
		var o = event.target;
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
		{
			var div = findThumbDiv(o);
			if (typeof div == "object")
				self.overRow(div);
			return;
		}
		if (o.tagName == "TD")
		{
			if ((o.firstChild != null) && (o.firstChild.nodeType == 1))
			{
				if (o.firstChild.scrollWidth > o.firstChild.offsetWidth)
					o.title = o.firstChild.innerText;
				else
					o.removeAttribute("title");
			}
		}
		else
			o.style.cursor = "default";
		
		var td = $.jcom.findParentObj(o, domobj, "TD");
		if (typeof td != "object")
			return; 
		if ((td.parentNode.id != "SeekTitleTR") && (td.parentNode.id != "HeadTR"))
			self.overRow(td);
	}
	
	function downgrid(event)
	{
		evtobj = event.target;
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
		{
			var headitem = gridhead.getHead(event.target.id);
			if ((typeof headitem != "object") || (typeof headitem.Editor != "object"))
				return;
			var div = findThumbDiv(event.target);
			if (self.CellEditorTest(div, headitem) == false)
				return;
			return headitem.Editor.preshow(event);
		}

		var td = $.jcom.findParentObj(event.target, domobj, "TD");
		if (typeof td == "object")
		{
			if ((typeof event.target.id == "string") && (event.target.id.substr(0, 6) == "Field_"))
			{//���һ����Ԫ�����ж���༭����� id Ϊ "Filed_" + FieldName
				var FieldName = event.target.id.substr(6);
				var headitem = gridhead.getHead(FieldName);
				if ((typeof headitem != "object") || (typeof headitem.Editor != "object"))
					return;
				if (self.CellEditorTest(td, headitem) == false)
					return;
				return headitem.Editor.preshow(event);
			}
			var FieldName = td.id.substr(0, td.id.length - 3);
			var headitem = gridhead.getHead(FieldName);
			if (typeof headitem != "object")
				return;
			if (typeof headitem.Editor == "object")
			{
				var div = td.firstChild;
				if (div != null)
				{
					if ((div.firstChild != null) && (div.firstChild.nodeType != 3))
						div = div.lastChild;
					event.target = div;
				}
				if (self.CellEditorTest(td, headitem) == false)
					return;
				return headitem.Editor.preshow(event);
			}
		}
		if (cfg.bodystyle == 3)	//�϶���ѡ
		{
			$(document).on("mouseup", selearea);
		}
			return;		//return false����ֹ�¼�����
	}

	this.CellEditorTest = function (td, headitem)	//�¼�:���Ե�ǰ��Ԫ���Ƿ�ɱ༭���緵��true����ʾ�ɱ༭�����򲻿ɱ༭
	{
		return true;
	};
	
	function selearea(event)
	{
		$(document).off("mouseup", selearea);
		if (event.which == 16)	//16:shiftKey
			return;
return;
 		var rg = document.selection.createRange();
 		window.status = rg.boundingTop + "-" + rg.boundingHeight;
		var el = rg.parentElement();
//		alert(el.tagName);
 		return;
 		var oRcts = rg.getClientRects();
		for (var x = 0; x < oRcts.length; x++)
   			window.status = (oRcts[x].top + "," + oRcts[x].bottom);
	}
			
	function clickGrid(e)
	{
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
		{
			var div = findThumbDiv(e.target);
			if (e.shiftKey && e.ctrlKey)
				return SetupLineLayer(div);
			if (typeof div == "object")
				self.clickRow(div, e);
			return;
		}
	
		if (e.target.id == "BtExTree")
			return expandTreeLine(e.target);
		var td = $.jcom.findParentObj(e.target, domobj, "TD");
		if (typeof td != "object")
		{
			self.clickRow(td, e);
			return;
		}
		if ((td.parentNode.id != "SeekTitleTR") && (td.parentNode.id != "HeadTR"))
		{
			self.clickRow(td, e);
		}
	}

	function SetupLineLayer(obj)
	{
		var win = new $.jcom.PopupWin("<div id=SetupLineLayerView style=width:100%;height:100%;><div id=Preview style=width:100%>" + obj.outerHTML +
			"</div><textarea id=ThumbNailTag style=width:100%;height:160px>" + obj.outerHTML +
			"</textarea><div align=center><input id=PreviewSetupLineLayer type=button value=Ԥ��>&nbsp;&nbsp;<input id=RunSetupLineLayer type=button value=Ӧ��></div></div>",
			{title:"�в�������", width:810, height:480});
		var c = $("#SetupLineLayerView");
		$("#RunSetupLineLayer", c).on("click", function (e)
		{
			cfg.ThumbNail = $("#ThumbNailTag").text();
			self.reset(data, info, head, cfg);
			
		});
		
		$("#PreviewSetupLineLayer", c).on("click", function (e)
		{
			$("#Preview", c).html($("#ThumbNailTag").text());
		});
	}
	
	function expandTreeLine(obj, flag)
	{
		var tr = obj.parentNode.parentNode.parentNode;
		var depth = $(tr).attr("node").split(",").length;
		if ((((flag == 1) || (flag == true)) && (obj.ex == 0))
			|| (((flag == 0) || (flag == false)) && (obj.ex == 1)))
			return;
		if ($(obj).attr("ex") == 1)
		{
			$(obj).attr("ex", 0);
			if (obj.tagName == "IMG")
				obj.src = cfg.expic[0];
			else
				obj.className = cfg.expic[0].substr(1);
			var dis = "";
			if ($(obj).attr("unloadflag") == 1)
			{
				var item = self.getItemData($(tr).attr("node"));
				if (item.child == null)
				{
//					odiv.innerHTML = "<span style=color:gray;>������...</span>";
					self.loadnode(item, obj);
				}
				else
					self.loadnodeok(item, obj);
			}
		}
		else
		{
			$(obj).attr("ex", 1);
			if (obj.tagName == "IMG")
				obj.src = cfg.expic[1];
			else
				obj.className = cfg.expic[1].substr(1);
			var dis = "none";
		}

		for (var x = tr.rowIndex + 1; x < tr.parentNode.rows.length; x++)
		{
			var d = $(tr.parentNode.rows[x]).attr("node");
			if (d.split(",").length <= depth)
				break;
			tr.parentNode.rows[x].style.display = dis;
		}
	}
	
	this.loadnode = function(item, obj)	//�¼�:������ͼ�ӽڵ��������ʱ������������¼��������ӽڵ���ɺ������loadnodeok��չ�֣��粻������¼����ӽڵ�Ĭ��Ϊ�����ݡ�
	{
			item.child = [];
			this.loadnodeok(item, obj);
	};
	
	this.loadnodeok = function(item, obj)	//����:������ͼ������ɺ���ô˷�������������ͼ��չ�֡�
	{
			var tr = obj.parentNode.parentNode.parentNode;
			var depth = $(tr).attr("node").split(",").length;
			insertChild(tr, "afterEnd", item.child, depth, $(tr).attr("node"));			
			obj.removeAttribute("unloadflag");
	};
	
	function dblclickgrid(event)
	{
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
		{
			var obj = findThumbDiv(event.target);
			if (typeof obj != "object")
				return;
			self.dblclickRow(obj);
		}
		var td = $.jcom.findParentObj(event.target, domobj, "TD");
		if (typeof td != "object")
			return;
		if ((td.parentNode.id != "SeekTitleTR") && (td.parentNode.id != "HeadTR"))
			self.dblclickRow(td);
	}

	function cellobj(td)
	{
		if (td.firstChild == null)
			return td;
		if (td.firstChild.nodeType == 3)
			return td;
		return td.firstChild;
	}
	
	this.makeThumb = function (line, hint, index, item)		//�¼�:����������ͼʱ������Ĭ�϶���Ϊ������
	{
		return "<div name=thumbdiv style='float:left;width:200px;padding:4px;margin:4px;border:1px solid gray;background-color:#fcfcfc;' title=" +
			hint + " node=" + index + "><div align=center style='width:200px;height:10px;overflow:hidden;'>" + self.makeThumbImg(line, hint, index, item) + "</div>" + line + "</div>";
	};
	
	this.makeThumbImg = function (line, hint, index, item)		//�¼�:��������ͼʱ������Ĭ�϶���Ϊ��
	{
		return "";
	};
	
	this.getHead = function (index)		//����:���ر�ͷ��������
	{
		return gridhead.getHead(index);
	};
	
	this.cellchange = function (obj)		//�¼�:��̬�༭����ɱ༭��������Ԫ�����ݸı�ʱ����
	{
		var value = obj.innerText;
		var ex = value;
		if ($(obj).attr("node") != undefined)
			value = $(obj).attr("node");
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
		{
			var div = $(obj).parents("[name='thumbdiv']");
			var node = div.attr("node");
			var FieldName = obj.id;
		}
		else
		{
			var td = obj.parentNode;
			if (td == null)
				return;
			if (td.tagName != "TD")
				td = td.parentNode;
			var node = $(td.parentNode).attr("node");
			var FieldName = td.id.substr(0, td.id.length - 3);
		}
		var item = self.getItemData(node);
//		var index = td.parentNode.rowIndex;
		item._Editflag = 1;		//�༭
		if (self.EditorChange(value, FieldName, node, obj) == false)
			return;
		if (typeof item[FieldName] == "object")
			item[FieldName].value = value;
		else
			item[FieldName] = value;
		if (typeof item[FieldName + "_ex"] != "undefined")
		{
			if (typeof item[FieldName + "_ex"] == "object")
				item[FieldName + "_ex"].value = ex;
			else
				item[FieldName + "_ex"] = ex;
		}
	};
	
	this.EditorChange = function (value, FieldName, node, obj)		//�¼�:�󶨵Ķ�̬�༭����ɱ༭���༭���Ѹı�ʱ����
	{
		return true;
	}

	this.setexpic = function(pic)		//����:��������չ��ͼ��
	{
		cfg.expic = pic;
		gridhead.config(cfg);
		self.reload();
	};
	
	function bodymenu(event)
	{
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
			var obj = findThumbDiv(event.target);
		else
			var obj = $.jcom.findParentObj(event.target, domobj, "TD");
		return self.bodymenu(obj, event);	
	}

	this.bodymenu = function (td, event)		//�¼�:�Ҽ��˵��¼�
	{};
	
	this.bodyonload = function ()		//�¼�:������ɺ���
	{};
	
	this.clickRow = function (td, event)		//�¼�:������ʱ������Ĭ�϶���Ϊѡ����
	{
		this.select(td);
		this.click(td, event);
//		domobj.focus();	
	}
	
	this.select = function (td)		//����:ѡ��ָ����Ԫ�����
	{
		var min = -1, max = -1, index, x, rows;
		if (typeof rollshadow == "object")
			rollshadow.hide();
		if (typeof selshadow != "object")
			return;
		if (typeof td != "object")
		{
			td = self.getRow(td);
			if (td == undefined)
			{
				selshadow.hide();
				return;
			}
			td = td.cells[0];
		}
		var o = td;
		if ((cfg.gridstyle == 3) || (cfg.gridstyle == 4))
			rows = $(domobj).find("[name='thumbdiv']");
		else
		{
			o = td.parentNode;
//			rows = $(domobj).find("tr");
			rows = $(domobj).find("#BodyTable tr");
		}
		if ((keycode == 16) && (keystate == 1) && (cfg.bodystyle == 3))	//16:ShiftKey
		{
			for (x = 0; x < rows.length; x++)
			{
				if (selshadow.isShadow(rows[x]) && (min == -1))
					min = x;
				if (selshadow.isShadow(rows[x]) && (x > max))
					max = x;
				if (rows[x] == o)
					index = x;
			}
//			index = td.parentNode.rowIndex;
			
			if ((min == -1) && (max == -1))
				selshadow.show(o);

			if (index < min)
				min = index;
			else
			{
				if (index > max)
					max = index;
				else
					min = index
			}
			selshadow.hide();
			for (x = min; x <= max; x++)
				selshadow.show(rows[x], true);
//			document.selection.empty();
			window.getSelection().removeAllRanges();
		}
		else
			selshadow.show(o, (keycode == 17) && (keystate == 1) && (cfg.bodystyle == 3));	//17: ctrlKey
		return o;
	};
	
	this.click = function (td, event) 		//�¼�:������ʱ����
	{};
	
	this.dblclickRow = function (td) 		//�¼�:˫����ʱ����
	{};
		
	this.keydown = function (event) 		//�¼�:���̼�����ʱ����
	{
		window.status += ".";
	};
	
	this.overRow = function (td) 		//�¼�:��껬����ʱ������Ĭ��Ϊ��ʾ��ɫ�ı���ɫ
	{
		if (typeof rollshadow != "object")
			return;
		var o = td;
		if ((cfg.gridstyle != 3) && (cfg.gridstyle != 4))
			o = td.parentNode;
		if (selshadow.isShadow(o))
			rollshadow.hide();
		else
			rollshadow.show(o);
	};
	
	this.orderField = function (Field, bDesc) 		//�¼�:������ʱ����
	{};
	
	this.resize = function ()		//����:�ı�ߴ�
	{
		if (cfg.resizeflag == 0)
			return;
//		if (($(domobj).css("overflow") == "visible") || ($(domobj).css("overflowY") == "visible")) 
//			return;
		BodyDiv.width($(domobj).width());
		BodyDiv.height($(domobj).outerHeight() - $("#HeadDiv", domobj).outerHeight(true) - $("#PageFoot", domobj).outerHeight(true));
	}
	
	this.reload = function (body, h, c)		//����:���¼���
	{
		if ((typeof h == "object") || (typeof c == "object"))
		{
			if (typeof h == "object")
			{
				if (typeof h.Records == "undefined")
					return this.reset(body, 0, h, c);
				else 
					return this.reset(body, h, 0, c);
			}
		}
			return self.reset(body, 0, h, c);
	};
	
	this.reset = function (newdata, newinfo, newhead, newcfg)		//����:��������Grid
	{
		self.DisEditor();
		if (typeof newdata == "object")
			data = newdata;
		if (typeof newinfo != "object")
		{
			newinfo = pagefoot.footinfo();
//			if (newinfo.Records == 0)
				newinfo.Records = data.length;
			if (newinfo.PageSize < data.length)
				newinfo.PageSize = data.length;
		}
		info = pagefoot.footinfo(newinfo);

		if (info.PageSize <= 0)
			info.PageSize = 100;
		
		if (typeof newhead == "object")
		{
			head = newhead;
			gridhead.reload(newhead);
		}
		if (typeof newcfg == "object")
		{
			cfg = $.jcom.initObjVal(cfg, newcfg);
			gridhead.config(cfg);
			self.setDomObj(domobj);
			return;
		}
		if (BodyDiv == undefined)
			return;
		var body = getbody(cfg.gridstyle);
		if  (cfg.gridstyle < 3)
		{
			var t = "<table id=BodyTable cellpadding=0 cellspacing=0 border=1 style='border-collapse:collapse;border:none;'>";
			if (((cfg.gridstyle == 2) && (cfg.headstyle != 3)) || ((cfg.gridstyle == 1) && (cfg.headstyle == 2)))	//headstyle=2,��ͷ�����ϲ��� headstyle=3:û�б�ͷ
				body = t + gridhead.getHeadLineTag() + body + "</table>";
			else
				body = t + body + "</table>";
		}
		if (typeof selshadow == "object")
			selshadow.hide();
		if (typeof rollshadow == "object")
			rollshadow.hide();
		BodyDiv.html(body);
		self.resize();

		if(typeof newinfo == "object")
			pagefoot.reload(info);
		this.bodyonload();
	};

	this.findNode = function(FieldName, value, list)		//����:Ѱ��ָ��ֵ�Ľڵ�
	{
		var result;
		if (list == undefined)
			list = data;
		for (var x = 0; x < list.length; x++)
		{
			if (list[x][FieldName] == value)
				return x;
			if ((typeof list[x].child == "object") && (list[x].child != null))
			{
				result = this.findNode(FieldName, value, list[x].child);
				if (result != undefined)
					return x + "," + result;
			}
		}
	};
	
	this.setCell = function (node, FieldName, value)		//����:���������õ�ָ���к�ָ����
	{
		if (typeof node == "object")
			var row = node;
		else
			var row = this.getRow(node);
		var item = this.getItemData(node);
		var td = $(row).find("#" + FieldName + "_TD")[0];
		if (typeof value == "object")
		{
			item[FieldName] = value;
			if (typeof td == "object")
			{
				var o = $.jcom.initObjVal({value:"", style:"", color:""}, value);
				var obj = cellobj(td);
				obj.innerHTML = o.value;
				obj.style.color = o.color;
				var s = $.jcom.getStyleObjFromString(o.style);
				$(obj).css(s);
			}
		}
		else
		{
			if (typeof item[FieldName] == "object")
				item[FieldName].value = value;
			else
				item[FieldName] = value;
			if (typeof td == "object")
				cellobj(td).innerHTML = value;
		}
	};
	
	this.getCell = function (node, FieldName)		//����:����ָ���ڵ�ŵ�ָ���еĵ�Ԫ�����
	{
		var row = this.getRow(node);
		return $(row).find("#" + FieldName + "_TD")[0];
	};
	
	this.getCellData = function (td)		//����:����ָ���ڵ�ŵ�ָ���е�����
	{
		var FieldName = td.id.split("_")[0];
		var index = parseInt($(td.parentNode).attr("node"));
		return data[index][FieldName];
	};
	
	this.getRow = function(node)		//����:����ָ���ڵ�ŵ���
	{
		return $(domobj).find("tr[node='" + node + "']")[0];
//		return domobj.all.BodyTable.rows[index];
	};

	this.attachEditor = function (FieldName, editor, valuechange)		//����:��ָ���а󶨵���̬�༭��
	{
		var y = gridhead.headItem(FieldName);
		if (y < 0)
			return;
		if (typeof editor != "object")
		{
			if (head[y].Quote == "")
				editor = new $.jcom.DynaEditor.Edit();
			else if (head[y].Quote.substr(0, 1) == "(")
				editor = new $.jcom.DynaEditor.List(head[y].Quote.substr(1, head[y].Quote.length - 2), 200, 300, 1);
		}
		head[y].Editor = editor;
		if (typeof valuechange == "function")
			editor.valueChange = valuechange;
		else if (valuechange != false)
			editor.valueChange = self.cellchange;
		return editor;
	};
	
	this.detachEditor = function (FieldName)		//����:����Զ�̬�༭���İ�
	{
		var y = gridhead.headItem(FieldName);
		if (y < 0)
			return;
		var editor = head[y].Editor;
		if (typeof editor == "undefined")
			return;
		head[y].Editor = undefined;
		return editor;
	};
	
	this.getSelRow = function(ntype)		//����:����ѡ����У������ڵ�ѡ
	{
		if (typeof rollshadow != "object")
			return;
		if (ntype == 1)
			return selshadow.getShadow();
		return selshadow.getObj();
	};
	
	this.getsel = function ()		//����:����ѡ����У���Ҫ���ڶ�ѡ
	{
		if (cfg.bodystyle != 2)
			return selshadow;
		var objs = [];
		var checks = $("input[name='LineSelBox']", domobj);
		for (var x = 0; x < checks.length; x++)
		{
			if (checks.eq(x).prop("checked"))
				objs[objs.length] = checks[x].parentNode.parentNode.parentNode;			
		}
		return objs;			
	};
	
	this.getData = function (index)		//����:�����б�����
	{
		if (index == undefined)
			return data;
		else
			return data[index];
	};
	
	this.getBodyTable = function ()		//����:����DOM����
	{
		return $("#BodyTable", domobj)[0];
	};
	
	this.outerDoc = function(nStyle, area, config)		//����:�������ı�
	{
		if (nStyle > 100)
			return getbody(nStyle - 100, 0, 0, "", area, config);
		
		return "<table id=BodyTable cellpadding=0 cellspacing=0 border=1 style='border-collapse:collapse;border:none;'>" + 
			gridhead.getHeadLineTag() + getbody(nStyle, 0, 0, "", area, config) + "</table>";
	};
	
	this.selCol = function (index)		//����:ѡ����
	{
		if (typeof selshadow != "object")
			return;
		selshadow.hide();
		var b = $("#BodyTable", domobj)[0];
		for (x = 0; x < b.rows.length; x++)
			selshadow.show(b.rows[x].cells[index], true);
	};

	this.deleteRow = function(row)			//����:ɾ����
	{
		if (typeof row == "undefined")
		{
			var rows = selshadow.getShadow();
			for (var x = rows.length - 1; x >= 0 ; x--)
				this.deleteRow(rows[x].obj);
			return;
		}
		if ((typeof row == "number") || (typeof row == "string"))
			return this.deleteRow(this.getRow(row));
		 var node = $(row).attr("node");
		 var ss = node.split(",");
		 var list = data;
		 for (var x = 0; x < ss.length - 1; x++)
		 {
		 	list = list[parseInt(ss[x])].child;
		 }
		var index = parseInt(ss[x]);
		var p = list.splice(index, 1);
		if (row.tagName != "TR")
		{
			self.reload();
			info.Records --;
			pagefoot.reload(info);
		 	return p[0];
		}
		var rows = row.parentNode.rows;
		for (var x = row.rowIndex + 1; x < rows.length; x++)
		{
			if ($(rows[x]).attr("node").split(",").length <= ss.length)
				break;
		}
		var rowIndex = row.rowIndex;
		for (var y = x - 1; y >= rowIndex; y --)
			$(rows[y]).remove();
		this.select();
		reindex();
		info.Records --;
		pagefoot.reload(info);
		return p[0];
	};
	
	this.insertRow = function (linedata, index)		//����:������
	{//
	//linedata:����Ҫ��������ݶ���
	//index:����Ҫ������кţ���Ϊundefined���Դӵ�ǰѡ���в��룬���޵�ǰѡ���л���ֵΪ-1������뵽���һ��
	//
		if (index == undefined)
		{
			index = data.length;
			var rows = selshadow.getShadow();
			if (rows.length > 0)
			{
				var node = $(rows[0].obj).attr("node");
			 	if (rows[0].obj.tagName == "TR")
			 	{
					var nodes = node.split(",");
					nodes[nodes.length - 1] = parseInt(nodes[nodes.length - 1]) + 1;
					return self.insertRow(linedata, nodes.toString());
				}
			 	else 
			 		return self.insertRow(linedata, node);
			}
		}
		if (index == -1)
			index = data.length;

		if (typeof index == "string")
		{
			var nodes = index.split(",");
			if (nodes.length <= 1)
				return self.insertRow(linedata, parseInt(index));
			var x = parseInt(nodes[nodes.length - 1]);
			nodes.splice(nodes.length - 1, 1);
			var pnode = nodes.toString();
			var child = this.getItemData(pnode).child;
			if ((x >=0) && ( x < child.length))
				child.splice(x, 0, linedata);
			else
			{
				x = child.length;
				child[child.length] = linedata;
			}
			var node = nodes.toString() + "," + x;
			var ptr = this.getRow(pnode);
			var treeimg = $(ptr).find("#BtExTree");
			if (treeimg.attr("unloadflag") == 1)
			{
				expandTreeLine(treeimg[0]);
				return node;
			}
			expandTreeLine(treeimg[0], 1);
			var rows = ptr.parentNode.rows;
			var depth = nodes.length;
			var tr = ptr;
			if (x > 0)
			{
				for (var y = ptr.rowIndex + 1; y < rows.length; y++)
				{
					var ss = $(rows[y]).attr("node").split(",");
					if ((ss.length <= depth) || (parseInt(ss[depth]) >= x))
						break;
				}
				var tr = rows[y - 1];
			}
			insertChild(tr, "afterEnd", [linedata], depth, index);			
			reindex();
			info.Records ++;
			pagefoot.reload(info);
			return node;
		}

		if (index == data.length)
			data[index] = linedata;
		else
			data.splice(index, 0, linedata);

		var trs = $(domobj).find("#BodyTable tr");
		if (trs.length == 0)
			return this.reload();
		
		var tr, where, depth;
		if (index == 0)
		{
			tr = this.getRow(index);
			where = "beforeBegin";
			depth = $(tr).attr("node").split(",").length - 1;
		}
		else
		{	
			tr = this.getRow(index - 1);
			depth = $(tr).attr("node").split(",").length - 1;
			where = "afterEnd";
			for (var x = tr.rowIndex + 1; x < trs.length; x++)
			{
				if ($(trs[x]).attr("node").split(",").length <= depth + 1)
					break;
			}			
			tr = trs[x - 1];
		}
		
		insertChild(tr, where, [linedata], depth, $(tr).attr("node"));
		info.Records ++;
		pagefoot.reload(info);
		reindex();
		return index;
	};
	
	function insertChild(tr, where, child, depth, node)
	{
		var oDiv = document.createElement("DIV");
		oDiv.innerHTML = "<table>" + getbody(cfg.gridstyle, child, depth, node) + "</table>";
		for (var x = oDiv.firstChild.rows.length - 1; x >= 0; x--)
		{
			var newtr = tr.insertAdjacentElement(where, oDiv.firstChild.rows[x]);
		}
		$(oDiv).remove();
	}
	
	this.insertCol = function (headitem)		//����:������,��ɺ���Ҫ���¼���
	{
		var index = data.length;
		var rows = selshadow.getShadow();
		if (rows.length > 0)
		{
		 	if (rows[0].obj.tagName == "TD")
				index = rows[rows.length - 1].obj.cellIndex + 1;
		}
		if (index == head.length)
			head[index] = headitem;
		else
			head.splice(index, 0, headitem);
	};
	
	this.waiting = function (s)		//����:���صȴ�
	{
		if (typeof domobj != "object")
			return;
		if (typeof s == "undefined")
			s = "������...";
		BodyDiv.html(s);
		pagefoot.reload("");
	};
	

	this.getItemData = function(node)		//����:���ݽڵ�ŵõ��ڵ�����
	{
		if (typeof node == "undefined")
		{
			var obj = this.getSelRow();
			if (obj == undefined)
				return;
			node = $(obj).attr("node");
		}
		if (typeof node == "number")
			return data[node];
		if (typeof node == "object")
			node = $(node).attr("node");
		if (node == undefined)
			return;
		var ss = node.split(",");
		var item, items = data;
		for (var x = 0; x < ss.length; x++)
		{
			item = items[parseInt(ss[x])];
			items = item.child;
		}
		return item;		
	};

	this.getItemKeyValue = function(item, key)		//����:���������������ֶ�,key:0��������1������ֶ�
	{
		if (typeof item != "object")
			item = self.getItemData();
		if (item == undefined)
			return;
		var head = self.getHead();
		for (var x = 0; x < head.length; x++)
		{
			if ((key == undefined) || (key == 0))
			{
				if (head[x].bPrimaryKey == 1)
					return item[head[x].FieldName];
			}
			else if (key == 1)
			{
				if (head[x].bTag == 1)
					return item[head[x].FieldName];
				
			}	
		}
	};
	
	this.expand = function(row, flag)		//����:չ������
	{
		if (typeof row == "undefined")
		{
			var rows = selshadow.getShadow();
			for (var x = 0; x < rows.length; x++)
				this.expand(rows[x].obj, flag);
			return;
		}

		var b = $("#BtExtree", row);
		if (b.length == 0)
			return;
		expandTreeLine(b[0], flag);
	};

	this.expandall = function (flag)		//����:չ����������
	{//note:������δ������ȫ��չ��ʱ�п��ܻ����
		var b = $("#BodyTable", domobj)[0];
		for (x = 0; x < b.rows.length; x++)
			self.expand(b.rows[x], flag);
	};

	this.OutExcel = function(filename, url, mode, area)		//����:������EXCEL
	{
		if ((typeof url != "string") || (url == ""))
			url = "../com/OutExcel.jsp";
		if (filename == undefined)
			filename = "Excel.xls";

		area = $.jcom.initObjVal({colbegin:0, colend:head.length, rowbegin:0, rowend:data.length}, area);
		var tag = "", count = 0, hcount = 0, vcount = 0;
		for (var z = area.colbegin; z < area.colend; z++)
		{
			if ((head[z].nShowMode != 1) && (head[z].nShowMode != 7) && (head[z].nShowMode != 9))
				continue;
			tag +="<input name=hv value='" + head[z].TitleName + "'><input name=hp value=" + head[z].FieldProp.width + ">"
			hcount ++;
		}
		for (var y = area.rowbegin; y < area.rowend; y++)
		{
			var o = $.jcom.initObjVal({bgcolor:"white", height:0}, data[y]._lineControl);
			if (o.show == 0)
				continue;
			tag +="<input name=vp value='" + o.height + "'>";
		}
		var yy = 0;
		for (var y = area.rowbegin; y < area.rowend; y++)
		{
			var x = 0;
			if (typeof data[y]._lineControl == "object")
			{
				if (data[y]._lineControl.show == 0)
					continue;
			}
			for (var z = area.colbegin; z < area.colend; z++)
			{
				if ((head[z].nShowMode != 1) && (head[z].nShowMode != 7) && (head[z].nShowMode != 9))
					continue;
				var key = head[z].FieldName;
				var value = data[y][key];
				if (typeof value != "undefined")
				{
					switch (mode)
					{
					case 1:			//����ת��
						value = gridhead.getFieldValue(data[y], z);
					case 2:			//ʹ��ԭʼ����
						break;
					case 3:
					case 0:			//ʹ�ý��������
					default:
						var cell = this.getCell(y, head[z].FieldName);
						if (cell == undefined)
							break;
						var v = cell.innerText;
						var img = $(cell).find("img");
						if (img.length > 0)
							v = img[0].src;
						if (typeof value == "object")
							value.value = v;
						else
							value = v;
					}
					if (typeof value == "object")
					{
						var o = $.jcom.initObjVal(value, {});
						o = $.jcom.initObjVal({value:"", colspan:1, rowspan:1, tdstyle:cfg.cellstyle,style:"", prop:"", color:"black"}, o);
						tag +="<input name=v" + count + " value='" + o.value + "'><input name=p" + count + " value='" + x + "," + yy + "," + o.colspan + "," +
							o.rowspan + "," + o.prop + "," + o.style + "," + o.tdstyle + "'>"
					}
					else
						tag +="<input name=v" + count + " value='" + value + "'><input name=p" + count + " value='" + x + "," + yy + ",1,1,,,'>"
					count ++;
				}
				x++;
			}
			yy ++;	
		}
		tag += "<input name=FileName value=" + filename + "><input name=hCount value=" + hcount + "><input name=vCount=" + data.length +
			"><input name=Count value=" + count + "><input name=headstyle=" + cfg.headstyle + ">";
		$.jcom.submit(url, tag, {fnReady:function(){}});
	};
	
	this.OutHTML = function(filename, url)	//����:����HTML�ļ�
	{
		if (url == undefined)
			url = "../com/OutHtml.jsp";
		var text = "<table id=BodyTable cellpadding=0 cellspacing=0 border=1 style='border-collapse:collapse;border:none;'>";
		if (cfg.headstyle != 3)
			text += gridhead.getHeadLineTag();
		var obj = {FileName:filename, body:text + getbody(cfg.gridstyle) + "</table>"}; 
		$.jcom.submit(url, obj);
	};

	this.pageskip = function (nPage)		//�¼�:��ҳʱ����
	{};
	
	this.getChildren = function (name)			//����: �õ����е��Ӷ���
	{
		var o = {selshadow: selshadow, rollshadow: rollshadow, gridhead: gridhead, pagefoot: pagefoot};
		if (name == undefined)
			return o;
		return o[name];
	};
	
	this.TitleBar = function (tag, option)		//����:���������
	{
		if (typeof cfg.titlebar == "string")
		{
			cfg.titlebar = tag;
			$("#GridTitleBar", domobj).html(tag);
			return;
		}
		option = $.jcom.initObjVal({id:"GridTitleBar"}, option);
		$(domobj).css({overflowY:"auto"});
		BodyDiv.css({overflowY:"visible"});
		if ($("#" + option.id, domobj).length == 0)
			$(domobj).prepend("<div id=" + option.id + " style='padding:4px;'></div>");
		if (typeof tag == "string")
			$("#" + option.id, domobj).html(tag);
		return $("#" + option.id, domobj)[0];
	};
	
	this.setDomObj = function(obj)	//����:���°�DOM����ֻ�е�һ������ʱ����Ҫ����true
	{
		if ((typeof domobj == "object") && (obj != true))
		{
			if (cfg.resizeflag == 1)
			{
//				$(window).off("resize", this.resize);
				$(window).off("resize", self.resize);
			}
			BodyDiv.off("scroll", onScroll);
			BodyDiv.off("mousewheel", self.DisEditor);

//			BodyDiv.off("resize", onScroll);
			BodyDiv.off("keydown", keydown);
			BodyDiv.off("keyup", keyup);

			BodyDiv.off("click", clickGrid);
			BodyDiv.off("dblclick", dblclickgrid);
			BodyDiv.off("mousedown", downgrid);
			BodyDiv.off("mouseover", rollgrid);
			BodyDiv.off("contextmenu", gridmenu);
		}
		if (typeof obj != "boolean")
			domobj = obj;
		if (typeof domobj != "object")
			return;

		createGrid();
		if (cfg.resizeflag == 1)
		{
	//		$(domobj).on("resize", this.resize);
			$(window).on("resize", self.resize);
			self.resize();
		}
		BodyDiv.on("scroll", onScroll);
		BodyDiv.on("mousewheel", self.DisEditor);

//		$("#BodyDiv", domobj).on("resize", onScroll); �п����ڱ༭����ʱ����������dynaeditorʧЧ������������ʱȴ�������ã����������붪ʧ��
		BodyDiv.on("keydown", keydown);
		BodyDiv.on("keyup", keyup);

		BodyDiv.on("click", clickGrid);
		BodyDiv.on("dblclick", dblclickgrid);
		BodyDiv.on("mousedown", downgrid);
		BodyDiv.on("mouseover", rollgrid);
		BodyDiv.on("contextmenu", gridmenu);
	};
	
	cfg = $.jcom.initObjVal({gridstyle:1, headstyle:1, bodystyle:3, footstyle:0, transText:1,ThumbNail:"",
			bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff",selbkcolor:"#B7E3FE",
			cellstyle: "border:1px solid #dddddd", divcss:"overflow-x:hidden;", headbordercolor:"",expic:[".TreeArrawOpen", ".TreeArrawClose"],
			nowrap:1, rightmenu:null, initDepth:1, nIndent:20, titlebar:undefined, footContainer:undefined, resizeflag:1}, cfg);

	if (typeof cfg.selbkcolor == "string")
		selshadow = new $.jcom.CommonShadow(0, cfg.selbkcolor);
	if (typeof cfg.rollbkcolor == "string")
		rollshadow = new $.jcom.CommonShadow(0, cfg.rollbkcolor);
	
	gridhead = new $.jcom.GridHead(0, head, cfg);
	gridhead.HeadChange = function (h) {self.reload(data, h);};
	gridhead.orderField = function (f, d) {return self.orderField(f, d);};
	pagefoot = new $.jcom.PageFoot(0, info, cfg);
	info = pagefoot.footinfo();	
	pagefoot.skip = function (page) {self.pageskip(page)};
	this.setDomObj(true);
};

$.jcom.ImageView = function(domobj, data, index, cfg)	//��:ͼƬ��ͼ
{
	var self = this;
	var img, eventbind = 0;
	var width, height, scale = 0, drag = 0, posx, posy;
	function init()
	{
		if (typeof index == "object")
		{
			for (var x = 0; x < data.length; x++)
			{
				if (data[x] == index)
				{
					index = x;
					break;
				}
			}
			if (x >= data.length)
				x = 0;
		}
		domobj.innerHTML = "<div style=width:100%;height:100%;overflow:hidden>" +
			"<table style=width:100%;height:100%;background-color:gray;><tr style=vertical-align:middle;>" +
			"<td align=center width=100%><img UNSELECTABLE=on id=PreviewImg src='../com/down.jsp?inpage=true&AffixID=" + 
			data[index].ID + "'></td></tr></table></div>";
		img = $(domobj).find("#PreviewImg")[0];
		img.onload = onload;
		if (eventbind == 0)
			eventon();
	}
	
	function onload()
	{
		imgresize();
		self.onready(data[index]);
	}
	
	function imgresize()
	{
		$(img).removeAttr("width");
		$(img).removeAttr("height");
		scale = 0;
		width = img.width;
		height = img.height;
		if (img.width > domobj.offsetWidth)
			img.width = domobj.offsetWidth;
		if (img.height > domobj.offsetHeight)
		{
			$(img).removeAttr("width");
			img.height = domobj.offsetHeight;
			height = 0;
		}
	}
	
	function scaleimg()
	{
		if (img.parentNode.style.cursor == "n-resize")
		{
			domobj.firstChild.scrollTop += parseInt(event.wheelDelta / 5);
			return;
		}
		if (img.parentNode.style.cursor == "w-resize")
		{
			domobj.firstChild.scrollLeft += parseInt(event.wheelDelta / 5);
			return;
		}
		if (height > 0)
		{
			var x = img.width + parseInt((img.width * event.wheelDelta) / 1000) + 1;
			if (x < 1)
				x = 1;
			if (x > 40960)
				x = 40960;
			img.width = x;
		}
		else
		{
			var x = img.height + parseInt((img.height * event.wheelDelta)/ 1000) + 1;
			if (x < 1)
				x = 1;
			if (x > 40960)
				x = 40960;
			img.height = x;
		}
	}
	
	function setpane()
	{
		if (drag == 1)
		{
			domobj.firstChild.scrollTop += posy - event.y;
			domobj.firstChild.scrollLeft += posx - event.x;
			posy = event.y;
			posx = event.x;
			return;		
		}
		var pos = $.jcom.getObjPos(domobj);
		if (event.clientX < pos.left + 40 + domobj.scrollLeft)
			img.parentNode.style.cursor = "W-resize";
		else if (event.clientX > pos.right - 40 + domobj.firstChild.scrollLeft)
			img.parentNode.style.cursor = "W-resize";
		else if (event.clientY < pos.top + 40 + domobj.firstChild.scrollTop)
			img.parentNode.style.cursor = "N-resize";
		else if (event.clientY > pos.bottom - 40 + domobj.firstChild.scrollTop)
			img.parentNode.style.cursor = "N-resize";
		else
			img.parentNode.style.cursor = "auto";
	}
	
	function runpane()
	{
		var pos = $.jcom.getObjPos(domobj);
		if (event.clientX < pos.left + 40 + domobj.firstChild.scrollLeft)
			return self.previous();
		if (event.clientX > pos.right - 40 + domobj.firstChild.scrollLeft)
			return self.next();
		img.parentNode.style.cursor = "hand";
		posx = event.x;
		posy = event.y;
		drag = 1;
	}
	
	function runpaneend()
	{
		img.parentNode.style.cursor = "auto";
		drag = 0;
	}

	function eventon()
	{
		$(domobj).on("resize", onload);
		$(domobj).on("mousewheel", scaleimg);
		$(domobj).on("mousemove", setpane);
		$(domobj).on("mousedown", runpane);
		$(domobj).on("mouseup", runpaneend);
		$(domobj).on("dblclick", quickscale);
		eventbind = 1;
	}
	function quickscale()
	{
		if (scale == 0)
		{
			$(img).removeAttr("width");
			$(img).removeAttr("height");
			scale = 1;
		}
		else
			onload();
	}
	
	this.reload = function(d, x)		//����:���¼���
	{
		data = d;
		index = x;
		init();
	}
	
	this.next = function()		//����:������һ��ͼƬ
	{
		if (index < data.length - 1)
		{
			index ++;
			img.src= "../com/down.jsp?inpage=true&AffixID=" + data[index].ID;
//			init();
		}
	};
	
	this.previous = function()		//����:������һ��ͼƬ
	{
		if (index > 0)
		{
			index --;
			img.src= "../com/down.jsp?inpage=true&AffixID=" + data[index].ID;
//			init();
		}
	};
	
	this.onready = function(item)		//�¼�:������ɺ����
	{};
	
	this.eventoff = function ()		//����:ȥ�����а��¼�
	{
		$(domobj).off("resize", imgresize);
		$(domobj).off("mousewheel", scaleimg);
		$(domobj).off("mousemove", setpane);
		$(domobj).off("mousedown", runpane);
		$(domobj).off("mouseup", runpaneend);
		$(domobj).off("dblclick", quickscale);
		eventbind = 0;
	}
	if (domobj == undefined)
		return;
	cfg = $.jcom.initObjVal({bgcolor:"gray", thumbview:1, toolbar:1}, cfg);
	init();
};

$.jcom.TreeView = function(domobj, data, cfg, head)	//��:������ͼ
{//
//domobj:����DOM����
//data:���ݼ�¼��Ϊ���ݶ������飬�磺[item, item, ...], itemΪ��{item:��Ҫ��ʾ�ı���ֶ� , img:ǰ����ʾ��ͼƬ, child:[...], fieldname1:value1, fieldname2:vaue2,...},��item �ֶ�δ���壬�ɸ��ݺ�����head�ֶζ��壬�Զ�ת���õ�����ֶΡ�
//����:child���=[],��ʾ�Ӷ���Ϊ�գ�=null,��ʾ���Ӷ��󣬵�δ���أ�����ʱ������¼���=undefined��ʾû���Ӷ�����û���Ӷ���չ��ͼʾ��ʡ��
//head:�ֶ�ͷ��Ϊ�������飬��Ա����
//	FieldName:""--�ֶ���--
//	TitleName:""--������--
//	nWidth:100--�п��--
//	nShowMode:1--��ʾ��ʽ--
//	bTag:0--�Ƿ����ֶ�--
//	Quote:""--���û����--
//	FieldType:1--��������--
//	bPrimaryKey:0--�Ƿ�������--
//	bSeek:0--�������--
//cfg:����.��Ա���±�,����ʱ����ı�Ĭ��ֵ�ĳ�Ա�ɺ���
//	bodycolor:"black"--ǰ����ɫ--
//	bodybkcolor:"white"--������ɫ--
//	rollbkcolor: "#f8f8ff"--���ͣ��ʱ�ı�����ɫ--
//	selbkcolor:"#B7E3FE"--ѡ���ı�����ɫ--
//	itemstyle:""--��ķ��--
//	imgstyle:""--ǰ��ͼƬ�ķ��--
//	transText:1--�Ƿ�ת������--
//	nowrap:1--�Ƿ�����--
//	rightmenu: null--�Ҽ��˵�--
//	initDepth:3--��ʼ��չʾ���������--
//	nIndent: 20--ÿ�������Ŀ��-- 
//	vpadding:1--��ֱ����--
//	expic:[".TreeArrawOpen", ".TreeArrawClose"]--չ��ͼ��--
//	dishint:0--��ֹ��ʾ--
//
//˵��:
	
	
var self = this;
//var expic = [".TreeArrawOpen", ".TreeArrawClose"];
var rollshadow, selshadow;
	function init()
	{
		if (typeof data != "object")
			return;
		var tag = "";
		for (var x = 0; x < data.length; x++)
			tag += getnodetag(data[x], 0, x);
		domobj.innerHTML = tag;
	}

	function getnodetag(item, depth, node)
	{
		var nowrap = "";
		if ((cfg.nowrap == 1) || (cfg.nowrap == true))
			nowrap = " nowrap=true";
		item = $.jcom.initObjVal({item:undefined, title:"", style:"", img:"", child:""}, item);
		if (typeof item.item == "undefined")
			translateItem(item);
		var title = " title=\"" + item.title + "\"";
		var style = item.style;
		if (style == "")
			style = cfg.itemstyle;
		var div = "<div node=" + node + " style=\"padding:" + cfg.vpadding + "px 2px " + cfg.vpadding + "px " +
			(depth * cfg.nIndent) + "px;" + style + "\"" + title + nowrap + ">"; 
		var img = $.jcom.getItemImg(item.img, cfg.imgstyle, 0, 0, "&nbsp;");

		var expic = cfg.expic;
		if (item.item.toLowerCase().substr(0, 5) == "[src=")
		{
			var pos = item.item.indexOf("]");
			if  (pos > 5)
			{
				value = item.item.substr(5, pos - 5);
				if (value == "none")
					expic = [];
				else
					expic = value.split(",");
				item.item = item.item.substr(pos + 1);
			}
			
		}
		var text = img + "<span>" + item.item + "</span>";
		var ex = getExpicTag(expic, 1, "visibility:hidden;");
//		if (expic.length == 2)
//		{
//			ex = "<img id=BtExTree src=" + expic[1] + " style=VERTICAL-ALIGN:middle;visibility:hidden;>";
//			if (cfg.expic[0].substr(0, 1) == ".")
//				ex = "<span id=BtExTree style=visibility:hidden; class=" + expic[1].substr(1) + "></span>";
//		}
		if (typeof item.child != "object")
			return div + ex + text + "</div>";

		ex = getExpicTag(expic, 1, "");
//		if (expic.length == 2)
//		{
//			ex = "<img id=BtExTree src=" + expic[1] + " style=VERTICAL-ALIGN:middle>";
//			if (cfg.expic[0].substr(0, 1) == ".")
//				ex = "<span id=BtExTree class=" + expic[1].substr(1) + "></span>";
//		}
		if ((depth >= cfg.initDepth - 1) || (item.child == null))
			return div + ex + text + "</div><div id=subdiv1 unloadflag=1 style='display:none;'></div>";
		var tag = "";
		for (var x = 0; x < item.child.length; x++)
			tag += getnodetag(item.child[x], depth + 1, node + "," + x);
		
		ex = getExpicTag(expic, 0, "");
//		if (expic.length == 2)
//		{
//			ex = "<img id=BtExTree src=" + expic[0] + " style=VERTICAL-ALIGN:middle>";
//			if (cfg.expic[0].substr(0, 1) == ".")
//				ex = "<span id=BtExTree class=" + expic[0].substr(1) + "></span>";
//		}
		return div + ex + text + "</div><div id=subdiv0 style=''>" + tag + "</div>";
	}

	function getExpicTag(expic, x, style)
	{
		if (expic.length == 2)
		{
			switch (expic[0].substr(0, 1))
			{
			case ".":
				return "<span id=BtExTree style='" + style + "' class=" + expic[x].substr(1) + "></span>";
			case "#":
				return $.jcom.getItemImg(expic[x], "font-size:14px;color:black;" + style, "span", "id=BtExTree");
			default:
				return "<img id=BtExTree src=" + expic[x] + " style='VERTICAL-ALIGN:middle;" + style + "'>";
			}
		}
		return "";
	}
	
	function translateItem(item)
	{
		if (typeof head != "object")
			return;
			
		for (var x = 0; x < head.length; x++)
		{
			var value = item[head[x].FieldName];
			if ((cfg.transText > 0) && (typeof item[head[x].FieldName + "_ex"] != "undefined"))
			{
				if (cfg.transText == 1)
					value = item[head[x].FieldName + "_ex"];
				else
					value = value + ":" + item[head[x].FieldName + "_ex"];
			}
			switch (head[x].nShowMode)
			{
			case 1:			//����
			case 7:			//ת��
			case 9:			//����
				if ((head[x].nShowMode == 9) || (head[x].bTag == 1))
				{
						item.item = value;
						break;
				}
			case 3:			//ע��
				if (cfg.dishint == 0)
					item.title += head[x].TitleName + ":" + value + "\n";
				break;
			case 2:			//����
				break;
			case 5:			//����
				break;
			case 6:			//����
				break;
			case 8:			//����
				break;
			case 4:			//��ֹ
				break;
			}
		}
	}

	function mouseevent(e)
	{
		var o = findparentnode(e.target);
//		if (typeof o == "undefined")
//			return;
		switch (e.type)
		{
		case "dblclick":
			return self.dblclick(o, e);
		case "contextmenu":
			return self.contextmenu(o, e);
		case "click":
			if (e.target.id == "BtExTree")
				return expand(e.target);
			return self.click(o, e);
		case "mouseover":
			return self.mouseover(o, e);
		default:
			alert(e.type);
		}
	}

	function expand(img, flag)
	{
		var odiv = img.parentNode.nextSibling;
		if ((odiv == null) || (((flag == 1) || (flag == true)) && (odiv.id == "subdiv0"))
			|| (((flag == 0) || (flag == false)) && (odiv.id == "subdiv1")))
			return;
		if (odiv.id == "subdiv1")
		{
			if (odiv.innerHTML != "")
				odiv.style.display = "block";
			odiv.id = "subdiv0";
			exPic(cfg.expic, 0, img)
			if ($(odiv).attr("unloadflag") == 1)
			{
				odiv.style.display = "block";
				$(odiv).attr("unloadflag", 2);
				var item = self.getTreeItem($(img.parentNode).attr("node"));
				if (item.child == null)
				{
					odiv.innerHTML = "<span style=color:gray;>������...</span>";
					self.loadnode(item, odiv);
				}
				else
					self.loadnodeok(item, odiv);
			}
		}
		else if (odiv.id == "subdiv0")
		{
			odiv.style.display = "none";
			odiv.id = "subdiv1";
			exPic(cfg.expic, 1, img)
		}
	}

	function exPic(expic, x, obj)
	{
		switch (cfg.expic[0].substr(0, 1))
		{
		case ".":
			obj.className = expic[x].substr(1);
			break;
		case "#":
			obj.innerHTML = "&" + expic[x];
			break;
		default:
			obj.src = expic[x];
		break;
		}
	}
	
	function findparentnode(obj)
	{
		for (var o = obj; o != domobj; o = o.parentNode)
		{
			if (o == null)
				return;
			if (typeof $(o).attr("node") != "undefined")
				return o;
		}
	}

	function translatedata(d)
	{
		if ((cfg.parentNode == "") || (typeof head != "object"))
			return d;
		var keys = cfg.parentNode.split(",");
		var root = [], node, items = [], links = [];
		links[0] = root;
		for (var y = 0; y < d.length; y++)
		{
			for (x = 0; x < keys.length; x ++)
			{
				if (d[y][keys[x]] != items[x])
				{
					node = links[x];
					var value = d[y][keys[x]];
					if (typeof d[y][keys[x] + "_ex"] == "string")
						value = d[y][keys[x] + "_ex"];
					node[node.length] = {item: value, child:[]};
					node = node[node.length - 1].child;
					links[x + 1] = node;
					items[x] = d[y][keys[x]];
				}
			}
			node[node.length] = d[y];
		}
		return root;
	}

	this.click = function (obj, e)		//�¼�:����ʱ������Ĭ�϶���Ϊѡ��ڵ�
	{
		this.select(obj);
	};

	this.expand = function (obj, flag)		//����:չ���ڵ�
	{
		var o = $(obj).find("#BtExTree");
		if (o.length > 0)
			expand(o[0], flag);
	};

	this.reloadNode = function (obj, childclear)		//����:���ؽڵ�
	{
		if ((typeof obj == "undefined") && (typeof selshadow == "object"))
			obj = selshadow.getObj();
		if (obj == undefined)
		{	
			if ((childclear == 1) || (childclear == true))
				return this.loadnode();
			return init();
		}
		$(obj.nextSibling).attr("unloadflag", 1);
		if ((childclear == 1) || (childclear == true))
		{
			var item = this.getTreeItem(obj);
			item.child = null;
		}
		self.expand(obj, false);
		self.expand(obj, true);
	};

	this.select = function (obj)		//����:ѡ��ڵ�
	{
		if (typeof rollshadow == "object")
			rollshadow.hide();
		if (typeof selshadow == "object")
			selshadow.show(obj);
	};

	this.dblclick = function (obj, e)		//�¼�:˫���ڵ㣬Ĭ�϶���Ϊչ��
	{
		this.expand(obj);
	};

	this.contextmenu = function (obj, e)		//�¼�:�Ҽ��˵�
	{
	};

	this.mouseover = function (obj, e)		//�¼�:��껮��
	{
		if (rollshadow == undefined)
			return;
		if (selshadow == undefined)
			return rollshadow.show(obj);
		if (selshadow.isShadow(obj))
			rollshadow.hide();
		else
			rollshadow.show(obj);
	};

	this.getdata = function ()		//����:�õ��ڵ�����
	{
		return data;
	};
	
	this.getHead = function ()	//����:�����ֶ�ͷ��������
	{
		return head;
	};
	
	this.getKeyItem = function(key, value, treedata)			//����:���ݹؼ��ֵõ��ڵ�
	{//ԭ��getnode����׼ȷ.��֮��������������
		if (treedata == undefined)
			treedata = data;
		for (var x = 0; x < treedata.length; x++)
		{
			if (treedata[x][key] == value)
				return treedata[x];
			if ((treedata.child != null) && (typeof treedata.child == "object"))
			{
				var result = this.getnode(key, value, treedata.child);
				if (typeof result == "object")
					return result;
			}
		}
	};

	this.getTreeItem = function(node)		//����:���ݽڵ��ţ��õ��ڵ�,�紫��ڵ�Ϊ�գ���ȡ�õ�ǰѡ��ڵ�
	{
		if ((typeof node == "undefined") && (typeof selshadow == "object"))
		{
			var o = selshadow.getObj();
			if (typeof o == "undefined")
				return;
			node = $(o).attr("node");
		}
		if (typeof node == "object")
			node = $(node).attr("node");
		if (typeof node == "number")
			return data[node];
		var ss = node.split(",");
		var item = data[parseInt(ss[0])];
		for (var x = 1; x < ss.length; x++)
			item = item.child[parseInt(ss[x])];
		return item;
	};

	this.getSelItemKeyValue = function()		//����:���ѡ���������
	{
		var item = self.getTreeItem();
		if (item == undefined)
			return;
		var head = self.getHead();
		if (head == undefined) 
		{
			if (item.ID != undefined)
				return item.ID;
			return item.item;
		}	
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].bPrimaryKey == 1)
				break;
		}
		return item[head[x].FieldName];		
	};
	

	this.setNodeText = function (node, text)		//����:���ýڵ��ı�
	{
		var item = getTreeItem(node);
		item.item = text;
	};
	
	this.getNodeObj = function(key, value)		//����:�õ��ڵ��DOM����
	{
		var node = value;
		if ((typeof key == "string") && (key != ""))
			node = self.getItemNode(key, value);
		if (typeof node == "undefined")
			return;
		var objs = $(domobj).find("DIV");
		for (var x = 0; x < objs.length; x++)
		{
			if ($(objs[x]).attr("node") == node)
				return objs[x];
		}
	};
	
	this.getItemNode = function(key, value, treedata, initnode)		//����:���ݹؼ��ֵõ��ڵ���
	{
		if (typeof treedata == "undefined")
			treedata = data;
		if (typeof initnode == "undefined")
			initnode = "";
		var node;
		for (var x = 0; x < treedata.length; x++)
		{
			if (initnode == "")
				node = initnode + x;
			else
				node = initnode + "," + x;
			if (value == treedata[x][key])
				return node;
			if ((treedata[x].child != null) && (typeof treedata[x].child == "object"))
			{
				node = this.getItemNode(key, value, treedata[x].child, node);
				if (typeof node != "undefined")
					return node;
			}
		}
	};

	this.setexpic = function(pic)		//����:���ýڵ�չ��ͼ��
	{
		cfg.expic = pic;
		init();
	};

	this.waiting = function (s)		//����:���صȴ�
	{
		if (typeof domobj != "object")
			return;
		if (typeof s == "undefined")
			s = "������...";
		domobj.innerHTML = s;		
	};

	this.setdata = function(d, h)		//����:��������
	{
		if (typeof h == "object")
			head = h;
		data = translatedata(d);
		if (typeof selshadow == "object")
				selshadow.hide();
		if (typeof rollshadow == "object")
			rollshadow.hide();
		init();
	};

	this.setDataParentNode = function (node)		//����:���ø��ڵ�
	{
		cfg.parentNode = node;
	}

	this.getsel = function ()		//����:�õ�ѡ��ڵ����
	{
		return selshadow;
	};

	this.append = function(d)		//����:���ӽڵ�
	{
		var len = data.length;
		data.splice(len, 0, d);
		var tag = "";
		for (var x = len; x < data.length; x++)
			tag += getnodetag(data[x], 0, x);
		domobj.insertAdjacentHTML("beforeEnd", tag);
	};
	
	this.remove = function ()	//����:�Ƴ�������δʵ��
	{
	};

	this.loadnode = function(item, odiv)		//�¼�:��̬�����ӽڵ㣬Ĭ��Ϊ���ؿ�
	{
		item.child = [];
		this.loadnodeok(item, odiv);
	};

	this.loadnodeok = function(item, odiv)		//����:��̬�����ӽڵ����õķ�������չ�ּ�����ɵ���
	{
		if (odiv.firstChild != null)
			$(odiv.firstChild).remove();		//odiv.firstChild.removeNode(true);
		var node = $(odiv.previousSibling).attr("node");
		var ss = node.split(",");
		var tag = "";
		for (var x = 0; x < item.child.length; x++)
			tag += getnodetag(item.child[x], ss.length, node + "," + x);
		odiv.innerHTML = tag;
		if (tag == "")
			odiv.style.display = "none";
		odiv.removeAttribute("unloadflag");
	};

	this.attachEditor = function (editor)		//����:���ڵ�󶨶�̬�༭��
	{
	};
	
	this.detachEditor = function ()		//����:���ڵ�󶨵Ķ�̬�༭��
	{
	};
		
	this.setdomobj = function (obj)		//����:�����󶨵�������DOM����
	{
		if (typeof domobj == "object")
		{
			$(domobj).off("click", mouseevent);
			$(domobj).off("dblclick", mouseevent);
			$(domobj).off("mouseover", mouseevent);
			$(domobj).off("contextmenu", mouseevent);
		}
		domobj = obj;
		if (typeof obj != "object")
			return;
		$(domobj).on("click", mouseevent);
		$(domobj).on("dblclick", mouseevent);
		$(domobj).on("mouseover", mouseevent);
		$(domobj).on("contextmenu", mouseevent);
		init();
	}

	this.getdomobj = function ()	//����:����dom����
	{
		return domobj;
	};
	
	this.count = function (item)		//����:����ڵ�����
	{
		if (typeof item != "object")
			item = data;
		if (typeof item.length != "number")
		{
			if (typeof item.child == "object")
				return this.count(item.child) + 1;
			return 1;
		}
		var cnt = 0;
		for (var x = 0; x < item.length; x++)
		{
			if ((typeof item[x].child == "object") && (item[x].child != null))
				cnt += this.count(item[x].child);
		}
		return cnt + item.length;
	};

	cfg = $.jcom.initObjVal({bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff",selbkcolor:"#B7E3FE", itemstyle:"",
			imgstyle:"", transText:1, nowrap:1, rightmenu:null,initDepth:3, nIndent:20,vpadding:1, parentNode:"", 
			expic:[".TreeArrawOpen", ".TreeArrawClose"], dishint:0}, cfg);

	if (typeof cfg.selbkcolor == "string")
		selshadow = new $.jcom.CommonShadow(0, cfg.selbkcolor);
	if (typeof cfg.rollbkcolor == "string")
		rollshadow = new $.jcom.CommonShadow(0, cfg.rollbkcolor);
	this.setdomobj(domobj);
};

$.jcom.Cascade = function(domobj, data, cfg)	//��:����ѡ���
{
	var self = this;
	var oSels = [];		//ÿһ����ѡ�����
	var selObj;			//��ǰ��ѡ�������һ��
	var casItems = [];	//ÿһ������б�
	var rollShadow;
	var bookmark;
	function init()
	{
		if (typeof domobj != "object")
			return;
		var tag = "";
		for (var x = 0; x < cfg.title.length; x++)
			tag += getLegend(x);
		
		$(domobj).html(tag);
		if (typeof data == "object")
			eventSet(1);
		self.reload();
	}
	
	function getLegend(x)
	{
		var tag = "<fieldset><legend tabindex=" + x + " style='FONT-SIZE:9pt;padding:0px 10px 0px 10px'>" +
			"<span class=TitleButton style=font-size:16px;>&#9698&nbsp;</span><span id=TitleText style='" +cfg.tcss + "'>" + cfg.title[x] + 
			"</span>&nbsp;<span class=CasInfo></span></legend>";
		var style = " style='padding:0px 20px;overflow:hidden;";
		if ((x < cfg.itemimg.length) && (cfg.itemimg[x].substr(0, 9) == "TimeAxis."))	//ʱ����
			style = " style='line-height:20px;padding:0px 30px;";
//		if (domobj.style.height != "")
//			style += "overflow-y:auto;border:1px solid red";
		style += "'";
		return tag + "<ul class=BodyDiv" + style + "></ul></fieldset>";
	}
	
	function eventSet(flag)
	{
		if ((flag & 2) > 0)
		{
			$("legend", domobj).off("click", ClickTitle);
			$(".BodyDiv", domobj).off("click", ClickItem);
			$(".BodyDiv", domobj).off("mouseover", RollItem);
			$(".BodyDiv", domobj).off("dblclick", DblClickItem);
		}
		if ((flag & 1) > 0)
		{
			$("legend", domobj).on("click", ClickTitle);
			$(".BodyDiv", domobj).on("click", ClickItem);
			$(".BodyDiv", domobj).on("mouseover", RollItem);
			$(".BodyDiv", domobj).on("dblclick", DblClickItem);
		}
	}
	
	function ClickTitle(e)
	{
		var depth = e.target.parentNode.tabIndex;
		var b = $(".TitleButton", domobj).eq(depth);
//		var o = $(".BodyDiv", domobj).eq(depth);
		var o = $(e.target.parentNode).next();
		if (o.css("display") == "none")
		{
			o.css("display", "");
			b.html("&#9698&nbsp;");	//�� 
			$(".CasInfo", domobj).eq(depth).html("");
		}
		else
		{
			o.css("display", "none");
			b.html("&#9655&nbsp;");
			var obj = self.getsel(depth);
			if (typeof obj == "object")
				$(".CasInfo", domobj).eq(depth).html(obj.innerHTML);
		}
		self.onClickTitle(e.target, depth);
	}

	this.onClickTitle = function(obj, depth)	//�¼�:�������ʱ����
	{
	};
	
	function RollItem(e)
	{
		if (rollShadow == undefined)
			return;
		var obj = e.target;
		if (obj.tagName != cfg.itemtag.toUpperCase())
			return rollShadow.hide();
		var node = $(obj).attr("node");
		if (node == undefined)
			return rollShadow.hide();
		for (var x = 0; x < oSels.length; x++)
		{
			if (oSels[x].isShadow(obj))
				return rollShadow.hide();
		}
		rollShadow.show(obj);
	}

	function ClickItem(e)
	{
		var tag = cfg.itemtag.toUpperCase();
		var obj = e.target;
		if (obj.tagName != tag)
		{
			obj = obj.parentNode;
			if  (obj.tagName != tag)
				return;
		}
		
		var item = self.select(obj);
		self.onclick(e.target, item);
	}
	
	this.AddLegend = function (title, items, img)	//����:��̬����һ��ѡ���
	{
		var index = AddTitle(title, img);
		if (index < 0)
			return;
		eventSet(2);
		var tag = getLegend(index);
		$(domobj).append(tag);
		eventSet(1);
		var node = $(selObj).attr("node");	
		oSels[oSels.length] = new $.jcom.CommonShadow(0, cfg.selbkcolor);
		self.loadLegend(items, node);
	};
	
	function AddTitle(title, img)
	{
		var index = cfg.title.length;
		for (var x = 0; x < index; x++)	//��������
		{
			if (cfg.title[x] == title)
				return -1;
		}
		
		cfg.title[index] = title;
		if (typeof img == "string")
			cfg.itemimg[index] = img;
		return index;
	}
	this.AddUserLegend = function (title, option)	//����:��̬����һ���Զ����ѡ���
	{
		var index = AddTitle(title);
		if (index < 0)
			return;
		option = $.jcom.initObjVal({LegendID: "UserLegend", TitleID: "UserTitle", divID: "UserDiv"}, option);
		var tag = "<fieldset id=UserFieldSet><legend tabindex=" + casItems.length + " id=" + option.LegendID + " style='FONT-SIZE:9pt;padding:0px 10px 0px 10px'>" +
			"<span class=TitleButton style=font-size:16px;>&#9698&nbsp;</span><span id=" + option.TitleID +  " style='" +cfg.tcss + "'>" + title + 
			"</span>&nbsp;<span class=CasInfo></span></legend><div id=" + option.divID + " style='padding:0px 20px;overflow:hidden;'></div></fieldset>";
		$(domobj).append(tag);
		$("#UserLegend", domobj).on("click", ClickTitle);
		return $("#" + option.divID, domobj);
	};
	
	this.RemoveLegend = function ()	//����:��̬ɾ�����һ��ѡ���
	{
		if (cfg.title.length == 1)	//������һ��
			return;
		if (typeof selObj == "object")
		{
			var node = $(selObj).attr("node").split(",");
			if (node.length == cfg.title.length)
				selObj = self.getsel(node.length - 2);
		}
		var o = $("fieldset", domobj).last();
		var id = o[0].id;
		o.remove();
		cfg.title.splice(cfg.title.length - 1, 1);
		if (id == "UserFieldSet")
			return;
		oSels.splice(oSels.length - 1, 1);
		if (casItems.length > oSels.length)
			return casItems.splice(casItems.length - 1, 1);
	}
	
	this.loadLegend = function(items, node)	//����:����ѡ��������,node����һ������ѡ���Ľڵ��
	{
		var depth = 0;
		if ((node == undefined) || (node == ""))
			node = "";
		else
		{
			var ss = node.split(",");
			depth = ss.length;
			node += ",";
		}
		casItems[depth] = items;
		if (items == undefined)
			items = "";
		if (typeof items == "string")
		{
			$(".BodyDiv", domobj).eq(depth).html(items);
			return;
		}
		var tag = "";
		var img = "";
		if (cfg.itemimg.length > depth)
			img = cfg.itemimg[depth];
		if (img.substr(0, 9) == "TimeAxis.")	//ʱ����
		{
			var field = img.substr(9);
			tag += getTimeAxisTag(items, node, field);
		}
		else
		{
			img =  $.jcom.getItemImg(img, cfg.imgstyle);
			for (var x = 0; x < items.length; x++)
				tag += getItemTag(items[x], node + x, img);
		}
		$(".BodyDiv", domobj).eq(depth).html(tag);
		
	}
	
	function getItemTag(item, node, img)
	{
		if (typeof item.img == "string")
			img = $.jcom.getItemImg(item.img, cfg.imgstyle);
		var check = "";
		if (cfg.checkbox == 1)
			check = "<input type=checkbox>";
		return "<" + cfg.itemtag + " node='" + node + "' style='" + cfg.itemstyle + "'>" + check + img + item.item + "</" + cfg.itemtag + ">";
	}
	
	
	function getTimeAxisTag(items, node, field)
	{
		var tag = "", t = "";
		for (var x = 0; x < items.length; x++)
		{
			if ($.jcom.GetDateTimeString(items[x][field], 1) != t)
			{
				t = $.jcom.GetDateTimeString(items[x][field], 1);
				tag += "<div style='margin-left:-7px;margin-top:-1px;font-size:44px;color:green;'>&#9671<span style=vertical-align:top class=timeline>" + t + "</span></div>";
			}
			tag += "<" + cfg.itemtag + " node=" + (node + x) + " class=timebody>" + items[x].item + "</" + cfg.itemtag + ">";
		}
		tag += "<span class=circle style='margin-left:0px;'></span>";
		return tag;
	}
	
	this.getCheckedItems = function (depth)	//����:�õ���ѡ������ݼ�
	{
		var o = $(".BodyDiv", domobj).eq(depth);
		var checks = $("input[type='checkbox']", o);
		var items = [];
		for (var x = 0; x < checks.length; x++)
		{
			if (checks.eq(x).prop("checked"))
				items[items.length] = casItems[depth][x];
		}
		return items;
	};
	
	this.loadnode = function(item, node)		//�¼�:��̬�����ӽڵ㣬Ĭ��Ϊ���ؿ�
	{
		item.child = [];
		this.loadnodeok(item, node);
	};

	this.loadnodeok = function(item, node)		//����:��̬�����ӽڵ����õķ�������չ�ּ�����ɵ���
	{
		self.loadLegend(item.child, node);
	};
	
	this.getNodeItems = function(node)	//����:���ݽڵ㣬��ýڵ������
	{
		if (node == undefined)
		{
			if (selObj == undefined)
				return;
			return self.getNodeItems(selObj);
		}
		if (typeof node == "object")
			node = $(node).attr("node");
		var ss = node.split(",");
		var items = [];
		for (var x = 0; x < ss.length; x++)
			items[x] = casItems[x][parseInt(ss[x])];
		return items;
	};
	
	this.getNodeTitle = function (node)	//����:���ݽڵ�õ��ڵ�ı���
	{
		var items = self.getNodeItems(node);
		if (items == undefined)
			return "";
		var title = items[0].item;
		for (var x = 1; x <items.length; x++)
			title += "&bull;" + items[x].item;
		return title;
	};
	
	this.getObjByNode = function (node)	//����:���ݽڵ�ŵõ�DOM����
	{
		return  $(cfg.itemtag + "[node='" + node + "']", domobj)[0];
	}
	
	this.select = function(obj)	//����:ѡ�����
	{
		if ((typeof obj == "string") || (typeof obj == "number"))
			obj = self.getObjByNode(obj);
		if (typeof rollShadow == "object")
			rollShadow.hide();
		if (obj == undefined)
		{
			if (selObj == undefined)
				return;
			var node = $(selObj).attr("node");
			var ss = node.split(",");
			var depth = ss.length - 1;
			oSels[depth].show(obj);
			if (depth > 0)
				selObj = oSels[depth - 1].getObj();
			else
				selObj = obj;		
			self.onPageChange(obj);
			return;
		}
		var node = $(obj).attr("node");
		var ss = node.split(",");
		var depth = ss.length - 1;
		selObj = obj;
		oSels[depth].show(obj);
		if ($(".BodyDiv", domobj).eq(depth).css("display") == "none")
			$(".CasInfo", domobj).eq(depth).html(obj.innerHTML);
		for (var x = depth + 1; x < cfg.title.length; x++)
				$(".CasInfo", domobj).eq(x).html("");
		var items = self.getNodeItems(node);
		var item = items[items.length - 1];
		if (ss.length < cfg.title.length)
		{
			if (item.child == null)
			{
				self.loadLegend("������...", node);
				self.loadnode(item, node);
			}
			else
				self.loadLegend(item.child, node);
		}
		self.onPageChange(obj, item);
		return item;
	}
	
	this.onPageChange = function (obj, item)	//�¼�:ѡ���µ���󷢳���֪ͨ
	{
	};
	
	this.onclick = function(obj, item)	//�¼�:����¼�
	{
	};
	
	function DblClickItem(e)
	{	
		var item = self.getselItem();
		self.ondblclick(e.target, item);
	}
	
	this.ondblclick = function(obj, item)	//�¼�:˫���¼�
	{	
	};
	
	this.getsel = function (depth)	//����:��õ�ǰѡ����
	{
		if (depth == undefined)
			return selObj;
		if ((depth < 0) || (depth >= oSels.length))
			return;
		return oSels[depth].getObj();
	};
	
	this.getdata = function ()	//����:��õ�һ��ѡ�������
	{
		return data;
	};
	
	this.getCasItems = function (depth)	//����:���ָ����ѡ��������
	{
		if (depth == undefined)
			return casItems;
		return casItems[depth];
	};
	
	this.getselItem = function (depth)	//����:��ñ�ѡ�������
	{
		if (depth == undefined)
			depth = oSels.length - 1;
		var obj = self.getsel(depth);
		if (obj == undefined)
			return;
		var items = self.getCasItems(depth);
		var node = $(obj).attr("node");
		var ss = node.split(",");
		return items[parseInt(ss[ss.length - 1])];
	};
	
	this.addItem = function (item, depth)	//����:����һ��ѡ����
	{
		if (depth == undefined)
			depth = oSels.length - 1;
		var items = casItems[depth];
		items[items.length] = item;
		var img = "";
		if (cfg.itemimg.length > depth)
			img =  $.jcom.getItemImg(cfg.itemimg[depth], cfg.imgstyle);
		tag = getItemTag(item, items.length - 1, img);
		$(".BodyDiv", domobj).eq(depth).append(tag);
	};
	
	this.removeItem = function (item, depth)	//����:�Ƴ�һ��ѡ����
	{
		if (item == undefined)
			item = self.getSelItem(depth);
		if (depth == undefined)
			depth = oSels.length - 1;
		var items = casItems[depth];
		var node = "";		//��ʱֻ���ǽ���һ��ʱ�����
		for (var x = 0; x < items.length; x++)
		{
			if (items[x] == item)
			{
				if (typeof selObj == "object")
				{
					oSels[oSels.length - 1].hide();
					selObj = undefined;
				}
				items.splice(x, 1);
				self.loadLegend(items, node);
//				$(cfg.itemtag + "[node='" + node + x + "']").remove();
				break;
			}
		}
	};

	this.getNodeByText = function(depth, text)	//����:�������ݻ�ö�Ӧ��ѡ����
	{
		for (var x = 0; x < casItems[depth].length; x++)
		{
			if (casItems[depth][x].item == text)
				return x;
		}
	};
	
	this.SkipPage = function (delta, bRun)	//����:��ת��ָ������Ŀ
	{
		var sel = self.getsel();
		var data = self.getdata();
		if (data.length == 0)
			return;
		if (sel == undefined)
		{
			if (bRun)
			{
				var node = getBookMarkNode(0);
				self.select(node);
				var obj = $(cfg.itemtag + "[node='" + node + "']", domobj)[0];
				self.onclick(obj, data[node]);
			}
			return cfg.prep + data[0].item;
		}
		var	node = $(sel).attr("node");
		if (delta == 0)
			return self.getNodeTitle(node);
		var items = self.getNodeItems(node);
//		var casItems = self.getCasItems();
//		var item = items[items.length - 1];

		if ((typeof casItems[items.length] == "object") && (casItems[items.length].length > 0) && (delta == 1))
		{//��������¼�ѡ��򣬾���ת���¼�ѡ��򣬽����delta = 1ʱ��Ч
			if (bRun)
			{
				var index = getBookMarkNode(items.length);
				var obj = $(cfg.itemtag +  "[node='" + node + "," + index + "']", domobj)[0];
				if (typeof obj == "object")
				{
					self.select(obj);
					self.onclick(obj, casItems[items.length][index]);
				}
			}
			return cfg.prep + casItems[items.length][0].item;
		}
		
		var ss = node.split(",");
		for (var x = items.length - 1; x >= 0; x--)
		{
			node = parseInt(ss[x]) + delta;
			if (casItems[x].length > node)
			{
				var item = casItems[x][node];
				ss[ss.length - 1] = node;
				node = ss.join(",");
				if (bRun)
				{
					self.select(node);
					var obj = $(cfg.itemtag + "[node='" + node + "']", domobj)[0];
					self.onclick(obj, item);
				}
				return self.getNodeTitle(node);
//				return cfg.prep + item.item;			
			}
			ss.splice(x, 1);
		}
	};
	
	function getBookMarkNode(depth)
	{
		if (typeof bookmark != "string")
			return 0;
		
		var ss = bookmark.split("&bull;");
		if (ss.length == depth + 1)
			bookmark = undefined;
		
		var	node = self.getNodeByText(depth, ss[depth]);
		if (node == undefined)
		{
			bookmark = undefined;
			return 0;
		}
		return node;
	}
	
	this.goBookMark = function(bk)	//����:��ת����Ǵ�
	{
		bookmark = bk;
		self.select();
		if (self.getCasItems(0).length > 0)
			self.SkipPage(1, true);
	};
	
	this.reload = function(d, node)	//����:���¼���
	{
		if (typeof d == "object")
			data = d;
//		oSels = [];
//		selObj = undefined;
		self.loadLegend(data, node);
	};

	this.config = function (c) //����:�ı�����
	{
		cfg = $.jcom.initObjVal(cfg, c);
		return cfg;
	};
	
	this.setdomobj = function (obj)		//����: ���°�DOM����
	{
		if (typeof domobj == "object")
			eventSet(2);
		domobj = obj;
		init();
	};

	cfg = $.jcom.initObjVal({title:[""], tcss:"", padding: "8px", itemstyle:"", selbkcolor:"#B7E3FE", prep:"", itemtag:"li", 
		itemimg:[""], rollDef: "#f8f8ff", checkbox:0, itemstyle:"display:inline-block;padding-right:8px;"}, cfg);
	for (var x = 0; x < cfg.title.length; x++)
		oSels[x] = new $.jcom.CommonShadow(0, cfg.selbkcolor);
	if (cfg.rollDef != false)
	{
		if (typeof cfg.rollDef == "string")
			rollShadow = new $.jcom.CommonShadow(0, cfg.rollDef);
		else if (typeof cfg.rollDef == "object")
			rollShadow = cfg.rollDef;
	}
	
	init();
};

$.jcom.FormBase = function(domobj, fields, record, cfg)	//��:�򵥱���ͼ
{//������FormView��Ļ���
//domobj:����dom����
//fields:�ֶζ��壬��ƽ̨�ı�����һ�£��μ�ƽ̨,����Ϊ������Ա�Ķ������飺
//CName:""--��������--
//EName:""--Ӣ������--
//nShow:1--�Ƿ���ʾ--
//nReadOnly:0--�Ƿ�ֻ��--
//nRequired: 0--�Ƿ����--
//InputType: 1--��������ͣ��μ�ƽ̨����--
//Relation:""--�������-- 
//Quote:""--ö����������--
//nCol:1--��λ��--
//nRow:1--��λ��--
//nWidth:1--���--
//nHeight:1--�߶�--
//Hint:""--������ʾ--
//record:���ݼ�¼
//cfg:����ѡ���������
//title:""--���ڲ�����--
//action:location.pathname + "?FormSaveFlag=1&Ajax=1"--�����ύ��ַaction--
//formtype:2--������--1-�鿴, 2-�޸�, 3-��ӡ,4-�Զ���,5-���,6-�༭, 7-��ѯ, 8-ҳ��
//nStyle:2--nStyle--
//nCols:1--����������--
//headTxt: ""--ҳͷ���ı�-- 
//footTxt: ""--ҳ�ŵ��ı�-- 
//requireTag:"<span style=color:red>*</span>"--�����ֶεı�ʶ--
//width:0--width--
//height:0--height--
//viewpage:""--viewpage--, 
//ncss:"1"--��ѡ�õ�css���--
//target: "FormViewTarget"--����Target--
//spaninput:0--�Ƿ���SPANȡ�������--, 
//nowrap:1--�Ƿ���������	
//enumurl:"../com/seleenum.jsp?AjaxMode=1&EnumType="--��ȡö�����ķ�������ַ--
//quoteimg:"../com/pic/search.png"--�������ĸ������������ͼ��--
//timeout:20--�ύ��ʱ���ʱ��--
//itemstyle:""--���ı��ķ��--
//valstyle:""--�������ķ��--
//submitbutton:"�ύ"--�ύ��ť������--


	var self = this;
	var form, dateeditor;
//	this.enumurl = "../com/seleenum.jsp?AjaxMode=1&EnumType=";
//	this.quoteimg = "../com/pic/search.png";
	this.initBase = function()	//����:��ʼ����
	{
		if ((typeof domobj != "object") || (fields == undefined))
			return;
		var tag = "<table border=0 cellpadding=3 width=100% cellspacing=1 class=jformtable" + cfg.ncss + "><tr>";
		if ((cfg.title != "") && (cfg.title != "null"))
			tag += "<td colspan=" + cfg.nStyle * cfg.nCols + " class=jformtitle" + cfg.ncss + ">" + cfg.title + "</td></tr><tr>";
		var htag = "", nowrap = "";
		var rows = 1, cols = 0;
		if (cfg.nowrap == 1)
			nowrap = " nowrap";
		for ( var x = 0; x < fields.length; x++)
		{
			fields[x] = $.jcom.initObjVal({CName:"", EName:"", nShow:1, nReadOnly:0, nRequired: 0, InputType: 1, 
				Relation:"", Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},  fields[x]);
			fields[x].editor = undefined;
			self.getquote(fields[x]);
			cols += fields[x].nWidth;
			if ((rows < fields[x].nRow) || (cols > cfg.nCols))
			{
				tag += "</tr><tr>";
				rows = fields[x].nRow;
				cols = fields[x].nWidth;
			}
			var required = "";
			if ((fields[x].nRequired == 1) && ((cfg.formtype == 2) || (cfg.formtype == 4) || (cfg.formtype == 6)))
				required = cfg.requireTag;
			var objtag = "";
			if ((fields[x].nShow == 0) || (fields[x].nWidth == 0) || (fields[x].InputType == 21))
				htag += "<input type=hidden name=" + fields[x].EName + ">";
			else
			{
				objtag = self.getFieldTag(fields[x]);
				switch (cfg.nStyle)
				{
				case 1:
					tag += "<td id=T1_" + fields[x].EName + nowrap + " class=jformval" + cfg.ncss + " colspan=" + fields[x].nWidth + ">" + fields[x].CName + required + "<br>" + objtag + "</td>";
					break;
				case 2:
					if (fields[x].CName == "$none")
						tag += "<td id=T2_" + fields[x].EName + " class=jformval" + cfg.ncss + " colspan=" + (fields[x].nWidth * 2) + ">" + objtag + "</td>";
					else
						tag += "<td id=T1_" + fields[x].EName + nowrap + " class=jformcon" + cfg.ncss + " style='" + cfg.itemstyle + "'>" + fields[x].CName + required + 
							"</td><td id=T2_" + fields[x].EName + " class=jformval" + cfg.ncss +
							" colspan=" + (fields[x].nWidth * 2 - 1) + ">" + objtag + "</td>";
					break;
				case 3:
					tag += "<td id=T1_" + fields[x].EName + nowrap + " class=jformcon" + cfg.ncss + ">" + fields[x].CName + required + 
						"</td><td id=T2_" + fields[x].EName + " class=jformval" + cfg.ncss + " width=40% colspan=" + (fields[x].nWidth * 3 - 2) + ">" + objtag + 
						"</td><td id=T3_" + fields[x].EName + " style=width:30%;color:gray;>" + fields[x].Hint + "</td>";
					break;
				}
			}
		}
		tag += "</tr></table>" + htag + getbar();
		if (cfg.formtype != 8)
			tag = "<form action=" + cfg.action + " target=" + cfg.target + " method=POST name=ActionSave>" + tag + "</form>";
		domobj.innerHTML = tag;
		for (var x = 0; x < fields.length; x++)
			self.prepare(fields[x]);
		self.setRecord(record);
		form = domobj.firstChild;
		$(form).on("keydown", mkevent);
		$(form).on("keypress", mkevent);
		$(form).on("mousedown", mkevent);
		$(form).on("click", mkevent);
		$(form).on("dblclick", mkevent);
		$(form).on("change", mkevent);
		$(form).on("contextmenu", mkevent);
		$(form).on("submit", self.beforesubmit);
		$(domobj).on("resize", resize);
		resize();
	};

	function resize()
	{
		if ((domobj.style.overflow == "") || (domobj.style.overflow == "visible"))
			return;
		var divs = $(domobj).find("[name=SizeDiv]");
		if (divs.length != 1)
			return;
		var h = domobj.offsetHeight - form.offsetHeight + divs[0].offsetHeight - 60;
		if (h < 50)
			h = 50;
		if (h > domobj.offsetHeight)
			h = domobj.offsetHeight;
		divs[0].style.height = h + "px";
		window.status = domobj.offsetHeight + "," + form.offsetHeight + "," + divs[0].offsetHeight + "," + h;
	}

	this.getFieldTag = function (field, prep, itemstyle, valstyle)	//����:�õ��ֶε�HTML����
	{
		var tag = "", readonly = "";
		
		if ((cfg.formtype == 1) || (cfg.formtype == 3) || (cfg.formtype == 5) || (cfg.formtype == 8) || (field.nReadOnly == 1))
			readonly = " readonly";
		var EName = field.EName;
		if (typeof prep == "string")
			EName = prep + EName;
		if (typeof itemstyle != "string")
			itemstyle = cfg.itemstyle;
		if (typeof valstyle != "string")
			valstyle = cfg.valstyle;
		var style = valstyle;
		if (style.substr(style.length - 1) != ";")
			style += ";";
		style += itemstyle;
			
		switch (field.InputType)
		{
		case 1:		//�༭��
			if (cfg.spaninput == 1)
			{
				var prop = "";
				if (readonly == "")
					prop = " CONTENTEDITABLE";
				if ((field.Quote == "") || (field.data == "~δʵ��~") || (field.data === ""))
					return "<span id=" + EName + prop + " style='overflow:hidden;" + style + "'></span>";
				return "<input type=hidden name=" + EName + "><span id=Alias_" + EName + prop + " style='overflow:hidden;" + style + "'>";
			}
			if ((field.Quote == "") || (field.data == "~δʵ��~") || (field.data === ""))
				return "<input type=text class=text name=" + EName + readonly + " style='" + style + "'>" + getFieldRelation(field.Relation);
			return "<input type=hidden name=" + EName + "><input type=text class=text name=Alias_" + EName + readonly + " style='" + style + "'>";
		case 2:		//����
			if ((field.Quote == "") || (field.data == "~δʵ��~") || (field.data === ""))
				return "<input type=checkbox value=1 name=" + EName + readonly + " style='" + style + "'>";
			return "<div id=" + EName + "_DIV style='min-height:" + field.nHeight * 30 + "px;" + style + "'></div>";
			break;
		case 3:		//��ѡ��
			return "<div id=" + EName + "_DIV style='min-height:" + field.nHeight * 30 + "px;" + style + "'></div>";
		case 4:		//������
			return "<select name=" + EName + " style='" + style + "'></select>";
		case 5:		//�ı���
			return "<textarea class=txt style='" + style + "'; name=" + EName + " rows=" + field.nHeight + readonly + "></textarea>" + getFieldRelation(field.Relation);
		case 6:		//�����
			return "<input type=password name=" + EName + readonly + " style='" + style + "'>";
		case 7:		//���ı���
			if (field.nHeight < 100)
				return "<div class=spantext id=" + EName + "_DIV style='overflow:hidden;height:" + field.nHeight * 30 + "px;" + style + "'></div>";
			return "<div class=spantext id=" + EName + "_DIV name=SizeDiv style='overflow:hidden;height:" + field.nHeight * 30 + "px;" + style + "'></div>"
		case 8:		//�Զ�������
			tag = "<input type=hidden name=" + EName + "><div id=" + EName + "_DIV style='overflow:hidden;min-height:" + field.nHeight * 30 + "px;" + style + "'>";
			if (field.Relation == "*Object")
				return tag + "</div>";
			if (field.Relation != "")
			{
				if (field.Relation.substr(0, 1) == "*")
					return tag + field.Relation.substr(1) + "</div>";
				else
					return field.Relation;
			}
			return "";
		case 9:		//��Ͽ�
		case 10:	//���
		case 11:	//����
		case 12:	//��ҳ
		case 13:	//��
		case 14:	//��ͼ
		case 15:	//ͼƬ
		case 16:	//ҳ��
			break;
		case 17:	//��ϸ��
			tag = "<div id=BTS_" + EName + " style='" + itemstyle + "'>" + field.Hint;
			if (readonly == "")
				tag += "&nbsp;&nbsp;<input type=button id=InsertDetail style='" + itemstyle + "' value=����>&nbsp;<input type=button id=DelDetail style='" + itemstyle + "' value=ɾ��>";
			return "<div id=" + EName + "_DIV style='overflow:hidden;min-height:" + (40 + field.nHeight * 30) + "px;'>" + tag + "</div>" + LoadDetail(field) +  "</div>";
			break;
		case 18:	//��ѡ��
			return "<input type=hidden name=" + EName + "><div id=" + EName + "_DIV style='min-height:" + field.nHeight * 30 + "px;" + style + "'></div>";
			break;
		case 22:	//OFFICE�ĵ�
		case 23:	//�ļ���
		case 24:	//Ԥ����
			break;
		case 21:	//���ؿ�
			break;
		}
		return tag;
	};

	function LoadDetail(field)
	{
		var tag = "<table id=" + field.EName + "_SubTable border=0><tr><td></td>";
		for (var x = 0; x <field.SubFields.length; x++)
		{
			if ((field.SubFields[x].bShow == 1) && (field.SubFields[x].nWidth > 0) && (field.SubFields[x].InputType != 21))
			{
				tag += "<td id=T1_" + field.EName + "_" + field.SubFields[x].EName + "><div style='width:" + field.SubFields[x].nWidth +
					"px;overflow:hidden;" + cfg.itemstyle + "'>" + field.SubFields[x].CName;
				if ((field.SubFields[x].nRequired == 1) && ((cfg.formtype == 2) || (cfg.formtype == 4) || (cfg.formtype == 6)))
					tag += cfg.requireTag;
				tag += "</div></td>";
			}
		}
		return tag + "</table>";
	}

	function InsertDetail(e)
	{
		var field = self.getFields(e.target.parentNode.id.substr(4));
		self.InsertDetailLine(field, record[field.EName][0]);
	}
	
	this.InsertDetailLine = function(field, rec)	//����:��ϸ���в���һ��
	{
		var oTab = $("#" + field.EName + "_SubTable", domobj);
		var index = oTab[0].rows.length;
		var tag = "<tr><td>" + index;
		for (var x = 0; x <field.SubFields.length; x++)
		{
			if ((field.SubFields[x].bShow == 1) && ((field.SubFields[x].nWidth == 0) || (field.SubFields[x].InputType == 21)))
				tag += "<input type=hidden name=" + field.EName + "_" + field.SubFields[x].EName + " value=''>";
			else if (field.SubFields[x].bPrimaryKey == 1)
				tag += "<input type=hidden name=I_" + field.EName + "_DataID value=''>";
		}
		tag += "</td>";
		for (var x = 0; x <field.SubFields.length; x++)
		{
			if ((field.SubFields[x].bShow == 1) && (field.SubFields[x].nWidth > 0) && (field.SubFields[x].InputType != 21))
			{
				self.getquote(field.SubFields[x]);
				tag += "<td id=T2_" + field.EName + "_" + field.SubFields[x].EName + "><div style='width:" + field.SubFields[x].nWidth + "px;overflow:hidden;'>" +
					self.getFieldTag(field.SubFields[x], field.EName + "_", 0, "width:" + (field.SubFields[x].nWidth - 4) + "px;") + "</div></td>";
			}
		}
		oTab.append(tag + "</tr>");
		for (var x = 0; x <field.SubFields.length; x++)
		{
			if ((field.SubFields[x].bShow == 1) && (field.SubFields[x].nWidth > 0) && (field.SubFields[x].InputType != 21))
				self.prepare(field.SubFields[x], field.EName + "_", index - 1);
		}
		for (var key in rec)
		{
			self.FieldValue(field.EName + "_" + key, rec[key], index - 1);
		}
	};
	
	function DelDetail(e)
	{
		var field = self.getFields(e.target.parentNode.id.substr(4));
		var oTab = $("#" + field.EName + "_SubTable", domobj);
		if (oTab[0].rows.length <= 2)
			return alert("����ɾ��������Ҫ��һ��");
		if (field.CurrentIndex == undefined)
			return alert("����ѡ��ǰ��");
		if (window.confirm("�Ƿ�ɾ����ǰ�У���" + field.CurrentIndex + "��)?"))
		{
			self.DelDetailLine(field, field.CurrentIndex);
			field.CurrentIndex = undefined;
		}
	}
	
	this.DelDetailLine = function(field, index)	//����:��ϸ����ɾ��һ��
	{
		var oTab = $("#" + field.EName + "_SubTable", domobj);
		oTab[0].rows[index].removeNode(true);
		for (var x = 1; x < oTab[0].rows.length; x++)
			oTab[0].rows[x].cells[0].innerText = x;
	};
	
	function setCurrentDetail(e)
	{
		var ss = e.target.name.split("_");
		var field = self.getFields(ss[0]);
		if (field == undefined)
			return;
		var tr = e.target.parentNode.parentNode.parentNode;
		if (field.CurrentIndex != undefined)
			$(tr.parentNode.rows[field.CurrentIndex].cells[0]).css({backgroundColor:""});
		$(tr.cells[0]).css({backgroundColor:"#B7E3FE"});
		field.CurrentIndex = tr.rowIndex;
	}
	function getFieldRelation(Relation)
	{
		if (Relation == "")
			return "";
		switch (Relation.substr(0, 1))
		{
		case "!":
			var s = Relation.substr(1, Relation.indexOf("(") - 1);
			var t = eval("(typeof " + s + ")");
			if (t != "function")
					return "";
			return "<img src=" + cfg.quoteimg + " onclick=" + Relation.substr(1) + " style=cursor:hand;margin-left:-20px>";
		case "?":
			return Relation.substr(1);
		default:
			break;
		}
		return "";
	}

	function getDateObj()
	{
		if (dateeditor == undefined)
			dateeditor = new $.jcom.DynaEditor.Date(240, 280);
		return dateeditor;
	}
	
	this.prepare = function(field, prep, index)	//����:׼�����ݣ�������̬����
	{
		if (typeof domobj != "object")
			return;
		if (field.data == "~δ����~")
		{
			if  (field.Relation.substr(0, 1) != "$")
				return self.loadFieldData(field);
			field.data = "";
		}
		var EName = field.EName;
		if (typeof prep == "string")
			EName = prep + EName;
		if (index == undefined)
			index = 0;
		var readonly = "";
		if ((cfg.formtype == 1) || (cfg.formtype == 3) || (cfg.formtype == 5) || (cfg.formtype == 8) || (field.nReadOnly == 1))
			readonly = " readonly";
		switch (field.InputType)
		{
		case 1:
			if ((readonly != "") || (field.nShow == 0) || (field.nWidth == 0))
				return;
			if (cfg.spaninput == 1)
			{
				var o = $("#" + EName, domobj)[index];
				if (o == undefined)
					return;
				createInputEditor(field, o);
				return;
			}
			var o = $("input[name='Alias_" + EName + "']", domobj)[index];			
			if (o == undefined)
				var o = $("input[name='" + EName + "']", domobj)[index];			
			if (o == undefined)
				return;
			createInputEditor(field, o);
			break;
		case 2:		//����
			if ((typeof field.data != "string") || (field.data == "") || (field.data == "~δʵ��~"))
				return;
			var ss = field.data.split(",");
			for (var tag = "", x = 0; x < ss.length; x ++)
			{
				var sss = ss[x].split(":");
				if (sss.length == 1)
					sss[1] = sss[0];
				tag += "<input type=checkbox name=Alias_" + EName + " value=" + sss[0] + readonly + ">" + sss[1] + "&nbsp;";
			}
			var obj = $("#" + EName + "_DIV", domobj);
			obj.eq(index).html("<input type=hidden name=" + EName + ">" + tag);
			self.FieldValue(EName, record[EName]);
			break;
		case 3:		//��ѡ��
			if ((typeof field.data != "string") || (field.data == "") || (field.data == "~δʵ��~"))
				return;
			var ss = field.data.split(",");
			for (var tag = "", x = 0; x < ss.length; x ++)
			{
				var sss = ss[x].split(":");
				if (sss.length == 1)
					sss[1] = sss[0];
				tag += "<input type=radio name=" + EName + " value=" + sss[0] + readonly + ">" + sss[1] + "&nbsp;";
			}
			var obj = $("#" + EName + "_DIV", domobj);
			obj.eq(index).html(tag);
			self.FieldValue(EName, record[EName]);
			break;
		case 4:		//������
			if ((typeof field.data != "string") || (field.data == "") || (field.data == "~δʵ��~"))
				return;
			var ss = field.data.split(",");
			var obj = $("select[name=" + EName + "]", domobj);
			for (var x = 0; x < ss.length; x ++)
			{
				var sss = ss[x].split(":");
				if (sss.length == 1)
					sss[1] = sss[0];
				var o = document.createElement("OPTION");
				o.value = sss[0];
				o.text = sss[1];
				obj[index].options.add(o);
			}
			obj.val(record[EName]);
			break;
		case 7:		//���ı���
			if (readOnly != "")
				break;			
			var nType = 1;
			if (field.Relation == "short" || field.Relation == "3")
				nType = 3;
			if (field.Relation == "middle" || field.Relation == "2")
				nType = 2;
			if (field.Relation == "hidden" || field.Relation == "0")
				nType = 0;
			field.editor = new $.jcom.HTMLEditor($("#" + EName + "_DIV", domobj)[index], {EName: EName, nType: nType});
			break;
		case 8:		//�Զ���
			if (field.Relation == "*Object")
				field.editor = self.CreatePredefObj($("#" + EName + "_DIV", domobj)[index], field);
			break;
		case 18:	//��ѡ��
			if ((typeof field.data != "string") || (field.data == "") || (field.data == "~δʵ��~"))
				return;
			var ss = field.data.split(",");
			for (var tag = "", x = 0; x < ss.length; x ++)
			{
				var sss = ss[x].split(":");
				if (sss.length == 1)
					sss[1] = sss[0];
				if (sss[0] == "")
					sss[0] = sss[1];
				tag += "<li name=" + EName + "_MultiSel node='" + sss[0] + "' class=MultiItem>" + sss[1] + "</li>";
			}
			var obj = $("#" + EName + "_DIV", domobj);
			obj.eq(index).html(tag);
			self.FieldValue(EName, record[EName]);
		}
	};
	
	function ClickMutiItem(e)
	{
		$(e.target).toggleClass("MultiSel");
		var name = $(e.target).attr("name");
		var fname = name.substr(0, name.length - 9);
		var objs = $("li", e.target.parentNode);
		var val = "";
		for (var x = 0; x < objs.length; x++)
		{
			if (objs[x].className.indexOf("MultiSel") > 0)
			{
				var node = objs.eq(x).attr("node");
				if (val == "")
					val = node;
				else
					val += "," + node;
			}
		}
		$("input[name='" + fname + "']", domobj).val(val);
		var field = self.getFields(fname);
		return self.onchange(field, e);
	}
	
	function createInputEditor(field, o)
	{
		if ((typeof field.data == "string") && (field.data != ""))
			field.editor = new $.jcom.DynaEditor.List(field.data, $(o).width(), 300, 1);
		else if (field.Relation.substr(0, 1) == "$")
		{
			var ss = field.Relation.substr(1).split(":");
			switch (ss[1])
			{
			case "DBTree":
				var tree = new $.jcom.DBTree(0, ss[0]);
				field.editor = new $.jcom.DynaEditor.TreeList(tree, $(o).width(), 300);
				break;
			case "DBCascade":
				alert("==");
				break;
			case "None":
				return;
			case "DBGrid":
			default:
				var grid = new $.jcom.DBGrid(0, ss[0]);
				field.editor = new $.jcom.DynaEditor.GridList(grid, $(o).width(), 300);
				break;
			}
		}
		else if (field.FieldType == 4)
		{
			if (getFieldRelation(field.Relation) == "")
				field.editor = getDateObj();
		}
		else
			return;
		field.editor.attach(o);
		field.editor.valueChange = FieldValueChange;		
	}

	function FieldValueChange(obj)
	{
		if (obj.name.substr(0, 6) == "Alias_")
			$("input[name='" + obj.name.substr(6) + "']", domobj).val($(obj).attr("node"));
	}
	
	function getbar()
	{
		var tag = "<div id=FormButtonDiv align=center class=jformtail" + cfg.ncss + ">";
		switch (cfg.formtype)
		{
		case 1:		//�鿴
			break;
		case 2:		//�޸�
			tag += "<input type=submit value='" + cfg.submitbutton + "' name=SubmitButton style='" + cfg.itemstyle + "'>&nbsp;";
			break;
		case 3:		//��ӡ
			break;
		case 4:		//�Զ���
			break;
		case 5:		//���
			break;
		case 6:		//�༭
			break;
		case 7:		//��ѯ
			break;
		case 8:		//ҳ��
			return "";
		}
		return tag + "</div>";
	}

	
	this.CreatePredefObj = function (obj, field)				//�¼�:�Զ����ֶ�Relation��־Ϊ*Objectʱ�����û������������
	{		
	};

	this.setQuote = function(fieldName, QuoteValue)		//����:�����ֶε�����
	{
		var x = self.getFieldsIndex(fieldName);
		fields[x].Quote = QuoteValue;
		if (x >=0)
		{
			self.getquote(fields[x]);
			self.prepare(fields[x]);
		}
	};
	
	this.onload = function(record)		//�¼�:��������ɺ󴥷���Ĭ�ϲ����Ǽ�������
	{
		self.setRecord(record);
	};
	
	this.CheckValue = function (field, value)		//����:����ֶεĺϷ���
	{
		if (typeof value == "object")
			value = value.value;
		if (value == undefined)
			value = "";
		if ((field.nReadOnly == 1) || (field.nWidth == 0) || (field.InputType == 21))
			return "";
		if (field.nRequired == 1)
		{
			if (value == "")
				return field.CName + "�ֶ�ӦΪ������\n";
		}
		if ((typeof field.data == "string") && (field.data != "") && (field.data != "~δʵ��~") && (value != ""))// && (value != 0))
		{
			if ((field.Quote.substr(0, 1) == "(") || (field.Quote.substr(0, 1) == "@"))
			{
				if (field.InputType == 2)	//��λ����
				{
					var  o = $("[name=Alias_" + field.EName + "]", domobj);
					value = 0;
					for (var x = 0; x < o.length; x++)
					{
						if (o[x].checked)
							value += parseInt(o[x].value);
					}
					$("[name=" + field.EName + "]", domobj).val(value);
					return "";
				}
				var ss = field.data.split(",");
				for (var y = 0; y < ss.length; y++)
				{
					var sss = ss[y].split(":");
					if ((value == sss[0]) || (value == sss[1]) || (value == ss[y]))
						break;
				}
				if (y == ss.length)
					return field.CName + "�ֶ�������ö�����б�֮��\n";
			}
		}
		switch (field.FieldType)
		{
		case 1:			//�ı�
			if (value.length > field.FieldLen)
				return field.CName + "�ֶγ��ȳ�����������󳤶�Ϊ" + field.FieldLen + ",ʵ�ʳ���Ϊ:" + value.length + "\n";
			break;
		case 2:			//��ע
			break;
		case 5:			//�Զ����
		case 3:			//����
		case 6:			//�����ȸ���
		case 7:			//˫���ȸ���
			if (isNaN(Number(value)))
			{
				$(domobj).find("#" + field.EName).parent().css("border", "1px solid red");
				return field.CName + "�ֶ�ӦΪ��ֵ��\n";
			}
			break;
		case 4:			//����
			if (value == "")
				break;
			var ss = value.split(" ")
			var sss = ss[0].split("-")
			if (isNaN(Number(sss[0])) || isNaN(sss[1]) || isNaN(sss[2]))
				return field.CName + "�ֶ����ڸ�ʽ����\n";
			var dd = new Date(Number(sss[0]), Number(sss[1]) - 1, Number(sss[2]));
			if ((dd.getFullYear() != Number(sss[0])) || (dd.getMonth() != Number(sss[1]) - 1) || (dd.getDate() != Number(sss[2])))
				return field.CName + "�ֶ����ڸ�ʽ����\n";
			if (ss.length < 2)
				break;
			sss = ss[1].split(":");
			for (var xx = 0; xx < sss.length; xx++)
			{
				if (sss.length > 3 || isNaN(Number(sss[xx])) || (Number(sss[xx]) > 59) || (Number(sss[xx]) < 0) || (Number(sss[0]) >= 24))
					return field.CName + "�ֶ����ڸ�ʽ����\n";
			}
			break;
		case 8:			//������
			break;
		case 9:			//��/��
			break;
		case 10:		//����
			break;			
		}
		return "";
	};

	this.CheckForm = function (record, bsilent)		//����:�����ĺϷ���
	{
		var errcnt = 0, hint = "";
		if (record == undefined)
			record = self.getRecord();
		self.clearRed();
		if (self.onCheckForm(fields, record) == false)
			return 1;
		var checkresult = [];
		for ( var x = 0; x < fields.length; x++)
		{
			if (fields[x].InputType == 17)	//��ϸ��
			{
				var subrec = record[fields[x].EName];
				for (var yy = 1; yy < subrec.length; yy++)
				{
					for (var xx = 0; xx < fields[x].SubFields.length; xx ++)
					{
						var result = self.CheckValue(fields[x].SubFields[xx], subrec[yy][fields[x].SubFields[xx].EName]);
						if (result != "")
						{
							var cname = fields[x].CName;
							if (cname == "$none")
								cname = fields[x].Hint;
							result = cname + "��" + yy + "��:" + result;
							hint += result;
							checkresult[checkresult.length] = {field: fields[x].EName + "_" + fields[x].SubFields[xx].EName, err: result};
//							$("#" + fields[x].EName, domobj).css("color", "red");
							errcnt ++;
						}
					}
				}
				continue;
			}
			var result = self.CheckValue(fields[x], record[fields[x].EName]);
			if (result != "")
			{
				$("#" + fields[x].EName, domobj).css("color", "red");
				hint += result;
				checkresult[checkresult.length] = {field: fields[x].EName, err: result};
				errcnt ++;
			}
			if (fields[x].InputType == 7)
				fields[x].obj.copydata();
		}
		if (bsilent == 1)
			return checkresult;
		if (errcnt > 0)
			alert("����" + errcnt + "��ϸ�������\n" + hint);
		return errcnt;
	};

	this.onCheckForm = function (fields, record)	//�¼�:�������Զ�����ֶλ�����Ҫ��ĺϷ��Լ��
	{
		return true;
	};

	this.clearRed = function ()		//����:��������Ϸ��ֶεĺ�ɫ���
	{
		for ( var x = 0; x < fields.length; x++)
			$(domobj).find("#" + fields[x].EName).css("color", "");
	};

	function mkevent(e)
	{
		var field = self.getFields(e.target.name);
		switch (e.type)
		{
		case "keydown":
			return self.onkeydown(field, e);
		case "keypress":
			return self.onkeypress(field, e);
		case "mousedown":
			if (field == undefined)
				setCurrentDetail(e);
			break;
		case "click":
			if (e.target.id == "InsertDetail")
				return InsertDetail(e);
			if (e.target.id == "DelDetail")
				return DelDetail(e);
			if (e.target.tagName == "LI")
				return ClickMutiItem(e);
			return self.onclick(field, e);
		case "dblclick":
			return self.ondblclick(field, e);
		case "contextmenu":
			return self.oncontextmenu(field, e);
		case "change":
			return self.onchange(field, e);
		default:
			alert(e.type);
		}
	}

	this.getquote = function(field, fun)	//����:�õ��ֶε�����ֵ
	{
		if (field.Relation.substr(0, 1) == "(")
		{
			field.Quote = field.Relation;
			field.Relation = "";
		}
		if (field.Relation.substr(0, 18) == "!SelectField(this,")
		{
			var str = field.Relation.substr(19);
			var ss = str.split("\",\"");
			field.Quote = "$" + ss[0] + "," + ss[1].substr(0, ss[1].length - 2);
			field.Relation = "";
		}
		
		
		if (field.Quote == "")
			return true;
		if (field.data != undefined)
			return true;
		switch (field.Quote.substr(0, 1))
		{
		case "(":
			field.data = field.Quote.substr(1, field.Quote.length - 2);
			EnumDataFilter(field);
			break;
		case "$":
			field.data = "~δ����~";
			break;
		case "@":
			field.data = "~δ����~";
			break;
		case "&":
			field.data = "";
			break;
		default:
			field.data = "~δ����~";
			break;
		}
		if ((field.data == "~δ����~") && (fun != undefined))
		{
			$.get(cfg.enumurl + field.Quote, {}, function (data)
			{
				field.data = data;
				fun(field);
			});
			return false;
		}
		return true;
	};

	function EnumDataFilter(field)
	{
		var filter = field.Relation.split(",");
		if (filter.length == 1)
			return;
		var items = field.data.split(",");
		var result = "";
		for (var x = 0; x < filter.length; x++)
		{
			for (var y = 0; y < items.length; y++)
			{
				var ss = items[y].split(":");
				if (ss[0] == filter[x])
				{
					result += items[y] + ",";
					break;
				}
			}
		}
		if (result == "")
			return;
		field.data = result.substr(0, result.length - 1);
	}

	this.setEnumAlias = function(EName, data)		//����:����ö�����ı���
	{
		var x = self.getFieldsIndex(EName);
		if (x == -1)
			return;
		fields[x].AliasData = data;
	};

	this.TranslateValue = function(EName, value)		//����:���ֶ�ֵת���ɷ���Ҫ��ĸ�ʽ
	{
		if ((typeof value == "string") && (value == ""))
			return value;
		var x = self.getFieldsIndex(EName);
		if (x == -1)
			return value;
		if ((fields[x].InputType == 2) && (fields[x].Quote != ""))	//��λ����
			return value;
		if (typeof fields[x].data == "string")	//ö����
		{
			var result = getEnumData(fields[x].data, value);
			if (typeof result == "object")
				return result;
			if (typeof fields[x].AliasData == "string")
			{
				var s1 = fields[x].AliasData.split(",");
				for (var y = 0; y < s1.length; y++)
				{
					var s2 = s1[y].split(":");
					var s3 = s2[1].split(";");
					for (var z = 0; z <s3.length; z++)
					{
						if (value == s3[z])
							return getEnumData(fields[x].data, s2[0]);
					}
				}
			}
		}
		else if ((fields[x].FieldType == 4) || (fields[x].Quote.substr(0, 3) == "&d:"))		//Date
		{
			if (self.CheckValue(fields[x], value) != "")
			{
				var ss = value.split("-");
				switch (ss.length)
				{
				case 1:
					ss = value.split(".");
					if (ss.length == 1)
					{
						if (isNaN(parseInt(value)))
							return "";
						value = parseInt(value) + "-1-1";
					}
				case 2:
					value = ss[0] + "-" + ss[1] + "-1";
					break;
				case 3:
					value = ss[0] + "-" + ss[1] + "-" + ss[2];
					break;
				}
			}
			value = {value: value, ex:$.jcom.GetDateTimeString(value, parseInt(fields[x].Quote.substr(3)))};
		}
		if ((fields[x].FieldType == 3) && (typeof value == "string"))
			value = parseInt(value);
		return value;
	};

	function getEnumData(data, value)
	{
		var s = data.split(",");
		for (var y = 0; y < s.length; y++)
		{
			var ss = s[y].split(":");
			if ((value == ss[0]) || (value == ss[1]) || (value == s[y]))
				return {value: ss[0], ex: ss[1]};
		}
		if (typeof value == "string")
		{
			var sss = value.split(",");
			if (sss.length > 1)
			{
				var v = "";
				for (var x = 0; x < sss.length; x++)
				{
					if (v != "")
						v += ",";
					var vv = getEnumData(data, sss[x]);
					if (typeof vv == "object")
						vv = vv.ex;
					v += vv;
				}
				if (v == value)
					return v;
				else 
					return {value: value, ex: v};
			}
		}
		return value;
	}
	
	this.getFieldsIndex = function(value, propName)		//����:��ȡ�ֶζ������ݵ�����
	{
		if (propName == undefined)
			propName = "EName";
		return $.jcom.inObjArray(fields, propName, value);
	};
		
	this.beforesubmit = function()	//����:�ύǰ���������ݷ���ֵȷ���Ƿ���Ҫ�����ύ
	{
		if (self.CheckForm() > 0)
			return false;
		var	result = self.submit();
		if (result == false)
			return false;
		if (cfg.spaninput == 1)
		{
			var r = self.getRecord();
			var text = self.MakeFormField(r);
			$.jcom.submit(cfg.action, text, {fnReady: this.aftersubmit});
			return false;
		}
		if (form.target == "FormViewTarget")
		{//�˲����Ƿ�ɺ�SaveForm�ϲ���
			var iframe = $("<iframe name=FormViewTarget style=display:none></iframe>");
			iframe.appendTo($(domobj));
			$(domobj).find("[name=SubmitButton]").prop("disabled", true);
			var t = 0;
			var timer = window.setInterval(function()
			{
				var b = iframe[0].contentWindow.document.body;
				if (b == null)
					return;
				if ((b.innerHTML == "") && (t++ <= cfg.timeout * 10))
					return;
				window.clearInterval(timer);
				var result = b.innerHTML;
				iframe.remove();
				$(domobj).find("[name=SubmitButton]").prop("disabled", false);
				if (t++ > cfg.timeout * 10)
					return alert("��ʱ��������δ��Ӧ");
				return self.aftersubmit(result);
			}, 100);
		}
		return true;
	};
		
	this.aftersubmit = function (result)		//�¼�:�ύ��ɺ󴥷�
	{
		alert(result);
	};

	this.submit = function ()				//�¼�:�ύʱ�������緵��false,����Ե�Ĭ�ϵ��ύ���������򣬼���Ĭ���ύ
	{
		return true;
	};
	
	this.MakeFormField = function (rec, rowflag)	//����:�������ύ�ı���ͨ�������ڱ༭
	{
		var text = "<input name=I_DataID value=" + $("input[name='I_DataID']", domobj).val() + ">";
		for (var key in rec)
		{
			var value = rec[key];
			if (typeof value == "object")
			{
				if ((rowflag == true) || (rowflag == 1))
					value = rec[key].ex;
				else
					value = rec[key].value;
			}
//			text += "<input name=" + key + " value=\"" + value.replace(/\"/g, "\\\"") + "\">";
			text += "<textarea name=" + key + ">" + value + "</textarea>";	//
		}
		return text;
	};
	
	this.onkeydown = function (field, e)	//�¼�:���̰����¼�
	{
	};
	
	this.onkeypress = function (field, e)		//�¼�:�����¼�
	{
	};

	this.onclick = function (field, e)	//�¼�:�����¼�
	{
	};
	
	this.ondblclick =function (field, e)	//�¼�:˫���¼�
	{
	};	

	this.onchange = function(field, e)		//�¼�:�������������ݱ仯����
	{
	};

	this.oncontextmenu = function(field, e)	//�¼�:�Ҽ��˵�����
	{
	};
	
	this.attachEvent = function(field, evt, fun)		//����:���¼�����δʵ��
	{
	};

	this.detachEvent = function(field, evt, fun)		//����:������¼�����δʵ��
	{
	};

	function setSubFormRecord(field, recs)
	{
		var oTab = $("#" + field.EName + "_SubTable", domobj);
		for (var x = oTab[0].rows.length - 1; x > 0; x--)
			oTab[0].rows[x].removeNode(true);
		
		if (recs.length == 0)
			return;
		if (recs.length == 1)
			return self.InsertDetailLine(field, recs[0]);
		for (var x = 1; x <recs.length; x++)
			self.InsertDetailLine(field, recs[x])
	}
	
	this.setRecord = function (rec)		//����:���ñ���¼
	{
		if (typeof rec == "object")
			record = rec;
		for (var key in rec)
		{
			var value = rec[key];
			var index = self.getFieldsIndex(key);
			if ((typeof value == "object") && (value.ex != undefined))
				value = value.ex;
			var ename = key;
			if (key.substr(key.length - 3) == "_ex")
				ename = "Alias_" + key.substr(0, key.length - 3);
			if (index >= 0)
			{
				if (fields[index].InputType == 17) 	//��ϸ��
				{
					setSubFormRecord(fields[index], rec[key]);
					continue;
				}
				
				if (((fields[index].InputType == 8) && (fields[index].Relation == "")) || (fields[index].InputType == 24))	//Ԥ������Զ���
				{
					$("#T2_" + ename).html(value); 
					rec[ename] = "";
					continue;
				}
				else if (fields[index].InputType == 7)		//HTML�༭��
				{
					if (typeof fields[index].obj == "object")
					{
						fields[index].obj.Text(value);
						continue;
					}
				}
				else if ((fields[index].InputType == 2) && (fields[index].Quote != ""))	//��λ����
				{
					var o = $("[name=" + ename + "]", domobj);
					o.val(rec[key]);
					var  o = $("[name=Alias_" + ename + "]", domobj);
					for (var x = 0; x < o.length; x++)
					{
						if (rec[key] & o[x].value)
							o[x].checked = true;
						else
							o[x].checked = false;
					}
				}
			}
			self.FieldValue(ename, value);
		}
		self.onRecordReady(fields, record);
	};
	
	this.onRecordReady = function (fields, record)		//�¼�:���ݼ�����ɺ����
	{};
	
	this.FieldValue = function (key, value, index)		//����:��ȡ�����ø������ֶ����Ƶ�ֵ
	{
		if (typeof value == "object")
		{
			self.FieldValue(key, value.value, index);
			self.FieldValue("Alias_" + key, value.ex, index);
			return;
		}
		if (index == undefined)
			index = 0;
		
		var o = $(domobj).find("[name=" + key + "]");
		if ((o.length == 0) && (cfg.spaninput == 1))
			o = $("#" + key);
		if (o.length < index + 1)
			return;
		var text;
		if (o[0].type == "checkbox")
		{
			if (typeof value != undefined)
			{
				if (value > 0)
					o.eq(index).prop("checked", true);
				else
					o.eq(index).prop("checked", false);
			}
			if (o.eq(index).prop("checked"))
				return 1;
			else
				return 0;
		}
		
		if (o[0].type == "radio")
		{
			var div = $("#" + key + "_DIV")[index];
			var o = $("[name=" + key + "]", div);			
			for (var x = 0; x < o.length; x++)
			{
				if (o[x].checked)
					text = o[x].value;
				if (o[x].value == value)
					o[x].checked = true;
			}
			return text;
		}
		if ((o[0].tagName == "TEXTAREA") || (o[0].tagName == "INPUT") || (o[0].tagName == "SELECT"))
			text = o.eq(index).val();
		else
			text = o.eq(index).html();
			
		if (value != undefined)
		{
			if ((o[0].tagName == "TEXTAREA") || (o[0].tagName == "INPUT") || (o[0].tagName == "SELECT"))
				o.eq(index).val(value);
			else
				o.eq(index).html(value);
		}
		return text;
	};
	
	this.getRecord = function (bDistransFlag)		//����:�õ�����¼
	{
		for (var key in record)
		{
			var o = getFormFieldObj(key);
			if (o.length == 0)
			{
				if (typeof record[key] == "object")
				{
					var field = self.getFields(key);
					if ((typeof field == "object") && (field.InputType == 17))
						record[key] = getSubFormRecord(field, record[key]);
				}
				continue;
			}
			record[key] = getFormFieldValue(key, o, 0);
			if (bDistransFlag != 1)
				record[key] = self.TranslateValue(key, record[key]);
		}
		return record;
	}

	function getFormFieldObj(key)
	{
		var o = $("[name=" + key + "]", domobj);
		if ((o.length == 0) && (cfg.spaninput == 1))
			o = $("#" + key);
		return o;
	}
	
	function getFormFieldValue(key, obj, index)
	{
		if (obj[index].type == "checkbox")
		{
			if (obj.eq(index).prop("checked"))
				return 1;
			else
				return 0;
		}
		if (obj[0].type == "radio")
		{
			var div = $("#" + key + "_DIV")[index];
			var o = $("[name=" + key + "]", div);
			for (var x = 0; x < o.length; x++)
			{
				if (o[x].checked)
					return o[x].value;
			}
			return 0;
		}
		if ((obj[index].tagName == "TEXTAREA") || (obj[index].tagName == "INPUT") || (obj[index].tagName == "SELECT"))
			return obj.eq(index).val();
		return obj.eq(index).html();
	}
	
	function getSubFormRecord(field, subrec)
	{
		var oTab = $("#" + field.EName + "_SubTable", domobj);
		var index = oTab[0].rows.length;
		subrec = [subrec[0]];
		for (var x = 1; x < index; x++)
		{
			subrec[x] = {};
			for (var subkey in subrec[0])
			{
				var obj = getFormFieldObj(field.EName + "_" + subkey);
				subrec[x][subkey] = getFormFieldValue(field.EName + "_" + subkey, obj, x - 1);
			}
		}
		return subrec;
	}

	this.loadFieldData = function (field)		//����:�����ֶ�����
	{
		function loadFieldDataOK(data)
		{
			field.data = $.trim(data);
			self.prepare(field);
		}
		$.get(cfg.enumurl + field.Quote, {}, loadFieldDataOK);
	}
	
	this.bind = function(obj)		//����:�󶨱���DOM����
	{
		if (typeof form == "object")
		{
			$(form).off("keydown", mkevent);
			$(form).off("keypress", mkevent);
			$(form).off("mousedown", mkevent);
			$(form).off("click", mkevent);
			$(form).off("dblclick", mkevent);
			$(form).off("change", mkevent);
			$(form).off("contextmenu", mkevent);
			$(form).off("submit", self.beforesubmit);
			$(domobj).off("resize", resize);
		}
		domobj = obj;
		self.initBase();
	}
	
	this.getFields = function (ename)		//����:�����ֶζ�������
	{
		if (ename == undefined)
			return fields;
		var index = self.getFieldsIndex(ename);
		if (index >= 0)
			return fields[index];
	};
	
	this.getCfg = function()		//����:��������
	{
		return cfg;
	};
	
	this.resetBase = function (f, r, c, flag)	//����: ���ݸ����Ĳ����� ��λ�������¹���
	{
		cfg = $.jcom.initObjVal(cfg, c);
		if (typeof f == "object")
		{
			fields = f;
			if (flag == undefined)
				self.bind(domobj);	//��fields�仯����Ҫ���¹���
		}
		if (typeof r == "object")
			self.setRecord(r);
	};
		
	this.appendHidden = function (field, value)		//����:Ϊ�����������ֶ�,��valueΪ������������ʱ�����Ӹö�����������Ϊ���Ƶ������ֶμ���
	{
		if (typeof form != "object")
			return;
		if (typeof value != "object")
			return form.insertAdjacentHTML("beforeEnd", "<input type=hidden name=\"" + field + "\" value=\"" + value + "\">");
		var div = $("#" + field);
		if (div.length == 0)
		{
			$(form).append("<div id=" + field + " style=display:none></div>");
			div = $("#" + field);
		}
		div.html($.jcom.submit("#getObjTag", value));		
	}
	
	cfg = $.jcom.initObjVal({title:"", action:location.pathname + "?FormSaveFlag=1&Ajax=1", formtype:2, nStyle:2,nCols:1,headTxt: "", footTxt: "", 
		requireTag:"<span style=color:red>*</span>", width:0,height:0,viewpage:"", ncss:"1", target: "FormViewTarget",spaninput:0, enumurl:"../com/seleenum.jsp?AjaxMode=1&EnumType=",
		quoteimg:"../com/pic/search.png", timeout:20, itemstyle:"", valstyle:"", nowrap:1, submitbutton:"�ύ"}, cfg);
};

$.jcom.FormView = function(domobj, fields, record, cfg)	//��:����ͼ
{
	var self = this;
	var layer;
	$.jcom.FormBase.call(this, domobj, fields, record, cfg);
	var oImport;
	function InitImport()
	{
		if (oImport == undefined)
		{
			oImport = new $.jcom.OfficeImport(fields, record);
			oImport.onImportItem = self.onImportItem;
			oImport.onImport = self.onImport;
		}
	}
	
	this.Import = function ()		//����:�ύ��������������ͨ�õ������
	{
		InitImport();
		return oImport.Import();
	};
	
	this.ImportWord = function(filename)		//����:ʹ�ñ���WORD API������WORD����ĵ�
	{
		InitImport();
		return oImport.ImportWord(filename);
	};
	
	this.ImportExcel = function(filename)		//����:ʹ�ñ���EXCEL API������EXCEL���
	{
		InitImport();
		return oImport.ImportExcel(filename);
	};	
	
	
	this.ImportFolder = function ()			//����:ʹ�ñ���API�������ļ��У�WORD��EXCEL���
	{
		InitImport();
		return oImport.ImportFolder();
	}

	this.onValidField = function (key, value)//�¼�:�����¼�������ȡĳ�ֶ�ֵ�����������ж���ȷ�Ի��������ת��
	{
		 self.TranslateValue(key, value);
	};

	this.onImportItem = function(appname, text, record, fields, doc, cell)		//�¼�:�����¼�������ȡ�ֶκ��������¼������Զ��嵼��ֵ
	{};
		
	this.onImport = function(record, fields, cnt, nType, obj, filename)		//�¼�:������ɺ���
	{
		self.setRecord(record);
		self.clearRed();
		alert("��������" + cnt +  "��");
		self.CheckForm();
	};
	
	function initLayerForm()
	{
		if (cfg.formtype != 8)
		{
			domobj.innerHTML = "<form action=" + cfg.action + " method=POST name=ActionSave></form>";
			form = domobj.firstChild;
		}
		else
			form = domobj;
		layer = new $.jcom.Layer(form, cfg.ex);
		var tag = form.innerHTML;
		for ( var x = 0; x < fields.length; x++)
		{
				objtag = self.getFieldTag(fields[x]);
				tag = tag.replace("(" + fields[x].EName + ")", objtag);
				self.getquote(fields[x]);
				
		}
		tag = tag.replace("(@@Submit@@)", "<input type=submit value='�� ��' name=SubmitButton>&nbsp;");
		tag = tag.replace("(@@Close@@)", "<input type=button value='�ر�' onclick=window.close()>&nbsp;");
		form.innerHTML = tag;
	}

	function initUserForm(userdata)
	{
		if ((cfg.menudef == "disabled") || (cfg.menudef == false))
			var formobj = $(domobj);
		else
		{
			var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"GridDiv"}};
			oLayer = new $.jcom.Layer(domobj, aFace, {});
			if (typeof cfg.menudef != "object")
			{
				cfg.menudef = [{item:"����",child:[{item:"���뵥���ļ�",action:self.Import},{item:"�����ļ���",action:self.ImportFolder}]},
					{item:"����",action:self.Output},{item:"����", action:self.SaveForm}];
			}
			self.menubar = new $.jcom.CommonMenubar(cfg.menudef, $("#SeekMenubar")[0], "");
			var formobj = $("#GridDiv", domobj);
		}

		for (var x = 0; x < fields.length; x++)
		{
			var objtag = self.getFieldTag(fields[x]);
			userdata = userdata.replace("(" + fields[x].EName + ")", objtag);
		}
		if (userdata.substr(0, 1) == "{")
		{
			var json = $.jcom.eval(userdata);
			if (typeof json == "string")
				return alert(json);

			json.head[0].nShowMode = 1;
			json.head[0].TitleName = "";
			json.head[0].nWidth = 1;
			var d = {_lineControl:{height:1,divstyle:"overflow:hidden"}};
			for (var x = 0; x < json.head.length; x++)
				d[json.head[x].FieldName] = {value:"", tdstyle:"border:none"};
			json.data.splice(0, 0, d);

			for (var x = 0; x < json.data.length; x++)
				json.data[x].Num = {value:"", tdstyle:"border:none"};
			self.view = new $.jcom.GridView(formobj[0], json.head, json.data, {}, {footstyle:4,headstyle:3,nowrap:0,resizeflag:0});
			self.view.clickRow = SelectGridCell;
			self.view.overRow = function (){};
		}
		else
			formobj.html(userdata);
		
		for (var x = 0; x < fields.length; x++)
		{
			self.getquote(fields[x]);
			self.prepare(fields[x]);
		}
		self.onload(record);
	}

	function SelectGridCell(td, event)
	{
		var o = $(td).find("span");
		if (o.prop("contentEditable"))
			o[0].focus();
	}
	
	this.Output = function (filename, mode)		//����:����������EXCEL�ļ�	
	{
		if (typeof filename != "string")
			filename = "Excel.xls";
		if (mode == 1)	//���ص�����
			return self.SaveForm({action:"../com/OutExcel.jsp?ExcelFormID=" + cfg.gridformid + "&FileName=" + filename, rawflag:true, setMenustatus:false, CheckForm:false, onSaveReady: null});
		if (mode == 2)	//���浽��������ʱ�ļ��У���д������
			return self.SaveForm({action:"../com/OutExcel.jsp?OutToServer=1&TMP=1&ExcelFormID=" + cfg.gridformid + "&FileName=" + filename, rawflag:true, setMenustatus:false, CheckForm:false, onSaveReady: null});
		if (mode == 3)	//���浽��������д�븽����
			return self.SaveForm({action:"../com/OutExcel.jsp?OutToServer=1&ExcelFormID=" + cfg.gridformid + "&FileName=" + filename, rawflag:true, setMenustatus:false, CheckForm:false, onSaveReady: null});
		self.view.OutExcel(filename, "", 3, {colbegin:1, rowbegin:1});
	};
	
	this.SaveForm = function (option)		//����:�ύ��
	{
		option = $.jcom.initObjVal({action:cfg.action, target:"_self", setMenustatus:true, rawflag:false, CheckForm:true, onSaveReady: SaveOK}, option); 
		if (typeof domobj == "object")
		{
			if (cfg.spaninput == 0)
			{
				if (self.beforesubmit() == false)
					return;
				return $("form", domobj)[0].submit();
//				return self.beforesubmit();
			}	
			if (option.CheckForm)
			{
				if (self.CheckForm() > 0)
					return false;
			}
		}
		var text = self.MakeFormField(record, option.rowflag);
		$.jcom.submit(option.action, text, {fnReady: option.onSaveReady});
		if (option.setMenuStatus)
			self.menubar.setDisabled("����", true);
	};
	
	function SaveOK()
	{
		var doc = $("#SaveFormFrame")[0].contentWindow.document;
		if (doc.readyState != "complete")
			return;
		if (typeof self.menubar == "object")
			self.menubar.setDisabled("����", false);
		var result = doc.body.innerHTML;
		if (result.substr(0,2) != "OK")
		{
			var id = -1;
			var hint = "����ʧ��:" + result;
		}
		else
		{
			var id = result.substr(3);
			var	hint = "����ɹ�";
		}
		var result = 0;
		if (typeof oImport == "object")
			result = oImport.ImportNext(id, hint);
		if (result == 0)
			alert(hint);
	}

	this.reset = function (f, r, c)	//����:��λ������ָ�����������¼���
	{
		if (typeof f == "object")
			fields = f;
		if (typeof r == "object")
			record = r;
		cfg = $.jcom.initObjVal(cfg, c);	
		self.resetBase(fields, 0, c, 1);
		initForm();
		self.setRecord(r);
	};
	
	function initForm()
	{
		if (typeof domobj != "object")
			return;
		cfg = $.jcom.initObjVal({ex:"", gridformid:0, menudef:"default"}, cfg);
		if (cfg.gridformid > 0)
		{
			$.get("../com/inform.jsp", {DataID:cfg.gridformid, Ajax:1}, initUserForm);
			return;
		}
		if (typeof cfg.ex == "object")
			return initLayerForm();
		self.initBase();
	}
	initForm();
};

$.jcom.OfficeImport = function(fields, record)		//��:OFFICE���ݵ�����
{
	var self = this;
	
	this.Import = function (url)		//����:�ύ��������������ͨ�õ������
	{
		if (typeof $("#ImportExcelFrame")[0] == "object")
			$("#ImportExcelFrame").remove();
		if (url == undefined)
			url = "../com/inform.jsp?ImportExcelFlag=1&Ajax=1";
		document.body.insertAdjacentHTML("afterBegin", "<iframe id=ImportExcelFrame style=display:none></iframe>");
		var doc = $("#ImportExcelFrame")[0].contentWindow.document;
		doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
			"</head><body><form id=ImportForm method=post action=" + url +
			" enctype=multipart/form-data><input type=file name=LocalName></form></body></html>");
		doc.charset = "gbk";
		var finput = $("input[name='LocalName']", doc);
		finput[0].onchange = StartImportFile;
		finput.click();
		$("#ImportExcelFrame")[0].onreadystatechange = ImportOK;
	};

	function StartImportFile()
	{
		var doc = $("#ImportExcelFrame")[0].contentWindow.document;
		var file = $("input[name='LocalName']", doc).val();
		if (file != "")
			self.onFileSel(file);
	}
	
	function ImportOK()
	{
		var doc = $("#ImportExcelFrame")[0].contentWindow.document;
		if (doc.readyState != "complete")
			return;
		var json = $.jcom.eval(doc.body.innerHTML);
		if (typeof json == "string")
		{
			return alert(json);
		}
//		var data = self.view.getData();
		var cnt = 0;
		for (var key in record)
		{
			if ($("#" + key).length > 0)
			{
				var td = $.jcom.findParentObj($("#" + key)[0], domobj, "TD");
				if (typeof td == "object")
				{
					var index = $(td.parentNode).attr("node");
					var fieldName = td.id.substr(0, td.id.length - 3);
					if (index < json.data.length)
					{
						var val = json.data[index - 1][fieldName];	//��ȥΪ���ָ�ʽ�������ӵ�һ�С�
						if (val != undefined)
						{
							if (typeof val == "object")
								val = val.value;
							$("#" + key).text("???");
							var begin = td.innerText.indexOf("???");
							var end = td.innerText.length - begin - 3;
							record[key] = self.TranslateValue(key, val.substring(begin, val.length - end));
							cnt ++;
						}
					}
				}
			}
		}
		self.onImport(record, fields, cnt, 1, json);
	}
	
	this.onFileSel = function (file)	//�¼�:ѡ����һ���ļ�������
	{
		if (file.substr(file.length - 3).toLowerCase() == "xls")
			doc.getElementById("ImportForm").submit();
		else
			self.ImportWord(file);
	};
	
	var word, excel;
	this.InitOffice = function(type)	//����:��ʼ��OFFICE�ؼ�
	{
		switch (type)
		{
		case 1:
		case "Word":
			if (typeof word != "object")
			{
				try
				{
					word = new ActiveXObject("Word.Application");
					$(window).on("beforeunload", self.QuitOffice);

				} catch (e)
				{
					alert("δ�ܴ򿪱��ص�OFFICE����" + e.description);
					return;
				}
			}
			else
			{
				try
				{
					word.Activate();
				}
				 catch (e)
				{
					word = undefined;
					return self.InitOffice(1);
				}
			}
			return word;
			break;
		case 2:
		case "Excel":
			if (typeof excel != "object")
			{
				try
				{
					excel = new ActiveXObject("Excel.Application");
//					excel.Visible = true;
					$(window).on("beforeunload", self.QuitOffice);

				} catch (e)
				{
					alert("δ�ܴ򿪱��ص�OFFICE����" + e.description);
					return;
				}
			}
			return excel;
			break;
		}
	};
	
	this.ImportWord = function(filename)		//����:ʹ�ñ���WORD API������WORD����ĵ�
	{
		self.InitOffice("Word");
		var doc = word.Documents.Open(filename, true, true);
		doc.ActiveWindow.Activate();
		var rows = doc.Tables(1).Rows.Count;
		var cols = doc.Tables(1).Columns.Count;
		var cnt = 0;
		for (var y = 0; y < rows; y++)
		{
			for (var x = 0; x < cols; x++)
			{
				try
				{
					var cell = doc.Tables(1).Cell(y + 1, x + 1);
				}
				catch (e)
				{
//					window.status = (y + "-" + x + e.description);
					continue;
				}
				
				var text = cell.Range.Text.replace(/[\s\7]+/g, "");
//				var index = self.getFieldsIndex(text, "CName");
				var index = $.jcom.inObjArray(fields, "CName", text);
				if (index > 0)
				{
					text = doc.Tables(1).Cell(y + 1, x + 2).Range.Text;
					if (fields[index].FieldLen <= 100)
						text = text.replace(/[\s\7]+/g, "");
					record[fields[index].EName] = self.onValidField(fields[index].EName, text);
					x++;
					cnt ++;
				}
				else
					self.onImportItem("Word", text, record, fields, doc, cell);
			}
		}
		self.onImport(record, fields, cnt, 2, doc, filename);
		doc.Close();
	};
	
	this.ImportExcel = function(filename)		//����:ʹ�ñ���EXCEL API������EXCEL���
	{
		self.InitOffice("Excel");
		var book = excel.Workbooks.Open(filename);  
		var sheet = book.Sheets(1);
		var rows = sheet.UsedRange.Rows.Count;
		var cols = sheet.UsedRange.Columns.Count;
		if (cols > 25)
			cols = 25;
		var cnt = 0;
		for (var y = 0; y < rows; y++)
		{
			for (var x = 0; x < cols; x++)
			{
				try
				{
					var cell = sheet.UsedRange.Cells(y + 1, x + 1);
				}
				catch (e)
				{
					window.status = (y + "-" + x + e.description);
//					continue;
				}
				
				var text = cell.Text.replace(/[\s\7]+/g, "");
				var index = $.jcom.inObjArray(fields, "CName", text);
				if (index > 0)
				{
					var offset = cell.MergeArea.Columns.Count;
					if (sheet.UsedRange.Cells(y + 1, x + 1 + offset).Value == undefined)
						text = "";
					else
						text = "" + sheet.UsedRange.Cells(y + 1, x + 1 + offset).Value;
					record[fields[index].EName] = self.onValidField(fields[index].EName, text);
					x += offset;
					cnt ++;
				}
				else
					self.onImportItem("Excel", text, record, fields, sheet, cell);
				
			}
		}
		self.onImport(record, fields, cnt, 3, sheet, filename);
		excel.Workbooks.Close();
	};	
	
	this.QuitOffice = function()	//����:�˳��ѳ�ʼ�����OFFICE���
	{
		try
		{
			if (typeof word == "object")
				word.Quit();
			if (typeof excel == "object")
				excel.Quit();
		}
		catch (e)
		{
		}
		$(window).off("beforeunload", self.QuitOffice);
		word = undefined;
		excel = undefined;
	};
	
	var importwin, importview;
	this.ImportFolder = function (def, filefilter)			//����:ʹ�ñ���API�������ļ��У�WORD��EXCEL���
	{
		var shell = new ActiveXObject("Shell.Application");
		var folder = shell.BrowseForFolder(0, "ѡ��Ҫ������ļ���", 0);
		if (folder == null)
			return;
		if (folder.Items().Count == 0)
			return alert("���ļ���");
		var path = folder.Items().Item(0).Path.substr(0, folder.Items().Item(0).Path.length - folder.Items().Item(0).Name.length);

		var fso = new ActiveXObject("Scripting.FileSystemObject");
		var folder = fso.GetFolder(path);

		var fc = new Enumerator(folder.files);
		var files = [];
		var y = 0;
		if (filefilter == undefined)
			filefilter = ["xls", "doc", "docx"];

		for (; !fc.atEnd(); fc.moveNext())
		{
			var item = fc.item();
			var ex = item.Name.substr(item.Name.lastIndexOf(".") + 1).toLowerCase();
			if ($.inArray(ex, filefilter) >= 0)
				files[y++] = {path:item.Path, FileName:item.Name, FileSize:item.Size, ID:0, Status:"δ����"};
		}
		
		if (importwin == undefined)
		{
			importwin = new $.jcom.PopupWin("<div id=View style=width:100%;height:100%></div>", {title:"�ļ��е���", width:600, height:480});
			importwin.close = function ()
			{
//				self.menubar.setDisabled("����", false);
				importwin.hide();
			}
			var aFace = {x:0,y:30,node:1,a:{id:"Top"},b:{id:"Bottom"}};
			var oLayer = new $.jcom.Layer($("#View")[0], aFace, {border:"1px dotted gray"});
			if (def == undefined)
				def = [{item:"����", action:self.RunImportFolder}];
			var menu = new $.jcom.CommonMenubar(def, $("#Top")[0],{title:""});
			importview = new $.jcom.GridView($("#Bottom")[0], [{FieldName:"FileName", TitleName:"����", nWidth:320, nShowMode:9},
				{FieldName:"FileSize", TitleName:"����", nWidth:60, nShowMode:1},
				{FieldName:"Status", TitleName:"״̬", nWidth:200, nShowMode:1}], files,{},{footstyle:4});
			importview.dblclickRow = self.RunImportFolder;
		}
		else
		{
			importwin.show();
			importview.reload(files);
		}
//		self.menubar.setDisabled("����", true);
	}

	this.RunImportFolder = function(obj, item)	//����:�����ļ���
	{
		var files = importview.getData();
		var row = importview.getSelRow();
	
		if (row == undefined)
			row = importview.select(0);
		var index = parseInt($(row).attr("node"));
		importview.setCell(index, "Status", "���ڵ���");
		self.ImportFolderItem(files[index].path, item);
	};
	
	this.ImportFolderItem = function(path, item)		//����: �����ļ����е�һ���ļ�
	{
		var ex = path.substr(path.length - 3).toLowerCase();
		if (ex == "xls")
			self.ImportExcel(path);
		else if ((ex == "doc") || (ex == "docx"))
			self.ImportWord(path);
	};
	
	this.onValidField = function(key, value)	//�¼�:����ȡĳ�ֶ�ֵ�������û����ɴ����жϵ���������Ƿ���Ҫת����
	{
		return value;
	};

	this.ImportNext = function(id, hint)	//����:������һ���ļ�
	{
		if (importview == undefined)
			return;
		var row = importview.getSelRow();		
		if (row == undefined)
			return 0;
		var index = parseInt($(row).attr("node"));
		importview.setCell(index, "Status", hint);
		importview.setCell(index, "ID", id);
		var files = importview.getData();
		for (var x = index + 1; x < files.length; x++)
		{
			if (files[x].ID == 0)
			{
				importview.select(x);
				self.RunImportFolder();
				return 1;
			}
		}
		return 2;
	};
	
	this.onImportItem = function(appname, text, record, fields, doc, cell)		//�¼�:�����¼�������ȡ�ֶ�δƥ�䵽��Ӧ�ֶκ��������¼������Զ��嵼��ֵ
	{};
		
	this.onImport = function(record, fields, cnt, nType, obj, filename)		//�¼�:������ɺ���
	{
	};	
};

$.jcom.HTMLEditor = function(domobj, cfg)	//��:HTML���ı��༭��
{
	var self = this;
	var tool, ruler, doc, spos;
	var cb, bb, pb, menudef, propwin;

	function getRngObj(obj, tag)
	{
		obj.focus();
		var target = null, item;
		var sel = doc.selection;
		if (typeof sel == "undefined")
		{
			sel = doc.getSelection();
			target = sel.focusNode.parentNode;
		}
		else
		{
			var ttype = sel.type;
			var selrange = sel.createRange();
			switch(ttype)
			{
			case 'Control' :
				if (selrange.length > 0 ) 
					target = selrange.item(0);
				break;
			case 'None' :
				target = selrange.parentElement();
				break;
			case 'Text' :
				target = selrange.parentElement();
				break;
			}
		}
		if ((tag == "") || (tag == undefined))
			return target;
		for (item = target; (item != null) && (item != obj); item = item.parentElement)
		{
			if (item.tagName == tag)
				return item;
		}
		return null;
	}

	function execCommand(obj, item)
	{
		doc.execCommand(item.cmd);
		SetStatus();
	}

	function EditorMenu()
	{
	}

	function KeyFilter()
	{
	}

	function SetStatus()
	{
	var x, value, o;
		if (cfg.nType == 0)
			return;
		
		for (x = spos; x < spos + 9; x++)
		{
			value = doc.queryCommandValue(menudef[x].cmd);
			o = tool.getDomItem(menudef[x]);
			o.style.backgroundColor = value ? "#d0d0d0" : "";
		}
		if (cfg.nType == 3)
			return;

		value = doc.queryCommandValue("ForeColor");
		cb.firstChild.style.backgroundColor = rgb(value);
		value = doc.queryCommandValue("BackColor");
		bb.firstChild.style.backgroundColor = rgb(value);
		value = doc.queryCommandValue("FormatBlock");
		o = $(domobj).find("#psel")[0];
		for (x = 0; x < o.options.length; x++)
		{
			if (o.options[x].innerText == value)
			{
				o.value = o.options[x].value;
				break;
			}
		}
		value = doc.queryCommandValue("FontName");
		o = $(domobj).find("#fsel")[0];
		for (var x = 0; x < o.options.length; x++)
		{
			if (o.options[x].innerText == value)
			{
				o.selectedIndex = x;
				break;
			}
		}
		o = getRngObj(doc.body);
		if (typeof o.currentStyle == "object")
			value = getRngObj(doc.body).currentStyle.fontSize;
		else
			value = doc.defaultView.getComputedStyle(o,null).fontSize;
		o = $(domobj).find("#ssel")[0];
		for (x = 0; x < o.options.length; x++)
		{
			if (o.options[x].innerText == value)
			{
				o.selectedIndex = x;
				break;
			}
		}
		if (x == o.options.length)
			o.value = "";
		if (cfg.nType == 2)
			return;			
		if ((typeof propwin == "object") && (propwin.closed == false))
		{
			pb.style.backgroundColor = "#d0d0d0";
			doc.body.focus();
			o = getRngObj(doc.body, "");
			propwin.InitObject(o);
		}
		else
			pb.style.backgroundColor = "";
	}

	function rgb(color)
	{
		if (color == null)
			color = 0;
		var c = "00000" + color.toString(16);
		c = c.substr(c.length - 6);
		return "#" + c.substr(4, 2) + c.substr(2, 2) + c.substr(0, 2);
	}

	function prop()
	{
		if ((typeof propwin == "object") && (propwin.closed == false))
			return;
		propwin = window.showModelessDialog("/HTMLProp.htm", getRngObj(doc.body, ""),
			"dialogWidth:320px;dialogHeight:400px;status:0;scroll:0;help:0");
	}

	function setcolor(obj, item)
	{
		var color = SelectColor(0);
		doc.body.focus();
		if (typeof(color) != "string")
			return;
		doc.execCommand(item.cmd, false, color);
		obj.firstChild.style.backgroundColor = color;
	}

	function insertTable()
	{
		var tag = showModalDialog("/HTMLtable.htm", window, "dialogWidth:22em; dialogHeight:18em; status:0;scroll:no;");
		self.insertHTML(tag);
	}

	function insertRow()
	{
		var tab = getRngObj(doc.body, "TABLE");
		if (tab == null)
			return;
		var row = tab.insertRow();
		for (var x = 0; x < tab.rows[0].cells.length; x++)
		{
			var cell = row.insertCell();
			cell.bgColor = tab.rows[0].cells[x].bgColor;
		}
	}

	function deleteRow()
	{
		var tr = getRngObj(doc.body, "TR");
		if (tr != null)
			$(tr).remove();
	}

	function insertCol()
	{
		var tab = getRngObj(doc.body, "TABLE");
		if (tab == null)
			return;
		for (var x = 0; x < tab.rows.length; x++)
		{
			var cell = tab.rows[x].insertCell();
			cell.bgColor = tab.rows[x].cells[0].bgColor;
		}
	}

	function deleteCol()
	{
		var td = getRngObj(doc.body, "TD");
		if (td == null)
			return;
		var tab = td.parentNode.parentNode.parentNode;
		var pos = td.cellIndex;
		for(var x = 0; x < tab.rows.length; x++)
			$(tab.rows[x].cells[pos]).remove();		//tab.rows[x].cells[pos].removeNode(true);
	}

	function insertCell()
	{
		var td = getRngObj(doc.body, "TD");
		if (td == null)
			return;
		var cell = td.parentNode.insertCell();
		cell.bgColor = td.bgColor;
	}

	function deleteCell()
	{
		var td = getRngObj(doc.body, "TD");
		if (td != null)
			$(td).remove();
	}

	function exCell(obj, item)
	{
		var td = getRngObj(doc.body, "TD");
		if (td == null)
			return;
		if (item.cmd == 1)
			td.colSpan += 1;
		if (item.cmd == 2)
			td.rowSpan += 1;
	}

	function insertImg()
	{
		var tag = showModalDialog("/SelectImg.htm", doc, "dialogWidth:480px; dialogHeight:220px; status:0;scroll:no;");
		self.insertHTML(tag);
	}

	function preview()
	{
		var win = new $.jcom.PopupWin("<iframe id=pview frameborder=0 style=width:100%;height:100%></iframe>",{title:"ҳ��Ԥ��",width:500,height:400,mask:30});
		$("#pview")[0].contentWindow.document.write(doc.getElementsByTagName("HTML")[0].outerHTML);
	}

	function viewsource()
	{
		var win = new $.jcom.PopupWin("<div style='width:100%;height:100%;padding-bottom:30px;'><textarea id=hsrc style=width:100%;height:100%;>" +
			"</textarea></div><div align=right style=position:relative;top:-28px><input id=runsrc type=button value=Ӧ��>&nbsp;</div>",
			{title:"HTML����",width:500,height:400,mask:30});
		$("#hsrc").val(doc.getElementsByTagName("HTML")[0].outerHTML);
		win.show(-1, -1, 640, 480);
		$("#runsrc")[0].onclick = applysrc;
	}

	function applysrc()
	{
		doc.write($("#hsrc").val());
		doc.close();
	}

	function formatblock()
	{
		doc.body.focus();
		doc.execCommand("FormatBlock", false, "<" + event.srcElement.value + ">");
	}

	function selfont()
	{
		doc.body.focus();
		doc.execCommand("FontName", false, event.srcElement.options[event.srcElement.selectedIndex].innerText);
	}

	function selsize()
	{
		doc.body.focus();
	 	var oRange = doc.selection.createRange();
		if (oRange.boundingWidth > 0)
		{
			doc.execCommand("FontName", false, "eWebEditor_Temp_FontName");
			var fs = doc.getElementsByTagName("FONT");
			for (var x = 0; x < fs.length; x++)
			{
				if (fs[x].face == "eWebEditor_Temp_FontName")
				{
					fs[x].removeAttribute("face");
					fs[x].style.fontSize = event.srcElement.options[event.srcElement.selectedIndex].innerText;
				}
			}
			return;
		}
		var tag = "<span id=TEMPSPAN style=width:8px;font-size:" + event.srcElement.options[event.srcElement.selectedIndex].innerText + "></span>";
		var mark = oRange.getBookmark();
		var x = oRange.move("character", 1);
		if (x > 0)
		{
			oRange.moveToBookmark(mark);
			oRange.pasteHTML(tag);
		}
		else
		{
			var o = oRange.parentElement();
			if (o.currentStyle.display == "block")
				oRange.pasteHTML(tag);
			else
				o.insertAdjacentHTML("afterEnd", tag);
		}
		oRange.moveToElementText(doc.all.TEMPSPAN);
		doc.all.TEMPSPAN.style.width = "";
		doc.all.TEMPSPAN.removeAttribute("id");
		oRange.select();
	}

	function Init()
	{
		if (typeof domobj != "object")
			return;
		var text = domobj.innerHTML;
		domobj.innerHTML = "<div class=HTMLEditToolbar></div>" +
			"<div id=HTMLEditorDiv style='width:100%;height:100%;padding-bottom:28px;overflow:hidden;'>" +
			"<iframe id=HTMLEditFrame class=HTMLEditorFrame style='width:100%;height:100%;' frameborder=0 scrolling='yes'></iframe></div>" +
			"<textarea style=border:0;width:100%;height:100%;display:none; name=" + cfg.EName + "></textarea>";
//			"<div style='width:100%;height:26px;background-color:" + cfg.footbkcolor + "'></div>";
		menudef = [];
		if (cfg.nType == 1)	//compelete
		{
			menudef[0] = {title:"�鿴", img:cfg.pdir + "tasks16.gif", child:[
				{item:"ҳ��Ԥ��", action:preview}, {item:"�鿴HTMLԴ����", action:viewsource}]}; 
			menudef[1] = {}; 
			menudef[2] = {title:"����", cmd:"Cut", img:cfg.pdir + "cut.gif", action:execCommand};
			menudef[3] = {title:"����", cmd:"Copy", img:cfg.pdir + "copy.gif", action:execCommand};
			menudef[4] = {title:"ճ��", cmd:"Paste", img:cfg.pdir + "paste.gif", action:execCommand};
			menudef[5] = {title:"����", img:cfg.pdir + "property.gif", action:prop};
			menudef[6] = {};
		}
		if ((cfg.nType == 1) || (cfg.nType == 2))	//compelete or middle
		{	
			menudef[menudef.length] = "<select id=psel align=middle style=width:54px><option value=P>��ͨ</option>" +
				"<option value=H1>����1</option><option value=H2>����2</option><option value=H3>����3</option>" +
				"<option value=H4>����4</option><option value=H5>����5</option><option value=H6>����6</option>" +
				"<option value=PRE>�ѱ��Ÿ�ʽ</option><option value=ADDRESS>��ַ</option></select>";
			menudef[menudef.length] = "<select id=fsel align=middle style=width:54px><option value=����>����</option>" +
				"<option>����</option><option>����</option><option>����</option><option>����</option><option>��Բ</option>" +
				"<option>������</option><option>΢���ź�</option><option>ϸ����</option>" +
				"<option>Arial</option><option>Arial Black</option><option>Arial Narrow</option>" +
				"<option>Bradley Hand ITC</option><option>Brush Script MT</option><option>Century Gothic</option>" +
				"<option>Comic Sans MS</option><option>Courier</option><option>MS Sans Serif</option>" +
				"<option>Script</option><option>System</option><option>Times New Roman</option>" +
				"<option>Viner Hand ITC</option><option>Verdana</option><option>Wide Latin</option><option>Wingdings</option></select>";
			menudef[menudef.length] = "<select id=ssel align=middle style=width:44px><option>9px</option><option>10px</option><option>11px</option>" +
				"<option>12px</option><option>13px</option><option>14px</option><option>15px</option>" +
				"<option>16px</option><option>18px</option><option>20px</option><option>22px</option>" +
				"<option>24px</option><option>26px</option><option>28px</option><option>36px</option>" +
				"<option>48px</option><option>72px</option></select>";
			menudef[menudef.length] = {title:"������ɫ", cmd:"ForeColor", img:cfg.pdir + "fgcolor1.gif", action:setcolor};
			menudef[menudef.length] = {title:"������ɫ", cmd:"BackColor", img:cfg.pdir + "fbcolor1.gif", action:setcolor};
			menudef[menudef.length] = {};
		}
		if ((cfg.nType == 1) || (cfg.nType == 2) || (cfg.nType == 3))	//compelete or middle or short
		{
			spos = menudef.length;
			menudef[menudef.length] = {title:"����", cmd:"Bold", img:cfg.pdir + "bold.gif", action:execCommand};
			menudef[menudef.length] = {title:"б��", cmd:"Italic", img:cfg.pdir + "italic.gif", action:execCommand};
			menudef[menudef.length] = {title:"�»���", cmd:"Underline", img:cfg.pdir + "under.gif", action:execCommand};
			menudef[menudef.length] = {title:"ɾ����", cmd:"StrikeThrough", img:cfg.pdir + "strike.gif", action:execCommand};
			menudef[menudef.length] = {title:"�����", cmd:"JustifyLeft", img:cfg.pdir + "aleft.gif", action:execCommand};
			menudef[menudef.length] = {title:"����", cmd:"JustifyCenter", img:cfg.pdir + "center.gif", action:execCommand};
			menudef[menudef.length] = {title:"�Ҷ���", cmd:"JustifyRight", img:cfg.pdir + "aright.gif", action:execCommand};
			menudef[menudef.length] = {title:"��Ŀ����", cmd:"InsertUnorderedList", img:cfg.pdir + "bullist.gif", action:execCommand}; 
			menudef[menudef.length] = {title:"���ֱ��", cmd:"InsertOrderedList", img:cfg.pdir + "numlist.gif", action:execCommand};
			menudef[menudef.length] = {};
		}
		if ((cfg.nType == 1) || (cfg.nType == 2))	//compelete or middle
		{	
			menudef[menudef.length] = {title:"���", img:cfg.pdir + "tablesel.gif", child:[
				{item:"������", img:cfg.pdir + "table.gif", action:insertTable},
				{item:"������", img:cfg.pdir + "insrow.gif", action:insertRow},
				{item:"ɾ����", img:cfg.pdir + "delrow.gif", action:deleteRow},
				{item:"������", img:cfg.pdir + "inscol.gif", action:insertCol},
				{item:"ɾ����", img:cfg.pdir + "delcol.gif", action:deleteCol},
				{item:"���뵥Ԫ��", img:cfg.pdir + "inscell.gif", action:insertCell},
				{item:"ɾ����Ԫ��", img:cfg.pdir + "delcell.gif", action:deleteCell},
				{item:"������Ԫ��", cmd:1, img:cfg.pdir + "excellh.gif", action:exCell},
				{item:"������Ԫ��", cmd:2, img:cfg.pdir + "excellv.gif", action:exCell}]};
			menudef[menudef.length] = {title:"��������", cmd:"CreateLink", img:cfg.pdir + "link.gif", action:execCommand};
			menudef[menudef.length] = {title:"����ͼƬ", img:cfg.pdir + "image.gif", action:insertImg};
		}
		if (cfg.nType > 0)
		{
			tool = new $.jcom.CommonMenubar(menudef, domobj.firstChild, {tagName:"SPAN"});
			cb = tool.getDomItem("������ɫ");
			bb = tool.getDomItem("������ɫ");
			pb = tool.getDomItem("����");
			if ((cfg.nType == 1) || (cfg.nType == 2))	//compelete or middle
			{
				$(domobj).find("#psel").on("change", formatblock);
				$(domobj).find("#fsel").on("change", selfont);
				$(domobj).find("#ssel").on("change", selsize);
			}
		}
		else
			domobj.firstChild.style.display = "none";
		doc = $(domobj).find("#HTMLEditFrame")[0].contentWindow.document;
		doc.designMode = "on";
		if (text == "")
			text = "<p>&nbsp;</p>";
		doc.write("<HTML><head><link rel='stylesheet' type='text/css' href='" + cfg.css + "'></head><BODY style=margin:0px;>" + text + "</BODY></HTML>");
		domobj.lastChild.value = text;
		$(doc).on("contextmenu",EditorMenu);
		$(doc).on("mouseup", SetStatus);
//		$(doc).on("keydown", KeyFilter);
		$(doc).on("keyup", SetStatus);
	}

	this.Text = function (v)	//����:��ȡ�����ñ༭����ı�
	{
		if (typeof v == "string")
			doc.body.innerHTML = v;
		return doc.body.innerHTML;
	};
	
	this.copydata = function()		//����:�����ı����ݱ��浽�ı����У��Ա��ύ
	{
		var o = $("textarea[name='" + cfg.EName + "']", domobj);
		o.val(doc.getElementsByTagName("HTML")[0].outerHTML);
		return o.val();
	};

	this.gettool = function()		//����:���ع�����
	{
		return tool;
	};

	this.getdoc = function()		//����:���ر༭��document����
	{
		return doc;
	};

	this.insertHTML = function(tag)		//����:���볬�ı�����
	{
		if (typeof(tag) != "string")
			return;
		doc.body.focus();
		if (typeof doc.selection == "object")
		{
		 	var oRange = doc.selection.createRange();
			oRange.pasteHTML(tag);
		}
		else
		{
			var r = doc.getSelection().getRangeAt(0);
			var oFragment = r.createContextualFragment(tag); 
			r.deleteContents();
			r.insertNode(oFragment);
		}
	};

	this.setDomObj = function (obj)	//����:��������DOM����
	{
		if (typeof domobj == "object")
		{
			$(doc).off("contextmenu",EditorMenu);
			$(doc).off("mouseup", SetStatus);
//			$(doc).off("keydown", KeyFilter);
			$(doc).off("keyup", SetStatus);
			$("#HTMLEditFrame", domobj).remove();
			tool.setDOMObj();
			domobj = undefined;
		}
		if (typeof obj == "object")
		{
			domobj = obj;
			Init();
		}
	};
	
	if (typeof domobj == "object")
	{
		cfg = $.jcom.initObjVal({EName:domobj.id, toolbkcolor:"#f7f5f4", footbkcolor:"#eeeeee", css: "../com/forum.css", pdir:"../com/pic/", nType:1}, cfg);
		Init();
	}
};

$.jcom.DynaEditor = {};	//"�༯:��̬�༭���༯��"
$.jcom.DynaEditor.Base = function(width, height)	//��:����
{//����,ʵ��һ����������ͷ�ı༭��,���������������,����������������ʵ��.

	this.oHost = undefined;		//������̬�༭���ԭ����
	this.oEdit = undefined;		//��̬���ɵı༭���DOM����
	this.oButton = undefined;	//��̬���ɵ�������ť�����ض���Ϊ������;
	this.oBox = undefined;		//������������ΪPopupBox����
	this.value = "";		//�༭�����ֵ
	this.bLastValue = true;		//�Ƿ��ס�ϴα༭����ֵ
	this.type = 0;			//�����������

	var self = this;
	var cfg = {bAutoPop:true, MutiItem:0, editorMode:1, OverWriteMode:false, bHint:false, hintColor:"rgb(192, 192, 192)"};	//editMode:0,��������ť���ޱ༭��.1:�б༭���������ť,2:�б༭��,��������ť,3:����CONTENTEDITABLE����ʵ�ֱ༭����������ť��4������CONTENTEDITABLE����ʵ�ֱ༭����������ť�� 
	var popImg = "<span style='background-color:white;cursor:default;vertical-align:top;margin-left:-13px;width:13px;overflow:hidden'>" +
		"<span style=position:relative;top:-6px;>&#9662</span></span>";
	this.attach = function(obj) //����:����̬�༭���󶨵�DOM����
	{
		var e = "mousedown";
		if ((obj.tagName == "INPUT") || (obj.tagName == "TEXTAREA") || (obj.tagName == "SELECT") || (obj.contentEditable == "true"))
			e = "focus";
		$(obj).on(e, self.preshow);
		if (cfg.bHint)
			self.checkTitle(obj, false);
	};

	this.detach = function(obj, flag) //����:���DOM����Ķ�̬�༭����
	{
		if (cfg.bHint)
			self.checkTitle(obj, true);
		var e = "mousedown";
		if ((obj.tagName == "INPUT") || (obj.tagName == "TEXTAREA") || (obj.tagName == "SELECT"))
			e = "focus";
		$(obj).off(e, self.preshow);
	};

	this.insert = function(obj, width, height, value) //����:����̬�༭�����뵽DOM�������Χλ��
	{
		this.create();
		obj.parentNode.appendChild(self.oEdit);
		self.oEdit.style.position = "static";
		self.oEdit.style.display = "inline";
		if (typeof width != "undefined")
			self.oEdit.style.width = width;
		if (typeof height != "undefined")
			self.oEdit.style.height = height;
		if (typeof value != "undefined")
		{
			self.value = value;
			self.oEdit.firstChild.value = value;
			self.oEdit.firstChild.select();
			self.oEdit.firstChild.focus();
		}
	};
	
	this.remove = function () //����:�Ƴ�����Ķ�̬�༭������,��insert��������
	{
		$(self.oEdit).remove();
	};

/*
	this.active = function (obj)		//����:��DOM�������óɿɱ༭״̬���������ֵΪ��ʱ��ʹ��title��Ϊ��ʾ������༭״̬����ʾ��ʧ����������inactive��������editModeΪ3��4ʱ��Ч��
	{
		obj.contentEditable = "true";
//		self.setTitle(obj.title);
//		$(obj).on("focus", focusField);
//		$(obj).on("blur", blurField);
//		$(obj).on("paste", self.pasteText);
//		if ((obj.innerText == "") && (obj.title != ""))
//		{
//			obj.innerText = obj.title;
//			obj.style.color = "gray";
//		}		
	};

	this.inactive = function (obj)		//����:�������Ŀɱ༭����
	{
		obj.contentEditable = "false";
		self.setTitle();
//		$(obj).off("focus", focusField);
//		$(obj).off("blur", blurField);
//		$(obj).off("paste", self.pasteText);
//		obj.style.color = "black";
//		if (obj.title == obj.innerText)
//			obj.innerText = "";
	};
*/	
	this.create = function()	 //����:������̬�༭���ڵ�һ��ʹ��ʱ����
	{
		switch (cfg.editorMode)
		{
		case 1:		//�б༭���������ť
		case 2:		//�б༭��,��������ť
			var tag = self.createTag();
			if (typeof tag == "string")
			{
				self.oEdit = document.createElement("SPAN");
				$(self.oEdit).css({position: "fixed", overflow: "hidden", display: "none", border: "1px solid gray", zIndex:99});
				self.oEdit.innerHTML = tag;				
			}
			if (typeof tag == "object")
				self.oEdit = tag;
			$(document.body).append(self.oEdit);
			var o = $(self.oEdit.firstChild);
			o.on("change", self.onChange);
			o.on("keydown", self.keydown);
//			o.on("blur", self.hide);
			o.on("compositionend", self.onPropChange);
			if (self.oEdit.firstChild != self.oEdit.lastChild)
			{
				self.oButton = self.oEdit.lastChild;
				$(self.oButton).on("mouseover", self.OverButton);
				$(self.oButton).on("mouseout", self.OutButton);
				$(self.oButton).on("mousedown",  self.runButton);
			}
			break;
		}		
	};


	this.prehide = function(event)	//����:���ݸ������¼����λ�ã��ж��Ƿ����ض���
	{
		if ((self.oHost == event.target) || (self.oEdit == event.target) || ($(event.target).is($(self.oEdit).children())))
			return;
		if (typeof self.oBox != "object")
			return self.hide();
		var b = self.oBox.getdomobj();
		if ((b == event.target) || ($(event.target).parents().is($(b))))
			return;
		self.hide(event);
	};

	this.preshow = function(event)	//����:�ӳ���ʾ��̬�༭��
	{
		var o = event.target;
		if (o.nodeType == 3)
			o = o.parentNode;
		switch (cfg.editorMode)	//��Ԥ�����ã�IE�����벻������
		{
		case 3:		//����CONTENTEDITABLE����ʵ�ֱ༭����������ť  == δʵ��
			if (self.oButton == undefined)
			{
				self.oButton = document.createElement(popImg);
				$(document.body).append(self.oButton);
				$(self.oButton).css({display:"none", position:"fixed"});
				$(self.oButton).on("mouseover", self.OverButton);
				$(self.oButton).on("mouseout", self.OutButton);
				$(self.oButton).on("mousedown",  self.runButton);
			}
			var pos = $.jcom.getObjPos(o);
			$(self.oButton).css({display:"inline", left:pos.right + "px", top:pos.top + "px"});			
		case 4:		//����CONTENTEDITABLE����ʵ�ֱ༭����������ť
			if (o.contentEditable == "true")
				return;
			o.contentEditable = "true";
			var o = $(o);
			o.on("compositionstart", CnStart);
			o.on("compositionend", self.onPropChange);
			o.on("keyup",CnKey);
			o.on("keydown", keydown);
			o.on("paste", self.pasteText);
			break;
		}
		window.setTimeout(function(){self.show(event);}, 10);
	};

	var Cnflag = 0;
	function CnStart(e)
	{
		Cnflag = 1;
	}
	
	function CnKey(e)
	{
		if (Cnflag == 1)
			return;
		self.onPropChange(e);
	}
	
	function keydown(event)
	{
		switch (event.which)
		{
		case 13:
			self.hide();
			return false;
		}
		return self.keydown(event);
	}
	
	this.show = function(event) //����:��ʾ��̬�༭��
	{
		self.hide();
		self.oHost = event.target;
		if (event.target.nodeType == 3)
			self.oHost = event.target.parentNode;
		self.checkTitle(self.oHost, true);
		self.value = self.getHostValue();

		if (cfg.editorMode > 0)
		{
			if (typeof self.oEdit == "undefined")
				self.create();
			if (typeof self.oEdit == "object")
			{
				var pos = $.jcom.getObjPos(self.oHost);
				if (pos.p != "fixed")
					self.oEdit.style.position = "absolute";
				self.oEdit.style.display = "";
				self.oEdit.style.width = (pos.right - pos.left + 2) + "px";
				self.oEdit.style.height = (pos.bottom - pos.top + 2) + "px";
				self.oEdit.style.left = pos.left + "px";
				self.oEdit.style.top = (pos.top - 1) + "px";
//				$(document.body).append(self.oEdit);

				self.oHost.style.visibility = "hidden";
				self.oEdit.firstChild.value = self.value;
				if (self.oEdit.firstChild.tagName == "INPUT")
				{
					self.oEdit.firstChild.select();
					self.oEdit.firstChild.focus();
//					self.checkTitle(self.oEdit.firstChild, true);
				}
				var value = $.trim(self.oEdit.firstChild.value);
				if (self.bLastValue && (value == "") && (self.value != ""))
					self.setValue(self.value);
			}
		}
		if (cfg.OverWriteMode)
		{
			if (document.queryCommandValue("OverWrite") == false)
				document.execCommand("OverWrite");
		}
		if (cfg.bAutoPop)
			self.popDown();
		$(document).on("mousedown",self.prehide);
//		$(document).on("keydown", self.prehide);	�ж��������ط���������ض����ƺ��ж�����
		self.onShow();
	};
	
	this.onShow = function () //�¼�:��ʾ��ɺ���
	{
	};
	
	this.getHostValue = function () //����:������������ֵ
	{
		if (self.oHost.tagName == "INPUT")
			return self.oHost.value;
		return self.oHost.innerText;
	}

	this.hide = function(event) //����:���ر�����
	{
		if (self.oHost == undefined)
			return;
		self.oHost.style.visibility = "visible";
		if (cfg.editorMode > 2)
		{
			if (self.oHost.contentEditable == "true")
			{
				var o = $(self.oHost);
				o.off("compositionstart", CnStart);
				o.off("compositionend", self.onPropChange);
				o.off("keyup",CnKey);
				o.off("keydown", keydown);
				o.off("paste", self.pasteText);
				if (self.value != self.oHost.innerText)
					self.onChange();
				self.oHost.contentEditable = "false";
				if (typeof self.oButton == "object")
					$(self.oButton).css({display:"none"});
			}
		}
		self.checkTitle(self.oHost, false);
		if (typeof self.oEdit == "object")
			self.oEdit.style.display = "none";

		if (typeof self.oBox == "object")
			self.oBox.hide();
		$(document).off("mousedown", self.prehide);
		$(document).off("keydown", self.prehide);
		self.onBlur(self.oHost);
		self.oHost = undefined;
	};
	
	this.isBoxShow = function ()	//����:�����½ӿ��Ƿ���ʾ
	{
		if (typeof self.oBox != "object")
			return false;
		return self.oBox.isShow();
	};
	
	this.onBlur = function (oHost) //�¼�:��ʧȥ�������
	{};
	
	this.onChange = function() //�¼�:���༭�������仯�����
	{
		if (typeof self.oEdit != "object")
		{
			self.value = self.oHost.innerText;
		}
		else
		{
			self.value = self.oEdit.firstChild.value;
			if (typeof self.oHost == "object")
			{
				if (self.oHost.tagName == "INPUT")
					self.oHost.value = self.value;
				else
					self.oHost.innerText = self.value;
				self.checkTitle(self.oHost, false);
				$(self.oHost).attr("node", $(self.oEdit.firstChild).attr("node"));
			if ((self.oHost.tagName == "INPUT") || (self.oHost.tagName == "TEXTAREA"))
				$(self.oHost).trigger("change");
			}
		}
		self.valueChange(self.oHost);
	};

	this.valueChange = function (oHost) //�¼�:���༭��ֵ�仯�������ΪonChange�������¼�
	{};

	this.onPropChange = function(e)	//�¼�:�����Ա仯�����
	{
		Cnflag = 0;
		if (typeof self.oEdit != "object")
		{
			if (self.oHost.innerText != self.value)
				return self.onCharChange(self.oHost.innerText);
			return;
		}
		if (self.oEdit.firstChild.value == self.value)
			return;
		if (document.selection.createRange().parentElement() != self.oEdit.firstChild)
			return;
		self.onCharChange(self.oEdit.firstChild.value);
	};
	
	this.onCharChange = function(value)		//�¼�:���ַ��仯�����
	{};

	this.pasteText = function()			//����:ȡ���������е��ı���ճ�����༭��
	{
//		self.oHost.innerText = clipboardData.getData("Text");
		var text = clipboardData.getData("Text");
		text = text.replace(/\n/g, "<br>");
	 	var oRange = document.selection.createRange();
		oRange.pasteHTML(text);
		return false;
	}
	
	this.setValue = function(value, exvalue) //����:���ñ༭����ֵ
	{
//		if (self.oEdit.firstChild.value == value)
//			return;
		self.value = value;
		var o = self.oEdit;
		if (typeof o != "object")
			o = self.oHost;
		else
			o  = o.firstChild;
		if (exvalue == undefined)
			exvalue = value;
		else
		{
			$(o).attr("node", value);
			self.value = exvalue;
		}
		if (typeof self.oEdit != "object")
		{
			if (cfg.MutiItem == 1)
				o.innerText += "," + exvalue;
			else
				o.innerText = exvalue;
		}
		else
		{
			if (cfg.MutiItem == 1)
				o.value += "," + exvalue;
			else
				o.value = exvalue;
		}
//		self.oEdit.firstChild.focus();		//�����䵼��SPINʧȥ����
//		self.oEdit.firstChild.blur();
//		self.onChange();
//		self.oHost.firstChild.fireEvent("onchange");
	};
	
	this.getValue = function () //����:��ñ༭����ֵ
	{
		return self.value;
	};
	
	this.confirm = function(value) //����:���ñ༭����ֵ�������ر༭��
	{
		if( self.value != value)
		{
			self.setValue(value);
			self.onChange();
		}
		self.hide();
	};
	
	this.createTag = function ()	//����:����Ĭ�ϵı༭�������ش˷������Զ���༭��
	{
		var tag = "<input type=text style='overflow:hidden;border:none;width:100%;height:100%;margin:0 13px 0 0'>";
		if  ((cfg.editorMode == 1) || (cfg.editorMode == 3))
			return tag + popImg;
		return tag;
	};
	
	
	this.createPop = function() //����:���������򣬻��������Ϊ�հף������������Ҫ������Ӧ����
	{
		var tag = "<div style='border:1px solid gray;width:" + self.width  + "px;height:" + self.height + "px;'></div>";
		self.oBox.setPopObj(tag);
	};

	this.setPopImg = function (pic, width)	//����:���ñ༭���½ӵ�ͼƬ
	{
		if ((typeof pic != "string") || (pic == ""))
		{
			popImg = "";
			return;
		}
		var style = "";
		if (typeof width != "undefined")
			style = " style=margin-left:-" + width + "px;";

		if (pic.substr(0, 1) == "<")
			popImg = pic
		else
			popImg = "<img UNSELECTABLE=on src=" + pic + style + ">";
	};
	
	this.onpop = function() //�¼�:����������ʱ����
	{};
	
	this.OverButton = function()	//�¼�:��껬��������ťʱ����
	{
		if (self.oEdit == undefined)
			return;
		self.oEdit.lastChild.style.borderLeft = "1px solid gray";
		self.oEdit.lastChild.style.filter = "progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#f6faff', EndColorStr='#86dffe')";
	}
	
	this.OutButton = function()		//�¼�:����뿪�½Ӱ�ťʱ����
	{
		if (self.oEdit == undefined)
			return;
		self.oEdit.lastChild.style.borderLeft = "1px solid transparent";
		self.oEdit.lastChild.style.filter = "";
	};

	this.runButton = function ()	//����:���а�ť��������������������;
	{
		self.popDown();
	};
	
	this.popDown = function()	//����:����������
	{
		if (self.oHost == undefined)
			return;
		self.width = width;
		self.height = height;
		var pos = $.jcom.getObjPos(self.oHost);
		if ((self.width == 0) || (typeof self.height == "undefined"))
			self.width = pos.right - pos.left + 40;
		if ((self.height == 0) || (typeof self.height == "undefined"))
			self.height = 200;
		if (typeof self.oBox == "undefined")
		{
			var cfg = {};
			if (pos.p != "fixed")
				cfg = {position:"absolute"};
			self.oBox = new $.jcom.PopupBox("", pos.left, pos.top, pos.left, pos.bottom - 1, cfg);
			self.createPop();
			self.oBox.hide();
		}
		if (self.oBox.isShow())
			self.oBox.hide();
		else
		{
			self.onpop();
			self.oBox.show(pos.left, pos.top, pos.left, pos.bottom - 1);
			self.oBox.top(); 
		}
	};
	
	this.hidePop = function () //����:�����½ӿ�
	{
		if (typeof self.oBox == "object")
			self.oBox.hide();
	};

	this.config = function (c) //����:�ı�����
	{
		cfg = $.jcom.initObjVal(cfg, c);
		return cfg;
	};

/*	
	this.setTitle = function (title) //����:�����������ʾ�������������Ϊ�գ��Ҳ��������뽹��ʱ���֣������뽹�����ʱ���������
	{
		self.title = title;
		if ((self.title == "") || (self.title == undefined))
		{
			clearTitle();
			$(self.oEdit.firstChild).off("focus", clearTitle);
			$(self.oEdit.firstChild).off("blur", checkTitle);
			return;
		}
		checkTitle();
		$(self.oEdit.firstChild).on("focus", clearTitle);
		$(self.oEdit.firstChild).on("blur", checkTitle);

	};
	

	function clearTitle()
	{
		if (self.oEdit.firstChild.style.color != "")
		{
			self.oEdit.firstChild.style.color = "";
			self.oEdit.firstChild.value = "";
		}
	}
*/
	this.checkTitle = function(obj, bfocus)	//����:������������ݣ��Ƿ�����ʾ����������Ӧ����ɫ
	{
		if (cfg.bHint == false)
			return;
		if (bfocus)
		{
			if (obj.style.color == cfg.hintColor)
			{
				if (obj.innerText == obj.title)
					obj.innerText = "";
				obj.style.color = "black";
			}
		}
		else
		{
			if (obj.innerText == "")
			{
				obj.innerText = obj.title;
				obj.style.color = cfg.hintColor;
			}
			else
				obj.style.color = "black";
		}
	};
	
	this.keydown = function (event) //�¼�:�����¼�
	{
	};
	
	this.keydownHost = function () //�¼�:��ʱ����
	{};
};

$.jcom.DynaEditor.Date = function (width, height, cfg)	//��:���ڿ�
{//��̬���ڱ༭��,���ࣺ$.jcom.DynaEditor.Base

	var self = this;
	var calendar;
	$.jcom.DynaEditor.Base.call(this, width, height);
	self.type = 1;
	
	this.createPop = function ()	//����:�������ڵ�����
	{
		var obj = self.oBox.getdomobj();
		obj.className = "CanlendarDiv";
		obj.style.border = "1px solid gray";
		obj.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
		obj.style.width = self.width + "px";
		obj.style.height = self.height + "px";
		calendar = new $.jcom.CalendarBase(0, obj, cfg);
		calendar.onDateComplete = confirm;
	};
	
	function confirm(t)
	{
		self.confirm(calendar.getDateString());
	};
	
	this.onpop = function ()	//�¼�:�������������¼�����������ʱ��
	{
		calendar.show(self.value);
		var d = calendar.getDateString();
//		self.oEdit.firstChild.value = d;
		calendar.selDateCell(d);
	};
};

$.jcom.DynaEditor.List = function(data, width, height, enumflag)	//��:�б��
{//��̬�б�༭��,���ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Base.call(this, width, height);
	self.type = 2;
	if (height == 0)
		height = 200;
	var shadow = new $.jcom.CommonShadow(1, "SelectObj");
		
	this.createPop = function ()	//����:�����б��
	{
		var tag = "";
		if (typeof data == "string")
		{
			if  (data.substr(0, 1) == "(")
				data = data.substr(1, data.length - 2);
			var ss = data.split(",");
			for (var x = 0; x < ss.length; x++)
			{
				var sss = ss[x].split(":");
				if ((enumflag == 1) && (sss.length > 1))
					tag += "<div UNSELECTABLE=on node=" + sss[0] + " nowrap style=cursor:default;padding-left:4px>" + sss[1] + "</div>";
				else
					tag += "<div UNSELECTABLE=on nowrap style=cursor:default;padding-left:4px>" + ss[x] + "</div>";
			}
		}
		self.oBox.setPopObj(tag);
		var div = self.oBox.getdomobj();
		div.style.border = "1px solid gray";
		div.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
		div.style.overflowY = "auto";
		div.style.overflowX = "hidden";
		div.style.width = width + "px";
		div.style.height = height + "px";
		$(div).on("click", function (event)
		{
			if (event.target != div)
			{
				if ($(event.target).attr("node") != undefined)
					$(self.oEdit.firstChild).attr("node", $(event.target).attr("node"));
				self.confirm($(event.target).text());
			}
			
		});
		$(div).on("mouseover", function(event)
		{
			var obj = event.target;
			if (obj.tagName != "DIV")
				obj = obj.parentNode;
			if (obj != div)
				 shadow.show(obj);
		});
	};
	
	this.onpop = function()	//�¼�:�������¼��������б�ߴ�
	{
		var div = self.oBox.getdomobj();
		div.style.width = self.width + "px";
		if ((typeof(self.height) != "undefined") && (div.clientHeight > self.height))
			div.style.height = self.height + "px";
	};
	
	this.setData = function (d)	//����:�����б�����
	{
		data = d;
		if (typeof self.oBox == "object")
		{
			shadow.hide();
			self.oBox.remove();
			self.oBox = undefined;
		}
//		self.value = "";		//Ӱ�쵽Search�࣬�����жϲ�������ı仯����ע�͵������᲻��Ӱ������
	};
	
	this.getData = function ()	//����:����б�����
	{
		return data;
	};
	
	this.keydown = function ()	//�¼�:���̼�����ʱ����
	{
		var sel = shadow.getObj();
		switch (event.keyCode)
		{
		case 40:		//down
			if (typeof sel == "object")
				sel = sel.nextSibling;
			break;
		case 38:		//up
			if (typeof sel == "object")
				sel = sel.previousSibling;
			break;
		case 13:	//enter
			self.confirm(self.oEdit.firstChild.value);
		default:
			return;
		}
		if (typeof self.oBox != "object")
			return;
		var div = self.oBox.getdomobj();
		if (typeof sel == "undefined")
			sel = div.firstChild;
		else if (sel == null)
			return;
		shadow.show(sel);
		sel.scrollIntoView(false);
//		self.setValue(sel.innerText);
		self.value = sel.innerText;
		if (typeof self.oEdit == "object")
			self.oEdit.firstChild.value = sel.innerText;
	};
};

$.jcom.DynaEditor.TreeList = function(tree, width, height)	//��:���Ϳ�
{//��̬���ͱ༭��,�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Base.call(this, width, height);
	self.type = 3;
	
	function ClickTree(obj)
	{
		tree.select(obj);
		var item = tree.getTreeItem();
		var node = tree.getSelItemKeyValue();
		if (node != undefined)
			$(self.oEdit.firstChild).attr("node", node);
		self.confirm(item.item);
	}
	
	this.createPop = function ()	//����:�������͵����б�
	{
		var tag = "<div style='overflow-x:hidden;overflow-y:auto;border:1px solid gray;width:" + (self.width - 2) + "px;height:" + (self.height - 2) + "px;'></div>";
		self.oBox.setPopObj(tag);
		var domObj = self.oBox.getdomobj();
		tree.setdomobj(domObj.firstChild);
	};
	
	this.TreeObj = function (o)		//����:���û��ȡ������ͼ����
	{
		if (o == undefined)
			return tree;
		if (typeof o == "object")
			tree = o;			
	};
	
	if (tree == undefined)
		return;
	tree.click = ClickTree;
}

$.jcom.DynaEditor.GridList = function (grid, width, height)	//��:����
{//��̬���༭��,�����ࣺ$.jcom.DynaEditor.Base
	var self = this;
	$.jcom.DynaEditor.Base.call(this, width, height);
	self.type = 4;

	function ClickGrid(obj)
	{
		grid.select(obj);
		var item = grid.getItemKeyValue(0, 1);
		self.confirm(item);
	}
	
	this.createPop = function ()	//����:����Grid�����б�
	{
		var tag = "<div style='overflow-x:hidden;overflow-y:auto;border:1px solid gray;width:" + (self.width - 2) + "px;height:" + (self.height - 2) + "px;'></div>";
		self.oBox.setPopObj(tag);
		var domObj = self.oBox.getdomobj();
		grid.setDomObj(domObj.firstChild);
	};
	if (grid == undefined)
		return;
	grid.click = ClickGrid;
}

$.jcom.DynaEditor.Edit = function()	//��:�����
{//��̬�����,ͨ���ı�contentEditable����ֱ��ʵ�ֱ༭,�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	var oldvalue;
	$.jcom.DynaEditor.Base.call(this);
	this.config({bAutoPop:false, editorMode:4, bHint:true});
}


$.jcom.DynaEditor.Input = function(width, height)	//��:�����
{//��̬�����,Ҳ��ѡ���,�ı���ȶ���Ļ���,�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Base.call(this, width, height);
	self.type = 5;
	self.config({bAutoPop:false, editorMode:2});
		
	this.createTag = function ()	//����:�����༭��
	{
		return "<input type=text style='width:100%;height:100%;border:none;'>";
	};
	
	this.initValue = function (value)	//����:��ʼ���༭�������
	{
		$(self.oEdit.firstChild).off("change", self.onChange);
		self.oEdit.firstChild.value = value;
		$(self.oEdit.firstChild).on("change", self.onChange);
	}
};

$.jcom.DynaEditor.Text = function(width, height)	//��:�ı���
{//��̬�ı���,�̳���$.jcom.DynaEditor.Input,�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Input.call(this, width, height);
	self.type = 6;
	this.createTag = function()	//����:�����ı���
	{
		self.bLastValue = false;
		return "<textarea style='width:100%;height:100%;border:none;'></textarea>";
	};
};

$.jcom.DynaEditor.Select = function(data, width, height)	//��:ѡ���
{//��̬ѡ���,�̳���$.jcom.DynaEditor.Input,�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Input.call(this, width, height);
	self.type = 7;
	this.createTag = function()	//����:����ѡ���
	{
		return "<select style='width:100%;height:100%;padding:1px'>" + self.createOptionTag() + "</select>";
	};

	this.createOptionTag = function ()	//����:����ѡ��
	{
		var tag = "";
		if (typeof data == "string")
		{
			var ss = data.split(",");
			for (var x = 0; x < ss.length; x++)
			{
				var sss = ss[x].split(":");
				var value = sss[0];
				var text = sss[0];
				if (sss.length > 1)
					text = sss[1];
				tag += "<option value=" + value + ">" + text + "</option>";
			}
		}
		return tag;
	};
	
	this.initValue = function (value)	//����:��ʼ���༭������
	{
		var sel = $(self.oEdit).find("select");	
		sel.off("change", self.onChange);
		var options = sel[0].options;
		for (var x = 0; x < options.length; x++)
		{
			if ((options[x].value == value) || (options[x].text == value) || (options[x].value + ":" + options[x].text == value))
			{
				options[x].selected = true;
				break;
			}
		}
		if (x == options.length)
			self.oEdit.firstChild.value = value;
		$(self.oEdit.firstChild).on("change", self.onChange);
	};
};

$.jcom.DynaEditor.Combo = function(data, width, height)	//��:��Ͽ�
{//��̬��Ͽ�,�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Base.call(this, width, height);
	self.type = 8;
	function selchange()
	{
		var domObj = self.oBox.getdomobj();
		var sel = $(domObj).find("select");
		var options = sel[0].options;
		var value = "", ex = "";
		for (var x = 0; x < options.length; x++)
		{
			if (options[x].selected)
			{
				if (value != "")
				{
					value += ",";
					ex += ",";
				}
				value += options[x].value;
				ex += options[x].text;
			}
		}	
		self.setValue(value, ex);
	}

	this.createOptionTag = function ()	//����:������Ͽ�
	{
		var tag = "";
		if (typeof data == "string")
		{
			var ss = data.split(",");
			for (var x = 0; x < ss.length; x++)
			{
				var sss = ss[x].split(":");
				var value = sss[0];
				var text = sss[0];
				if (sss.length > 1)
					text = sss[1];
				tag += "<option value=" + value + ">" + text + "</option>";
			}
		}
		return tag;
	};
	
	this.createPop = function ()	//����:����������
	{
		var tag = "<div style='border:1px solid gray;overflow:auto;width:" + self.width  + "px;height:" + self.height + "px;'></div>";
		self.oBox.setPopObj(tag);
		var domObj = self.oBox.getdomobj();
		domObj.innerHTML = "<select multiple=true style='width:" + self.width + "px;height:" + self.height +"px;padding:1px'>" + self.createOptionTag() + "</select>";
		var sel = $(domObj).find("select");
		sel.on("change", selchange);
	};
	
	this.onpop = function ()	//����:���������¼�
	{
		var domObj = self.oBox.getdomobj();
		var sel = $(domObj).find("select");
		var options = sel[0].options;
		var ss = self.value.split(",");
		for (var x = 0; x < options.length; x++)
		{
			options[x].selected = false;
			for (var y = 0; y < ss.length; y++)
			{
				if ((options[x].value == ss[y]) || (options[x].text == ss[y]) || (options[x].value + ":" + options[x].text == ss[y]))
				{
					options[x].selected = true;
					break;
				}
			}
		}
	};
};

$.jcom.DynaEditor.Spin = function (minvalue, maxvalue, stepvalue)	//��:������
{//��̬������,�̳���$.jcom.DynaEditor.Input�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	var t = new Date();
	$.jcom.DynaEditor.Input.call(this, 0, 0);
	self.type = 9;
	var _create = this.create;
	this.create = function()	//����:����������
	{
		_create();
		$(this.oEdit.lastChild).on("scroll", run);
		this.oEdit.lastChild.scrollTop = 500;
	};

	function run(event)
	{
		var t1 = new Date();
		if (t1.getTime() - t.getTime() < 180)
			return;
		t = t1;
		if (self.oEdit.lastChild.scrollTop == 500)
			return;
		if (self.oEdit.lastChild.scrollTop > 500)
			self.setValue(self.cal(self.oEdit.firstChild.value, 1));
		else
			self.setValue(self.cal(self.oEdit.firstChild.value, -1));
		self.onChange();
		self.oEdit.lastChild.scrollTop = 500;
	}
	
	this.cal = function(value, step)	//����:��������
	{
		var result = parseInt(value) + stepvalue * step;
		if (result > maxvalue)
			result = maxvalue;
		if (result < minvalue)
			result = minvalue;
		 return result;
	}

	this.createTag = function()	//����:����������HTML����
	{
		return "<input type=text style='width:100%;height:18px;position:absolute;border:none;border-right:20px solid transparent;top:1px;left:1px;'>" +
			"<div UNSELECTABLE=on style='position:absolute;overflow-y:scroll;overflow-x:hidden;width:100%;height:20px;border:1px solid gray;'>" +
			"<div UNSELECTABLE=on style=height:1000px;></div></div>";
	};

};

$.jcom.DynaEditor.Search = function(hisfun, runfun)	//��:������
{//��̬����ʾ��������,���Զ���ɱ༭��,�̳���$.jcom.DynaEditor.List�����ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.List.call(this);
	self.type = 10;
	var mode = 1;
	if (typeof runfun == "function")
		this.setPopImg("<img UNSELECTABLE=on src=../com/pic/search.png style=margin-left:-16px>");
	else
		mode = 2;
		self.config({bAutoPop:false, editorMode:mode});
	
	this.onCharChange = function(value)	//�¼�:�ַ��ı��¼���������������
	{
//		self.value = value;
		if (typeof hisfun != "function")
			return;
		var data = hisfun(value);
		if ((typeof data == "string") && (data != ""))
		{
			self.setData(data);
			self.popDown();
		}
		else
			self.hidePop();
	};

	this.confirm = function(value)	//����:ȷ������
	{
		self.setValue(value);
		self.onChange();
		self.hide();
		self.runButton();
	};
	
	this.OverButton = function() 	//�¼�:��껬���¼�
	{};
	this.OutButton = function()	//�¼�:����뿪�¼�
	{};
	
	this.runButton = function ()	//����:��ť���²���
	{
		if (typeof runfun == "function")
			runfun(self.oEdit.firstChild.value);
	};
};

$.jcom.DynaEditor.FontSel = function()	//��:����ѡ���
{//������δʵ�֣���̬������ɫѡ��Ի��򣬻��ࣺ$.jcom.DynaEditor.Base

	var self = this;
	$.jcom.DynaEditor.Base.call(this);

};

$.jcom.DynaEditor.FileUpload = function(saveurl)	//��:�ļ��ϴ���
{//������δʵ�� ����̬�ļ��ϴ��򣬻��ࣺ$.jcom.DynaEditor.Base

	var self = this;
//	$.jcom.DynaEditor.Input.call(this, data);

};

$.jcom.FileUpload = function(ocxdisabled)	//��:�ļ��ϴ�
{
var self = this;
var ocx;
var root = $.jcom.GetRootPath();
var upurl = root + "/com/upfile.jsp";
var downurl = root +"/com/down.jsp";
var upcnt = 0, downcnt = 0;
var errorMsg=["0:�ɹ�", "-1:����������","-2:�����ļ������ϴ���������","-3:�ϴ���ַ����","-4:���ܴ򿪱����ļ�","-5:���ܽ�������"];
$.jcom.FileUpload.instance = this;
	function Init()
	{
		if (typeof ocx == "object")
			return true;
		ocx = document.getElementById("htexOCX");
		if (ocx != null)
			return;
		if (document.getElementById("htexOCX") != "object")
			document.body.insertAdjacentHTML("beforeEnd", "<object classid=clsid:805E221F-1C22-424B-BDCD-9CE834919407 codebase=" +
				root + "/htex.ocx id=htexOCX width=1 height=1></object>");
		ocx = document.getElementById("htexOCX");
		ocx.onerror = function ()
		{
			ocx.onerror = null;
			$(ocx).remove();
			ocx = undefined;
			if (confirm("��Ҫ��ʾ��δ�ܼ��ذ�װ�ļ��ϴ��ؼ���\n" +
				"�����뽫��վ��" + location.hostname + "���뵽����վ�㣬���ڰ�ȫ���������ã�\n" +
				"����δǩ����ActiveX�ؼ���δ���Ϊ�ɰ�ȫִ�нű���ActiveX�ؼ���ʼ����ִ�нű���������ҳ����ֵ�ActiveX�ؼ��İ�װѡ��ſ�ʹ���ļ��ϴ��ؼ���\n�Ƿ�Ҫ���°�װ?"))
				Init();
			return false;
		}
//		ocx.attachEvent("htexEvent", htexEvent);
		ocx.attachEvent("DownFileEvent", self.DownFileEvent);
		ocx.attachEvent("PostFileEvent", self.PostFileEvent);		
	}

	this.PostFileEvent = function(id, param1, param2)	//�¼�:�ϴ��¼�
	{
		var evtName, info;
		switch (id)
		{
		case 1:
			evtName = "SendFileBegin";
			info = ocx.HTTPPostGetValue(param1, 2);
			if (parseInt(info) == 0)
				info = ocx.HTTPPostGetValue(param1, 1);
			else
				evtName = "SendFileProgress";
			break;
		case 2:
			evtName = "SendFileProgress";
			info = ocx.HTTPPostGetValue(param1, 2);
			break;
		case 3:
			evtName = "SendFileOK";
			info = ocx.HTTPPostGetValue(param1, 4);
			var ss = info.split(":");
			var ID = parseInt(ss[1]);
			if (ID <= 0)
				evtName = "SendFileCancel";
			upcnt --;
			break;
		case 4:
			evtName = "SendFileFail";
			info = ocx.HTTPPostGetValue(param1, 5);
			upcnt --;
			break;
		default:
			alert("ERROR" + id);
			return;
		}
		self.progress(evtName, param1, info);
	};

	this.DownFileEvent = function(id, param1, param2)	//�¼�:�����¼�
	{
		var evtName, info;
		switch (id)
		{
		case 1:
			evtName = "DownFileBegin";
			info = ocx.HTTPDownGetValue(param1, 4);	//local filename
			break;
		case 2:
			evtName = "DownFileProgress";
			info = ocx.HTTPDownGetValue(param1, 2);	//offset
			break;
		case 3:
			evtName = "DownFileOK";
			info = ocx.HTTPDownGetValue(param1, 4);	//Post status
			downcnt --;
			break;
		case 4:
			evtName = "DownFileFail";
			info = ocx.HTTPDownGetValue(param1, 5);
			downcnt --;
			break;
		default:
			alert("ERROR" + id);
			return;
		}
		self.downprogress(evtName, param1, info);
	};

	function htexEvent(evtName, param1, param2)
	{
		switch (evtName)
		{
		case "SendFileBegin":
		case "SendFileProgress":
			break;
		case "SendFileOK":
		case "SendFileFail":
			upcnt --;
			break;
		}
		self.progress(evtName, param1, param2);
	}
	
	this.upload = function(filename, folder, id)	//����:�ϴ��ļ�������
	{
		if (typeof this.getocx() != "object")
			return -1;
		var posturl = upurl + "?saveto=" + folder;
		if (typeof id != "undefined")
			posturl += "&affixid=" + id;
		var id = ocx.HTTPPostFile(filename, posturl, document.cookie, 1);
		if (id >= 0)
			upcnt ++;
		return id;
	};

	this.upfile = function(filename, option)	//����:�ϴ��ļ�
	{
		if (typeof this.getocx() != "object")
			return "����δ���ϴ����ϴ����δ����������";
		if (typeof option != "object")
			return "����δ���ϴ����������岻��ȷ";
		var posturl = upurl, sp = "?";
		for (var key in option)
		{	//��ѡ����,affixid, DestDir, ParentID, SecretType, saveto
			posturl += sp + key + "=" + option[key];
			sp = "&";
		}
		var id = ocx.HTTPPostFile(filename, posturl, document.cookie, 1);
		if (id >= 0)
			upcnt ++;
		return id;		
	}
	
	this.stop = function(id)	//����:ֹͣ�ϴ�
	{
		ocx.HTTPPostStop(id);
		if (upcnt > 0)
			upcnt --;
	};
	
	this.stopdown = function(id)	//����:ֹͣ����
	{
		ocx.HTTPDownStop(id);
		if (downcnt > 0)
			downcnt --;
	};

	this.getocx = function()	//����:����OCX����
	{
		if (typeof ocx != "object")
		{
			Init();
			return;
		}
		return ocx;
	};

	this.gettask = function(ntype)	//����:�õ��ϴ������ص��ļ���������
	{
		switch (ntype)
		{
		case 1:
			return upcnt;
		case 2:
			return downcnt;
		default:
			return upcnt + downcnt;
		}
	};
	
	this.openfile = function(fun, option)	//����:�򿪱����ļ�
	{
		var o = document.createElement("<input type=file>");
		document.body.insertAdjacentElement("beforeEnd", o);
		o.style.display = "none";
		o.onchange = function ()
		{
			if (o.value != "")
			{
				if (typeof fun == "function")
					fun(o.value);
				else
				{
//					this.upload(o.value, "��ʱ�����ļ���");
					this.upfile(o.value, option);
				}
			}
			o.onchange = null;
			$(o).remove();
		}
		o.click();
	};
	

	this.downfile = function(localfile, param, saveflag)	//����:�����ļ�������
	{
		if (saveflag == undefined)
			saveflag = 0;//����ͬ���ļ������
		var url = downurl + "?" + param;
		if (param.substr(0, 4) == "http")
			url = param;
		id = ocx.HTTPDownFile(url, localfile, document.cookie, saveflag);
		downcnt ++;
		return id;
	};
	
	this.setURL = function(up, down)	//����:�ı��ϴ������صķ�����·��
	{
		if (typeof up == "string")
			upurl = up;
		if (typeof down == "string")
			downurl = down;
	};
	
	this.getError = function(id)	//����:��ȡ������Ϣ
	{
		if (id >= 0)
			return id;
		var no = 0 - id;
		if (no > errMsg.length - 1)
			return id;
		return errorMsg[no];
	}
	
	this.progress = function (evt, param1, param2)	//�¼�:�ϴ��¼�
	{};
	this.downprogress = function (evt, param1, param2)	//����:�����¼�
	{};
	
	if (typeof __JCOM__HelpFile != "undefined")	return;		//�ж�helpʱ���ص�ʵ��
	if (ocxdisabled != 1)
	{
		Init();
	}
};

$.jcom.DragDrop = function()	//��:�Ϸ�
{//���ౣ����δ��ʵ��Ӧ��
var self = this;
var srcObj, bDragChanged;
var targets = new Array();
	function DragStart(obj)
	{
		if (event.button == 2)
			return;
	
//		obj.click();
		var oDiv = document.createElement("div");
		oDiv.innerHTML = obj.outerHTML;
		oDiv.style.display = "block";
		oDiv.style.position = "absolute";
		oDiv.style.filter = "alpha(opacity=70)";
		document.body.appendChild(oDiv);
		oDiv.style.top = $.jcom.getObjPos(obj).top;
		oDiv.style.left = $.jcom.getObjPos(obj).left;
		BeginDragObj(oDiv);
		document.onmousemove = Draging;
		document.onmouseup = EndDrag;
		bDragChanged = 0;
		srcObj = obj;
	}

	function Draging()
	{
	var x, pos, tx, ty;
		DragingObj();
		tx = event.clientX;
		ty = event.clientY;
		for (x = 0; x < targets.length; x++)
		{
			if (targets[x] != srcObj)
			{
				pos = $.jcom.getObjPos(targets[x]);
				if(tx >= pos.left && tx <= pos.right && ty >= pos.top && ty <= pos.bottom)
				{
					if (self.dragtest(targets[x]))
					{
						targets[x].insertAdjacentElement("afterEnd", srcObj);
						bDragChanged = 1;
					}
				}
			}
		}
	}

	function EndDrag()
	{
		ResetObjPos(dragObj, 15);
		EndDragObj();
	}

	function ResetObjPos(obj, delta)
	{
		var pos = $.jcom.getObjPos(dragObj);
		var tx = obj.style.pixelLeft;
		var ty = obj.style.pixelTop;
		var dx = (tx - pos.left) / delta;
		var dy = (ty - pos.top) / delta;
		var oInterval = window.setInterval(function()
		{
			if (delta > 1)
			{
				delta --;
				tx -= dx;
				ty -= dy;
				if (tx < 0)
					tx = 0;
				if (ty < 0)
					ty < 0;
				obj.style.left = tx + "px";
				obj.style.top = ty + "px";
			}
			else
			{
				clearInterval(oInterval);
				$(obj).remove();
//				if (bDragChanged == 1)
//					UserDragFun(2, SeekDragSrcObj, oldParent);
				return;
			}
		}, 20);
	}

	this.attachSrc = function(hitobj, dragobj)	//����:�󶨵�����
	{
		if (typeof dragobj == "undefined")
			dragobj = hitobj;
		hitobj.onmousedown = function () 
		{
			DragStart(dragobj);
		};
	};
	
	this.detachSrc = function(hitobj)	//����:�Ӱ󶨶�����
	{
		hitobj.onmousedown = null;
	};
	
	this.attachTarget = function (obj)	//����:
	{
		targets[targets.length] = obj;
	};
	
	this.detachTarget = function (obj)	//����:
	{
		
	};
	
	this.ondrag = function()	//�¼�:
	{
	};
	
	this.ondraging = function ()	//�¼�:
	{
	};
	
	this.ondragend = function ()	//�¼�:
	{
	};
	
	this.dragtest = function(obj)	//�¼�:
	{
		return true;
	}
};

$.jcom.OfficeInput = function(domobj)	//��:OFFICE�༭��
{
	var hidobj, conobj,readonly, rows,username, editmode;
	var App, oUpload;
	var doclist = [];
	var watch;
	var root = $.jcom.GetRootPath();

	function InitDoc()
	{
		hidobj = domobj.previousSibling;
		conobj = domobj.parentNode;
		readonly = parseInt(hidobj.bReadonly);
		rows = hidobj.rows;
		username = hidobj.user;
		editmode = hidobj.editmode;

		var ss = hidobj.value.split(",");
		for (var x = 0; x < ss.length; x++)
		{
			doclist[x] = {};
			if (ss[x] == "")
				var sss = ["0", ""];
			else
				var sss = ss[x].split(":");
			
			doclist[x].id= parseInt(sss[0]);
			if (sss.length > 1)
				doclist[x].name = sss[1];
			else
				doclist[x].name = "";
			if (x == 0)
				InitDocbar(domobj, x);
			else
				InitDocbar(0, x);
		}
	}

	function OfficeUploadEvent(evt, param1, param2)
	{
		switch (evt)
		{
		case "SendFileBegin":
			break;
		case "SendFileProgress":
			break;
		case "SendFileOK":
			var ss = param2.split(":");
			var uploadid = parseInt(param1);
			if (ss[0] == "OK")
			{
				for (var x = 0; x < doclist.length; x++)
				{
					if (doclist[x].uploadid == uploadid)
					{
						doclist[x].id = parseInt(ss[1]);
						doclist[x].uploadid = -1;
						doclist[x].fullname = undefined;
						UploadOKEvent();
						break;
					}
				}
			}
			else
				alert(param2);
			break;
		case "SendFileFail":
			oUpload.stop(param1);
			alert("����", "�ϴ�OFFICE�ļ�ʧ�ܣ�" + param2);
			break;
		}
	}
	
	function UploadOKEvent() {}
	
	function InitDocbar(obj, index)
	{
		var result = "";
		if (typeof obj != "object")
		{
			obj = document.createElement("SPAN");
			obj.className = "OfficeInput";
			conobj.insertAdjacentHTML("beforeEnd", "<br>");
			conobj.insertAdjacentElement("beforeEnd", obj);
		}
		if (readonly == 0)
		{
			var o = CreateDocButton(obj, "�½�", NewDoc);
			o = CreateDocButton(o, "�ϴ�", UploadDoc);
			o = CreateDocButton(o, "�Ķ�", ReadDoc);
			o = CreateDocButton(o, "�༭", EditDoc);
			o = CreateDocButton(o, "����", "", root + "/com/down.jsp?AffixID=" + doclist[index].id);
			o = CreateDocButton(o, "ɾ��", DeleteDoc);
			oUpload = new $.jcom.FileUpload();
			oUpload.progress = OfficeUploadEvent;
		}
		else
		{
			if (doclist[index].id != 0)
			{
				var o = CreateDocButton(obj, "�Ķ�", ReadDoc);
				o = CreateDocButton(o, "����", "", root + "/com/down.jsp?AffixID=" + doclist[index].id);
			}
		}
		obj.innerText = doclist[index].name;
	}

	function CreateDocButton(obj, name, click, href)
	{
		var o = document.createElement("A");
		o.innerText = name;
		if (click == "")
			o.href = href;
		else
		{
			o.onclick = click;
			o.href = "javascript:void(0)";
		}
		o.style.marginLeft = "5px";
		obj.insertAdjacentElement("afterEnd", o);
		return o;
	}

	function getDocIndex(obj)
	{
		var objs = conobj.getElementsByTagName("A");
		var index = -1;
		for (var x = 0; x < objs.length; x++)
		{
			if (objs[x].innerText == obj.innerText)
				index ++;
			if (objs[x] == obj)
				break;
		}
		return index;
	}
	
	function SetSyn()
	{
		if (typeof watch == "undefined")
			watch = window.setInterval(SyncStatus, 500);
		SyncStatus();
	}
		
	function SyncStatus()
	{
		var objs = conobj.getElementsByTagName("SPAN");
		var cnt = 0;
		for (var x = 0; x < doclist.length; x++)
		{
			if (typeof doclist[x].doc == "object")
			{
				try
				{
					objs[x].innerHTML = doclist[x].doc.name + "<q style=color:gray>(�༭��...)</q>";
					doclist[x].name = doclist[x].doc.name;
					doclist[x].fullname = doclist[x].doc.FullName;
				}
				catch (e)
				{
					if (doclist[x].fullname == doclist[x].name)
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(OFFICE����" + e.description + ")</q>";
					else
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(�ѱ���)</q>";
				}
				cnt ++;
			}
			else
				objs[x].innerHTML = doclist[x].name;
		}
		if (cnt == 0)
		{
			clearInterval(watch);
			watch = undefined;
		}
	}
	
	function CreateApp()
	{
		if (typeof App != "object")
		{
			try
			{
				App = new ActiveXObject("Word.Application");
				App.visible=true;
				App.UserName = username;
			} catch (e)
			{
				alert("δ�ܴ򿪱��ص�OFFICE����");
				return false;
			}
		}
		else
		{
			try
			{
				App.visible = true;
			}
			catch (e)
			{
				App = new ActiveXObject("Word.Application");
				App.visible=true;
				for (var x = 0; x < doclist.length; x++)
					doclist[x].doc = undefined;
			}
		}
	}
	
	function NewDoc()
	{
		if (CreateApp() == false)
			return;
		var doc = App.Documents.Add();
		App.Activate();
		doc.ActiveWindow.Activate();
		var index = doclist.length;
		if (doclist[index - 1].name == "")
		{
			doclist[index - 1].name = doc.FullName;
			doclist[index - 1].doc = doc;
			domobj.innerText = doc.FullName;
		}
		else
		{
			doclist[index] = {};
			doclist[index].id = 0;
			doclist[index].name = doc.FullName;
			doclist[index].status = "";
			doclist[index].doc = doc;
			InitDocbar(0, index);
		}
		SetSyn();
	}
	
	function EditDoc()
	{
		var index = getDocIndex(event.srcElement);
		if (typeof doclist[index].doc == "object")
		{
			CreateApp();
			try
			{
				doclist[index].doc.ActiveWindow.Activate();
				App.Activate();
			}
			catch (e)
			{
				alert("�ĵ��ѹرջ򲻿��á�");
//				event.srcElement.nextSibling.nextSibling.click();
			}
			return;
		}
		if (doclist[index].id == 0)
			return;

		if (CreateApp() == false)
			return;
		var doc = App.Documents.Open(root + "/com/down.jsp?AffixID=" + doclist[index].id);
		doc.SaveAs(App.Options.DefaultFilePath(0) + "\\" + doclist[index].name);
		doc.TrackRevisions = true;
		doclist[index].doc = doc;
		doclist[index].fullname = doc.FullName;
		App.Activate();
		doc.ActiveWindow.Activate();
		SetSyn();
//		alert(doc.Saved);
	}
	
	function ReadDoc()
	{
		var index = getDocIndex(event.srcElement);
		if (doclist[index].id == 0)
			return;
		if (CreateApp() == false)
			return;
		var href = root + "/com/down.jsp?AffixID=" + doclist[index].id;
		var doc = App.Documents.Open(href);
		doc.ActiveWindow.Caption = doclist[index].name;
		App.Activate();
		doc.ActiveWindow.Activate();
	}
	
	function DownDoc()
	{
		var index = getDocIndex(event.srcElement);
		if (doclist[index].id == 0)
			return alert("δ�ϴ���");
		location.href =	root + "/com/down.jsp?AffixID=" + doclist[index].id;
	}
	
	function DeleteDoc()
	{
		var obj = event.srcElement;
		var index = getDocIndex(obj);
		if (doclist[index].id != 0)
		{
			if (window.confirm("�Ƿ�ɾ�����ϴ����ļ�") == false)
				return;
			AjaxRequestPage("../com/upload.jsp?option=DeleteFile&fileName0=" + doclist[index].id, true, "",
				function (data){alert(data);});
		}
		if (index > 0)
		{
			for (var x = 0; x < 7; x++)
				$(obj.previousSibling).remove();	//obj.previousSibling.removeNode(true);
			$(obj).remove();
			doclist.splice(index, 1);
		}
		else
		{
			doclist[0].id = 0;
			doclist[0].name = "";
			doclist[0].doc = undefined;
			domobj.innerText = "";
		}
	}
	
	this.SaveDoc = function (funok)		//����:�ϴ�OFFICE�ļ����˷����ڱ��ύǰ�ɱ��ύ������ã�����Ϊ��ʽ���ύ����
	{
		if (typeof funok == "function")
			UploadOKEvent = funok;
		for (var x = 0; x < doclist.length; x++)
		{
			if (typeof doclist[x].fullname == "string")
			{
				if (typeof doclist[x].doc == "object")
				{
					try
					{
						doclist[x].doc.Save();
						SyncStatus();
						doclist[x].doc.Close();
					}
					catch (e)
					{
					}
					doclist[x].doc = undefined;
				}
				if (doclist[x].fullname == doclist[x].name)
					alert("�����ϴ��ļ���[" + doclist[x].name + "]�ļ��Ѷ�ʧ��");
				else
				{
					if ((typeof doclist[x].uploadid == "undefined") || (doclist[x].uploadid < 0))
					{
//						doclist[x].uploadid = oUpload.upload(doclist[x].fullname, "��ʱ�����ļ���", doclist[x].id);
						doclist[x].uploadid = oUpload.upfile(doclist[index].fullname, {DestDir:"Form", saveto: "��Office�ĵ�", affixid:doclist[index].id});
						if (doclist[x].uploadid < 0)
							alert("�ϴ�OFFICE�ļ�ʧ��:" + doclist[x].uploadid);
					}
				}
//				if (savefile(x) != "OK")
					return false;
				SyncStatus();
			} 
		}
		var value = "";
		for (var x = 0; x < doclist.length; x++)
		{
			if (doclist[x].id != 0)
			{
				if (value != "")
					value += ",";
				value += doclist[x].id + ":" + doclist[x].name;
			}
		}
		hidobj.value = value;
		return true;	
	}
	
	function UploadDoc()
	{
		UploadDoc.SubmitLocalFileOK = SubmitLocalFileOK;
		SubmitLocalFileOK = UploadOK;
		StartSubmitLocalFile("��ʱ�����ļ���");
	}
	
	function UploadOK(FileType, AffixID, FileCName)
	{
		UploadOK.obj = undefined;

		var index = doclist.length;
		if (doclist[index - 1].name == "")
		{
			doclist[index - 1].name = FileCName;
			doclist[index - 1].id = AffixID;
			domobj.innerText = FileCName;
		}
		else
		{
			doclist[index] = {};
			doclist[index].id = AffixID;
			doclist[index].name = FileCName;
			InitDocbar(0, index);
		}
		SubmitLocalFileOK = UploadDoc.SubmitLocalFileOK;
	}
	if (domobj == undefined)
		return;
	InitDoc();
};

$.jcom.ConSignEditor = function(domobj)	//��:��ǩ��
{
	var hidobj, username,readonly, bRequired, oldvalue, editobj;
	function onchange()
	{
		if (readonly == 2)
			hidobj.value = username + ":" + editobj.value.replace(/:/g, "��").replace(/;/g, "��") + ";";
		else
			hidobj.value = oldvalue + username + ":" + editobj.value.replace(/:/g, "��").replace(/;/g, "��") + ";";
	}

	function Init()
	{
		hidobj = domobj.previousSibling;
		username = hidobj.UserName;
		readonly = parseInt(hidobj.bReadonly);
		bRequired = parseInt(hidobj.bRequired);
		oldvalue = hidobj.value;

		var EName = hidobj.name;
		var CName = hidobj.CName.split(",");
		var rows = parseInt(hidobj.rows);
		var lineheight = parseInt(hidobj.lineHeight);
		if ((readonly == 1) && (hidobj.value == ""))
			return "";
		var tag = "<input type=hidden name=" + EName + "_Pattern value='" + username + ":.*;'><div";
		var ss = hidobj.value.split(";");
		if ((rows > 1) && (ss.length > rows))
			tag += " style=width:100%;height:" + (rows * 24) + "px;overflow-y:auto";
		tag += "><table style=width:100%;>";
		var value = oldvalue;
		if ((value.indexOf(username + ":") < 0) && (readonly != 1))
		{
			if (value != "")
				value += ";";
			value += username + ":;";
		}
		var ss = value.split(";");
		for (var x = 0; x < ss.length; x++)
		{
			var sss = ss[x].split(":");
			if (sss.length < 2)
				continue;
			if (($.trim(sss[1]) == "") && ((readonly == 1) || (sss[0] != username)))
				continue;
			tag += "<tr><td width=5% nowrap class=jformconreadonly1>" + CName[0] + "</td><td width=20%><input name=" +
				EName + "_F1 readonly class=textreadonly value='" + sss[0] + "' style=width:100%;></td>";
			if ((sss[0] == username) && (readonly != 1))
			{
				tag += "<td width=5% nowrap class=jformcon1>" + CName[1] + "</td><td width=70%>";
				var sreq = "";
				if (bRequired == 1)
					sreq = " bRequired=1";
				if (lineheight == 1)
					tag += "<input id=ConsignInput name=" + EName + "_F2" + sreq + " class=text style=width:100%; value='" + sss[1] + "'>";
				else
					tag += "<textarea id=ConsignInput name=" + EName + "_F2" + sreq + " class=text rows=" + lineheight + " style=width:100%;>" + sss[1] + "</textarea>";				
			}
			else
			{
				tag += "<td width=5% nowrap class=jformconreadonly1>" + CName[1] + "</td><td width=70%>";
				if (lineheight == 1)
					tag += "<input readonly name=" + EName + "_F2 class=textreadonly style=width:100%; value=" + sss[1] + ">";
				else
					tag += "<div id=TextReadOnlyViewDiv rows=" + lineheight + " style=width:100%;height:" + rows * 20 + "px;>" + sss[1].replace(/\n/g, "<br>") + "</div>";
			}
			tag += "</td></tr>";
		}
		domobj.insertAdjacentHTML("beforeEnd", tag + "</table></div>");
		editobj = domobj.all.ConsignInput;
		switch (readonly)
		{
		case 0:			//edit
			hidobj.value = value;
		case 1:			//readonly
			break;
		case 2:			//append
			hidobj.value = username + ":;";
			break;
		}
			
		if (typeof editobj == "object")
		{
			editobj.onchange = onchange;
			editobj.scrollIntoView();
		}
	}
	if (domobj == undefined)
		return;
	Init();
};

$.jcom.SizeBox = function(mode, bgcolor, maskcolor, opacity)	//��:�ߴ��
{
	var self = this;
	var domobj, mask, nAction, px, py;
	var eleft = -2048, etop = -2048, eright = 2048, ebottom = 2048;
	var minwidth = 8, minheight = 8; maxwidth = 4096, maxheight = 4096;
	var old = {left:0, top:0, width:100, height:100, status:0};
	function init()
	{
		if (typeof bgcolor == "undefined")
			bgcolor = "blue"; 
		mask= document.createElement("DIV");
		$(document.body).append(mask);
		$(mask).css({display: "none", position: "absolute", zIndex: 98, padding: "4px", overflow: "hidden"});

		$(mask).on("mousedown", MouseBegin);
		$(mask).on("mousemove", MouseEdge);
		$(mask).on("dblclick", self.dblclick);
		if (mode == 0)		//û�����ŵ�ָʾ��
			return;
		var tag = "<div style=position:absolute;overflow:hidden;width:4px;height:5px;background-color:" + bgcolor + "></div>";
		mask.innerHTML = "<div style='width:100%;height:100%;overflow:hidden;'></div>" +
			tag + tag + tag + tag + tag + tag + tag + tag;
		if (typeof maskcolor == "string")		//��͸�����Ը�ס�����Ի���¼�
		{
			mask.firstChild.style.backgroundColor = maskcolor;
			mask.firstChild.style.filter = "alpha(opacity=" + opacity + ")";
		}	
		mask.children[1].style.cursor = "NW-resize";
		mask.children[2].style.cursor = "N-resize";
		mask.children[3].style.cursor = "NE-resize";
		mask.children[4].style.cursor = "W-resize";
		mask.children[5].style.cursor = "E-resize";
		mask.children[6].style.cursor = "SW-resize";
		mask.children[7].style.cursor = "S-resize";
		mask.children[8].style.cursor = "SE-resize";
	}
	
	function MouseBegin(event)
	{
		for (var x = 0; x < mask.children.length; x++)
		{
			if (event.srcElement == mask.children[x])
				break;
		}
		if (x < mask.children.length)
			nAction = x;
		self.start(event, nAction);
	}


	function MouseEdge(event)
	{
		if (mode == 0)
			return;
		var pos = $.jcom.getObjPos(mask);
		if (event.clientX < pos.left + 4)
		{
			mask.style.cursor = "W-resize";
			nAction = 4;
			return;
		}
		if (event.clientX > pos.right - 4)
		{
			mask.style.cursor = "E-resize";
			nAction = 5;
			return;
		}
		if (event.clientY < pos.top + 4)
		{
			mask.style.cursor = "N-resize";
			nAction = 2;
			return;
		}
		if (event.clientY > pos.bottom - 4)
		{
			mask.style.cursor = "S-resize";
			nAction = 7;
			return;
		}
		mask.style.cursor = "default";
		nAction = 0;
	}

	function MouseAction(event)
	{
		Action(event, nAction);
		Apply();
	}

	function Apply()
	{
		if (old.status == 1)
		{
			domobj.style.left = mask.style.left;
			domobj.style.top = mask.style.top;
			domobj.style.width = mask.style.width;
			domobj.style.height = mask.style.height;
			resizedomobj();
			return;
		}
		domobj.style.left = parseInt(mask.style.left) + 2 + "px";
		domobj.style.top = parseInt(mask.style.top) + 2 + "px";
		domobj.style.width = parseInt(mask.style.width) - 4 + "px";
		domobj.style.height = parseInt(mask.style.height) - 4 + "px";
		resizedomobj();
		SetBox();
		self.ActionEvent(2, nAction);
	}
	
	function resizedomobj()
	{
		if (typeof $(domobj).attr("userfun") == "object")
			$(domobj).attr("userfun").resize();
	}

	function Action(event, act)
	{
		switch (act)
		{
		case 0:		//MOVE
			if (event.clientX + px < eleft)
				mask.style.left = eleft + "px";
			else if (event.clientX + px + parseInt(mask.style.width) > eright)
				mask.style.left = eright - parseInt(mask.style.width) + "px";
			else
				mask.style.left = event.clientX + px + "px";
			
			if (event.clientY + py < etop)
				mask.style.top = etop + "px";
			else if (event.clientY + py + mask.style.pixelHeight > ebottom)
				mask.style.top = ebottom - parseInt(mask.style.height) + "px";
			else
				mask.style.top = event.clientY + py + "px";
			break;
		case 1:		//SIZE:left top
			Action(event, 2);
			Action(event, 4);
			break;
		case 2:		//SIZE:top
			var b = parseInt(mask.style.top) + parseInt(mask.style.height);
			if (b - event.clientY < minheight)
			{
				mask.style.height = minheight + "px";
				mask.style.top = b - minheight + "px";
			}
			else if (b - event.clientY > maxheight)
			{
				mask.style.height = maxheight + "px";
				mask.style.top = b - maxheight + "px";
			}
			else
			{
				mask.style.top = event.clientY + "px";
				mask.style.height = b - parseInt(mask.style.top) + "px";
			}
			break;
		case 3:		//SIZE: right top
			Action(event, 2);
			Action(event, 5);
			break;
		case 4:		//SIZE: left
			var r = parseInt(mask.style.left) + parseInt(mask.style.width);
			if (r - event.clientX < minwidth)
			{
				mask.style.width = minwidth + "px";
				mask.style.left = r - minwidth + "px";
			}
			else if (r - event.clientX > maxwidth)
			{
				mask.style.width = maxwidth + "px";
				mask.style.left = r - maxwidth + "px";
				
			}
			else
			{
				mask.style.left = event.clientX + "px";
				mask.style.width = r - parseInt(mask.style.left) + "px";
			}
			break;
		case 5:		//SIZE:	right
			if (event.clientX - parseInt(mask.style.left) < minwidth)
				mask.style.width = minwidth + "px";
			else if (event.clientX - parseInt(mask.style.left) > maxwidth)
				mask.style.width = maxwidth + "px";
			else
				mask.style.width = event.clientX - parseInt(mask.style.left) + "px";
			break;
		case 6:		//SIZE:	left bottom
			Action(event, 4);
			Action(event, 7);
			break;
		case 7:		//SIZE:	bottom
			if (event.clientY - parseInt(mask.style.top) < minheight)
				mask.style.height = minheight + "px";
			else if (event.clientY - parseInt(mask.style.top) > maxheight)
				mask.style.height = maxheight + "px";
			else
				mask.style.height = event.clientY - parseInt(mask.style.top) + "px";
			break;
		case 8:		//SIZE: right bottom
			Action(event, 5);
			Action(event, 7);
			break;
		case 9:
			break;
		}
	}
	
	function MouseEnd()
	{
		$(document).off("mousemove", MouseAction);
		$(document).off("mouseup", MouseEnd);
		$(mask).on("mousemove", MouseEdge);
		self.ActionEvent(3, nAction);
	}

	function SetBox()
	{
		if (mode == 0)
			return;
		var pos = $.jcom.getObjPos(domobj);
		mask.children[1].style.top = "0px";		//left top
		mask.children[1].style.left = "0px";
		mask.children[2].style.top = "0px";		//top
		mask.children[2].style.left = parseInt((pos.right - pos.left) / 2) + "px";
		mask.children[3].style.top = "0px";		//right top
		mask.children[3].style.left = (pos.right - pos.left - 1) + "px";

		mask.children[4].style.top = parseInt((pos.bottom - pos.top) / 2) + "px";
		mask.children[4].style.left = "0px";		//left
		mask.children[5].style.top = parseInt((pos.bottom - pos.top) / 2) + "px";
		mask.children[5].style.left = (pos.right - pos.left - 1) + "px";	//right

		mask.children[6].style.top = (pos.bottom - pos.top - 1) + "px";
		mask.children[6].style.left = "0px";		//left bottom
		mask.children[7].style.top = (pos.bottom - pos.top - 1) + "px";		//bottom
		mask.children[7].style.left = parseInt((pos.right - pos.left) / 2) + "px";
		mask.children[8].style.top = (pos.bottom - pos.top - 1) + "px";		//right bottom
		mask.children[8].style.left = (pos.right - pos.left - 1) + "px";	
	};

	this.start = function(event, act)	//����:�������ţ�ֻ���˹���������ʱ����Ҫ���ô˷�����
	{
		if (old.status == 1)
			return;
		if (typeof act != "number")
			act = 0;
		nAction = act;
		var pos = $.jcom.getObjPos(mask);
		px = pos.left - event.clientX;
		py = pos.top - event.clientY;
		$(mask).off("mousemove", MouseEdge);
		$(document).on("mousemove", MouseAction);
		$(document).on("mouseup", MouseEnd);
		self.ActionEvent(1, nAction);
	};

	this.runMax = function(nType)	//����:��󻯺ͻ�ԭ
	{
		if ((old.status == 0) && (nType != 0))
		{
			old.status = 1;
			old.left = mask.style.left;
			old.top = mask.style.top;
			old.width = mask.style.width;
			old.height = mask.style.height;

			mask.style.left = "0px";
			mask.style.top = "0px";
			mask.style.width = "100%";
			mask.style.height = "100%";
			mask.style.display = "none";

		}
		else if ((old.status == 1) && (nType != 1))
		{
			old.status = 0;
			mask.style.left = old.left;
			mask.style.top = old.top;
			mask.style.width = old.width;
			mask.style.height = old.height;
			mask.style.display = "block";
		}
		Apply();
	};

	this.dblclick = function ()		//�¼�:˫���¼�
	{};

	this.attach = function (obj)	//����:�����ſ�󶨵�DOM����
	{
		domobj = obj;
		var pos = $.jcom.getObjPos(obj);
		$(mask).css({top: (pos.top - 2) + "px", left: (pos.left - 2) + "px", width: (pos.right - pos.left + 4) + "px", height: (pos.bottom - pos.top + 4) + "px", display: "block"}); 
		SetBox();
	};

	this.detach = function ()	//����:�����ſ��DOM������
	{
		mask.style.display = "none";
	};

	this.SetMaxRange = function (l, t, r, b)	//����:�������ſ�ı߽�
	{
		eleft = l - 2;
		etop = t - 2;
		eright = r + 2;
		ebottom = b + 2;
	
	}
	
	this.SetLimitBox = function (type, w, h)	//����:����������С�ĳߴ�
	{
		switch (type)
		{
		case 0:
			minwidth = w + 4;
			minheight = h + 4;
			break;
		case 1:
			maxwidth = w;
			maxheight = h;
			break;
		}
	};

	this.remove = function ()	//����:�Ƴ����ſ�
	{
		$(mask).remove();
	};

	this.ActionEvent = function(status, action)	//�¼�:���ſ�������¼�
	{};

	init();
};

$.jcom.Layer = function(domobj, faceRoot, cfg)	//��:���ֿ�
{
	var self = this;
	var domw, domh;		//�����Ŀ��
	var sp = 3;		//div �Ŀ�϶������div���У�

	function getTag(aFace, width, height)
	{
		if (typeof aFace.x == "undefined")
			return "";
		var tag = "", html = "";
		if (aFace.x <= 0)
		{
			var o = $.jcom.initObjVal({style:"", id:"A" + aFace.node, html:""}, aFace.a);
			if (typeof(aFace.a.child) == "object")
				html = getTag(aFace.a.child, width, aFace.y);
			tag += "<div id=\"" + o.id + "\" node=DVA" + aFace.node + " style='border-bottom:" + cfg.border + ";height:" + aFace.y + 
				"px;width:100%;overflow:hidden;" + o.style + "'>" + html + o.html + "</div>";
			html = "";
			var o = $.jcom.initObjVal({style:"", id:"B" + aFace.node, html:""}, aFace.b);
			if (typeof(aFace.b.child) == "object")
				html = getTag(aFace.b.child, width, height - aFace.y - 1);
			tag += "<div id=\"" + o.id + "\" node=DVB" + aFace.node + " style=';height:" + (height - aFace.y - 1) + 
				"px;width:100%;overflow:hidden;" + o.style + "'>" + html + o.html + "</div>";
		}
		else if (aFace.y <= 0)
		{
			var o = $.jcom.initObjVal({style:"", id:"A" + aFace.node, html:""}, aFace.a);
			if (typeof(aFace.a.child) == "object")
				html = getTag(aFace.a.child, aFace.x, height);
			tag += "<div id=\"" + o.id + "\" node=DVA" + aFace.node + " style='border-right:" + cfg.border + ";width:" + aFace.x +
				"px;height:100%;overflow:hidden;float:left;" + o.style + "'>" + html + o.html + "</div>";
			html = "";
			var o = $.jcom.initObjVal({style:"", id:"B" + aFace.node, html:""}, aFace.b);
			if (typeof(aFace.b.child) == "object")
				html = getTag(aFace.b.child, width - aFace.x - 1, height);
			tag += "<div id=\"" + o.id + "\" node=DVB" + aFace.node + " style='width:" + (width - aFace.x - sp) +
					"px;height:100%;overflow:hidden;float:left;" + o.style + "'>" + html + o.html + "</div>";
		}
	return tag;
	}

	function resize()
	{
		var dw = domobj.clientWidth - domw;
		var dh = domobj.clientHeight - domh;
		if ((dw == 0) && (dh == 0))
			return;
		if (typeof faceRoot.a != "object")
			return;
		$(domobj).off("resize", resize);
		resizerun(faceRoot, dw, dh);
		domw = domobj.clientWidth;	
		domh = domobj.clientHeight;
		rearrange(faceRoot, domw, domh);
		rearrange(faceRoot);
		self.onResize();
		window.setTimeout(function (){$(domobj).on("resize", resize);}, 1000);
	}

	function resizerun(aFace, dw, dh)
	{
		if ((aFace.x == -2) || (aFace.x == -3))
			aFace.y += dh;
		if ((aFace.y == -2) || (aFace.y == -3))
			aFace.x += dw;
		if (typeof aFace.a.child == "object")
			resizerun(aFace.a.child, dw, dh);
		if (typeof aFace.b.child == "object")
			resizerun(aFace.b.child, dw, dh);		
	}
	
	function splitInit(aFace)
	{
		if ((aFace.x == -1) || (aFace.y == -1) || (aFace.x == -3) || (aFace.y == -3))
		{
			var oo = self.getABDIV(aFace);
			aFace.split = new $.jcom.Split(oo[0], oo[1]);
			aFace.split.onsplit = onsplit;
			resize();
		}
		if ((typeof aFace.a == "object") && (typeof aFace.a.child == "object"))
			splitInit(aFace.a.child);
		if ((typeof aFace.b == "object") && (typeof aFace.b.child == "object"))
			splitInit(aFace.b.child);
	}

	function onsplit(left, top, split)
	{
		var aFace = getsplitface(faceRoot, split);
		if (aFace.x <= 0)
			aFace.y = top;
		else
			aFace.x = left;

		rearrange(faceRoot, domw, domh);
		rearrange(faceRoot);
	}

	function getsplitface(aFace, split)
	{
		if (aFace.split == split)
			return aFace;
		var oo = [aFace.a, aFace.b];
		for (var x = 0; x < oo.length; x++)
		{
			if ((typeof oo[x] == "object") && (typeof oo[x].child == "object"))
			{
				var obj = getsplitface(oo[x].child, split);
				if (typeof obj == "object")
					return obj;
			}
		}
	}
	
	function rearrange(aFace, width, height)
	{
		if (width == undefined)
		{
			if (typeof aFace.split == "object")
				aFace.split.refresh();
			if (typeof(aFace.a.child) == "object")
				rearrange(aFace.a.child);
			if (typeof(aFace.b.child) == "object")
				rearrange(aFace.b.child);
			return;
		}
		var ab = self.getABDIV(aFace);
		if (aFace.x <= 0)
		{
			if (typeof(aFace.a.child) == "object")
				rearrange(aFace.a.child, width, aFace.y);
			$(ab[0]).height(aFace.y);
			if (typeof(aFace.b.child) == "object")
				rearrange(aFace.b.child, width, height - aFace.y - 1);
			$(ab[1]).height(height - aFace.y - 1);
		}
		else if (aFace.y <= 0)
		{
			if (typeof(aFace.a.child) == "object")
				rearrange(aFace.a.child, aFace.x, height);
			$(ab[0]).width(aFace.x);
			if (typeof(aFace.b.child) == "object")
				rearrange(aFace.b.child, width - aFace.x - sp, height);
			$(ab[1]).width(width - aFace.x - sp);
		}
	}
	
	this.getcfg = function ()	//����:�õ�����
	{
		return cfg;
	};

	this.refresh = function(aface, reloadflag)	//����:ˢ��
	{
		if (typeof aface == "object")
			faceRoot = aface;
		if (typeof faceRoot != "object")
			return;
		if (reloadflag == false)
			return resize();
//		$(domobj).off("resize", resize);
		$(window).off("resize", resize);
		var w = domobj.style.width;
		var h = domobj.style.height;
		domobj.style.width = cfg.dwidth + "px";
		domobj.style.height = cfg.dheight + "px";
		domw = domobj.clientWidth;
		domh = domobj.clientHeight;
		domobj.innerHTML = getTag(faceRoot, domw, domh);
		domobj.style.width = w;
		domobj.style.height = h;
		resize();
//		$(domobj).on("resize", resize);
		$(window).on("resize", resize);
		if (cfg.split == 1)
			splitInit(faceRoot);
	};
	
	this.getABDIV = function(aFace, ab)	//����:���ݸ����Ĳ�����õ���������DOM�����е�һ��
	{
		if (ab == "a")
			return $(domobj).find("div[node=DVA" + aFace.node + "]")[0];
		if (ab == "b")
			return $(domobj).find("div[node=DVB" + aFace.node + "]")[0];
		return [$(domobj).find("div[node=DVA" + aFace.node + "]")[0], $(domobj).find("div[node=DVB" + aFace.node + "]")[0]];
	}
	
	this.getObj = function(id) 	//����:����ID�õ������е��Ӷ���
	{
		return $("#" + id, domobj);
	};
	
	this.getFaceRoot = function()	//����:�õ����ֵĸ�����
	{
		return faceRoot;
	};
	
	this.getFace = function(id, aFace)		//����:�õ����ֶ���
	{
		if (aFace == undefined)
			aFace = faceRoot;
		if ((aFace.a.id == id) || (aFace.b.id == id))
			return aFace;
		var oo = [aFace.a, aFace.b];
		for (var x = 0; x < oo.length; x++)
		{
			if (typeof oo[x].child == "object")
			{
				var o = this.getFace(id, oo[x].child);
				if  (typeof o == "object")
					return o;
			}
		}
	};
	
	this.setProp = function(id, prop, value)	//����:��������
	{
		var aFace = this.getFace(id);
		if (aFace == undefined)
			return;
		if ((prop == "x") || (prop == "y"))
			aFace[prop] = value;
		else
		{
			var o = aFace.a;
			if (aFace.b.id == id)
				o = aFace.b;
			o[prop] = value;
		}
		domw = domobj.clientWidth;	
		domh = domobj.clientHeight;
		rearrange(faceRoot, domw, domh);
		rearrange(faceRoot);
	};

	this.config = function (c) //����:�õ�����������
	{
		if (c == undefined)
			return cfg;
		cfg = $.jcom.initObjVal(cfg, c);
		if (faceRoot.x != undefined)
			this.refresh();
	};
	
	this.onResize = function ()			//�¼�:resize��ɺ���
	{
	};
	cfg = $.jcom.initObjVal({border:"", split:1, dwidth:640, dheight:480}, cfg);
	this.refresh();	
};
