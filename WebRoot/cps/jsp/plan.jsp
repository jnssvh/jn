<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
//@@##345:后台用户自定义声明代码(归档用注释,切勿删改)
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
  
  String sql = "update UserReportDetail set Value='" + value + "' where EName='" + EName +  "' and CName='" + CName + "' and ParentID=" + DataID;
  int result = jdb.ExecuteSQL(0, sql);
  if (result == 0)
  {
    sql = "insert UserReportDetail (EName, CName, Value, ParentID) values('" + EName + "','" + CName + "','" + value + "'," + DataID + ")";
    result  = jdb.ExecuteSQL(0, sql);
  }
	 return "OK";
}
private int SaveCourseItem(JDatabase jdb, int Term_id, int Class_id, int index, int Mode_id, int Course_id, int Subject_id, int Style_id, String Course_name,
	String Teacher_id, String Teacher_name, String Department, String Course_time, String Note, int RefID, int Course_state)  throws SQLException
{
	String sql;
	int OldRefID = 0, RefCourseID = 0, result;
	if (RefID == -1)	//保存公共课程前，检查同名的公共课程是否存在
		RefCourseID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Course", "Course_id", "term_id", Term_id + " and Course_name='" + Course_name +
			"' and Course_id<>" + Course_id + " and RefID>0"));
	if (Course_id == 0)
	{
		sql = "insert into CPB_Course(Subject_id, term_id, Mode_id, Style_id, class_id, Course_name, Teacher_id, Teacher_name, Note, Department, Course_time, RefID, Course_state, nOrder) values(" +
			Subject_id + "," + Term_id + "," + Mode_id + "," + Style_id + "," + Class_id + ",'" + Course_name + "','" + Teacher_id + "','" +
			Teacher_name + "','" + Note + "','" + Department + "'," + Course_time + "," + RefID + "," + Course_state + "," + index + ")";
		result = jdb.ExecuteSQL(0, sql);
		Course_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Course", "Course_id", "class_id", Class_id + " and Mode_id=" + Mode_id +
				" and Course_name='" + Course_name + "' and Subject_id=" + Subject_id + " and nOrder=" + index));
		if (RefID == -1)
		{
			if (RefCourseID == 0)
				RefCourseID = Course_id;
			sql = "update CPB_Course set RefID=" + RefCourseID + " where Course_id=" + Course_id;
			result = jdb.ExecuteSQL(0, sql);
			OldRefID = Course_id;
		}
	}
	else
	{
		if (RefID <= 0)
		{
			sql = "update CPB_Course set Subject_id=" + Subject_id + ", Mode_id=" + Mode_id + ", Style_id=" + Style_id + ", Course_name='" + Course_name +
				"', Teacher_id='" + Teacher_id + "', Teacher_name='" + Teacher_name + "', Note='" + Note + "', Department='" + Department +
				"', Course_time=" + Course_time + ", Course_state=" + Course_state + ", nOrder=" + index + " where Course_id=" + Course_id;
			result = jdb.ExecuteSQL(0, sql);
			if (RefID == -1)
			{
				OldRefID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Course", "RefID", "Course_id", "" + Course_id));
				if (OldRefID > 0)
				{
					sql = "update CPB_Course set Subject_id=" + Subject_id + ", Style_id=" + Style_id + ", Course_name='" + Course_name +
						"', Teacher_id='" + Teacher_id + "', Teacher_name='" + Teacher_name + "', Note='" + Note + "', Department='" + Department +
						"', Course_time=" + Course_time + ", Course_state=" + Course_state + " where term_id=" + Term_id + " and RefID=" + OldRefID;
					result = jdb.ExecuteSQL(0, sql);
				}
				else
				{
					if (RefCourseID == 0)
						RefCourseID = Course_id;
					sql = "update CPB_Course set RefID=" + RefCourseID + " where Course_id=" + Course_id;
					result = jdb.ExecuteSQL(0, sql);					
				}
			}
		}
		else
		{
			sql = "update CPB_Course set Course_state=" + Course_state + ", nOrder=" + index + " where Course_id=" + Course_id;
			result = jdb.ExecuteSQL(0, sql);
		}
	}
	
	if (RefID < 0)		//选修课
	{
		String [] items = Note.split("\\|");
		if (items.length == 2)
		{
			int RoomID = WebChar.ToInt(jdb.GetTableValue(0, "Place", "ID", "Name", "'" + items[1] + "'"));
			String AP = getDateAP(items[0]);
			String EndTime = VB.DateAdd("h", 2, items[0]);

			ResultSet rs = jdb.rsSQL(0, "select Course_id, class_id from CPB_Course where RefID=" + OldRefID);
			while (rs.next())
			{
				int Syllabuses_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Syllabuses", "Syllabuses_id", "Syllabuses_course_id", "" + rs.getInt("Course_id") + " and nType=2"));
				if (Syllabuses_id == 0)
					sql = "insert into CPB_Syllabuses(term_id, class_id, nType, Syllabuses_subject_id, Syllabuses_course_id," +
						"Syllabuses_course_name, Syllabuses_teacher_id, Syllabuses_teacher_name, Syllabuses_ClassRoom_id," +
						"Syllabuses_ClassRoom, Syllabuses_date, BeginTime, EndTime, Syllabuses_AP) values(" +
						Term_id + "," + rs.getInt("class_id") + ",2," + Subject_id + "," + OldRefID + ",'" + Course_name + "','" + 
						Teacher_id + "','" + Teacher_name + "'," + RoomID + ",'" + items[1] + "','" +
						items[0] + "','" + items[0] + "','" + EndTime + "','" + AP + "')";
				else
					sql = "update CPB_Syllabuses set Syllabuses_subject_id=" + Subject_id + ", Syllabuses_course_id=" + rs.getInt("Course_id") + ", Syllabuses_course_name='" +
						Course_name + "', Syllabuses_teacher_id='" + Teacher_id + "', Syllabuses_teacher_name='" + Teacher_name + "', Syllabuses_ClassRoom_id=" +
						RoomID + ", Syllabuses_ClassRoom='" + items[1] + "', Syllabuses_date='" + items[0] + "', BeginTime='" + items[0] + "', EndTime='" +
						EndTime + "', Syllabuses_AP='" + AP + "' where Syllabuses_id=" + Syllabuses_id;
				result = jdb.ExecuteSQL(0, sql);
			}
/*			
			int FreeID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Syllabuses_free", "Syllabuses_free_id", "Syllabuses_free_course_id", "" + OldRefID));			
			if (FreeID == 0)
				sql = "insert into CPB_Syllabuses_free(term_id, Syllabuses_type, Syllabuses_free_subject_id, Syllabuses_free_course_id," +
					"Syllabuses_free_course_name, Syllabuses_free_teacher_id, Syllabuses_free_teacher_name, Syllabuses_free_ClassRoom_id," +
					"Syllabuses_free_ClassRoom_name, Syllabuses_free_date, BeginTime, EndTime, Syllabuses_free_ap) values(" +
						Term_id + ",1," + Subject_id + "," + OldRefID + ",'" + Course_name + "','" + Teacher_id + "','" + Teacher_name + "'," + RoomID + ",'" + items[1] + "','" +
						items[0] + "','" + items[0] + "','" + EndTime + "','" + AP + "')";
			else
				sql = "update CPB_Syllabuses_free set Syllabuses_free_subject_id=" + Subject_id + ", Syllabuses_free_course_id=" + OldRefID + ", Syllabuses_free_course_name='" +
					Course_name + "', Syllabuses_free_teacher_id='" + Teacher_id + "', Syllabuses_free_teacher_name='" + Teacher_name + "', Syllabuses_free_ClassRoom_id=" +
					RoomID + ", Syllabuses_free_ClassRoom_name='" + items[1] + "', Syllabuses_free_date='" + items[0] + "', BeginTime='" + items[0] + "', EndTime='" +
					EndTime + "', Syllabuses_free_ap='" + AP + "' where Syllabuses_free_id=" + FreeID;
			result = jdb.ExecuteSQL(0, sql);
*/
		}
	}
	
	if (!Department.equals("") && (Subject_id>0) && (WebChar.ToInt(Teacher_id)>0))
	{
		sql = "select Subject_id from CPB_Subject where Subject_id=" + Subject_id + " and (Department_name='' or Department_name='null' or Department_name is null)";
		ResultSet rs = jdb.rsSQL(0, sql);
		if (rs.next())
		{
			sql = "update CPB_Subject set Department_name='" + Department + "' where Subject_id=" + Subject_id;
			result = jdb.ExecuteSQL(0, sql);
			
		}
		sql = "select Teacher_id from CPB_Teacher where Teacher_id=" + Teacher_id + " and (DeptName='' or DeptName='null' or DeptName is null)";
		rs = jdb.rsSQL(0, sql);
		if (rs.next())
		{
			sql = "update CPB_Teacher set DeptName='" + Department + "' where Teacher_id=" + Teacher_id;
			result = jdb.ExecuteSQL(0, sql);						
		}
	}
	
	return Course_id;
}

private int SaveModeItem(JDatabase jdb, int Term_id, int Class_id, int index, int Mode_id, String Mode_Name, String Mode_other, double Mode_time,
	int ParentNode, int RefID)  throws SQLException
{
	String sql;
	int result, RefModeID = 0;
	if (RefID == -1)	//保存公共单元前，检查同名的公共单元是否存在
		RefModeID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Mode", "Mode_id", "Term_id", Term_id + " and Mode_Name='" + Mode_Name +
				"' and Mode_id<>" + Mode_id + " and RefID>0"));
	if (Mode_id == 0)
	{
		sql = "insert into CPB_Mode(Term_id, Class_id, Mode_Name, Mode_order, RefID, Mode_other, ParentNode, Mode_time) values(" +
			Term_id + "," + Class_id + ",'" + Mode_Name + "'," + index + "," + RefID + ",'" + Mode_other + "'," + ParentNode + "," + Mode_time + ")";
		result = jdb.ExecuteSQL(0, sql);
		Mode_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Mode", "Mode_id", "Mode_Name", "'" + Mode_Name + "' and Class_id='" + Class_id + "' and Mode_order=" + index));
		if (RefID == -1)
		{
			if (RefModeID == 0)
				RefModeID = Mode_id;
			sql = "update CPB_Mode set RefID=" + RefModeID + " where Mode_id=" + Mode_id;
			result = jdb.ExecuteSQL(0, sql);			
		}
	}
	else
	{
		if (RefID <= 0)
		{
			sql = "update CPB_Mode set Mode_Name='" + Mode_Name + "', ParentNode=" + ParentNode + ", Mode_other='" + Mode_other + 
				"', Mode_order=" + index + ",Mode_time=" + Mode_time + " where Mode_id=" + Mode_id + " and Term_id=" + Term_id;
			result = jdb.ExecuteSQL(0, sql);
			if (RefID == -1)
			{
				int OldRefID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Mode", "RefID", "Mode_id", "" + Mode_id));
				if (OldRefID > 0)
				{
					sql = "update CPB_Mode set Mode_Name='" + Mode_Name + "', Mode_other='" + Mode_other + 
						"',Mode_time=" + Mode_time + " where RefID=" + OldRefID + " and Term_id=" + Term_id;
					result = jdb.ExecuteSQL(0, sql);
				}
				else
				{
					if (RefModeID == 0)
						RefModeID = Mode_id;					
					sql = "update CPB_Mode set RefID=" + RefModeID + " where Mode_id=" + Mode_id;
					result = jdb.ExecuteSQL(0, sql);					
				}
			}
		}
		else
		{
			sql = "update CPB_Mode set Mode_order=" + index + " where Mode_id=" + Mode_id;
			result = jdb.ExecuteSQL(0, sql);
		}
	}
	return Mode_id;
}

private int SaveFreeSyllabuses(JDatabase jdb, int Term_id, int Class_id, String BeginTime, String EndTime, String FreeIds)  throws SQLException
{
	int ActID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Activity", "Activity_id", "Activity_name", "'选修课' and (Term_id=0 or Term_id is null)"));
	String sql, AP = getDateAP(BeginTime);
	int Syllabuses_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Syllabuses", "Syllabuses_id", "FreeIDs", 
		"'" + FreeIds + "' and class_id=" + Class_id + "and Syllabuses_subject_name='上次从教学计划自动转换的选修课'"));
	if (Syllabuses_id == 0)
	 	sql = "insert into CPB_Syllabuses (term_id, class_id, Syllabuses_date, Syllabuses_AP, BeginTime, EndTime, Syllabuses_course_id,Syllabuses_course_name," +
			"Syllabuses_subject_id, Syllabuses_subject_name, Syllabuses_activity_id, Syllabuses_activity_name, FreeIDs) values(" + Term_id + "," + Class_id + ",'" + 
			BeginTime + "','" + AP + "','" + BeginTime + "','" + EndTime + "',0,'选修课',0,'从教学计划自动转换的选修课'," + ActID + ",'选修课', '" + FreeIds + "')";
	else
	 	sql = "update CPB_Syllabuses set term_id=" + Term_id + ", class_id=" + Class_id + ", Syllabuses_date='" + BeginTime + "', Syllabuses_AP='" + AP +
	 		"', BeginTime='" + BeginTime + "', EndTime='" + EndTime + "', Syllabuses_course_id=0,Syllabuses_course_name='选修课'," +				
			"Syllabuses_subject_id=0, Syllabuses_subject_name='从教学计划自动转换的选修课', Syllabuses_activity_id=" + ActID + ", Syllabuses_activity_name='选修课', FreeIDs='" + 
	 		FreeIds + "' where Syllabuses_id=" + Syllabuses_id;
	return jdb.ExecuteSQL(0, sql);
}
private String getPlanOptions(SysApp sysApp)
{
	return "{CourseShowMode: " +  sysApp.getSysParam(5, "PlanCourseShowMode", "教学计划课程显示结构", "1") +
		", CourseNoMode:" + sysApp.getSysParam(5, "PlanCourseNoMode", "教学计划课程序号编排方式", "1") +
		", CourseNameMode:" + sysApp.getSysParam(5, "PlanCourseNameMode", "教学计划课程名称显示方式", "0") +
		", TeacherShowMode:" + sysApp.getSysParam(5, "PlanTeacherShowMode", "教学计划本校授课人显示方式", "0") +
		", OuterTeacherShowMode:" + sysApp.getSysParam(5, "PlanOuterTeacherShowMode", "教学计划外请授课人显示方式", "0") +
		", CourseNameEditEnable:" + sysApp.getSysParam(5, "PlanCourseNameEditEnable", "教学计划编辑课程名称允许", "2") +
		", CourseTimeEnable:" + sysApp.getSysParam(5, "PlanCourseTimeEnable", "教学计划课程时长显示编辑允许", "0") +
		", TeacherEditEnable:" + sysApp.getSysParam(5, "PlanTeacherEditEnable", "教学计划编辑授课人允许", "0") +
		", TeacherUnitEditEnable:" + sysApp.getSysParam(5, "PlanTeacherUnitEditEnable", "教学计划编辑授课人单位允许", "0") +
		", CourseLayerMode:" + sysApp.getSysParam(5, "PlanCourseLayerMode", "教学计划课程排版方式", "1") +
		", CourseFreeInfo:" + sysApp.getSysParam(5, "PlanCourseFreeInfo", "教学计划选修课显示内容", "1") +
		", ActivityMode:" + sysApp.getSysParam(5, "PlanActivityMode", "教学计划教学活动处理方式", "1") +
		", CourseShowRed:" + sysApp.getSysParam(5, "PlanCourseShowRed", "标红非专题库中的课程 ", "1") +
		", CommonUnitCourseEditEnable:" + sysApp.getSysParam(5, "PlanCommonUnitCourseEditEnable", "编辑公共单元与课程 ", "0") + "}";
}

