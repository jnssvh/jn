<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,net.sf.json.JSONArray, net.sf.json.JSONObject,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="java.util.Date"%> 
<%@ include file="../../init_comm.jsp"%>
<%!
private boolean ValueInCollection(String value, String collection)
{
	if (collection.equals(""))
		return true;
	String [] s = collection.split(",");
	for (int x = 0; x < s.length; x++)
	{
		if (value.equals(s[x]))
			return true;
	}
	return false;
}

private String getDateAP(String date)
{
	String AP = "上午";
	String [] bb = date.split(" ");
	int d = VB.DateDiff2("h", date,  bb[0] + " 12:00:00");
	if (d > 0)
		AP = "下午";
	d = VB.DateDiff2("h", date, bb[0] + " 18:00:00");
	if (d > 0)
		AP =  "晚上";
	return AP;
}

class CourseItem {
	int ID;
	Date beginTime;
	Date endTime;
	String TeacherID;
	String AssistMan;
	String Course;
	int ClassID;
	String ClassName;
	String Teacher;
	String Room;
	int roomID;
}

private String trS(String s)
{
	if ((s == null) || s.equals(""))
		return "";
	s = s.replace(" ", "");
	s = s.replace("、", ",");
	s = s.replace("，", ",");
	return s;
}

private boolean CompValue(String a, String b, String [] ExItems)
{
	if ((a == null) || (b == null))
		return false;

	if (a.equals(b))
	{
		if (a.equals("") || a.equals("null"))
			return false;
	}

	String [] s1 = a.split(",");
	String [] s2 = b.split(",");
	for (int x = 0; x < s1.length; x++)
	{
		for (int y = 0; y < s2.length; y++)
		{
			if (s1[x].equals(s2[y]))
			{
				int z = 0;
				for (z = 0; z < ExItems.length; z++)
				{
					if (s1[x].equals(ExItems[z]))
						break;
				}
				if (z >= ExItems.length)
					return true;
			}
		}
	}
	return false;
}

private String getCourseOptions(SysApp sysApp)
{
//	var viewInfo = {nPage:1, PageSize:WebChar.ToInt(sysApp.getSysParam(5, "CourseDefaultPageSize", "每页显示的课表的天数", "120")), Records:0};
	return "{AMBegin:\"" +  sysApp.getSysParam(5, "CourseDefaultAMBegin", "默认上午上课开始时间", "8:30") + "\",AMEnd: \"" +
		sysApp.getSysParam(5, "CourseDefaultAMEnd", "默认上午下课开始时间", "11:30") + "\",PMBegin:\"" +
		sysApp.getSysParam(5, "CourseDefaultPMBegin", "默认下午上课开始时间", "15:00") + "\",PMEnd: \"" +
		sysApp.getSysParam(5, "CourseDefaultPMEnd", "默认下午下课开始时间", "17:30") + "\",EVBegin: \"" +
		sysApp.getSysParam(5, "CourseDefaultEVBegin", "默认晚上上课开始时间", "19:30") + "\",EVEnd: \"" +
		sysApp.getSysParam(5, "CourseDefaultEVEnd", "默认晚上下课开始时间", "21:30") + "\",DayShowMode:" +
		sysApp.getSysParam(5, "CourseDefaultDayShowMode", "课程表中日期显示的形式", "1") + ", DateFormat:" +
		sysApp.getSysParam(5, "CourseDefaultDateFormat", "课程表中日期显示的格式", "1") + ",ShowWeek:" +
		sysApp.getSysParam(5, "CourseShowWeek", "单独显示星期", "1") + ", ShowEndTime: " +
		sysApp.getSysParam(5, "CourseShowEndTime", "单独显示下课时间", "1") + ", ShowAssistMan: " +
		sysApp.getSysParam(5, "CourseShowAssistMan", "显示辅教人", "1") + ",ShowAssistInfo: " + 
		sysApp.getSysParam(5, "CourseShowAssistInfo", "显示辅教内容", "1") + ",ShowNote: " +
		sysApp.getSysParam(5, "CourseShowNote", "显示备注", "1") + ",ShowRed: " +
		sysApp.getSysParam(5, "CourseShowRed", "标蓝非师资库专题库中的课程", "1") + ",ActivityOption: " +
		sysApp.getSysParam(5, "CourseActivityOption", "将教学活动作为专题处理", "1") + ",SaveToCourseOption: " +
		sysApp.getSysParam(5, "CourseSaveToCourseOption", "课程保存后自动转到教学计划", "0") + ",SaveInstantOption: " +
		sysApp.getSysParam(5, "CourseSaveInstantOption", "课程保存后自动冲突检测", "0") + ",DelePasteItemOption: " +
		sysApp.getSysParam(5, "CourseDelePasteItemOption", "自动删除已粘贴的剪贴薄内容", "1") + ",SkipHolidayOption: " +
		sysApp.getSysParam(5, "CourseSkipHolidayOption", "自动排课时跳过节假日", "1") + ",ShowWeekEnd: " +
		sysApp.getSysParam(5, "CourseShowWeekEnd", "休息日未排课时间显示方式", "0") + ",ShowHoliday: " +
		sysApp.getSysParam(5, "CourseShowHoliday", "节假日未排课时间显示方式", "1") + ",ShowOuterTeach: " +
		sysApp.getSysParam(5, "CourseShowOuterTeach", "异地教学时间显示方式", "1") + ",ShowLongCourse: " +
		sysApp.getSysParam(5, "CourseShowLongCourse", "一天或以上课程显示方式", "1") + ", ShowWorkdayIdle: \"" +
		sysApp.getSysParam(5, "CourseShowWorkdayIdle", "工作日未排课时间显示内容", "") + "\"}";
}

private CourseItem getNextCourseRecord(ResultSet rs) throws SQLException
{
	if (rs.next() == false)
		return null;
	CourseItem item = new CourseItem();
	item.ID = rs.getInt("Syllabuses_id");
	item.beginTime = VB.CDate(rs.getString("BeginTime"));
	item.endTime = VB.CDate(rs.getString("EndTime"));
	item.TeacherID = rs.getString("Syllabuses_teacher_id");
	item.AssistMan = rs.getString("AssistMan");
	item.roomID = rs.getInt("Syllabuses_ClassRoom_id");
	item.ClassID = rs.getInt("class_id");
	item.ClassName = rs.getString("Class_Name");
	item.Teacher = rs.getString("Syllabuses_teacher_name");
	item.Room = rs.getString("Syllabuses_ClassRoom");
	item.Course = rs.getString("Syllabuses_subject_name");
	return item;
}

