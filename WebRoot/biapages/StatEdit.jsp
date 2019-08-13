<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
//@@##185:�������û��Զ�����������(�鵵��ע��,����ɾ��)
//
private static int statSaveItem(JDatabase jdb, int statPlanId, int InvestDetailId, int answerDetailId, int comId, int statSysDetailId, 
	int statMethodId, String statName, double sValue, double fillValue)
{//����ĳͳ�Ʒ���ĳͳ���������ֵ
	if (statSysDetailId > 0)
	{
		String itemCName = jdb.getStringBySql(0, "select itemCName from asSysDetail where ID=" + statSysDetailId);
		if (statName.equals(""))
			statName = itemCName;
		else
			statName = itemCName + "." + statName;
	}
	String sql = "select ID from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + InvestDetailId
		+ " and answerDetailId=" + answerDetailId + " and comId=" + comId + " and statSysDetailId=" + statSysDetailId + " and statMethodId=" + statMethodId;
	int id = jdb.getIntBySql(0, sql);
	if (id > 0)
		sql = "update asStatResult set sValue=" + sValue + ", fillValue=" + fillValue + ", statName='" + statName + "' where ID=" + id;
	else
		sql = "insert into asStatResult(statPlanId, InvestDetailId, answerDetailId, comId, statSysDetailId, statMethodId, statName, sValue, fillValue) values(" +
			statPlanId + "," + InvestDetailId + "," + answerDetailId + "," + comId + "," + statSysDetailId + "," + statMethodId +
			",'" + statName + "'," + sValue + "," + fillValue + ")";
	jdb.ExecuteSQL(0, sql);
	return 1;
}

private static int statSaveRank(JDatabase jdb, int statPlanId, int InvestDetailId, int comId, int statSysDetailId, 
	int statMethodId, String fieldName, String value)
{
	int id = jdb.getIntBySql(0, "select ID from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + InvestDetailId
		  + " and comId=" + comId + " and statSysDetailId=" + statSysDetailId + " and statMethodId=" + statMethodId);
	if (id > 0)
	{
		String sql = "update asStatResult set " + fieldName + "=" + value + " where ID=" + id;		
		jdb.ExecuteSQL(0, sql);
	}
	return 1;

}

private static int statGetMethod(JDatabase jdb, int statItemType, int statDataType, String statName)
{//���ĳͳ�Ʒ���ĳָ����ָ�����㷽��
	int methodId = jdb.getIntBySql(0, "select ID from asStatMethod where nType=" + statItemType + " and name='" + statName + "'");
	if (methodId > 0)
		return methodId;
	jdb.ExecuteSQL(0, "insert into asStatMethod (name, bSel, nType, dataType) values('" +statName + "',0," + statItemType + "," + statDataType + ")");
	methodId = jdb.getIntBySql(0, "select ID from asStatMethod where nType=" + statItemType + " and name='" + statName + "'");
		
	return methodId;
}
private static int statSaveTotal(JDatabase jdb, int statPlanId, int InvestDetailId, int statSysDetailId, 
	double totalVal, double maxVal, double minVal, int count)
{//���㲢����ĳͳ�Ʒ���ĳָ����ܺͣ����ֵ��
	int dataType = jdb.getIntBySql(0, "select dataType from asSysDetail where ID=" + statSysDetailId);
	String name = "�ܺ�";
	int methodId = statGetMethod(jdb, 2, dataType, name);
	statSaveItem(jdb, statPlanId, InvestDetailId, 0, 0, statSysDetailId, methodId, name, 0, totalVal);

	name = "���ֵ";
	methodId = statGetMethod(jdb, 2, dataType, name);
	statSaveItem(jdb, statPlanId, InvestDetailId, 0, 0, statSysDetailId, methodId, name, 0, maxVal);
	
	name = "��Сֵ";
	methodId = statGetMethod(jdb, 2, dataType, name);
	statSaveItem(jdb, statPlanId, InvestDetailId, 0, 0, statSysDetailId, methodId, name, 0, minVal);

	name = "����";
	methodId = statGetMethod(jdb, 2, 13, name);
	statSaveItem(jdb, statPlanId, InvestDetailId, 0, 0, statSysDetailId, methodId, name, 0, count);
	
	name = "����";
	methodId = statGetMethod(jdb, 2, dataType, name);
	statSaveItem(jdb, statPlanId, InvestDetailId, 0, 0, statSysDetailId, methodId, name, 0, maxVal - minVal);
	
	name = "ƽ��ֵ";
	methodId = statGetMethod(jdb, 2, 7, name);
	statSaveItem(jdb, statPlanId, InvestDetailId, 0, 0, statSysDetailId, methodId, "ƽ��ֵ", 0, totalVal / count);
	return 1;
}

