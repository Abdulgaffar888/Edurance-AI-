const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');


module.exports = {
async renderMarpDeck(slideJson, opts = {}) {
// Convert slideJson to markdown (Marp) file
const md = slideJson.slides.map(s => `---\n# ${s.title}\n\n${s.content_markdown}\n`).join('\n');
const filename = `./tmp/deck-${Date.now()}.md`;
if (!fs.existsSync('./tmp')) fs.mkdirSync('./tmp');
fs.writeFileSync(filename, md);


const outPdf = filename.replace('.md', '.pdf');
// Call marp CLI
execSync(`npx @marp-team/marp-cli ${filename} -o ${outPdf}`);
return outPdf;
}
};