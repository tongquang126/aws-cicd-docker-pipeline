# app/app.py
#
# Một web app Flask rất đơn giản để demo.
# Khi container chạy, service sẽ lắng nghe ở cổng 5000.

from flask import Flask, jsonify

# Khởi tạo Flask app
app = Flask(__name__)


@app.route("/")
def index():
    """
    Endpoint chính, trả về một trang HTML rất đơn giản.
    """
    return """
    <html>
      <head>
        <title>AWS CI/CD Docker Pipeline Demo</title>
      </head>
      <body>
        <h1>Hello from aws-cicd-docker-pipeline!</h1>
        <p>This web app is built with Flask, Docker, CodeBuild, and CodePipeline.</p>
      </body>
    </html>
    """


@app.route("/health")
def health():
    """
    Endpoint để healthcheck. CodeBuild/Deploy có thể dùng để check.
    """
    return jsonify({"status": "ok"})


# Chạy app ở môi trường local (python app.py)
if __name__ == "__main__":
    # host="0.0.0.0" để container có thể expose ra bên ngoài
    app.run(host="0.0.0.0", port=5000, debug=True)
