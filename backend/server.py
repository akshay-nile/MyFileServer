# This should be the first import statement for proper environment setup
import services.environment

from services.decorators import validate_path
from services.explorer import get_device_info, get_drives_info, get_items_info

from flask import Flask, jsonify, render_template, request
from werkzeug.exceptions import HTTPException


app = services.environment.configure(Flask(__name__))


# To serve the UI build from dist folder after packaging
@app.route('/', methods=['GET'])
def home():
    if services.environment.IS_DEV_ENV:
        return "<h1>Can not serve 'index.html' in Development Mode!</h1>"
    return render_template('index.html')


# To get info about drives or items at the given path
@app.route('/api/items', methods=['GET'])
@validate_path
def get_items(path):
    if path == '/':
        device = get_device_info()
        drives = get_drives_info()
        return jsonify({'device': device, 'drives': drives})
    options = dict()
    options['search'] = request.args.get('search', None)
    options['sort_by'] = request.args.get('sort_by', 'name')
    options['reverse'] = request.args.get('reverse', False)
    options['show_hidden'] = request.args.get('show_hidden', False)
    folders, files = get_items_info(path, **options)
    return jsonify({'folders': folders, 'files': files})


# Global http error handler to get jsonified error response
@app.errorhandler(HTTPException)
def handle_http_exception(error):
    response = {
        "error": error.name,
        "message": error.description,
        "code": error.code
    }
    return jsonify(response), error.code


if __name__ == '__main__':
    app.run(
        host=app.config.get('HOST'),
        port=app.config.get('PORT'),
        debug=app.config.get('DEBUG'),
        # ssl_context=app.config.get('SSL_CONTEXT'),
        # use_reloader=False
    )
