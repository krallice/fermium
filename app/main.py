from flask import Flask, jsonify, request, json
import yaml

app = Flask(__name__)

## srozanc@MT1117s:~/azure/tfapi$ curl -X POST -H "Content-Type: application/json" -d '{"atomicnumber": 141, "elementname": "niobium" }' http://192.168.219.251:8080/v1/elements
## srozanc@MT1117s:~/azure/tfapi$ curl 192.168.219.251:8080/v1/elements

# Dataset:
elements = {}
elements[1] = {"elementname": "hydrogen", "atomicnumber": 1}
elements[2] = {"elementname": "helium", "atomicnumber": 2}
elements[3] = {"elementname": "lithium", "atomicnumber": 3}
elements[4] = {"elementname": "beryllium", "atomicnumber": 4}
elements[100] = {"elementname": "fermium", "atomicnumber": 100}

# JSON Responses (Default):

@app.route("/elements")
def get_elements():
    response = app.response_class(
        response=json.dumps(elements),
        #response=yaml.dump(elements),
        mimetype='application/json'
    )
    return response

@app.route("/elements/<atomicnumber>")
def get_elements_byatomic(atomicnumber):
    response = app.response_class(
        response=json.dumps(elements[int(atomicnumber)]),
        mimetype='application/json'
    )
    return response

# YAML Responses:

@app.route("/yaml-elements")
def get_yamlelements():
    response = app.response_class(
        response=yaml.dump(elements),
        mimetype='application/yaml'
    )
    return response

@app.route("/yaml-elements/<atomicnumber>")
def get_yamlelements_byatomic(atomicnumber):
    response = app.response_class(
        response=yaml.dump(elements[int(atomicnumber)]),
        mimetype='application/yaml'
    )
    return response

@app.route("/elements", methods=['PUT'])
def put_element():
    r = request.get_json()
    elements[r["atomicnumber"]] = r
    return '', 204

@app.route("/elements/<atomicnumber>", methods=['DELETE'])
def delete_element(atomicnumber):
    try:
        del elements[int(atomicnumber)]
    except KeyError:
        return '', 404
    return '', 200
