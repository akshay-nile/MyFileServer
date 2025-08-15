import time
import socket
import threading
import requests


def get_local_ip():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.connect(('8.8.8.8', 80))
        ip = sock.getsockname()[0]
        if not ip.startswith('192.168.'):
            print('Not connected to WiFi')
    except OSError:
        ip = None
    finally:
        sock.close()
    return ip


def get_public_ip():
    try:
        ip = requests.get('https://ifconfig.me', timeout=5).text
    except requests.RequestException:
        ip = None
        print('Not connected to Internet')
    return ip


def get_user_selection():
    text = input('Run server on Public IP (Yes/No): ').lower().strip()

    # Entering Yes or simply y will get public ip
    if text.startswith('y'):
        ip = get_public_ip()
    # Entering No, n or simply nothing will get local ip
    elif text.startswith('n') or not text:
        ip = get_local_ip()
    # Otherwise use the localhost ip
    else:
        ip = '127.0.0.1'

    if ip is None:
        exit()
    print()     # Extra blank line to saperate the Flask's logs

    return ip


def publish_server_address(server_address: str):
    def my_socket():
        try:
            pythonanywhere = 'https://akshaynile.pythonanywhere.com/mysocket?socket='
            text = requests.post(pythonanywhere + server_address, timeout=5).text
            if text == 'success':
                print(' * Socket publication was successful √ \n')
        except requests.RequestException:
            time.sleep(1)
            print(' * Socket publication attempt failed ╳ \n')
    threading.Thread(target=my_socket).start()
