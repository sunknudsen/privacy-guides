"use strict"

import "dotenv/config"
import clipboard from "clipboardy"

if (process.argv.length !== 3 || !process.argv[2].match(/http(s)?:\/\//)) {
  console.info("Usage: node copy-link.js selectedText")
  process.exit(1)
}

if (
  process.env.REPO === undefined ||
  process.env.LOCALHOST_PROXY === undefined
) {
  console.info("Missing environment variables")
  process.exit(1)
}

const selectedText = process.argv[2]

clipboard.write(
  selectedText.replace(
    `https://raw.githubusercontent.com/${process.env.REPO}/master`,
    process.env.LOCALHOST_PROXY
  )
)