//(归档用注释,切勿删改)后台用户自定义声明代码 End##@@
%>
<%
String rs_TrainBook="", rs_Class_id="", rs_Term_id="", rs_Class_Name="", rs_Class_BeginTime="", rs_Class_EndTime="", rs_Class_order="", rs_ClassRoom_id="", rs_Mode_ids="", rs_cname="", rs_teacher_ids="", rs_ClassCode="", rs_Department_level="", rs_train_goal="", rs_train_object="", rs_train_address="", rs_train_content="", rs_train_style="", rs_train_claim="", rs_classmates="", rs_TrainUnit="", rs_OuterArea="", rs_OuterDays="", rs_OuterBegin="", rs_OuterEnd="", rs_TrainLeader="", rs_CourseList="", rs_BECourse="", rs_Books="", rs_PlanNote="", rs_PlanPara1="";
String strTable = "CPB_Class";
String sql = "";
	int FormType = 4;
	String DataID = WebChar.requestStr(request, "DataID");
	int ModuleNo = WebChar.ToInt(request.getParameter("ModuleNo"));
	int Count = 1;
// +++++++++服务器全局页面启动代码开始++++++++
// ServerPageStartCode
if(request.getProtocol().compareTo("HTTP/1.0")==0)
	response.setHeader("Pragma","max-age=5");
if(request.getProtocol().compareTo("HTTP/1.1")==0)
	response.setHeader("Cache-Control","max-age=5");
response.setDateHeader("Expires",0);
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();

	if (user.initWebUser(jdb, cookie) != 1)
	{
		ServletContext sc = getServletContext();
		request.setAttribute("pagename", SysApp.scriptName(request));
		RequestDispatcher rd = sc.getRequestDispatcher("/com/error.jsp");
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		return;
	}

	WebEnum webenum = new WebEnum(jdb);
	SysApp sysApp = new SysApp(jdb);
	project.SystemLog sysLog = new project.SystemLog(jdb, user, request);
// --------服务器全局页面启动代码结束--------
	String FormTitle = "教学计划编辑";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "教学计划编辑";
		String ex = "";
		ex = "{x:0,y:32,node:1,a:{},b:{}}";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"征订教材\", EName:\"TrainBook\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:250, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级编号\", EName:\"Class_id\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:5,FieldLen:4, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"学期编号\", EName:\"Term_id\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"CPB_Term.Term_id,Term_Name\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级名称\", EName:\"Class_Name\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"开始时间\", EName:\"Class_BeginTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"&d:1\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"结束时间\", EName:\"Class_EndTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"&d:1\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"排序\", EName:\"Class_order\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"教室\", EName:\"ClassRoom_id\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"Place.ID,Name\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"模块编号\", EName:\"Mode_ids\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级别名\", EName:\"cname\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"组织员编号\", EName:\"teacher_ids\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"+Member.ID,CName\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级编码\", EName:\"ClassCode\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:8, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"部门级别\", EName:\"Department_level\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训目的\", EName:\"train_goal\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训对象\", EName:\"train_object\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:14, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训地点\", EName:\"train_address\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训内容\", EName:\"train_content\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训方式\", EName:\"train_style\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:17, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训要求\", EName:\"train_claim\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:18, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"计划培训人数\", EName:\"classmates\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:19, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"主办承办单位\", EName:\"TrainUnit\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:20, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学地点\", EName:\"OuterArea\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:21, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学天数\", EName:\"OuterDays\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:22, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学开始时间\", EName:\"OuterBegin\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"\", nCol:1, nRow:23, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学结束时间\", EName:\"OuterEnd\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"\", nCol:1, nRow:24, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"项目负责人编号\", EName:\"TrainLeader\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"+Member.ID,CName\", nCol:1, nRow:25, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"课程列表\", EName:\"CourseList\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"开班式和结业式\", EName:\"BECourse\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"学习参考书目\", EName:\"Books\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"其它\", EName:\"PlanNote\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:28, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"教学计划实施\", EName:\"PlanPara1\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:28, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='CPB_Class_Course'"));
	String FormBar = FormTitle;
	String FlowInput = WebChar.getReqAttrib(request, "I_FlowInput");
	String FlowButton = WebChar.getReqAttrib(request, "I_FlowButton");
	String FlowAttach = WebChar.getReqAttrib(request, "I_FlowAttach");
	int RunMode = WebChar.ToInt(WebChar.getReqAttrib(request, "I_RunMode"));
	String FlowTitle = WebChar.getReqAttrib(request, "I_FlowTitle");
	String FlowBar = WebChar.getReqAttrib(request, "I_FlowBar");
	if (!FlowAttach.equals(""))
		FlowAttach = "<div id=FlowAttach>" + FlowAttach + "</div>";
	if (!FlowTitle.equals(""))
		FormTitle = FlowTitle + "(" + FormTitle + ")";
	if (FlowBar.equals(""))
		FormBar = "<div id=UserFormHeadDiv class=jformtitle2>&nbsp;&nbsp;" + FormTitle + "</div>";
	else
		FormBar = FlowBar;

