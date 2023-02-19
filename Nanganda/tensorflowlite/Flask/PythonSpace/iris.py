"""
Create on 2023-02-06
author : Kenny
Description : Flutter와 Python의 AI 예측값 보내기
"""

from flask import Flask, jsonify, render_template, request
import joblib
import tensorflow as tf
import os
app = Flask(__name__)

@app.route("/iris")
def iris():
    
    wh = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./rf_iris.h5")
    sepalLength = float(request.args.get("sepalLength"))
    sepalWidth = float(request.args.get("sepalWidth"))
    petalLength = float(request.args.get("petalLength"))
    petalWidth = float(request.args.get("petalWidth"))
    
    clf = joblib.load(wh)
    pre = clf.predict([[sepalLength, sepalWidth, petalLength, petalWidth]])
    
    
    
    return jsonify({'result' : pre[0][5:]})



if __name__ == "__main__":
    app.run(host="localhost", port=5000, debug=True)
    
    