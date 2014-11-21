express = require('express')
app = express()

app.use(express.static(__dirname + '/Public'));

app.get '/', (req, res)->
  require('fs').readFile 'index.html', 'utf8', (err, text)->
    res.send text

app.listen 1337
