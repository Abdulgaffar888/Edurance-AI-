const uploadToS3 = async () => {
  throw new Error("AWS storage not configured - use local mode");
};
const getS3Url = () => {
  throw new Error("AWS storage not configured - use local mode");
};
module.exports = { uploadToS3, getS3Url };
