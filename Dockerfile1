FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel
WORKDIR /app
RUN apt update -q && apt install -fyqq git
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN pip install .
ENTRYPOINT ["sleep", "inf"]
