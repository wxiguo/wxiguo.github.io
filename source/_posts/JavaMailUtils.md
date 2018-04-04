---
title: JavaMail发送邮件
date: 2018-04-04 13:23:10
updated: 2018-04-04 13:23:10
top: false
categories:
    - Java
tags:
    - Java
    - JavaUtils
description: 通过JavaMail实现发送邮件
---

## 简介

JavaMail是Sun公司提供给开发人员在程序中处理Email的API，JavaMail未加入到JDK中，需要自己下载使用。

## jar包下载

配置`maven`信息：

```xml
<dependencies>
    <dependency>
        <groupId>com.sun.mail</groupId>
        <artifactId>javax.mail</artifactId>
        <version>1.6.1</version>
    </dependency>
</dependencies>
```

## Java代码段

```java
import java.io.File;
import java.util.Date;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.Authenticator;
import javax.mail.BodyPart;
import javax.mail.Message.RecipientType;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.internet.MimeUtility;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import cn.com.ylpw.basis.utils.Constants;
import com.sun.mail.util.MailSSLSocketFactory;

/** 
 * @author wxg
 * @version 创建时间：2018年4月4日 上午10:04:18 
 * @explain 
 */
public class JavaMailUtils {

    private static final Logger log = LoggerFactory.getLogger(JavaMailUtils.class);

    private final static String OUTPUT = Constants.emailProperties.jsp_getValue("output");
    private final static String MAILSERVER = Constants.emailProperties.jsp_getValue("mailServer");
    private final static String LOGINACCOUNT = Constants.emailProperties.jsp_getValue("loginAccount");
    private final static String LOGINAUTHCODE = Constants.emailProperties.jsp_getValue("loginAuthCode");
    private final static String Sender = Constants.emailProperties.jsp_getValue("sender");
    private final static String[] RECIPIENTS = Constants.emailProperties.jsp_getValue("recipient").split(",");
    private final static String EMAILCONTENTTYPE = "text/html;charset=utf-8";

    /**
     * 
     * @Title:       sendEmail
     * @Description:
                     邮件发送工具
     * @param:       @param mailServer       邮件服务器的主机名:如 "smtp.**.com"
     * @param:       @param loginAccount     登录邮箱的账号:如 "******@***.com"
     * @param:       @param loginAuthCode    登录邮箱，账号设置那里"生成授权码"
     * @param:       @param sender           发件人
     * @param:       @param recipients       收件人:支持群发
     * @param:       @param emailSubject     邮件的主题
     * @param:       @param emailContent     邮件的内容
     * @param:       @param emailContentType 邮件内容的类型,支持纯文本:"text/plain;charset=utf-8";带有Html格式的内容:"text/html;charset=utf-8";
     * @param:       @param attachment       邮件附件，目录下所有文件
     * @param:       @return                 true or false
     * @return:       boolean   
     * @throws
     */
    public static boolean sendEmail(String mailServer, final String loginAccount, final String loginAuthCode, String sender, String[] recipients, String emailSubject, String emailContent, String emailContentType, File[] attachment) {
        boolean res = false;
        try{
            // 跟smtp服务器建立连接
            Properties properties = new Properties();
            // 设置邮件服务器主机名
            properties.setProperty("mail.smtp.host", mailServer);
            // 发送服务器身份验证，采用用户名和密码方式
            properties.setProperty("mail.smtp.auth", "true");
            // 发送邮件协议名称
            properties.setProperty("mail.transport.protocol", "smtp");
            // 开启SSL加密
            MailSSLSocketFactory mailSSLSocketFactory = new MailSSLSocketFactory();
            mailSSLSocketFactory.setTrustAllHosts(true);
            properties.put("mail.smtp.ssl.enable", "true");
            properties.put("mail.smtp.ssl.socketFactory", mailSSLSocketFactory);
            // 创建session
            Session session = Session.getDefaultInstance(properties, new Authenticator(){
                protected PasswordAuthentication getPasswordAuthentication(){
                    PasswordAuthentication passwordAuth = 
                        new PasswordAuthentication(loginAccount, loginAuthCode);
                    return passwordAuth;
                }
            });
            // 设置打开调试状态
            session.setDebug(false);
            // 创建一封邮件
            MimeMessage mimeMessage = new MimeMessage(session);
            
            // 发件人
            mimeMessage.setFrom(new InternetAddress(sender));
            // 收件人
            InternetAddress[] recipientsEmail = new InternetAddress[recipients.length];
            for(int i = 0;i < recipients.length;i++){
                recipientsEmail[i] = new InternetAddress(recipients[i]);
            }
            mimeMessage.setRecipients(RecipientType.TO, recipientsEmail);
            // 抄送人
//            mimeMessage.setRecipients(RecipientType.CC, recipientsEmail);
            // 设置多个密送地址
//            mimeMessage.setRecipients(RecipientType.BCC, recipientsEmail);
            // 发送日期  
            mimeMessage.setSentDate(new Date()); 
            // 设置邮件标题
            mimeMessage.setSubject(emailSubject);
            // 添加正文和附件
            Multipart multipart = new MimeMultipart();
            // 添加邮件正文 
            BodyPart contentPart = new MimeBodyPart();
            contentPart.setContent(emailContent, emailContentType);
            multipart.addBodyPart(contentPart);
            // 设置附件
            BodyPart attachmentBodyPart = null;
            // 添加附件的内容
            if (null != attachment && attachment.length != 0) {
                for (File file : attachment) {
                    attachmentBodyPart = new MimeBodyPart();
                    DataSource source = new FileDataSource(file);
                    attachmentBodyPart.setDataHandler(new DataHandler(source));
                    // MimeUtility.encodeWord可以避免文件名乱码
                    attachmentBodyPart.setFileName(MimeUtility.encodeWord(file.getName()));
                    multipart.addBodyPart(attachmentBodyPart);
                }
            }
            // 将multipart对象放到message中
            mimeMessage.setContent(multipart);
            // 设置邮件内容
//            mimeMessage.setContent(emailContent, emailContentType);
            // 发送邮件
            Transport.send(mimeMessage);
            log.error("邮件发送成功");
            res = true;
        }catch(Exception e){
            log.error("邮件发送失败: " + e.getMessage(), e);
            res = false;
        }
        return res;
    }
    
    /**
     * 
     * @Title:      sendEmail
     * @Description:
                    发送普通邮件
     * @param:      @param emailSubject    主题
     * @param:      @param emailContent    内容
     * @param:      @return   
     * @return:      boolean   
     * @throws
     */
    public static boolean sendEmail(String emailSubject, String emailContent){
        if(OUTPUT.equals("true")){
//            File file = new File("D:\\中文cs");
//            File[] files = file.listFiles();
            return sendEmail(MAILSERVER, LOGINACCOUNT, LOGINAUTHCODE, Sender,
                    RECIPIENTS, emailSubject, emailContent, EMAILCONTENTTYPE,
                    null);
        }
        return false;
    }
```