private static void statFillValTotal(JDatabase jdb, int statPlanId, int investDetailId, String companys) throws SQLException
{//���㲢����ĳͳ�Ʒ�����Ҷ���ĳָ����ܺͣ����ֵ��
	int oldSysDetailId = -1;
	double totalValue = 0, maxValue = 0, minValue = 99999;
	int count = 0;
	String sql = "select asSysDetailId, sValue from asAnswerDetail where answerId in (select ID from asAnswer where PlanDetailId=" +
		investDetailId + " and comId in(" + companys + ")) order by asSysDetailId";
	if (investDetailId == 0)
		sql = "select statSysDetailId as asSysDetailId, fillValue as sValue from asStatResult where statPlanId=" + statPlanId +
			" and InvestDetailId=0 and comId in(" + companys + ") order by statSysDetailId";
	ResultSet rs = jdb.rsSQL(0, sql);
	while (rs.next())
	{
		int asSysDetailId = rs.getInt("asSysDetailId");
		double v = WebChar.ToDouble(rs.getString("sValue"));
		if (asSysDetailId != oldSysDetailId)
		{
			if (oldSysDetailId != -1)
			{
				statSaveTotal(jdb, statPlanId, investDetailId, oldSysDetailId, totalValue, maxValue, minValue, count);			
				totalValue = 0;
				maxValue = v;
				minValue = v;
				count = 0;
			}
			oldSysDetailId = asSysDetailId;
		}
		count ++;
		totalValue += v;
		if (v > maxValue)
			maxValue = v;
		if (v < minValue)
			minValue = v;
	}
	if (count == 0)
		System.out.println("oldSysDetailId:" + oldSysDetailId);
	else
		statSaveTotal(jdb, statPlanId, investDetailId, oldSysDetailId, totalValue, maxValue, minValue, count);			
	rs.close();
}

private static void statFillValIndex(JDatabase jdb, int statPlanId, int investDetailId, String companys) throws SQLException
{//����Ҷ����ָ��ֵ
	String sql = "select asAnswerDetail.ID, asSysDetailId, sValue, weight, method, answerId from asAnswerDetail" +
		" left join asStatSysDetail on asAnswerDetail.asSysDetailId=asStatSysDetail.sysDetailId where answerId in (select ID from asAnswer where PlanDetailId=" +
		investDetailId + " and comId in(" + companys + ")) and asStatSysDetail.statPlanId=" + statPlanId + " order by asSysDetailId";
	if (investDetailId == 0)
		sql = "select 0 as ID, statSysDetailId as asSysDetailId, fillValue as sValue, weight, method, comId from asStatResult left join asStatSysDetail " +
			"on asStatResult.statSysDetailId=asStatSysDetail.sysDetailId where InvestDetailId=0 and comId in(" + companys + ") and asStatResult.statPlanId=" + statPlanId + " order by statSysDetailId";
	ResultSet rs = jdb.rsSQL(0, sql);
	while (rs.next())
	{
		double v = WebChar.ToDouble(rs.getString("sValue"));
		int asSysDetailId = rs.getInt("asSysDetailId");
		int method = rs.getInt("method");
		double d = 0, r = 0;
		d = getDivisor(jdb, method, statPlanId, investDetailId, asSysDetailId);
		if (d > 0)
			r = v  / d;
		int comId;
		if (investDetailId == 0)
			comId = rs.getInt("comId");
		else
			comId = jdb.getIntBySql(0, "select comId from asAnswer where ID=" + rs.getInt("answerId"));
		statSaveItem(jdb, statPlanId, investDetailId, rs.getInt("Id"), comId, asSysDetailId, 0, "", r, v);					
	}
	rs.close();
}

private static String statChildrenValue(JDatabase jdb, int statPlanId, int asSysMainId, int investDetailId, int comId, int parentId, int depth) throws SQLException
{//����ĳͳ�Ʒ�����ĳ����ָ��ķ�Ҷ����ָ��ֵ
	ResultSet rs = jdb.rsSQL(0, "select ID from asSysDetail where asSysId=" + asSysMainId + " and parentId=" + parentId);
	int cnt = 0;
	double v = 0;
	String r;
	while (rs.next())
	{
		int id = rs.getInt("ID");
		r = statChildrenValue(jdb, statPlanId, asSysMainId, investDetailId, comId, id, depth + 1);	
		double weight = WebChar.ToDouble(jdb.getStringBySql(0, "select weight from asStatSysDetail where statPlanId=" + statPlanId + " and sysDetailId=" + id)); 
		if (r.equals("null"))
		{
			v += WebChar.ToDouble(jdb.getStringBySql(0, "select fillValue from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + investDetailId		
				 + " and comId=" + comId + " and statSysDetailId=" + id + " and statMethodId=0")) * weight;
		}
		else
			v += WebChar.ToDouble(r) * weight;
		cnt ++;
	}
	rs.close();
	if (cnt == 0)
		return "null";
	String name = "";
	int methodId = 0;
	if (parentId == 0)
	{
		name = "��ҵ�ۺ�ָ��";
		methodId = statGetMethod(jdb, 3, 7, name);	
	}
	statSaveItem(jdb, statPlanId, investDetailId, 0, comId, parentId, methodId, name, 999999, v);
	return "" + v;
}