private String getCheckCourseResult(JDatabase jdb, int ClassID, int nMode, int TermID, String BeginTime, String EndTime) throws SQLException
{
	ArrayList <CourseItem> items = new ArrayList<CourseItem>();
	ResultSet rs = null;
	switch (nMode)
	{
	case 1:		//学期范围
		rs = jdb.rsSQL(0,"select Syllabuses_id, BeginTime, EndTime, Syllabuses_teacher_id, Syllabuses_teacher_name, " +
				"Syllabuses_subject_name, Syllabuses_course_name, Syllabuses_ClassRoom, Syllabuses_ClassRoom_id, AssistMan, CPB_Syllabuses.class_id, CPB_Class.Class_Name" + 
				" from CPB_Syllabuses left join CPB_Class on CPB_Syllabuses.class_id=CPB_Class.Class_id where CPB_Syllabuses.term_id=" +
				TermID + " order by BeginTime");
		break;
	case 2:		//班级范围
		rs = jdb.rsSQL(0,"select Syllabuses_id, BeginTime, EndTime, Syllabuses_teacher_id, Syllabuses_teacher_name, " +
				"Syllabuses_subject_name, Syllabuses_course_name, Syllabuses_ClassRoom, Syllabuses_ClassRoom_id, AssistMan, CPB_Syllabuses.class_id, CPB_Class.Class_Name" + 
				" from CPB_Syllabuses left join CPB_Class on CPB_Syllabuses.class_id=CPB_Class.Class_id where CPB_Syllabuses.BeginTime>='" + BeginTime +
				"' and CPB_Syllabuses.EndTime<='" + EndTime + "' order by BeginTime");
		break;
	}
	
	String [] ExTeachers = jdb.getStringsBySql(0, "select Teacher_name from CPB_Teacher where DeptName=Teacher_name");
	String [] ExClassRooms = jdb.getStringsBySql(0, "select Name from Place where Seats=9999");	
	int cnt = 0, nums = 1;
	String result = "", result1 = "";
	while (true)
	{
		CourseItem item = getNextCourseRecord(rs);
		if ((item != null) && (ClassID == item.ClassID))
			item.ClassName = "<span style=color:red>" + item.ClassName + "</span>";
		if (cnt > 0)
		{
			CourseItem prev = items.get(cnt - 1);
			if (	(item == null) 
				||	(prev.beginTime.getMonth() * 100 + prev.beginTime.getDate() != item.beginTime.getMonth() * 100 + item.beginTime.getDate()))
			{
				for (int x = 0; x < cnt; x++)
				{
					CourseItem xitem = items.get(x);
					if ((nMode == 2) && (xitem.ClassID != ClassID))
						continue;
					int z = x + 1;
					if (nMode == 2)
						z = 0;
					for (int y = z; y < cnt; y++)
					{
						CourseItem yitem = items.get(y);
						if ((nMode == 2) && (yitem.ClassID == ClassID))
							continue;
						if (yitem.beginTime.compareTo(xitem.endTime) >= 0)
							break;
						String reason = "";
						int nConflict = 0;
						if (CompValue(xitem.Room, yitem.Room, ExClassRooms))
						{
							reason = "&nbsp;地点冲突";
							nConflict += 1;
						}
						if (CompValue(trS(xitem.Teacher), trS(yitem.Teacher), ExTeachers) && !xitem.Room.equals(yitem.Room))
						{
							reason += "&nbsp;教师冲突";
							nConflict += 2;
						}
						if  (CompValue(trS(xitem.AssistMan), trS(yitem.AssistMan), ExTeachers) && !xitem.Room.equals(yitem.Room))
						{
							reason += "&nbsp;辅教人冲突";
							nConflict += 4;
						}
						if (!reason.equals(""))
						{
							if (nMode == 1)
							{
								result += "<li>" + (nums ++) + reason + "</li><table border=1 style='border-collapse:collapse;border:1px solid gray;'><tr><td width=100>班级</td><td width=80>上课时间</td><td width=300>课程</td><td width=80>教师</td><td width=80>辅教人</td><td width=80>地点</td></tr>" + 
									"<tr><td>" + xitem.ClassName + "</td><td>" + VB.dateCStr(xitem.beginTime, "MM-dd HH:mm") + "</td><td>" + xitem.Course + "</td><td>" +
									xitem.Teacher + "</td><td>" + xitem.AssistMan + "</td><td>" + xitem.Room + "</td></tr>" +
									"<tr><td>" + yitem.ClassName + "</td><td>" + VB.dateCStr(yitem.beginTime, "MM-dd HH:mm") + "</td><td>" + yitem.Course + "</td><td>" +
									yitem.Teacher + "</td><td>" + yitem.AssistMan + "</td><td>" + yitem.Room + "</td></tr></table><br>";
							}
							else
							{
								if (!result.equals(""))
									result += ",";
								result += "{CourseID:" + xitem.ID + ", nConflict:" + nConflict + ", Info:\"" + yitem.ClassName + "|" + VB.dateCStr(yitem.beginTime, "MM-dd HH:mm") +
									"|" + WebChar.toJson(yitem.Course) + "|" + yitem.Teacher + "|" + yitem.AssistMan + "|" + yitem.Room + "\"}";
							}
						}
					}
				}
				items.clear();
				cnt = 0;
			}
		}

		if (item != null)
		{
			items.add(item);
			cnt ++;
		}
		else
			break;
	}
	if (nMode == 1)
		return "<h5>共有" + (nums - 1) + "条冲突</h5>" + result;
	return "[" + result + "]";	
}

private String SetClassExValue(JDatabase jdb, WebUser user, int ClassID, String EName, String CName, String value)
{
	String st = VB.Now();
	
	int DataID = WebChar.ToInt(jdb.GetTableValue(0, "UserReport", "ID", "TypeName", "'ClassTeachPlan' and param1=" + ClassID));
	if (DataID == 0)
	{
		String sql = "insert into UserReport (TypeName, TmplID, FormName, RPTName, param1, CreateMan, CreateTime) values('ClassTeachPlan', " +
				0 + ",'FormClassTeachPlan','班次教学计划'," + ClassID + ",'" + user.CMemberName + "','" + st + "')";
		int result  = jdb.ExecuteSQL(0, sql);
		DataID = WebChar.ToInt(jdb.GetTableValue(0, "UserReport", "ID", "TypeName", "'ClassTeachPlan' and param1=" + ClassID + " and CreateTime='" + st + "'"));
	}
	else
	{
		String sql = "update UserReportDetail set Value='" + value + "' where EName='" + EName +  "' and CName='" + CName + "' and ParentID=" + DataID;
		int result = jdb.ExecuteSQL(0, sql);
		if (result == 0)
		{
			sql = "insert UserReportDetail (EName, CName, Value, ParentID) values('" + EName + "','" + CName + "','" + value + "'," + DataID + ")";
			result  = jdb.ExecuteSQL(0, sql);
		}
	}
	return "OK";
}

