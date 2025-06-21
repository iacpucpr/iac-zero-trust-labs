
from flask import Flask
import os
import hvac

app = Flask(__name__)

@app.route("/")
def secret():
    client = hvac.Client(url='http://vault:8200', token='root')
    secret = client.secrets.kv.v2.read_secret_version(path='app/secret')
    return f"Segredo protegido: {secret['data']['data']['mensagem']}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