private static void statChildrenTotal(JDatabase jdb, int statPlanId, int asSysMainId, int investDetailId, String companys, int parentId, int depth) throws SQLException
{//���㲢����ĳͳ�Ʒ����ķ�Ҷ���ĳָ����ܺͣ����ֵ��
	ResultSet rs = jdb.rsSQL(0, "select ID from asSysDetail where asSysId=" + asSysMainId + " and parentId=" + parentId);
	while (rs.next())
	{
		int id = rs.getInt("ID");
		ResultSet rs1 = jdb.rsSQL(0, "select fillValue from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + investDetailId		
			+ " and comId in (" + companys + ") and statSysDetailId=" + id + " and statMethodId=0 and sValue=999999");
		double totalValue = 0, maxValue = 0, minValue = 99999;
		int count = 0;
		
		while (rs1.next())
		{
			count ++;
			double v = rs1.getDouble("fillValue");
			totalValue += v;
			if (v > maxValue)
				maxValue = v;
			if (v < minValue)
				minValue = v;
		}
		rs1.close();
		if (count > 0)
			statSaveTotal(jdb, statPlanId, investDetailId, id, totalValue, maxValue, minValue, count);
		statChildrenTotal(jdb, statPlanId, asSysMainId, investDetailId, companys, id, depth + 1);
	}
	rs.close();
}

private static double statChildrenIndex(JDatabase jdb, int statPlanId, int asSysMainId, int investDetailId, int comId, int parentId, int depth) throws SQLException
{//�����Ҷ����ָ��ֵ�����ظýڵ��ָ��ֵ

	double weightsum = WebChar.ToDouble(jdb.getStringBySql(0, "select sum(weight) from asStatSysDetail where statPlanId=" + statPlanId + " and sysDetailId in (" + 
		"select ID from asSysDetail where asSysId=" + asSysMainId + " and parentId=" + parentId + ")"));
	double vv, result = 0, weight;
	
	String name = "";
	int cnt = 0, methodId = 0;
	if (parentId == 0)
	{
		name = "��ҵ�ۺ�ָ��";
		methodId = statGetMethod(jdb, 3, 7, name);	
	}
	double v = WebChar.ToDouble(jdb.getStringBySql(0, "select fillValue from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + 
		investDetailId + " and comId=" + comId + " and statMethodId=" + methodId + " and statSysDetailId =" + parentId));
		
	ResultSet rs = jdb.rsSQL(0, "select statSysDetailId, sValue, fillValue from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + 
		investDetailId + " and comId=" + comId + " and statMethodId=0 and statSysDetailId in (select ID from asSysDetail where asSysId=" + asSysMainId +
		" and parentId=" + parentId + ")");
	while (rs.next())
	{
		int statSysDetailId = rs.getInt("statSysDetailId");
		vv = statChildrenIndex(jdb, statPlanId, asSysMainId, investDetailId, comId, statSysDetailId, depth + 1);
			
		weight = WebChar.ToDouble(jdb.getStringBySql(0, "select weight from asStatSysDetail where statPlanId=" + statPlanId + " and sysDetailId=" + statSysDetailId));
		result += vv * weight / weightsum;
		cnt ++;
	}
	rs.close();
	if (cnt == 0)
		return WebChar.ToDouble(jdb.getStringBySql(0, "select sValue from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + 
			investDetailId + " and comId=" + comId + " and statMethodId=" + methodId + " and statSysDetailId =" + parentId));
	
	if (depth > 1)
	{
		int method = jdb.getIntBySql(0, "select method from asStatSysDetail where statPlanId=" + statPlanId + " and sysDetailId=" + parentId);
		double d = getDivisor(jdb, method, statPlanId, investDetailId, parentId);
		if (d > 0)
			result = v / d;
	}
	statSaveItem(jdb, statPlanId, investDetailId, 0, comId, parentId, methodId, name, result, v);

	return result;
}

private static double getDivisor(JDatabase jdb, int method, int statPlanId, int investDetailId, int asSysDetailId) 
{
	int methodId = 0;
	switch (method)
	{
	case 1:		//ƽ��ֵ�㷨
		methodId = statGetMethod(jdb, 2, 0, "ƽ��ֵ");
		break;
	case 2:		//���ֵ�㷨
		methodId = statGetMethod(jdb, 2, 0, "���ֵ");
		break;
	case 3:		//��Сֵ�㷨
		methodId = statGetMethod(jdb, 2, 0, "��Сֵ");
		break;
	case 4:		//�����㷨
		methodId = statGetMethod(jdb, 2, 0, "����");
		break;
	case 5:		//�ٷֱ��㷨
		methodId = statGetMethod(jdb, 2, 0, "�ܺ�");
		break;
	}
	double d = 0;			
	if (methodId > 0)
		d = WebChar.ToDouble(jdb.getStringBySql(0, "select fillValue from asStatResult where statPlanId=" + statPlanId + 
			" and InvestDetailId=" + investDetailId + " and statSysDetailId=" + asSysDetailId + " and statMethodId=" + methodId));
	return d;
}

