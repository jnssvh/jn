package share.mark.action;

import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.jaguar.JDatabase;
import com.jaguar.VB;
import com.jaguar.WebChar;
import com.jaguar.WebUser;
import com.jaguar.list.AjaxList;

import graduatestudent.GraduateSystem;
import project.AjaxForm;
import project.AjaxModelImpl;
import project.SysApp;
import project.SystemLog;

public class MarkInstance  implements AjaxModelImpl {
    private static Logger logger = WebChar.logger;
	private JDatabase jdb = null;
	private WebUser user = null;
	private SysApp sysApp = null;
	private int nDB = 0;
	private WebChar webChar = new WebChar();
	private AjaxList ajaxList = null;
	
	private HttpServletRequest request = null;
	private HttpServletResponse response = null;
	private SystemLog sysLog = null;
	public String basePath;
	public Pattern p = Pattern.compile(".*/\\d{3}\\..*");
	
	public MarkInstance() {
		
	}
	
	public void init(JDatabase jdb, WebUser user, SysApp sysApp
			, HttpServletRequest request, HttpServletResponse response) {
		this.jdb = jdb;
		this.user = user;
		this.sysApp = sysApp;
		this.request = request;
		this.response = response;
		sysLog = new SystemLog(jdb, user, request);
		ajaxList = new AjaxList(jdb);
		String path = request.getContextPath();
		basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	}


	public String getDataList() {
		AjaxForm form = new AjaxForm(request);
		String rtn = "", sql = "", url = "";
		String plus = null;

		String instanceName = WebChar.requestStr(request, "instanceName");
		String formName = WebChar.requestStr(request, "formName");
		if (formName.indexOf("Alias_share_id") == 0) {
			sql = "SELECT share_id,share_name,share_code FROM share_info"
				+ " ORDER BY order_no";
			plus = "<tree></tree><img_dir>../pic/381.png</img_dir>";
		} else if (formName.indexOf("Alias_mark_id") == 0) {
				sql = "SELECT mark_id,mark_name,mark_code FROM share_mark_info"
					+ " ORDER BY order_no";
				plus = "<tree></tree><img_dir>../pic/381.png</img_dir>";
		} else if (formName.indexOf("Alias_k_id") == 0) {
			sql = "SELECT k_id,K_name"
				+ ",(SELECT EnumString FROM UEnumData WHERE EnumTypeCode='share_time_type' AND EnumValue=time_type) time_type"
				+ ",time_length"
				+ " FROM share_k"
				+ " ORDER BY order_no";
			plus = "<tree></tree><img_dir>../pic/381.png</img_dir>";
		} else if (formName.indexOf("Alias_sign_id") == 0) {
			int mark_id = WebChar.RequestInt(request, "mark_id");
			sql = "SELECT sign_id,action_name"
				+ ",(SELECT EnumString FROM UEnumData WHERE EnumTypeCode='share_guide_result' AND EnumValue=guide_result) guide_result"
				+ " FROM share_mark_sign"
				+ (mark_id > 0 ? " WHERE mark_id=" + mark_id : "")
				+ " ORDER BY order_no";
			plus = "<tree></tree><img_dir>../pic/381.png</img_dir>";
		} else {
			return "";
		}
		rtn = ajaxList.getAjaxHTML(sql, instanceName, plus);
		//System.out.println(rtn);
		return rtn;
	}
}