//@@##323:后台载入时用户自定义代码(归档用注释,切勿删改)
//load from server
/*临时代码，已作废。
	{
		ResultSet rs = jdb.rsSQL(0, "select * from CPB_Course where Teacher_id>0 and Teacher_name=''");
		while (rs.next())
		{
			String Teacher_name = jdb.GetTableValue(0, "CPB_Teacher", "Teacher_name", "Teacher_id", rs.getString("Teacher_id"));
			sql = "update CPB_Course set Teacher_name='" + Teacher_name + "' where Course_id=" + rs.getString("Course_id");
			int v = jdb.ExecuteSQL(0, sql);
		}
		rs.close();
	}
*/	
//test
	if (WebChar.RequestInt(request, "SearchSubject") > 0)
	{
		String key = WebChar.requestStr(request, "SeekKey");
		String Data = jdb.getJsonBySql(0, "select top 500 Subject_id, Subject_name, Informant_id, Informant_name, Teacher_id, Teacher_name, Department_name from CPB_Subject where Subject_name like '%"
			+ key + "%' or Informant_name like '%" + key + "%' or Teacher_name like '%" + key + "%' or Department_name like '%" + key + "%' order by Subject_name");
		out.print(Data);
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "FindSubjectByName") > 0)
	{
		String Subject_name =  WebChar.requestStr(request, "Subject_name");
		String Teacher_name =  WebChar.requestStr(request, "Teacher_name");
		int SubjectID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Course", "Subject_id", "Course_name", "'" + Subject_name + "' and Teacher_name='" + 
			Teacher_name + "' order by Subject_id desc"));
		if (SubjectID == 0)
			SubjectID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Subject", "Subject_id", "Subject_name", "'" + Subject_name + "' and (Teacher_name='"
				+ Teacher_name + "' or Informant_name='" + Teacher_name + "') order by Subject_id desc"));
		out.print(SubjectID);
		jdb.closeDBCon();
		return;		
	}
	if (WebChar.RequestInt(request, "RemoveCourseRef") > 0)
	{
		int CourseID = WebChar.RequestInt(request, "CourseID");
		sql = "update CPB_Course set RefID=0 where RefID=" + CourseID;
		int result = jdb.ExecuteSQL(0, sql);
		out.print(result);
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SaveCourseToSubject") > 0)
	{
		int Subject_id = WebChar.RequestInt(request, "Subject_id");
		String Subject_name =  WebChar.requestStr(request, "Subject_name");
		String Teacher_name =  WebChar.requestStr(request, "Teacher_name");
		String Department =  WebChar.requestStr(request, "Department");
		String t = VB.Now();
		if (Subject_id > 0)
		{
			sql = "update CPB_Subject set Subject_name='" + Subject_name + "', informant_name='" + Teacher_name + "', Teacher_name='" + Teacher_name +
				"', Department_name='" + Department + "', SubmitMan='" + user.CMemberName + "', Frist_time='" + t + "' where Subject_id=" + Subject_id;
			jdb.ExecuteSQL(0, sql);
		}
		else
		{
			sql = "insert into CPB_Subject (Subject_name, informant_name, Department_name, Teacher_name, SubmitMan, Frist_time) values('" + Subject_name + "','" + 
					Teacher_name + "','" + Department + "','" + Teacher_name + "','" + user.CMemberName + "','" + t + "')";
			jdb.ExecuteSQL(0, sql);
			Subject_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Subject", "Subject_id", "Subject_name", "'" + Subject_name + "' and informant_name='" + Teacher_name +
				"' and SubmitMan='" + user.CMemberName + "' and Frist_time='" + t +"'")); 
		}
		out.print(Subject_id);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "OutHTMLToServer") == 1)
	{
		int AffixID = WebChar.RequestInt(request, "AffixID");
		String AffixName = WebChar.requestStr(request, "AffixName");
		String docid = jdb.GetTableValue(0, "CPT_TeachDoc", "ID", "ClassID", DataID + " and nTPLID in (select ID from CPT_DocTpl where AttribName='JXJH')");
		sql = "insert into CPT_TeachDocItem(Title, SubmitMan, SubmitTime, ClassID, TeachDocID, AffixID) values('" +
			AffixName + "','" + user.CMemberName + "','" + VB.Now() + "'," + DataID + "," + docid + "," + AffixID + ")";
		jdb.ExecuteSQL(0, sql);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}

	int Class_id = WebChar.RequestInt(request, "ClassID");
	if (WebChar.RequestInt(request, "CopyfromSyllabuses") == 1)
	{
		if (Class_id == 0)
			Class_id = WebChar.ToInt(DataID);
//		ResultSet rs = jdb.rsSQL(0, "select * from CPB_Syllabuses where class_id=" + Class_id + " and Syllabuses_subject_id>0");
		ResultSet rs = jdb.rsSQL(0, "select * from CPB_Syllabuses where class_id=" + Class_id);
		int result;
		int term_id = jdb.getIntBySql(0, "select Term_id from CPB_Class where Class_id=" + Class_id);
		int Mode_id = jdb.getIntBySql(0, "select top 1 Mode_id from CPB_Mode where Class_id=" + Class_id + " order by Mode_order");
		result = jdb.ExecuteSQL(0, "update CPB_Course set Course_authorization='99' where class_id=" + Class_id + " and (nOrder=0 or nOrder is null)");
		while (rs.next())
		{
			int Syllabuses_id = rs.getInt("Syllabuses_id");
			int Syllabuses_subject_id = rs.getInt("Syllabuses_subject_id");
			String Syllabuses_subject_name = rs.getString("Syllabuses_subject_name");
			int Course_id = jdb.getIntBySql(0, "select Course_id from CPB_Course where class_id=" + Class_id + " and ((Subject_id=" + Syllabuses_subject_id +
				" and Subject_id>0) or (Subject_id=0 and Course_name='" + Syllabuses_subject_name + "'))");
			if (Course_id == 0)
			{
				sql = "insert into CPB_Course(Subject_id, term_id, Mode_id, Style_id, class_id, Course_name, Teacher_id, Teacher_name, Course_authorization) values("
					+ rs.getInt("Syllabuses_subject_id") + "," + term_id + "," + Mode_id + ",0," + Class_id + ",'" + Syllabuses_subject_name +
					"','" + rs.getString("Syllabuses_teacher_id") + "','" + rs.getString("Syllabuses_teacher_name") + "', '')";
				result = jdb.ExecuteSQL(0, sql);
				Course_id = jdb.getIntBySql(0, "select Course_id from CPB_Course where class_id=" + Class_id + " and ((Subject_id=" + Syllabuses_subject_id +
						" and Subject_id>0) or (Subject_id=0 and Course_name='" + Syllabuses_subject_name + "'))");
			}
			else
			{
				sql = "update CPB_Course set Subject_id=" + Syllabuses_subject_id + ", Course_name='" + Syllabuses_subject_name +
						"', Teacher_id='" + rs.getString("Syllabuses_teacher_id") + "', Teacher_name='" + rs.getString("Syllabuses_teacher_name") + 
						"', Course_authorization='' where Course_id=" + Course_id;
				result = jdb.ExecuteSQL(0, sql);				
			}
			String AP = getDateAP(rs.getString("BeginTime"));
			sql = "update CPB_Syllabuses set Syllabuses_course_id=" + Course_id + ", Syllabuses_course_name='" + rs.getString("Syllabuses_subject_name") +
					"', Syllabuses_AP='" + AP + "' where Syllabuses_id=" + Syllabuses_id;//Syllabuses_subject_id=" + Syllabuses_subject_id + " and class_id=" + Class_id;
			result = jdb.ExecuteSQL(0, sql);
			//这条SQL为了与柳州党校的排课表兼容，终将废弃
			sql = "UPDATE CPB_Syllabuses SET Syllabuser_ClassRoom_id=Syllabuses_ClassRoom_id,Syllabuser_ClassRoom=Syllabuses_ClassRoom," +
					"Syllabuser_teacher_name=Syllabuses_teacher_name where Syllabuses_id=" + Syllabuses_id;//Syllabuses_subject_id=" + Syllabuses_subject_id + " and class_id=" + Class_id;;
			result = jdb.ExecuteSQL(0, sql);
		}
		result = jdb.ExecuteSQL(0, "delete from CPB_Course where Course_authorization='99' and Class_id=" + Class_id);
		
		if (WebChar.RequestInt(request, "Ajax") == 1)
			out.print("OK");
		else
			response.sendRedirect("CPB_Class_Course.jsp?EditMode=1&DataID=" + Class_id);
    	jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SaveFlag") == 1)
	{
		int Term_id = WebChar.RequestInt(request, "Term_id");
		Class_id =  WebChar.RequestInt(request, "Class_id");
//		String OuterBegin = jdb.GetValidSQLDateStr(WebChar.RequestForms(request, "OuterBegin", 0), "yyyy-MM-dd");
//		String OuterEnd = jdb.GetValidSQLDateStr(WebChar.RequestForms(request, "OuterEnd", 0), "yyyy-MM-dd");
		String OuterBegin = "null";
		String OuterEnd = "null";
		sql = "update CPB_Class set train_goal='" + WebChar.RequestForms(request, "train_goal", 0) +
			"', train_object='" + WebChar.RequestForms(request, "train_object", 0) +
			"', train_address='" + WebChar.RequestForms(request, "train_address", 0) +
			"', train_content='" + WebChar.RequestForms(request, "train_content", 0) +
			"', train_style='" + WebChar.RequestForms(request, "train_style", 0) +
			"', train_claim='" + WebChar.RequestForms(request, "train_claim", 0) +
			"', classmates=" + WebChar.RequestForms(request, "classmates", 0) +
			", TrainUnit='" + WebChar.RequestForms(request, "TrainUnit", 0) +
			"', Class_BeginTime='" + WebChar.RequestForms(request, "Class_BeginTime", 0) +
			"', Class_EndTime='" + WebChar.RequestForms(request, "Class_EndTime", 0) +
			"', OuterBegin=" + OuterBegin + ", OuterEnd=" + OuterEnd  +
			", OuterArea='" + WebChar.RequestForms(request, "OuterArea", 0) +
			"' where Class_id=" + Class_id;
		int result = jdb.ExecuteSQL(0, sql);

		String Books = WebChar.RequestForms(request, "Books", 0);
		SetClassExValue(jdb, user, Class_id, "Books", "学习参考书目", Books);

		String PlanPara1 = WebChar.RequestForms(request, "PlanPara1", 0);
		SetClassExValue(jdb, user, Class_id, "PlanPara1", "教学计划实施", PlanPara1);
		
		String PlanNote = WebChar.RequestForms(request, "PlanNote", 0);
		SetClassExValue(jdb, user, Class_id, "PlanNote", "其它", PlanNote);
		
		String delModeIds = WebChar.requestStr(request, "delModeIds");
		String delCourseIds = WebChar.requestStr(request, "delCourseIds");
		if (!delModeIds.equals(""))
		{
			result = jdb.ExecuteSQL(0, "delete from CPB_Mode where Mode_id in (" + delModeIds + ") and Class_id='" + Class_id + "'");
			result = jdb.ExecuteSQL(0, "delete from CPB_Mode where RefID in (" + delModeIds + ") and RefID>0 and term_id=" + Term_id);
		}
		if (!delCourseIds.equals(""))
		{
			result = jdb.ExecuteSQL(0, "delete from CPB_Course where Course_id in (" + delCourseIds + ") and class_id=" + Class_id);
			result = jdb.ExecuteSQL(0, "delete from CPB_Course where RefID in (" + delCourseIds + ") and RefID>0 and term_id=" + Term_id);
			result = jdb.ExecuteSQL(0, "delete from CPB_Syllabuses_free where Syllabuses_free_course_id in (" + delCourseIds + ") and term_id=" + Term_id);
		}
		int Modelen = 0, freeflag = 0;
		String tmp[] = request.getParameterValues("Mode_Name");
		if (tmp != null)
			Modelen = tmp.length;
		for (int x = 0; x < Modelen; x++)
		{
			int Mode_id = WebChar.ToInt(WebChar.RequestForms(request, "Mode_id", x));
			String Mode_Name = WebChar.RequestForms(request, "Mode_Name", x);
			int RefID = WebChar.ToInt(WebChar.RequestForms(request, "RefID", x));
			String Mode_other = WebChar.RequestForms(request, "Mode_other", x);
			double Mode_time = WebChar.ToDouble(WebChar.RequestForms(request, "Mode_time", x));
			Mode_id = SaveModeItem(jdb, Term_id, Class_id, x + 1, Mode_id, Mode_Name, Mode_other, Mode_time, 0, RefID);
				
			tmp = request.getParameterValues("Course_name_" + x);
			int Courselen = 0;
			if (tmp != null)
				Courselen = tmp.length;
			for (int y = 0; y < Courselen; y++)
			{
				int Course_id = WebChar.ToInt(WebChar.RequestForms(request, "Course_id_" + x, y));
				int Subject_id = WebChar.ToInt(WebChar.RequestForms(request, "Subject_id_" + x, y));
				int Style_id = WebChar.ToInt(WebChar.RequestForms(request, "Style_id_" + x, y));
				String Course_name = WebChar.RequestForms(request, "Course_name_" + x, y);
				String Teacher_id = WebChar.RequestForms(request, "Teacher_id_" + x, y);
				String Teacher_name = WebChar.RequestForms(request, "Teacher_name_" + x, y);
				String Department = WebChar.RequestForms(request, "Department_" + x, y);
				String Course_time = WebChar.RequestForms(request, "Course_time_" + x, y);
				String Note = WebChar.RequestForms(request, "Note_" + x, y);
				int CourseRefID = WebChar.ToInt(WebChar.RequestForms(request, "RefID_" + x, y));
				int Course_state = WebChar.ToInt(WebChar.RequestForms(request, "Course_state_" + x, y));
				Course_id = SaveCourseItem(jdb, Term_id, Class_id, y + 1, Mode_id, Course_id, Subject_id, Style_id, Course_name,
					Teacher_id, Teacher_name, Department, Course_time, Note, CourseRefID, Course_state);

			}
			if (Mode_other.equals("2"))	//将选修课加入到课表中
				freeflag = 1;
			
			int ChildLen = 0;
			tmp = request.getParameterValues("SubMode_Name_" + x);
			if (tmp != null)
				ChildLen = tmp.length;
		
			for (int y = 0; y < ChildLen; y++)
			{
				int SubMode_id = WebChar.ToInt(WebChar.RequestForms(request, "SubMode_id_" + x, y));
				String SubMode_Name = WebChar.RequestForms(request, "SubMode_Name_" + x, y);
				int SubRefID = WebChar.ToInt(WebChar.RequestForms(request, "RefID_" + x, y));
				SubMode_id = SaveModeItem(jdb, Term_id, Class_id, y + 1, SubMode_id, SubMode_Name, "", 0, Mode_id, SubRefID);

				tmp = request.getParameterValues("Course_name_" + x + "_" + y);
				Courselen = 0;
				if (tmp != null)
					Courselen = tmp.length;
				for (int z = 0; z < Courselen; z++)
				{
					int Course_id = WebChar.ToInt(WebChar.RequestForms(request, "Course_id_" + x + "_" + y, z));
					int Subject_id = WebChar.ToInt(WebChar.RequestForms(request, "Subject_id_" + x + "_" + y, z));
					int Style_id = WebChar.ToInt(WebChar.RequestForms(request, "Style_id_" + x + "_" + y, z));
					String Course_name = WebChar.RequestForms(request, "Course_name_" + x + "_" + y, z);
					String Teacher_id = WebChar.RequestForms(request, "Teacher_id_" + x + "_" + y, z);
					String Teacher_name = WebChar.RequestForms(request, "Teacher_name_" + x + "_" + y, z);
					String Note = WebChar.RequestForms(request, "Note_" + x + "_" + y, z);
					String Department = WebChar.RequestForms(request, "Department_" + x + "_" + y, z);
					String Course_time = WebChar.RequestForms(request, "Course_time_" + x + "_" + y, z);
					int CourseRefID = WebChar.ToInt(WebChar.RequestForms(request, "RefID_" + x + "_" + y, z));
					int Course_state = WebChar.ToInt(WebChar.RequestForms(request, "Course_state_" + x + "_" + y, z));
					
					Course_id = SaveCourseItem(jdb, Term_id, Class_id, z + 1, SubMode_id, Course_id, Subject_id, Style_id, Course_name,
							Teacher_id, Teacher_name, Department, Course_time, Note, CourseRefID, Course_state);
				}
			}
		}
/*
		if (freeflag == 1)	//将选修课加入到课表中
		{
			sql = "update CPB_Syllabuses set Syllabuses_subject_name='上次从教学计划自动转换的选修课' where class_id=" + Class_id + " and Syllabuses_subject_name='从教学计划自动转换的选修课'";
			result = jdb.ExecuteSQL(0, sql);

			String b1 = null, e = "", ids = "";
			sql = "select Syllabuses_free_id, BeginTime,EndTime from CPB_Syllabuses_free where Syllabuses_free_course_id in (select RefID from CPB_Course where class_id=" + Class_id + ") order by BeginTime,Syllabuses_free_id";
			ResultSet rs = jdb.rsSQL(0, sql);
			while (rs.next())
			{
				String b2 = rs.getString("BeginTime");
				int freeid = rs.getInt("Syllabuses_free_id");
				if (b1 == null)
				{
					b1 = b2;
					e = rs.getString("EndTime");
					ids = "" + freeid;
					continue;
				}
				if (b2.equals(b1))
					ids += "," + freeid;
				else
				{
					SaveFreeSyllabuses(jdb, Term_id, Class_id, b1, e, ids);
					b1 = b2;
					e = rs.getString("EndTime");
					ids = "" + freeid;
				}
			}
			if (!ids.equals(""))
				SaveFreeSyllabuses(jdb, Term_id, Class_id, b1, e, ids);
			sql = "delete from CPB_Syllabuses where class_id=" + Class_id + " and Syllabuses_subject_name='上次从教学计划自动转换的选修课'";
			result = jdb.ExecuteSQL(0, sql);			
		}		
*/
		
		for (int x = 0; x < 2; x++)
		{
			int BE_id = WebChar.ToInt(WebChar.RequestForms(request, "BE_id", x));
			String BEname = WebChar.RequestForms(request, "BEname", x);
			String BETime = WebChar.RequestForms(request, "BETime", x);
			String BEaddress = WebChar.RequestForms(request, "BEaddress", x);
			String BEnote = WebChar.RequestForms(request, "BEnote", x);
			String content =  BETime + "|" + BEaddress + "|" + BEnote;
			if ((BE_id == 0) && BEname.equals(""))
				continue;
			if (BE_id == 0)
				sql = "insert into CPB_Course(subject_id, term_id, Mode_id, Style_id, class_id, Course_name, Course_Content, nOrder) values(0, " +
					Term_id + ",0,0," + Class_id + ",'" + BEname + "','" + content + "'," + (x + 1) + ")";
			else
				sql = "update CPB_Course set Course_name='" + BEname + "', Course_Content='" + content + "', nOrder=" + (x + 1) + " where Course_id=" + BE_id;
			result = jdb.ExecuteSQL(0, sql);
		}

		out.print("OK");
		jdb.closeDBCon();
		return;
	}
	int EditMode = WebChar.RequestInt(request, "EditMode");
	if (DataID.equals("") || DataID.equals("0"))
		DataID = "" + Class_id;

	if (WebChar.RequestInt(request, "getClassCourseData") == 1)
	{
		String jsonStyle = jdb.getJsonBySql(0, "select * from CPB_Teach_Style where Term_id=0 order by style_order");
		String Option = jdb.GetTableValue(0, "UserReportDetail", "Value", "EName", "'ClassPlanConfig' and ParentID in (select ID from UserReport where param1=" +
				Class_id + " and TypeName='ClassTeachPlan')");
		if (Option.equals(""))
			Option = getPlanOptions(sysApp);
		String ClassCode = WebChar.requestStr(request, "ClassCode");
		String jsonModeBase = "[]";
		if (ClassCode.length() > 6)
			jsonModeBase = jdb.getJsonBySql(0, "select * from CPB_Mode where Term_id=0 and Class_id='" + ClassCode.substring(4, 5) + "' order by Mode_order");
//		String jsonMode = jdb.getJsonBySql(0, "select * from CPB_Mode where (',' + Class_id + ',' like '%," + DataID + ",%') or (',' + Class_id + ',' like '%, " + DataID + ", %') order by Mode_order");
		String jsonMode = jdb.getTreeJson(0, "CPB_Mode", "Mode_Name", "Mode_id", "ParentNode",  "Class_id, Mode_order, Mode_other, Mode_time, Note, CSS, RefID", 
			"((',' + Class_id + ',' like '%," + DataID + ",%') or (',' + Class_id + ',' like '%, " + DataID + ", %')) order by Mode_order", "0");
	
		String jsonCourse = jdb.getJsonBySql(0, "select Course_id, Subject_id, Mode_id, Style_id, Informant_id, Informant_name, Teacher_id, Teacher_name, Course_name, Note,Course_time, Department,Activity_id, RefID, Course_state, nOrder from CPB_Course where ',' + class_id + ',' like '%," + DataID + ",%' order by Mode_id, nOrder");
		String jsonPlace = jdb.getTreeJson(0, "Place", "Name", "ID", "ParentID",  "Place_Type, Seats", "", "0");
		if (jsonPlace.equals("[]"))
		{//将CPB_Classroom表转换成Place表
			sql = "select * from CPB_Classroom";
			ResultSet rs = jdb.rsSQL(0, sql);
			jdb.ExecuteSQL(0, "set IDENTITY_INSERT Place on");
			while (rs.next())
			{
				sql = "insert into Place(ID, Name, Place_Type, Device, ItemType) values ("+ rs.getInt("ClassRoom_id") + ",'" +
					rs.getString("ClassRoom_name") + "',1,'" + rs.getString("CardMathineIP") + "'," + rs.getInt("ClassRoom_type") + ")";
				jdb.ExecuteSQL(0, sql);
			}
			jdb.ExecuteSQL(0, "set IDENTITY_INSERT Place off");
			jdb.rsClose(0, rs);
			jsonPlace = jdb.getTreeJson(0, "Place", "Name", "ID", "ParentID",  "Place_Type, Seats", "", "0");
		}
//		String jsonBECourse =  jdb.getJsonBySql(0, "select Syllabuses_id, BeginTime, Syllabuses_subject_id, Syllabuses_subject_name, Syllabuses_ClassRoom, Syllabuses_bak from CPB_Syllabuses where class_id=" +
//			DataID + " and (Syllabuses_subject_name='开班式' or Syllabuses_course_name='开班式' or Syllabuses_subject_name='结业式' or Syllabuses_course_name='结业式') order by BeginTime");
		out.print("{Style:" + jsonStyle + ", ModeBase:" + jsonModeBase + ", Mode:" + jsonMode + ", Option:" + Option + ", Course:" + jsonCourse + ", Place:" + jsonPlace + "}");
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "getPlace") > 0)
	{
		
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "getCommUnit") > 0)
	{
		int Term_id = WebChar.RequestInt(request, "Term_id");
		String jsonModeCommon = jdb.getTreeJson(0, "CPB_Mode", "Mode_Name", "Mode_id", "ParentNode",  "Term_id, Class_id, Mode_order, Mode_other, Mode_time, Note, CSS, RefID", 
				"RefID>0 and RefID=Mode_id and Term_id=" + Term_id + " order by Mode_order", "0");
		String jsonCourse = jdb.getJsonBySql(0, "select Course_id, Subject_id, term_id, Mode_id, Style_id, Informant_id, Informant_name, Teacher_id," +
			"Teacher_name, Course_name, Note,Course_time, Department,Activity_id, RefID, Course_state from CPB_Course where Mode_id in(select Mode_id from CPB_Mode where RefID>0 and Term_id=" +
			Term_id + " and RefID=Mode_id) and RefID=Course_id order by Mode_id, Style_id");
		out.print("{Mode:" + jsonModeCommon + ", Course:" + jsonCourse + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getCommCourse") > 0)
	{
		int Term_id = WebChar.RequestInt(request, "Term_id");
		String jsonCourse = jdb.getJsonBySql(0, "select Course_id, Subject_id, term_id, Mode_id, Style_id, Informant_id, Informant_name, Teacher_id," +
			"Teacher_name, Course_name, Note,Course_time, Department,Activity_id, RefID, Course_state from CPB_Course where Mode_id in(select Mode_id from CPB_Mode where RefID=0 and Term_id=" +
			Term_id + ") and RefID=Course_id order by Mode_id, Style_id");
		out.print(jsonCourse);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "getLastClass") > 0)
	{
		String jsonClass = "未找到近期班次数据";
		sql = "select * from CPB_Class where Class_id=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_Term_id = rs.getString("Term_id");
//			rs_Class_BeginTime = rs.getString("Class_BeginTime");
			String lastTermID = jdb.getValueBySql(0, "select top 1 Term_id from CPB_Term where Term_id<>" + rs_Term_id + " order by Term_BeginTime desc");
			jsonClass = jdb.getJsonBySql(0, "select Class_id, Class_Name, ClassCode from CPB_Class where (Class_id<>" + DataID + 
				" and Term_id=" + rs_Term_id + ") or Term_id=" + lastTermID + " order by ClassCode");
		}
		jdb.rsClose(0, rs);
		out.print(jsonClass);		
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getOldTerm") > 0)
	{
		String jsonTerm = "未找到上期学期数据";
		sql = "select * from CPB_Class where Class_id=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_Term_id = rs.getString("Term_id");
			String lastTermID = jdb.getValueBySql(0, "select top 1 Term_id from CPB_Term where Term_id<>" + rs_Term_id + " order by Term_BeginTime desc");
			jsonTerm = jdb.getJsonBySql(0, "select Term_id, Term_Name from CPB_Term where Term_id not in(" + rs_Term_id + "," + lastTermID + ") order by Term_BeginTime desc");
		}
		jdb.rsClose(0, rs);
		out.print(jsonTerm);		
		jdb.closeDBCon();
		return;
		
	}

	if (WebChar.RequestInt(request, "getOldClass") > 0)
	{
		int Term_id = WebChar.RequestInt(request, "Term_id");
		String jsonClass = jdb.getJsonBySql(0, "select Class_id, Class_Name, ClassCode from CPB_Class where Term_id=" + Term_id + " order by ClassCode");
		out.print(jsonClass);		
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "getNewSubject") == 1)
	{
		String jsonSubject = jdb.getJsonBySql(0, "select top 100 Subject_id, Subject_name, Tech_type, Teacher_name, Teacher_id, Informant_id, Informant_name, Department_name from CPB_Subject where Subject_flag in (1,3,4,5,6,7) or Subject_flag is null order by Frist_time desc");
		out.print("{Data:" +jsonSubject + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "SavePlanOption") == 1)
	{
		int nType = WebChar.RequestInt(request, "nType");
	
		String CourseShowMode = WebChar.requestStr(request, "CourseShowMode");
		String CourseNoMode = WebChar.requestStr(request, "CourseNoMode");
		String CourseNameMode = WebChar.requestStr(request, "CourseNameMode");

		String TeacherShowMode = WebChar.requestStr(request, "TeacherShowMode");
		String OuterTeacherShowMode = WebChar.requestStr(request, "OuterTeacherShowMode");

		String CourseNameEditEnable = WebChar.requestStr(request, "CourseNameEditEnable");
		String CourseTimeEnable = WebChar.requestStr(request, "CourseTimeEnable");
		String TeacherEditEnable = WebChar.requestStr(request, "TeacherEditEnable");
		String TeacherUnitEditEnable = WebChar.requestStr(request, "TeacherUnitEditEnable");
		
		String CourseLayerMode = WebChar.requestStr(request, "CourseLayerMode");
		String CourseFreeInfo = WebChar.requestStr(request, "CourseFreeInfo");
		String ActivityMode = WebChar.requestStr(request, "ActivityMode");
		String CourseShowRed = WebChar.requestStr(request, "CourseShowRed");
		String CommonUnitCourseEditEnable = WebChar.requestStr(request, "CommonUnitCourseEditEnable");
				
		String value = "";
		if (nType == 2)
		{
			sysApp.setSysParam("PlanCourseShowMode", CourseShowMode);
			sysApp.setSysParam("PlanCourseNoMode", CourseNoMode);
			sysApp.setSysParam("PlanCourseNameMode", CourseNameMode);
		
			sysApp.setSysParam("PlanTeacherShowMode", TeacherShowMode);
			sysApp.setSysParam("PlanOuterTeacherShowMode", OuterTeacherShowMode);
			
			sysApp.setSysParam("PlanCourseNameEditEnable", CourseNameEditEnable);
			sysApp.setSysParam("PlanCourseTimeEnable", CourseTimeEnable);
			sysApp.setSysParam("PlanTeacherEditEnable", TeacherEditEnable);
			sysApp.setSysParam("PlanTeacherUnitEditEnable", TeacherUnitEditEnable);

			sysApp.setSysParam("PlanCourseLayerMode", CourseLayerMode);
			sysApp.setSysParam("PlanCourseFreeInfo", CourseFreeInfo);
			sysApp.setSysParam("PlanActivityMode", ActivityMode);
			sysApp.setSysParam("PlanCourseShowRed", CourseShowRed);
			sysApp.setSysParam("PlanCommonUnitCourseEditEnable", CommonUnitCourseEditEnable);
		}
		else
		{
			value = "{CourseShowMode:" + CourseShowMode + ", CourseNoMode:" + CourseNoMode + ", CourseNameMode:" + CourseNameMode +
				", TeacherShowMode:" + TeacherShowMode + ", OuterTeacherShowMode:" + OuterTeacherShowMode + ",CourseNameEditEnable:" +
				CourseNameEditEnable + ", CourseTimeEnable:" + CourseTimeEnable + ",TeacherEditEnable:"+ TeacherEditEnable +
				",TeacherUnitEditEnable:"+ TeacherUnitEditEnable +
				", CourseLayerMode:" + CourseLayerMode + ", CourseFreeInfo:" + CourseFreeInfo + ", ActivityMode:" + ActivityMode + 
				", CourseShowRed:" + CourseShowRed + ", CommonUnitCourseEditEnable:" + CommonUnitCourseEditEnable + "}";
		}
		SetClassExValue(jdb, user, Class_id, "ClassPlanConfig", "班级课程表配置选项", value);

		out.print("OK");
		jdb.closeDBCon();
		return;
	}
	{
		sql = "select EName, value from UserReportDetail where ParentID in (select ID from UserReport where TypeName='ClassTeachPlan' and param1=" + DataID + ")";	
		ResultSet rs = jdb.rsSQL(0, sql);
		while (rs.next())
		{
			String EName = rs.getString("EName");
			if (EName.equals("Books"))
				rs_Books = rs.getString("value");
			else if (EName.equals("PlanPara1"))
				rs_PlanPara1 = rs.getString("value");
			else if (EName.equals("PlanNote"))
				rs_PlanNote = rs.getString("value");
		}
		jdb.rsClose(0, rs);
	}