private static void statRank(JDatabase jdb, int statPlanId, int asSysMainId, int investDetailId, String companys) throws SQLException
{
	ResultSet rs = jdb.rsSQL(0, "select ID from asSysDetail where asSysId=" + asSysMainId);
	while (rs.next())
	{
		int id = rs.getInt("ID");
		statRankItem(jdb, statPlanId, asSysMainId, investDetailId, companys, id);
	}
	rs.close();
	statRankItem(jdb, statPlanId, asSysMainId, investDetailId, companys, 0);
}

private static void statRankItem(JDatabase jdb, int statPlanId, int asSysMainId, int investDetailId, String companys, int asSysDetailId) throws SQLException
{
	int statMethodId = 0;
	if (asSysDetailId == 0)
		statMethodId = statGetMethod(jdb, 3, 7, "��ҵ�ۺ�ָ��");
	ResultSet rs = jdb.rsSQL(0, "select sValue, comId from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + investDetailId		
			+ " and comId in (" + companys + ") and statSysDetailId=" + asSysDetailId + " and statMethodId=" + statMethodId + " order by sValue desc");
	int rank = 0, cnt = 0;
	double vv = 999999999;
	while (rs.next())
	{
		cnt ++;
		int comId = rs.getInt("comId");
		double v = rs.getDouble("sValue");
		if ((v < vv) || (rank == 0))
			rank = cnt;
		vv = v;
		statSaveRank(jdb, statPlanId, investDetailId, comId, asSysDetailId, statMethodId, "indexRank", "" + rank);
	}
	rs.close();
		
	rs = jdb.rsSQL(0, "select fillValue,comId from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + investDetailId		
		+ " and comId in (" + companys + ") and statSysDetailId=" + asSysDetailId + " and statMethodId=" + statMethodId + " order by fillValue desc");
	rank = 0;
	cnt = 0;
	vv = 999999999;
	while (rs.next())
	{
		cnt ++;
		int comId = rs.getInt("comId");
		double v = rs.getDouble("fillValue");
		if ((v < vv) || (rank == 0))
			rank = cnt;
		vv = v;
		statSaveRank(jdb, statPlanId, investDetailId, comId, asSysDetailId, statMethodId, "valueRank", "" + rank);
	}
	rs.close();
}

private static void statAverage(JDatabase jdb, int statPlanId, int asSysMainId, int investDetailId) throws SQLException
{
	String name = "������ҵƽ��ָ��";
	int methodId = statGetMethod(jdb, 1, 7, name);
	ResultSet rs = jdb.rsSQL(0, "select ID from asSysDetail where asSysId=" + asSysMainId);
	while (rs.next())
	{
		int asSysDetailId = rs.getInt("ID");
		ResultSet rs1 = jdb.rsSQL(0, "select count(ID), sum(sValue), sum(fillValue) from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + investDetailId	+
			" and statSysDetailId=" + asSysDetailId + " and statMethodId=0");
		while (rs1.next())
		{
			int count = rs1.getInt(1);
			double v = 0, vv = 0;
			if (count > 0)
			{
				v = rs1.getDouble(2) / count;
				vv = rs1.getDouble(3) / count;
			}
			statSaveItem(jdb, statPlanId, investDetailId, 0, 0, asSysDetailId, methodId, name, v, vv);
		}
		rs1.close();
	}
	rs.close();
	
	String name1 = "��ҵ�ۺ�ָ��";
	int statMethodId = statGetMethod(jdb, 3, 7, name1);
	ResultSet rs1 = jdb.rsSQL(0, "select count(ID), sum(sValue), sum(fillValue) from asStatResult where statPlanId=" + statPlanId + " and InvestDetailId=" + investDetailId	+
			" and statSysDetailId=0 and statMethodId=" + statMethodId);
	while (rs1.next())
	{
		int count = rs1.getInt(1);
		double v = 0, vv = 0;
		if (count > 0)
		{
			v = rs1.getDouble(2) / count;
			vv = rs1.getDouble(3) / count;
		}
		statSaveItem(jdb, statPlanId, investDetailId, 0, 0, 0, methodId, name1 + "." + name, v, vv);
	}
	rs1.close();
}

private static double getItemGatherVal(int sumMethod, double totalVal, double lastVal, int count, int ncount)
{
	switch (sumMethod)
	{
		case 0:
		case 1:	//�ۼӷ�
			return totalVal;
		case 2:	//ƽ����
			if (count == 0)
				return 0;
			return totalVal / count;
		case 3:	//ȥ��ƽ����
			if (ncount == 0)
				return 0;
			return totalVal / ncount;
		case 4:	//�������ݷ�
			return lastVal;
	}
	return 0;
}

