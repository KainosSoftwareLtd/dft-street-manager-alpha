var soap = require('soap')

soap.createClient('http://localhost:15099/stockquote?wsdl', function (err, client) {
  if (err) throw err
  client.GetLastTradePrice({ tickerSymbol: 'AAPL' }, function (err, result) {
    if (err) throw err
    console.log(result)
  })
})