//(归档用注释,切勿删改)后台载入时用户自定义代码 End##@@
	int bAppend = 0;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = "select * from CPB_Class where Class_id=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_TrainBook = WebChar.getRSDefault(jdb.getRSString(0, rs, "TrainBook"), "");
			rs_Class_id = WebChar.getRSDefault(jdb.getRSString(0, rs, "Class_id"), "");
			rs_Term_id = WebChar.getRSDefault(jdb.getRSString(0, rs, "Term_id"), "");
			rs_Class_Name = WebChar.getRSDefault(jdb.getRSString(0, rs, "Class_Name"), "");
			rs_Class_BeginTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "Class_BeginTime"), "");
			rs_Class_BeginTime = VB.dateCStr(VB.CDate(rs_Class_BeginTime), "yyyy-MM-dd");
			rs_Class_EndTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "Class_EndTime"), "");
			rs_Class_EndTime = VB.dateCStr(VB.CDate(rs_Class_EndTime), "yyyy-MM-dd");
			rs_Class_order = WebChar.getRSDefault(jdb.getRSString(0, rs, "Class_order"), "");
			rs_ClassRoom_id = WebChar.getRSDefault(jdb.getRSString(0, rs, "ClassRoom_id"), "");
			rs_Mode_ids = WebChar.getRSDefault(jdb.getRSString(0, rs, "Mode_ids"), "");
			rs_cname = WebChar.getRSDefault(jdb.getRSString(0, rs, "cname"), "");
			rs_teacher_ids = WebChar.getRSDefault(jdb.getRSString(0, rs, "teacher_ids"), "");
			rs_ClassCode = WebChar.getRSDefault(jdb.getRSString(0, rs, "ClassCode"), "");
			rs_Department_level = WebChar.getRSDefault(jdb.getRSString(0, rs, "Department_level"), "");
			rs_train_goal = WebChar.getRSDefault(jdb.getRSString(0, rs, "train_goal"), "");
			rs_train_object = WebChar.getRSDefault(jdb.getRSString(0, rs, "train_object"), "");
			rs_train_address = WebChar.getRSDefault(jdb.getRSString(0, rs, "train_address"), "");
			rs_train_content = WebChar.getRSDefault(jdb.getRSString(0, rs, "train_content"), "");
			rs_train_style = WebChar.getRSDefault(jdb.getRSString(0, rs, "train_style"), "");
			rs_train_claim = WebChar.getRSDefault(jdb.getRSString(0, rs, "train_claim"), "");
			rs_classmates = WebChar.getRSDefault(jdb.getRSString(0, rs, "classmates"), "");
			rs_TrainUnit = WebChar.getRSDefault(jdb.getRSString(0, rs, "TrainUnit"), "");
			rs_OuterArea = WebChar.getRSDefault(jdb.getRSString(0, rs, "OuterArea"), "");
			rs_OuterDays = WebChar.getRSDefault(jdb.getRSString(0, rs, "OuterDays"), "");
			rs_OuterBegin = WebChar.getRSDefault(jdb.getRSString(0, rs, "OuterBegin"), "");
			rs_OuterEnd = WebChar.getRSDefault(jdb.getRSString(0, rs, "OuterEnd"), "");
			rs_TrainLeader = WebChar.getRSDefault(jdb.getRSString(0, rs, "TrainLeader"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	rs_classmates = WebChar.getRSDefault(rs_classmates, "30");
	rs_PlanPara1 = WebChar.getRSDefault(rs_PlanPara1, "本教学计划由教学处、学员工作处和有关教研部共同组织实施。");
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		str +=", Term_id_ex:\"" + jdb.GetQuoteValue("CPB_Term",0, "Term_id", "Term_Name", rs_Term_id) + "\"";
		str +=", ClassRoom_id_ex:\"" + jdb.GetQuoteValue("Place",0, "ID", "Name", rs_ClassRoom_id) + "\"";
		str +=", teacher_ids_ex:\"" + jdb.GetQuoteValue("+Member",0, "ID", "CName", rs_teacher_ids) + "\"";
		str +=", TrainLeader_ex:\"" + jdb.GetQuoteValue("+Member",0, "ID", "CName", rs_TrainLeader) + "\"";
		out.print("{TrainBook:\"" + WebChar.toJson(rs_TrainBook) + 
			"\",Class_id:\"" + rs_Class_id + 
			"\",Term_id:\"" + rs_Term_id + 
			"\",Class_Name:\"" + rs_Class_Name + 
			"\",Class_BeginTime:\"" + rs_Class_BeginTime + 
			"\",Class_EndTime:\"" + rs_Class_EndTime + 
			"\",Class_order:\"" + rs_Class_order + 
			"\",ClassRoom_id:\"" + rs_ClassRoom_id + 
			"\",Mode_ids:\"" + rs_Mode_ids + 
			"\",cname:\"" + rs_cname + 
			"\",teacher_ids:\"" + rs_teacher_ids + 
			"\",ClassCode:\"" + rs_ClassCode + 
			"\",Department_level:\"" + rs_Department_level + 
			"\",train_goal:\"" + WebChar.toJson(rs_train_goal) + 
			"\",train_object:\"" + WebChar.toJson(rs_train_object) + 
			"\",train_address:\"" + WebChar.toJson(rs_train_address) + 
			"\",train_content:\"" + WebChar.toJson(rs_train_content) + 
			"\",train_style:\"" + WebChar.toJson(rs_train_style) + 
			"\",train_claim:\"" + WebChar.toJson(rs_train_claim) + 
			"\",classmates:\"" + rs_classmates + 
			"\",TrainUnit:\"" + rs_TrainUnit + 
			"\",OuterArea:\"" + rs_OuterArea + 
			"\",OuterDays:\"" + rs_OuterDays + 
			"\",OuterBegin:\"" + rs_OuterBegin + 
			"\",OuterEnd:\"" + rs_OuterEnd + 
			"\",TrainLeader:\"" + rs_TrainLeader + 
			"\",CourseList:\"" + WebChar.toJson(rs_CourseList) + 
			"\",BECourse:\"" + WebChar.toJson(rs_BECourse) + 
			"\",Books:\"" + WebChar.toJson(rs_Books) + 
			"\",PlanNote:\"" + WebChar.toJson(rs_PlanNote) + 
			"\",PlanPara1:\"" + WebChar.toJson(rs_PlanPara1) + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "教学计划编辑";
		String ex = "";
		ex = "{x:0,y:32,node:1,a:{},b:{}}";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"征订教材\", EName:\"TrainBook\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:250, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级编号\", EName:\"Class_id\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:5,FieldLen:4, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"学期编号\", EName:\"Term_id\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"CPB_Term.Term_id,Term_Name\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级名称\", EName:\"Class_Name\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"开始时间\", EName:\"Class_BeginTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"&d:1\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"结束时间\", EName:\"Class_EndTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"&d:1\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"排序\", EName:\"Class_order\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"教室\", EName:\"ClassRoom_id\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"Place.ID,Name\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"模块编号\", EName:\"Mode_ids\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级别名\", EName:\"cname\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"组织员编号\", EName:\"teacher_ids\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"+Member.ID,CName\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"班级编码\", EName:\"ClassCode\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:8, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"部门级别\", EName:\"Department_level\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训目的\", EName:\"train_goal\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训对象\", EName:\"train_object\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:14, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训地点\", EName:\"train_address\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训内容\", EName:\"train_content\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训方式\", EName:\"train_style\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:17, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"培训要求\", EName:\"train_claim\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:2000, Quote:\"\", nCol:1, nRow:18, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"计划培训人数\", EName:\"classmates\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:19, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"主办承办单位\", EName:\"TrainUnit\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:20, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学地点\", EName:\"OuterArea\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:21, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学天数\", EName:\"OuterDays\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:22, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学开始时间\", EName:\"OuterBegin\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"\", nCol:1, nRow:23, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"异地教学结束时间\", EName:\"OuterEnd\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:16, Quote:\"\", nCol:1, nRow:24, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"项目负责人编号\", EName:\"TrainLeader\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"+Member.ID,CName\", nCol:1, nRow:25, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"课程列表\", EName:\"CourseList\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"开班式和结业式\", EName:\"BECourse\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"学习参考书目\", EName:\"Books\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"其它\", EName:\"PlanNote\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:28, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"教学计划实施\", EName:\"PlanPara1\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:28, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str +=", Term_id_ex:\"" + jdb.GetQuoteValue("CPB_Term",0, "Term_id", "Term_Name", rs_Term_id) + "\"";
		str +=", ClassRoom_id_ex:\"" + jdb.GetQuoteValue("Place",0, "ID", "Name", rs_ClassRoom_id) + "\"";
		str +=", teacher_ids_ex:\"" + jdb.GetQuoteValue("+Member",0, "ID", "CName", rs_teacher_ids) + "\"";
		str +=", TrainLeader_ex:\"" + jdb.GetQuoteValue("+Member",0, "ID", "CName", rs_TrainLeader) + "\"";
		out.print("{TrainBook:\"" + WebChar.toJson(rs_TrainBook) + 
			"\",Class_id:\"" + rs_Class_id + 
			"\",Term_id:\"" + rs_Term_id + 
			"\",Class_Name:\"" + rs_Class_Name + 
			"\",Class_BeginTime:\"" + rs_Class_BeginTime + 
			"\",Class_EndTime:\"" + rs_Class_EndTime + 
			"\",Class_order:\"" + rs_Class_order + 
			"\",ClassRoom_id:\"" + rs_ClassRoom_id + 
			"\",Mode_ids:\"" + rs_Mode_ids + 
			"\",cname:\"" + rs_cname + 
			"\",teacher_ids:\"" + rs_teacher_ids + 
			"\",ClassCode:\"" + rs_ClassCode + 
			"\",Department_level:\"" + rs_Department_level + 
			"\",train_goal:\"" + WebChar.toJson(rs_train_goal) + 
			"\",train_object:\"" + WebChar.toJson(rs_train_object) + 
			"\",train_address:\"" + WebChar.toJson(rs_train_address) + 
			"\",train_content:\"" + WebChar.toJson(rs_train_content) + 
			"\",train_style:\"" + WebChar.toJson(rs_train_style) + 
			"\",train_claim:\"" + WebChar.toJson(rs_train_claim) + 
			"\",classmates:\"" + rs_classmates + 
			"\",TrainUnit:\"" + rs_TrainUnit + 
			"\",OuterArea:\"" + rs_OuterArea + 
			"\",OuterDays:\"" + rs_OuterDays + 
			"\",OuterBegin:\"" + rs_OuterBegin + 
			"\",OuterEnd:\"" + rs_OuterEnd + 
			"\",TrainLeader:\"" + rs_TrainLeader + 
			"\",CourseList:\"" + WebChar.toJson(rs_CourseList) + 
			"\",BECourse:\"" + WebChar.toJson(rs_BECourse) + 
			"\",Books:\"" + WebChar.toJson(rs_Books) + 
			"\",PlanNote:\"" + WebChar.toJson(rs_PlanNote) + 
			"\",PlanPara1:\"" + WebChar.toJson(rs_PlanPara1) + 
			"\"" + str + "}");
		out.print(", {FlowInput:\"" + WebChar.toJson(FlowInput) +
			"\", FlowButton:\"" + WebChar.toJson(FlowButton) + 
			"\", FlowTitle:\"" + FlowTitle + 
			"\", FlowAttach:\"" + WebChar.toJson(FlowAttach) + 
			"\", DataID:\"" + DataID + 
			"\", FormAction:\"CPB_Class_Course.jsp\", ExcelFormID:" + ExcelFormID + "}]");
		jdb.closeDBCon();
		return;
	}
	out.println(WebFace.GetHTMLHead(FormTitle, "<link rel='stylesheet' type='text/css' href='../forum.css'>"));
%>
<script language=javascript src=../com/jquery.js></script>
<script language=javascript src=../com/jcom.js></script>
<script language=javascript src=../com/view.js></script>
<script language=javascript src=../LY_CPB/incPlan.js></script>
<script language=javascript src=../LY_CPB/plancourse.js></script>

<script language=javascript>
nDefaultWinMode = 5;
//FormFeatures = 'titlebar=0,toolbar=0,scrollbars=0,resizable=0,width=640,height=200,left=50,top=50';
</script><body scroll=no style='background:' alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0>
<div id=FormDiv style=overflow:auto;width:100%;height:100%;></div></body>
<script language=javascript>
window.onload = function ()
{
 var ex = "";
	var ex = {x:0,y:32,node:1,a:{},b:{}};
	var fields = [{CName:"征订教材", EName:"TrainBook", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:250, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"班级编号", EName:"Class_id", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:5, FieldLen:4, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"学期编号", EName:"Term_id", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"CPB_Term.Term_id,Term_Name", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"班级名称", EName:"Class_Name", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"开始时间", EName:"Class_BeginTime", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:16, Quote:"&d:1", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:""},
		{CName:"结束时间", EName:"Class_EndTime", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:16, Quote:"&d:1", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:""},
		{CName:"排序", EName:"Class_order", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:""},
		{CName:"教室", EName:"ClassRoom_id", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"Place.ID,Name", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:""},
		{CName:"模块编号", EName:"Mode_ids", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:200, Quote:"", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:""},
		{CName:"班级别名", EName:"cname", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:""},
		{CName:"组织员编号", EName:"teacher_ids", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:200, Quote:"+Member.ID,CName", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:""},
		{CName:"班级编码", EName:"ClassCode", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:8, Quote:"", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:""},
		{CName:"部门级别", EName:"Department_level", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:""},
		{CName:"培训目的", EName:"train_goal", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:2000, Quote:"", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:""},
		{CName:"培训对象", EName:"train_object", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:2000, Quote:"", nCol:1, nRow:14, nWidth:1, nHeight:1, Hint:""},
		{CName:"培训地点", EName:"train_address", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:2000, Quote:"", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:""},
		{CName:"培训内容", EName:"train_content", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:2000, Quote:"", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:""},
		{CName:"培训方式", EName:"train_style", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:2000, Quote:"", nCol:1, nRow:17, nWidth:1, nHeight:1, Hint:""},
		{CName:"培训要求", EName:"train_claim", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:2000, Quote:"", nCol:1, nRow:18, nWidth:1, nHeight:1, Hint:""},
		{CName:"计划培训人数", EName:"classmates", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:19, nWidth:1, nHeight:1, Hint:""},
		{CName:"主办承办单位", EName:"TrainUnit", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:20, nWidth:1, nHeight:1, Hint:""},
		{CName:"异地教学地点", EName:"OuterArea", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:21, nWidth:1, nHeight:1, Hint:""},
		{CName:"异地教学天数", EName:"OuterDays", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:22, nWidth:1, nHeight:1, Hint:""},
		{CName:"异地教学开始时间", EName:"OuterBegin", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:16, Quote:"", nCol:1, nRow:23, nWidth:1, nHeight:1, Hint:""},
		{CName:"异地教学结束时间", EName:"OuterEnd", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:16, Quote:"", nCol:1, nRow:24, nWidth:1, nHeight:1, Hint:""},
		{CName:"项目负责人编号", EName:"TrainLeader", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"+Member.ID,CName", nCol:1, nRow:25, nWidth:1, nHeight:1, Hint:""},
		{CName:"课程列表", EName:"CourseList", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:"", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:""},
		{CName:"开班式和结业式", EName:"BECourse", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:"", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:""},
		{CName:"学习参考书目", EName:"Books", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:27, nWidth:1, nHeight:1, Hint:""},
		{CName:"其它", EName:"PlanNote", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:28, nWidth:1, nHeight:1, Hint:""},
		{CName:"教学计划实施", EName:"PlanPara1", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:28, nWidth:1, nHeight:1, Hint:""}];
	var record = {TrainBook:"<%=WebChar.toJson(rs_TrainBook)%>",
		Class_id:"<%=rs_Class_id%>",
		Term_id:"<%=rs_Term_id%>",
		Class_Name:"<%=WebChar.toJson(rs_Class_Name)%>",
		Class_BeginTime:"<%=rs_Class_BeginTime%>",
		Class_EndTime:"<%=rs_Class_EndTime%>",
		Class_order:"<%=rs_Class_order%>",
		ClassRoom_id:"<%=rs_ClassRoom_id%>",
		Mode_ids:"<%=WebChar.toJson(rs_Mode_ids)%>",
		cname:"<%=WebChar.toJson(rs_cname)%>",
		teacher_ids:"<%=WebChar.toJson(rs_teacher_ids)%>",
		ClassCode:"<%=WebChar.toJson(rs_ClassCode)%>",
		Department_level:"<%=rs_Department_level%>",
		train_goal:"<%=WebChar.toJson(rs_train_goal)%>",
		train_object:"<%=WebChar.toJson(rs_train_object)%>",
		train_address:"<%=WebChar.toJson(rs_train_address)%>",
		train_content:"<%=WebChar.toJson(rs_train_content)%>",
		train_style:"<%=WebChar.toJson(rs_train_style)%>",
		train_claim:"<%=WebChar.toJson(rs_train_claim)%>",
		classmates:"<%=rs_classmates%>",
		TrainUnit:"<%=WebChar.toJson(rs_TrainUnit)%>",
		OuterArea:"<%=WebChar.toJson(rs_OuterArea)%>",
		OuterDays:"<%=WebChar.toJson(rs_OuterDays)%>",
		OuterBegin:"<%=rs_OuterBegin%>",
		OuterEnd:"<%=rs_OuterEnd%>",
		TrainLeader:"<%=WebChar.toJson(rs_TrainLeader)%>",
		CourseList:"<%=WebChar.toJson(rs_CourseList)%>",
		BECourse:"<%=WebChar.toJson(rs_BECourse)%>",
		Books:"<%=WebChar.toJson(rs_Books)%>",
		PlanNote:"<%=WebChar.toJson(rs_PlanNote)%>",
		PlanPara1:"<%=WebChar.toJson(rs_PlanPara1)%>"};
	var ExcelFormID = <%=ExcelFormID%>;
//@@##321:客户端载入时(归档用注释,切勿删改)

//	var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"TeachFrame"}};
//	var aFace = {x:0,y:28,node:1,a:{id:"SeekMenubar"},b:{child:{x:360,y:-1,node:2,a:{id:"LeftDiv"},b:{id:"TeachFrame"}}}};
	var aFace = {x:0,y:28,node:1,a:{id:"SeekMenubar"},b:{child:{x:360,y:-1,node:2,a:{id:"LeftDiv",child:{x:0,y:28,node:3,a:{id:"SearchDiv"},b:{id:"TreeDiv"}}},b:{id:"TeachFrame"}}}}
	$("#FormDiv").css("overflow", "hidden");
	layer = new $.jcom.Layer($("#FormDiv")[0], aFace, {});
	$("#SeekMenubar").css({borderBottom:"1px solid gray"});
	$("#TeachFrame")[0].style.overflow = "auto";
	$("#TeachFrame")[0].style.backgroundColor = "#c0c0c0";	
	$("#TeachFrame")[0].style.padding = "2px";
	$("#TeachFrame").html("<center style='width:100%;height:100%;padding:2px'>" +
		"<div align=left id=TeachDoc style='width:798px;height:100%;overflow-y:visible;overflow-x:hidden;background:white;padding:20px 100px 20px 100px;border-left:1px solid black;border-bottom:1px solid black;border-right:3px solid black'>正在加载...</div></center>");
	record = InitRecord(record);
	jsonClass = record;
	if (EditMode == 1)
	{
		$("#SearchDiv").css({borderBottom:"1px solid gray", borderRight:"1px solid gray"});
		$("#SearchDiv").html("<div id=SearchInput style=float:left;></div><div style=float:right;width:20px;padding-top:4px;><img id=SearchButton src=../pic/search.png></div>");
		$("#SearchInput").attr("title", "在此输入需要搜索的课程内容或授课人...");
		SearchEdit = new $.jcom.DynaEditor.Edit();
		SearchEdit.config({editorMode:4});
		SearchEdit.onShow = SetSearchButton;
		SearchEdit.onBlur = CheckSearchButton;
		$("#SearchButton").on("click", ClearSearch);
		SearchEdit.onCharChange = DocSearch;
		SearchEdit.attach($("#SearchInput")[0]);
		
		rootItems = [{item:"最新专题", nType:2, img:"../pic/eut_bs_icon19.png", style:"font:normal normal normal 14px 微软雅黑;", child:null},
		 	{item:"公共单元", nType:8, img:"../pic/382.png", style:"font:normal normal normal 14px 微软雅黑;", child:null},
		 	{item:"公共课程", nType:9, img:"../pic/eut_bs_icon16.png", style:"font:normal normal normal 14px 微软雅黑;", child:null},
			{item:"近期课程", nType:6, img:"../pic/384.png", style:"font:normal normal normal 14px 微软雅黑;", child:null},
			{item:"往期课程", nType:7, img:"../pic/388.png", style:"font:normal normal normal 14px 微软雅黑;", child:null},
			{item:"专题库", nType:3, img:"../pic/385.png", style:"font:normal normal normal 14px 微软雅黑;", child:null},
			{item:"剪贴薄", nType:5, img:"../pic/eut_bs_icon14.png", style:"font:normal normal normal 14px 微软雅黑;", child:null}];
		$("#TreeDiv").css({overflow:"auto", borderRight:"1px solid gray"});
		tree = new $.jcom.TreeView($("#TreeDiv")[0], rootItems);
		tree.loadnode = LoadLeftTree;
		tree.dblclick = TreeDblClick;
		var def = [{item:"文件",child:[{item:"打开",action:OpenClass},{item:"从电子版的教学计划导入",action:ImportPlan},
		           		{item:"导出教学计划到文件",action:OutFile},{item:"导出教学计划到班次文档", action:OutFile},{},
		        	    {item:"关闭", action:"window.close()"}]},
			{item:"编辑",child:[{item:"清空剪切薄中的内容", action:ClearClips}]},
			{item:"视图", child:[{item:"普通视图", action:null}, {item:"页面视图", action:null}, {}, {item:"仅显示课程的树表视图", action:null}]}, 
			{item:"设置", action:CourseConfig},
			{item:"工具", child:[{item:"设置默认教学单元模板", action:TeachUnit},{item:"维护教学形式",action:RunTeachStyle},
				{item:"维护专题库",action:RunSubject},{item:"维护师资库",action:RunTeacher},{},{item:"设置文档模板", action:SetFormModule},{},
				{item:"将课表中的课程复制到教学计划", action:CopyfromSyllabuses},
				{item:"编辑课程表", action:RunCourseEdit}]}, 
			{item:"刷新", action:"location.reload()"}, 
			{item:"预览", action:Preview},
			{item:"保存", action:SaveDoc}];
	}
	else
	{
		var def = [{item:"文件",child:[{item:"打开",action:OpenReadOnlyClass},
		     		           		{item:"导出教学计划到文件",action:OutFile},{item:"导出教学计划到班次文档", action:OutFile},{},
		    		        	    {item:"关闭", action:"window.close()"}]},
						{item:"刷新", action:"location.reload()"}	];
		$("#LeftDiv").css({overflow:"auto", borderRight:"1px solid gray"});
	}
	menubar = new $.jcom.CommonMenubar(def, $("#SeekMenubar")[0], "<span id=TitleSpan>" + record.Class_Name + "-" + record.ClassCode + "</span>");
	rec = record;
	if (ExcelFormID > 0)
		$.get("../com/inform.jsp", {DataID:ExcelFormID, Ajax:1}, getUserPlanDocOK);
	else
		$.get(location.pathname, {getClassCourseData:1, DataID: record.Class_id, ClassCode:record.ClassCode}, getClassCourseDataOK);

//(归档用注释,切勿删改) 客户端载入时 End##@@
}
//@@##322:客户端自定义脚本(归档用注释,切勿删改)
//js
var EditMode = <%=EditMode%>;
var jsonClass;//, aStyle, styleEditor, aUnit, delCourseIds = [], delModeIds = [], BECourse;
var focusFieldObj;//, focusTitleObj;
var tree;//, courseObj, subjecttree, subjectview;
var PlanDoc, rec;
//var word, doc;
//var clipUnits = [], clipStyles = []; clipCourses = [];
var CourseEditor, pEdit, dateEditor;
var option = {
		CourseShowMode:<%=sysApp.getSysParam(5, "PlanCourseShowMode", "教学计划课程显示结构", "1")%>,
		CourseNoMode: <%=sysApp.getSysParam(5, "PlanCourseNoMode", "教学计划课程序号编排方式", "1")%>,
		CourseNameMode: <%=sysApp.getSysParam(5, "PlanCourseNameMode", "教学计划课程名称显示方式", "0")%>,
		TeacherShowMode: <%=sysApp.getSysParam(5, "PlanTeacherShowMode", "教学计划本校授课人显示方式", "0")%>,
		OuterTeacherShowMode: <%=sysApp.getSysParam(5, "PlanOuterTeacherShowMode", "教学计划外请授课人显示方式", "0")%>,
		CourseNameEditEnable: <%=sysApp.getSysParam(5, "PlanCourseNameEditEnable", "教学计划编辑课程名称允许", "2")%>,
		CourseTimeEnable: <%=sysApp.getSysParam(5, "PlanCourseTimeEnable", "教学计划课程时长显示编辑允许", "0")%>,
		TeacherEditEnable: <%=sysApp.getSysParam(5, "PlanTeacherEditEnable", "教学计划编辑授课人允许", "0")%>,
		TeacherUnitEditEnable: <%=sysApp.getSysParam(5, "PlanTeacherUnitEditEnable", "教学计划编辑授课人单位允许", "0")%>,
		CourseLayerMode: <%=sysApp.getSysParam(5, "PlanCourseLayerMode", "教学计划课程排版方式", "1")%>,
		CourseFreeInfo: <%=sysApp.getSysParam(5, "PlanCourseFreeInfo", "教学计划选修课显示内容", "1")%>,
		ActivityMode: <%=sysApp.getSysParam(5, "PlanActivityMode", "教学计划教学活动处理方式", "1")%>,
		CourseShowRed: <%=sysApp.getSysParam(5, "PlanCourseShowRed", "标红非专题库中的课程 ", "1")%>,
		CommonUnitCourseEditEnable: <%=sysApp.getSysParam(5, "PlanCommonUnitCourseEditEnable", "编辑公共单元与课程 ", "0")%>
		};

function getClassCourseDataOK(data)
{
	var jsonData = $.jcom.eval(data);
	if (typeof jsonData == "string")
			return alert(jsonData);

	jsonClass.train_goal = DealEnter(jsonClass.train_goal);
	jsonClass.train_object = DealEnter(jsonClass.train_object);
	jsonClass.train_content = DealEnter(jsonClass.train_content);
//	jsonClass.Class_BeginTime =	$.jcom.GetDateTimeString(jsonClass.Class_BeginTime, 12);
//	jsonClass.Class_EndTime = $.jcom.GetDateTimeString(jsonClass.Class_EndTime, 12);
//	jsonClass.OuterBegin = $.jcom.GetDateTimeString(jsonClass.OuterBegin, 12);
//	jsonClass.OuterEnd = $.jcom.GetDateTimeString(jsonClass.OuterEnd, 12);
	
	var tag = getPlanDoc();
	$("#TeachDoc").html(tag);

	for (key in jsonClass)
	{
		var o = $("#" + key);
		if (o.length > 0)
			o.html(jsonClass[key]);
	}

	CourseEditor = new PlanCourseEditor($("#PlanCourseDoc")[0], jsonData, option, {mode:EditMode});
	CourseEditor.onClipChange = ReloadClip;
	CourseEditor.onDblClick = DblClickPlan;
	BECourse = CourseEditor.getUnitCourse(0), 
	CourseEditor.setBECourse($("#BECourseDiv")[0]);
	if (EditMode == 0)
		return;

	pEdit = new $.jcom.DynaEditor.Edit();
	pEdit.valueChange = PEditValueChange;
	var o = $(".pedit");
	dateEditor = new $.jcom.DynaEditor.Date(200, 200);
	dateEditor.valueChange = DateValueChange;
	var o = $(".tedit");
	PlanAttachEditor();
	document.body.onbeforeunload = SaveConfirm;
}

function PlanAttachEditor(flag)
{
	var o = $(".pedit");
	for (var x = 0; x < o.length; x++)
	{
		if ((flag == false) || (flag == undefined))
			pEdit.detach(o[x]);
		if ((flag == true) || (flag == undefined))
			pEdit.attach(o[x]);
	}
	var o = $(".tedit");
	for (var x = 0; x < o.length; x++)
	{
		if ((flag == false) || (flag == undefined))
			dateEditor.detach(o[x]);
		if ((flag == true) || (flag == undefined))
			dateEditor.attach(o[x]);
	}
}

function ReloadClip()
{
	var obj = tree.getNodeObj("nType", 5);
	tree.reloadNode(obj, true);
}

function PEditValueChange(obj)
{
	jsonClass[obj.id] = obj.innerText;
}

function DateValueChange(obj)
{
	jsonClass[obj.id] = obj.innerText;
	obj.innerText = $.jcom.GetDateTimeString(obj.innerText, 12);
}

function getUserPlanDocOK(data)
{
	PlanDoc = data;
	$.get(location.pathname, {getClassCourseData:1, DataID: rec.Class_id, ClassCode:rec.ClassCode}, getClassCourseDataOK);	
}

function getPlanDoc()
{
	if (typeof PlanDoc == "string")
		return PlanDoc;
	
	var tag = "<H1 align=center>教学计划</H1>";
	tag += "<h2>一、培训目的</h2><p id=train_goal title=输入培训目的 class=pedit style=text-indent:30px;></p>";
	tag += "<h2>二、培训对象</h2><p id=train_object title=输入培训对象 class=pedit style=text-indent:30px;></p>";
	tag += "<h2>三、培训人数</h2><p style=text-indent:0px>计划培训人数<span id=classmates class=pedit title=输入人数></span>人。</p>";
	tag += "<h2>四、培训时间</h2><p><span id=Class_BeginTime title=培训开始时间 class=tedit style=text-indent:15px;></span>至<span id=Class_EndTime class=tedit title=培训结束时间>" +
		"</span>。异地培训起止时间：<span id=OuterBegin title=开始时间 class=tedit></span>至 <span id=OuterEnd class=tedit title=结束时间 style=text-indent:0px;></span>。</p>";
	tag += "<h2>五、培训地点</h2><p><span id=train_address title=输入培训地点 class=pedit style=text-indent:15px></span>。<span id=OuterArea title=输入异地培训地点 class=pedit></span></p>";
	tag += "<h2>六、培训内容</h2><p id=train_content class=pedit title=输入培训内容 style=text-indent:30px></p>";
	tag += "<div id=PlanCourseDoc style=overflow:visible></div>";
	tag += "<h2>七、开班式和结业式</h2><div id=BECourseDiv></div>"
	tag += "<h2>八、教学与学员管理</h2><p id=C_train_claim class=pedit title=输入教学与学员管理 style=text-indent:30px></p>";
	tag += "<h2>九、学员考核与颁发学业证书</h2><p id=C_train_style class=pedit title=输入内容 style=text-indent:30px></p>";
	return tag;
}

function SaveConfirm()
{
	event.returnValue="教学计划有可能已改变.";
}

function ClickDoc(event)
{
	var o = findObj(event.target);
	if (o == focusTitleObj)
		return;
	if (typeof focusTitleObj == "object")
	{
//		focusTitleObj.style.borderBottom = "none";
		var a = $(focusTitleObj).find("a");
		a.css("display", "none");
		focusTitleObj = undefined;
		
	}
	focusTitleObj = o;
	if (typeof o != "object")
		return;
	var a = $(o).find("a");
	a.css("display", "inline");
//	o.style.borderBottom = "1px solid #cccccc";
}

function OpenClass()
{
	if (typeof openwin == "object")
		return openwin.show();
	openwin = new $.jcom.PopupWin("<div id=ClassTree style=width:100%;height:420px;overflow:auto;></div>" +
		"<div align=right style=width:100%;height:30px><input type=button value=打开 onclick=RunOpenClass()>&nbsp;&nbsp;</div>", 
		{title:"选择班级教学计划", width:640, height:480, mask:50});
	openwin.close = openwin.hide;
	fun = function (data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		classtree = new $.jcom.TreeView(document.all.ClassTree, [], {parentNode:"Term_id"}, json.head);
		classtree.setdata(json.data);
		classtree.dblclick = RunOpenClass;
	}
	$.get("CPB_Class_docview.jsp", {GetTreeData:2}, fun);
}

function RunOpenClass()
{
	var item = classtree.getTreeItem();
	if (typeof item != "object")
		return alert("请先选择班级");
	if (typeof item.Class_id == "undefined")
		return alert("请选择班级，学期不能打开");
	classID = item.Class_id;
	$.get(location.pathname, {getrecord:1, DataID: item.Class_id}, getClassPlanDataOK);
	if (typeof openwin == "object")
		openwin.hide();
}

function getClassPlanDataOK(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return alert(json);
	jsonClass = json;	
	$("#TitleSpan").html(jsonClass.Class_Name + "-" + jsonClass.ClassCode);
	$.get(location.pathname, {getClassCourseData:1, DataID: jsonClass.Class_id, ClassCode:jsonClass.ClassCode}, getClassCourseDataOK);
}

function OpenReadOnlyClass()
{
	if (typeof classtree == "object")
		return RunOpenClass();
	fun = function (data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		classtree = new $.jcom.TreeView($("#LeftDiv")[0], [], {parentNode:"Term_id"}, json.head);
		classtree.setdata(json.data);
		classtree.dblclick = RunOpenClass;
	}
	$.get("../fvs/CPB_Class_docview.jsp", {GetTreeData:2}, fun);
}

function OutFile(obj, item)
{
	var mode = EditMode;
	EditMode = 0;
	var body = getPlanDoc();
	EditMode = mode;
	var action = "../com/OutHtml.jsp";
	if (item.item == "导出教学计划到班次文档")
		action += "?OutToServer=1";
	var text = "<input name=body><input name=FileName value=" + jsonClass.Class_Name + "-" + jsonClass.ClassCode + "教学计划.doc>"; 
	if (typeof $("#SaveFormFrame")[0] == "object")
		$("#SaveFormFrame").remove();
	document.body.insertAdjacentHTML("beforeEnd", "<iframe id=SaveFormFrame style=display:none></iframe>");
	var doc = $("#SaveFormFrame")[0].contentWindow.document;
	doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
		"</head><body><form id=SaveForm method=post action=" + action + ">" + text + "</form></body></html>");
	doc.charset = "gbk";
	doc.getElementsByName("body")[0].value = body;
	doc.getElementById("SaveForm").submit();
}

function OutHtmltoServerOK(id)
{
	$.get(location.pathname + "?AffixName=" + jsonClass.Class_Name + "教学计划.htm",
		{OutHTMLToServer:1, DataID:jsonClass.Class_id, AffixID:id}, OutHtmltoDocOK);
}

function OutHtmltoDocOK(data)
{
	alert(data);
}

function SetFormModule()
{
var user = "<%=user.EMemberName%>";
	if (user != "admin")
		return alert("只有管理员才能使用此功能。");
	window.open("UserDatas_viewExcel.jsp?");
}
function CopyfromSyllabuses()
{
	if (window.confirm("只有不通过教学计划直接排课的课程才需要复制，是否继续？"))
	{
		document.body.onbeforeunload = null;
		location.href = location.href + "&CopyfromSyllabuses=1";
	}
}

function RunCourseEdit()
{
	window.open("../LY_CPB/CourseEditNew.jsp?EditMode=1&ClassID=" + jsonClass.Class_id);
}
function TeachUnit()
{
	window.open("CPB_Mode_view_TeachUnit.jsp");
}

function RunSubject()
{
	window.open("CPB_Subject_Class_view.jsp");
}

function RunTeacher()
{
	window.open("CPB_Teacher_list.jsp");
}

function RunTeachStyle()
{
	window.open("CPB_Teach_Style_view.jsp");
}

function DealEnter(s)
{
	s = s.replace(/ /g, "&nbsp;&nbsp;");
	return s.replace(/\n/g, "<br>");
}

function Preview()
{
	window.open(location.pathname + "?ClassID=" + jsonClass.Class_id);
}


function PrepareSubjectData(root)
{
	for (var x = 0; x < root.length; x++)
	{
		root[x].nType = 31;
		root[x].item = root[x].Subject_Class_name;
		if (root[x].child.length == 0)
			root[x].child = null;
		else
			PrepareSubjectData(root[x].child);
	}	
}

function ClearClips()
{
	CourseEditor.ClearClips("将清空剪贴薄中的所有内容,是否确定？");
	ReloadClip();
}

function SaveDoc()
{
//	if (typeof focusFieldObj == "object")
//		blurField(focusFieldObj);
	if 	(CourseEditor.ClearClips("剪贴薄中仍然有未被粘贴的内容，保存后，这些肉容将会丢失，是否继续？\点击确定，将继续保存。") == false)
		return;

	var text = CourseEditor.MakeSaveFormTag();
	for (var key in jsonClass)
		text += "<textarea name=" + key + ">" + jsonClass[key] + "</textarea>";
	$.jcom.submit(location.pathname + "?SaveFlag=1", text, {fnReady:SaveOK});
	menubar.setDisabled("保存", true);
}

function SaveOK()
{
	var doc = $("#SaveFormFrame")[0].contentWindow.document;
	if (doc.readyState != "complete")
		return;
	menubar.setDisabled("保存", false);
	var result = doc.body.innerHTML;
	if (result.substr(0,2) != "OK")
		alert("保存失败:" + result);
	else
	{
		alert("保存成功");
		document.body.onbeforeunload = null;
		location.reload(true);
	}
}
function LoadLeftTree(item, div)
{
	var fun1 = function(data)	//班级课程
	{
		var jsonData = $.jcom.eval(data);
		if (typeof jsonData == "string")
			return alert(jsonData);

		item.child = DealUnitCourse(jsonData.Mode, jsonData.Course, 1);
		tree.loadnodeok(item, div);
	};
	
	var fun2 = function(data)	//??
	{
		alert(data);
		item.child = [];
		tree.loadnodeok(item, div);
		
	};
	
	var fun3 = function(data)	//专题库
	{
		var treedata = $.jcom.eval(data);
		if (typeof head == "string")
			return alert(treedata);
		PrepareSubjectData(treedata);
		item.child = treedata;
		tree.loadnodeok(item, div);
	};
	
	var fun4 = function(data)	//教学活动
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json;
		for (var x = 0; x < json.length; x++)
		{
			item.child[x].item = "<img src=../pic/ico_groups24.gif style=height:16px>&nbsp;" + StrAdd(item.child[x].Activity_name, item.child[x].Activity_Principals);
			item.child[x].nType = 41;
//			CheckItemInCourse(item.child[x], 2);
		}
		tree.loadnodeok(item, div);
	};
	
	var fun6 = function (data)	//近期课程
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json;
		for (var x = 0; x < item.child.length; x++)
		{
			item.child[x].item = "<img src=../pic/qt.png style=height:16px>&nbsp;" +  StrAdd(item.child[x].ClassCode, item.child[x].Class_Name);
			item.child[x].style = "font:normal bolder normal 14px 黑体;"
			item.child[x].nType = 61;
			item.child[x].child = null;
		}
		tree.loadnodeok(item, div);		
	};
	
	var fun7 = function(data)	//往期课程
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json;
		for (var x = 0; x < item.child.length; x++)
		{
			item.child[x].item = "<img src=../pic/calendar16.gif style=height:16px>&nbsp;" +  item.child[x].Term_Name;
			item.child[x].nType = 71;
			item.child[x].child = null;
//			CheckItemInCourse(item.child[x], 1);
		}
		tree.loadnodeok(item, div);		
	};
	
	var fun8 = function(data)	//公共单元
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = DealUnitCourse(json.Mode, json.Course, 0);
		tree.loadnodeok(item, div);	
	};
		
	var fun31 = function(data)	//最新专题
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json.Data;
		for (var x = 0; x < item.child.length; x++)
		{
			item.child[x].item = "<img src=../pic/wendang.png style=height:16px>&nbsp;" + StrAdd(item.child[x].Subject_name, item.child[x].Teacher_name);
			item.child[x].nType = 32;
//			CheckItemInCourse(item.child[x], 1);
		}
		tree.loadnodeok(item, div);		
	};
	
	var fun9 = function (data)	//公共课程
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json;
		for (var x = 0; x < item.child.length; x++)
		{
			item.child[x].item = "<img src=../pic/yjs6.png style=height:16px>&nbsp;" + StrAdd(item.child[x].Course_name, item.child[x].Teacher_name);
			item.child[x].nType = 12;
//			CheckItemInCourse(item.child[x], 1);
		}
		tree.loadnodeok(item, div);		
		
	};
	
	switch (item.nType)
	{
	case 2:	//最新专题
		$.get(location.pathname,{getNewSubject:1}, fun31);
		break;
	case 3:	//专题库
		$.get("../fvs/CPB_Subject_Class_view.jsp",{GetTreeData:1, nFormat:0}, fun3);
		break;
	case 4:	//教学活动
		$.get("../fvs/CPB_Activity_list.jsp",{GetTreeData:1, OrderField:"Activity_id"}, fun4);
		break;
	case 5:	//剪贴薄
		var oClip = CourseEditor.getClip();
		item.child = [];
		var cnt = 0;
		for (var x = 0;  x < oClip.clipUnits.length; x++)
		{
			var o = $.extend(true, {}, oClip.clipUnits[x]);
			item.child[cnt ++] = o;
			o.refClip = x;
			o.item = "<img src=../pic/flow_bs_manage.png>教学单元:" + o.Mode_Name;
			o.nType = 51;
			for (var y = 0; y < o.child.length; y++)
			{
				if (o.child[y].Style_Name == undefined)
				{
					o.child[y].item =  "<img src=../pic/flow_bs_manage.png>教学模块:" + o.child[y].Mode_Name;
					o.child[y].nType = 52;
				}
				else
				{
					o.child[y].item =  "<img src=../pic/flow_bs_manage.png>教学形式:" + o.child[y].Style_Name;
					o.child[y].nType = 53;
					o.child[y].refClip = [x, y];
				}
				
				if (o.child[y].Course.length > 0)
				{
					o.child[y].child = o.child[y].Course;
					for (var z = 0; z < o.child[y].child.length; z++)
					{
						o.child[y].child[z].item = "<img src=../pic/flow_bs_manage.png>课程:" + o.child[y].child[z].Course_name;
						o.child[y].child[z].nType = 54;
						o.child[y].child[z].refClip = [x, y, z];
					}
				}
			}
			
			var z = o.child.length;
			for (var y = 0; y < o.Course.length; y++)
			{
				o.child[z] = o.Course[y];
				o.child[z].item = "<img src=../pic/flow_bs_manage.png>课程:" + o.Course[y].Course_name;
				o.child[z].nType = 54;
				o.child[z++].refClip = [x, y];
			}
		}

		for (var x = 0; x < oClip.clipSubUnits.length; x++)
		{
			item.child[cnt ++] = oClip.clipSubUnits[x];
			if (oClip.clipSubUnits[x].Style_Name == undefined)
				oClip.clipSubUnits[x].item = "<img src=../pic/flow_bs_manage.png>教学模块:" + oClip.clipSubUnits[x].Mode_Name;
			else
				oClip.clipSubUnits[x].item = "<img src=../pic/flow_bs_manage.png>教学形式:" + oClip.clipSubUnits[x].Style_Name;
				
			if (oClip.clipSubUnits[x].Course.length > 0)
			{
				oClip.clipSubUnits[x].child = oClip.clipSubUnits[x].Course;
				for (var y = 0; y < oClip.clipSubUnits[x].child.length; y++)
					oClip.clipSubUnits[x].child[y].item = "<img src=../pic/flow_bs_manage.png>课程:" + StrAdd(oClip.clipSubUnits[x].child[y].Course_name, oClip.clipSubUnits[x].child[y].Teacher_name);
			}
		}			

		for (var x = 0; x < oClip.clipCourses.length; x++)
		{
			item.child[cnt ++] = oClip.clipCourses[x];
			oClip.clipCourses[x].item = "<img src=../pic/flow_bs_manage.png>课程:" + StrAdd(oClip.clipCourses[x].Course_name, oClip.clipCourses[x].Teacher_name);
			oClip.clipCourses[x].nType = 54;
			oClip.clipCourses[x].refClip = x;
		}
		
		tree.loadnodeok(item, div);
		break;
	case 6:	//近期课程
		$.get(location.pathname,{getLastClass:1, DataID:jsonClass.Class_id}, fun6);
		break;
	case 7:	//往期课程
		$.get(location.pathname,{getOldTerm:1, DataID:jsonClass.Class_id}, fun7);
		break;
	case 8:		//公共单元
		$.get(location.pathname,{getCommUnit:1, DataID:jsonClass.Class_id, Term_id:jsonClass.Term_id}, fun8);
		break;
	case 9:		//公共课程
		$.get(location.pathname,{getCommCourse:1, DataID:jsonClass.Class_id, Term_id:jsonClass.Term_id}, fun9);
		break;
	case 31:	//专题分类
		$.get("../fvs/CPB_Subject_list.jsp",{GetGridData:1, SeekKey:"CPB_Subject.Subject_class_id", SeekParam:item.Subject_Class_id}, fun31);
		break;
	case 61:	//班级课程
		$.get(location.pathname,{getClassCourseData:1, DataID:item.Class_id}, fun1);
		break;
	case 71:	//学期
		$.get(location.pathname,{getOldClass:1, Term_id:item.Term_id}, fun6);
		break;
//	case 81:	//单元下的课程
//		$.get(location.pathname,{getCommUnitCourse:1, DataID:jsonClass.Class_id, Mode_id:item.Mode_id}, fun81);
//		break;
	}
}

