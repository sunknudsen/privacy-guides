"use strict"

import fsExtra from "fs-extra"
import { parse } from "path"
import execa from "execa"

const { readFile, writeFile } = fsExtra

if (
  process.argv.length !== 5 ||
  !process.argv[2].match(/\.md$/) ||
  !process.argv[3].match(/^[0-9]+$/) ||
  !process.argv[4].match(
    /^https:\/\/www\.youtube\.com\/watch\?v=([\w-]+)(&t=(\d+))?$/
  )
) {
  console.info(
    "Usage: node insert-youtube-player.js file lineNumber youtubeWatchUrl"
  )
  process.exit(1)
}

;(async () => {
  try {
    const file = process.argv[2]
    const lineNumber = process.argv[3]
    const youtubeWatchUrl = process.argv[4]
    const content = await readFile(file, "utf8")
    const lines = content.split("\n")
    const { stdout } = await execa("node", [
      "node_modules/youtube-player-screenshot/bin/youtube-player-screenshot.js",
      "--url",
      youtubeWatchUrl,
      "--type",
      "jpeg",
      "--output",
      parse(file).dir,
      "--privacy",
      "--stdout",
    ])
    let updatedContent = ""
    lines.forEach(function (line, index) {
      let lineBreak = "\n"
      if (index === lines.length - 1) {
        lineBreak = ""
      }
      if (index === parseInt(lineNumber) - 1) {
        updatedContent += `${stdout}${lineBreak}`
      } else {
        updatedContent += `${line}${lineBreak}`
      }
    })
    await writeFile(file, updatedContent)
  } catch (error) {
    console.error(error.message)
  }
})()
