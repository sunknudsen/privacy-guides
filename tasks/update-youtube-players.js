"use strict"

import readdirp from "readdirp"
import fsExtra from "fs-extra"
import { parse, join } from "path"
import execa from "execa"

const { readFile, writeFile, remove } = fsExtra

const playerRegExp = /\[\!\[.*?\]\((.*?\.png)\)\]\((.*?) ".*?"\)/

;(async () => {
  try {
    console.info("Updating YouTube players…")
    const options = {
      fileFilter: "*.md",
      directoryFilter: "!node_modules",
    }
    for await (const file of readdirp(process.cwd(), options)) {
      const content = await readFile(file.fullPath, "utf8")
      const lines = content.split("\n")
      let updatedContent = ""
      for (const [index, line] of lines.entries()) {
        let lineBreak = "\n"
        if (index === lines.length - 1) {
          lineBreak = ""
        }
        let match
        if ((match = line.match(playerRegExp))) {
          const dir = parse(file.fullPath).dir
          const imagePath = match[1]
          const youtubeWatchUrl = match[2]
          console.info(`Processing ${file.path}…`)
          await remove(join(dir, imagePath))
          const { stdout } = await execa("node", [
            "node_modules/youtube-player-screenshot/bin/youtube-player-screenshot.js",
            "--url",
            youtubeWatchUrl,
            "--width",
            1360,
            "--height",
            764,
            "--type",
            "jpeg",
            "--output",
            dir,
            "--privacy",
            "--stdout",
          ])
          updatedContent += `${stdout}${lineBreak}`
        } else {
          updatedContent += `${line}${lineBreak}`
        }
      }
      await writeFile(file.fullPath, updatedContent)
    }
    console.info("Done")
  } catch (error) {
    console.error(error.message)
  }
})()
