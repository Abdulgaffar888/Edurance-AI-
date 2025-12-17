module.exports = function solvePrompt(ocrText, grade, opts = {}) {
if (opts.hintOnly) return `Give a one-line hint for this problem for grade ${grade}: ${ocrText}`;
return `Provide JSON solution for grade ${grade}: ${ocrText} with steps and latex`;
};  