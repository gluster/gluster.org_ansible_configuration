from flask import Flask, request, Response
import os
import hmac

app = Flask(__name__)

# "It's a secret to everybody"
webhook_secret = os.getenv('SECRET')

# https://ryanharrison.co.uk/2018/09/04/validate-github-webhook-signatures.html
@app.route('/', methods=['POST', 'GET'])
def respond():
    if request.method == 'GET':
        return Response(status=200)
    if not "X-Hub-Signature" in request.headers:
        abort(400) # bad request if no header present

    if webhook_secret:
        signature = request.headers['X-Hub-Signature']
        payload = request.data
        secret = webhook_secret.encode()
    
        hmac_gen = hmac.new(secret, payload, hashlib.sha1)

        digest = "sha1=" + hmac_gen.hexdigest()
        if not hmac.compare_digest(digest, signature):
            abort(400) # if the signatures don't match, bad request not from GitHub

    event = request.headers['X-Github-Event']
    if event != 'issue_comment':
        return Response(status=200)

    j = request.json
    if j['action'] != 'created':
        return Response(status=200)

    if j['repository']['full_name'] != "gluster/project-infrastructure":
        return Response(status=200)

    print(j)
    # TODO 
    # check the format 
    # send the format

    return Response(status=200)

