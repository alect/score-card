#!/usr/bin/python

import os
import urllib
import sys
import signal
import socket
from xml.dom.minidom import parse, parseString

class Score():
    def __init__(self, name, claimed_value):
        self.name = name
        self.value = claimed_value
        self.verified = False


if __name__ == '__main__':
    print 'starting verifier'
    
    # Of course we need the cross domain policy file to actually communicate with flash
    policy_file = ''
    with open('/home/bitdiddle/crossdomain.xml') as f:
        policy_file = f.read()

    # Now prepare to launch our swf verifier
    swffile = sys.argv[1]
    posting = os.getenv('POSTING')
    
    # Now retrieve the replay log, the username, and the claimed scores from the posting 
    username = ''
    log = ''
    claimed_scores = {}
    state_name = ''
    state_param_name = ''
    state_param_value = '' 

    try:
        document = parseString(posting)
        username_tags = document.getElementsByTagName('User')
        if len(username_tags) > 0:
            username = username_tags[0].getAttribute('name')
        score_tags = document.getElementsByTagName('Score')
        for score_tag in score_tags:
            score_name = score_tag.getAttribute('name')
            claimed_value = score_tag.getAttribute('value')
            claimed_scores[score_name] = Score(score_name, claimed_value)
        state_tags = document.getElementsByTagName('State')
        if len(state_tags) > 0:
            state_name = state_tags[0].getAttribute('name')
            state_param_name = state_tags[0].getAttribute('paramName')
            state_param_value = state_tags[0].getAttribute('paramValue')
        log_tags = document.getElementsByTagName('Log')
        if (len(log_tags) > 0):
            log = log_tags[0].firstChild.nodeValue.strip()
        
    except:
        print 'failed document parse'
        print posting
        exit(0)

    if username == '' or log == '' or len(claimed_scores) == 0:
        print 'failed username, log, or scores parse'
        print 'username: ' + username
        print 'log: ' + log
        print 'claimed_scores: ' + str(claimed_scores)
        exit(0)


    print posting

    # Look at the last frame in the log to figure out what the timeout is 
    timeout = None
    log_lines = log.split('\n')[1:]
    if len(log_lines) > 0:
        last_line = log_lines[-1].split('k')[0]
        try:
            last_frame = int(last_line)
            timeout = 22.0 + (last_frame*4)/30.0
        except:
            pass
    
    
    print 'timeout for local score server: ' + str(timeout)
    host = 'localhost'
    port = 0
    packet_size = 1024
    backlog = 5
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((host, port))
    s.settimeout(timeout)
    # Find out what our assigned port actually is
    port = s.getsockname()[1]
    s.listen(backlog)

    

    swfarg = '%s?%s\\&%s\\&%s' % (swffile, 'verifying=true', 'localScorePort=' + str(port), 'replayLog=' + urllib.quote(log))
    if state_name != '':
        swfarg += '\\&replayState=%s' % state_name
    if state_param_name != '' and state_param_value != '':
        swfarg += '\\&stateParamName=%s\\&stateParamValue=%s' % (state_param_name, state_param_value)
    #swfarg = '%s?%s' % (swffile, 'verifying=true')
    print 'swfarg is: ' + swfarg
    # Now that we have our swf argument, it's time to launch the firefox instance with the verifier
    pid = os.fork()
    if pid == 0:
        print 'launching firefox'
        os.system('/home/bitdiddle/run-firefox.sh %s' % swfarg)
        
    else:
        print 'now listening for scores'
        # Now we listen for official score verifications
        # Kill the system if we hit a timeout
        try:
            listening = True
            while listening:
                client, address = s.accept()
                connected = True
                while connected:
                    data = client.recv(packet_size)
                    print 'some data: ' + data
                    if not data:
                        connected = False
                        client.close()
                        continue
                    if data.strip().startswith('<policy-file-request/>'):
                        print 'policy file requested'
                        client.send(policy_file+'\0')
                    elif data.strip().startswith('<Hello/>'):
                        print 'Client Said Hello!'
                        connected = False
                        client.close()
                    elif data.strip().startswith('<ReplayEnd/>'):
                        listening = False
                        connected = False
                        client.close()
                    elif data.strip().startswith('<ScoreVerification>'):
                        print 'parsing verification'
                        try:
                            document = parseString(data)
                            score_tags = document.getElementsByTagName('Score')
                            for score_tag in score_tags:
                                score_name = score_tag.getAttribute('name')
                                claimed_value = score_tag.getAttribute('value')
                                if claimed_scores.has_key(score_name) and claimed_scores[score_name].value == claimed_value:
                                    claimed_scores[score_name].verified = True
                        except:
                            pass
                        connected = False
                        client.close()
        except:
            print 'Verification timed out!'
            pass
        os.kill(pid, signal.SIGKILL)
        
        fully_verified = True
        for score in claimed_scores.values():
            if not score.verified:
                fully_verified = False
        if fully_verified:
            print 'Fully verified!'
        else:
            print 'Suspicious!'
