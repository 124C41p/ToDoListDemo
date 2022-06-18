const express = require('express')
const app = express()
const db = require('./db')

app.use(express.static('static'))
app.use(express.static('dist'))
app.use(express.json())

app.post('/api/list', async (req,res) => {
    res.send(await db.getList())
})

app.post('/api/add', async (req,res) => {
    await db.add(req.body.text)
    res.end()
})

app.post('/api/remove', async (req,res) => {
    await db.remove(req.body.id)
    res.end()
})

db.init().then(() => {
    app.listen(8080, () => {
        console.log('server running')
    })
})