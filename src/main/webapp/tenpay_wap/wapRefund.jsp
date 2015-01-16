<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.1//EN"
"http://www.wapforum.org/DTD/wml_1.1.xml">

<%@ page language="java" contentType="text/vnd.wap.wml;charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ page import="com.tenpay.RequestHandler" %>
<%@ page import="com.tenpay.client.ClientResponseHandler" %>
<%@ page import="com.tenpay.client.*" %>
<%@ page import="java.io.File" %>
<%@ page import="com.tenpay.util.MD5Util" %>
<wml>
<head>
<meta http-equiv="Cache-Control" content="max-age=0" forua="true"/>
<meta http-equiv="Cache-control" content="must-revalidate" />
<meta http-equiv="Cache-control" content="private" />
<meta http-equiv="Cache-control" content="no-cache" />
</head>
<card id="wappay" title="财付通wap手机退款示例">
<p>
<%
    //商户号
    String partner = "1900000109";

    //密钥
    String key = "8934e7d15453e97507ef794cf7b0519d";

    //创建查询请求对象
    RequestHandler reqHandler = new RequestHandler(null, null);
    //通信对象
    TenpayHttpClient httpClient = new TenpayHttpClient();
    //应答对象
    XMLClientResponseHandler resHandler = new XMLClientResponseHandler();

    //-----------------------------
    //设置请求参数
    //-----------------------------
    reqHandler.init();
    reqHandler.setKey(key);
    reqHandler.setGateUrl("https://mch.tenpay.com/refundapi/gateway/refund.xml");

    //-----------------------------
    //设置接口参数
    //-----------------------------
    reqHandler.setParameter("service_version", "1.1");
    reqHandler.setParameter("partner", "1900000109");
    reqHandler.setParameter("out_trade_no", "201309121605246676");	//商户订单号
    reqHandler.setParameter("transaction_id", "1900000109201309129353899182");//财付通订单号
    reqHandler.setParameter("out_refund_no", "1044537275");//商户退款单号
    reqHandler.setParameter("total_fee", "1");
    reqHandler.setParameter("refund_fee", "1");
    reqHandler.setParameter("op_user_id", "1900000109");
    //操作员密码,MD5处理
    reqHandler.setParameter("op_user_passwd", MD5Util.MD5Encode("111111","GBK"));

    reqHandler.setParameter("recv_user_id", "");
    reqHandler.setParameter("reccv_user_name", "");
    //-----------------------------
    //设置通信参数
    //-----------------------------
    //设置请求返回的等待时间
    httpClient.setTimeOut(5);
    //设置ca证书
    httpClient.setCaInfo(new File("e:/cacert.pem"));

    //设置个人(商户)证书
    httpClient.setCertInfo(new File("e:/1900000109.pfx"), "1900000109");

    //设置发送类型POST
    httpClient.setMethod("POST");

    //设置请求内容
    String requestUrl = reqHandler.getRequestURL();
    httpClient.setReqContent(requestUrl);
    String rescontent = "null";

    //后台调用
    if(httpClient.call()) {
        //设置结果参数
        rescontent = httpClient.getResContent();
        resHandler.setContent(rescontent);
        resHandler.setKey(key);

        //获取返回参数
        String retcode = resHandler.getParameter("retcode");

        //判断签名及结果
        if(resHandler.isTenpaySign()&& "0".equals(retcode)) {
    	/*退款状态	refund_status
			4，10：退款成功。
			3，5，6：退款失败。
			8，9，11:退款处理中。
			1，2: 未确定，需要商户原退款单号重新发起。
			7：转入代发，退款到银行发现用户的卡作废或者冻结了，导致原路退款银行卡失败，资金回流到商户的现金帐号，需要商户人工干预，通过线下或者财付通转账的方式进行退款。
			*/
            String refund_status=resHandler.getParameter("refund_status");
            String out_refund_no=resHandler.getParameter("out_refund_no");

            if("4".equals(refund_status) || "10".equals(refund_status))
                refund_status = refund_status+"(退款成功)";
            else if("3".equals(refund_status) || "5".equals(refund_status) || "6".equals(refund_status))
                refund_status = refund_status+"(退款失败)";
            else if("8".equals(refund_status) || "9".equals(refund_status) || "11".equals(refund_status))
                refund_status = refund_status+"(退款处理中)";
            else if("7".equals(refund_status))
                refund_status = refund_status+"(未确定，需要商户原退款单号重新发起。)";

            out.println("商户退款单号"+out_refund_no+"的退款状态是："+refund_status);


        } else {
            //错误时，返回结果未签名，记录retcode、retmsg看失败详情。
            System.out.println("验证签名失败或业务错误");
            System.out.println("retcode:" + resHandler.getParameter("retcode")+
                    " retmsg:" + resHandler.getParameter("retmsg"));
            out.println("retcode:" + resHandler.getParameter("retcode")+
                    " retmsg:" + resHandler.getParameter("retmsg"));
        }
    } else {
        System.out.println("后台调用通信失败");
        System.out.println(httpClient.getResponseCode());
        System.out.println(httpClient.getErrInfo());
        //有可能因为网络原因，请求已经处理，但未收到应答。
    }

    //获取debug信息,建议把请求、应答内容、debug信息，通信返回码写入日志，方便定位问题
    System.out.println("http res:" + httpClient.getResponseCode() + "," + httpClient.getErrInfo());
    System.out.println("req url:" + requestUrl);
    System.out.println("req debug:" + reqHandler.getDebugInfo());
    System.out.println("res content:" + rescontent);
    System.out.println("res debug:" + resHandler.getDebugInfo());

%>

</p>
</card>
</wml>