private static void statGather(JDatabase jdb, int statPlanId, int asSysMainId, int comId, String investDetailIds) throws SQLException
{
	String [] detailIds = investDetailIds.split(",");
	if (detailIds.length < 2)
		return;
	String name = "��ҵ����";
	int methodId = statGetMethod(jdb, 4, 7, name);
	ResultSet rs = jdb.rsSQL(0, "select sValue, asSysDetailId, planDetailId, sumMethod from asAnswerDetail left join asAnswer on asAnswerDetail.answerId=asAnswer.ID " +
		"left join asSysDetail on asAnswerDetail.asSysDetailId=asSysDetail.ID where comId=" +
		comId + " and planDetailId in (" + investDetailIds + ") order by asSysDetailId, planDetailId");
	double totalValue = 0, lastValue = 0, v, vv;
	int count = 0, ncount = 0, oldSysDetailId = -1, asSysDetailId = 0, planDetailId = 0, sumMethod = 0;

	while (rs.next())
	{
		v = WebChar.ToDouble(rs.getString("sValue"));
		asSysDetailId = rs.getInt("asSysDetailId");
		planDetailId = rs.getInt("planDetailId");
		sumMethod = rs.getInt("sumMethod");
		
		if (asSysDetailId != oldSysDetailId)
		{
			if (oldSysDetailId != -1)
			{
				vv = getItemGatherVal(sumMethod, totalValue, lastValue, count, ncount);
				statSaveItem(jdb, statPlanId, 0, 0, comId, oldSysDetailId, methodId, name, 0, vv);
				totalValue = 0;
				count = 0;
				ncount = 0;
			}
			oldSysDetailId = asSysDetailId;
		}
		count ++;
		if (v > 0)
			ncount ++;
		totalValue += v;
		if (planDetailId == WebChar.ToInt(detailIds[detailIds.length - 1]))
			lastValue = v;
	}
	vv = getItemGatherVal(sumMethod, totalValue, lastValue, count, ncount);
	statSaveItem(jdb, statPlanId, 0, 0, comId, oldSysDetailId, methodId, name, 0, vv);
}


public static int statRun(int statPlanId)
{
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	try
	{
		ResultSet rs = jdb.rsSQL(0, "select * from asStatPlan where ID=" + statPlanId);
		if (!rs.next())
		{
			rs.close();
			jdb.closeDBCon();
			return 0;
		}
		
		System.out.println("ͳ�ƿ�ʼʱ��:" + VB.Now());
		jdb.ExecuteSQL(0, "update asStatPlan set status=1 where ID=" + statPlanId);
		int asSysMainId = rs.getInt("asSysMainId");
		String beginTime = rs.getString("beginTime");
		String endTime = rs.getString("endTime");
		String companys = rs.getString("companys");
		String [] comIds = companys.split(",");
		String InvestDetailIds = "";
		rs.close();
		String sql = "select * from asInvestPlanDetail where beginTime>='" + beginTime + "' and endTime<='" + endTime 
			+ "' and mainId in (select ID from asInvestPlan where asSysMainId=" + asSysMainId + ") order by beginTime";
		rs = jdb.rsSQL(0, sql);
		while (rs.next())
		{
			int planDetailId = rs.getInt("ID");
			System.out.println("����Ҷ���ָ��ֵ�����ֵ����Сֵ��ƽ��ֵ������ܺͣ�����:" + VB.Now());
			statFillValTotal(jdb, statPlanId, planDetailId, companys);
			System.out.println("����Ҷ���ָ��ֵ:" + VB.Now());
			statFillValIndex(jdb, statPlanId, planDetailId, companys);
			
			System.out.println("������ҵ��Ҷ���ָ��ֵ:" + VB.Now());
			for (int x = 0; x <comIds.length; x++)	//������ҵ��Ҷ���ָ��ֵ
				statChildrenValue(jdb, statPlanId, asSysMainId, planDetailId, WebChar.ToInt(comIds[x]), 0, 0);
			System.out.println("�����Ҷ���ָ��ֵ�����ֵ����Сֵ��ƽ��ֵ������ܺͣ�����:" + VB.Now());
			statChildrenTotal(jdb, statPlanId, asSysMainId, planDetailId, companys, 0, 0);
			
			System.out.println("�����Ҷ����ָ��ֵ:" + VB.Now());
			for (int x = 0; x < comIds.length; x++)	//�����Ҷ����ָ��ֵ
				statChildrenIndex(jdb, statPlanId, asSysMainId, planDetailId, WebChar.ToInt(comIds[x]), 0, 0);

			System.out.println("����ָ������:" + VB.Now());
			statRank(jdb, statPlanId, asSysMainId, planDetailId, companys);		//����ָ������

			System.out.println("��������ƽ��ָ��:" + VB.Now());
			statAverage(jdb, statPlanId, asSysMainId, planDetailId);	//��������ƽ��ָ��
			if (!InvestDetailIds.equals(""))
				InvestDetailIds += ",";
			InvestDetailIds += planDetailId;
		}		
		rs.close();
		
		System.out.println("������ҵ�Ļ���ָ��:" + VB.Now());
		for (int x = 0; x < comIds.length; x++)	//������ҵ�Ļ���ָ��
			statGather(jdb, statPlanId, asSysMainId, WebChar.ToInt(comIds[x]), InvestDetailIds);
		statFillValTotal(jdb, statPlanId, 0, companys);
		statFillValIndex(jdb, statPlanId, 0, companys);

		System.out.println("������ҵ��Ҷ������ָ��ֵ:" + VB.Now());
		for (int x = 0; x <comIds.length; x++)	//������ҵ��Ҷ���ָ��ֵ
			statChildrenValue(jdb, statPlanId, asSysMainId, 0, WebChar.ToInt(comIds[x]), 0, 0);
		System.out.println("�����Ҷ������ָ��ֵ�����ֵ����Сֵ��ƽ��ֵ������ܺͣ�����:" + VB.Now());
		statChildrenTotal(jdb, statPlanId, asSysMainId, 0, companys, 0, 0);
			
		System.out.println("�����Ҷ���Ļ���ָ��ֵ:" + VB.Now());
		for (int x = 0; x < comIds.length; x++)	//�����Ҷ����ָ��ֵ
			statChildrenIndex(jdb, statPlanId, asSysMainId, 0, WebChar.ToInt(comIds[x]), 0, 0);

		System.out.println("�������ָ������:" + VB.Now());
		statRank(jdb, statPlanId, asSysMainId, 0, companys);		//����ָ������
			
		System.out.println("�����������ƽ��ָ��:" + VB.Now());
		statAverage(jdb, statPlanId, asSysMainId, 0);	//��������ƽ��ָ��
	}			
	catch (Exception e) 
	{
		WebChar.printError(e);
	}
				
	jdb.ExecuteSQL(0, "update asStatPlan set status=2 where ID=" + statPlanId);
	System.out.println("ͳ�ƽ���ʱ��:" + VB.Now());
	return 1;
}
//(�鵵��ע��,����ɾ��)�������û��Զ����������� End##@@

