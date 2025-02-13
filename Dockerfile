# Base Python 3.10 image
FROM python:3.10-bullseye

# Expose Ports for Jupyter and Spark UI
EXPOSE 8888 4040

# Change shell to /bin/bash
SHELL ["/bin/bash", "-c"]

# Upgrade pip
RUN pip install --upgrade pip

# Install OpenJDK for Spark
RUN apt-get update && \
    apt install -y openjdk-11-jdk && \
    apt-get clean;

# Fix certificate issues
RUN apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Install nano & vim for text editing
RUN apt-get install -y nano && \
    apt-get install -y vim;

# Set JAVA_HOME for Java environment
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME

# Download and Setup Spark binaries
WORKDIR /tmp
RUN wget https://archive.apache.org/dist/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz
RUN tar -xvf spark-3.3.0-bin-hadoop3.tgz
RUN mv spark-3.3.0-bin-hadoop3 spark
RUN mv spark /
RUN rm spark-3.3.0-bin-hadoop3.tgz

# Set up environment variables for Spark & PySpark
ENV SPARK_HOME /spark
ENV PYSPARK_PYTHON /usr/local/bin/python
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.5-src.zip
ENV PATH $PATH:$SPARK_HOME/bin

# Fix configuration files for Spark
RUN mv $SPARK_HOME/conf/log4j2.properties.template $SPARK_HOME/conf/log4j2.properties
RUN mv $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
RUN mv $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh

# Install JupyterLab, PySpark, Kafka, Delta Lake & Boto3 for AWS
RUN pip install jupyterlab
RUN pip install pyspark==3.3.0
RUN pip install kafka-python==2.0.2
RUN pip install delta-spark==2.2.0
RUN pip install boto3

# Set working directory and clone your GitHub repo
WORKDIR /home/jupyter

# Clone your PySpark-Learning repository
RUN git clone https://github.com/Chandza/PySpark-Learning.git

# Fix Jupyter logging issue
RUN ipython profile create
RUN echo "c.IPKernelApp.capture_fd_output = False" >> "/root/.ipython/profile_default/ipython_kernel_config.py"

# Start JupyterLab automatically when the container starts
CMD ["python3", "-m", "jupyterlab", "--ip", "0.0.0.0", "--allow-root"]