function RemoveCourseRef(item)
{
	if (item.RefID <= 0)
		return;
	if (item.Course_name == undefined)
		return;
	if (window.confirm("将要移除此项公共课？是否确定？") == false)
		return;
	$.get(location.pathname,{RemoveCourseRef:1, CourseID:item.Course_id}, function(data){alert(data);});
}

function TreeDblClick(obj)
{
	var item = tree.getTreeItem(obj);
	if (item.child == null)
		return tree.expand(obj);		
	switch (item.nType)
	{
	case 8:	//公共单元
		CourseEditor.ApplyUnits(item.child);
		break;
	case 11:	//单元
		CourseEditor.ApplyOneUnit(item, true);
		CourseEditor.Option(option);
		break;
	case 12:	//单元内课程或公共课程
		if (event.shiftKey)
			return RemoveCourseRef(item);
		CourseEditor.ApplyCourseItem(item);
		break;
	case 13:	//选修课下的时间或？
		break;
	case 32:	//专题
		CourseEditor.ApplyCourseItem(item);
		break;
	case 51:	//剪贴薄单元
		var oClip = CourseEditor.getClip();
		CourseEditor.ApplyOneUnit(oClip.clipUnits[item.refClip]);
		oClip.clipUnits.splice(item.refClip, 1);
		ReloadClip();
		CourseEditor.Option(option);
		break;
	case 52:	//剪贴薄单元中的模块
	case 53:	//剪贴薄中的教学形式
		break;
	case 54:	//剪贴薄下的教学模块或形式下的课程或模块下的课程或课程
		if (CourseEditor.ApplyCourseItem(item, true) != true)
			return;
		var oClip = CourseEditor.getClip();
		if (typeof item.refClip == "number")
			oClip.clipCourses.splice(item.refClip, 1);
		else
		{
			if (item.refClip.length == 3)
				oClip.clipUnits[item.refClip[0]].child[item.refClip[1]].Course.splice(item.refClip[2], 1);
			else
				oClip.clipUnits[item.refClip[0]].Course.splice(item.refClip[1], 1);
		}
		ReloadClip();
		break;
	case 61:	//班级课程
		CourseEditor.ApplyUnits(item.child);
		break;
	}
}
var ConfigWin;
var planOptionFields = ["CourseShowMode", "CourseNoMode", "CourseNameMode", "TeacherShowMode", "OuterTeacherShowMode", "CourseNameEditEnable",
 	"CourseTimeEnable", "TeacherEditEnable", "TeacherUnitEditEnable", "CourseLayerMode", "CourseFreeInfo", "ActivityMode", "CourseShowRed", "CommonUnitCourseEditEnable"];
