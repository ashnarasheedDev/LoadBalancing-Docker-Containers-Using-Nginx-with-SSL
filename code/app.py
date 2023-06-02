from flask import Flask
import os
app = Flask(__name__)

@app.route('/')
def index():
    
  return '<h1><center>This is Flask Application - Version1 Nginx</center></h1>'

flask_port = os.getenv('FLASK_PORT',5000)
app.run(host='0.0.0.0', port=flask_port)
