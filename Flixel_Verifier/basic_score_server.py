import socket
import os
from xml.dom.minidom import parse, parseString


if __name__ == '__main__':
    # First, load up the cross domain policy for communicating with Flash applications
    policy_file = ''
    with open('crossdomain.xml') as f:
        policy_file = f.read()

    # Now load the database of games and their relevant information
    game_database = {}
    with open('game_database.db') as f:
        game_database = eval(f.read())

    host = 'ec2-23-20-243-120.compute-1.amazonaws.com'
    port = 50000
    packet_size = 1024
    backlog = 5
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((host, port))
    s.listen(backlog)
    while True:
        client, address = s.accept()
        connected = True
        while connected:
            # first, receive some data
            data = client.recv(packet_size)
            if data:
                if data.strip().startswith('<policy-file-request/>'):
                    client.send(policy_file+'\0')
                    print 'sending policy file'
                elif data.strip().startswith('<ScorePosting>'):
                    # If we have a score posting, receive the whole thing
                    posting = ''
                    while len(data):
                        posting += data
                        data = client.recv(packet_size)
                    client.close()
                    # try to parse the posting to figure out which game this is for
                    try:
                        document = parseString(posting)
                        game_tags = document.getElementsByTagName('Game')
                        if (len(game_tags) > 0):
                            game_name = game_tags[0].getAttribute('id')
                            if game_name == '' or not game_database.has_key(game_name):
                                print 'no such game: ' + game_name
                            else:
                                # Otherwise, it's time to send this posting to that game's particular handler
                                print 'Received score posting for game: ' + game_name
                                game_info = game_database[game_name]
                                game_dir = game_info['game_dir']
                                try:
                                    # Now fork and start up the handler
                                    if os.fork() == 0:
                                        os.chdir(os.getcwd() + '/' + game_dir)
                                        os.putenv('POSTING', posting)
                                        os.execl(os.getcwd() + '/post_handler', '')
                                except OSError as e:
                                    print e
                        else:
                            print 'no game tags'
                    except Exception as e:
                        # Just disconnect if the posting was malformed
                        print e
                    connected = False
                else:
                    client.close()
                    connected = False
                        

    
