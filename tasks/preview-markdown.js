"use strict"

import "dotenv/config"
import open from "open"

if (process.argv.length < 3 || !process.argv[2].match(/\.md$/)) {
  console.info("Usage: node open-preview.js file")
  process.exit(1)
}

const file = process.argv[2]
const options = process.argv[3]

if (options === "use-proxy") {
  open(`${process.env.LOCALHOST_PROXY}/${file}`)
} else {
  open(`http://localhost:${process.env.PORT ?? 8080}/${file}`)
}