%>
<%
// ServerChapterPageStartCode
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	user = new SysUser();
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
			response.sendRedirect("../bia/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	String CodeName="StatEdit";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='StatEdit' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##166:��������������(�鵵��ע��,����ɾ��)
//

	if (WebChar.RequestInt(request, "LoadStatSysDetail") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		String items = jdb.getJsonBySql(0, "select * from asStatSysDetail where statPlanId=" + statPlanId);
		out.print(items);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "StartStat") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		int status = jdb.getIntBySql(0, "select status from asStatPlan where ID=" + statPlanId);
		if (status == 1)
		{
			out.print("ͳ�Ʒ������ڼ�����..�������ٴ�����.");
			jdb.closeDBCon();
			return;	
		}
		
		Runnable runnable = new Runnable()
		{
			public void run()
			{
				int statPlanId = WebChar.ToInt(Thread.currentThread().getName());
					statRun(statPlanId);
			}
		};
		Thread thread = new Thread(runnable, "" + statPlanId);
		thread.start();
		out.print("ͳ�Ʒ��������Ѿ��ں�̨�ɹ���������ȴ�Լ5���Ӻ�ת��ͳ�ƽ��ҳ��鿴");
		jdb.closeDBCon();
		return;
	}



//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>��������</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2019-4-28 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../bia/bia.js"></script>

<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"StatEdit", Role:<%=Purview%>};
var env = {com:"../com", proj:"../bia", fvs:"../biafvs", flow:"../biaflow", page:"../biapages"};
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
	var Tools = [
		{item:"����", img:"#59356", action:NewRecordFilter, info:"����һ����¼", Attrib:2, Param:1},
		{item:"�༭", img:"#59357", action:EditRecordFilter, info:"�༭��ǰ��¼", Attrib:2, Param:1},
		{item:"ɾ��", img:"#58996", action:DelRecordFilter, info:"ɾ����ǰ��¼", Attrib:2, Param:1},
		{item:"ˢ��", img:"#58976", action:RefreshFilter, info:"���¼���", Attrib:1, Param:1},
		{item:"ͳ��", img:"#59199", action:StartStat, info:"������̨ͳ������", Attrib:0, Param:1}
			];
	book.setTool(Tools);
//@@##167:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//��������:Filter
	var o = book.setDocTop("������...", "Filter", "");
	book.Filter = new $.jcom.DBCascade(o, env.fvs + "/asStatPlan_view.jsp", {}, {}, {title:["����"]});
	book.Filter.onclick = ClickFilter;
	book.setPageObj(book.Filter);
	var o = book.setDocBottom("", "paper");
	book.asView = new AsSysStatView(o, 0, {title:"����ָ����ϵ", mode:3});


//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##168:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//
function ClickFilter(obj, item)
{
	if (book.Page == undefined)
	{
		var o = book.getDocObj("Page")[0];
		book.Page = new $.jcom.DBForm(o,  env.fvs + "/asStatPlan_form.jsp", {DataID:item.ID}, 
			{itemstyle:"font:normal normal normal 16px ΢���ź�",valstyle:"width:400px", formtype:8});
		book.Page.PrepareData = PrepareForm;
		book.Page.onRecordReady = FormPageReady;
	}
	else
		book.Page.getDBRecord(item.ID);
}

