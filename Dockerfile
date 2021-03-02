FROM tomcat:alpine
MAINTAINER mehaklakhanpal
COPY target/devopssampleapplication /usr/local/tomcat/webapps/testapp
EXPOSE 8080
CMD /usr/local/tomcat/bin/catalina.sh run