function CourseConfig()
{
	if (typeof ConfigWin == "object")
		return ConfigWin.show();
	ConfigWin = new $.jcom.PopupWin("<div id=PlanCourseConfig style=width:100%;height:100%;padding:8px;>" +
			"<span style=width:120px>课程显示结构</span>" +
			"<input name=CourseShowMode type=radio checked value=0>单元-教学形式-课程&nbsp;<input name=CourseShowMode type=radio value=1>单元-模块-课程" +
			"<br><span style=width:120px>课程序号编排方式</span><input name=CourseNoMode type=radio checked value=0>按段落编排&nbsp;&nbsp;<input name=CourseNoMode type=radio value=1>整体编排" +
			"<br><span style=width:120px>课程名称显示方式</span><input name=CourseNameMode type=radio checked value=0>仅显示名称&nbsp;<input name=CourseNameMode type=radio value=1>显示教学形式:名称&nbsp;&nbsp;" +
			"<br><span style=width:120px>编辑课程名称</span><input name=CourseNameEditEnable type=radio checked value=0>不允许&nbsp;&nbsp;<input name=CourseNameEditEnable type=radio value=1>允许&nbsp;<input name=CourseNameEditEnable type=radio value=2>由教学形式决定" +
			"<br><span style=width:120px>课程排版方式</span><input name=CourseLayerMode type=radio checked value=0>课程和授谭人均居左&nbsp;<input name=CourseLayerMode type=radio value=1>课程居左，授课人居右" +
			"<br><span style=width:120px>本校授课人显示方式</span><input name=TeacherShowMode type=radio checked value=0>显示姓名&nbsp;&nbsp;<input name=TeacherShowMode type=radio value=1>显示姓名+部门&nbsp;" +
			"<br><span style=width:120px>外请授课人显示方式</span><input name=OuterTeacherShowMode type=radio checked value=0>显示姓名（外请）&nbsp;&nbsp;<input name=OuterTeacherShowMode type=radio value=1>显示姓名+单位&nbsp;" +
			"<br><span style=width:120px>编辑授课人</span><input name=TeacherEditEnable type=radio checked value=0>不允许&nbsp;&nbsp;<input name=TeacherEditEnable type=radio value=1>允许&nbsp;" +
			"<br><span style=width:120px>编辑授课人说明</span><input name=TeacherUnitEditEnable type=radio checked value=0>不允许&nbsp;&nbsp;<input name=TeacherUnitEditEnable type=radio value=1>允许&nbsp;" +
			"<br><span style=width:120px>显示编辑课程时长</span><input name=CourseTimeEnable type=radio checked value=0>不允许&nbsp;&nbsp;<input name=CourseTimeEnable type=radio value=1>允许&nbsp;" +
			"<br><span style=width:120px>选修课显示内容</span><input name=CourseFreeInfo type=radio checked value=0>课程+授课人&nbsp;&nbsp;<input name=CourseFreeInfo type=radio value=1>时间+课程+授课人+地点" +
			"<br><span style=width:120px>教学活动处理方式</span><input name=ActivityMode type=radio checked value=0>按专题处理&nbsp;&nbsp;<input name=ActivityMode type=radio value=1>单独处理&nbsp;&nbsp;" +
			"<br><span style=width:120px>标红非专题库中课程</span><input name=CourseShowRed type=radio checked value=0>否&nbsp;&nbsp;<input name=CourseShowRed type=radio value=1>是&nbsp;&nbsp;" +
			"<br><span style=width:120px>编辑公共单元与课程</span><input name=CommonUnitCourseEditEnable type=radio checked value=0>不允许&nbsp;&nbsp;<input name=CommonUnitCourseEditEnable type=radio value=1>允许&nbsp;&nbsp;" +
			"<br><br><center><input type=button value=保存为本班配置 onclick=ConfirmPlanOption(1)>&nbsp;<input type=button value=保存为全校配置 onclick=ConfirmPlanOption(2)></center></div>", 
			{title:"设置选项", width:420, height:460});
	ConfigWin.close = ConfigWin.hide;
	for (var x = 0; x < planOptionFields.length; x++)
	{
		var o = $("input[name='" + planOptionFields[x] + "']");
		o.eq(option[planOptionFields[x]]).prop("checked", true);
	}
}
function ConfirmPlanOption(nType)
{
	for (var x = 0; x < planOptionFields.length; x++)
	{
		var o = $("input[name='" + planOptionFields[x] + "']");
		for (var y = 0; y < o.length; y ++)
		{
			if (o.eq(y).prop("checked"))
					option[planOptionFields[x]] = parseInt(o.eq(y).val());
		}
	}

	var fun = function (data)
	{
		if (data != "OK")
			alert(data);
		ConfigWin.hide();
		CourseEditor.Option(option);
	}
	
	var tag = "";
	for (var key in option)
		tag += "&" + key + "=" + option[key];
	$.jcom.Ajax(location.pathname + "?SavePlanOption=1&ClassID=" + jsonClass.Class_id + "&nType=" + nType + tag, true, "", fun);	
}


