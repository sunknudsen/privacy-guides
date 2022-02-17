"use strict"

import express from "express"

const app = express()

app.use(
  express.static(".", {
    dotfiles: "ignore",
    index: false,
  })
)

const server = app.listen(process.env.PORT ?? 8080, () => {
  console.info(`Server listening on port ${server.address().port}`)
})
