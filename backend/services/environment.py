import os
import sys
import platform
import importlib


# Identify (or guess) the current environment is dev or prod
IS_DEV_ENV = all(map(os.path.exists, ('.venv', 'pyproject.toml', 'uv.lock')))

# After packaging (i.e. prod environment) libs folder must be present
if not IS_DEV_ENV and os.path.isdir('libs'):
    # Add libs folder path to the beginning of sys.path to point to the local libs
    libs_path = os.path.abspath('libs')
    if libs_path not in sys.path:
        sys.path.insert(0, libs_path)

    # Create .nomedia file for Android to hide all the media files from Gallery
    if platform.system() == 'Linux' and not os.path.isfile('.nomedia'):
        open('.nomedia', 'w').close()


from flask import Flask
from services.network import publish_server_address, get_user_selection


def configure(app: Flask) -> Flask:
    if IS_DEV_ENV:
        app.config['HOST'] = 'localhost'
        app.config['PORT'] = 8849
        app.config['DEBUG'] = True

        # Enable CORS for all routes in dev mode only
        flask_cors = importlib.import_module('flask_cors')
        flask_cors.CORS(app)
    else:
        # Configure app to use dist folder to serve the UI build at home route '/'
        dist_path = os.path.abspath('dist')
        app.static_folder = dist_path
        app.template_folder = dist_path

        # Bind to actual network ip, set custom port and disable debug mode
        app.config['HOST'] = get_user_selection()
        app.config['PORT'] = 8849
        app.config['DEBUG'] = False

        # Set ssl-context to use RSA keys in production mode for https support
        # app.config['SSL_CONTEXT'] = ('ssl_keys/public.key', 'ssl_keys/private.key')

        # Publish the appropriate socket address to my website
        host, port = app.config['HOST'], app.config['PORT']
        host = host if host.count('.') == 3 else f'[{host}]'
        publish_server_address(f'http://{host}:{port}')

    return app