function ClearSearch()
{
//	var data = tree.getdata();
//	if (data == rootItems)
//	{		
//		$("#SearchInput")[0].fireEvent("onmousedown");
//		return;
//	}
	$("#SearchInput").html("");
	SearchEdit.checkTitle($("#SearchInput")[0], false);
	tree.setdata(rootItems);
	CheckSearchButton();
}

function DocSearch(value)
{
	if (value == "")
		return;
	$.get(location.pathname + "?SearchSubject=1&SeekKey=" + value, {}, DocSearchOK);
}

function DocSearchOK(data)
{
	var list = eval(data);
	for (var x = 0; x < list.length; x++)
	{
		if (list[x].Teacher_name == "")
		{
			list[x].Teacher_name = list[x].Informant_name;
			list[x].Teacher_id = list[x].Informant_id;
		}
		list[x].item = "<img src=../pic/384.png style=height:16px>&nbsp;" + list[x].Subject_name + "-" + list[x].Teacher_name;
		list[x].nType = 32;
//		CheckItemInCourse(item.child[x], 1);
	}
	tree.setdata(list);	
}

function SetSearchButton()
{
	$("#SearchButton").attr("src", "../pic/delete1.gif");
}

function CheckSearchButton()
{
	var data = tree.getdata();
	if (data == rootItems)
		$("#SearchButton").attr("src","../pic/search.png");
	else
		$("#SearchButton").attr("src", "../pic/delete1.gif");
}
var importPlanWin;
function ImportPlan()
{
  importPlanWin = new $.jcom.PopupWin("<div id=ImportForm style=width:100%;height:100%><textarea id=PlanText style=width:100%;height:540px></textarea>" +
    "<div>提示：请先将电子版的教学计划文本复制后粘贴到此处。   <input type=button value=导入 onclick=RunImportPlan(this)></div></div>", 
      {title:"导入教学计划", mask:50, width:640, height:600, resize:0});
}

