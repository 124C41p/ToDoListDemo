const express = require('express')
const app = express()
const db = require('./db')
const { setTimeout } = require('timers/promises')

app.use(express.static('static'))
app.use(express.static('dist'))
app.use(express.json())

async function simulateLag(delay) {
    delay = Math.min(Math.max(delay ?? 0, 0), 3000)
    if (delay > 0)
        await setTimeout(delay)
}

app.post('/api/list', async (req, res) => {
    await simulateLag(req.body.lag)
    res.send(await db.getList())
})

app.post('/api/add', async (req, res) => {
    await simulateLag(req.body.lag)
    await db.add(req.body.text)
    res.end()
})

app.post('/api/remove', async (req, res) => {
    await simulateLag(req.body.lag)
    await db.remove(req.body.id)
    res.end()
})

db.init().then(() => {
    app.listen(8080, () => {
        console.log('server running')
    })
})