## 异常处理


需要注意的是，在本机`junit`测试配置是正常的，但是启动服务后程序异常，日志如下：

```
java.lang.UnsupportedOperationException: Method not yet implemented
    at javax.mail.internet.MimeMessage.<init>(MimeMessage.java:89) ~[geronimo-spec-javamail-1.3.1-rc3.jar:1.3.1-rc3]
    at cn.com.ylpw.basis.utils.JavaMailUtils.sendEmail(JavaMailUtils.java:93) [classes/:na]
    at cn.com.ylpw.basis.utils.JavaMailUtils.sendEmail(JavaMailUtils.java:159) [classes/:na]
    at cn.com.ylpw.alliance.controller.CreateXmlData.createXmlAll(CreateXmlData.java:174) [classes/:na]
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.7.0_75]
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57) ~[na:1.7.0_75]
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) ~[na:1.7.0_75]
    at java.lang.reflect.Method.invoke(Method.java:606) ~[na:1.7.0_75]
    at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:221) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:137) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:110) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandleMethod(RequestMappingHandlerAdapter.java:777) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:706) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:85) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:943) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:877) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:966) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.servlet.FrameworkServlet.doGet(FrameworkServlet.java:857) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at javax.servlet.http.HttpServlet.service(HttpServlet.java:622) [servlet-api.jar:na]
    at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:842) [spring-webmvc-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at javax.servlet.http.HttpServlet.service(HttpServlet.java:729) [servlet-api.jar:na]
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:292) [catalina.jar:8.0.35]
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:207) [catalina.jar:8.0.35]
    at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52) [tomcat-websocket.jar:8.0.35]
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:240) [catalina.jar:8.0.35]
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:207) [catalina.jar:8.0.35]
    at org.springframework.web.filter.HiddenHttpMethodFilter.doFilterInternal(HiddenHttpMethodFilter.java:77) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:240) [catalina.jar:8.0.35]
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:207) [catalina.jar:8.0.35]
    at org.springframework.orm.hibernate4.support.OpenSessionInViewFilter.doFilterInternal(OpenSessionInViewFilter.java:151) [spring-orm-4.1.6.RELEASE.jar:4.1.6.RELEASE]
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:240) [catalina.jar:8.0.35]
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:207) [catalina.jar:8.0.35]
    at org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal(CharacterEncodingFilter.java:88) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-4.1.5.RELEASE.jar:4.1.5.RELEASE]
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:240) [catalina.jar:8.0.35]
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:207) [catalina.jar:8.0.35]
    at org.apache.catalina.core.StandardWrapperValve.invoke(StandardWrapperValve.java:212) [catalina.jar:8.0.35]
    at org.apache.catalina.core.StandardContextValve.invoke(StandardContextValve.java:106) [catalina.jar:8.0.35]
    at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:502) [catalina.jar:8.0.35]
    at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:141) [catalina.jar:8.0.35]
    at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:79) [catalina.jar:8.0.35]
    at org.apache.catalina.valves.AbstractAccessLogValve.invoke(AbstractAccessLogValve.java:616) [catalina.jar:8.0.35]
    at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:88) [catalina.jar:8.0.35]
    at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:528) [catalina.jar:8.0.35]
    at org.apache.coyote.http11.AbstractHttp11Processor.process(AbstractHttp11Processor.java:1099) [tomcat-coyote.jar:8.0.35]
    at org.apache.coyote.AbstractProtocol$AbstractConnectionHandler.process(AbstractProtocol.java:672) [tomcat-coyote.jar:8.0.35]
    at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1520) [tomcat-coyote.jar:8.0.35]
    at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.run(NioEndpoint.java:1476) [tomcat-coyote.jar:8.0.35]
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145) [na:1.7.0_75]
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:615) [na:1.7.0_75]
    at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) [tomcat-util.jar:8.0.35]
    at java.lang.Thread.run(Thread.java:745) [na:1.7.0_75]
```

经过查询是jar冲突导致的，定位到geronimo-spec-javamail.jar问题，通过`maven`的`exclusions`标签注释掉该jar包，问题解决。配置如下：

```xml
<dependency>
    <groupId>com.cloudhopper.proxool</groupId>
    <artifactId>proxool</artifactId>
    <version>0.9.1</version>
    <!-- 这个就是我们要排除依赖包，解决jar包冲突 -->
    <exclusions>
        <exclusion>
            <groupId>geronimo-spec</groupId>
            <artifactId>geronimo-spec-javamail</artifactId>
        </exclusion>
        <exclusion>
            <groupId>geronimo-spec</groupId>
            <artifactId>geronimo-spec-jms</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```