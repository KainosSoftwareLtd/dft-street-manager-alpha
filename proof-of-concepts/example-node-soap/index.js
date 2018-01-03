var fs = require('fs')
var path = require('path')
var http = require('http')
var soap = require('soap')

var soapService = {
  StockQuoteService: {
    StockQuotePort: {
      GetLastTradePrice: function (args, cb, soapHeader) {
        if (soapHeader) {
          return { price: soapHeader.SomeToken }
        }
        if (args.tickerSymbol === 'trigger error') {
          throw new Error('triggered server error')
        } else if (args.tickerSymbol === 'Async') {
          return cb(null, { price: 19.56 })
        } else if (args.tickerSymbol === 'SOAP Fault v1.2') {
          throw new Error({
            Fault: {
              Code: {
                Value: 'soap:Sender',
                Subcode: { value: 'rpc:BadArguments' }
              },
              Reason: { Text: 'Processing Error' }
            }
          })
        } else if (args.tickerSymbol === 'SOAP Fault v1.1') {
          throw new Error({
            Fault: {
              faultcode: 'soap:Client.BadArguments',
              faultstring: 'Error while processing arguments'
            }
          })
        } else {
          return { price: 19.56 }
        }
      },

      SetTradePrice: function (args, cb, soapHeader) {
      },

      IsValidPrice: function (args, cb, soapHeader, req) {
        var validationError = {
          Fault: {
            Code: {
              Value: 'soap:Sender',
              Subcode: { value: 'rpc:BadArguments' }
            },
            Reason: { Text: 'Processing Error' },
            statusCode: 500
          }
        }

        var isValidPrice = function () {
          var price = args.price
          if (isNaN(price) || (price === ' ')) {
            return cb(validationError)
          }

          price = parseInt(price, 10)
          var validPrice = (price > 0 && price < Math.pow(10, 5))
          return cb(null, { valid: validPrice })
        }

        setTimeout(isValidPrice, 10)
      }
    }
  }
}

var wsdl = fs.readFileSync(path.join(__dirname, 'stockquote.wsdl'), 'utf8')

var server = http.createServer(function (req, res) {
  res.statusCode = 404
  res.end()
})

console.log('starting server on port 15099')

server.listen(15099, null, null, function () {
  soap.listen(server, '/stockquote', soapService, wsdl)
})
server.log = function (type, data) {
  console.log(`type: ${type}`)
}