function RunImportPlan(obj)
{
	PlanAttachEditor(false);
	obj.disabled = true;
	obj.value = "正在导入...";
	var texts = $("#PlanText")[0].innerText.split("\n");
	var tmpl = [{key:"一、教学目的", id:"train_goal"},
				{key:"二、学习时间", id:"train_time"},
				{key:"三、教学方法", id:"train_style"},
				{key:"四、教学内容安排", id:"train_content"},
				{key:"导学", id:"CourseBegin"},
				{key:"五、学习要求", id:"train_claim"},
				{key:"六、教学计划的实施", alias:"六、教学计划实施", id:"PlanPara1"},
				{key:"七、学习参考书目", id:"Books"},
				{key:"八、其它", id:"PlanNote"}];

	for (var x = 0, y = 0; x < texts.length; x++)
	{
		if ((texts[x].indexOf(tmpl[y].key) >= 0) || (texts[x].indexOf(tmpl[y].alias) >=0))
		{
			tmpl[y].pos = x;
			x ++;
			if (y ++ >= tmpl.length - 1)
				break;
		}
	}
	
	var oklog = "";
	tmpl[tmpl.length] = {id:"TheEnd", pos: texts.length - 1};
	for (var x = 0; x < tmpl.length - 1; x ++)
	{
		if ((tmpl[x].pos == undefined) || (tmpl[x + 1].pos == undefined))
		{
			oklog += "导入段落失败，未找到段落:" + tmpl[x].key + "\n";
			continue;
		}
		oklog += "导入段落成功:" + tmpl[x].key + "\n";
		
		var value = texts[tmpl[x].pos + 1];
		for (var y = tmpl[x].pos + 2; y < tmpl[x + 1].pos; y++)
			value += "<br>" + texts[y];
		value = value.replace(/ /g, "&nbsp;&nbsp;");
		jsonClass[tmpl[x].id] = value;
		$("#" + tmpl[x].id).html(value);
	}
	oklog += ImportPlanCourse(texts, tmpl[4].pos, tmpl[5].pos);
	var aUnit = CourseEditor.getUnits();
	RemoveOld(aUnit);
	$("#PlanText").val(oklog + "\n正在自动对应导入课程的专题编号...\n");
	coursecnt = 0;
	AutoFindSubjectID(aUnit, $("#PlanText"), 0, 0, 0);
	CourseEditor.Option(option);
	PlanAttachEditor(true);
	obj.value = "导入完成";
}
var coursecnt = 0;
function AutoFindSubjectID(aUnit, txtobj, xx, yy, zz)
{
	var fun = function (data)
	{
		item.Subject_id = parseInt(data);
		txtobj.val(txtobj.val() + coursecnt++ + "." + item.Course_name + "所对应的专题编号是" + item.Subject_id + "\n");
		AutoFindSubjectID(aUnit, txtobj, x, y, z);
	};
	
	for (var x = xx; x < aUnit.length - 1; x++, yy = 0, zz = 0)
	{
		
		if ((typeof aUnit[x].child == "object") && (yy < aUnit[x].child.length))
		{		
			for (var y = yy; y < aUnit[x].child.length; y++, zz = 0)
			{
				for (var z = zz; z < aUnit[x].child[y].Course.length; z++)
				{
					var item = aUnit[x].child[y].Course[z];
					if (item.Subject_id == 0)
					{
						$.jcom.Ajax(location.pathname + "?FindSubjectByName=1&Subject_name=" + item.Course_name +
							"&Teacher_name=" + item.Teacher_name, true, "", fun);
						z++;
						return;
					}
				}
			}
		}
		y = 999;
		for (var z = zz; z < aUnit[x].Course.length; z++)
		{
			var item = aUnit[x].Course[z];
			if (item.Subject_id == 0)
			{
				$.jcom.Ajax(location.pathname + "?FindSubjectByName=1&Subject_name=" + item.Course_name +
						"&Teacher_name=" + item.Teacher_name, true, "", fun);
				z++;
				return;	
			}
		}
	}
	CourseEditor.Option(option);
}

function RemoveOld(aUnit)
{
	for (var x = aUnit.length - 1; x >= 0; x--)
	{
		if (aUnit[x].newflag != 1)
		{
			var dels = aUnit.splice(x, 1);
			CourseEditor.RemoveUnit(dels[0]);
			continue;
		}
		else
			delete aUnit[x].newflag;
		
		for (var y = aUnit[x].Course.length - 1; y >= 0; y--)
		{
			if (aUnit[x].Course[y].newflag != 1)
			{
				var del = aUnit[x].Course.splice(y, 1);
				CourseEditor.RemoveCourse(del[0]);
			}
			else
				delete aUnit[x].Course[y].newflag;
		}
		
		if (typeof aUnit[x].child == "object")
			RemoveOld(aUnit[x].child);
	}

}


function ImportPlanCourse(texts, b, e)
{
	var log = "";
	if ((b == undefined) || (e == undefined))
		return log;
	var aUnit = CourseEditor.getUnits();
	var upos = 0, spos = 0, cpos = 0;
	for (var x = b; x < e; x++)
	{
		var text = $.trim(texts[x]);
		var lineType = getLineType(text);
		if (lineType == 0)
			continue;
		switch (lineType)
		{
		case 10:	//普通单元
		case 11:	//特殊单元
		case 12:	//选修课
		case 15:	//特殊单元+公共单元
		case 16:	//选修课+公共单元
			var u = scanUnitName(text);
			log += "导入单元成功:" + u.Mode_Name + "\n";
			ImportUnit(aUnit, u, upos++, lineType);
			spos = 0;
			cpos = 0;
			break;
		case 20:	//单元下面的教学日或学习日
			aUnit[upos-1].Mode_time = getUnitTime(text);
			break;
		case 30:	//单元下的教学模块
			var u = scanSubUnitName(text);
			log += "导入单元下的教学模块成功:" + u.Mode_Name + "\n";
			ImportSubUnit(aUnit[upos - 1].child, u, spos++);
			break;
		case 40:	//课程
			var text1 = texts[x + 1];
			var nexttype = getLineType(text1);
			if (nexttype == 60)
				x ++;
			else
				text1 = "";
			var c = scanCourse(text, text1);
			if ((spos > 0) && (aUnit[upos - 1].child[spos - 1].value != undefined))
			{
				c.Note = aUnit[upos - 1].child[spos - 1].value;
				var r = c.Teacher_name.match(/\(|（/g);
				if (r != null)
				{
					c.room = c.Teacher_name.substr(r.lastIndex, c.Teacher_name.length - r.lastIndex - 1);
					c.Teacher_name = c.Teacher_name.substr(0, r.lastIndex - 1);
					c.Note += "|" + c.room;
				}
			}
			ImportCourse(aUnit, c, upos - 1, spos - 1, cpos++);
			break;
		case 50:	//选修课下的日期
			var y = $.jcom.makeDateObj(jsonClass.Class_BeginTime).getFullYear();
			var d = $.jcom.makeDateObj(y + "年" + text);
			var t = $.jcom.GetDateTimeString(d, 1) + " 15:00";
			aUnit[upos - 1].child[spos++] = {Time:text, value:t, Course:[], newflag:1};
			break;
		case 60:	//其它类型
			break;
		}
	}
	return log;
}

function getLineType(s, lastType)
{
	if (s == "")
		return 0;
	var pos = s.search(/\d+[\.．、]/);
	if (pos >= 0)
		return 40;
	var lTmpl = [{key:"导学",type:11},
		{key:"单元", type:10}, {key:"教学模块", type:30},
		{key:"周五大讲坛", type:15}, {key:"高端讲坛",type:15},
		{key:"区情讲坛", type:15}, {key:"专题报告", type:15},
		{key:"时政专题", type:15}, {key:"晚聚习", type:15}, 
		{key:"学员讲堂", type:15}, {key:"选修课", type:16},
		{key:"网上学习", type:15},
		{key:"学习日", type:20}, {key:"教学日", type:20}
	];
	for (var x = 0; x < lTmpl.length; x++)
	{
		var pos = s.indexOf(lTmpl[x].key); 
		if ((pos >= 0) && (pos <= 6))
			return lTmpl[x].type;		
	}
	var pos = s.search(/\d+月\d+日/);
	if (pos >=0)
		return 50;
	return 60;
}

function scanUnitName(text)
{
	var pos = text.search(/[\(\s\:（：]/g);
	var u = CourseEditor.getBlankUnit();
	if (pos > 0)
	{
		u.Mode_Name = text.substr(0, pos);
		var s = $.trim(text.substr(pos + 1));
		var t = getUnitTime(s);
		if (t != undefined)
			u.Mode_time = t;
		else
		{
			if (u.Mode_Name.indexOf("单元") > 0)
				u.Mode_Name = s;
			else
				u.Mode_Note = s;
		}
	}
	else
		u.Mode_Name = text;
	if (u.Mode_Name.substr(0, 1) == "*")
	{
		u.Mode_name = u.Mode_name.substr(1);
		u.RefID = -1;		
	}
	return u;
}

function scanSubUnitName(text)
{
	var pos = text.search(/[\s\:：]/g);
	var u = CourseEditor.getBlankUnit(true);
	if (pos > 0)
		u.Mode_Name = $.trim(text.substr(pos + 1));
	return u;
}

function getUnitTime(s)
{
	var pos = s.search(/教学日|学习日/);
	if (pos > 0)
	{
		var r = s.match(/\d+/);
		if (r.length > 0)
			return parseInt(r[0]);
	}
}

function scanCourse(text, text1)
{
	var c = CourseEditor.getBlankCourse(0);
	var pos = text.search(/[\.．、]/g);
	if (pos >= 0)
		text = $.trim(text.substr(pos + 1));
	pos = text.search(/\s/);
	if (pos > 0)
	{
		c.Course_name = text.substr(0, pos);
		c.Teacher_name = $.trim(text.substr(pos + 1));
	}
	else
	{
		var s = $.trim(text1);
		pos = text1.search(/\S/);
		if (pos > 6)
		{
			c.Course_name = text;
			c.Teacher_name = s;
		}
		else
		{
			pos = s.search(/\s/);
			if (pos > 0)
			{
				c.Teacher_name = $.trim(s.substr(pos + 1));
				c.Course_name = text + s.substr(0, pos);
			}
			else
				c.Course_name = text + s;
		}
	}
	pos = c.Course_name.search(/(\(|（)\d天(\)|）)/);		//
	if (pos > 0)
	{
		c.Course_time = parseFloat(c.Course_name.substr(pos + 1));
		c.Course_name = c.Course_name.substr(0, pos);
	}
	if (c.Course_name.substr(0, 1) == "*")	//公共课程记号
	{
		c.Course_name = c.Course_name.substr(1);
		c.RefID = -1;
	}
	return c;
}

function ImportUnit(aUnit, u, pos, prop)
{
	for (var x = 0; x < aUnit.length; x++)
	{
		if (aUnit[x].Mode_Name == u.Mode_Name)
		{
			aUnit[x].newflag = 1;
			if (x == pos)
				return;
			var del = aUnit.splice(x, 1);
			aUnit.splice(pos, 0, del[0]);
			return;
		}
	}
	prop = prop % 10;
	if (((prop & 4) >> 2) > 0)
		u.RefID = -1;
	u.Mode_other = prop & 3;
	aUnit.splice(pos, 0, u);
	aUnit[pos].newflag = 1;
}

function ImportSubUnit(SubUnits, u, pos)
{
	for (var x = 0; x < SubUnits.length; x++)
	{
		if (SubUnits[x].Mode_Name == u.Mode_Name)
		{
			SubUnits[x].newflag = 1;
			if (x == pos)
				return;
			var del = SubUnits.splice(x, 1);
			SubUnits.splice(pos, 0, del[0]);
			return;
		}
	}
	u.newflag = 1;
	SubUnits.splice(pos, 0, u);
}

function getCourseByPlan(aUnit, Course)
{
	for (var x = 0; x < aUnit.length; x++)
	{
		for (var y = 0; y < aUnit[x].Course.length; y++)
		{
			if (aUnit[x].Course[y].Course_name == Course.Course_name)
			{
				var del = aUnit[x].Course.splice(y, 1);
				return del[0];
			}
		}
		
		for (var y = 0; y < aUnit[x].child.length; y++)
		{
			for (var z = 0; z < aUnit[x].child[y].Course.length; z++)
			{
				if (aUnit[x].child[y].Course[z].Course_name == Course.Course_name)
				{
					var del = aUnit[x].child[y].Course.splice(z, 1);
					return del[0];
				}
			}
		}		
	}
}

function ImportCourse(aUnit, Course, upos, spos, cpos)
{
	var c = getCourseByPlan(aUnit, Course);
	if (c != undefined)
	{
		Course.Subject_id = c.Subject_id;
		Course.Course_id = c.Course_id;
//		Course.Course_name = "*" + Course.Course_name;
	}
	var u = aUnit[upos];
	if (spos >= 0)
		u = u.child[spos];
	Course.newflag = 1;
	u.Course.splice(cpos + 1, 0, Course);
}

function DblClickPlan(nType, obj, item, event)
{
	switch (nType)
	{
	case 1:
	case 2:
		break;
	case 3:
		CheckCourse(obj, item, event);
		break;
	}
}

var checkCourseBox, courseItem;
function CheckCourse(obj, item, event)
{
	if (item.Course_name == "")
		return;
	courseItem = item;
	var tag = "&nbsp;您可以<span style=cursor:hand;color:blue onclick=CheckCourseValue(1)>按专题名称检索</span>, " +
				"&nbsp;还可以:<span style=cursor:hand;color:blue onclick=CheckCourseValue(2)>按授课人检索</span>";
	CheckCourseValue(1);
	var fun = function (data)
	{
		alert(data);
	};
	if (item.Subject_id == 0)
	{
		tag = "&nbsp;<input id=SaveCourseToSubject type=button value=将课程加入专题库 onclick=SaveCourseToSubject(this)>" +
			"<br>&nbsp;提示：请先专题查重，在确定专题库中无此专题时，才应将课程加入专题库 。<br>为有效查重，<br>" + tag;
	}
	else
		tag += "<br>&nbsp;如果您发现课程对应的新专题名称或授课人不准确，<br>您还可以直接修改课程名称和授课人，并修改后:<input id=SaveCourseToSubject type=button value=保存到专题库 onclick=SaveCourseToSubject(this)>&nbsp;";
	var pos = $.jcom.getObjPos(obj);
	if (checkCourseBox == undefined)
	{
		checkCourseBox = new $.jcom.PopupBox("", pos.left, pos.top, pos.left, pos.bottom - 1);
		var o = checkCourseBox.getdomobj();
		o.style.border = "1px solid gray";
		o.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
	}
	checkCourseBox.setPopObj(tag);
	checkCourseBox.show(pos.left, pos.top, pos.left, pos.bottom - 1);
	$("#SaveCourseToSubject").attr("disabled", false)
	$(document).on("mousedown",CourseBoxHide);
}


function SaveCourseToSubject(obj)
{
	var fun = function (data)
	{
		courseItem.Subject_id = parseInt(data);
		var o = $("Q", CourseEditor.getFocusObj());
		o.css("color", "black");
		checkCourseBox.hide();
	}
	$.jcom.Ajax(location.pathname + "?SaveCourseToSubject=1&Subject_id=" + courseItem.Subject_id + "&Subject_name=" + courseItem.Course_name +
		"&Teacher_name=" + courseItem.Teacher_name + "&Department=" + courseItem.Department, true, "", fun);	
	obj.disabled = true;	
}

function CourseBoxHide(e)
{
	var b = checkCourseBox.getdomobj();
	if ((b == e.target) || ($(e.target).parents().is($(b))))
		return;
	$(document).off("mousedown",CourseBoxHide);
	checkCourseBox.hide();	
}

function CheckCourseValue(ntype)
{
	if (ntype == 1)
		var value = courseItem.Course_name;
	else
		var value = courseItem.Teacher_name;
		
	$("#SearchInput").html(value);
	SearchEdit.preshow({target:$("#SearchInput")[0]});
	DocSearch(value);
}

//(归档用注释,切勿删改) 客户端载入时 End##@@
</script></html>