%>
<%
	int ClassID = WebChar.RequestInt(request, "ClassID");
	if (WebChar.RequestInt(request, "OutExcelToServer") == 1)
	{
		int AffixID = WebChar.RequestInt(request, "AffixID");
		String AffixName = WebChar.requestStr(request, "AffixName");
		String docid = jdb.GetTableValue(0, "CPT_TeachDoc", "ID", "ClassID", ClassID + " and nTPLID in (select ID from CPT_DocTpl where AttribName='Course')");
		String sql = "insert into CPT_TeachDocItem(Title, SubmitMan, SubmitTime, ClassID, TeachDocID, AffixID) values('" +
			AffixName + "','" + user.CMemberName + "','" + VB.Now() + "'," + ClassID + "," + docid + "," + AffixID + ")";
		jdb.ExecuteSQL(0, sql);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "SaveOuterDate") == 1)
	{
		String OuterBegin = WebChar.requestStr(request, "OuterBegin");
		String OuterEnd = WebChar.requestStr(request, "OuterEnd");
		String sql = "update CPB_Class set OuterBegin='" + OuterBegin + "', OuterEnd='" + OuterEnd + "' where Class_id=" + ClassID;
		int	result  = jdb.ExecuteSQL(0, sql);
		String OtherOuterTime = WebChar.requestStr(request, "OtherOuterTime");
		SetClassExValue(jdb, user, ClassID, "OtherOuterTime", "其它异地教学时间段", OtherOuterTime);
		out.print("OK:" + result);
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "SaveHoliday") == 1)
	{
		String [] p = request.getParameterValues("THoliday");
		if (p != null)
		{
			for (int x = 0; x < p.length; x++)
			{
				int THoliday = WebChar.ToInt(WebChar.RequestForms(request, "THoliday", x));
				String HolidayName = WebChar.RequestForms(request, "HolidayName", x);
				int nDateType = WebChar.ToInt(WebChar.RequestForms(request, "nDateType", x));
				int nType = WebChar.ToInt(WebChar.RequestForms(request, "nType", x));
				int ID = WebChar.ToInt(jdb.GetTableValue(0, "Holiday", "ID", "THoliday", "" + THoliday));
				if (ID > 0)
					jdb.ExecuteSQL(0, "update Holiday set HolidayName='" + HolidayName + "', nDateType=" + nDateType + ", nType=" + nType + " where ID=" + ID);
				else
					jdb.ExecuteSQL(0, "insert Holiday (THoliday, HolidayName, nDateType, nType) values(" + THoliday + ",'" + HolidayName + "'," + nDateType + "," + nType + ")");
			}
		}
		String ClassHoliday = WebChar.requestStr(request, "ClassHoliday");
		SetClassExValue(jdb, user, ClassID, "ClassHoliday", "班级节假日", ClassHoliday);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SaveDefaultCourseTime") == 1)
	{
		int nType = WebChar.RequestInt(request, "nType");

		String AMBegin = WebChar.requestStr(request, "AMBegin");
		String AMEnd = WebChar.requestStr(request, "AMEnd");
		String PMBegin = WebChar.requestStr(request, "PMBegin");
		String PMEnd = WebChar.requestStr(request, "PMEnd");
		String EVBegin = WebChar.requestStr(request, "EVBegin");
		String EVEnd = WebChar.requestStr(request, "EVEnd");
		String value = "";
		if (nType == 2)
		{
			sysApp.setSysParam("CourseDefaultAMBegin", AMBegin);
			sysApp.setSysParam("CourseDefaultAMEnd", AMEnd);
			sysApp.setSysParam("CourseDefaultPMBegin", PMBegin);
			sysApp.setSysParam("CourseDefaultPMEnd", PMEnd);
			sysApp.setSysParam("CourseDefaultEVBegin", EVBegin);
			sysApp.setSysParam("CourseDefaultEVEnd", EVEnd);
		}
		else
			value = "{AMBegin:\"" + AMBegin + "\", AMEnd:\"" + AMEnd + "\", PMBegin:\"" + PMBegin + "\", PMEnd:\"" + PMEnd + "\", EVBegin:\"" + EVBegin + "\", EVEnd:\"" + EVEnd + "\"}";
		SetClassExValue(jdb, user, ClassID, "DefaultClassCourseTime", "班级默认上下课时间", value);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SaveFaceOption") == 1)
	{
		int nType = WebChar.RequestInt(request, "nType");
		int EditMode = WebChar.RequestInt(request, "EditMode");

//		String PageSize = WebChar.requestStr(request, "PageSize");

		String DayShowMode = WebChar.requestStr(request, "DayShowMode");
		String DateFormat = WebChar.requestStr(request, "DateFormat");
		
		String ShowWeek = WebChar.requestStr(request, "ShowWeek");
		String ShowEndTime = WebChar.requestStr(request, "ShowEndTime");
		String ShowAssistMan = WebChar.requestStr(request, "ShowAssistMan");
		String ShowAssistInfo = WebChar.requestStr(request, "ShowAssistInfo");
		String ShowNote = WebChar.requestStr(request, "ShowNote");

		String ShowRed = WebChar.requestStr(request, "ShowRed");
		String ActivityOption = WebChar.requestStr(request, "ActivityOption");
		String SaveToCourseOption = WebChar.requestStr(request, "SaveToCourseOption");
		String SaveInstantOption = WebChar.requestStr(request, "SaveInstantOption");
		String DelePasteItemOption = WebChar.requestStr(request, "DelePasteItemOption");
		String SkipHolidayOption = WebChar.requestStr(request, "SkipHolidayOption");
		
		String ShowWeekEnd = WebChar.requestStr(request, "ShowWeekEnd");
		String ShowHoliday = WebChar.requestStr(request, "ShowHoliday");
		String ShowOuterTeach = WebChar.requestStr(request, "ShowOuterTeach");
		String ShowLongCourse = WebChar.requestStr(request, "ShowLongCourse");
		String ShowWorkdayIdle = WebChar.requestStr(request, "ShowWorkdayIdle");
				
		String value = "";
		if (nType == 2)
		{
	
			sysApp.setSysParam("CourseDefaultDayShowMode", DayShowMode);
			sysApp.setSysParam("CourseDefaultDateFormat", DateFormat);
		
			sysApp.setSysParam("CourseShowWeek", ShowWeek);
			sysApp.setSysParam("CourseShowEndTime", ShowEndTime);
			sysApp.setSysParam("CourseShowAssistMan", ShowAssistMan);
			sysApp.setSysParam("CourseShowAssistInfo", ShowAssistInfo);
			sysApp.setSysParam("CourseShowNote", ShowNote);

			if (EditMode == 1)
			{
//				sysApp.setSysParam("CourseDefaultPageSize", PageSize);
				sysApp.setSysParam("CourseShowRed", ShowRed);
				sysApp.setSysParam("CourseActivityOption", ActivityOption);
				sysApp.setSysParam("CourseSaveToCourseOption", SaveToCourseOption);
				sysApp.setSysParam("CourseSaveInstantOption", SaveInstantOption);
				sysApp.setSysParam("CourseDelePasteItemOption", DelePasteItemOption);
				sysApp.setSysParam("CourseSkipHolidayOption", SkipHolidayOption);
				SetClassExValue(jdb, user, ClassID, "ClassCourseConfig", "班级课程表编辑配置选项", "");
			}
			if (EditMode == 2)
			{
				sysApp.setSysParam("CourseShowWeekEnd", ShowWeekEnd);
				sysApp.setSysParam("CourseShowHoliday", ShowHoliday);
				sysApp.setSysParam("CourseShowOuterTeach", ShowOuterTeach);
				sysApp.setSysParam("CourseShowLongCourse", ShowLongCourse);
				sysApp.setSysParam("CourseShowWorkdayIdle", ShowWorkdayIdle);
				SetClassExValue(jdb, user, ClassID, "ClassCourseReadOnlyConfig", "班级课程表阅读配置选项", "");
			}
		}
		else
		{
			if (EditMode == 1)
			{
				value = "{DayShowMode:" + DayShowMode + ", DateFormat:" + DateFormat + ", ShowWeek:" + ShowWeek + 
					", ShowEndTime:" + ShowEndTime + ", ShowAssistMan:" + ShowAssistMan + ", ShowAssistInfo:" + ShowAssistInfo + ", ShowNote:" + ShowNote + 
					", ShowRed:" + ShowRed + ", ActivityOption:" + ActivityOption + ", SaveToCourseOption:" + SaveToCourseOption +
					", SaveInstantOption:" + SaveInstantOption + ", DelePasteItemOption:" + DelePasteItemOption + ", SkipHolidayOption:" + SkipHolidayOption + "}";
				SetClassExValue(jdb, user, ClassID, "ClassCourseConfig", "班级课程表编辑配置选项", value);
			}
			if (EditMode == 2)
			{
				value = "{DayShowMode:" + DayShowMode + ", DateFormat:" + DateFormat + ", ShowWeek:" + ShowWeek + 
						", ShowEndTime:" + ShowEndTime + ", ShowAssistMan:" + ShowAssistMan + ", ShowAssistInfo:" + ShowAssistInfo + ", ShowNote:" + ShowNote +  
						", ShowWeekEnd:" + ShowWeekEnd + ",ShowHoliday:" + ShowHoliday + ",ShowOuterTeach:" + ShowOuterTeach + ",ShowLongCourse:" + ShowLongCourse +
						", ShowWorkdayIdle:\"" + ShowWorkdayIdle + "\"}";
				SetClassExValue(jdb, user, ClassID, "ClassCourseReadOnlyConfig", "班级课程表阅读配置选项", value);
			}
		}

		out.print("OK");
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "SaveCourseStateFlag") > 0)
	{
		int CourseState = WebChar.RequestInt(request, "CourseState");
		String EditMembers = WebChar.requestStr(request, "EditMembers");
		String ViewMembers = WebChar.requestStr(request, "ViewMembers");
		String value = "{CourseState:" + CourseState + ", EditMembers:\"" + EditMembers + "\", ViewMembers:\"" + ViewMembers + "\"}";
		SetClassExValue(jdb, user, ClassID, "ClassCourseStateAndRight", "班级课程表状态与权限", value);
		out.print("OK");
		jdb.closeDBCon();
		return;
		
	}
	if (WebChar.RequestInt(request, "GetFlowData") > 0)
	{
		int id = WebChar.ToInt(jdb.GetTableValue(0, "FT_PlaceReq", "ID", "ClassID", "" + ClassID));
		if (id > 0)
		{
			String Data = jdb.getJsonBySql(0, "select FT_PlaceReqDetail.*, place.Name from FT_PlaceReqDetail left join place on FT_PlaceReqDetail.PlaceID=place.ID where  ReqID=" + id);
			out.print(Data);
		}
		else
			out.print("[]");
	
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SearchFlow") > 0)
	{
		int id = WebChar.ToInt(jdb.GetTableValue(0, "FT_PlaceReq", "ID", "ClassID", "" + ClassID));
		if (id > 0)
		{
			id = WebChar.ToInt(jdb.GetTableValue(0, "FlowData", "ID", "DataID", "'" + id +
				"' and FlowID in (select ID from FlowMain where EName='FlowPlaceReq')"));
			out.print("[{StepID:" + id + "}]");
		}
		else
			out.print("[{StepID:0}]");
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "CheckCourse") > 0)
	{
		String b = WebChar.requestStr(request, "BeginTime");
		String e =  WebChar.requestStr(request, "EndTime");
		e = VB.DateAdd("d", 1, e);	//多加一天

		String result = getCheckCourseResult(jdb, ClassID, WebChar.RequestInt(request, "Mode"), WebChar.RequestInt(request, "TermID"), b, e);
		out.print(result);
		jdb.closeDBCon();
		return;		
	}
	
	if (WebChar.RequestInt(request, "CheckTeacher") > 0)
	{
		int num = WebChar.RequestInt(request, "num");
		String json = "";
		for (int x = 0; x < num; x++)
		{
			int id = WebChar.ToInt(WebChar.RequestForms(request, "id", x));
			String Teacher = trS(WebChar.GetAjaxPostData(request, "Teacher", x));
			String [] ss = Teacher.split(",");
			String dbTeacherID = "", dbTeacher = "", dbnType = "", dbUnit = "", exs = "";			
			for (int y = 0; y < ss.length; y++)
			{
				String sql = "select Teacher_id, Teacher_name, nType, TeacherUnit from CPB_Teacher where Teacher_name='" + ss[y] + "' or Teacher_name like '" + ss[y] + "[0-9]%'";
				ResultSet rs = jdb.rsSQL(0, sql);
				String TeacherID = "", nType = "", TeacherName = "", Unit = "", sp = "";
				while (rs.next())
				{
					TeacherID += sp + rs.getInt("Teacher_id");
					TeacherName += sp + rs.getString("Teacher_name");
					nType += sp + rs.getInt("nType");
					Unit += sp + rs.getString("TeacherUnit");
					sp = ",";
				}
				if (y == 0)
				{
					dbTeacherID = TeacherID;
					dbTeacher = TeacherName;
					dbnType = nType;
					dbUnit = Unit;
				}
				else
				{
					exs += ",{spTeacher:\"" + ss[y] + "\", dbTeacherID:\"" + TeacherID + "\",dbTeacher:\"" + TeacherName +
						"\", dbnType:\"" + nType + "\", dbUnit:\"" + Unit + "\"}";
				}
			}
			if (!json.equals(""))
				json += ",";
			if (ss.length == 1)
				json += "{id:" + id + ", spTeacher:\"" + Teacher + "\", dbTeacherID:\"" + dbTeacherID + "\",dbTeacher:\"" +
					dbTeacher + "\", dbnType:\"" + dbnType + "\", dbUnit:\"" + dbUnit + "\"}";
			else
				json += "{id:{value:" + id + ",rowspan:" + ss.length + "}, spTeacher:\"" + ss[0] + "\", dbTeacherID:\"" +
					dbTeacherID + "\",dbTeacher:\"" + dbTeacher + "\", dbnType:\"" + dbnType + "\", dbUnit:\"" + dbUnit + "\"}" + exs;
		}
		out.print("[" + json + "]");
		jdb.closeDBCon();
		return;		
	}
	
	if (WebChar.RequestInt(request, "GetConflictEx") > 0)
	{
		int roomID = WebChar.RequestInt(request, "roomID");
		if (roomID > 0)
			jdb.ExecuteSQL(0, "update Place set Seats=0 where ID=" + roomID);
		int Teacher_id = WebChar.RequestInt(request, "Teacher_id");
		if (Teacher_id > 0)
			jdb.ExecuteSQL(0, "update CPB_Teacher set DeptName='' where Teacher_id=" + Teacher_id);
		
		String ExTeachers = jdb.getJsonBySql(0, "select Teacher_id, Teacher_name as item from CPB_Teacher where DeptName=Teacher_name");
		String ExClassRooms = jdb.getJsonBySql(0, "select ID, Name as item from Place where Seats=9999");	
		out.print("{ExTeachers:" + ExTeachers + ", ExClassRooms:" + ExClassRooms + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "MarkConflictItem") > 0)
	{		
		String sql, Value = WebChar.requestStr(request, "Value");
		int id, nType = WebChar.RequestInt(request, "nType");
		switch (nType)
		{
		case 1:
		case 2:
			Value = trS(Value);
			String [] ss = Value.split(",");
			for (int x = 0; x < ss.length; x++)
			{
				id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Teacher", "Teacher_id", "Teacher_name", "'" + ss[x] + "'"));
				if (id == 0)
					sql = "insert into CPB_Teacher (Teacher_name, nType, DeptName) values('" + Value + "',1,'" + ss[x] + "')";
				else
					sql = "update CPB_Teacher set DeptName=Teacher_name where ID=" + id;
				jdb.ExecuteSQL(0, sql);
			}
			break;
		case 3:
			id = WebChar.ToInt(jdb.GetTableValue(0, "Place", "ID", "Name", "'" + Value + "'"));
			if (id == 0)
				sql = "insert into Place (Name, Seats) values('" + Value + "',9999)";
			else
				sql = "update Place set Seats=9999 where ID=" + id;
			jdb.ExecuteSQL(0, sql);
			break;			
		}
		out.print("OK");
		jdb.closeDBCon();
		return;		
	}
	if (WebChar.RequestInt(request, "ExportWord") > 0)
	{
		String FileName = jdb.GetTableValue(0, "CPB_Class", "Class_name", "Class_id", "" + ClassID);
        FileName = new String(FileName.getBytes(), "ISO8859-1");
		response.setContentType("application/doc"); 
		response.setHeader("Content-Disposition", "inline; filename=\"" + FileName + ".doc\"");
		out.print(WebChar.RequestForms(request, "SyllabusText", 0));
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "DeleteOldCourse") > 0)
	{
		String b = jdb.GetTableValue(0, "CPB_Class", "Class_BeginTime", "Class_id", "" + ClassID);
		String e =  VB.DateAdd("d", 1, jdb.GetTableValue(0, "CPB_Class", "Class_EndTime", "Class_id", "" + ClassID));	//多加一天
		int result = jdb.ExecuteSQL(0, "delete from CPB_Syllabuses where Class_id=" + ClassID + " and (BeginTime<'" + b + "' or EndTime>'" + e + "')");
		out.print("OK");
		jdb.closeDBCon();
		return;		
	}

	if (WebChar.RequestInt(request, "LoadCourse") > 0)
	{
		int EditMode = WebChar.RequestInt(request, "EditMode");
		String stateRight = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'ClassCourseStateAndRight' and ParentID in (select ID from UserReport where param1=" +
				ClassID + " and TypeName='ClassTeachPlan')");
		int CourseState = 0;
		String EditMembers = "", ViewMembers = "";
		if (!stateRight.equals(""))
		{
			JSONObject stateObj = JSONObject.fromObject(stateRight);
			if (stateObj.has("CourseState"))
				CourseState = stateObj.getInt("CourseState");
			if (CourseState == 1)
			{
				if (stateObj.has("EditMembers"))
					EditMembers = stateObj.getString("EditMembers");
				if (stateObj.has("ViewMembers"))
					ViewMembers = stateObj.getString("ViewMembers");
				if (EditMode == 1)
				{
					EditMembers = FlowFun.GetFlowUser(EditMembers, jdb, user, 0);
					if ((ValueInCollection(user.CMemberName, EditMembers) == false) && (user.isAdmin() == false))
					{
						out.print("没有编辑课程表的权限");	
						jdb.closeDBCon();
						return;
					}
				}
				else
				{
					ViewMembers = FlowFun.GetFlowUser(ViewMembers, jdb, user, 0);
					if ((ValueInCollection(user.CMemberName, EditMembers) == false) && (user.isAdmin() == false))
					{
						out.print("课程表还在编辑中，请耐心等待到发布后再查看。");	
						jdb.closeDBCon();
						return;
					}
				}
			}
		}
		else
			stateRight = "{}";
		
		ResultSet rs = jdb.rsSQL(0, "select Class_id, Term_id, Class_Name, Class_BeginTime, Class_EndTime, ClassRoom_id, teacher_ids, ClassCode,OuterBegin,OuterEnd,TrainLeader from CPB_Class where Class_id=" + ClassID);
		String classObj = jdb.getJsonByResultSet(0, rs);
		rs.previous();
		String Teachers = rs.getString("teacher_ids");
		if (VB.isEmpty(Teachers) == false)
			Teachers = jdb.getStringBySql(0, "select CName from Member where ID in(" + Teachers + ")");
		rs.close();
		String Course = jdb.getJsonBySql(0,"select Syllabuses_id,Syllabuses_date,Syllabuses_AP, BeginTime, EndTime, Syllabuses_subject_id,Syllabuses_subject_name,Syllabuses_activity_id," +
			"Syllabuses_activity_name, Syllabuses_course_id,Syllabuses_course_name,Syllabuses_teacher_id,Syllabuses_teacher_name,Syllabuses_ClassRoom_id,Syllabuses_ClassRoom," +
			"Syllabuses_bak, AssistMan, AssistInfo, FreeIDs, Syllabuses_Department, RefID,nType from CPB_Syllabuses where class_id=" + ClassID + " order by BeginTime");
		Date b = VB.CDate(jdb.GetTableValue(0, "CPB_Class", "Class_BeginTime", "Class_id", "" + ClassID));
		Date e =  VB.CDate(jdb.GetTableValue(0, "CPB_Class", "Class_EndTime", "Class_id", "" + ClassID));
		int bb = (b.getYear() + 1900) * 10000 + (b.getMonth() + 1) * 100 + b.getDate();
		int ee = (e.getYear() + 1900) * 10000 + (e.getMonth() + 1) * 100 + e.getDate();
		String Holiday = jdb.getJsonBySql(0, "select THoliday, HolidayName, nType, nDateType from Holiday where THoliday>=" + bb + "and THoliday<=" + ee + "order by THoliday");
		String ClassHoliday = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'ClassHoliday' and ParentID in (select ID from UserReport where param1=" +
			ClassID + " and TypeName='ClassTeachPlan')");
		if (ClassHoliday.equals(""))
			ClassHoliday = "[]";
		String OtherOuterTime = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'OtherOuterTime' and ParentID in (select ID from UserReport where param1=" +
			ClassID + " and TypeName='ClassTeachPlan')");
		if (OtherOuterTime.equals(""))
			OtherOuterTime = "[]";
		if (EditMode == 1)
		{
			String ClassCourseConfig = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'ClassCourseConfig' and ParentID in (select ID from UserReport where param1=" +
					ClassID + " and TypeName='ClassTeachPlan')");
			if (ClassCourseConfig.equals(""))
				ClassCourseConfig = "{}";
			String DefaultClassCourseTime = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'DefaultClassCourseTime' and ParentID in (select ID from UserReport where param1=" +
					ClassID + " and TypeName='ClassTeachPlan')");
			if (DefaultClassCourseTime.equals(""))
				DefaultClassCourseTime = "{}";
			String et = VB.dateCStr(e, "yyyy-MM-dd");
			et = VB.DateAdd("d", 1, et);	//多加一天
			String ConflictJSON = getCheckCourseResult(jdb, ClassID, 2, 0, VB.dateCStr(b, "yyyy-MM-dd"), et);
			out.print("{Course:" + Course + ", Holiday:" + Holiday + ", ClassHoliday:" + ClassHoliday + ", OtherOuterTime:" + OtherOuterTime +
				", DefaultClassCourseTime:" + DefaultClassCourseTime + ", ClassCourseConfig:" + ClassCourseConfig + ", Conflict:" + ConflictJSON +
				", classObj:" + classObj + ", Teachers:\"" + Teachers + "\", StateRight:" + stateRight + ", Options:" + getCourseOptions(sysApp) + "}");//", FreeCourse:" + FreeCourse + "}");
		}
		else
		{
			String ClassCourseConfig = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'ClassCourseReadOnlyConfig' and ParentID in (select ID from UserReport where param1=" +
				ClassID + " and TypeName='ClassTeachPlan')");
			if (ClassCourseConfig.equals(""))
				ClassCourseConfig = "{}";
			out.print("{Course:" + Course + ", Holiday:" + Holiday + ", ClassHoliday:" + ClassHoliday + ", OtherOuterTime:" + OtherOuterTime +
				", ClassCourseConfig:" + ClassCourseConfig + ", classObj:" + classObj + ", Teachers:\"" + Teachers + "\", Options:" + getCourseOptions(sysApp) + "}");
		}
//		String FreeCourse = jdb.getJsonBySql(0,"select Syllabuses_free_id, BeginTime, EndTime, Syllabuses_free_subject_id,Syllabuses_free_subject_name," +
//				"Syllabuses_free_course_id,Syllabuses_free_course_name,Syllabuses_free_teacher_id,Syllabuses_free_teacher_name,Syllabuses_free_ClassRoom_id," +
//				"Syllabuses_free_ClassRoom_name, AssistMan, AssistInfo, Note from CPB_Syllabuses_free where term_id in (select Term_id from CPB_Class where Class_id=" + 
//				ClassID + ") order by BeginTime");


//		String b = jdb.GetTableValue(0, "CPB_Class", "Class_BeginTime", "Class_id", "" + ClassID);
//		String e =  VB.DateAdd("d", 1, jdb.GetTableValue(0, "CPB_Class", "Class_EndTime", "Class_id", "" + ClassID));
//		out.print(jdb.getJsonBySql(0,"select * from CPB_Syllabuses where class_id=" + ClassID + " and BeginTime >= '" + b + "' and EndTime <= '" + e +
//			"' order by BeginTime"));
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "LoadTermCourse") > 0)
	{
		String Course = jdb.getJsonBySql(0,"select Syllabuses_id,Syllabuses_date,Syllabuses_AP,BeginTime, EndTime, Syllabuses_subject_id,Syllabuses_subject_name,Syllabuses_activity_id," +
				"Syllabuses_activity_name, Syllabuses_course_id,Syllabuses_course_name,Syllabuses_teacher_id,Syllabuses_teacher_name,Syllabuses_ClassRoom_id,Syllabuses_ClassRoom," +
				"Syllabuses_bak, AssistMan, CPB_Syllabuses.class_id, Class_Name from CPB_Syllabuses left join CPB_Class on CPB_Syllabuses.class_id=CPB_Class.Class_id where CPB_Syllabuses.Term_id=" +
				WebChar.RequestInt(request, "Term_id") + " order by BeginTime");
		out.print(Course);

		jdb.closeDBCon();
		return;		
	}

	if (WebChar.RequestInt(request, "LoadManyClassCourse") > 0)
	{
		String b = WebChar.requestStr(request, "ClassBeginTime");
		String e = WebChar.requestStr(request, "ClassEndTime");
		String ClassIDs = WebChar.requestStr(request, "ClassIDs");
		String sql = "select Class_id, Class_Name from CPB_Class where Class_id in (" + ClassIDs + ")";
		String Classes = jdb.getJsonBySql(0, sql);
		sql = "select Syllabuses_id,Syllabuses_date,Syllabuses_AP,BeginTime, EndTime, Syllabuses_subject_id,Syllabuses_subject_name,Syllabuses_activity_id," +
				"Syllabuses_activity_name, Syllabuses_course_id,Syllabuses_course_name,Syllabuses_teacher_id,Syllabuses_teacher_name,Syllabuses_ClassRoom_id,Syllabuses_ClassRoom," +
				"Syllabuses_bak, AssistMan, class_id from CPB_Syllabuses  where class_id in (" + ClassIDs + ") and Syllabuses_date>='" + b + "' and Syllabuses_date<='" + e + "' order by BeginTime";
		String Course = jdb.getJsonBySql(0, sql);
		out.print("{Course:" + Course + ", Classes:" + Classes + "}");
		jdb.closeDBCon();
		return;		
	}
	
	if (WebChar.RequestInt(request, "SearchSubject") > 0)
	{
		String Data = jdb.getJsonBySql(0, "select Subject_id, Subject_name, Teacher_id, Teacher_name, Department_name from CPB_Subject where Subject_name like '%" + WebChar.requestStr(request, "SeekKey") + "%'");
		out.print(Data);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "SearchTeacher") > 0)
	{
		String Data = jdb.getJsonBySql(0, "select * from CPB_Teacher where Teacher_name like '%" + WebChar.requestStr(request, "SeekKey") + "%'");
		out.print(Data);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "SearchSubjectDoc") > 0)
	{
		String key = WebChar.requestStr(request, "SeekKey");
		String Data = jdb.getJsonBySql(0, "select Subject_id, Subject_name, Teacher_id, Teacher_name, Department_name from CPB_Subject where Subject_name like '%" +
			 key + "%' or Teacher_name like '%" + key + "%' order by Frist_time desc");
		out.print(Data);
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "GetTeachSubject") > 0)
	{
		String subjectData = jdb.getJsonBySql(0, "select * from CPB_Subject where Teacher_id='" +
			WebChar.RequestInt(request, "TeacherID") + "'");
		out.print(subjectData);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "GetClassByTime") > 0)
	{
		String t = WebChar.requestStr(request, "Time");
		int term = WebChar.RequestInt(request, "Term_id");
		int Class_id = WebChar.RequestInt(request, "Class_id");
		String s = jdb.getJsonBySql(0, "select Class_id, Class_Name from CPB_Class where Term_id=" + term + " and Class_id<>" + Class_id + 
			" and Class_BeginTime<='" + t + "' and Class_EndTime>='" + t + "'"); 
		out.print(s);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "GetClassByBETime") > 0)
	{
		String b = WebChar.requestStr(request, "ClassBeginTime");
		String e = WebChar.requestStr(request, "ClassEndTime");
		String s = jdb.getJsonBySql(0, "select Class_id, ClassCode, Class_Name, Class_BeginTime, Class_EndTime from CPB_Class where Class_EndTime>='" + b +
			"' and Class_BeginTime<='" + e + "' and (TrainUnit is null or TrainUnit<>'保留')");
		out.print(s);
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SetCommonCourse") > 0)
	{
		int Syllabuses_id = WebChar.RequestInt(request, "Syllabuses_id");
		String ClassIDs = WebChar.requestStr(request, "ClassIDs");
		int DelFlag = WebChar.RequestInt(request, "DelFlag");
		ResultSet rs = jdb.rsSQL(0, "select * from CPB_Syllabuses where Syllabuses_id=" + Syllabuses_id);
		String sql = "", log = "";
		if (rs.next())
		{
			ResultSet rs1 = jdb.rsSQL(0, "select * from CPB_Class where Term_id=" + rs.getInt("term_id") + " and Class_BeginTime<='" + rs.getString("Syllabuses_date") +
				"' and Class_EndTime>='" + rs.getString("Syllabuses_date") + "' and Class_id in (" + ClassIDs + ")");
			while (rs1.next())
			{
				int course_id = rs.getInt("Syllabuses_course_id");
				int subject_id = rs.getInt("Syllabuses_subject_id");
				if (subject_id > 0)
					course_id = jdb.getIntBySql(0, "select Course_id from CPB_Course where class_id=" + rs1.getInt("Class_id") + " and Subject_id=" + subject_id);
					
				log += rs1.getString("Class_name") + "\n";
				int id = jdb.getIntBySql(0, "select Syllabuses_id from CPB_Syllabuses where class_id=" + rs1.getInt("Class_id") + " and BeginTime<='" +
					rs.getString("EndTime") + "' and EndTime>='" + rs.getString("BeginTime") + "'");
				if (DelFlag == 1)
				{
					sql = "delete from CPB_Syllabuses where class_id=" + rs1.getInt("Class_id") + " and BeginTime<'" +
						rs.getString("EndTime") + "' and EndTime>'" + rs.getString("BeginTime") + "' and Syllabuses_id<>" + id;
					int result  = jdb.ExecuteSQL(0, sql);
				}
				if (id == 0)
				{
				 	sql = "insert into CPB_Syllabuses (term_id, class_id, Syllabuses_date, BeginTime, EndTime, Syllabuses_course_id,Syllabuses_course_name," +
						"Syllabuses_subject_id, Syllabuses_subject_name, Syllabuses_activity_id, Syllabuses_activity_name, Syllabuses_Department, Syllabuses_teacher_id, " +
				 		"Syllabuses_teacher_name, Syllabuses_ClassRoom_id, Syllabuses_ClassRoom, Syllabuses_bak, AssistMan, AssistInfo, RefID) values(" + rs.getInt("term_id") +
				 		"," + rs1.getInt("Class_id") + ",'" + rs.getString("Syllabuses_date") + "','" + rs.getString("BeginTime") + "','" + rs.getString("EndTime") + "'," +
				 		course_id + ",'" + rs.getString("Syllabuses_course_name") + "'," + subject_id +
						",'" + rs.getString("Syllabuses_subject_name") + "'," + rs.getInt("Syllabuses_activity_id") + ",'" + rs.getString("Syllabuses_activity_name") + "','" + 
				 		rs.getString("Syllabuses_Department") + "','" + rs.getString("Syllabuses_teacher_id") + "','" + rs.getString("Syllabuses_teacher_name") + "'," + 
						rs.getInt("Syllabuses_ClassRoom_id") + ",'" + rs.getString("Syllabuses_ClassRoom") + "','" + rs.getString("Syllabuses_bak") +
						"','" + rs.getString("AssistMan") + "','" + rs.getString("AssistInfo") + "'," + Syllabuses_id + ")";
				}
				else
				{
					sql = "update CPB_Syllabuses set Syllabuses_date='" + rs.getString("Syllabuses_date") + "', BeginTime='" + rs.getString("BeginTime") + 
						"', EndTime='" + rs.getString("EndTime") + "', Syllabuses_course_id=" + course_id + ",Syllabuses_course_name='" +
						rs.getString("Syllabuses_course_name") + "', Syllabuses_subject_id=" + subject_id + ",Syllabuses_subject_name='" +
						rs.getString("Syllabuses_subject_name") + "', Syllabuses_activity_id=" + rs.getInt("Syllabuses_activity_id") +", Syllabuses_activity_name='" +
						rs.getString("Syllabuses_activity_name") + "',Syllabuses_Department='" + rs.getString("Syllabuses_Department") + "', Syllabuses_teacher_id='" + 
						rs.getString("Syllabuses_teacher_id") + "', Syllabuses_teacher_name='" + rs.getString("Syllabuses_teacher_name") + "',Syllabuses_ClassRoom_id=" + 
						rs.getInt("Syllabuses_ClassRoom_id") + ", Syllabuses_ClassRoom='" + rs.getString("Syllabuses_ClassRoom") + "',Syllabuses_bak='" + 
						rs.getString("Syllabuses_bak") + "',AssistMan='" + rs.getString("AssistMan") + "', AssistInfo='" + rs.getString("AssistInfo") +
						"',RefID=" +  Syllabuses_id + " where Syllabuses_id=" + id;
				}
				int result = jdb.ExecuteSQL(0, sql);
			}
			rs1.close();
			int course_id = rs.getInt("Syllabuses_course_id");
			if (course_id > 0)
				jdb.ExecuteSQL(0, "update CPB_Course set Big_Course=1 where Course_id=" + course_id);
		}
		rs.close();
		out.print("公共课程已经在如下班级生效：\n" +log);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "SaveCourse") > 0)
	{
		int term_id = WebChar.RequestInt(request, "term_id");
		int num = WebChar.RequestInt(request, "Num");
		String sql, DeleteIDs = WebChar.requestStr(request, "DeleteIDs");
		int result;
		if (!DeleteIDs.equals(""))
		{
			ResultSet rs = jdb.rsSQL(0, "select * from CPB_Syllabuses where Syllabuses_id in (" + DeleteIDs + ")");
			while (rs.next())
			{
				String Syllabuses_id = rs.getString("Syllabuses_id");
				String log = "课程名称:" + rs.getString("Syllabuses_subject_name") + ", 授课人:" + rs.getString("Syllabuses_teacher_name") +
					", 时间:" + VB.dateCStr(rs.getTimestamp("BeginTime"), "yyyy-MM-dd HH:mm") + "-" + VB.dateCStr(rs.getTimestamp("EndTime"), "HH:mm") + ", 地点:" + rs.getString("Syllabuses_ClassRoom");
			 	SystemLog.setLog(jdb, user, request, "6", "【删除课表记录】" + log, "ClassID:" + ClassID, Syllabuses_id);
			}
			rs.close();
			result = jdb.ExecuteSQL(0, "delete from CPB_Syllabuses where Syllabuses_id in (" + DeleteIDs + ")");
		}
		String jsonResult = "";
		for (int x = 0; x < num; x++)
		{
			int index = WebChar.ToInt(WebChar.RequestForms(request, "index", x));
			int Syllabuses_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_id", x));
			String Syllabuses_date = WebChar.RequestForms(request, "Syllabuses_date", x);
			String BeginTime = WebChar.RequestForms(request, "BeginTime", x);
			String EndTime = WebChar.RequestForms(request, "EndTime", x);
			String Syllabuses_AP = getDateAP(BeginTime);
			int Syllabuses_course_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_course_id", x));
			int Syllabuses_subject_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_subject_id", x));
			String Syllabuses_subject_name = WebChar.GetAjaxPostData(request, "Syllabuses_subject_name", x);
			int Syllabuses_activity_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_activity_id", x));
			String Syllabuses_activity_name = WebChar.GetAjaxPostData(request, "Syllabuses_activity_name", x);
			String Syllabuses_Department = WebChar.GetAjaxPostData(request, "Syllabuses_Department", x);
			String Syllabuses_teacher_id = WebChar.GetAjaxPostData(request, "Syllabuses_teacher_id", x);
			String Syllabuses_teacher_name = WebChar.GetAjaxPostData(request, "Syllabuses_teacher_name", x);
			int Syllabuses_ClassRoom_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_ClassRoom_id", x));
			String Syllabuses_ClassRoom = WebChar.GetAjaxPostData(request, "Syllabuses_ClassRoom", x);
			String Syllabuses_bak = WebChar.GetAjaxPostData(request, "Syllabuses_bak", x);
			String AssistMan = WebChar.GetAjaxPostData(request, "AssistMan", x);
			String AssistInfo = WebChar.GetAjaxPostData(request, "AssistInfo", x);
			String Syllabuses_course_name = Syllabuses_subject_name;
			if (Syllabuses_course_name.equals(""))
				Syllabuses_course_name = Syllabuses_activity_name;
			int RefID = WebChar.ToInt(WebChar.RequestForms(request, "RefID", x));
			if (Syllabuses_id == 0)
			{
					String log = "课程名称:" + Syllabuses_subject_name + ", 授课人:" + Syllabuses_teacher_name +
					", 时间:" + VB.dateCStr(VB.CDate(BeginTime), "yyyy-MM-dd HH:mm") + "-" +  VB.dateCStr(VB.CDate(EndTime), "HH:mm") + ", 地点:" + Syllabuses_ClassRoom;
				 	SystemLog.setLog(jdb, user, request, "6", "【新增课表记录】" + log, "ClassID:" + ClassID, "");

				 	sql = "insert into CPB_Syllabuses (term_id, class_id, Syllabuses_date, Syllabuses_AP,BeginTime, EndTime, Syllabuses_course_id,Syllabuses_course_name," +
						"Syllabuses_subject_id, Syllabuses_subject_name, Syllabuses_activity_id, Syllabuses_activity_name, Syllabuses_Department, Syllabuses_teacher_id, " +
				 		"Syllabuses_teacher_name, Syllabuses_ClassRoom_id, Syllabuses_ClassRoom, Syllabuses_bak, AssistMan, AssistInfo) values(" + term_id + "," + ClassID + ",'" + 
						Syllabuses_date + "','" + Syllabuses_AP + "','" +BeginTime + "','" + EndTime + "'," + Syllabuses_course_id + ",'" + Syllabuses_course_name + "'," +
				 		Syllabuses_subject_id + ",'" + Syllabuses_subject_name + "'," + Syllabuses_activity_id + ",'" + Syllabuses_activity_name + "','" + Syllabuses_Department +
				 		"','" + Syllabuses_teacher_id + "','" + Syllabuses_teacher_name + "'," + Syllabuses_ClassRoom_id + ",'" + Syllabuses_ClassRoom + "','" + Syllabuses_bak +
						"','" + AssistMan + "','" + AssistInfo + "')";
					result  = jdb.ExecuteSQL(0, sql);
			 		Syllabuses_id = WebChar.ToInt(jdb.getValueBySql(0, "select top 1 Syllabuses_id from CPB_Syllabuses where class_id=" + ClassID + " and BeginTime='" + BeginTime +
				 			"' and EndTime='" + EndTime + "' and Syllabuses_course_id=" + Syllabuses_course_id + " and Syllabuses_subject_id=" + Syllabuses_subject_id +
				 			" and Syllabuses_activity_id=" + Syllabuses_activity_id + " and Syllabuses_teacher_id='" + Syllabuses_teacher_id + "' and Syllabuses_ClassRoom_id=" +
				 			Syllabuses_ClassRoom_id + " and Syllabuses_teacher_name='" + Syllabuses_teacher_name + "' and Syllabuses_ClassRoom='" + Syllabuses_ClassRoom + "'"));
				 	if (Syllabuses_course_id > 0)
				 	{
				 		ResultSet rs = jdb.rsSQL(0, "select Course_id, class_id from CPB_Course where RefID=" + Syllabuses_course_id);
				 		int refcnt = 0;
				 		while (rs.next())
				 		{
				 			if (rs.getInt("class_id") != ClassID)
				 			{
								sql = "insert into CPB_Syllabuses (term_id, class_id, Syllabuses_date, Syllabuses_AP, BeginTime, EndTime, Syllabuses_course_id,Syllabuses_course_name," +
									"Syllabuses_subject_id, Syllabuses_subject_name, Syllabuses_activity_id, Syllabuses_activity_name, Syllabuses_Department, Syllabuses_teacher_id, " +
									"Syllabuses_teacher_name, Syllabuses_ClassRoom_id, Syllabuses_ClassRoom, Syllabuses_bak, AssistMan, AssistInfo, RefID) values(" + term_id + "," +
									rs.getInt("class_id") + ",'" + Syllabuses_date + "','" + Syllabuses_AP + "','" + BeginTime + "','" + EndTime + "'," + rs.getInt("Course_id") +
									",'" + Syllabuses_course_name + "'," + Syllabuses_subject_id + ",'" + Syllabuses_subject_name + "'," + Syllabuses_activity_id + ",'" +
									Syllabuses_activity_name + "','" + Syllabuses_Department + "','" + Syllabuses_teacher_id + "','" + Syllabuses_teacher_name + "'," +
									Syllabuses_ClassRoom_id + ",'" + Syllabuses_ClassRoom + "','" + Syllabuses_bak + "','" + AssistMan + "','" + AssistInfo + "'," + Syllabuses_id + ")";
								jdb.ExecuteSQL(0, sql);
								refcnt ++;
				 			}
				 		}
				 		if (refcnt > 0)
				 		{
					 		sql = "update CPB_Syllabuses set RefID=" + Syllabuses_id + " where Syllabuses_id=" + Syllabuses_id;
							jdb.ExecuteSQL(0, sql);
				 		}
				 	}
			}
			else
			{
				ResultSet rs = jdb.rsSQL(0, "select * from CPB_Syllabuses where Syllabuses_id=" + Syllabuses_id);
				if (rs.next())
				{
					String log = "现课程名称:" + Syllabuses_subject_name + ", 现授课人:" + Syllabuses_teacher_name +
					", 现时间:" + VB.dateCStr(VB.CDate(BeginTime), "yyyy-MM-dd HH:mm") + "-" + VB.dateCStr(VB.CDate(EndTime), "HH:mm") + ", 现地点:" + Syllabuses_ClassRoom;
					String logold = "原课程名称:" + rs.getString("Syllabuses_course_name") + ", 原授课人:" + rs.getString("Syllabuses_teacher_name") +
						", 原时间:" + VB.dateCStr(rs.getTimestamp("BeginTime"), "yyyy-MM-dd HH:mm") + "-" + VB.dateCStr(rs.getTimestamp("EndTime"), "HH:mm") + ", 原地点:" + rs.getString("Syllabuses_ClassRoom");
				 	SystemLog.setLog(jdb, user, request, "6", "【修改课表记录】" + log + "<br>\n---------------------------------&nbsp;&nbsp;" + logold, "ClassID:" + ClassID, "" + Syllabuses_id);
				}
				rs.close();
				
					sql = "update CPB_Syllabuses set Syllabuses_date='" + Syllabuses_date + "', Syllabuses_AP='" + Syllabuses_AP + "', BeginTime='" + BeginTime + 
						"', EndTime='" + EndTime + "', Syllabuses_course_id=" + Syllabuses_course_id + ",Syllabuses_course_name='" + Syllabuses_course_name + 
						"', Syllabuses_subject_id=" + Syllabuses_subject_id + ",Syllabuses_subject_name='" + Syllabuses_subject_name + 
						"', Syllabuses_activity_id=" + Syllabuses_activity_id +", Syllabuses_activity_name='" + Syllabuses_activity_name + 
						"',Syllabuses_Department='" + Syllabuses_Department + "', Syllabuses_teacher_id='" + Syllabuses_teacher_id + 
						"', Syllabuses_teacher_name='" + Syllabuses_teacher_name + "',Syllabuses_ClassRoom_id=" + Syllabuses_ClassRoom_id +
						", Syllabuses_ClassRoom='" + Syllabuses_ClassRoom + "',Syllabuses_bak='" + Syllabuses_bak +
						"',AssistMan='" + AssistMan + "', AssistInfo='" + AssistInfo + "' where Syllabuses_id=" + Syllabuses_id;
					result  = jdb.ExecuteSQL(0, sql);
					if (RefID > 0)
					{
						sql = "update CPB_Syllabuses set Syllabuses_date='" + Syllabuses_date + "', Syllabuses_AP='" + Syllabuses_AP + "', BeginTime='" + BeginTime + 
							"', EndTime='" + EndTime + "', Syllabuses_Department='" + Syllabuses_Department + "', Syllabuses_teacher_id='" + Syllabuses_teacher_id + 
							"', Syllabuses_teacher_name='" + Syllabuses_teacher_name + "',Syllabuses_ClassRoom_id=" + Syllabuses_ClassRoom_id +
							", Syllabuses_ClassRoom='" + Syllabuses_ClassRoom + "',Syllabuses_bak='" + Syllabuses_bak +
							"',AssistMan='" + AssistMan + "', AssistInfo='" + AssistInfo + "' where RefID=" + RefID;
						result  = jdb.ExecuteSQL(0, sql);
					}
			}
			if (!jsonResult.equals(""))
				jsonResult += ",";
			jsonResult += "{index:" + index + ", id:" + Syllabuses_id + ", result:" + result + "}";
		}
		String b = jdb.GetTableValue(0, "CPB_Class", "Class_BeginTime", "Class_id", "" + ClassID);
		String e =  jdb.GetTableValue(0, "CPB_Class", "Class_EndTime", "Class_id", "" + ClassID);
		e = VB.DateAdd("d", 1, e);	//多加一天		
		String ConflictJSON = getCheckCourseResult(jdb, ClassID, 2, 0, b, e);		
		out.print("{SaveResult:[" + jsonResult + "], Conflict:" + ConflictJSON + "}");
		jdb.closeDBCon();
		return;
	}
%>