function PrepareForm(fields, record, cfg)
{
	if (editMode == 0)
		cfg.formtype = 8;
	else
		cfg.formtype = 4;
//	book.asView.reload(record.asSysMainId, {editMode:editMode});
}

function FormPageReady(fields, record)
{
	if (record.I_DataID == undefined)
		return;
	var field = book.Page.getFields("companys");
	if (field.editor == undefined)
	{
		$("#" + field.EName + "_DIV").css({width:""});
		var cfg = {resizeflag:0};
		var tag = "<h2 align=center>��ͳ����ҵ</h2>";
		if (editMode != 0)
		{
			cfg.bodystyle  = 2;
			tag += "&nbsp;&nbsp;<input type=button onclick=InsertCom() value=����>&nbsp;<input type=button onclick=DelCom() value=ɾ��></div>";
		}
		field.editor = new $.jcom.GridView($("#" + field.EName + "_DIV")[0], [{FieldName:"comName", TitleName:"��ҵ����", nWidth:400}],[],{}, cfg);
		field.editor.TitleBar(tag);
	}
	
	var items = [];
	if ((record.companys != "") && (record.companys != undefined))
	{
		var ss = record.companys.split(",");
		var ssex = record.companys_ex.split(",");
		for (var x = 0; x < ss.length; x++)
			items[items.length] = {ID: ss[x], comName: ssex[x]};
	}
	field.editor.reload(items);
	book.asView.reload(record.asSysMainId, record.I_DataID, {editMode:editMode});
}

var comWin, comGrid;
function InsertCom()
{
	if (comWin == undefined)
	{
		var record = book.Page.getRecord();
		comWin = new $.jcom.PopupWin("<div id=ComGridDiv style=width:100%;height:400px;overflow:auto;></div>" +
			"<div style=float:right><input id=InsertFromCom type=button value=ȷ��>&nbsp;&nbsp;</div>", 
				{title:"ѡ����ҵ", width:640, height:480, mask:50,position:"fixed"});
		comGrid = new $.jcom.DBGrid($("#ComGridDiv")[0],  env.fvs + "/company_sel.jsp", {URLParam:"?asSysId=" + record.asSysMainId.value},
			{SeekKey:"", SeekParam:""}, {gridstyle:1, bodystyle:2, footstyle:4, initDepth:4, nowrap:0});
		comWin.close = comWin.hide;
		$("#InsertFromCom").on("click", InsertComRun);
	}
	else
		comWin.show();
}

function InsertComRun()
{
	var sels = comGrid.getsel();
	if (sels.length == 0)
		return alert("����ѡ����ҵ");
	var ids = "";
	var value = book.Page.FieldValue("companys");
	var ss = value.split(",");
	var field = book.Page.getFields("companys");
	var items = field.editor.getData();
	for (var x = 0; x <sels.length; x++)
	{
		var item = comGrid.getItemData($(sels[x]).attr("node"));
		for (var y = 0; y < ss.length; y++)
		{
			if (item.ID == ss[x])
				break;
		}
		if (y >= ss.length)
		{
			if (ids != "")
				ids += ",";
			ids += item.ID;
			items[items.length] = {ID:item.ID, comName:item.comName};
		}
	}
	comWin.hide();
	if (ids != "")
	{
		if (value != "")
			value += ",";
		value += ids;
		book.Page.FieldValue("companys", value);
		field.editor.reload(items); 
	}
}

function DelCom()
{
	var field = book.Page.getFields("companys");
	var sels = field.editor.getsel();
	if (sels.length == 0)
		return alert("���ȹ�ѡ��ҵ");
	for (var x = sels.length - 1; x >= 0; x--)
		field.editor.deleteRow(sels[x]);
	var items = field.editor.getData();
	var ids = "";
	for (var x = 0; x <items.length; x++)
	{
		if (ids != "")
			ids += ",";
		ids += items[x].ID;
	}
	book.Page.FieldValue("companys", ids);
}

var editMode = 0, hostMenuDef;
function toggleEditMode()		//����:��ȫ���༭ģʽ���Ķ�ģʽ֮���л�
{
	var menu = book.getChild("toolObj");
	if (editMode == 0)
	{
		editMode = 1;
		book.toggleEditMode();
		hostMenuDef = menu.getmenu();
		var def = [{item:"����", img:"#59432", action:SavePageForm},{item:"����",img:"#59470", action:toggleEditMode}];
		menu.reload(def);
	}
	else
	{
		if (window.confirm("�Ƿ�ȷ��Ҫ�˳��༭ģʽ?") == false)
				return;
		book.toggleEditMode();
		editMode = 0;
		menu.reload(hostMenuDef);
		location.reload();
	}
}

function SavePageForm()
{
	var items = book.asView.grid.getData();
	var rec = [];
	getasViewRecord(items, rec);
	book.Page.appendHidden("asStatSysDetail", rec);
	book.Page.SaveForm();
}

function getasViewRecord(items, rec)
{
	for (var x = 0; x < items.length; x++)
	{
		rec[rec.length] = {sysDetailId: items[x].ID, weight: items[x].weight, method:items[x].method};
		if (typeof items[x].child == "object")
			getasViewRecord(items[x].child, rec);
	}
}

