// deletes custom cloudformation resource described in
// https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-lambda-resource-delete/

let https = require("https")
let url = require("url")

let deleteRequest = { RequestType: 'Delete',
ServiceToken: process.env.SERVICE_TOKEN,
ResponseURL: process.env.RESPONSE_URL,
StackId: process.env.STACK_ID,
RequestId: process.env.REQUEST_ID,
LogicalResourceId: process.env.LOGICAL_RESOURCE_ID,
PhysicalResourceId: process.env.PHYSICAL_RESOURCE_ID,
ResourceType: process.env.RESOURCE_TYPE,
ResourceProperties:
{ ServiceToken: process.env.SERVICE_TOKEN,
S3ObjectName: process.env.OBJECT_NAME } }

let body = JSON.stringify({
  Status: "SUCCESS",
  PhysicalResourceId: deleteRequest.PhysicalResourceId,
  StackId: deleteRequest.StackId,
  RequestId: deleteRequest.RequestId,
  LogicalResourceId: deleteRequest.LogicalResourceId,
})

console.log("Response body:\n", body)

let parsedUrl = url.parse(deleteRequest.ResponseURL)
let options = {
  hostname: parsedUrl.hostname,
  port: 443,
  path: parsedUrl.path,
  method: "PUT",
  headers: {
      "content-type": "",
      "content-length": body.length
  }
}

let request = https.request(options, (response) => {
  console.log("Status code: " + response.statusCode)
  console.log("Status message: " + response.statusMessage)
})

request.on("error", (error) => {
  console.log("send(..) failed executing https.request(..): " + error)
})

request.write(body)
request.end()