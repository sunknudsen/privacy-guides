"use strict"

import "dotenv/config"

import clipboard from "clipboardy"

if (process.argv.length !== 3 || !process.argv[2].match(/http(s)?:\/\//)) {
  console.info("Usage: node copy-link.js selectedText")
  process.exit(1)
}

var text = process.argv[2]

if (process.env.LOCALHOST_PROXY) {
  text = text.replace(
    "https://raw.githubusercontent.com/sunknudsen/privacy-guides/master",
    process.env.LOCALHOST_PROXY
  )
}

clipboard.write(text)