function NewRecordFilter(obj, item)	//����
{
//����һ����¼
book.Filter.NewItem();
}



function EditRecordFilter(obj, item)	//�༭
{
//�༭��ǰ��¼
	toggleEditMode();
	book.Page.reset(0, 0, {formtype:4});
}



function DelRecordFilter(obj, item)	//ɾ��
{
//ɾ����ǰ��¼
book.Filter.DeleteItem();
}



function RefreshFilter(obj, item)	//ˢ��
{
//���¼���
location.reload();
}

function AsSysStatView(domobj, SysId, cfg)		//ͳ�Ʒ���������ϵѡ��
{
	var self = this;
	var statPlanId;
	var methodEditor, weightEditor;
	self.grid = undefined;
	var defaultData;

	this.reload = function (id, statId, option)
	{
		SysId = id;
		statPlanId = statId;
		if (self.grid == undefined)
		{
			self.grid = new $.jcom.DBGrid(domobj, env.fvs + "/asSysDetail_view.jsp", 
					{URLParam:"?asSysId=" + id, formitemstyle:"font:normal normal normal 16px ΢���ź�", formvalstyle:"width:400px",gridtree:2},
					{SeekKey:"", SeekParam:""}, {gridstyle:1, footstyle:4, initDepth:4, nowrap:0, resizeflag:0});
			self.grid.PrepareData = PrepareGrid;
			self.grid.bodyonload = onGridReady;
			var title = cfg.title;
			if (title.substr(0, 1) != "<")
				title = "<h2 align=center>" + title + "</h2>"
			self.grid.TitleBar(title);
		}
		else
		{
			self.grid.config({URLParam:"?asSysId=" + id});
			self.grid.ReloadGrid();
		}
		cfg = $.jcom.initObjVal(cfg, option);
		defaultData = undefined;
	};
	
	function loadStatOK(data)
	{
		var items = $.jcom.eval(data);
		if (typeof items == "string")
			return alert(items);
		var data = self.grid.getData();
		if (defaultData == undefined)
			defaultData = $.extend(true, [], data);
		for (var x = 0; x < items.length; x++)
		{
			var node = self.grid.findNode("ID", items[x].sysDetailId);
			if (node != undefined)
			{
				var item = self.grid.getItemData(node);
				item.weight = items[x].weight;
				item.method = items[x].method;
				item.method_ex = self.grid.getItemValue(items[x], "method");
			}
			else
				alert("ERROR");
		}
		self.grid.reload(data);
	}
		
	function PrepareGrid(items, head, depth)
	{
		if (depth == undefined)
		{
			depth = 0;
			for (var x = 0; x < head.length; x++)
			{
				switch (head[x].FieldName)
				{
				case "method":
					head[x].nShowMode = 1;
					break;
				case "dataType":
					head[x].nShowMode = 6;
					break;					
				}
			}
		}
		for (var x = 0; x < items.length; x++)
		{
			items[x].itemCName = {value:items[x].itemCName, style:"font:normal normal normal " + (18 - depth * 2) + "px ΢���ź�;"}
			if (typeof items[x].child == "object")
			{
				if (items[x].child.length == 0)
					items[x].child = undefined;
				else
					PrepareGrid(items[x].child, head, depth + 1);
			}
			if (typeof items[x].child != "object")
				items[x].info = {value:items[x].info, style:"font:normal normal normal 13px ����;"};
		}
		if (depth == 0)
			$.get(cfg.jsp, {LoadStatSysDetail:1, statPlanId: statPlanId}, loadStatOK);
		return items;
	}
	
	function ResetValue()
	{
		if (window.confirm("������������ϵ��Ȩ�غ�ָ�����㷽������ΪĬ��ֵ���Ƿ�ȷ����") == false)
			return;
		var data = $.extend(true, [], defaultData);
		self.grid.reload(data);
	}

	function onGridReady()
	{
		if (cfg.editMode == 1)
		{
			if (methodEditor == undefined)
			{
				methodEditor = self.grid.attachEditor("method");
				weightEditor = self.grid.attachEditor("weight");
			}
			else
			{
				self.grid.attachEditor("method", methodEditor);
				self.grid.attachEditor("weight", weightEditor);
			}
			self.grid.TitleBar("<h2 align=center>" + cfg.title + "</h2><br><input id=ResetValue type=button value=����ΪĬ��ֵ>");
			$("#ResetValue", domobj).on("click", ResetValue);
		}
		else
		{
				self.grid.detachEditor("method");
				self.grid.detachEditor("weight");
		}
	}
	
	cfg = $.jcom.initObjVal({editMode:0, title:"", jsp:location.pathname}, cfg);
	if (SysId > 0)
		this.reload(SysId);
}



function StartStat(obj, item)	//ͳ��
{
//������̨ͳ������
	var item = book.Filter.getselItem(0);
	$.get(location.pathname, {StartStat:1,statPlanId: item.ID}, function(s){alert(s);}); 
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
