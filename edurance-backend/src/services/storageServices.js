const AWS = require('aws-sdk');
const fs = require('fs');
const s3 = new AWS.S3({ region: 'us-east-1' });


module.exports = {
async uploadFile(localPath) {
const bucket = process.env.S3_BUCKET;
const key = `generated/${path.basename(localPath)}`;
const body = fs.readFileSync(localPath);
await s3.putObject({ Bucket: bucket, Key: key, Body: body, ACL: 'public-read' }).promise();
return `https://${bucket}.s3.amazonaws.com/${key}`;
}
};