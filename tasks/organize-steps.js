"use strict"

import fsExtra from "fs-extra"

const { readFile, writeFile } = fsExtra

const headingRegExp = /^## /
const stepRegExp = /^### Step [1-9][0-9]*(.*?)?:/

if (process.argv.length !== 3 || !process.argv[2].match(/\.md$/)) {
  console.info("Usage: node organize-steps.js file")
  process.exit(1)
}

;(async () => {
  try {
    const file = process.argv[2]
    const content = await readFile(file, "utf8")
    const lines = content.split("\n")
    let organizedContent = ""
    let step = 1
    lines.forEach(function (line, index) {
      let lineBreak = "\n"
      if (index === lines.length - 1) {
        lineBreak = ""
      }
      if (line.match(headingRegExp)) {
        step = 1
      }
      let match
      if ((match = line.match(stepRegExp))) {
        let disclaimer = ""
        if (match[1]) {
          disclaimer = match[1]
        }
        organizedContent += `${line.replace(
          stepRegExp,
          `### Step ${step}${disclaimer}:`
        )}${lineBreak}`
        step++
      } else {
        organizedContent += `${line}${lineBreak}`
      }
    })
    await writeFile(file, organizedContent)
  } catch (error) {
    console.error(error)
  }
})()
