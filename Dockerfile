# 使用OpenJDK 17作为基础镜像
FROM openjdk:17-jre-slim

# 设置维护者信息
LABEL maintainer="your-email@example.com"
LABEL description="Simple Java Web Application with JMX Exporter for ECS"

# 创建应用目录
RUN mkdir -p /opt/app

# 设置工作目录
WORKDIR /opt/app

# 复制JMX Exporter jar文件
COPY jmx_prometheus_javaagent-0.20.0.jar /opt/app/

# 复制Web应用程序jar文件（使用80端口版本）
COPY simple-web-app.jar /opt/app/

# 复制JMX配置文件
COPY config.yaml /opt/app/

# 安装curl用于健康检查
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# 创建非root用户
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /opt/app
USER appuser

# 暴露端口
EXPOSE 80 9404

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# 启动命令
CMD ["java", "-javaagent:jmx_prometheus_javaagent-0.20.0.jar=9404:config.yaml", "-jar", "simple-web-app.jar"]
