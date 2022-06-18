const db = require('./db')
const express = require('express')
const app = express()

app.use('/', express.static('public'))
app.use(express.json())

app.post('/api/v2/list', async (req,res) => {
    res.send(await db.getList());
})

app.post('/api/v2/add', async (req,res) => {
    await db.add(req.body.text)
    res.end()
})

app.post('/api/v2/remove', async (req,res) => {
    await db.remove(req.body.id);
    res.end()
})

db.init().then(() => {
    app.listen(8080, () => {
        console.log('server running')
    })
})