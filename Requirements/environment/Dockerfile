FROM python:3.11-slim                                                                                   
                  
WORKDIR /task

RUN pip install --no-cache-dir pandas

COPY input_artifacts/ /task/input_artifacts/

RUN mkdir -p /task/work