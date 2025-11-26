# Dockerfile
#
# Dockerfile dùng để build image cho Flask web app.
# CodeBuild sẽ dùng Dockerfile này để build image và push lên ECR.

# Base image Python from Amazon ECR Public Gallery (no rate limit)
FROM public.ecr.aws/docker/library/python:3.11-slim

# Không tạo .pyc, log sạch sẽ hơn
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Tạo thư mục làm việc
WORKDIR /app

# Cài package system tối thiểu (nếu cần thêm pip build, curl,...)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy file requirements và cài thư viện Python
COPY app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ mã nguồn app vào container
COPY app/ /app/

# Expose port 5000 cho Flask/Gunicorn
EXPOSE 5000

# Lệnh chạy container
# Ở đây dùng gunicorn để chạy production-like server
# "app:app" nghĩa là: module app.py, biến app = Flask(...)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
