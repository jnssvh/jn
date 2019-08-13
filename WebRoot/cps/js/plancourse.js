/**
 * 
 */
function getCourseTime(t)
{
	if ((t == null) || (t == "") || (t == 0) || t == 0.5)
		return "����";
	if (t == 1.0)
		return "һ��";
	if (t == 1.5)
		return "һ���";
	if (t == 2.0)
		return "����";
	if (t == 2.5)
		return "�����";
	if (t == 3.0)
		return "����";
	return t + "��";
}

function getUnitChineseNo(index, aU)
{
	var c = "";
	if (aU[index].RefID != 0)
		c = "*";
	if (aU[index].Mode_other == 1)
		return c + ".";
	if (aU[index].Mode_other == 2)
		return c + "ѡ�޿�:";
	var cnt = 0;
	for (var x = 0; x <= index; x++)
	{
		if ((aU[x].Mode_other != 1) && (aU[x].Mode_other != 2))
			cnt ++;
	}
	return c + "��" + $.jcom.getChineseNumber(cnt) + "��Ԫ:";
}

function CompareCourse(a, b)
{
	var da = $.jcom.makeDateObj(a.time);
	var db = $.jcom.makeDateObj(b.time);
    if (da == db)
        return 0;
    if (da < db)
        return -1;
    else
        return 1; 
}

function StrAdd(a, b)
{
	if ($.trim(b) == "")
		return a;
	if ($.trim(a) == "")
		return b;
	return a + "-" + b;
}


function DealUnitCourse(aU, aC, flag, checkfun)	//flag=0,��Ԫ������flag=1,ȥ��������Ԫ�Ϳγ̵����ã�������flag=2,����
{
	for (var x = 0; x < aU.length; x++)
	{
		if (flag == 1)
			aU[x].RefID = 0;
		aU[x].Mode_Name = aU[x].item;
		var prep = "��Ԫ:";
		if (aU[x].Mode_other == 1)
			prep = ".";
		if (aU[x].Mode_other == 2)
			prep = "ѡ�޿�:";
		if (flag == 2)
			prep = getUnitChineseNo(x, aU);
		aU[x].item = "<img src=../pic/355.png style=height:16px>&nbsp;" + prep + aU[x].Mode_Name;
		aU[x].nType = 11;
		for (var y = 0; y < aU[x].child.length; y++)
		{
			if (flag == 1)
				aU[x].child[y].RefID = 0;
			aU[x].child[y].Mode_Name = aU[x].child[y].item;
			aU[x].child[y].item = "<img src=../pic/355.png style=height:16px>&nbsp;ģ��:" + aU[x].child[y].Mode_Name;
			aU[x].child[y].nType = 13;
			aU[x].child[y].child = [];
		}
	}
	for (var x = 0; x < aC.length; x++)
	{
		if (flag == 1)
			aC[x].RefID = 0;
		for (y = 0; y < aU.length; y++)
		{
			if (aC[x].Mode_id == aU[y].Mode_id)
			{
				aU[y].child[aU[y].child.length] = aC[x];
				aC[x].item = "<img src=../pic/yjs6.png style=height:16px>&nbsp;" + StrAdd(aC[x].Course_name, aC[x].Teacher_name);
				aC[x].nType = 12;
				if (typeof checkfun == "function")
					checkfun(aC[x], 3);
				break;
			}
			for (var z = 0; z < aU[y].child.length; z++)
			{
				if (aC[x].Mode_id == aU[y].child[z].Mode_id)
				{
					aU[y].child[z].child[aU[y].child[z].child.length] = aC[x];
					aC[x].item = "<img src=../pic/yjs6.png style=height:16px>&nbsp;" + StrAdd(aC[x].Course_name, aC[x].Teacher_name);
					aC[x].nType = 12;
					if (typeof checkfun == "function")
						checkfun(aC[x], 3);
					break;
				}
			}
		}
	}
	
	for (var y = 0; y < aU.length; y++)
	{
		if (aU[y].Mode_other == 2)		//ѡ�޿�
		{
			var child = aU[y].child;
			aU[y].child = [];
			for (var x = 0; x < child.length; x++)
			{
				var ss = child[x].Note.split("|");
				child[x].time = ss[0];
				child[x].room = "";
				if (ss.length == 2)
					child[x].room = ss[1]; 
			}
			child = child.sort(CompareCourse);
			var d = "0000-1-1", cnt = 0, z = 0;
			for (var x = 0; x < child.length; x++)
			{
				var ss = child[x].Note.split("|");
				if (d != ss[0])
				{
					d = ss[0];
					aU[y].child[cnt++] = {item:d, Time:d, nType:13, child:[]};
					z = 0;
				}
				child[x].room = "";
				if (ss.length == 2)
				{
					child[x].room = ss[1];
					if ($.trim(ss[1]) != "")
						child[x].item += "(" + ss[1] + ")";
				}
				aU[y].child[cnt - 1].child[z++] = child[x];
			}
		}
	}	
	return aU;
}