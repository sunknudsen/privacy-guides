"use strict"

import "dotenv/config"
import express from "express"
import got from "got"
import fsExtra from "fs-extra"
import prettier from "prettier"
import handlebars from "handlebars"

const { pathExists, readFile } = fsExtra

const gfm = handlebars.compile(await readFile("./gfm.hbs", "utf8"))

const app = express()

app.get("/github-markdown.css", async (req, res, next) => {
  try {
    const path = "./node_modules/github-markdown-css/github-markdown.css"
    const exists = await pathExists(path)
    if (exists === false) {
      return next()
    }
    const css = await readFile(path, "utf8")
    res.setHeader("Content-Type", "text/css")
    return res.send(css)
  } catch (error) {
    console.log(error)
    return res.sendStatus(500)
  }
})

app.get("*.md", async (req, res, next) => {
  try {
    const path = `.${req.url}`
    const exists = await pathExists(path)
    if (exists === false) {
      return next()
    }
    const markdown = await readFile(path, "utf8")
    const response = await got.post("https://api.github.com/markdown", {
      json: {
        mode: "gfm",
        text: markdown,
      },
    })
    res.setHeader("Content-Type", "text/html")
    return res.send(
      prettier.format(
        gfm({
          markdown: response.body,
        }),
        {
          parser: "html",
        }
      )
    )
  } catch (error) {
    console.log(error)
    return res.sendStatus(500)
  }
})

app.use(
  express.static(".", {
    dotfiles: "ignore",
    index: false,
  })
)

const server = app.listen(process.env.PORT ?? 8080, () => {
  console.info(`Server listening on port ${server.address().port}`)
})
